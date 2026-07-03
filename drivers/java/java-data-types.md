# Data Types

The GQLDB Java driver supports a comprehensive set of data types for storing and querying graph data. This guide covers property types, enums, and type conversions.

## Property Types

The `PropertyType` enum defines all supported data types:

```java
import com.gqldb.types.PropertyType;
```

### Numeric Types

| Type | Description | Java Type |
|------|-------------|-----------|
| `INT32` | 32-bit signed integer | `Integer` |
| `UINT32` | 32-bit unsigned integer | `Long` |
| `INT64` | 64-bit signed integer | `Long` |
| `UINT64` | 64-bit unsigned integer | `Long` |
| `FLOAT` | 32-bit floating point | `Float` |
| `DOUBLE` | 64-bit floating point | `Double` |
| `DECIMAL` | Arbitrary precision decimal | `GqldbDecimal` |

### String Types

| Type | Description | Java Type |
|------|-------------|-----------|
| `STRING` | Variable-length string | `String` |
| `TEXT` | Long text | `String` |

### Boolean and Null

| Type | Description | Java Type |
|------|-------------|-----------|
| `BOOL` | Boolean value | `Boolean` |
| `NULL` | Null value | `null` |
| `UNSET` | Unset/unknown type | `null` |

### Binary

| Type | Description | Java Type |
|------|-------------|-----------|
| `BLOB` | Binary data | `byte[]` |

### Date and Time Types

| Type | Description | Java Type |
|------|-------------|-----------|
| `TIMESTAMP` | Unix timestamp with nanoseconds | `java.time.Instant` |
| `DATETIME` | Date and time (deprecated) | `GqldbLocalDateTime` |
| `DATE` | Date only | `GqldbDate` |
| `LOCAL_DATETIME` | Local date and time | `GqldbLocalDateTime` |
| `ZONED_DATETIME` | Date and time with timezone | `GqldbZonedDateTime` |
| `LOCAL_TIME` | Local time of day | `GqldbLocalTime` |
| `ZONED_TIME` | Time with timezone | `GqldbZonedTime` |

#### Temporal string and JSON format

The temporal wrapper classes (`GqldbLocalDateTime`, `GqldbZonedDateTime`, `GqldbDate`, `GqldbLocalTime`, `GqldbZonedTime`) render a **canonical string** from `toString()`:

- Date-time uses a **space** separator: `"YYYY-MM-DD HH:mm:ss"`.
- Fractional seconds are appended only when non-zero, with trailing zeros trimmed: `.153`, `.5`, or omitted entirely.
- Zoned types append the UTC offset as `+HH:MM` / `-HH:MM`.
- Date-only is `"YYYY-MM-DD"`; time-only is `"HH:mm:ss[.fff]"` (plus offset for `GqldbZonedTime`).

The same wrappers implement `Comparable`, so they sort chronologically.

**JSON serialization uses this canonical string** (a behavior change): each wrapper's `toString()` is annotated `@JsonValue`, so Jackson emits the string form rather than the field-by-field object.

```java
GqldbLocalDateTime dt = new GqldbLocalDateTime((short) 2026, (byte) 7, (byte) 1,
        (byte) 15, (byte) 40, (byte) 12, 153_000_000);
System.out.println(dt.toString());   // 2026-07-01 15:40:12.153

GqldbDate d = new GqldbDate((short) 2026, (byte) 7, (byte) 1);
System.out.println(d.toString());    // 2026-07-01

GqldbLocalTime t = new GqldbLocalTime((byte) 15, (byte) 40, (byte) 12, 0);
System.out.println(t.toString());    // 15:40:12  (no fractional part)

// Jackson serializes to the same string via @JsonValue:
// new ObjectMapper().writeValueAsString(dt)  ->  "2026-07-01 15:40:12.153"
```

### Duration Types

| Type | Description | Java Type |
|------|-------------|-----------|
| `YEAR_TO_MONTH` | Year-month duration | `YearToMonth` |
| `DAY_TO_SECOND` | Day-second duration | `DayToSecond` |

### Geospatial Types

| Type | Description | Java Type |
|------|-------------|-----------|
| `POINT` | 2D geographic point | `Point` |
| `POINT3D` | 3D point | `Point3D` |

### Collection Types

| Type | Description | Java Type |
|------|-------------|-----------|
| `LIST` | Ordered list | `List<?>` |
| `SET` | Unordered unique set | `Set<?>` |
| `MAP` | Key-value map | `Map<String, ?>` |
| `VECTOR` | Numeric vector | `Vector` |

### Graph Types

| Type | Description | Java Type |
|------|-------------|-----------|
| `NODE` | Graph node | `GqldbNode` |
| `EDGE` | Graph edge | `GqldbEdge` |
| `PATH` | Graph path | `GqldbPath` |

## PropertyType Enum

