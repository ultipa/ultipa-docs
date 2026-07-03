# Data Operations

The GQLDB Node.js driver provides methods for inserting and deleting nodes and edges programmatically, without writing GQL queries.

## Data Operation Methods

`insertNodes` and `insertEdges` are **overloaded** — TypeScript has overload signatures and the runtime dispatches by `typeof arg1`:

| Call shape | Backed by | Returns |
|---|---|---|
| `insertNodes(graphName, nodes, config?)` | gRPC `InsertNodes` RPC (high-throughput) | `Promise<InsertNodesResult>` |
| `insertNodes(nodes, config?)` | GQL `INSERT` statement (convenience) | `Promise<Response>` |

`insertNodesBatchAuto` / `insertEdgesBatchAuto` are alternate names for the gRPC path and continue to work (not deprecated).

| Method | Description |
|--------|-------------|
| `insertNodes(graphName, nodes, config?)` | Insert nodes via gRPC (high-throughput) |
| `insertNodes(nodes, config?)` | Insert nodes via GQL INSERT statement |
| `insertNodesBatchAuto(graphName, nodes, config?)` | Alias for `insertNodes(graphName, …)` |
| `insertEdges(graphName, edges, config?)` | Insert edges via gRPC (high-throughput) |
| `insertEdges(edges, config?)` | Insert edges via GQL INSERT statement |
| `insertEdgesBatchAuto(graphName, edges, config?)` | Alias for `insertEdges(graphName, …)` |
| `deleteNodesByIds(nodeIds, config?)` | Delete nodes by `_id` list |
| `deleteNodesByCondition(labels, where, limit?, config?)` | Delete nodes by labels and/or `WHERE` condition |
| `deleteEdgesByIds(edgeIds, config?)` | Delete edges by `_id` list |
| `deleteEdgesByCondition(label, where, limit?, config?)` | Delete edges by label and/or `WHERE` condition |

### Choosing a path

| | gRPC path (`insertNodes(graphName, …)`) | GQL path (`insertNodes(nodes, …)`) |
|---|---|---|
| Backed by | gRPC `InsertNodes` RPC | GQL `INSERT` statement |
| Bulk session | Required for high throughput (`startBulkImport`) | Not required |
| Performance | High-throughput for large imports | Good for small batches |
| Custom node `_id` | Supported (`NodeData.id`) | Supported (`NodeData.id` → `_id`) |
| Custom edge `_id` | Supported (`EdgeData.id`) | Supported (`EdgeData.id` → `_id`) |
| Insert modes | Normal, Overwrite | Normal, Overwrite, Upsert |
| Use case | ETL, data migration, bulk loading | Scripts, small batches, Upsert |

> **Custom edge `_id` requires `WITH EDGE_ID` on the target graph.** This is a server-side prerequisite — the graph must have been created with `CREATE GRAPH <name> WITH EDGE_ID` for user-supplied edge `_id`s to be honored on either path. Without it, the server auto-generates edge `_id`s and any value passed via `EdgeData.id` is ignored.

## Inserting Nodes (gRPC Batch)

### insertNodesBatchAuto()

Insert one or more nodes into a graph:

```typescript
import { GqldbClient, NodeData, InsertNodesResult } from '@ultipa-graph/ultipa-driver';

async function insertNodesExample(client: GqldbClient) {
  const nodes: NodeData[] = [
    {
      id: 'user1',
      labels: ['User'],
      properties: {
        name: 'Alice',
        age: 30,
        email: 'alice@example.com'
      }
    },
    {
      id: 'user2',
      labels: ['User'],
      properties: {
        name: 'Bob',
        age: 25
      }
    },
    {
      id: 'user3',
      labels: ['User', 'Admin'],  // Multiple labels
      properties: {
        name: 'Charlie',
        role: 'administrator'
      }
    }
  ];

  const result: InsertNodesResult = await client.insertNodes('myGraph', nodes);

  console.log('Success:', result.success);
  console.log('Node count:', result.nodeCount);
  console.log('Node IDs:', result.nodeIds);
  console.log('Message:', result.message);
}
```

### NodeData Interface

```typescript
interface NodeData {
  id?: string;                       // Optional custom node _id (auto-generated when empty)
  labels: string[];                  // One or more labels
  properties: Record<string, any>;   // Node properties
}
```

A non-empty `id` is written as `_id` on the inserted node (both gRPC and GQL paths).

### InsertNodesResult Interface

```typescript
interface InsertNodesResult {
  success: boolean;
  nodeIds: string[];
  nodeCount: number;
  message: string;
}
```

### Insert Options

Control node insertion behavior with `InsertNodesConfig`:

```typescript
import { BulkCreateNodesOptions } from '@ultipa-graph/ultipa-driver';

async function insertWithOptions(client: GqldbClient) {
  const nodes: NodeData[] = [
    { id: 'user1', labels: ['User'], properties: { name: 'Alice' } }
  ];

  // Overwrite existing nodes with same ID
  const result = await client.insertNodes('myGraph', nodes, {
    options: {
      overwrite: true
    }
  });
}
```

### Insert with Bulk Import Session

For high-throughput inserts, use bulk import:

```typescript
async function insertWithBulkImport(client: GqldbClient) {
  // Start bulk import session
  const session = await client.startBulkImport('myGraph');

  try {
    // Insert nodes using the session
    const result = await client.insertNodes('myGraph', nodes, {
      bulkImportSessionId: session.sessionId
    });

    // End the session
    await client.endBulkImport(session.sessionId);
  } catch (error) {
    await client.abortBulkImport(session.sessionId);
    throw error;
  }
}
```

## Inserting Edges

### insertEdges()

Insert one or more edges into a graph:

```typescript
import { GqldbClient, EdgeData, InsertEdgesResult } from '@ultipa-graph/ultipa-driver';

async function insertEdgesExample(client: GqldbClient) {
  const edges: EdgeData[] = [
    {
      id: 'e1',
      label: 'Follows',
      fromNodeId: 'user1',
      toNodeId: 'user2',
      properties: {
        since: '2024-01-15'
      }
    },
    {
      id: 'e2',
      label: 'Follows',
      fromNodeId: 'user2',
      toNodeId: 'user3',
      properties: {}
    },
    {
      id: 'e3',
      label: 'Knows',
      fromNodeId: 'user1',
      toNodeId: 'user3',
      properties: {
        strength: 0.8
      }
    }
  ];

  const result: InsertEdgesResult = await client.insertEdges('myGraph', edges);

  console.log('Success:', result.success);
  console.log('Edge count:', result.edgeCount);
  console.log('Edge IDs:', result.edgeIds);
  console.log('Skipped:', result.skippedCount);
  console.log('Message:', result.message);
}
```

### EdgeData Interface

```typescript
interface EdgeData {
  id?: string;                       // Optional custom edge _id (requires WITH EDGE_ID graph)
  label: string;                     // Edge label/type
  fromNodeId: string;                // Source node ID
  toNodeId: string;                  // Target node ID
  properties: Record<string, any>;   // Edge properties
}
```

A non-empty `id` is written as `_id` on the inserted edge (both gRPC and GQL paths). The target graph must have been created with `WITH EDGE_ID` for the server to honor user-supplied edge `_id`s.

### InsertEdgesResult Interface

```typescript
interface InsertEdgesResult {
  success: boolean;
  edgeIds: string[];
  edgeCount: number;
  message: string;
  skippedCount: number;  // Edges skipped due to missing nodes
}
```

### Edge Insert Options

```typescript
import { BulkCreateEdgesOptions } from '@ultipa-graph/ultipa-driver';

async function insertEdgesWithOptions(client: GqldbClient) {
  const edges: EdgeData[] = [
    { id: 'e1', label: 'Follows', fromNodeId: 'user1', toNodeId: 'user999', properties: {} }
  ];

  // Skip edges where source or target node doesn't exist
  const result = await client.insertEdges('myGraph', edges, {
    options: {
      skipInvalidNodes: true
    }
  });

  console.log('Inserted:', result.edgeCount);
  console.log('Skipped:', result.skippedCount);
}
```

## GQL-based Insert (Convenience)

### insertNodes() / insertEdges()

These convenience methods generate and execute GQL `INSERT` statements. They don't require a bulk import session and use the session's current graph:

```typescript
await client.useGraph('myGraph');

const nodes = [
  { labels: ['Person'], properties: { name: 'Alice', age: 30 } },
  { labels: ['Person'], properties: { name: 'Bob', age: 25 } },
  // Custom _id via the id field
  { id: 'p3', labels: ['Person'], properties: { name: 'Charlie' } },
];
await client.insertNodes(nodes);

const edges = [
  { label: 'Knows', fromNodeId: 'id1', toNodeId: 'id2', properties: { since: 2024 } },
  // Custom _id (requires graph created WITH EDGE_ID)
  { id: 'tx-001', label: 'Knows', fromNodeId: 'id1', toNodeId: 'id3', properties: { since: 2025 } },
];
await client.insertEdges(edges);
```

> GQL `INSERT` only supports a single label per node; if `NodeData.labels` has multiple entries, only the first is used in the GQL path. Use the gRPC path for multi-label nodes.

## Per-call Configuration (InsertConfig)

The GQL-path `insertNodes(nodes, …)` / `insertEdges(edges, …)` accept an optional `InsertConfig` for per-call graph routing and insert mode:

