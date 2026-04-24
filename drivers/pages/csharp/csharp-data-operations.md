# Data Operations

The GQLDB C# driver provides methods for inserting, updating, and deleting nodes and edges in the graph.

## Data Methods

| Method | Description |
|--------|-------------|
| `InsertNodesBatchAutoAsync(graphName, nodes, config)` | Insert multiple nodes via gRPC |
| `InsertEdgesBatchAutoAsync(graphName, edges, config)` | Insert multiple edges via gRPC |
| `InsertNodesAsync(nodes, config)` | Insert nodes via GQL INSERT |
| `InsertEdgesAsync(edges, config)` | Insert edges via GQL INSERT |
| `DeleteNodesAsync(graphName, nodeIds, labels, where)` | Delete nodes |
| `DeleteEdgesAsync(graphName, edgeIds, label, where)` | Delete edges |

## Inserting Nodes

### InsertNodesBatchAutoAsync()

Insert multiple nodes into a graph via gRPC:

```csharp
using Gqldb;
using Gqldb.Types;

var config = new GqldbConfig { Hosts = { "localhost:60061" } };

using var client = new GqldbClient(config);
await client.LoginAsync("admin", "password");
await client.UseGraphAsync("myGraph");

// Create node data
var nodes = new List<NodeData>
{
    new NodeData
    {
        Labels = { "User" },
        Properties = { ["name"] = "Alice", ["age"] = 30, ["email"] = "alice@example.com" }
    },
    new NodeData
    {
        Labels = { "User" },
        Properties = { ["name"] = "Bob", ["age"] = 25, ["email"] = "bob@example.com" }
    },
    new NodeData
    {
        Labels = { "User", "Admin" },
        Properties = { ["name"] = "Charlie", ["age"] = 35 }
    }
};

// Insert nodes
var result = await client.InsertNodesBatchAutoAsync("myGraph", nodes);

Console.WriteLine($"Success: {result.Success}");
Console.WriteLine($"Inserted: {result.NodeCount} nodes");
Console.WriteLine($"Node IDs: {string.Join(", ", result.NodeIds)}");
```

### InsertNodesAsync() (GQL-based)

Insert nodes using GQL INSERT statements:

```csharp
var nodes = new List<NodeData>
{
    new NodeData
    {
        Labels = { "User" },
        Properties = { ["name"] = "Alice", ["age"] = 30 }
    }
};

await client.InsertNodesAsync(nodes);
```

### NodeData Class

```csharp
public class NodeData
{
    public string Id { get; set; } = "";
    public List<string> Labels { get; set; } = new();
    public Dictionary<string, object?> Properties { get; set; } = new();
}
```

### Insert Options

```csharp
var insertConfig = new InsertNodesConfig
{
    Overwrite = true  // Overwrite if exists
};

var result = await client.InsertNodesBatchAutoAsync("myGraph", nodes, insertConfig);
```

## Inserting Edges

### InsertEdgesBatchAutoAsync()

Insert multiple edges into a graph via gRPC:

```csharp
using Gqldb.Types;

var edges = new List<EdgeData>
{
    new EdgeData
    {
        Label = "Follows",
        FromNodeId = "u1",
        ToNodeId = "u2",
        Properties = { ["since"] = "2023-01-15" }
    },
    new EdgeData
    {
        Label = "Follows",
        FromNodeId = "u2",
        ToNodeId = "u3",
        Properties = { ["since"] = "2023-06-20" }
    },
    new EdgeData
    {
        Label = "Knows",
        FromNodeId = "u1",
        ToNodeId = "u3",
        Properties = { ["years"] = 5 }
    }
};

var result = await client.InsertEdgesBatchAutoAsync("myGraph", edges);

Console.WriteLine($"Success: {result.Success}");
Console.WriteLine($"Inserted: {result.EdgeCount} edges");
Console.WriteLine($"Skipped: {result.SkippedCount}");
```

### InsertEdgesAsync() (GQL-based)

Insert edges using GQL INSERT statements:

```csharp
var edges = new List<EdgeData>
{
    new EdgeData
    {
        Label = "Follows",
        FromNodeId = "u1",
        ToNodeId = "u2",
        Properties = { ["since"] = "2024-01-01" }
    }
};

await client.InsertEdgesAsync(edges);
```

### EdgeData Class

```csharp
public class EdgeData
{
    public string Label { get; set; } = "";
    public string FromNodeId { get; set; } = "";
    public string ToNodeId { get; set; } = "";
    public Dictionary<string, object?> Properties { get; set; } = new();
}
```

### Edge Insert Options

```csharp
var edgeConfig = new InsertEdgesConfig
{
    SkipInvalidNodes = true  // Skip edges with invalid endpoints
};

var result = await client.InsertEdgesBatchAutoAsync("myGraph", edges, edgeConfig);
```

## Per-call Configuration

`InsertNodesAsync()` and `InsertEdgesAsync()` accept an optional `InsertConfig` for per-call graph routing and insert mode:

```csharp
using Gqldb;
using Gqldb.Types;

// Target a specific graph without UseGraphAsync()
var cfg = new InsertConfig
{
    GraphName = "myGraph",
    InsertType = InsertType.Overwrite,  // Normal (default) or Overwrite
    Timeout = 60                        // Optional per-call timeout (seconds)
};

await client.InsertNodesAsync(nodes, cfg);
await client.InsertEdgesAsync(edges, cfg);
```

## Deleting Nodes

### DeleteNodesAsync()

Delete nodes from the graph:

```csharp
// Delete by IDs
var result = await client.DeleteNodesAsync(
    "myGraph",
    nodeIds: new List<string> { "u1", "u2", "u3" }
);
Console.WriteLine($"Deleted: {result.DeletedCount} nodes");

// Delete by labels
result = await client.DeleteNodesAsync(
    "myGraph",
    labels: new List<string> { "TempUser" }
);

// Delete with WHERE clause
result = await client.DeleteNodesAsync(
    "myGraph",
    labels: new List<string> { "User" },
    where: "n.age < 18"
);
```

## Deleting Edges

### DeleteEdgesAsync()

Delete edges from the graph:

```csharp
// Delete by IDs
var result = await client.DeleteEdgesAsync(
    "myGraph",
    edgeIds: new List<string> { "e1", "e2" }
);
Console.WriteLine($"Deleted: {result.DeletedCount} edges");

// Delete by label
result = await client.DeleteEdgesAsync(
    "myGraph",
    label: "TempConnection"
);

// Delete with WHERE clause
result = await client.DeleteEdgesAsync(
    "myGraph",
    label: "Follows",
    where: "e.since < '2020-01-01'"
);
```

## Using GQL for Data Operations

You can also use GQL queries for data operations:

```csharp
// Insert with GQL
await client.GqlAsync(@"
    INSERT (a:User {_id: 'u1', name: 'Alice'}),
           (b:User {_id: 'u2', name: 'Bob'}),
           (a)-[:Follows {since: '2024-01-01'}]->(b)
");

// Update with GQL
await client.GqlAsync("MATCH (u:User {_id: 'u1'}) SET u.age = 31");

// Delete with GQL
await client.GqlAsync("MATCH (u:User {_id: 'u1'}) DELETE u");
```

## Result Classes

### InsertNodesResult

```csharp
public class InsertNodesResult
{
    public bool Success { get; set; }
    public List<string> NodeIds { get; set; }
    public long NodeCount { get; set; }
    public string Message { get; set; }
}
```

### InsertEdgesResult

```csharp
public class InsertEdgesResult
{
    public bool Success { get; set; }
    public List<string> EdgeIds { get; set; }
    public long EdgeCount { get; set; }
    public string Message { get; set; }
    public long SkippedCount { get; set; }
}
```

### DeleteResult

```csharp
public class DeleteResult
{
    public bool Success { get; set; }
    public long DeletedCount { get; set; }
    public string Message { get; set; }
}
```

