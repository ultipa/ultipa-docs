# Response Processing

The GQLDB Go driver provides the `Response` and `Row` types for working with query results. This guide covers how to extract and convert data from query responses.

## Response Struct

The `Gql()` method returns a `Response` pointer containing query results:

```go
import (
    "context"

    gqldb "github.com/ultipa/ultipa-go-driver/v6"
)

ctx := context.Background()

response, err := client.Gql(ctx, "MATCH (n:User) RETURN n.name, n.age", nil)
if err != nil {
    log.Fatal(err)
}

fmt.Printf("Columns: %v\n", response.Columns)        // ["n.name", "n.age"]
fmt.Printf("Row count: %d\n", response.RowCount)     // Number of rows
fmt.Printf("Has more: %v\n", response.HasMore)       // Pagination indicator
fmt.Printf("Warnings: %v\n", response.Warnings)      // Any query warnings
fmt.Printf("Rows affected: %d\n", response.RowsAffected)  // For write operations
```

### Response Fields and Methods

| Field/Method | Return Type | Description |
|--------------|-------------|-------------|
| `Columns` | `[]string` | Column names from the query |
| `Rows` | `[]*Row` | List of result rows |
| `RowCount` | `int64` | Total number of rows |
| `HasMore` | `bool` | Whether more results are available |
| `Warnings` | `[]string` | Query warnings |
| `RowsAffected` | `int64` | Rows affected by write operations |
| `IsEmpty()` | `bool` | Whether response has no rows |
| `First()` | `*Row` | First row or nil |
| `Last()` | `*Row` | Last row or nil |

## Row Struct

Each row contains values that can be accessed by index:

```go
response, _ := client.Gql(ctx, "MATCH (n:User) RETURN n.name, n.age, n.active", nil)

for _, row := range response.Rows {
    // Access by index (returns interface{} and error)
    name, _ := row.Get(0)      // First column
    age, _ := row.Get(1)       // Second column
    active, _ := row.Get(2)    // Third column

    // Typed accessors
    nameStr, _ := row.GetString(0)     // Returns string
    ageInt, _ := row.GetInt(1)         // Returns int64
    activeBool, _ := row.GetBool(2)    // Returns bool

    fmt.Printf("%s, age %d, active: %v\n", nameStr, ageInt, activeBool)
}
```

### Row Methods

| Method | Return Type | Description |
|--------|-------------|-------------|
| `Get(index)` | `(interface{}, error)` | Get value at index |
| `GetString(index)` | `(string, error)` | Get value as string |
| `GetInt(index)` | `(int64, error)` | Get value as int64 |
| `GetFloat(index)` | `(float64, error)` | Get value as float64 |
| `GetBool(index)` | `(bool, error)` | Get value as bool |

## Iterating Results

### Using for loop

```go
response, _ := client.Gql(ctx, "MATCH (n) RETURN n", nil)

for _, row := range response.Rows {
    val, _ := row.Get(0)
    fmt.Println(val)
}
```

### Using ForEach

```go
err := response.ForEach(func(row *gqldb.Row, index int) error {
    val, _ := row.Get(0)
    fmt.Printf("Row %d: %v\n", index, val)
    return nil
})
```

### Using Map

```go
results, err := response.Map(func(row *gqldb.Row) (interface{}, error) {
    return row.GetString(0)
})

for _, name := range results {
    fmt.Println(name)
}
```

## Quick Access Methods

### First and Last Row

```go
first := response.First()  // First row or nil
last := response.Last()    // Last row or nil

if first != nil {
    val, _ := first.Get(0)
    fmt.Printf("First result: %v\n", val)
}
```

### Check if Empty

```go
if response.IsEmpty() {
    fmt.Println("No results found")
}
```

### Single Value

For queries that return a single row with a single column:

```go
countResponse, _ := client.Gql(ctx, "MATCH (n) RETURN count(n)", nil)

// Get single value as interface{}
val, err := countResponse.SingleValue()

// Typed single value accessors
countInt, _ := countResponse.SingleInt()      // As int64
countStr, _ := countResponse.SingleString()   // As string
```

## Converting to Maps

### ToMaps()

Convert rows to a slice of maps:

```go
response, _ := client.Gql(ctx, "MATCH (u:User) RETURN u.name AS name, u.age AS age", nil)
users, err := response.ToMaps()

// Result: []map[string]interface{}{{"name": "Alice", "age": 30}, {"name": "Bob", "age": 25}}
for _, user := range users {
    fmt.Printf("%s is %v years old\n", user["name"], user["age"])
}
```

### ToJSON()

Convert to JSON bytes:

```go
jsonBytes, err := response.ToJSON()
fmt.Println(string(jsonBytes))
```

