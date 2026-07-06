# Data Types

The GQLDB Node.js driver supports a comprehensive set of data types for storing and querying graph data. This guide covers property types, enums, and type conversions.

## Property Types

The `PropertyType` enum defines all supported data types:

```typescript
import { PropertyType } from '@ultipa-graph/ultipa-driver';
```

### Numeric Types

| Type | Description | JavaScript Type |
|------|-------------|-----------------|
| `INT32` | 32-bit signed integer | `number` |
| `UINT32` | 32-bit unsigned integer | `number` |
| `INT64` | 64-bit signed integer | `number` |
| `UINT64` | 64-bit unsigned integer | `number` |
| `FLOAT` | 32-bit floating point | `number` |
| `DOUBLE` | 64-bit floating point | `number` |
| `DECIMAL` | Arbitrary precision decimal | `{ value: string }` |

### String Types

| Type | Description | JavaScript Type |
|------|-------------|-----------------|
| `STRING` | Variable-length string | `string` |
| `TEXT` | Long text | `string` |

### Boolean and Null

| Type | Description | JavaScript Type |
|------|-------------|-----------------|
| `BOOL` | Boolean value | `boolean` |
| `NULL` | Null value | `null` |
| `UNSET` | Unset/unknown type | `undefined` |

### Binary

| Type | Description | JavaScript Type |
|------|-------------|-----------------|
| `BLOB` | Binary data | `Buffer` |

### Date and Time Types

| Type | Description | JavaScript Type |
|------|-------------|-----------------|
| `TIMESTAMP` | Unix timestamp with nanoseconds | `{ year, month, day, hour, minute, second, nanosecond }` |
| `DATETIME` | Date and time (deprecated, use TIMESTAMP) | `{ year, month, day, hour, minute, second, nanosecond }` |
| `DATE` | Date only | `{ year, month, day }` |
| `LOCAL_DATETIME` | Local date and time | `{ year, month, day, hour, minute, second, nanosecond }` |
| `ZONED_DATETIME` | Date and time with timezone | `{ year, month, day, hour, minute, second, nanosecond, offsetMinutes }` |
| `LOCAL_TIME` | Local time of day | `{ hour, minute, second, nanosecond }` |
| `ZONED_TIME` | Time with timezone | `{ hour, minute, second, nanosecond, offsetMinutes }` |

### Duration Types

| Type | Description | JavaScript Type |
|------|-------------|-----------------|
| `YEAR_TO_MONTH` | Year-month duration | `{ months: number }` |
| `DAY_TO_SECOND` | Day-second duration | `{ seconds: number, nanoseconds: number }` |

### Geospatial Types

| Type | Description | JavaScript Type |
|------|-------------|-----------------|
| `POINT` | 2D geographic point | `{ latitude: number, longitude: number, srid: number }` |
| `POINT3D` | 3D point | `{ x: number, y: number, z: number, srid: number }` |

### Collection Types

| Type | Description | JavaScript Type |
|------|-------------|-----------------|
| `LIST` | Ordered list | `any[]` |
| `SET` | Unordered unique set | `Set<any>` |
| `MAP` | Key-value map | `Record<string, any>` |
| `VECTOR` | Numeric vector | `{ values: number[] }` |

### Graph Types

| Type | Description | JavaScript Type |
|------|-------------|-----------------|
| `NODE` | Graph node | `Node` |
| `EDGE` | Graph edge | `Edge` |
| `PATH` | Graph path | `Path` |

### Other Types

| Type | Description | JavaScript Type |
|------|-------------|-----------------|
| `RECORD` | Record/row | `object` |
| `TABLE` | Table data | `object` |
| `ERROR` | Error value | `{ code: number, message: string }` |

## PropertyType Enum Values