## Complete Example

```csharp
using Gqldb;
using Gqldb.Types;

async Task Main()
{
    var config = new GqldbConfig
    {
        Hosts = { "localhost:60061" },
        TimeoutSeconds = 30
    };

    using var client = new GqldbClient(config);
    await client.LoginAsync("admin", "password");
    await client.CreateGraphAsync("dataOpsDemo");
    await client.UseGraphAsync("dataOpsDemo");

    // Insert nodes
    Console.WriteLine("=== Inserting Nodes ===");
    var users = new List<NodeData>
    {
        new() { Labels = { "User" }, Properties = { ["name"] = "Alice", ["age"] = 30, ["active"] = true } },
        new() { Labels = { "User" }, Properties = { ["name"] = "Bob", ["age"] = 25, ["active"] = true } },
        new() { Labels = { "User" }, Properties = { ["name"] = "Charlie", ["age"] = 35, ["active"] = false } },
        new() { Labels = { "User", "Admin" }, Properties = { ["name"] = "Diana", ["age"] = 28, ["active"] = true } },
    };

    var insertConfig = new InsertNodesConfig { Overwrite = true };
    var result = await client.InsertNodesBatchAutoAsync("dataOpsDemo", users, insertConfig);
    Console.WriteLine($"  Inserted {result.NodeCount} users");

    // Insert edges
    Console.WriteLine("\n=== Inserting Edges ===");
    var relationships = new List<EdgeData>
    {
        new() { Label = "Follows", FromNodeId = "u1", ToNodeId = "u2", Properties = { ["since"] = "2023-01" } },
        new() { Label = "Follows", FromNodeId = "u2", ToNodeId = "u3", Properties = { ["since"] = "2023-03" } },
        new() { Label = "Follows", FromNodeId = "u1", ToNodeId = "u4", Properties = { ["since"] = "2023-06" } },
        new() { Label = "Knows", FromNodeId = "u3", ToNodeId = "u4", Properties = { ["years"] = 3 } },
    };

    var edgeConfig = new InsertEdgesConfig { SkipInvalidNodes = true };
    var edgeResult = await client.InsertEdgesBatchAutoAsync("dataOpsDemo", relationships, edgeConfig);
    Console.WriteLine($"  Inserted {edgeResult.EdgeCount} relationships");

    // Verify data
    Console.WriteLine("\n=== Current Data ===");
    var response = await client.GqlAsync(
        "MATCH (n:User) RETURN n.name, n.age, n.active ORDER BY n.name"
    );
    foreach (var row in response.Rows)
    {
        Console.WriteLine($"  {row.GetString(0)}: age={row.GetInt(1)}, active={row.GetBool(2)}");
    }

    // Delete inactive users
    Console.WriteLine("\n=== Delete Inactive Users ===");
    var deleteResult = await client.DeleteNodesAsync(
        "dataOpsDemo",
        labels: new List<string> { "User" },
        where: "n.active = false"
    );
    Console.WriteLine($"  Deleted {deleteResult.DeletedCount} inactive users");

    // Delete old relationships
    Console.WriteLine("\n=== Delete Old Relationships ===");
    var edgeDeleteResult = await client.DeleteEdgesAsync(
        "dataOpsDemo",
        label: "Follows",
        where: "e.since < '2023-04'"
    );
    Console.WriteLine($"  Deleted {edgeDeleteResult.DeletedCount} old relationships");

    // Final state
    Console.WriteLine("\n=== Final Data ===");
    response = await client.GqlAsync("MATCH (n:User) RETURN n.name ORDER BY n.name");
    var names = response.Rows.Select(r => r.GetString(0));
    Console.WriteLine($"  Users: {string.Join(", ", names)}");

    response = await client.GqlAsync("MATCH ()-[e]->() RETURN count(e)");
    Console.WriteLine($"  Edges: {response.SingleInt()}");

    // Cleanup
    await client.DropGraphAsync("dataOpsDemo");
}
```
