# Data Operations

The GQLDB Node.js driver provides methods for inserting and deleting nodes and edges programmatically, without writing GQL queries.

## Data Operation Methods

| Method | Description |
|--------|-------------|
| `insertNodes(nodes, config)` | Insert nodes via GQL INSERT statement |
| `insertNodesBatchAuto(graphName, nodes, config)` | Insert nodes via gRPC (high-throughput) |
| `insertEdges(edges, config)` | Insert edges via GQL INSERT statement |
| `insertEdgesBatchAuto(graphName, edges, config)` | Insert edges via gRPC (high-throughput) |
| `deleteNodes(graphName, nodeIds, labels, where)` | Delete nodes |
| `deleteEdges(graphName, edgeIds, label, where)` | Delete edges |

### insertNodes vs insertNodesBatchAuto

| | `insertNodes` | `insertNodesBatchAuto` |
|---|---|---|
| Method | GQL `INSERT` statement | gRPC `InsertNodes` RPC |
| Bulk session | Not required | Required (`startBulkImport`) |
| Performance | Good for small batches | High-throughput for large imports |
| Custom node ID | Not supported | Supported (`NodeData.id`) |
| Use case | Simple inserts, scripts | ETL, data migration, bulk loading |

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
  id?: string;                       // Optional node identifier
  labels: string[];                  // One or more labels
  properties: Record<string, any>;   // Node properties
}
```

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
  label: string;                     // Edge label/type
  fromNodeId: string;                // Source node ID
  toNodeId: string;                  // Target node ID
  properties: Record<string, any>;   // Edge properties
}
```

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
];
await client.insertNodes(nodes);

const edges = [
  { label: 'Knows', fromNodeId: 'id1', toNodeId: 'id2', properties: { since: 2024 } },
];
await client.insertEdges(edges);
```

## Per-call Configuration (InsertConfig)

`insertNodes()` and `insertEdges()` accept an optional `InsertConfig` for per-call graph routing and insert mode:

```typescript
import { InsertConfig, InsertType } from '@ultipa-graph/ultipa-driver';

// Target a specific graph without useGraph()
const cfg: InsertConfig = {
  graphName: 'myGraph',
  insertType: InsertType.OVERWRITE,  // NORMAL (default) or OVERWRITE
  timeout: 60,                       // optional per-call timeout (seconds)
};
await client.insertNodes(nodes, cfg);
await client.insertEdges(edges, cfg);
```

All other convenience methods accept `QueryConfig` the same way:

```typescript
import { QueryConfig } from '@ultipa-graph/ultipa-driver';

await client.showNodeLabels({ graphName: 'graphA' });
await client.createNodeLabel('User', props, { graphName: 'graphB' });
await client.gql('MATCH (n) RETURN n', { graphName: 'graphC', timeout: 10 });
```

## Deleting Nodes

### deleteNodes()

Delete nodes from a graph:

```typescript
import { GqldbClient, DeleteResult } from '@ultipa-graph/ultipa-driver';

async function deleteNodesExample(client: GqldbClient) {
  // Delete specific nodes by ID
  const result1 = await client.deleteNodes('myGraph', ['user1', 'user2']);
  console.log(`Deleted ${result1.deletedCount} nodes`);

  // Delete nodes by label
  const result2 = await client.deleteNodes('myGraph', undefined, ['TempUser']);
  console.log(`Deleted ${result2.deletedCount} TempUser nodes`);

  // Delete nodes matching a condition
  const result3 = await client.deleteNodes(
    'myGraph',
    undefined,
    ['User'],
    'age < 18'  // WHERE clause
  );
  console.log(`Deleted ${result3.deletedCount} underage users`);
}
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `graphName` | `string` | Target graph |
| `nodeIds` | `string[]` | Specific node IDs to delete |
| `labels` | `string[]` | Delete nodes with these labels |
| `where` | `string` | Additional filter condition |

### DeleteResult Interface

```typescript
interface DeleteResult {
  success: boolean;
  deletedCount: number;
  message: string;
}
```

## Deleting Edges

### deleteEdges()

Delete edges from a graph:

```typescript
async function deleteEdgesExample(client: GqldbClient) {
  // Delete specific edges by ID
  const result1 = await client.deleteEdges('myGraph', ['e1', 'e2']);
  console.log(`Deleted ${result1.deletedCount} edges`);

  // Delete edges by label
  const result2 = await client.deleteEdges('myGraph', undefined, 'TempRelation');
  console.log(`Deleted ${result2.deletedCount} TempRelation edges`);

  // Delete edges matching a condition
  const result3 = await client.deleteEdges(
    'myGraph',
    undefined,
    'Follows',
    'since < "2020-01-01"'
  );
  console.log(`Deleted ${result3.deletedCount} old follow relationships`);
}
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `graphName` | `string` | Target graph |
| `edgeIds` | `string[]` | Specific edge IDs to delete |
| `label` | `string` | Delete edges with this label |
| `where` | `string` | Additional filter condition |

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
    await client.deleteNodes('myGraph', ['node1']);
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
    const deleteResult = await client.deleteNodes('dataOpsDemo', undefined, ['TempUser']);
    console.log(`Deleted ${deleteResult.deletedCount} temporary users`);

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
