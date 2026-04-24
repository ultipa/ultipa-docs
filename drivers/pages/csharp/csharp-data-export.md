# Data Export

The GQLDB C# driver provides streaming export capabilities for efficiently extracting large amounts of data from the database.

## Export Methods

| Method | Description |
|--------|-------------|
| `ExportAsync(config, callback)` | Export graph data with full configuration |

## Unified Export

### ExportAsync()

Export nodes and/or edges in JSON Lines format with streaming:

```csharp
using Gqldb;

var config = new GqldbConfig { Hosts = { "localhost:60061" } };

using var client = new GqldbClient(config);
await client.LoginAsync("admin", "password");

var exportConfig = new ExportConfig
{
    GraphName = "myGraph",
    BatchSize = 1000,
    ExportNodes = true,
    ExportEdges = true
};

await client.ExportAsync(exportConfig, async chunk =>
{
    var data = System.Text.Encoding.UTF8.GetString(chunk.Data);
    var lines = data.Trim().Split('\n');

    foreach (var line in lines)
    {
        if (!string.IsNullOrEmpty(line))
        {
            Console.WriteLine(line);
        }
    }

    if (chunk.IsFinal && chunk.Stats != null)
    {
        Console.WriteLine($"\nExport complete:");
        Console.WriteLine($"  Nodes: {chunk.Stats.NodesExported}");
        Console.WriteLine($"  Edges: {chunk.Stats.EdgesExported}");
        Console.WriteLine($"  Bytes: {chunk.Stats.BytesWritten}");
        Console.WriteLine($"  Duration: {chunk.Stats.DurationMs}ms");
    }
});
```

### ExportConfig Class

```csharp
public class ExportConfig
{
    public string GraphName { get; set; } = "";
    public int BatchSize { get; set; } = 1000;
    public bool ExportNodes { get; set; } = true;
    public bool ExportEdges { get; set; } = true;
    public List<string> NodeLabels { get; set; } = new();
    public List<string> EdgeLabels { get; set; } = new();
    public bool IncludeMetadata { get; set; } = true;
}
```

### ExportResult Class

```csharp
public class ExportResult
{
    public byte[] Data { get; set; }
    public bool IsFinal { get; set; }
    public ExportStats? Stats { get; set; }
}
```

### ExportStats Class

```csharp
public class ExportStats
{
    public long NodesExported { get; set; }
    public long EdgesExported { get; set; }
    public long BytesWritten { get; set; }
    public long DurationMs { get; set; }
}
```

## Filtering Exports

### Export Specific Labels

```csharp
// Export only User nodes and Follows edges
var exportConfig = new ExportConfig
{
    GraphName = "socialGraph",
    ExportNodes = true,
    ExportEdges = true,
    NodeLabels = { "User", "Company" },
    EdgeLabels = { "Follows", "WorksAt" }
};

await client.ExportAsync(exportConfig, async chunk =>
{
    // Process chunk
});
```

### Export Only Nodes

```csharp
var exportConfig = new ExportConfig
{
    GraphName = "myGraph",
    ExportNodes = true,
    ExportEdges = false
};

await client.ExportAsync(exportConfig, async chunk => { /* ... */ });
```

### Export Only Edges

```csharp
var exportConfig = new ExportConfig
{
    GraphName = "myGraph",
    ExportNodes = false,
    ExportEdges = true
};

await client.ExportAsync(exportConfig, async chunk => { /* ... */ });
```

## Writing to File

```csharp
async Task ExportToFile(GqldbClient client, string graphName, string outputPath)
{
    var exportConfig = new ExportConfig
    {
        GraphName = graphName,
        BatchSize = 5000,
        ExportNodes = true,
        ExportEdges = true
    };

    using var fs = File.OpenWrite(outputPath);

    await client.ExportAsync(exportConfig, async chunk =>
    {
        await fs.WriteAsync(chunk.Data);

        if (chunk.IsFinal)
        {
            await fs.FlushAsync();
            if (chunk.Stats != null)
            {
                Console.WriteLine(
                    $"Export complete: {chunk.Stats.NodesExported} nodes, " +
                    $"{chunk.Stats.EdgesExported} edges"
                );
            }
        }
    });
}

// Usage
await ExportToFile(client, "myGraph", "export.jsonl");
```

