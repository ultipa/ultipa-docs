# Executing Queries

The GQLDB Go driver provides methods for executing GQL queries with various options including streaming, query explanation, and profiling.

## Query Methods

| Method | Description |
|--------|-------------|
| `Gql(ctx, query, config)` | Execute a GQL query and return results |
| `GqlStream(ctx, query, config, callback)` | Execute a query with streaming results |
| `Explain(ctx, query, config)` | Get the execution plan for a query |
| `Profile(ctx, query, config)` | Execute with profiling and get statistics |

## Basic Query Execution

### Gql()

Execute a GQL query and return the results:

```go
import (
    "context"
    "fmt"

    gqldb "github.com/ultipa/ultipa-go-driver/v6"
)

ctx := context.Background()

// Simple query
response, err := client.Gql(ctx, "MATCH (n:Person) RETURN n.name, n.age", nil)
if err != nil {
    log.Fatal(err)
}

fmt.Printf("Columns: %v\n", response.Columns)
fmt.Printf("Row count: %d\n", response.RowCount)

for _, row := range response.Rows {
    name, _ := row.GetString(0)
    age, _ := row.GetInt(1)
    fmt.Printf("%s: %d\n", name, age)
}
```

## QueryConfig

Configure query execution with `QueryConfig`:

```go
queryConfig := &gqldb.QueryConfig{
    GraphName:      "myGraph",           // Target graph
    Parameters:     map[string]interface{}{"limit": 10},  // Query parameters
    TransactionID:  0,                   // Transaction ID (0 = no transaction)
    Timeout:        60,                  // Query timeout in seconds
    ReadOnly:       true,                // Read-only mode
    MaxPathResults: 1000,               // Max path results (0 = no limit)
}

response, err := client.Gql(ctx,
    "MATCH (n:Person) RETURN n LIMIT $limit",
    queryConfig,
)
```

### QueryConfig Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `GraphName` | `string` | `""` | Target graph (uses session default if empty) |
| `Parameters` | `map[string]interface{}` | `nil` | Query parameters |
| `TransactionID` | `uint64` | `0` | Transaction ID for transactional queries |
| `Timeout` | `int` | `0` | Query timeout in seconds (0 = use client default) |
| `ReadOnly` | `bool` | `false` | Execute as read-only |
| `MaxPathResults` | `int64` | `0` | Maximum number of path results to return (0 = no limit) |

## Parameterized Queries

Use parameters to safely pass values:

```go
config := &gqldb.QueryConfig{
    Parameters: map[string]interface{}{
        "name":    "Alice",
        "min_age": 25,
    },
}

response, err := client.Gql(ctx,
    "MATCH (n:Person) WHERE n.name = $name AND n.age >= $min_age RETURN n",
    config,
)
```

## Streaming Results

### GqlStream()

For large result sets, use streaming to process results in chunks:

```go
ctx := context.Background()

err := client.GqlStream(ctx, "MATCH (n) RETURN n", nil,
    func(response *gqldb.Response) error {
        for _, row := range response.Rows {
            val, _ := row.Get(0)
            fmt.Printf("Processing: %v\n", val)
        }
        return nil
    },
)

if err != nil {
    log.Fatal(err)
}
```

### Streaming with Configuration

```go
config := &gqldb.QueryConfig{
    GraphName: "largeGraph",
    Timeout:   300,  // 5 minutes for large queries
}

var results []interface{}

err := client.GqlStream(ctx, "MATCH (n:DataPoint) RETURN n.value", config,
    func(response *gqldb.Response) error {
        for _, row := range response.Rows {
            val, _ := row.Get(0)
            results = append(results, val)
        }
        return nil
    },
)

fmt.Printf("Collected %d values\n", len(results))
```

## Query Explanation

### Explain()

Get the execution plan without running the query:

```go
plan, err := client.Explain(ctx, "MATCH (a)-[r]->(b) WHERE a.name = 'Alice' RETURN b", nil)
if err != nil {
    log.Fatal(err)
}

fmt.Println("Execution plan:")
fmt.Println(plan)
```

### Explain with Configuration

```go
config := &gqldb.QueryConfig{GraphName: "myGraph"}
plan, err := client.Explain(ctx,
    "MATCH (n:Person)-[:Knows]->{1,3}(m:Person) RETURN m",
    config,
)
fmt.Println(plan)
```

## Query Profiling

### Profile()

Execute a query and get performance statistics:

```go
stats, err := client.Profile(ctx, "MATCH (n:Person) RETURN n LIMIT 100", nil)
if err != nil {
    log.Fatal(err)
}

fmt.Println("Profile statistics:")
fmt.Println(stats)
```

### Profile Complex Queries

```go
config := &gqldb.QueryConfig{
    GraphName: "socialNetwork",
    Timeout:   120,
}

stats, err := client.Profile(ctx,
    "MATCH (a:User)-[:Follows]->{1,3}(b:User) RETURN DISTINCT b LIMIT 1000",
    config,
)
fmt.Println(stats)
```

## Query Within Transaction

Execute queries within a transaction:

```go
ctx := context.Background()

// Start a transaction
tx, err := client.BeginTransaction(ctx, "myGraph", false, 60)
if err != nil {
    log.Fatal(err)
}

// Execute queries in the transaction
config := &gqldb.QueryConfig{TransactionID: tx.ID}

_, err = client.Gql(ctx, "INSERT (n:Person {_id: 'p1', name: 'Alice'})", config)
if err != nil {
    client.Rollback(ctx, tx.ID)
    log.Fatal(err)
}

_, err = client.Gql(ctx, "INSERT (n:Person {_id: 'p2', name: 'Bob'})", config)
if err != nil {
    client.Rollback(ctx, tx.ID)
    log.Fatal(err)
}

// Commit the transaction
_, err = client.Commit(ctx, tx.ID)
if err != nil {
    log.Fatal(err)
}
```

