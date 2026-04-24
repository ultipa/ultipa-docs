# Data Types

The GQLDB C# driver supports a comprehensive set of data types for storing and querying graph data. This guide covers property types, enums, and type conversions.

## Property Types

The `PropertyType` enum defines all supported data types:

```csharp
using Gqldb.Types;
```

### Numeric Types

| Type | Description | C# Type |
|------|-------------|---------|
| `Int32` | 32-bit signed integer | `int` |
| `UInt32` | 32-bit unsigned integer | `uint` |
| `Int64` | 64-bit signed integer | `long` |
| `UInt64` | 64-bit unsigned integer | `ulong` |
| `Float` | 32-bit floating point | `float` |
| `Double` | 64-bit floating point | `double` |
| `Decimal` | Arbitrary precision decimal | `GqldbDecimal` |

### String Types

| Type | Description | C# Type |
|------|-------------|---------|
| `String` | Variable-length string | `string` |
| `Text` | Long text | `string` |

### Boolean and Null

| Type | Description | C# Type |
|------|-------------|---------|
| `Bool` | Boolean value | `bool` |
| `Null` | Null value | `null` |
| `Unset` | Unset/unknown type | `null` |

### Binary

| Type | Description | C# Type |
|------|-------------|---------|
| `Blob` | Binary data | `byte[]` |

### Date and Time Types

| Type | Description | C# Type |
|------|-------------|---------|
| `Timestamp` | Unix timestamp with nanoseconds | `DateTimeOffset` |
| `Datetime` | Date and time (deprecated) | `DateTime` |
| `Date` | Date only | `GqldbDate` |
| `LocalDatetime` | Local date and time | `GqldbLocalDateTime` |
| `ZonedDatetime` | Date and time with timezone | `GqldbZonedDateTime` |
| `LocalTime` | Local time of day | `GqldbLocalTime` |
| `ZonedTime` | Time with timezone | `GqldbZonedTime` |

### Duration Types

| Type | Description | C# Type |
|------|-------------|---------|
| `YearToMonth` | Year-month duration | `GqldbYearToMonth` |
| `DayToSecond` | Day-second duration | `GqldbDayToSecond` |

### Geospatial Types

| Type | Description | C# Type |
|------|-------------|---------|
| `Point` | 2D geographic point | `GqldbPoint` |
| `Point3D` | 3D point | `GqldbPoint3D` |

### Collection Types

| Type | Description | C# Type |
|------|-------------|---------|
| `List` | Ordered list | `IList<object>` |
| `Set` | Unordered unique set | `HashSet<object>` |
| `Map` | Key-value map | `Dictionary<string, object>` |
| `Vector` | Numeric vector | `GqldbVector` |

### Graph Types

| Type | Description | C# Type |
|------|-------------|---------|
| `Node` | Graph node | `GqldbNode` |
| `Edge` | Graph edge | `GqldbEdge` |
| `Path` | Graph path | `GqldbPath` |

## PropertyType Enum

```csharp
using Gqldb.Types;

public enum PropertyType
{
    Unset = 0,
    Int32 = 1,
    UInt32 = 2,
    Int64 = 3,
    UInt64 = 4,
    Float = 5,
    Double = 6,
    String = 7,
    Datetime = 8,   // Deprecated, use Timestamp
    Timestamp = 9,
    Text = 10,
    Blob = 11,
    Point = 12,
    Decimal = 13,
    List = 14,
    Set = 15,
    Map = 16,
    Null = 17,
    Bool = 18,
    LocalDatetime = 19,
    ZonedDatetime = 20,
    Date = 21,
    ZonedTime = 22,
    LocalTime = 23,
    YearToMonth = 24,
    DayToSecond = 25,
    Record = 26,
    Point3D = 27,
    Vector = 28,
    Table = 29,
    Path = 30,
    Error = 31,
    Node = 32,
    Edge = 33
}
```

## GraphType Enum

```csharp
using Gqldb.Types;

public enum GraphType
{
    Open = 0,      // Schema-less graph
    Closed = 1,    // Schema-enforced graph
    Ontology = 2   // Ontology-enabled graph
}
```

## HealthStatus Enum

```csharp
using Gqldb.Types;

public enum HealthStatus
{
    Unknown = 0,
    Serving = 1,
    NotServing = 2,
    ServiceUnknown = 3
}
```

## CacheType Enum

```csharp
using Gqldb.Types;

public enum CacheType
{
    All = 0,
    Ast = 1,
    Plan = 2
}
```

## Type Classes

### Node Types

```csharp
using Gqldb.Types;

// Data for inserting nodes
public class NodeData
{
    public string Id { get; set; } = "";
    public List<string> Labels { get; set; } = new();
    public Dictionary<string, object?> Properties { get; set; } = new();
}

// Internal node representation
public class GqldbNode
{
    public string Id { get; set; } = "";
    public List<string> Labels { get; set; } = new();
    public Dictionary<string, object?> Properties { get; set; } = new();
}
```

### Edge Types

```csharp
using Gqldb.Types;

// Data for inserting edges
public class EdgeData
{
    public string Label { get; set; } = "";
    public string FromNodeId { get; set; } = "";
    public string ToNodeId { get; set; } = "";
    public Dictionary<string, object?> Properties { get; set; } = new();
}

// Internal edge representation
public class GqldbEdge
{
    public string Id { get; set; } = "";
    public string Label { get; set; } = "";
    public string FromNodeId { get; set; } = "";
    public string ToNodeId { get; set; } = "";
    public Dictionary<string, object?> Properties { get; set; } = new();
}
```

### Path Type

