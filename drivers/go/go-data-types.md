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

## InsertType Constants

Controls the GQL keyword emitted by `InsertNodesGql` / `InsertEdgesGql`, and the duplicate-`_id` semantic for `InsertNodes` / `InsertEdges` (via `InsertNodesConfig.Mode` / `InsertEdgesConfig.Mode`):

```go
type InsertType int

const (
    InsertTypeNormal    InsertType = 0  // INSERT — errors on duplicate _id
    InsertTypeOverwrite InsertType = 1  // INSERT OVERWRITE — replaces entity wholesale
    InsertTypeUpsert    InsertType = 2  // UPSERT — merges new properties into existing entity
)
```

`InsertTypeOverwrite` drops properties not present in the write. `InsertTypeUpsert` preserves them and only overwrites the ones present in the write. They are not interchangeable.

## InsertConfig

Per-call configuration for the GQL-emitter convenience helpers (`InsertNodesGql` / `InsertEdgesGql`). Embeds `QueryConfig`:

```go
type InsertConfig struct {
    QueryConfig                     // embedded — GraphName, Timeout, TransactionID, etc.
    InsertType InsertType           // defaults to InsertTypeNormal (zero value)
}
```

Pass `nil` to use the session graph and `InsertTypeNormal`.

## InsertNodesConfig / InsertEdgesConfig

Configuration for the gRPC bulk-import functions (`InsertNodes` / `InsertEdges`):

```go
type InsertNodesConfig struct {
    Mode                InsertType   // Normal / Overwrite / Upsert
    BulkImportSessionID string       // Optional: bulk import session ID for auto-checkpoint
}

type InsertEdgesConfig struct {
    SkipInvalidNodes    bool         // Skip edges where source/target node doesn't exist
    Mode                InsertType   // Normal / Overwrite / Upsert
    BulkImportSessionID string       // Optional: bulk import session ID for auto-checkpoint
}
```

Edge `InsertTypeOverwrite` and `InsertTypeUpsert` require `WITH EDGE_ID` on the target graph.

## Type Structs

### Node Types

```go
// Data for inserting nodes (input to InsertNodes / InsertNodesGql)
type NodeData struct {
    ID         string                  // Optional custom _id (auto-generated when empty)
    Labels     []string
    Properties map[string]interface{}
}

// Node from query results
type Node struct {
    ID         string                  // user-facing identifier
    UUID       string                  // system numeric handle, decimal-formatted;
                                       // empty on pre-6.1.147 servers
    Labels     []string
    Properties map[string]interface{}
}
```

### Edge Types

```go
// Data for inserting edges (input to InsertEdges / InsertEdgesGql)
type EdgeData struct {
    ID         string                  // Optional custom _id; requires WITH EDGE_ID graph
    Label      string
    FromNodeID string
    ToNodeID   string
    Properties map[string]interface{}
}

// Edge from query results
type Edge struct {
    ID         string
    UUID       string                  // system numeric handle; empty on pre-6.1.147 servers
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
    SRID      int32   // spatial reference system id; 0 = unset
}

func (p Point) X() float64           // alias for Longitude
func (p Point) Y() float64           // alias for Latitude

type Point3D struct {
    X float64
    Y float64
    Z float64
    SRID int32   // spatial reference system id; 0 = unset
}

func (p Point3D) Longitude() float64  // alias for X
func (p Point3D) Latitude() float64   // alias for Y
func (p Point3D) Height() float64     // alias for Z
```

`Point` validates against WGS-84 bounds server-side (longitude ∈ [-180, 180], latitude ∈ [-90, 90]). `Point3D` is Cartesian — the server does **not** enforce geographic bounds on Point3D, even when accessed through the lon/lat aliases.

#### Spatial reference systems (SRID)

Both point types carry an `SRID int32`. A value of `0` means **unset**, and the driver fills a default on encode:

```go
const (
    DefaultPoint2DSRID = 4326 // WGS-84 (geographic)
    DefaultPoint3DSRID = 0    // cartesian, no CRS
)
```

- Leaving `SRID` at its zero value encodes the type's default (`Point` → `4326`, `Point3D` → `0`); the server in turn normalizes an unset 2D point to `4326` and an unset 3D point to `9157`.
- An explicit non-zero `SRID` (e.g. `3857`) round-trips through encode/decode unchanged.
- Legacy payloads from older servers that don't report an SRID decode back to the type's default (`4326` for 2D, `0` for 3D), so existing data reads consistently.

```go
// Explicit SRID — preserved end to end
p := gqldb.Point{Latitude: 30.5, Longitude: 114.3, SRID: 3857}

// Unset SRID — encoder fills DefaultPoint2DSRID (4326)
q := gqldb.Point{Latitude: 40.7128, Longitude: -74.0060}

// 3D point defaults to SRID 0 (cartesian) unless set
c := gqldb.Point3D{X: 1, Y: 2, Z: 3}
```

### Duration Types

```go
type YearToMonth struct {
    Months int32
}

type DayToSecond struct {
    Seconds     int64    // signed — negative durations (e.g. -PT1H) round-trip correctly
    Nanoseconds uint32
}
```

### Vector Type

```go
type Vector struct {
    Values []float32
}

func (v Vector) Len() int            // dimension count
```

