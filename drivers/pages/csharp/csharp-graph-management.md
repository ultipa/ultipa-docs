# Graph Management

The GQLDB C# driver provides methods for creating, managing, and querying graph metadata.

## Graph Methods

| Method | Description |
|--------|-------------|
| `CreateGraphAsync(name, graphType, description)` | Create a new graph |
| `DropGraphAsync(name, ifExists)` | Delete a graph |
| `UseGraphAsync(name)` | Set the current graph for the session |
| `ListGraphsAsync()` | List all available graphs |
| `GetGraphInfoAsync(name)` | Get information about a specific graph |

## Creating Graphs

### CreateGraphAsync()

Create a new graph:

```csharp
using Gqldb;
using Gqldb.Types;

var config = new GqldbConfig { Hosts = { "localhost:60061" } };

using var client = new GqldbClient(config);
await client.LoginAsync("admin", "password");

// Create a basic graph (schema-less)
await client.CreateGraphAsync("myGraph");

// Create with specific type
await client.CreateGraphAsync("schemaGraph", GraphType.Closed);

// Create with description
await client.CreateGraphAsync(
    "socialNetwork",
    GraphType.Open,
    "Social network for user connections"
);
```

### GraphType Enum

```csharp
using Gqldb.Types;

GraphType.Open      // Schema-less graph (default)
GraphType.Closed    // Schema-enforced graph
GraphType.Ontology  // Ontology-enabled graph
```

## Dropping Graphs

### DropGraphAsync()

Delete a graph:

```csharp
// Drop a graph (raises error if not found)
await client.DropGraphAsync("myGraph");

// Drop with ifExists (no error if not found)
await client.DropGraphAsync("myGraph", ifExists: true);
```

## Setting Current Graph

### UseGraphAsync()

Set the current graph for the session:

```csharp
await client.UseGraphAsync("myGraph");

// Now queries use myGraph by default
var response = await client.GqlAsync("MATCH (n) RETURN count(n)");
```

## Listing Graphs

### ListGraphsAsync()

Get all available graphs:

```csharp
var graphs = await client.ListGraphsAsync();

foreach (var graph in graphs)
{
    Console.WriteLine($"Name: {graph.Name}");
    Console.WriteLine($"  Type: {graph.GraphType}");
    Console.WriteLine($"  Description: {graph.Description}");
    Console.WriteLine($"  Node count: {graph.NodeCount}");
    Console.WriteLine($"  Edge count: {graph.EdgeCount}");
    Console.WriteLine();
}
```

### GraphInfo Class

```csharp
public class GraphInfo
{
    public string Name { get; set; }
    public GraphType GraphType { get; set; }
    public string Description { get; set; }
    public long NodeCount { get; set; }
    public long EdgeCount { get; set; }
}
```

## Getting Graph Information

### GetGraphInfoAsync()

Get detailed information about a specific graph:

```csharp
try
{
    var info = await client.GetGraphInfoAsync("myGraph");
    Console.WriteLine($"Graph: {info.Name}");
    Console.WriteLine($"Type: {info.GraphType}");
    Console.WriteLine($"Nodes: {info.NodeCount}");
    Console.WriteLine($"Edges: {info.EdgeCount}");
    Console.WriteLine($"Description: {info.Description}");
}
catch (GqldbException e)
{
    Console.WriteLine("Graph not found");
}
```

## Error Handling

```csharp
using Gqldb;

// Handle graph already exists
try
{
    await client.CreateGraphAsync("existingGraph");
}
catch (GqldbException e) when (e.Message.Contains("exists"))
{
    Console.WriteLine("Graph already exists");
}

// Safe graph creation
try
{
    await client.CreateGraphAsync("myGraph");
}
catch (GqldbException)
{
    Console.WriteLine("Graph already exists, using existing");
}

await client.UseGraphAsync("myGraph");
```

## Ensure Graph Exists Pattern

```csharp
async Task<GraphInfo> EnsureGraph(
    GqldbClient client, string name,
    GraphType graphType = GraphType.Open, string description = "")
{
    if (!await client.HasGraphAsync(name))
    {
        await client.CreateGraphIfNotExistAsync(name, graphType, description);
        Console.WriteLine($"Created graph '{name}'");
    }

    return await client.GetGraphInfoAsync(name);
}

// Usage
var graphInfo = await EnsureGraph(client, "myGraph", GraphType.Open, "My application graph");
await client.UseGraphAsync("myGraph");
```

## Working with Multiple Graphs

```csharp
using Gqldb;

var config = new GqldbConfig { Hosts = { "localhost:60061" } };

using var client = new GqldbClient(config);
await client.LoginAsync("admin", "password");

// Create multiple graphs
await client.CreateGraphAsync("users");
await client.CreateGraphAsync("products");
await client.CreateGraphAsync("orders");

// Query specific graph without switching
var usersConfig = new QueryConfig { GraphName = "users" };
var productsConfig = new QueryConfig { GraphName = "products" };

var users = await client.GqlAsync("MATCH (u:User) RETURN u", usersConfig);
var products = await client.GqlAsync("MATCH (p:Product) RETURN p", productsConfig);

// Or switch between graphs
await client.UseGraphAsync("users");
// ... work with users

await client.UseGraphAsync("orders");
// ... work with orders
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

    // List existing graphs
    Console.WriteLine("=== Existing Graphs ===");
    foreach (var graph in await client.ListGraphsAsync())
    {
        Console.WriteLine($"  {graph.Name} ({graph.GraphType})");
    }

    // Create graphs
    Console.WriteLine("\n=== Creating Graphs ===");
    var graphsToCreate = new[]
    {
        ("socialNetwork", GraphType.Open, "Social connections"),
        ("productCatalog", GraphType.Closed, "Product information"),
        ("knowledgeBase", GraphType.Ontology, "Knowledge graph")
    };

    foreach (var (name, gtype, desc) in graphsToCreate)
    {
        await client.CreateGraphIfNotExistAsync(name, gtype, desc);
        Console.WriteLine($"  Ensured: {name}");
    }

    // Get detailed info
    Console.WriteLine("\n=== Graph Details ===");
    foreach (var (name, _, _) in graphsToCreate)
    {
        var info = await client.GetGraphInfoAsync(name);
        Console.WriteLine($"  {info.Name}:");
        Console.WriteLine($"    Type: {info.GraphType}");
        Console.WriteLine($"    Description: {info.Description}");
        Console.WriteLine($"    Nodes: {info.NodeCount}");
        Console.WriteLine($"    Edges: {info.EdgeCount}");
    }

    // Work with a graph
    Console.WriteLine("\n=== Working with socialNetwork ===");
    await client.UseGraphAsync("socialNetwork");

    await client.GqlAsync(@"
        INSERT (a:User {_id: 'u1', name: 'Alice'}),
               (b:User {_id: 'u2', name: 'Bob'}),
               (a)-[:Follows]->(b)
    ");

    var socialInfo = await client.GetGraphInfoAsync("socialNetwork");
    Console.WriteLine($"  After insert: {socialInfo.NodeCount} nodes, {socialInfo.EdgeCount} edges");

    // Clean up
    Console.WriteLine("\n=== Cleanup ===");
    foreach (var (name, _, _) in graphsToCreate)
    {
        await client.DropGraphAsync(name, ifExists: true);
        Console.WriteLine($"  Dropped: {name}");
    }

    // Verify
    Console.WriteLine("\n=== Final Graph List ===");
    var remaining = (await client.ListGraphsAsync()).Select(g => g.Name);
    Console.WriteLine($"  Remaining graphs: {string.Join(", ", remaining)}");
}
```
