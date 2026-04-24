# Executing Queries

The GQLDB C# driver provides methods for executing GQL queries with various options including streaming, query explanation, and profiling.

## Query Methods

| Method | Description |
|--------|-------------|
| `GqlAsync(query, config)` | Execute a GQL query and return results |
| `GqlStreamAsync(query, callback, config)` | Execute a query with streaming results |
| `ExplainAsync(query, config)` | Get the execution plan for a query |
| `ProfileAsync(query, config)` | Execute with profiling and get statistics |

## Basic Query Execution

### GqlAsync()

Execute a GQL query and return the results:

```csharp
using Gqldb;

var config = new GqldbConfig { Hosts = { "localhost:60061" } };

using var client = new GqldbClient(config);
await client.LoginAsync("admin", "password");
await client.UseGraphAsync("myGraph");

// Simple query
var response = await client.GqlAsync("MATCH (n:Person) RETURN n.name, n.age");

Console.WriteLine($"Columns: {string.Join(", ", response.Columns)}");
Console.WriteLine($"Row count: {response.RowCount}");

foreach (var row in response.Rows)
{
    var name = row.GetString(0);
    var age = row.GetInt(1);
    Console.WriteLine($"{name}: {age}");
}
```

## QueryConfig

Configure query execution with `QueryConfig`:

```csharp
using Gqldb;

// Create query configuration
var queryConfig = new QueryConfig
{
    GraphName = "myGraph",
    Parameters = new Dictionary<string, object?> { ["limit"] = 10 },
    Timeout = 60,
    ReadOnly = true
};

var response = await client.GqlAsync(
    "MATCH (n:Person) RETURN n LIMIT $limit",
    queryConfig
);
```

### QueryConfig Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `GraphName` | `string?` | `null` | Target graph (uses session default if null) |
| `Parameters` | `Dictionary<string, object?>?` | `null` | Query parameters |
| `TransactionId` | `ulong` | `0` | Transaction ID for transactional queries |
| `Timeout` | `int` | `0` | Query timeout in seconds (0 = use client default) |
| `ReadOnly` | `bool` | `false` | Execute as read-only |
| `MaxPathResults` | `long` | `0` | Maximum number of path results (0 = unlimited) |

## Parameterized Queries

Use parameters to safely pass values:

```csharp
using Gqldb;

var queryConfig = new QueryConfig
{
    Parameters = new Dictionary<string, object?>
    {
        ["name"] = "Alice",
        ["min_age"] = 25
    }
};

var response = await client.GqlAsync(
    "MATCH (n:Person) WHERE n.name = $name AND n.age >= $min_age RETURN n",
    queryConfig
);
```

## Streaming Results

### GqlStreamAsync()

For large result sets, use streaming to process results in chunks:

```csharp
await client.GqlStreamAsync(
    "MATCH (n) RETURN n",
    async response =>
    {
        foreach (var row in response.Rows)
        {
            Console.WriteLine($"Processing: {row.Get(0)}");
        }
    }
);
```

### Streaming with Configuration

```csharp
using Gqldb;

var queryConfig = new QueryConfig
{
    GraphName = "largeGraph",
    Timeout = 300  // 5 minutes for large queries
};

var results = new List<object?>();

await client.GqlStreamAsync(
    "MATCH (n:DataPoint) RETURN n.value",
    async response =>
    {
        foreach (var row in response.Rows)
        {
            results.Add(row.Get(0));
        }
    },
    queryConfig
);

Console.WriteLine($"Collected {results.Count} values");
```

## Query Explanation

### ExplainAsync()

Get the execution plan without running the query:

```csharp
var plan = await client.ExplainAsync(
    "MATCH (a)-[r]->(b) WHERE a.name = 'Alice' RETURN b"
);
Console.WriteLine("Execution plan:");
Console.WriteLine(plan);
```

### Explain with Configuration

```csharp
var queryConfig = new QueryConfig { GraphName = "myGraph" };
var plan = await client.ExplainAsync(
    "MATCH (n:Person)-[:Knows]->{1,3}(m:Person) RETURN m",
    queryConfig
);
Console.WriteLine(plan);
```

## Query Profiling

### ProfileAsync()

Execute a query and get performance statistics:

```csharp
var stats = await client.ProfileAsync("MATCH (n:Person) RETURN n LIMIT 100");
Console.WriteLine("Profile statistics:");
Console.WriteLine(stats);
```

### Profile Complex Queries

```csharp
var queryConfig = new QueryConfig
{
    GraphName = "socialNetwork",
    Timeout = 120
};

var stats = await client.ProfileAsync(
    "MATCH (a:User)-[:Follows]->{1,3}(b:User) RETURN DISTINCT b LIMIT 1000",
    queryConfig
);
Console.WriteLine(stats);
```

## Query Within Transaction

Execute queries within a transaction:

```csharp
using Gqldb;

// Start a transaction
var tx = await client.BeginTransactionAsync("myGraph");

try
{
    // Execute queries in the transaction
    var txConfig = new QueryConfig { TransactionId = tx.Id };

    await client.GqlAsync("INSERT (n:Person {_id: 'p1', name: 'Alice'})", txConfig);
    await client.GqlAsync("INSERT (n:Person {_id: 'p2', name: 'Bob'})", txConfig);

    // Commit the transaction
    await client.CommitAsync(tx.Id);
}
catch
{
    // Rollback on error
    await client.RollbackAsync(tx.Id);
    throw;
}
```

## Working with Different Data Types

```csharp
// Insert various data types
await client.GqlAsync(@"
    INSERT (n:DataNode {
        _id: 'dn1',
        int_val: 42,
        float_val: 3.14159,
        bool_val: true,
        string_val: 'hello',
        list_val: [1, 2, 3],
        map_val: {key: 'value'},
        date_val: DATE('2024-01-15'),
        point_val: POINT(37.7749, -122.4194)
    })
");

// Query and retrieve
var response = await client.GqlAsync("MATCH (n:DataNode) RETURN n");
var (nodes, schemas) = response.Alias("n").AsNodes();

foreach (var node in nodes)
{
    Console.WriteLine($"ID: {node.Id}");
    Console.WriteLine($"Properties: {string.Join(", ", node.Properties)}");
}
```

## Error Handling

```csharp
using Gqldb;

try
{
    var response = await client.GqlAsync("MATCH (n) RETURN n");
}
catch (GqldbException e) when (e.Message.Contains("empty"))
{
    Console.WriteLine("Query cannot be empty");
}
catch (GqldbException e) when (e.Message.Contains("timeout"))
{
    Console.WriteLine("Query timed out");
}
catch (GqldbException e)
{
    Console.WriteLine($"Query failed: {e.Message}");
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
        TimeoutSeconds = 30
    };

    using var client = new GqldbClient(config);
    await client.LoginAsync("admin", "password");
    await client.CreateGraphAsync("queryDemo");
    await client.UseGraphAsync("queryDemo");

    // Insert test data
    await client.GqlAsync(@"
        INSERT (alice:Person {_id: 'p1', name: 'Alice', age: 30}),
               (bob:Person {_id: 'p2', name: 'Bob', age: 25}),
               (charlie:Person {_id: 'p3', name: 'Charlie', age: 35}),
               (alice)-[:Knows]->(bob),
               (bob)-[:Knows]->(charlie)
    ");

    // Basic query
    Console.WriteLine("=== Basic Query ===");
    var response = await client.GqlAsync(
        "MATCH (n:Person) RETURN n.name, n.age ORDER BY n.age"
    );
    foreach (var row in response.Rows)
    {
        Console.WriteLine($"  {row.GetString(0)}: {row.GetInt(1)}");
    }

    // Parameterized query
    Console.WriteLine("\n=== Parameterized Query ===");
    var queryConfig = new QueryConfig
    {
        Parameters = new Dictionary<string, object?> { ["min_age"] = 28 }
    };
    response = await client.GqlAsync(
        "MATCH (n:Person) WHERE n.age >= $min_age RETURN n.name",
        queryConfig
    );
    foreach (var row in response.Rows)
    {
        Console.WriteLine($"  {row.GetString(0)}");
    }

    // Aggregation
    Console.WriteLine("\n=== Aggregation ===");
    response = await client.GqlAsync(
        "MATCH (n:Person) RETURN count(n), avg(n.age), max(n.age)"
    );
    var firstRow = response.First;
    if (firstRow != null)
    {
        Console.WriteLine($"  Count: {firstRow.GetInt(0)}");
        Console.WriteLine($"  Avg age: {firstRow.GetFloat(1):F1}");
        Console.WriteLine($"  Max age: {firstRow.GetInt(2)}");
    }

    // Path query
    Console.WriteLine("\n=== Path Query ===");
    response = await client.GqlAsync(@"
        MATCH p = (a:Person)-[:Knows]->{1,2}(b:Person)
        WHERE a.name = 'Alice'
        RETURN p
    ");
    var paths = response.Alias("p").AsPaths();
    foreach (var path in paths)
    {
        var names = path.Nodes.Select(n =>
            n.Properties.GetValueOrDefault("name", n.Id)?.ToString() ?? n.Id
        );
        Console.WriteLine($"  Path: {string.Join(" -> ", names)}");
    }

    // Explain query
    Console.WriteLine("\n=== Query Plan ===");
    var plan = await client.ExplainAsync(
        "MATCH (a)-[r]->(b) RETURN a, r, b LIMIT 10"
    );
    Console.WriteLine(plan);

    // Profile query
    Console.WriteLine("\n=== Query Profile ===");
    var stats = await client.ProfileAsync("MATCH (n:Person) RETURN n");
    Console.WriteLine(stats);

    // Streaming
    Console.WriteLine("\n=== Streaming ===");
    var count = 0;
    await client.GqlStreamAsync(
        "MATCH (n) RETURN n",
        async resp => { count += resp.Rows.Count; }
    );
    Console.WriteLine($"  Streamed {count} rows");

    // Cleanup
    await client.DropGraphAsync("queryDemo");
}
```