```java
public enum PropertyType {
    UNSET,
    INT32, UINT32, INT64, UINT64,
    FLOAT, DOUBLE,
    STRING, TEXT,
    DATETIME, TIMESTAMP,
    BLOB,
    POINT, POINT3D,
    DECIMAL,
    LIST, SET, MAP,
    NULL, BOOL,
    LOCAL_DATETIME, ZONED_DATETIME,
    DATE, ZONED_TIME, LOCAL_TIME,
    YEAR_TO_MONTH, DAY_TO_SECOND,
    RECORD, VECTOR, TABLE, PATH,
    ERROR, NODE, EDGE
}
```

## Graph Type Enum

```java
public enum GraphType {
    OPEN,      // Schema-less graph
    CLOSED,    // Schema-enforced graph
    ONTOLOGY   // Ontology-enabled graph
}
```

## Health Status Enum

```java
public enum HealthStatus {
    UNKNOWN,
    SERVING,
    NOT_SERVING,
    SERVICE_UNKNOWN
}
```

## Cache Type Enum

```java
public enum CacheType {
    ALL,
    AST,
    PLAN
}
```

## Insert Type Enum

Controls the GQL keyword emitted by `insertNodes(nodes, …)` / `insertEdges(edges, …)`:

```java
import com.gqldb.types.InsertType;

public enum InsertType {
    NORMAL,       // INSERT — errors on duplicate _id
    OVERWRITE,    // INSERT OVERWRITE — replaces entity wholesale on duplicate _id
    UPSERT        // UPSERT — merges new properties into existing entity on duplicate _id
}
```

`OVERWRITE` drops properties not present in the write. `UPSERT` preserves them and only overwrites the ones present in the write. They are not interchangeable.

## InsertConfig

Per-call configuration for the GQL-path insert convenience methods. Extends [`QueryConfig`](java-executing-queries.md):

```java
import com.gqldb.InsertConfig;
import com.gqldb.types.InsertType;

public class InsertConfig extends QueryConfig {
    public InsertConfig();
    InsertType getInsertType();              // default NORMAL
    void setInsertType(InsertType type);     // null → NORMAL
}
```

Inherits `graphName`, `timeout`, `transactionId`, etc. from `QueryConfig`.

## Type Classes

### Node Types

```java
// Data for inserting nodes
public class NodeData {
    public NodeData(List<String> labels, Map<String, Object> properties);
    public NodeData(String id, List<String> labels, Map<String, Object> properties);
    static NodeData create(String label);
    static NodeData create(String label, Map<String, Object> properties);
    static NodeData create(List<String> labels, Map<String, Object> properties);
    static NodeData createWithId(String id, String label);
    static NodeData createWithId(String id, String label,
                                 Map<String, Object> properties);
    static NodeData createWithId(String id, List<String> labels,
                                 Map<String, Object> properties);
    NodeData withProperty(String key, Object value);
    String getId();                          // empty string when unset
    List<String> getLabels();
    Map<String, Object> getProperties();
}

// Node from query results
public class Node {
    String getId();
    String getUuid();                        // internal numeric id (stringified)
    List<String> getLabels();
    Map<String, Object> getProperties();
    Object getProperty(String name);         // single-property accessor
}

// Internal node representation
public class GqldbNode {
    String getId();
    List<String> getLabels();
    Map<String, Object> getProperties();
}
```

### Edge Types

```java
// Data for inserting edges
public class EdgeData {
    public EdgeData(String label, String fromNodeId, String toNodeId,
                    Map<String, Object> properties);
    public EdgeData(String id, String label, String fromNodeId, String toNodeId,
                    Map<String, Object> properties);
    static EdgeData create(String label, String fromNodeId, String toNodeId);
    static EdgeData create(String label, String fromNodeId, String toNodeId,
                           Map<String, Object> properties);
    static EdgeData createWithId(String id, String label,
                                 String fromNodeId, String toNodeId);
    static EdgeData createWithId(String id, String label,
                                 String fromNodeId, String toNodeId,
                                 Map<String, Object> properties);
    EdgeData withProperty(String key, Object value);
    String getId();                          // empty string when unset
    String getLabel();
    String getFromNodeId();
    String getToNodeId();
    Map<String, Object> getProperties();
}

// Edge from query results
public class Edge {
    String getId();
    String getUuid();                        // internal numeric id (stringified)
    String getLabel();
    String getFromNodeId();
    String getToNodeId();
    Map<String, Object> getProperties();
    Object getProperty(String name);         // single-property accessor
}
```

### Path Type

```java
public class Path {
    List<Node> getNodes();
    List<Edge> getEdges();
}

public class GqldbPath {
    List<GqldbNode> getNodes();
    List<GqldbEdge> getEdges();
}
```

### Geospatial Types

