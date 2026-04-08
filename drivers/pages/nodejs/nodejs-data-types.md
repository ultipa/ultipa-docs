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
| `DATETIME` | Date and time (deprecated, use TIMESTAMP) | `Date` |
| `DATE` | Date only | `Date` |
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
| `POINT` | 2D geographic point | `{ latitude: number, longitude: number }` |
| `POINT3D` | 3D point | `{ x: number, y: number, z: number }` |

### Collection Types

| Type | Description | JavaScript Type |
|------|-------------|-----------------|
| `LIST` | Ordered list | `any[]` |
| `SET` | Unordered unique set | `any[]` |
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

## Type Interfaces

### Node Types

```typescript
// Data for inserting nodes
interface NodeData {
  id?: string;                        // Optional node ID
  labels: string[];
  properties: Record<string, any>;
}

// Node from query results
interface Node {
  id: string;
  labels: string[];
  properties: Record<string, any>;
}
```

### Edge Types

```typescript
// Data for inserting edges
interface EdgeData {
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
  internalTxId: number;
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

```typescript
interface Point {
  latitude: number;
  longitude: number;
}

interface Point3D {
  x: number;
  y: number;
  z: number;
}
```

## TypedValue

The driver uses `TypedValue` internally for type-safe data transfer:

```typescript
interface TypedValue {
  type: PropertyType;
  data: Buffer;
  isNull: boolean;
}

// Create a TypedValue
import { createTypedValue, PropertyType } from '@ultipa-graph/ultipa-driver';

const intValue = createTypedValue(PropertyType.INT64, 42);
const stringValue = createTypedValue(PropertyType.STRING, 'hello');

// Convert TypedValue to JavaScript value
import { typedValueToJS } from '@ultipa-graph/ultipa-driver';

const jsValue = typedValueToJS(intValue);  // 42
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
  const date: Date = row.get(0);  // JavaScript Date
  const startTime: Date = row.get(1);
  console.log('Event date:', date.toISOString());
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
    hosts: ['localhost:60061']
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
