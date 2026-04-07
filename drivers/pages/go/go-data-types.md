# Data Types

The GQLDB Go driver supports a comprehensive set of data types for storing and querying graph data. This guide covers property types, enums, and type conversions.

## Property Types

The `PropertyType` constants define all supported data types:

```go
import gqldb "github.com/ultipa/ultipa-go-driver/v6"
```

### Numeric Types

| Type | Description | Go Type |
|------|-------------|---------|
| `PropertyTypeInt32` | 32-bit signed integer | `int32` |
| `PropertyTypeUint32` | 32-bit unsigned integer | `uint32` |
| `PropertyTypeInt64` | 64-bit signed integer | `int64` |
| `PropertyTypeUint64` | 64-bit unsigned integer | `uint64` |
| `PropertyTypeFloat` | 32-bit floating point | `float32` |
| `PropertyTypeDouble` | 64-bit floating point | `float64` |
| `PropertyTypeDecimal` | Arbitrary precision decimal | `Decimal` |

### String Types

| Type | Description | Go Type |
|------|-------------|---------|
| `PropertyTypeString` | Variable-length string | `string` |
| `PropertyTypeText` | Long text | `string` |

### Boolean and Null

| Type | Description | Go Type |
|------|-------------|---------|
| `PropertyTypeBool` | Boolean value | `bool` |
| `PropertyTypeNull` | Null value | `nil` |
| `PropertyTypeUnset` | Unset/unknown type | `nil` |

### Binary

| Type | Description | Go Type |
|------|-------------|---------|
| `PropertyTypeBlob` | Binary data | `[]byte` |

### Date and Time Types

| Type | Description | Go Type |
|------|-------------|---------|
| `PropertyTypeTimestamp` | Unix timestamp with nanoseconds | `time.Time` |
| `PropertyTypeDatetime` | Date and time (deprecated) | `time.Time` |
| `PropertyTypeDate` | Date only | `LocalDateTime` |
| `PropertyTypeLocalDatetime` | Local date and time | `LocalDateTime` |
| `PropertyTypeZonedDatetime` | Date and time with timezone | `ZonedDateTime` |
| `PropertyTypeLocalTime` | Local time of day | `LocalTime` |
| `PropertyTypeZonedTime` | Time with timezone | `ZonedTime` |

### Duration Types

| Type | Description | Go Type |
|------|-------------|---------|
| `PropertyTypeYearToMonth` | Year-month duration | `YearToMonth` |
| `PropertyTypeDayToSecond` | Day-second duration | `DayToSecond` |

### Geospatial Types

| Type | Description | Go Type |
|------|-------------|---------|
| `PropertyTypePoint` | 2D geographic point | `Point` |
| `PropertyTypePoint3D` | 3D point | `Point3D` |

### Collection Types

| Type | Description | Go Type |
|------|-------------|---------|
| `PropertyTypeList` | Ordered list | `[]interface{}` |
| `PropertyTypeSet` | Unordered unique set | `Set` |
| `PropertyTypeMap` | Key-value map | `map[string]interface{}` |
| `PropertyTypeVector` | Numeric vector | `Vector` |

### Graph Types

| Type | Description | Go Type |
|------|-------------|---------|
| `PropertyTypeNode` | Graph node | `*Node` |
| `PropertyTypeEdge` | Graph edge | `*Edge` |
| `PropertyTypePath` | Graph path | `Path` |

## PropertyType Constants

```go
const (
    PropertyTypeUnset
    PropertyTypeInt32
    PropertyTypeUint32
    PropertyTypeInt64
    PropertyTypeUint64
    PropertyTypeFloat
    PropertyTypeDouble
    PropertyTypeString
    PropertyTypeDatetime      // Deprecated, use PropertyTypeTimestamp
    PropertyTypeTimestamp
    PropertyTypeText
    PropertyTypeBlob
    PropertyTypePoint
    PropertyTypeDecimal
    PropertyTypeList
    PropertyTypeSet
    PropertyTypeMap
    PropertyTypeNull
    PropertyTypeBool
    PropertyTypeLocalDatetime
    PropertyTypeZonedDatetime
    PropertyTypeDate
    PropertyTypeZonedTime
    PropertyTypeLocalTime
    PropertyTypeYearToMonth
    PropertyTypeDayToSecond
    PropertyTypeRecord
    PropertyTypePoint3D
    PropertyTypeVector
    PropertyTypeTable
    PropertyTypePath
    PropertyTypeError
    PropertyTypeNode
    PropertyTypeEdge
)
```

## GraphType Constants

```go
const (
    GraphTypeOpen     // Schema-less graph
    GraphTypeClosed   // Schema-enforced graph
    GraphTypeOntology // Ontology-enabled graph
)
```

## HealthStatus Constants

```go
const (
    HealthStatusUnknown
    HealthStatusServing
    HealthStatusNotServing
    HealthStatusServiceUnknown
)
```

## CacheType Constants

```go
const (
    CacheTypeAll
    CacheTypeAST
    CacheTypePlan
)
```

## Type Structs

### Node Types

```go
// Data for inserting nodes
type NodeData struct {
    ID         string
    Labels     []string
    Properties map[string]interface{}
}

// Node from query results
type Node struct {
    ID         string
    Labels     []string
    Properties map[string]interface{}
}
```

### Edge Types

