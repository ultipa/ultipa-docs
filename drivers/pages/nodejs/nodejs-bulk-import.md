# Bulk Import

The GQLDB Node.js driver provides a bulk import service for high-throughput data ingestion. Bulk import optimizes performance by batching operations and reducing overhead.

## Bulk Import Methods

| Method | Description |
|--------|-------------|
| `startBulkImport()` | Start a bulk import session |
| `endBulkImport()` | End the session with a final checkpoint |
| `abortBulkImport()` | Cancel the session without saving |
| `getBulkImportStatus()` | Get the current status of a session |

## Starting a Bulk Import Session

### startBulkImport()

Initialize a bulk import session for a graph:

```typescript
import { GqldbClient, BulkImportSession, BulkImportOptions } from '@ultipa-graph/ultipa-driver';

async function startBulkImportExample(client: GqldbClient) {
  // Basic start
  const session: BulkImportSession = await client.startBulkImport('myGraph');
  console.log('Session ID:', session.sessionId);
  console.log('Success:', session.success);

  // Start with options
  const options: BulkImportOptions = {
    estimatedNodes: 1000000,   // Hint for pre-allocating node ID cache
    estimatedEdges: 5000000    // Hint for edge batch sizing
  };

  const optimizedSession = await client.startBulkImport('myGraph', options);
}
```

### BulkImportOptions Interface

```typescript
interface BulkImportOptions {
  estimatedNodes?: number;    // Hint for pre-allocating node ID cache
  estimatedEdges?: number;    // Hint for edge batch sizing
}
```

### BulkImportSession Interface

```typescript
interface BulkImportSession {
  success: boolean;
  sessionId: string;
  message: string;
}
```

## Inserting Data During Bulk Import

Use the session ID with `insertNodes()` and `insertEdges()`:

```typescript
async function bulkInsertExample(client: GqldbClient) {
  const session = await client.startBulkImport('myGraph', {
    checkpointEvery: 50000
  });

  try {
    // Insert nodes in batches
    for (let batch = 0; batch < 100; batch++) {
      const nodes = generateNodeBatch(batch, 1000);  // 1000 nodes per batch

      await client.insertNodes('myGraph', nodes, {
        bulkImportSessionId: session.sessionId
      });
    }

    // Insert edges in batches
    for (let batch = 0; batch < 100; batch++) {
      const edges = generateEdgeBatch(batch, 5000);  // 5000 edges per batch

      await client.insertEdges('myGraph', edges, {
        bulkImportSessionId: session.sessionId
      });
    }

    // End with final checkpoint
    const result = await client.endBulkImport(session.sessionId);
    console.log(`Imported ${result.totalRecords} records`);

  } catch (error) {
    // Abort on error
    await client.abortBulkImport(session.sessionId);
    throw error;
  }
}
```

## Ending a Bulk Import

### endBulkImport()

Complete the session with a final checkpoint:

```typescript
import { EndBulkImportResult } from '@ultipa-graph/ultipa-driver';

async function endBulkImportExample(client: GqldbClient) {
  const session = await client.startBulkImport('myGraph');

  // ... insert data ...

  const result: EndBulkImportResult = await client.endBulkImport(session.sessionId);

  console.log('Success:', result.success);
  console.log('Total records:', result.totalRecords);
  console.log('Message:', result.message);
}
```

### EndBulkImportResult Interface

```typescript
interface EndBulkImportResult {
  success: boolean;
  totalRecords: number;
  message: string;
}
```

## Aborting a Bulk Import

### abortBulkImport()

Cancel a session without saving uncommitted data:

```typescript
import { AbortBulkImportResult } from '@ultipa-graph/ultipa-driver';

async function abortBulkImportExample(client: GqldbClient) {
  const session = await client.startBulkImport('myGraph');

  try {
    // ... insert data ...

    if (someErrorCondition) {
      const result: AbortBulkImportResult = await client.abortBulkImport(session.sessionId);
      console.log('Abort success:', result.success);
      console.log('Message:', result.message);
      return;
    }

    await client.endBulkImport(session.sessionId);

  } catch (error) {
    await client.abortBulkImport(session.sessionId);
    throw error;
  }
}
```

### AbortBulkImportResult Interface

```typescript
interface AbortBulkImportResult {
  success: boolean;
  message: string;
}
```

## Checking Bulk Import Status

### getBulkImportStatus()

Get the current status of a bulk import session:

```typescript
import { BulkImportStatus } from '@ultipa-graph/ultipa-driver';

async function checkStatusExample(client: GqldbClient) {
  const session = await client.startBulkImport('myGraph');

  // ... insert some data ...

  const status: BulkImportStatus = await client.getBulkImportStatus(session.sessionId);

  console.log('Is active:', status.isActive);
  console.log('Graph name:', status.graphName);
  console.log('Record count:', status.recordCount);
  console.log('Last checkpoint count:', status.lastCheckpointCount);
  console.log('Created at:', new Date(status.createdAt));
  console.log('Last activity:', new Date(status.lastActivity));
}
```

