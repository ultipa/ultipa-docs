# Schema Management

The GQLDB Node.js driver provides convenience methods for managing labels, properties, constraints, indexes, and fulltext indexes. These methods require a graph to be selected via `useGraph()` or a `QueryConfig` with `graphName`.

## Label Methods

| Method | Description |
|--------|-------------|
| `showLabels(config)` | List all labels (node and edge) |
| `showNodeLabels(config)` | List node labels |
| `showEdgeLabels(config)` | List edge labels |
| `showNodeTypes(config)` | List node types with properties (CLOSED graph) |
| `showEdgeTypes(config)` | List edge types with properties (CLOSED graph) |
| `getNodeLabel(name, config)` | Get a single node label |
| `getEdgeLabel(name, config)` | Get a single edge label |
| `createNodeLabel(name, props, config)` | Create a node label |
| `createEdgeLabel(name, props, config)` | Create an edge label |
| `dropNodeLabel(name, config)` | Drop a node label |
| `dropEdgeLabel(...names)` | Drop one or more edge labels |
| `createLabelIfNotExist(type, name, props, config)` | Create label if it doesn't exist |
| `alterNodeLabel(oldName, newName, config)` | Rename a node label |
| `alterEdgeLabel(oldName, newName, config)` | Rename an edge label |

## Listing Labels

```typescript
await client.useGraph('myGraph');

// All labels
const labels = await client.showLabels();
for (const label of labels) {
  console.log(`${label.labels} (${label.type})`);
}

// Node labels only
const nodeLabels = await client.showNodeLabels();

// Edge labels only
const edgeLabels = await client.showEdgeLabels();
```

## Listing Types (CLOSED Graph)

```typescript
const nodeTypes = await client.showNodeTypes();
for (const nt of nodeTypes) {
  const props = nt.properties.map(p => p.name).join(', ');
  console.log(`${nt.name}: ${props}`);
}
```

## Creating Labels

```typescript
import { DBType } from '@ultipa-graph/ultipa-driver';

// Create a node label with properties
await client.createNodeLabel('Person', [
  { name: 'name', type: 'STRING' },
  { name: 'age', type: 'INT64' },
]);

// Create an edge label
await client.createEdgeLabel('KNOWS', [
  { name: 'since', type: 'INT64' },
]);

// Idempotent create — returns true if created, false if already existed
const created = await client.createLabelIfNotExist(DBType.NODE, 'Person', [
  { name: 'name', type: 'STRING' },
]);
```

## Renaming / Dropping Labels

```typescript
await client.alterNodeLabel('OldName', 'NewName');
await client.dropNodeLabel('Person');
await client.dropEdgeLabel('KNOWS', 'LIKES');
```

## Property Methods

| Method | Description |
|--------|-------------|
| `showNodeProperty(labelName, config)` | Show properties for a node label |
| `showEdgeProperty(labelName, config)` | Show properties for an edge label |
| `getNodeProperty(labelName, propName, config)` | Get a single property |
| `createNodeProperty(labelName, props, config)` | Add properties |
| `dropNodeProperty(labelName, ...propNames)` | Drop properties |
| `createPropertyIfNotExist(type, labelName, props, config)` | Add if not exist |

## Managing Properties

```typescript
// Show
const props = await client.showNodeProperty('Person');
for (const p of props) {
  console.log(`  ${p.name}: ${p.type}`);
}

// Add
await client.createNodeProperty('Person', [
  { name: 'email', type: 'STRING' },
]);

// Drop
await client.dropNodeProperty('Person', 'email');
```

## Constraint Methods

| Method | Description |
|--------|-------------|
| `createNotNullConstraint(type, labelName, propName, config)` | Create NOT NULL |
| `dropNotNullConstraint(type, labelName, propName, config)` | Drop NOT NULL |
| `createUniqueConstraint(type, labelName, ...propNames)` | Create UNIQUE |
| `dropUniqueConstraint(type, labelName, ...propNames)` | Drop UNIQUE |

## Managing Constraints

```typescript
import { DBType } from '@ultipa-graph/ultipa-driver';

await client.createNotNullConstraint(DBType.NODE, 'Person', 'name');
await client.createUniqueConstraint(DBType.NODE, 'Person', 'email');
await client.dropNotNullConstraint(DBType.NODE, 'Person', 'name');
await client.dropUniqueConstraint(DBType.NODE, 'Person', 'email');
```

## Index Methods

| Method | Description |
|--------|-------------|
| `showIndex(config)` | List all indexes |
| `showNodeIndex(config)` | List node indexes |
| `showEdgeIndex(config)` | List edge indexes |
| `createNodeIndex(indexName, labelName, props, config)` | Create a node index |
| `createEdgeIndex(indexName, labelName, props, config)` | Create an edge index |
| `dropNodeIndex(indexName, config)` | Drop a node index |
| `dropEdgeIndex(indexName, config)` | Drop an edge index |

## Managing Indexes

```typescript
// Show
const indexes = await client.showIndex();
for (const idx of indexes) {
  console.log(`${idx.indexName} on ${idx.label}.${idx.property} (${idx.status})`);
}

// Create
await client.createNodeIndex('idx_name', 'Person', [{ name: 'name' }]);

// With prefix length
await client.createNodeIndex('idx_prefix', 'Person', [{ name: 'name', prefixLength: 10 }]);

// Drop
await client.dropNodeIndex('idx_name');
```

## Fulltext Index Methods

| Method | Description |
|--------|-------------|
| `showFulltext(config)` | List all fulltext indexes |
| `createNodeFulltext(indexName, labelName, props, config)` | Create node fulltext |
| `createEdgeFulltext(indexName, labelName, props, config)` | Create edge fulltext |
| `dropNodeFulltext(indexName, config)` | Drop node fulltext |
| `dropEdgeFulltext(indexName, config)` | Drop edge fulltext |

## Managing Fulltext Indexes

```typescript
// Show
const fts = await client.showFulltext();
for (const ft of fts) {
  console.log(`${ft.indexName} on ${ft.schemaName} (${ft.status})`);
}

// Create
await client.createNodeFulltext('ft_name', 'Person', ['name']);

// Drop
await client.dropNodeFulltext('ft_name');
```

## Per-call Configuration

All methods accept an optional `QueryConfig` for per-call graph targeting:

```typescript
const labels = await client.showNodeLabels({ graphName: 'graphA' });
```

## Special Character Handling

Label and property names with special characters (spaces, hyphens, dots) are automatically wrapped in backticks by the SDK.

> **Note:** Graph names, index names, and fulltext index names do **not** support special characters.