## Collecting to Memory

```csharp
using System.Text.Json;

async Task<(List<JsonDocument> Nodes, List<JsonDocument> Edges)> ExportToMemory(
    GqldbClient client, string graphName)
{
    var nodes = new List<JsonDocument>();
    var edges = new List<JsonDocument>();

    var exportConfig = new ExportConfig
    {
        GraphName = graphName,
        BatchSize = 1000
    };

    await client.ExportAsync(exportConfig, async chunk =>
    {
        var data = System.Text.Encoding.UTF8.GetString(chunk.Data);
        foreach (var line in data.Trim().Split('\n'))
        {
            if (string.IsNullOrEmpty(line)) continue;

            var doc = JsonDocument.Parse(line);
            var type = doc.RootElement.GetProperty("_type").GetString();

            if (type == "node")
                nodes.Add(doc);
            else if (type == "edge")
                edges.Add(doc);
        }
    });

    Console.WriteLine($"Collected {nodes.Count} nodes and {edges.Count} edges");
    return (nodes, edges);
}

// Usage
var (exportedNodes, exportedEdges) = await ExportToMemory(client, "myGraph");
```

## Complete Example

```csharp
using Gqldb;
using System.Text;
using System.Text.Json;

async Task Main()
{
    var config = new GqldbConfig
    {
        Hosts = { "localhost:60061" },
        TimeoutSeconds = 60
    };

    using var client = new GqldbClient(config);
    await client.LoginAsync("admin", "password");

    // Create and populate test graph
    await client.CreateGraphAsync("exportDemo");
    await client.UseGraphAsync("exportDemo");

    await client.GqlAsync(@"
        INSERT (a:User {_id: 'u1', name: 'Alice', age: 30}),
               (b:User {_id: 'u2', name: 'Bob', age: 25}),
               (c:Company {_id: 'c1', name: 'Acme Inc'}),
               (a)-[:Follows {since: '2023-01-01'}]->(b),
               (a)-[:WorksAt {role: 'Engineer'}]->(c)
    ");

    // Export to file
    Console.WriteLine("=== Export to File ===");
    var outputPath = "graph-export.jsonl";

    var exportConfig = new ExportConfig
    {
        GraphName = "exportDemo",
        BatchSize = 100,
        ExportNodes = true,
        ExportEdges = true,
        IncludeMetadata = true
    };

    var totalRecords = 0;
    using (var fs = File.OpenWrite(outputPath))
    {
        await client.ExportAsync(exportConfig, async chunk =>
        {
            await fs.WriteAsync(chunk.Data);
            var data = Encoding.UTF8.GetString(chunk.Data);
            totalRecords += data.Trim().Split('\n').Count(l => !string.IsNullOrEmpty(l));

            if (chunk.IsFinal)
            {
                await fs.FlushAsync();
                Console.WriteLine($"  Records exported: {totalRecords}");
                if (chunk.Stats != null)
                {
                    Console.WriteLine($"  Nodes: {chunk.Stats.NodesExported}");
                    Console.WriteLine($"  Edges: {chunk.Stats.EdgesExported}");
                    Console.WriteLine($"  Size: {chunk.Stats.BytesWritten} bytes");
                }
            }
        });
    }

    // Read and display the file
    Console.WriteLine("\n=== Exported Data ===");
    foreach (var line in File.ReadLines(outputPath))
    {
        Console.WriteLine($"  {line}");
    }

    // Export filtered data
    Console.WriteLine("\n=== Export Only Users ===");
    var filteredConfig = new ExportConfig
    {
        GraphName = "exportDemo",
        ExportNodes = true,
        ExportEdges = false,
        NodeLabels = { "User" }
    };

    await client.ExportAsync(filteredConfig, async chunk =>
    {
        var data = Encoding.UTF8.GetString(chunk.Data);
        foreach (var line in data.Trim().Split('\n'))
        {
            if (string.IsNullOrEmpty(line)) continue;
            var doc = JsonDocument.Parse(line);
            var name = doc.RootElement
                .GetProperty("properties")
                .GetProperty("name")
                .GetString();
            Console.WriteLine($"  User: {name}");
        }
    });

    // Cleanup
    File.Delete(outputPath);
    await client.DropGraphAsync("exportDemo");
}
```