```csharp
using Gqldb.Types;

public class GqldbPath
{
    public List<GqldbNode> Nodes { get; set; } = new();
    public List<GqldbEdge> Edges { get; set; } = new();
}
```

### Geospatial Types

```csharp
using Gqldb.Types;

public record struct GqldbPoint(double Longitude, double Latitude);

public record struct GqldbPoint3D(double X, double Y, double Z);
```

### Date/Time Types

```csharp
using Gqldb.Types;

public record struct GqldbDate(ushort Year, byte Month, byte Day);

public record struct GqldbLocalDateTime(
    ushort Year, byte Month, byte Day,
    byte Hour, byte Minute, byte Second, uint Nanosecond)
{
    public DateTime ToDateTime();
}

public record struct GqldbZonedDateTime(
    ushort Year, byte Month, byte Day,
    byte Hour, byte Minute, byte Second, uint Nanosecond,
    short OffsetMinutes)
{
    public DateTimeOffset ToDateTimeOffset();
}

public record struct GqldbLocalTime(
    byte Hour, byte Minute, byte Second, uint Nanosecond);

public record struct GqldbZonedTime(
    byte Hour, byte Minute, byte Second, uint Nanosecond,
    short OffsetMinutes);
```

### Duration Types

```csharp
using Gqldb.Types;

public record struct GqldbYearToMonth(int Months);

public record struct GqldbDayToSecond(ulong Seconds, uint Nanoseconds);
```

### Vector Type

```csharp
using Gqldb.Types;

public class GqldbVector
{
    public float[] Values { get; }
    public GqldbVector(float[] values);
}
```

### DateTimeHelpers

```csharp
using Gqldb.Types;

// Helper factory methods
var ldt = DateTimeHelpers.CreateLocalDateTime(2024, 6, 15, 9, 0, 0);
var date = DateTimeHelpers.CreateDate(2024, 6, 15);
var time = DateTimeHelpers.CreateLocalTime(9, 30, 0);

// Convert from .NET types
var fromDt = DateTimeHelpers.FromDateTime(DateTime.Now);
var fromDto = DateTimeHelpers.FromDateTimeOffset(DateTimeOffset.Now);
```

## Type Wrapper Classes

For explicit type specification:

```csharp
using Gqldb.Types;

// Wrap values with explicit types
var node = new NodeData
{
    Labels = { "Test" },
    Properties =
    {
        ["int32_val"] = new GqldbInt32(42),
        ["uint32_val"] = new GqldbUInt32(100),
        ["float32_val"] = new GqldbFloat32(3.14f),
        ["uint64_val"] = new GqldbUInt64(9999999999)
    }
};
```

## Type Conversion Examples

### Working with Dates

```csharp
// Insert with date
await client.GqlAsync(@"
    INSERT (e:Event {
        _id: 'e1',
        name: 'Conference',
        date: DATE('2024-06-15'),
        startTime: DATETIME('2024-06-15T09:00:00Z')
    })
");

// Query and convert
var response = await client.GqlAsync("MATCH (e:Event) RETURN e.date, e.startTime");
var row = response.First;
if (row != null)
{
    var eventDate = row.Get(0);
    var startTime = row.Get(1);
    Console.WriteLine($"Event date: {eventDate}");
    Console.WriteLine($"Start time: {startTime}");
}
```

### Working with Points

```csharp
// Insert with location
await client.GqlAsync(@"
    INSERT (p:Place {
        _id: 'p1',
        name: 'Office',
        location: POINT(37.7749, -122.4194)
    })
");

// Query and access point
var response = await client.GqlAsync("MATCH (p:Place) RETURN p.location");
var row = response.First;
if (row != null)
{
    var location = row.Get(0);
    if (location is GqldbPoint point)
    {
        Console.WriteLine($"Lat: {point.Latitude}, Lng: {point.Longitude}");
    }
}
```

### Working with Collections

```csharp
// Insert with list and map
await client.GqlAsync(@"
    INSERT (u:User {
        _id: 'u1',
        name: 'Alice',
        tags: ['developer', 'blogger'],
        metadata: {level: 5, premium: true}
    })
");

// Query collections
var response = await client.GqlAsync("MATCH (u:User) RETURN u.tags, u.metadata");
var row = response.First;
if (row != null)
{
    var tags = row.Get(0);    // IList
    var metadata = row.Get(1);  // Dictionary
    Console.WriteLine($"Tags: {tags}");
    Console.WriteLine($"Metadata: {metadata}");
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
    await client.CreateGraphAsync("typeDemo");
    await client.UseGraphAsync("typeDemo");

    // Insert data with various types
    await client.GqlAsync(@"
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
    ");

    // Query and check types
    var response = await client.GqlAsync(@"
        MATCH (u:User {_id: 'u1'})
        RETURN u.name, u.age, u.balance, u.active, u.joined,
               u.location, u.tags, u.settings
    ");

    var row = response.First;
    if (row != null)
    {
        Console.WriteLine($"Name (string): {row.GetString(0)}");
        Console.WriteLine($"Age (int): {row.GetInt(1)}");
        Console.WriteLine($"Balance (float): {row.GetFloat(2)}");
        Console.WriteLine($"Active (bool): {row.GetBool(3)}");
        Console.WriteLine($"Joined: {row.Get(4)}");
        Console.WriteLine($"Location: {row.Get(5)}");
        Console.WriteLine($"Tags: {row.Get(6)}");
        Console.WriteLine($"Settings: {row.Get(7)}");

        // Check property types
        Console.WriteLine("\nProperty types:");
        for (int i = 0; i < row.Values.Count; i++)
        {
            Console.WriteLine($"  Column {i}: {row.GetPropertyType(i)}");
        }
    }

    await client.DropGraphAsync("typeDemo");
}
```