## Working with Different Data Types

```go
// Insert various data types
_, err := client.Gql(ctx, `
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
`, nil)

// Query and retrieve
response, err := client.Gql(ctx, "MATCH (n:DataNode) RETURN n", nil)
alias, err := response.Alias("n")
if err != nil {
    log.Fatal(err)
}
nodes, schemas, err := alias.AsNodes()

for _, node := range nodes {
    fmt.Printf("ID: %s\n", node.ID)
    fmt.Printf("Properties: %v\n", node.Properties)
}
```

## Error Handling

```go
import (
    "errors"

    gqldb "github.com/ultipa/ultipa-go-driver/v6"
)

response, err := client.Gql(ctx, "MATCH (n) RETURN n", nil)
if err != nil {
    if errors.Is(err, gqldb.ErrEmptyQuery) {
        log.Println("Query cannot be empty")
    } else if errors.Is(err, gqldb.ErrQueryTimeout) {
        log.Println("Query timed out")
    } else if errors.Is(err, gqldb.ErrQueryFailed) {
        log.Printf("Query failed: %v", err)
    } else {
        log.Printf("Error: %v", err)
    }
}
```

## Complete Example

```go
package main

import (
    "context"
    "fmt"
    "log"
    "time"

    gqldb "github.com/ultipa/ultipa-go-driver/v6"
)

func main() {
    config := gqldb.NewConfigBuilder().
        Hosts("localhost:9000").
        Timeout(30 * time.Second).
        Build()

    client, err := gqldb.NewClient(config)
    if err != nil {
        log.Fatal(err)
    }
    defer client.Close()

    ctx := context.Background()
    client.Login(ctx, "admin", "password")
    client.CreateGraph(ctx, "queryDemo", gqldb.GraphTypeOpen, "")
    client.UseGraph(ctx, "queryDemo")

    // Insert test data
    client.Gql(ctx, `
        INSERT (alice:Person {_id: 'p1', name: 'Alice', age: 30}),
               (bob:Person {_id: 'p2', name: 'Bob', age: 25}),
               (charlie:Person {_id: 'p3', name: 'Charlie', age: 35}),
               (alice)-[:Knows]->(bob),
               (bob)-[:Knows]->(charlie)
    `, nil)

    // Basic query
    fmt.Println("=== Basic Query ===")
    response, _ := client.Gql(ctx, "MATCH (n:Person) RETURN n.name, n.age ORDER BY n.age", nil)
    for _, row := range response.Rows {
        name, _ := row.GetString(0)
        age, _ := row.GetInt(1)
        fmt.Printf("  %s: %d\n", name, age)
    }

    // Parameterized query
    fmt.Println("\n=== Parameterized Query ===")
    queryConfig := &gqldb.QueryConfig{
        Parameters: map[string]interface{}{"min_age": 28},
    }
    response, _ = client.Gql(ctx,
        "MATCH (n:Person) WHERE n.age >= $min_age RETURN n.name",
        queryConfig,
    )
    for _, row := range response.Rows {
        name, _ := row.GetString(0)
        fmt.Printf("  %s\n", name)
    }

    // Aggregation
    fmt.Println("\n=== Aggregation ===")
    response, _ = client.Gql(ctx, "MATCH (n:Person) RETURN count(n), avg(n.age), max(n.age)", nil)
    row := response.First()
    if row != nil {
        count, _ := row.GetInt(0)
        avg, _ := row.GetFloat(1)
        max, _ := row.GetInt(2)
        fmt.Printf("  Count: %d\n", count)
        fmt.Printf("  Avg age: %.1f\n", avg)
        fmt.Printf("  Max age: %d\n", max)
    }

    // Path query
    fmt.Println("\n=== Path Query ===")
    response, _ = client.Gql(ctx, `
        MATCH p = (a:Person)-[:Knows]->{1,2}(b:Person)
        WHERE a.name = 'Alice'
        RETURN p
    `, nil)
    pAlias, _ := response.Alias("p")
    paths, _ := pAlias.AsPaths()
    for _, path := range paths {
        var names []string
        for _, node := range path.Nodes {
            if name, ok := node.Properties["name"].(string); ok {
                names = append(names, name)
            }
        }
        fmt.Printf("  Path: %v\n", names)
    }

    // Explain query
    fmt.Println("\n=== Query Plan ===")
    plan, _ := client.Explain(ctx, "MATCH (a)-[r]->(b) RETURN a, r, b LIMIT 10", nil)
    fmt.Println(plan)

    // Profile query
    fmt.Println("\n=== Query Profile ===")
    stats, _ := client.Profile(ctx, "MATCH (n:Person) RETURN n", nil)
    fmt.Println(stats)

    // Streaming
    fmt.Println("\n=== Streaming ===")
    count := 0
    client.GqlStream(ctx, "MATCH (n) RETURN n", nil, func(resp *gqldb.Response) error {
        count += len(resp.Rows)
        return nil
    })
    fmt.Printf("  Streamed %d rows\n", count)

    // Cleanup
    client.DropGraph(ctx, "queryDemo", true)
}
```