```typescript
enum PropertyType {
  UNSET = 0,
  INT32 = 1,
  UINT32 = 2,
  INT64 = 3,
  UINT64 = 4,
  FLOAT = 5,
  DOUBLE = 6,
  STRING = 7,
  DATETIME = 8,  // Deprecated
  TIMESTAMP = 9,
  TEXT = 10,
  BLOB = 11,
  POINT = 12,
  DECIMAL = 13,
  LIST = 14,
  SET = 15,
  MAP = 16,
  NULL = 17,
  BOOL = 18,
  LOCAL_DATETIME = 19,
  ZONED_DATETIME = 20,
  DATE = 21,
  ZONED_TIME = 22,
  LOCAL_TIME = 23,
  YEAR_TO_MONTH = 24,
  DAY_TO_SECOND = 25,
  RECORD = 26,
  POINT3D = 27,
  VECTOR = 28,
  TABLE = 29,
  PATH = 30,
  ERROR = 31,
  NODE = 32,
  EDGE = 33
}
```

## Graph Type Enum

```typescript
enum GraphType {
  OPEN = 0,      // Schema-less graph
  CLOSED = 1,    // Schema-enforced graph
  ONTOLOGY = 2   // Ontology-enabled graph
}
```

## Health Status Enum

```typescript
enum HealthStatus {
  UNKNOWN = 0,
  SERVING = 1,
  NOT_SERVING = 2,
  SERVICE_UNKNOWN = 3
}
```

## Cache Type Enum

```typescript
enum CacheType {
  ALL = 0,
  AST = 1,
  PLAN = 2
}
```

## InsertType Enum

Controls the GQL keyword emitted by `insertNodes(nodes, …)` / `insertEdges(edges, …)`. Note: Node.js uses PascalCase enum values, unlike the other SDKs.

```typescript
import { InsertType } from '@ultipa-graph/ultipa-driver';

enum InsertType {
  Normal = 0,       // INSERT — errors on duplicate _id
  Overwrite = 1,    // INSERT OVERWRITE — replaces entity wholesale on duplicate _id
  Upsert = 2,       // UPSERT — merges new properties into existing entity on duplicate _id
}
```

`Overwrite` drops properties not present in the write. `Upsert` preserves them and only overwrites the ones present in the write. They are not interchangeable.

## InsertConfig

Per-call configuration for the GQL-path insert convenience methods. Extends [`QueryConfig`](nodejs-executing-queries.md):

```typescript
import { InsertConfig, InsertType } from '@ultipa-graph/ultipa-driver';

interface InsertConfig extends QueryConfig {
  insertType?: InsertType;            // defaults to InsertType.Normal when omitted
  // inherits from QueryConfig:
  //   graphName?: string;
  //   parameters?: Record<string, any>;
  //   transactionId?: number;
  //   timeout?: number;
  //   readOnly?: boolean;
  //   maxPathResults?: number;
}
```

## Type Interfaces

### Node Types

```typescript
// Data for inserting nodes (input to insertNodes)
interface NodeData {
  id?: string;                        // Optional custom _id (auto-generated when empty)
  labels: string[];
  properties: Record<string, any>;
}

// Node from query results (returned in Response rows)
interface Node {
  id: string;
  labels: string[];
  properties: Record<string, any>;
}

// Internal/wire-level node representation (gqldb 6.1.147+ carries uuid)
interface GqldbNode {
  id: string;                         // user-facing identifier
  uuid: string;                       // system numeric handle, decimal-formatted;
                                      // '' on pre-6.1.147 servers
  labels: string[];
  properties: Record<string, any>;
}
```

### Edge Types

```typescript
// Data for inserting edges (input to insertEdges)
interface EdgeData {
  id?: string;                        // Optional custom _id (requires WITH EDGE_ID graph)
  label: string;
  fromNodeId: string;
  toNodeId: string;
  properties: Record<string, any>;
}

// Edge from query results
interface Edge {
  id: string;
  label: string;
  fromNodeId: string;
  toNodeId: string;
  properties: Record<string, any>;
}

// Internal/wire-level edge representation
interface GqldbEdge {
  id: string;
  uuid: string;                       // '' on pre-6.1.147 servers
  label: string;
  fromNodeId: string;
  toNodeId: string;
  properties: Record<string, any>;
}
```

### Path Type

```typescript
interface Path {
  nodes: Node[];
  edges: Edge[];
}
```

### Graph Information

```typescript
interface GraphInfo {
  name: string;
  graphType: GraphType;
  description: string;
  nodeCount: number;
  edgeCount: number;
}
```

### Transaction Information