```typescript
import { InsertConfig, InsertType } from '@ultipa-graph/ultipa-driver';

// Target a specific graph without useGraph()
const cfg: InsertConfig = {
  graphName: 'myGraph',
  insertType: InsertType.Overwrite,  // Normal (default), Overwrite, or Upsert
  timeout: 60,                       // optional per-call timeout (seconds)
};
await client.insertNodes(nodes, cfg);
await client.insertEdges(edges, cfg);
```

### InsertType semantics

| Value | Emitted GQL | On duplicate `_id` |
|---|---|---|
| `InsertType.Normal` (default) | `INSERT` | Error |
| `InsertType.Overwrite` | `INSERT OVERWRITE` | Replaces the entity wholesale — properties not in the write are **lost** |
| `InsertType.Upsert` | `UPSERT` | Merges properties — properties not in the write are **preserved** |

`Overwrite` and `Upsert` are different semantics on existing rows; they are not interchangeable.

All other convenience methods accept `QueryConfig` the same way:

```typescript
import { QueryConfig } from '@ultipa-graph/ultipa-driver';

await client.showNodeLabels({ graphName: 'graphA' });
await client.createNodeLabel('User', props, { graphName: 'graphB' });
await client.gql('MATCH (n) RETURN n', { graphName: 'graphC', timeout: 10 });
```

## Deleting Nodes

There are two delete-node methods. Both are async and resolve to a `Response`; the number of nodes removed is on `response.rowsAffected`. Deletes are always `DETACH DELETE` (attached edges are removed too). The target graph is selected via the optional `config` object (`DeleteConfig`), not a positional argument.

### deleteNodesByIds()

Delete nodes by their `_id` values:

```typescript
import { GqldbClient } from '@ultipa-graph/ultipa-driver';

async function deleteNodesByIdsExample(client: GqldbClient) {
  const response = await client.deleteNodesByIds(
    ['user1', 'user2'],
    { graphName: 'myGraph' }
  );
  console.log(`Deleted ${response.rowsAffected} nodes`);
}
```

An empty `nodeIds` array short-circuits and contacts no server (0 rows affected).

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `nodeIds` | `string[]` | `_id` values of the nodes to delete |
| `config` | `DeleteConfig` | Optional per-call config (`graphName`, `returnDeleted`, `allowDeleteAll`, `timeout`, …) |

### deleteNodesByCondition()

Delete nodes by labels and/or a `WHERE` condition, with an optional `limit`:

```typescript
async function deleteNodesByConditionExample(client: GqldbClient) {
  // Delete nodes by label
  const response1 = await client.deleteNodesByCondition(
    ['TempUser'],
    undefined,
    undefined,
    { graphName: 'myGraph' }
  );
  console.log(`Deleted ${response1.rowsAffected} TempUser nodes`);

  // Delete nodes matching a condition (at most 100)
  const response2 = await client.deleteNodesByCondition(
    ['User'],
    'n.age < 18',   // WHERE clause; the node is bound as `n`
    100,            // optional LIMIT
    { graphName: 'myGraph' }
  );
  console.log(`Deleted ${response2.rowsAffected} underage users`);
}
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `labels` | `string[]` | Delete nodes carrying any of these labels |
| `where` | `string` | `WHERE` condition; the matched node is bound as `n` |
| `limit` | `number` | Optional cap on the number of nodes deleted |
| `config` | `DeleteConfig` | Optional per-call config (`graphName`, `returnDeleted`, `allowDeleteAll`, `timeout`, …) |

> Calling `deleteNodesByCondition` with **both** `labels` and `where` empty would delete every node in the graph, so it throws unless you set `allowDeleteAll: true` in the config.

### DeleteConfig

```typescript
interface DeleteConfig extends QueryConfig {
  returnDeleted?: boolean;   // default true — emit RETURN so the response carries the deleted data
  allowDeleteAll?: boolean;  // default false — safety latch for graph-wide deletes
  // plus QueryConfig fields: graphName, parameters, timeout, ...
}
```

Set `returnDeleted: false` on large bulk deletes to skip returning the deleted rows and save bandwidth; `rowsAffected` still carries the count. When `returnDeleted` is left at its default, the deleted nodes are also available via `response.alias('n').asNodes()`.

## Deleting Edges

Edge deletion mirrors node deletion: both methods are async, resolve to a `Response`, and report the count on `response.rowsAffected`. Deleting edges by `_id` requires the graph to have `EDGE_ID` enabled (`ALTER GRAPH <name> SET EDGE_ID ENABLED`).

### deleteEdgesByIds()

Delete edges by their `_id` values:

```typescript
async function deleteEdgesByIdsExample(client: GqldbClient) {
  const response = await client.deleteEdgesByIds(
    ['e1', 'e2'],
    { graphName: 'myGraph' }
  );
  console.log(`Deleted ${response.rowsAffected} edges`);
}
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `edgeIds` | `string[]` | `_id` values of the edges to delete |
| `config` | `DeleteConfig` | Optional per-call config (`graphName`, `returnDeleted`, `allowDeleteAll`, `timeout`, …) |

