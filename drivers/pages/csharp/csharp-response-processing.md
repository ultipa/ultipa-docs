# Response Processing

The GQLDB C# driver provides the `Response` and `Row` classes for working with query results. This guide covers how to extract and convert data from query responses.

## Response Class

The `GqlAsync()` method returns a `Response` object containing query results:

```csharp
using Gqldb;

var config = new GqldbConfig { Hosts = { "localhost:60061" } };

using var client = new GqldbClient(config);
await client.LoginAsync("admin", "password");
await client.UseGraphAsync("myGraph");

var response = await client.GqlAsync("MATCH (n:User) RETURN n.name, n.age");

Console.WriteLine($"Columns: {string.Join(", ", response.Columns)}");
Console.WriteLine($"Row count: {response.RowCount}");
Console.WriteLine($"Has more: {response.HasMore}");
Console.WriteLine($"Warnings: {string.Join(", ", response.Warnings)}");
Console.WriteLine($"Rows affected: {response.RowsAffected}");
```

### Response Attributes and Methods

| Attribute/Method | Return Type | Description |
|------------------|-------------|-------------|
| `Columns` | `List<string>` | Column names from the query |
| `Rows` | `List<Row>` | List of result rows |
| `RowCount` | `long` | Total number of rows |
| `HasMore` | `bool` | Whether more results are available |
| `Warnings` | `List<string>` | Query warnings |
| `RowsAffected` | `long` | Rows affected by write operations |
| `IsEmpty` | `bool` | Whether response has no rows |
| `First` | `Row?` | First row or null |
| `Last` | `Row?` | Last row or null |

## Row Class

Each row contains values that can be accessed by index:

```csharp
var response = await client.GqlAsync("MATCH (n:User) RETURN n.name, n.age, n.active");

foreach (var row in response.Rows)
{
    // Access by index
    var name = row.Get(0);
    var age = row.Get(1);
    var active = row.Get(2);

    // Typed accessors
    var nameStr = row.GetString(0);
    var ageInt = row.GetInt(1);
    var activeBool = row.GetBool(2);

    Console.WriteLine($"{nameStr}, age {ageInt}, active: {activeBool}");
}
```

### Row Methods

| Method | Return Type | Description |
|--------|-------------|-------------|
| `Get(index)` | `object?` | Get value at index |
| `GetString(index)` | `string` | Get value as string |
| `GetInt(index)` | `long` | Get value as integer |
| `GetFloat(index)` | `double` | Get value as float |
| `GetBool(index)` | `bool` | Get value as boolean |
| `GetPropertyType(index)` | `PropertyType` | Get the type at index |

## Iterating Results

### Using foreach

```csharp
var response = await client.GqlAsync("MATCH (n) RETURN n");

foreach (var row in response.Rows)
{
    Console.WriteLine(row.Get(0));
}
```

### Using ForEach

```csharp
response.ForEach((row, index) =>
{
    Console.WriteLine($"Row {index}: {row.Get(0)}");
});
```

### Using Map

```csharp
var names = response.Map(row => row.GetString(0));
Console.WriteLine($"Names: {string.Join(", ", names)}");
```

## Quick Access Methods

### First and Last Row

```csharp
var first = response.First;
var last = response.Last;

if (first != null)
{
    Console.WriteLine($"First result: {first.Get(0)}");
}
```

### Check if Empty

```csharp
if (response.IsEmpty)
{
    Console.WriteLine("No results found");
}
```

### Single Value

For queries that return a single row with a single column:

```csharp
var countResponse = await client.GqlAsync("MATCH (n) RETURN count(n)");
var count = countResponse.SingleValue();  // Returns the single value

// Typed single value accessors
var countInt = countResponse.SingleInt();
var countStr = countResponse.SingleString();
```

## Converting to Dictionaries

### ToMaps()

Convert rows to a list of dictionaries:

```csharp
var response = await client.GqlAsync(
    "MATCH (u:User) RETURN u.name AS name, u.age AS age"
);
var users = response.ToMaps();

foreach (var user in users)
{
    Console.WriteLine($"{user["name"]} is {user["age"]} years old");
}
```

### ToJson()

Convert to JSON string:

```csharp
var jsonStr = response.ToJson();
Console.WriteLine(jsonStr);
```

### Get Value by Column Name

```csharp
var response = await client.GqlAsync(
    "MATCH (u:User) RETURN u.name AS name, u.age AS age"
);

foreach (var row in response.Rows)
{
    var name = response.GetByName(row, "name");
    var age = response.GetByName(row, "age");
    Console.WriteLine($"{name}: {age}");
}
```