### Get Value by Column Name

```go
response, _ := client.Gql(ctx, "MATCH (u:User) RETURN u.name AS name, u.age AS age", nil)

for _, row := range response.Rows {
    name, _ := response.GetByName(row, "name")
    age, _ := response.GetByName(row, "age")
    fmt.Printf("%v: %v\n", name, age)
}
```

## Alias and Get Methods

Query results are accessed through `AliasResult`, which is obtained from the `Response` using `Alias()` or `Get()`. These methods return `(*AliasResult, error)`.

### Alias()

Retrieve a result column by its alias name:

```go
response, _ := client.Gql(ctx, "MATCH (u:User) RETURN u, u.age AS age", nil)

// Get the alias result for "u"
alias, err := response.Alias("u")
if err != nil {
    log.Fatal(err)
}

// Now use AliasResult methods
nodes, schemas, err := alias.AsNodes()
```

### Get()

Retrieve a result column by its positional index:

```go
response, _ := client.Gql(ctx, "MATCH (u:User) RETURN u, u.age AS age", nil)

// Get the first column (index 0)
alias, err := response.Get(0)
if err != nil {
    log.Fatal(err)
}

nodes, schemas, err := alias.AsNodes()
```

### AliasResult Methods

| Method | Return Type | Description |
|--------|-------------|-------------|
| `AsNodes()` | `([]*Node, map[string]*Schema, error)` | Extract nodes |
| `AsEdges()` | `([]*Edge, map[string]*Schema, error)` | Extract edges |
| `AsPaths()` | `([]*Path, error)` | Extract paths |
| `AsTable()` | `(*Table, error)` | Get as table |
| `AsAttr()` | `(*Attr, error)` | Extract attribute values |

## Extracting Graph Elements

### AsNodes()

Extract nodes from the response:

```go
response, _ := client.Gql(ctx, "MATCH (u:User) RETURN u", nil)

alias, err := response.Alias("u")
if err != nil {
    log.Fatal(err)
}
nodes, schemas, err := alias.AsNodes()
if err != nil {
    log.Fatal(err)
}

// Access nodes
for _, node := range nodes {
    fmt.Printf("ID: %s\n", node.ID)
    fmt.Printf("Labels: %v\n", node.Labels)
    fmt.Printf("Properties: %v\n", node.Properties)
}

// Access inferred schemas
for label, schema := range schemas {
    fmt.Printf("Schema for %s: %v\n", label, schema)
}
```

### Node Struct

```go
type Node struct {
    ID         string
    Labels     []string
    Properties map[string]interface{}
}
```

### AsEdges()

Extract edges from the response:

```go
response, _ := client.Gql(ctx, "MATCH ()-[e:Follows]->() RETURN e", nil)

alias, err := response.Alias("e")
if err != nil {
    log.Fatal(err)
}
edges, schemas, err := alias.AsEdges()

for _, edge := range edges {
    fmt.Printf("ID: %s\n", edge.ID)
    fmt.Printf("Label: %s\n", edge.Label)
    fmt.Printf("From: %s\n", edge.FromNodeID)
    fmt.Printf("To: %s\n", edge.ToNodeID)
    fmt.Printf("Properties: %v\n", edge.Properties)
}
```

### Edge Struct

```go
type Edge struct {
    ID         string
    Label      string
    FromNodeID string
    ToNodeID   string
    Properties map[string]interface{}
}
```

### AsPaths()

Extract paths from the response:

```go
response, _ := client.Gql(ctx, "MATCH p = (a)->{1,3}(b) RETURN p LIMIT 10", nil)

alias, err := response.Alias("p")
if err != nil {
    log.Fatal(err)
}
paths, err := alias.AsPaths()

for _, path := range paths {
    fmt.Printf("Path nodes: %d\n", len(path.Nodes))
    fmt.Printf("Path edges: %d\n", len(path.Edges))

    // Print path
    for i, node := range path.Nodes {
        fmt.Printf("  Node: %s\n", node.ID)
        if i < len(path.Edges) {
            fmt.Printf("    -[%s]->\n", path.Edges[i].Label)
        }
    }
}
```

### Path Struct

```go
type Path struct {
    Nodes []*Node
    Edges []*Edge
}
```

## Table Format

### AsTable()

Get the response as a generic table:

```go
response, _ := client.Gql(ctx, "MATCH (u:User) RETURN u.name, u.age", nil)

alias, err := response.Get(0)
if err != nil {
    log.Fatal(err)
}
table, err := alias.AsTable()

fmt.Printf("Table: %s\n", table.Name)
fmt.Printf("Headers: ")
for _, h := range table.Headers {
    fmt.Printf("%s (%v) ", h.Name, h.Type)
}
fmt.Println()
fmt.Printf("Rows: %v\n", table.Rows)
```