```typescript
interface TransactionInfo {
  transactionId: number;
  sessionId: number;
  graphName: string;
  readOnly: boolean;
  createdAt: number;
  durationMs: number;
  internalTxId: string;
}
```

### Schema Types

```typescript
interface Schema {
  name: string;
  properties: PropertyDef[];
}

interface PropertyDef {
  name: string;
  type: PropertyType;
}
```

### Table Types

```typescript
interface Table {
  name: string;
  headers: Header[];
  rows: any[][];
}

interface Header {
  name: string;
  type: PropertyType;
}

interface Attr {
  name: string;
  type: PropertyType;
  values: any[];
}
```

## Geospatial Types

`Point` and `Point3D` are classes (not plain interfaces) with read-only getter aliases. Plain object literals are still accepted as `Point` / `Point3D` values, but constructing via the class gives you the alias getters.

```typescript
class Point {
  constructor(
    public readonly latitude: number,
    public readonly longitude: number,
    public readonly srid: number = 0,   // spatial reference system id; 0 = unset
  );
  get x(): number;                    // alias for longitude
  get y(): number;                    // alias for latitude
}

class Point3D {
  constructor(
    public readonly x: number,
    public readonly y: number,
    public readonly z: number,
    public readonly srid: number = 0,   // spatial reference system id; 0 = unset
  );
  get longitude(): number;            // alias for x
  get latitude(): number;             // alias for y
  get height(): number;               // alias for z
}
```

`Point` validates against WGS-84 bounds server-side (longitude ∈ [-180, 180], latitude ∈ [-90, 90]). `Point3D` is Cartesian — the server does **not** enforce geographic bounds on Point3D, even when accessed through the lon/lat aliases.

### Spatial reference system (`srid`)

Both `Point` and `Point3D` carry a numeric `srid` (spatial reference system identifier). It defaults to `0`, meaning **unset**. An unset SRID resolves to the type's default:

| Type | Unset (`srid === 0`) normalizes to | Constant |
|------|------------------------------------|----------|
| `Point` (2D) | `4326` (WGS-84, geographic) | `DEFAULT_POINT_2D_SRID = 4326` |
| `Point3D` (3D) | `9157` (Cartesian) | `DEFAULT_POINT_3D_SRID = 0` |

The `srid` field round-trips: a point decoded from a query result exposes the server's value. Legacy payloads from older servers (no SRID on the wire) decode to the type's default SRID. Plain object literals may also include `srid`; when omitted it is treated as `0`.

```typescript
import { Point, Point3D } from '@ultipa-graph/ultipa-driver';

// Unset SRID (server normalizes 2D → 4326)
const p1 = new Point(37.7749, -122.4194);
console.log(p1.srid);              // 0 (unset)

// Explicit SRID
const p2 = new Point(37.7749, -122.4194, 4326);

// 3D point with SRID
const p3 = new Point3D(1, 2, 3, 9157);

// Reading back a point returned from a query
const response = await client.gql('MATCH (p:Place) RETURN p.location');
const loc = response.first()?.get(0);
console.log(loc.latitude, loc.longitude, loc.srid);
```

## Vector Type

```typescript
class Vector implements Iterable<number> {
  constructor(public readonly values: number[]);
  get length(): number;               // dimension count
  [Symbol.iterator](): IterableIterator<number>;
}
```

`vec.length` returns the dimension; `for (const v of vec)` walks the float components. Plain object literals `{ values: [...] }` still pass `isVector()`; construct via the class to get the iterator / length getter.

## TypedValue

The driver uses `TypedValue` internally for type-safe data transfer:

```typescript
interface TypedValue {
  type: PropertyType;
  data: Buffer;
  isNull: boolean;
}

// Create a TypedValue — the PropertyType is inferred from the JavaScript value
import { createTypedValue } from '@ultipa-graph/ultipa-driver';

const intValue = createTypedValue(42);        // inferred as INT64
const stringValue = createTypedValue('hello'); // inferred as STRING

// Convert TypedValue to JavaScript value
import { typedValueToJS } from '@ultipa-graph/ultipa-driver';

const jsValue = typedValueToJS(intValue);  // 42
```

## Temporal String Formatting