### BulkImportStatus Interface

```typescript
interface BulkImportStatus {
  isActive: boolean;
  graphName: string;
  recordCount: number;
  lastCheckpointCount: number;
  createdAt: number;      // Timestamp in milliseconds
  lastActivity: number;   // Timestamp in milliseconds
}
```

## Best Practices

### Batch Size

Choose appropriate batch sizes for optimal performance:

```typescript
const OPTIMAL_BATCH_SIZE = 10000;  // Adjust based on your data

async function efficientBulkImport(client: GqldbClient, allNodes: NodeData[]) {
  const session = await client.startBulkImport('myGraph', {
    checkpointEvery: 100000
  });

  try {
    // Process in batches
    for (let i = 0; i < allNodes.length; i += OPTIMAL_BATCH_SIZE) {
      const batch = allNodes.slice(i, i + OPTIMAL_BATCH_SIZE);
      await client.insertNodes('myGraph', batch, {
        bulkImportSessionId: session.sessionId
      });

      // Progress logging
      if ((i + OPTIMAL_BATCH_SIZE) % 100000 === 0) {
        console.log(`Processed ${i + OPTIMAL_BATCH_SIZE} nodes`);
      }
    }

    await client.endBulkImport(session.sessionId);
  } catch (error) {
    await client.abortBulkImport(session.sessionId);
    throw error;
  }
}
```

### Error Recovery

Implement checkpoint-based recovery:

```typescript
async function robustBulkImport(client: GqldbClient, data: NodeData[][]) {
  const session = await client.startBulkImport('myGraph');
  let processedBatches = 0;

  try {
    for (const batch of data) {
      await client.insertNodes('myGraph', batch, {
        bulkImportSessionId: session.sessionId
      });

      processedBatches++;

      // Checkpoint every 10 batches for recovery
      if (processedBatches % 10 === 0) {
        await client.checkpoint(session.sessionId);
        console.log(`Checkpoint at batch ${processedBatches}`);
      }
    }

    await client.endBulkImport(session.sessionId);

  } catch (error) {
    console.error(`Error at batch ${processedBatches}:`, error.message);

    // Data up to last checkpoint is safe
    const status = await client.getBulkImportStatus(session.sessionId);
    console.log(`Saved records: ${status.recordCount - status.lastCheckpointCount}`);

    await client.abortBulkImport(session.sessionId);
    throw error;
  }
}
```

## Complete Example

```typescript
import { GqldbClient, createConfig, NodeData, EdgeData } from '@ultipa-graph/ultipa-driver';

async function main() {
  const client = new GqldbClient(createConfig({
    hosts: ['localhost:60061']
  }));

  try {
    await client.login('admin', 'password');

    // Create graph for bulk import
    await client.createGraph('bulkDemo');

    // Start bulk import session
    const session = await client.startBulkImport('bulkDemo', {
      checkpointEvery: 10000,
      estimatedNodes: 100000,
      estimatedEdges: 500000
    });

    console.log('Started bulk import session:', session.sessionId);

    // Generate and insert nodes
    for (let batch = 0; batch < 10; batch++) {
      const nodes: NodeData[] = [];
      for (let i = 0; i < 10000; i++) {
        const id = batch * 10000 + i;
        nodes.push({
          id: `user${id}`,
          labels: ['User'],
          properties: {
            name: `User ${id}`,
            index: id
          }
        });
      }

      await client.insertNodes('bulkDemo', nodes, {
        bulkImportSessionId: session.sessionId
      });

      console.log(`Inserted batch ${batch + 1}/10`);
    }

    // Check status
    const status = await client.getBulkImportStatus(session.sessionId);
    console.log('Current status:', status);

    // Manual checkpoint
    const checkpoint = await client.checkpoint(session.sessionId);
    console.log('Checkpoint:', checkpoint);

    // Generate and insert edges
    const edges: EdgeData[] = [];
    for (let i = 0; i < 50000; i++) {
      edges.push({
        id: `edge${i}`,
        label: 'Knows',
        fromNodeId: `user${i}`,
        toNodeId: `user${(i + 1) % 100000}`,
        properties: {}
      });
    }

    await client.insertEdges('bulkDemo', edges, {
      bulkImportSessionId: session.sessionId
    });

    // End bulk import
    const result = await client.endBulkImport(session.sessionId);
    console.log('Bulk import completed:', result);

    // Verify
    await client.useGraph('bulkDemo');
    const countResponse = await client.gql('MATCH (n) RETURN count(n)');
    console.log('Total nodes:', countResponse.singleNumber());

    // Clean up
    await client.dropGraph('bulkDemo');

  } finally {
    await client.close();
  }
}

main().catch(console.error);
```
