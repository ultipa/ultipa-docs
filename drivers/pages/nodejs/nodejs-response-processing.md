# Response Processing

The GQLDB Node.js driver provides the `Response` and `Row` classes for working with query results. This guide covers how to extract and convert data from query responses.

## Response Class

The `gql()` method returns a `Response` object containing query results:

```typescript
import { GqldbClient, Response } from '@ultipa-graph/ultipa-driver';

async function queryExample(client: GqldbClient) {
  const response: Response = await client.gql('MATCH (n:User) RETURN n.name, n.age');

  console.log('Columns:', response.columns);     // ['n.name', 'n.age']
  console.log('Row count:', response.rowCount);  // Number of rows
  console.log('Has more:', response.hasMore);    // Pagination indicator
  console.log('Warnings:', response.warnings);   // Any query warnings
  console.log('Rows affected:', response.rowsAffected);  // For write operations
}
```

### Response Properties

| Property | Type | Description |
|----------|------|-------------|
| `columns` | `string[]` | Column names from the query |
| `rows` | `Row[]` | Array of result rows |
| `rowCount` | `number` | Total number of rows |
| `hasMore` | `boolean` | Whether more results are available |
| `warnings` | `string[]` | Query warnings |
| `rowsAffected` | `number` | Rows affected by write operations |
| `length` | `number` | Same as `rows.length` |

## Row Class

Each row contains values that can be accessed by index:

```typescript
const response = await client.gql('MATCH (n:User) RETURN n.name, n.age, n.active');

for (const row of response.rows) {
  // Access by index
  const name = row.get(0);    // First column
  const age = row.get(1);     // Second column
  const active = row.get(2);  // Third column

  // Typed accessors
  const nameStr = row.getString(0);    // Returns string
  const ageNum = row.getNumber(1);     // Returns number
  const activeBool = row.getBoolean(2); // Returns boolean

  console.log(`${nameStr}, age ${ageNum}, active: ${activeBool}`);
}
```

### Row Methods

| Method | Return Type | Description |
|--------|-------------|-------------|
| `get(index)` | `any` | Get value at index |
| `getString(index)` | `string` | Get value as string |
| `getNumber(index)` | `number` | Get value as number |
| `getBoolean(index)` | `boolean` | Get value as boolean |
| `getType(index)` | `PropertyType` | Get the property type at index |

## Iterating Results

### Using for...of

```typescript
const response = await client.gql('MATCH (n) RETURN n');

// Response implements Symbol.iterator
for (const row of response) {
  console.log(row.get(0));
}
```

### Using forEach

```typescript
response.forEach((row, index) => {
  console.log(`Row ${index}:`, row.get(0));
});
```

### Using map

```typescript
const names = response.map(row => row.getString(0));
console.log('Names:', names);
```

## Quick Access Methods

### First and Last Row

```typescript
const first = response.first();  // First row or undefined
const last = response.last();    // Last row or undefined

if (first) {
  console.log('First result:', first.get(0));
}
```

### Check if Empty

```typescript
if (response.isEmpty()) {
  console.log('No results found');
}
```

### Single Value

For queries that return a single row with a single column:

```typescript
const countResponse = await client.gql('MATCH (n) RETURN count(n)');
const count = countResponse.singleValue();  // Returns the single value

// Typed single value accessors
const countNum = countResponse.singleNumber();  // As number
const countStr = countResponse.singleString();  // As string
```

## Converting to Objects

### toObjects()

Convert rows to an array of plain objects:

```typescript
const response = await client.gql('MATCH (u:User) RETURN u.name AS name, u.age AS age');
const users = response.toObjects();

// Result: [{ name: 'Alice', age: 30 }, { name: 'Bob', age: 25 }]
for (const user of users) {
  console.log(`${user.name} is ${user.age} years old`);
}
```

### toJSON()

Convert to JSON string:

```typescript
const json = response.toJSON();
console.log(json);
// '[{"name":"Alice","age":30},{"name":"Bob","age":25}]'
```

### Get Value by Column Name

```typescript
const response = await client.gql('MATCH (u:User) RETURN u.name AS name, u.age AS age');

for (const row of response.rows) {
  const name = response.getByName(row, 'name');
  const age = response.getByName(row, 'age');
  console.log(`${name}: ${age}`);
}
```

## Column Access with alias() and get()

The preferred way to access typed results is through `alias()` (by column name) or `get()` (by column index), which return an `AliasResult` object with methods to extract nodes, edges, paths, tables, and attributes:

```typescript
const response = await client.gql('MATCH (u:User)-[r:Follows]->(f:User) RETURN u, r, f');

// Access by column name
const users = response.alias('u').asNodes();
const follows = response.alias('r').asEdges();
const friends = response.alias('f').asNodes();

// Or by column index
const usersAlt = response.get(0).asNodes();
```

### AliasResult Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `asNodes()` | `NodeResult` | Extract as node objects |
| `asEdges()` | `EdgeResult` | Extract as edge objects |
| `asPaths()` | `Path[]` | Extract as path objects |
| `asTable()` | `Table` | Extract as table |
| `asAttr()` | `Attr` | Extract as attribute |

```typescript
// Extract nodes with schemas
const nodeResult = response.alias('u').asNodes();
for (const node of nodeResult.nodes) {
  console.log('ID:', node.id);
  console.log('Labels:', node.labels);
  console.log('Properties:', node.properties);
}

// Extract edges
const edgeResult = response.alias('r').asEdges();
for (const edge of edgeResult.edges) {
  console.log('From:', edge.from, 'To:', edge.to, 'Label:', edge.label);
}
```

## Extracting Graph Elements (Deprecated)