## Accessing Result Columns

Query results are organized by columns (aliases). To extract typed data such as nodes, edges, paths, tables, or attributes, you must first select a column using `Alias()` (by name) or `Get()` (by index). These return an `AliasResult` object with type-specific extraction methods.

### Alias()

Select a column by its alias name:

```csharp
var response = await client.GqlAsync(
    "MATCH (u:User)-[e:Follows]->(f:User) RETURN u, e, f"
);

// Access by alias name
var (users, userSchemas) = response.Alias("u").AsNodes();
var (edges, edgeSchemas) = response.Alias("e").AsEdges();
var (friends, friendSchemas) = response.Alias("f").AsNodes();
```

### Get()

Select a column by its positional index:

```csharp
var response = await client.GqlAsync("MATCH (u:User) RETURN u, u.name");

// Access by index
var (nodes, schemas) = response.Get(0).AsNodes();
var names = response.Get(1).AsAttr();
```

### AliasResult Class

The `AliasResult` object returned by `Alias()` and `Get()` provides the following methods:

| Method | Return Type | Description |
|--------|-------------|-------------|
| `AsNodes()` | `(List<GqldbNode>, Dictionary<string, Schema>)` | Extract nodes and schemas |
| `AsEdges()` | `(List<GqldbEdge>, Dictionary<string, Schema>)` | Extract edges and schemas |
| `AsPaths()` | `List<GqldbPath>` | Extract paths |
| `AsTable()` | `Table` | Extract as a table |
| `AsAttr()` | `Attr` | Extract as attribute values |
| `AsValues()` | `List<object?>` | Extract raw values |

## Extracting Graph Elements

### AsNodes()

Extract nodes from a specific column of the response:

```csharp
var response = await client.GqlAsync("MATCH (u:User) RETURN u");
var (nodes, schemas) = response.Alias("u").AsNodes();

foreach (var node in nodes)
{
    Console.WriteLine($"ID: {node.Id}");
    Console.WriteLine($"Labels: {string.Join(", ", node.Labels)}");
    Console.WriteLine($"Properties: {string.Join(", ", node.Properties)}");
}

// Access inferred schemas
foreach (var (label, schema) in schemas)
{
    Console.WriteLine($"Schema for {label}: {string.Join(", ", schema.Properties.Select(p => p.Name))}");
}
```

### GqldbNode Class

```csharp
public class GqldbNode
{
    public string Id { get; set; }
    public List<string> Labels { get; set; }
    public Dictionary<string, object?> Properties { get; set; }
}
```

### AsEdges()

Extract edges from a specific column of the response:

```csharp
var response = await client.GqlAsync("MATCH ()-[e:Follows]->() RETURN e");
var (edges, schemas) = response.Alias("e").AsEdges();

foreach (var edge in edges)
{
    Console.WriteLine($"ID: {edge.Id}");
    Console.WriteLine($"Label: {edge.Label}");
    Console.WriteLine($"From: {edge.FromNodeId}");
    Console.WriteLine($"To: {edge.ToNodeId}");
    Console.WriteLine($"Properties: {string.Join(", ", edge.Properties)}");
}
```

### GqldbEdge Class

```csharp
public class GqldbEdge
{
    public string Id { get; set; }
    public string Label { get; set; }
    public string FromNodeId { get; set; }
    public string ToNodeId { get; set; }
    public Dictionary<string, object?> Properties { get; set; }
}
```

### AsPaths()

Extract paths from a specific column of the response:

```csharp
var response = await client.GqlAsync("MATCH p = (a)->{1,3}(b) RETURN p LIMIT 10");
var paths = response.Alias("p").AsPaths();

foreach (var path in paths)
{
    Console.WriteLine($"Path nodes: {path.Nodes.Count}");
    Console.WriteLine($"Path edges: {path.Edges.Count}");

    for (int i = 0; i < path.Nodes.Count; i++)
    {
        Console.WriteLine($"  Node: {path.Nodes[i].Id}");
        if (i < path.Edges.Count)
        {
            Console.WriteLine($"    -[{path.Edges[i].Label}]->");
        }
    }
}
```

### GqldbPath Class

```csharp
public class GqldbPath
{
    public List<GqldbNode> Nodes { get; set; }
    public List<GqldbEdge> Edges { get; set; }
}
```

## Table Format

### AsTable()

Get a specific column of the response as a generic table:

```csharp
var response = await client.GqlAsync("MATCH (u:User) RETURN u.name, u.age");
var table = response.Get(0).AsTable();

Console.WriteLine($"Headers: {string.Join(", ", table.Headers.Select(h => h.Name))}");
Console.WriteLine($"Rows: {table.Rows.Count}");
```