### deleteEdgesByCondition()

Delete edges by label and/or a `WHERE` condition, with an optional `limit`. Note this takes a single `label` (string), not an array:

```typescript
async function deleteEdgesByConditionExample(client: GqldbClient) {
  // Delete edges by label
  const response1 = await client.deleteEdgesByCondition(
    'TempRelation',
    undefined,
    undefined,
    { graphName: 'myGraph' }
  );
  console.log(`Deleted ${response1.rowsAffected} TempRelation edges`);

  // Delete edges matching a condition
  const response2 = await client.deleteEdgesByCondition(
    'Follows',
    'e.since < "2020-01-01"',  // WHERE clause; the edge is bound as `e`
    undefined,
    { graphName: 'myGraph' }
  );
  console.log(`Deleted ${response2.rowsAffected} old follow relationships`);
}
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `label` | `string` | Delete edges with this label |
| `where` | `string` | `WHERE` condition; the matched edge is bound as `e` |
| `limit` | `number` | Optional cap on the number of edges deleted |
| `config` | `DeleteConfig` | Optional per-call config (`graphName`, `returnDeleted`, `allowDeleteAll`, `timeout`, …) |

> As with nodes, calling `deleteEdgesByCondition` with **both** `label` and `where` empty throws unless `allowDeleteAll: true` is set. When `returnDeleted` is left at its default, deleted edges are available via `response.alias('e').asEdges()`.

## Error Handling

```typescript
import {
  InsertFailedError,
  DeleteFailedError,
  GraphNotFoundError
} from '@ultipa-graph/ultipa-driver';

async function safeDataOperations(client: GqldbClient) {
  try {
    await client.insertNodes('myGraph', nodes);
  } catch (error) {
    if (error instanceof InsertFailedError) {
      console.error('Insert failed:', error.message);
    } else if (error instanceof GraphNotFoundError) {
      console.error('Graph does not exist');
    } else {
      throw error;
    }
  }

  try {
    await client.deleteNodesByIds(['node1'], { graphName: 'myGraph' });
  } catch (error) {
    if (error instanceof DeleteFailedError) {
      console.error('Delete failed:', error.message);
    }
  }
}
```

## Complete Example

```typescript
import { GqldbClient, createConfig, NodeData, EdgeData } from '@ultipa-graph/ultipa-driver';

async function main() {
  const client = new GqldbClient(createConfig({
    hosts: ['localhost:9000']
  }));

  try {
    await client.login('admin', 'password');

    // Create test graph
    await client.createGraph('dataOpsDemo');

    // Insert users
    const users: NodeData[] = [
      { id: 'alice', labels: ['User'], properties: { name: 'Alice', age: 30 } },
      { id: 'bob', labels: ['User'], properties: { name: 'Bob', age: 25 } },
      { id: 'charlie', labels: ['User'], properties: { name: 'Charlie', age: 35 } },
      { id: 'temp1', labels: ['TempUser'], properties: { name: 'Temp1' } },
      { id: 'temp2', labels: ['TempUser'], properties: { name: 'Temp2' } }
    ];

    const nodeResult = await client.insertNodes('dataOpsDemo', users);
    console.log(`Inserted ${nodeResult.nodeCount} users`);

    // Insert relationships
    const relationships: EdgeData[] = [
      { id: 'r1', label: 'Follows', fromNodeId: 'alice', toNodeId: 'bob', properties: {} },
      { id: 'r2', label: 'Follows', fromNodeId: 'bob', toNodeId: 'charlie', properties: {} },
      { id: 'r3', label: 'Knows', fromNodeId: 'alice', toNodeId: 'charlie', properties: { years: 5 } }
    ];

    const edgeResult = await client.insertEdges('dataOpsDemo', relationships);
    console.log(`Inserted ${edgeResult.edgeCount} relationships`);

    // Delete temporary users
    const deleteResponse = await client.deleteNodesByCondition(
      ['TempUser'],
      undefined,
      undefined,
      { graphName: 'dataOpsDemo' }
    );
    console.log(`Deleted ${deleteResponse.rowsAffected} temporary users`);

    // Verify remaining data
    await client.useGraph('dataOpsDemo');
    const countResponse = await client.gql('MATCH (n) RETURN count(n)');
    console.log(`Remaining nodes: ${countResponse.singleNumber()}`);

    // Clean up
    await client.dropGraph('dataOpsDemo');

  } finally {
    await client.close();
  }
}

main().catch(console.error);
```