```java
public class Point {
    public static final int DEFAULT_POINT_2D_SRID = 4326;  // WGS-84

    public Point(double latitude, double longitude);           // srid defaults to 0 (unset)
    public Point(double latitude, double longitude, int srid);
    double getLatitude();
    double getLongitude();
    int getSrid();              // spatial reference system id; 0 = unset
    double getX();              // alias for getLongitude()
    double getY();              // alias for getLatitude()
}

public class Point3D {
    public static final int DEFAULT_POINT_3D_SRID = 0;      // cartesian, no CRS

    public Point3D(double x, double y, double z);              // srid defaults to 0 (unset)
    public Point3D(double x, double y, double z, int srid);
    double getX();
    double getY();
    double getZ();
    int getSrid();              // spatial reference system id; 0 = unset
    double getLongitude();      // alias for getX()
    double getLatitude();       // alias for getY()
    double getHeight();         // alias for getZ()
}
```

Both point types carry a **spatial reference system id (SRID)**. An SRID of `0` means "unset": on the wire the encoder fills the type default (`DEFAULT_POINT_2D_SRID` = `4326` for `Point`, `DEFAULT_POINT_3D_SRID` = `0` for `Point3D`), and the server normalizes an unset SRID to `4326` for 2D points and `9157` for 3D points. Values decoded from older servers that don't report an SRID (the legacy shorter wire form) also fall back to the type default. Read it back with `getSrid()`:

```java
Point p = new Point(30.5, 114.3);          // srid unset (0)
System.out.println(p.getSrid());           // 0

Point wgs = new Point(30.5, 114.3, 4326);  // explicit WGS-84
System.out.println(wgs.getSrid());         // 4326
```

### Duration Types

```java
public class YearToMonth {
    public YearToMonth(int months);
    int getMonths();
}

public class DayToSecond {
    public DayToSecond(long seconds, int nanoseconds);
    public DayToSecond(java.time.Duration duration);
    long getSeconds();
    int getNanoseconds();
    java.time.Duration toDuration();
}
```

### Vector Type

```java
public class Vector implements Iterable<Float> {
    public Vector(float[] values);
    float[] getValues();
    int getDimensions();
    int size();                  // alias for getDimensions()
    float get(int index);
    Iterator<Float> iterator();  // from Iterable<Float>
}
```

## TypedValue

The driver uses `TypedValue` internally for type-safe data transfer:

```java
import com.gqldb.types.TypedValue;
import com.gqldb.types.PropertyType;

// Get typed values from a row
Row row = response.first().get();
List<TypedValue> typedValues = row.getTypedValues();

for (TypedValue tv : typedValues) {
    PropertyType type = tv.getType();
    Object javaValue = tv.toJava();
    System.out.println("Type: " + type + ", Value: " + javaValue);
}
```

### Parsing values from strings

`TypedValue.fromString` builds a typed value by parsing a string against a target `PropertyType`. Its companion is the instance method `formatValue()`, which renders a `TypedValue` back to the canonical string form.

```java
public static TypedValue fromString(String value, PropertyType targetType);
public String formatValue();
```

A `null` or empty string yields an unset value of the target type. Numeric, boolean, decimal, temporal (canonical `"YYYY-MM-DD HH:mm:ss"` and ISO-8601 duration `P...`), and the following non-scalar forms are supported:

**POINT** (`PropertyType.POINT`) accepts three forms:

| Form | Example | Order |
|------|---------|-------|
| Canonical keyed | `point({latitude: 30.5, longitude: 114.3})` | keys, any order |
| Positional | `30.5,114.3` or `(30.5,114.3)` | **latitude, longitude** |
| OGC/PostGIS WKT | `POINT(114.3 30.5)` | **longitude FIRST**, then latitude |

Latitude is validated to `[-90, 90]` and longitude to `[-180, 180]`. Note the WKT form is `POINT(lon lat)` — the opposite axis order of the lenient comma form.

**POINT3D** (`PropertyType.POINT3D`) accepts `point({x: 1, y: 2, z: 3})`, positional `1,2,3` / `(1,2,3)`, and WKT `POINT(1 2 3)` / `POINT Z(1 2 3)` (cartesian x,y,z — no lon/lat swap).

**VECTOR** (`PropertyType.VECTOR`) accepts `[0.1,0.2,0.3]` or the bracket-less `0.1,0.2,0.3`; `[]` yields an empty vector.

**BLOB** (`PropertyType.BLOB`) decodes standard Base64 by default; a `0x` / `0X` prefix selects hex.