### Table and Header Classes

```csharp
public class Table
{
    public string Name { get; set; }
    public List<Header> Headers { get; set; }
    public List<object?[]> Rows { get; set; }
}

public class Header
{
    public string Name { get; set; }
    public PropertyType Type { get; set; }
}
```

## Attribute Extraction

### AsAttr()

Extract values from a specific column:

```csharp
var response = await client.GqlAsync("MATCH (u:User) RETURN u.age AS age");
var ageAttr = response.Alias("age").AsAttr();

Console.WriteLine($"Column name: {ageAttr.Name}");
Console.WriteLine($"Type: {ageAttr.Type}");
Console.WriteLine($"Values: {string.Join(", ", ageAttr.Values)}");

// Calculate statistics
var ages = ageAttr.Values
    .Where(v => v is int or long or double)
    .Select(v => Convert.ToDouble(v))
    .ToList();

if (ages.Any())
{
    Console.WriteLine($"Average age: {ages.Average():F1}");
}
```

### Attr Class

```csharp
public class Attr
{
    public string Name { get; set; }
    public PropertyType Type { get; set; }
    public List<object?> Values { get; set; }
}
```

## Complete Example

```csharp
using Gqldb;

async Task Main()
{
    var config = new GqldbConfig
    {
        Hosts = { "localhost:60061" },
        DefaultGraph = "socialNetwork"
    };

    using var client = new GqldbClient(config);
    await client.LoginAsync("admin", "password");

    // Setup test data
    await client.CreateGraphAsync("socialNetwork");
    await client.UseGraphAsync("socialNetwork");
    await client.GqlAsync(@"
        INSERT (a:User {_id: 'u1', name: 'Alice', age: 30}),
               (b:User {_id: 'u2', name: 'Bob', age: 25}),
               (c:User {_id: 'u3', name: 'Charlie', age: 35}),
               (a)-[:Follows {since: '2023-01'}]->(b),
               (b)-[:Follows {since: '2023-03'}]->(c),
               (c)-[:Follows {since: '2023-06'}]->(a)
    ");

    // Query nodes
    Console.WriteLine("=== Query Nodes ===");
    var nodeResponse = await client.GqlAsync("MATCH (u:User) RETURN u LIMIT 5");
    var (nodes, schemas) = nodeResponse.Alias("u").AsNodes();
    foreach (var node in nodes)
    {
        Console.WriteLine($"User {node.Id}: {node.Properties.GetValueOrDefault("name")}");
    }

    // Query with multiple columns
    Console.WriteLine("\n=== Query Columns ===");
    var colResponse = await client.GqlAsync(
        "MATCH (u:User) RETURN u.name AS name, u.age AS age ORDER BY u.age DESC LIMIT 3"
    );
    var users = colResponse.ToMaps();
    Console.WriteLine($"Top 3 oldest users: {colResponse.ToJson()}");

    // Query paths
    Console.WriteLine("\n=== Query Paths ===");
    var pathResponse = await client.GqlAsync(
        "MATCH p = (a:User)-[:Follows]->{1,2}(b:User) RETURN p LIMIT 3"
    );
    var paths = pathResponse.Alias("p").AsPaths();
    foreach (var path in paths)
    {
        var route = string.Join(" -> ", path.Nodes.Select(n =>
            n.Properties.GetValueOrDefault("name", n.Id)?.ToString() ?? n.Id
        ));
        Console.WriteLine($"Path: {route}");
    }

    // Aggregate query
    Console.WriteLine("\n=== Aggregate Query ===");
    var countResponse = await client.GqlAsync("MATCH (n) RETURN count(n)");
    Console.WriteLine($"Total nodes: {countResponse.SingleInt()}");

    // Extract attribute values
    Console.WriteLine("\n=== Attribute Extraction ===");
    var ageResponse = await client.GqlAsync("MATCH (u:User) RETURN u.age AS age");
    var ages = ageResponse.Alias("age").AsAttr();
    var numericAges = ages.Values
        .Where(v => v != null)
        .Select(v => Convert.ToDouble(v))
        .ToList();

    if (numericAges.Any())
    {
        Console.WriteLine($"Ages: {string.Join(", ", numericAges)}");
        Console.WriteLine($"Min age: {numericAges.Min()}");
        Console.WriteLine($"Max age: {numericAges.Max()}");
    }

    // Cleanup
    await client.DropGraphAsync("socialNetwork");
}
```
