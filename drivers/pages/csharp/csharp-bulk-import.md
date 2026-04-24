# Bulk Import

The GQLDB C# driver provides bulk import functionality for high-throughput data ingestion with optimized write performance.

## Bulk Import Methods

| Method | Description |
|--------|-------------|
| `StartBulkImportAsync(graphName, options)` | Start a bulk import session |
| `EndBulkImportAsync(sessionId)` | End the bulk import session |
| `AbortBulkImportAsync(sessionId)` | Cancel session without final sync |
| `GetBulkImportStatusAsync(sessionId)` | Get session status |

## Basic Usage

```csharp
using Gqldb;
using Gqldb.Types;

var config = new GqldbConfig { Hosts = { "localhost:60061" } };

using var client = new GqldbClient(config);
await client.LoginAsync("admin", "password");
await client.UseGraphAsync("myGraph");

// Start bulk import session
var session = await client.StartBulkImportAsync("myGraph");

Console.WriteLine($"Session ID: {session.SessionId}");

try
{
    // Insert nodes in batches
    foreach (var batch in nodeBatches)
    {
        var insertConfig = new InsertNodesConfig
        {
            BulkImportSessionId = session.SessionId
        };
        await client.InsertNodesBatchAutoAsync("myGraph", batch, insertConfig);
    }

    // Insert edges in batches
    foreach (var batch in edgeBatches)
    {
        var insertConfig = new InsertEdgesConfig
        {
            BulkImportSessionId = session.SessionId
        };
        await client.InsertEdgesBatchAutoAsync("myGraph", batch, insertConfig);
    }

    // End session
    var result = await client.EndBulkImportAsync(session.SessionId);
    Console.WriteLine($"Import complete: {result.TotalRecords} records, {result.Message}");
}
catch
{
    // Abort on error
    await client.AbortBulkImportAsync(session.SessionId);
    throw;
}
```

## Starting a Bulk Import Session

### StartBulkImportAsync()

```csharp
var options = new BulkImportOptions
{
    EstimatedNodes = 1000000,   // Hint for pre-allocating node ID cache
    EstimatedEdges = 5000000    // Hint for edge batch sizing
};

var session = await client.StartBulkImportAsync("myGraph", options);
```

### BulkImportSession Class

```csharp
public class BulkImportSession
{
    public string SessionId { get; set; }
    public bool Success { get; set; }
    public string Message { get; set; }
}
```

## Ending a Bulk Import

### EndBulkImportAsync()

Complete the bulk import session:

```csharp
var result = await client.EndBulkImportAsync(session.SessionId);

Console.WriteLine("Bulk import completed:");
Console.WriteLine($"  Success: {result.Success}");
Console.WriteLine($"  Total records: {result.TotalRecords}");
Console.WriteLine($"  Message: {result.Message}");
```

### AbortBulkImportAsync()

Cancel without final sync (discards unflushed data):

```csharp
await client.AbortBulkImportAsync(session.SessionId);
Console.WriteLine("Bulk import aborted");
```

## Monitoring Status

### GetBulkImportStatusAsync()

```csharp
var status = await client.GetBulkImportStatusAsync(session.SessionId);

Console.WriteLine($"Active: {status.IsActive}");
Console.WriteLine($"Graph: {status.GraphName}");
Console.WriteLine($"Records: {status.RecordCount}");
Console.WriteLine($"Last checkpoint count: {status.LastCheckpointCount}");
Console.WriteLine($"Created at: {status.CreatedAt}");
Console.WriteLine($"Last activity: {status.LastActivity}");
```

## Batch Processing Pattern

```csharp
async Task BulkImportData(
    GqldbClient client, string graphName,
    List<NodeData> nodes, List<EdgeData> edges, int batchSize = 5000)
{
    var session = await client.StartBulkImportAsync(graphName);

    try
    {
        // Import nodes
        var totalNodes = 0L;
        for (int i = 0; i < nodes.Count; i += batchSize)
        {
            var batch = nodes.GetRange(i, Math.Min(batchSize, nodes.Count - i));
            var insertConfig = new InsertNodesConfig
            {
                BulkImportSessionId = session.SessionId
            };
            var result = await client.InsertNodesBatchAutoAsync(graphName, batch, insertConfig);
            totalNodes += result.NodeCount;
            Console.WriteLine($"Imported {totalNodes} nodes...");
        }

        // Import edges
        var totalEdges = 0L;
        for (int i = 0; i < edges.Count; i += batchSize)
        {
            var batch = edges.GetRange(i, Math.Min(batchSize, edges.Count - i));
            var edgeConfig = new InsertEdgesConfig
            {
                BulkImportSessionId = session.SessionId
            };
            var result = await client.InsertEdgesBatchAutoAsync(graphName, batch, edgeConfig);
            totalEdges += result.EdgeCount;
            Console.WriteLine($"Imported {totalEdges} edges...");
        }

        // Complete
        await client.EndBulkImportAsync(session.SessionId);
    }
    catch
    {
        await client.AbortBulkImportAsync(session.SessionId);
        throw;
    }
}
```