```go
// Data for inserting edges
type EdgeData struct {
    Label      string
    FromNodeID string
    ToNodeID   string
    Properties map[string]interface{}
}

// Edge from query results
type Edge struct {
    ID         string
    Label      string
    FromNodeID string
    ToNodeID   string
    Properties map[string]interface{}
}
```

### Path Type

```go
type Path struct {
    Nodes []*Node
    Edges []*Edge
}
```

### Geospatial Types

```go
type Point struct {
    Latitude  float64
    Longitude float64
}

type Point3D struct {
    X float64
    Y float64
    Z float64
}
```

### Duration Types

```go
type YearToMonth struct {
    Months int32
}

type DayToSecond struct {
    Nanos int64
}
```

### Vector Type

```go
type Vector struct {
    Values []float32
}

func (v Vector) Dimension() int {
    return len(v.Values)
}
```

## TypedValue

The driver uses `TypedValue` internally for type-safe data transfer:

```go
type TypedValue struct {
    Type   PropertyType
    Data   []byte
    IsNull bool
}

// Convert to Go type
func (tv *TypedValue) ToGo() (interface{}, error)
```

### Creating TypedValues

```go
// Create from Go value
tv, err := gqldb.NewTypedValue(42)
tv, err = gqldb.NewTypedValue("hello")
tv, err = gqldb.NewTypedValue(3.14)
tv, err = gqldb.NewTypedValue(true)
```

### Creating Parameters

```go
// Create query parameter
param, err := gqldb.NewParameter("name", "Alice")
param, err = gqldb.NewParameter("age", 30)
```

## Type Conversion Examples

### Working with Dates

```go
// Insert with date
client.Gql(ctx, `
    INSERT (e:Event {
        _id: 'e1',
        name: 'Conference',
        date: DATE('2024-06-15'),
        startTime: DATETIME('2024-06-15T09:00:00Z')
    })
`, nil)

// Query and convert
response, _ := client.Gql(ctx, "MATCH (e:Event) RETURN e.date, e.startTime", nil)
row := response.First()
if row != nil {
    date, _ := row.Get(0)
    startTime, _ := row.Get(1)
    fmt.Printf("Event date: %v\n", date)
    fmt.Printf("Start time: %v\n", startTime)
}
```

### Working with Points

```go
// Insert with location
client.Gql(ctx, `
    INSERT (p:Place {
        _id: 'p1',
        name: 'Office',
        location: POINT(37.7749, -122.4194)
    })
`, nil)

// Query and access point
response, _ := client.Gql(ctx, "MATCH (p:Place) RETURN p.location", nil)
row := response.First()
if row != nil {
    location, _ := row.Get(0)
    if pt, ok := location.(*gqldb.Point); ok {
        fmt.Printf("Lat: %f, Lng: %f\n", pt.Latitude, pt.Longitude)
    }
}
```

### Working with Collections

```go
// Insert with list and map
client.Gql(ctx, `
    INSERT (u:User {
        _id: 'u1',
        name: 'Alice',
        tags: ['developer', 'blogger'],
        metadata: {level: 5, premium: true}
    })
`, nil)

// Query collections
response, _ := client.Gql(ctx, "MATCH (u:User) RETURN u.tags, u.metadata", nil)
row := response.First()
if row != nil {
    tags, _ := row.Get(0)
    metadata, _ := row.Get(1)
    fmt.Printf("Tags: %v\n", tags)
    fmt.Printf("Metadata: %v\n", metadata)
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
    client.CreateGraph(ctx, "typeDemo", gqldb.GraphTypeOpen, "")
    client.UseGraph(ctx, "typeDemo")

    // Insert data with various types
    client.Gql(ctx, `
        INSERT (u:User {
            _id: 'u1',
            name: 'Alice',
            age: 30,
            balance: 1234.56,
            active: true,
            joined: DATE('2023-01-15'),
            location: POINT(40.7128, -74.0060),
            tags: ['developer', 'mentor'],
            settings: {theme: 'dark', notifications: true}
        })
    `, nil)

    // Query and check types
    response, _ := client.Gql(ctx, `
        MATCH (u:User {_id: 'u1'})
        RETURN u.name, u.age, u.balance, u.active, u.joined,
               u.location, u.tags, u.settings
    `, nil)

    row := response.First()
    if row != nil {
        name, _ := row.GetString(0)
        age, _ := row.GetInt(1)
        balance, _ := row.GetFloat(2)
        active, _ := row.GetBool(3)
        joined, _ := row.Get(4)
        location, _ := row.Get(5)
        tags, _ := row.Get(6)
        settings, _ := row.Get(7)

        fmt.Printf("Name (string): %s\n", name)
        fmt.Printf("Age (int64): %d\n", age)
        fmt.Printf("Balance (float64): %.2f\n", balance)
        fmt.Printf("Active (bool): %v\n", active)
        fmt.Printf("Joined: %v\n", joined)
        fmt.Printf("Location: %v\n", location)
        fmt.Printf("Tags: %v\n", tags)
        fmt.Printf("Settings: %v\n", settings)

        // Check property types
        fmt.Println("\nProperty types:")
        for i, tv := range row.Values {
            fmt.Printf("  Column %d: %v\n", i, tv.Type)
        }
    }

    client.DropGraph(ctx, "typeDemo", true)
}
```