```java
import com.gqldb.types.TypedValue;
import com.gqldb.types.PropertyType;

TypedValue pt   = TypedValue.fromString("POINT(114.3 30.5)", PropertyType.POINT);      // WKT: lon lat
TypedValue pt2  = TypedValue.fromString("point({latitude: 30.5, longitude: 114.3})",
                                        PropertyType.POINT);
TypedValue p3d  = TypedValue.fromString("1,2,3", PropertyType.POINT3D);
TypedValue vec  = TypedValue.fromString("[0.1,0.2,0.3]", PropertyType.VECTOR);
TypedValue b64  = TypedValue.fromString("SGVsbG8=", PropertyType.BLOB);                // Base64
TypedValue hex  = TypedValue.fromString("0x48656c6c6f", PropertyType.BLOB);            // hex
TypedValue dt   = TypedValue.fromString("2026-07-01 15:40:12.153",
                                        PropertyType.LOCAL_DATETIME);

Point parsed = (Point) pt.toJava();
System.out.println(parsed.getLatitude() + ", " + parsed.getLongitude());  // 30.5, 114.3
```

## Type Conversion Examples

### Working with Dates

```java
import java.time.*;

// Insert with date
client.gql("INSERT (e:Event {" +
    "_id: 'e1', " +
    "name: 'Conference', " +
    "date: DATE('2024-06-15'), " +
    "startTime: DATETIME('2024-06-15T09:00:00Z')" +
    "})");

// Query and convert
Response response = client.gql("MATCH (e:Event) RETURN e.date, e.startTime");
response.first().ifPresent(row -> {
    Object date = row.get(0);      // GqldbDate
    Object startTime = row.get(1); // GqldbLocalDateTime (DATETIME)
    System.out.println("Event date: " + date);
    System.out.println("Start time: " + startTime);
});
```

### Working with Points

```java
// Insert with location
client.gql("INSERT (p:Place {" +
    "_id: 'p1', " +
    "name: 'Office', " +
    "location: POINT(37.7749, -122.4194)" +
    "})");

// Query and access point
Response response = client.gql("MATCH (p:Place) RETURN p.location");
response.first().ifPresent(row -> {
    Object location = row.get(0);
    if (location instanceof Point) {
        Point pt = (Point) location;
        System.out.println("Lat: " + pt.getLatitude() + ", Lng: " + pt.getLongitude());
        System.out.println("SRID: " + pt.getSrid());  // e.g. 4326 after server normalization
    }
});
```

### Working with Collections

```java
// Insert with list and map
client.gql("INSERT (u:User {" +
    "_id: 'u1', " +
    "name: 'Alice', " +
    "tags: ['developer', 'blogger'], " +
    "metadata: {level: 5, premium: true}" +
    "})");

// Query collections
Response response = client.gql("MATCH (u:User) RETURN u.tags, u.metadata");
response.first().ifPresent(row -> {
    List<?> tags = (List<?>) row.get(0);
    Map<?, ?> metadata = (Map<?, ?>) row.get(1);
    System.out.println("Tags: " + tags);
    System.out.println("Metadata: " + metadata);
});
```

## Complete Example

```java
import com.gqldb.*;
import com.gqldb.types.PropertyType;
import java.util.*;

public class DataTypesExample {
    public static void main(String[] args) {
        GqldbConfig config = GqldbConfig.builder()
            .hosts("localhost:9000")
            .build();

        try (GqldbClient client = new GqldbClient(config)) {
            client.login("admin", "password");
            client.createGraph("typeDemo");
            client.useGraph("typeDemo");

            // Insert data with various types
            client.gql("INSERT (u:User {" +
                "_id: 'u1', " +
                "name: 'Alice', " +
                "age: 30, " +
                "balance: 1234.56, " +
                "active: true, " +
                "joined: DATE('2023-01-15'), " +
                "location: POINT(40.7128, -74.0060), " +
                "tags: ['developer', 'mentor'], " +
                "settings: {theme: 'dark', notifications: true}" +
                "})");

            // Query and check types
            Response response = client.gql(
                "MATCH (u:User {_id: 'u1'}) " +
                "RETURN u.name, u.age, u.balance, u.active, u.joined, " +
                "u.location, u.tags, u.settings"
            );

            response.first().ifPresent(row -> {
                System.out.println("Name (String): " + row.getString(0));
                System.out.println("Age (long): " + row.getLong(1));
                System.out.println("Balance (double): " + row.getDouble(2));
                System.out.println("Active (boolean): " + row.getBoolean(3));
                System.out.println("Joined: " + row.get(4));
                System.out.println("Location: " + row.get(5));
                System.out.println("Tags: " + row.get(6));
                System.out.println("Settings: " + row.get(7));

                // Check property types
                System.out.println("\nProperty types:");
                List<TypedValue> typedValues = row.getTypedValues();
                List<String> columns = response.getColumns();
                for (int i = 0; i < typedValues.size(); i++) {
                    System.out.println("  " + columns.get(i) + ": " +
                        typedValues.get(i).getType());
                }
            });

            client.dropGraph("typeDemo");

        } catch (GqldbException e) {
            System.err.println("Error: " + e.getMessage());
        }
    }
}
```