## Result Classes

### EndBulkImportResult

```csharp
public class EndBulkImportResult
{
    public bool Success { get; set; }
    public long TotalRecords { get; set; }
    public string Message { get; set; }
}
```

### BulkImportStatus

```csharp
public class BulkImportStatus
{
    public bool IsActive { get; set; }
    public string GraphName { get; set; }
    public long RecordCount { get; set; }
    public long LastCheckpointCount { get; set; }
    public long CreatedAt { get; set; }
    public long LastActivity { get; set; }
}
```

## Complete Example

```csharp
using Gqldb;
using Gqldb.Types;
using System.Diagnostics;

async Task Main()
{
    var config = new GqldbConfig
    {
        Hosts = { "localhost:60061" },
        TimeoutSeconds = 300  // 5 minute timeout for bulk operations
    };

    using var client = new GqldbClient(config);
    await client.LoginAsync("admin", "password");
    await client.CreateGraphAsync("bulkDemo");
    await client.UseGraphAsync("bulkDemo");

    // Generate test data
    Console.WriteLine("=== Generating Test Data ===");
    var numNodes = 100000;
    var numEdges = 500000;

    var nodes = Enumerable.Range(0, numNodes).Select(i => new NodeData
    {
        Labels = { "TestNode" },
        Properties = { ["index"] = i, ["value"] = $"value_{i}" }
    }).ToList();

    var edges = Enumerable.Range(0, numEdges).Select(i => new EdgeData
    {
        Label = "TestEdge",
        FromNodeId = $"n{i % numNodes}",
        ToNodeId = $"n{(i + 1) % numNodes}",
        Properties = { ["weight"] = i * 0.1 }
    }).ToList();

    Console.WriteLine($"  Generated {nodes.Count} nodes and {edges.Count} edges");

    // Start bulk import
    Console.WriteLine("\n=== Starting Bulk Import ===");
    var sw = Stopwatch.StartNew();

    var options = new BulkImportOptions
    {
        EstimatedNodes = numNodes,
        EstimatedEdges = numEdges
    };
    var session = await client.StartBulkImportAsync("bulkDemo", options);
    Console.WriteLine($"  Session ID: {session.SessionId}");

    try
    {
        // Import nodes in batches
        Console.WriteLine("\n=== Importing Nodes ===");
        var batchSize = 10000;
        var importedNodes = 0L;

        for (int i = 0; i < nodes.Count; i += batchSize)
        {
            var batch = nodes.GetRange(i, Math.Min(batchSize, nodes.Count - i));
            var insertConfig = new InsertNodesConfig
            {
                BulkImportSessionId = session.SessionId
            };
            var result = await client.InsertNodesBatchAutoAsync("bulkDemo", batch, insertConfig);
            importedNodes += result.NodeCount;

            if (importedNodes % 50000 == 0)
            {
                var status = await client.GetBulkImportStatusAsync(session.SessionId);
                Console.WriteLine($"  Progress: {importedNodes} nodes, records: {status.RecordCount}");
            }
        }
        Console.WriteLine($"  Total nodes imported: {importedNodes}");

        // Import edges in batches
        Console.WriteLine("\n=== Importing Edges ===");
        var importedEdges = 0L;

        for (int i = 0; i < edges.Count; i += batchSize)
        {
            var batch = edges.GetRange(i, Math.Min(batchSize, edges.Count - i));
            var edgeConfig = new InsertEdgesConfig
            {
                BulkImportSessionId = session.SessionId
            };
            var result = await client.InsertEdgesBatchAutoAsync("bulkDemo", batch, edgeConfig);
            importedEdges += result.EdgeCount;

            if (importedEdges % 100000 == 0)
            {
                Console.WriteLine($"  Progress: {importedEdges} edges");
            }
        }
        Console.WriteLine($"  Total edges imported: {importedEdges}");

        // End bulk import
        Console.WriteLine("\n=== Completing Bulk Import ===");
        var endResult = await client.EndBulkImportAsync(session.SessionId);

        sw.Stop();
        Console.WriteLine($"  Completed in {sw.Elapsed.TotalSeconds:F2} seconds");
        Console.WriteLine($"  Success: {endResult.Success}");
        Console.WriteLine($"  Total records: {endResult.TotalRecords}");
        Console.WriteLine($"  Message: {endResult.Message}");

        // Verify
        Console.WriteLine("\n=== Verification ===");
        var response = await client.GqlAsync("MATCH (n:TestNode) RETURN count(n)");
        Console.WriteLine($"  Node count: {response.SingleInt()}");

        response = await client.GqlAsync("MATCH ()-[e:TestEdge]->() RETURN count(e)");
        Console.WriteLine($"  Edge count: {response.SingleInt()}");
    }
    catch (Exception e)
    {
        Console.WriteLine($"\nError: {e.Message}");
        Console.WriteLine("Aborting bulk import...");
        await client.AbortBulkImportAsync(session.SessionId);
        throw;
    }
    finally
    {
        await client.DropGraphAsync("bulkDemo");
    }
}
```