> The following methods on `Response` are deprecated. Use `response.alias(name)` or `response.get(index)` instead.

### asNodes()

Extract nodes from the response:

```typescript
import { Node, NodeResult, Schema } from '@ultipa-graph/ultipa-driver';

const response = await client.gql('MATCH (u:User) RETURN u');
const result: NodeResult = response.asNodes();

// Access nodes
for (const node of result.nodes) {
  console.log('ID:', node.id);
  console.log('Labels:', node.labels);
  console.log('Properties:', node.properties);
}

// Access inferred schemas
for (const [label, schema] of result.schemas) {
  console.log(`Schema for ${label}:`, schema);
}
```

### Node Interface

```typescript
interface Node {
  id: string;
  labels: string[];
  properties: Record<string, any>;
}

interface NodeResult {
  nodes: Node[];
  schemas: Map<string, Schema>;
}
```

### asEdges()

Extract edges from the response:

```typescript
import { Edge, EdgeResult } from '@ultipa-graph/ultipa-driver';

const response = await client.gql('MATCH ()-[e:Follows]->() RETURN e');
const result: EdgeResult = response.asEdges();

for (const edge of result.edges) {
  console.log('ID:', edge.id);
  console.log('Label:', edge.label);
  console.log('From:', edge.fromNodeId);
  console.log('To:', edge.toNodeId);
  console.log('Properties:', edge.properties);
}
```

### Edge Interface

```typescript
interface Edge {
  id: string;
  label: string;
  fromNodeId: string;
  toNodeId: string;
  properties: Record<string, any>;
}

interface EdgeResult {
  edges: Edge[];
  schemas: Map<string, Schema>;
}
```

### asPaths()

Extract paths from the response:

```typescript
import { Path } from '@ultipa-graph/ultipa-driver';

const response = await client.gql('MATCH p = (a)-[*1..3]->(b) RETURN p LIMIT 10');
const paths: Path[] = response.asPaths();

for (const path of paths) {
  console.log('Path nodes:', path.nodes.length);
  console.log('Path edges:', path.edges.length);

  // Print path
  for (let i = 0; i < path.nodes.length; i++) {
    console.log(`  Node: ${path.nodes[i].id}`);
    if (i < path.edges.length) {
      console.log(`    -[${path.edges[i].label}]->`);
    }
  }
}
```

### Path Interface

```typescript
interface Path {
  nodes: Node[];
  edges: Edge[];
}
```

## Table Format

### asTable()

Get the response as a generic table:

```typescript
import { Table, Header } from '@ultipa-graph/ultipa-driver';

const response = await client.gql('MATCH (u:User) RETURN u.name, u.age');
const table: Table = response.asTable();

console.log('Headers:', table.headers.map(h => h.name));
console.log('Rows:', table.rows);
```

### Table Interface

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
```

## Attribute Extraction

### asAttr()

Extract values from a specific column:

```typescript
import { Attr } from '@ultipa-graph/ultipa-driver';

const response = await client.gql('MATCH (u:User) RETURN u.age AS age');
const ageAttr: Attr = response.asAttr('age');

console.log('Column name:', ageAttr.name);
console.log('Type:', ageAttr.type);
console.log('Values:', ageAttr.values);

// Calculate statistics
const ages = ageAttr.values as number[];
const avgAge = ages.reduce((a, b) => a + b, 0) / ages.length;
console.log('Average age:', avgAge);
```

### Attr Interface

```typescript
interface Attr {
  name: string;
  type: PropertyType;
  values: any[];
}
```

## Complete Example

```typescript
import { GqldbClient, createConfig } from '@ultipa-graph/ultipa-driver';

async function main() {
  const client = new GqldbClient(createConfig({
    hosts: ['localhost:9000'],
    defaultGraph: 'socialNetwork'
  }));

  try {
    await client.login('admin', 'password');

    // Query nodes
    console.log('=== Query Nodes ===');
    const nodeResponse = await client.gql('MATCH (u:User) RETURN u LIMIT 5');
    const { nodes } = nodeResponse.asNodes();
    for (const node of nodes) {
      console.log(`User ${node.id}: ${node.properties.name}`);
    }

    // Query with multiple columns
    console.log('\n=== Query Columns ===');
    const colResponse = await client.gql(
      'MATCH (u:User) RETURN u.name AS name, u.age AS age ORDER BY u.age DESC LIMIT 3'
    );
    const users = colResponse.toObjects();
    console.log('Top 3 oldest users:', users);

    // Query paths
    console.log('\n=== Query Paths ===');
    const pathResponse = await client.gql(
      'MATCH p = (a:User)-[:Follows*1..2]->(b:User) RETURN p LIMIT 3'
    );
    const paths = pathResponse.asPaths();
    for (const path of paths) {
      const route = path.nodes.map(n => n.properties.name || n.id).join(' -> ');
      console.log(`Path: ${route}`);
    }

    // Aggregate query
    console.log('\n=== Aggregate Query ===');
    const countResponse = await client.gql('MATCH (n) RETURN count(n)');
    console.log('Total nodes:', countResponse.singleNumber());

    // Extract attribute values
    console.log('\n=== Attribute Extraction ===');
    const ageResponse = await client.gql('MATCH (u:User) RETURN u.age AS age');
    const ages = ageResponse.asAttr('age');
    const numericAges = ages.values.filter(a => typeof a === 'number') as number[];
    if (numericAges.length > 0) {
      console.log('Ages:', numericAges);
      console.log('Min age:', Math.min(...numericAges));
      console.log('Max age:', Math.max(...numericAges));
    }

  } finally {
    await client.close();
  }
}

main().catch(console.error);
```