Temporal values decode to plain component objects (`{ year, month, day, ... }`), not JavaScript `Date`s. To render them, the driver exposes canonical string formatters that emit the `"YYYY-MM-DD HH:mm:ss[.fff]"` form: a **space** separates date and time, the fractional second is **trimmed** of trailing zeros (omitted entirely when zero), and zoned types append the UTC offset as `+HH:MM` / `-HH:MM`.

| Function | Input type | Example output |
|----------|-----------|----------------|
| `dateToString(d)` | `GqldbDate` | `2026-07-01` |
| `localTimeToString(t)` | `GqldbLocalTime` | `15:40:12.153` |
| `zonedTimeToString(t)` | `GqldbZonedTime` | `15:40:12.153+08:00` |
| `localDateTimeToString(dt)` | `GqldbLocalDateTime` | `2026-07-01 15:40:12.153` |
| `zonedDateTimeToString(dt)` | `GqldbZonedDateTime` | `2026-07-01 15:40:12.153+08:00` |

`formatValue(tv)` produces the same canonical string directly from a `TypedValue` for any temporal type, including `TIMESTAMP` (rendered in UTC).

```typescript
import {
  localDateTimeToString,
  zonedDateTimeToString,
  dateToString,
} from '@ultipa-graph/ultipa-driver';

const response = await client.gql('MATCH (e:Event) RETURN e.date, e.startTime');
const row = response.first();
if (row) {
  const date = row.get(0);       // GqldbDate component object
  const start = row.get(1);      // GqldbLocalDateTime component object
  console.log(dateToString(date));            // "2024-06-15"
  console.log(localDateTimeToString(start));  // "2024-06-15 09:00:00"
}
```

> Note: The decoded values remain component objects, so `response.toJSON()` / `toObjects()` serialize them as their `{ year, month, ... }` fields. Call the formatter (or `formatValue`) when you need the canonical string form. These formatters — and `fromString` / `formatValue` — are re-exported from the package root (`@ultipa-graph/ultipa-driver`).

## Parsing Values from Strings

`fromString(s, targetType)` parses a string into a `TypedValue` of the requested `PropertyType`; an empty string yields a null `TypedValue`. Its companion `formatValue(tv)` performs the inverse — serializing a `TypedValue` back to its canonical string.

```typescript
import { PropertyType, fromString, formatValue } from '@ultipa-graph/ultipa-driver';

function fromString(s: string, targetType: PropertyType): TypedValue;
function formatValue(tv: TypedValue): string;

const tv = fromString('42', PropertyType.INT64);
console.log(formatValue(tv));  // "42"
```

Beyond the scalar and temporal types (which accept the same canonical forms shown above), the spatial, vector, and blob types accept several notations:

### Points (`PropertyType.POINT`)

| Form | Example | Coordinate order |
|------|---------|------------------|
| Canonical keyed | `point({latitude: 30.5, longitude: 114.3})` | keys, any order |
| WKT | `POINT(114.3 30.5)` | **longitude first** (OGC/PostGIS) |
| Positional | `30.5,114.3` or `(30.5,114.3)` | **latitude first** (opposite of WKT) |

Latitude is validated against `[-90, 90]` and longitude against `[-180, 180]`.

```typescript
const a = fromString('point({latitude: 30.5, longitude: 114.3})', PropertyType.POINT);
const b = fromString('POINT(114.3 30.5)', PropertyType.POINT); // WKT: lon first
const c = fromString('30.5,114.3', PropertyType.POINT);        // positional: lat first
```

### 3D points (`PropertyType.POINT3D`)

Cartesian `x, y, z` — no coordinate swap. Accepts keyed `point({x: 1, y: 2, z: 3})`, WKT `POINT(1 2 3)` / `POINT Z(1 2 3)`, and positional `1,2,3` / `(1,2,3)`.

```typescript
const p = fromString('point({x: 1, y: 2, z: 3})', PropertyType.POINT3D);
```

### Vectors (`PropertyType.VECTOR`)

A comma-separated float list, with or without brackets; `[]` yields an empty vector.

```typescript
const v = fromString('[0.1, 0.2, 0.3]', PropertyType.VECTOR);
const w = fromString('0.1,0.2,0.3', PropertyType.VECTOR);  // brackets optional
```