`v.Len()` returns the number of dimensions — mirrors the Python driver's `len(vec)` ergonomic and the server-side `size(VECTOR)` / `ai.vector_dim(VECTOR)` functions.

### Temporal Type Formatting

The temporal types — `LocalDateTime`, `ZonedDateTime`, `GqldbDate`, `LocalTime`, and `ZonedTime` — each expose a canonical `String()` and marshal to that same string via `MarshalJSON()`.

```go
func (ldt LocalDateTime) String() string
func (zdt ZonedDateTime) String() string
func (d GqldbDate) String() string
func (lt LocalTime) String() string
func (zt ZonedTime) String() string

func (ldt LocalDateTime) MarshalJSON() ([]byte, error)  // -> "2026-07-01 15:40:12.153"
// (same for ZonedDateTime, GqldbDate, LocalTime, ZonedTime)
```

The canonical form is `YYYY-MM-DD HH:mm:ss[.fff]`:

- A **space** separates the date and time (not `T`).
- Trailing zeros in the fractional-seconds part are trimmed; when the fraction is zero it is dropped entirely.
- Zoned types append the UTC offset as `±HH:MM` (with `+00:00` for UTC).

`MarshalJSON()` emits this canonical string, so a temporal type serializes as a bare JSON string rather than a struct — for example `json.Marshal(ldt)` yields `"2026-07-01 15:40:12.153"`.

```go
gqldb.LocalDateTime{Time: time.Date(2026, 7, 1, 15, 40, 12, 153000000, time.UTC)}.String()
// "2026-07-01 15:40:12.153"

gqldb.LocalDateTime{Time: time.Date(2026, 7, 1, 15, 40, 12, 0, time.UTC)}.String()
// "2026-07-01 15:40:12"          (zero fraction dropped)

gqldb.ZonedTime{Hour: 15, Minute: 40, Second: 12, Nanosecond: 153000000, OffsetMinutes: 480}.String()
// "15:40:12.153+08:00"

gqldb.GqldbDate{Year: 2026, Month: 7, Day: 1}.String()
// "2026-07-01"

// JSON — bare canonical string, not a struct
b, _ := json.Marshal(gqldb.LocalDateTime{Time: time.Date(2026, 7, 1, 15, 40, 12, 153000000, time.UTC)})
// b == `"2026-07-01 15:40:12.153"`
```

## Parsing values from strings

When data arrives as text (for example CSV import), `NewTypedValueFromString` parses a string into a `TypedValue` for a given target type. Its inverse, `FormatValue`, serializes a `TypedValue` back to its canonical string form.

```go
func NewTypedValueFromString(s string, targetType PropertyType) (*TypedValue, error)
func (tv *TypedValue) FormatValue() (string, error)
```

An empty string parses to a null `TypedValue` of the target type. Numeric, boolean, string, decimal, temporal, and duration types accept their canonical forms (temporal parsing tolerates both `T` and space separators and an optional trailing offset). The spatial, vector, and blob types accept several forms:

### POINT

| Form | Example | Notes |
|------|---------|-------|
| Canonical keyed | `point({latitude: 30.5, longitude: 114.3})` | Keys case-insensitive, any order |
| Positional | `30.5,114.3` or `(30.5,114.3)` | `latitude,longitude` order |
| WKT (OGC/PostGIS) | `POINT(114.3 30.5)` | `POINT(<lon> <lat>)` — **longitude first** (opposite of the positional comma form) |

Latitude is validated to `[-90, 90]` and longitude to `[-180, 180]`.

### POINT3D

| Form | Example | Notes |
|------|---------|-------|
| Canonical keyed | `point({x: 1, y: 2, z: 3})` | Keys case-insensitive, any order |
| Positional | `1,2,3` or `(1,2,3)` | `x,y,z` order |
| WKT | `POINT(1 2 3)` or `POINT Z(1 2 3)` | Cartesian `x y z`, no reordering |

### VECTOR

A bracketed or bracket-less comma list: `[0.1,0.2,0.3]` or `0.1,0.2,0.3`. `[]` yields an empty (non-nil) vector.

### BLOB

Base64 (`StdEncoding`) by default; a `0x` / `0X` prefix selects hex. `FormatValue` emits Base64, which round-trips back through `NewTypedValueFromString`.

```go
// Parse a WKT point (lon-first) into a Point TypedValue
tv, err := gqldb.NewTypedValueFromString("POINT(114.3 30.5)", gqldb.PropertyTypePoint)
if err != nil {
    log.Fatal(err)
}
val, _ := tv.ToGo()
pt := val.(gqldb.Point)
fmt.Printf("Lat: %v, Lng: %v\n", pt.Latitude, pt.Longitude) // Lat: 30.5, Lng: 114.3

// Parse a vector and a hex blob
vecTV, _ := gqldb.NewTypedValueFromString("[0.1,0.2,0.3]", gqldb.PropertyTypeVector)
blobTV, _ := gqldb.NewTypedValueFromString("0x48656c6c6f", gqldb.PropertyTypeBlob)

// Serialize back to canonical text
s, _ := vecTV.FormatValue() // "[0.1,0.2,0.3]"
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
    if pt, ok := location.(gqldb.Point); ok {
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