### Table and Header Structs

```go
type Table struct {
    Name    string
    Headers []*Header
    Rows    [][]interface{}
}

type Header struct {
    Name string
    Type PropertyType
}
```

## Attribute Extraction

### AsAttr()

Extract values from a specific column:

```go
response, _ := client.Gql(ctx, "MATCH (u:User) RETURN u.age AS age", nil)

alias, err := response.Alias("age")
if err != nil {
    log.Fatal(err)
}
ageAttr, err := alias.AsAttr()

fmt.Printf("Column name: %s\n", ageAttr.Name)
fmt.Printf("Type: %v\n", ageAttr.Type)
fmt.Printf("Values: %v\n", ageAttr.Values)

// Calculate statistics
var sum int64
for _, v := range ageAttr.Values {
    if age, ok := v.(int64); ok {
        sum += age
    }
}
avg := float64(sum) / float64(len(ageAttr.Values))
fmt.Printf("Average age: %.1f\n", avg)
```

### Attr Struct

```go
type Attr struct {
    Name   string
    Type   PropertyType
    Values []interface{}
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
        DefaultGraph("socialNetwork").
        Timeout(30 * time.Second).
        Build()

    client, err := gqldb.NewClient(config)
    if err != nil {
        log.Fatal(err)
    }
    defer client.Close()

    ctx := context.Background()
    client.Login(ctx, "admin", "password")

    // Setup test data
    client.CreateGraph(ctx, "socialNetwork", gqldb.GraphTypeOpen, "")
    client.UseGraph(ctx, "socialNetwork")
    client.Gql(ctx, `
        INSERT (a:User {_id: 'u1', name: 'Alice', age: 30}),
               (b:User {_id: 'u2', name: 'Bob', age: 25}),
               (c:User {_id: 'u3', name: 'Charlie', age: 35}),
               (a)-[:Follows {since: '2023-01'}]->(b),
               (b)-[:Follows {since: '2023-03'}]->(c),
               (c)-[:Follows {since: '2023-06'}]->(a)
    `, nil)

    // Query nodes
    fmt.Println("=== Query Nodes ===")
    nodeResponse, _ := client.Gql(ctx, "MATCH (u:User) RETURN u LIMIT 5", nil)
    uAlias, _ := nodeResponse.Alias("u")
    nodes, _, _ := uAlias.AsNodes()
    for _, node := range nodes {
        fmt.Printf("User %s: %v\n", node.ID, node.Properties["name"])
    }

    // Query with multiple columns
    fmt.Println("\n=== Query Columns ===")
    colResponse, _ := client.Gql(ctx,
        "MATCH (u:User) RETURN u.name AS name, u.age AS age ORDER BY u.age DESC LIMIT 3",
        nil,
    )
    users, _ := colResponse.ToMaps()
    fmt.Printf("Top 3 oldest users: %v\n", users)

    // Query paths
    fmt.Println("\n=== Query Paths ===")
    pathResponse, _ := client.Gql(ctx,
        "MATCH p = (a:User)-[:Follows]->{1,2}(b:User) RETURN p LIMIT 3",
        nil,
    )
    pAlias, _ := pathResponse.Alias("p")
    paths, _ := pAlias.AsPaths()
    for _, path := range paths {
        var route []string
        for _, n := range path.Nodes {
            if name, ok := n.Properties["name"].(string); ok {
                route = append(route, name)
            } else {
                route = append(route, n.ID)
            }
        }
        fmt.Printf("Path: %v\n", route)
    }

    // Aggregate query
    fmt.Println("\n=== Aggregate Query ===")
    countResponse, _ := client.Gql(ctx, "MATCH (n) RETURN count(n)", nil)
    count, _ := countResponse.SingleInt()
    fmt.Printf("Total nodes: %d\n", count)

    // Extract attribute values
    fmt.Println("\n=== Attribute Extraction ===")
    ageResponse, _ := client.Gql(ctx, "MATCH (u:User) RETURN u.age AS age", nil)
    ageAlias, _ := ageResponse.Alias("age")
    ages, _ := ageAlias.AsAttr()

    var minAge, maxAge int64 = 999, 0
    for _, v := range ages.Values {
        if age, ok := v.(int64); ok {
            if age < minAge {
                minAge = age
            }
            if age > maxAge {
                maxAge = age
            }
        }
    }
    fmt.Printf("Ages: %v\n", ages.Values)
    fmt.Printf("Min age: %d\n", minAge)
    fmt.Printf("Max age: %d\n", maxAge)

    // Cleanup
    client.DropGraph(ctx, "socialNetwork", true)
}
```