### Binary (`PropertyType.BLOB`)

Standard Base64 by default; a `0x` / `0X` prefix selects hexadecimal. Invalid encodings throw.

```typescript
const fromB64 = fromString('SGVsbG8=', PropertyType.BLOB);   // base64 → Buffer
const fromHex = fromString('0x48656c6c6f', PropertyType.BLOB); // hex → Buffer
```

## Type Conversion Examples

### Working with Dates

```typescript
// Insert with date
await client.gql(`
  INSERT (e:Event {
    _id: 'e1',
    name: 'Conference',
    date: DATE('2024-06-15'),
    startTime: DATETIME('2024-06-15T09:00:00Z')
  })
`);

// Query and convert
const response = await client.gql('MATCH (e:Event) RETURN e.date, e.startTime');
const row = response.first();
if (row) {
  // DATE decodes to a { year, month, day } component object (not a JS Date);
  // DATETIME/TIMESTAMP decode to { year, month, day, hour, minute, second, nanosecond }.
  const date = row.get(0);
  const startTime = row.get(1);
  console.log('Event date:', `${date.year}-${date.month}-${date.day}`);
  console.log('Start time:', `${startTime.year}-${startTime.month}-${startTime.day} ${startTime.hour}:${startTime.minute}:${startTime.second}`);
}
```

### Working with Points

```typescript
// Insert with location
await client.gql(`
  INSERT (p:Place {
    _id: 'p1',
    name: 'Office',
    location: POINT(37.7749, -122.4194)
  })
`);

// Query and access point
const response = await client.gql('MATCH (p:Place) RETURN p.location');
const location = response.first()?.get(0);
console.log(`Lat: ${location.latitude}, Lng: ${location.longitude}`);
```

### Working with Collections

```typescript
// Insert with list and map
await client.gql(`
  INSERT (u:User {
    _id: 'u1',
    name: 'Alice',
    tags: ['developer', 'blogger'],
    metadata: {level: 5, premium: true}
  })
`);

// Query collections
const response = await client.gql('MATCH (u:User) RETURN u.tags, u.metadata');
const row = response.first();
if (row) {
  const tags: string[] = row.get(0);
  const metadata: Record<string, any> = row.get(1);
  console.log('Tags:', tags);
  console.log('Metadata:', metadata);
}
```

### Working with Vectors

```typescript
// Insert with vector
await client.gql(`
  INSERT (d:Document {
    _id: 'd1',
    title: 'Sample',
    embedding: VECTOR([0.1, 0.2, 0.3, 0.4])
  })
`);

// Query vector
const response = await client.gql('MATCH (d:Document) RETURN d.embedding');
const embedding = response.first()?.get(0);
console.log('Vector values:', embedding.values);
```

## Complete Example

```typescript
import { GqldbClient, createConfig, PropertyType } from '@ultipa-graph/ultipa-driver';

async function main() {
  const client = new GqldbClient(createConfig({
    hosts: ['localhost:9000']
  }));

  try {
    await client.login('admin', 'password');
    await client.createGraph('typeDemo');
    await client.useGraph('typeDemo');

    // Insert data with various types
    await client.gql(`
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
    `);

    // Query and check types
    const response = await client.gql(`
      MATCH (u:User {_id: 'u1'})
      RETURN u.name, u.age, u.balance, u.active, u.joined, u.location, u.tags, u.settings
    `);

    const row = response.first();
    if (row) {
      console.log('Name (string):', row.getString(0));
      console.log('Age (number):', row.getNumber(1));
      console.log('Balance (number):', row.getNumber(2));
      console.log('Active (boolean):', row.getBoolean(3));
      console.log('Joined (Date):', row.get(4));
      console.log('Location (Point):', row.get(5));
      console.log('Tags (array):', row.get(6));
      console.log('Settings (object):', row.get(7));

      // Check property type
      console.log('\nProperty types:');
      for (let i = 0; i < response.columns.length; i++) {
        console.log(`  ${response.columns[i]}: ${PropertyType[row.getType(i)]}`);
      }
    }

    await client.dropGraph('typeDemo');

  } finally {
    await client.close();
  }
}

main().catch(console.error);
```
