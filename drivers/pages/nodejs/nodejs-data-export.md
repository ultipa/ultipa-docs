# Data Export

The GQLDB Node.js driver provides streaming export capabilities for efficiently extracting large amounts of data from the database.

## Export Methods

| Method | Description |
|--------|-------------|
| `export()` | Export graph data in JSON Lines format (recommended) |
| `exportNodes()` | Stream nodes from a graph (deprecated) |
| `exportEdges()` | Stream edges from a graph (deprecated) |

## Unified Export

### export()

Export nodes and/or edges in JSON Lines format with streaming:

```typescript
import { GqldbClient, ExportConfig, ExportChunk } from 'gqldb-nodejs';

async function exportExample(client: GqldbClient) {
  const config: ExportConfig = {
    graphName: 'myGraph',
    batchSize: 1000,
    exportNodes: true,
    exportEdges: true
  };

  await client.export(config, (chunk: ExportChunk) => {
    // Process each chunk of data
    const lines = chunk.data.toString('utf-8').split('\n').filter(l => l);

    for (const line of lines) {
      const record = JSON.parse(line);
      console.log(record);
    }

    if (chunk.isFinal && chunk.stats) {
      console.log('Export complete:');
      console.log(`  Nodes: ${chunk.stats.nodesExported}`);
      console.log(`  Edges: ${chunk.stats.edgesExported}`);
      console.log(`  Bytes: ${chunk.stats.bytesWritten}`);
      console.log(`  Duration: ${chunk.stats.durationMs}ms`);
    }
  });
}
```

### ExportConfig Interface

```typescript
interface ExportConfig {
  graphName: string;          // Target graph
  batchSize?: number;         // Records per chunk
  exportNodes?: boolean;      // Include nodes (default: true)
  exportEdges?: boolean;      // Include edges (default: true)
  nodeLabels?: string[];      // Filter by node labels
  edgeLabels?: string[];      // Filter by edge labels
  includeMetadata?: boolean;  // Include metadata in output
}
```

### ExportChunk Interface

```typescript
interface ExportChunk {
  data: Buffer;           // JSON Lines data
  isFinal: boolean;       // Is this the last chunk?
  stats?: ExportStats;    // Statistics (on final chunk)
}
```

### ExportStats Interface

```typescript
interface ExportStats {
  nodesExported: number;
  edgesExported: number;
  bytesWritten: number;
  durationMs: number;
}
```

## Filtering Exports

### Export Specific Labels

```typescript
async function exportFilteredExample(client: GqldbClient) {
  // Export only User nodes and Follows edges
  await client.export(
    {
      graphName: 'socialGraph',
      exportNodes: true,
      exportEdges: true,
      nodeLabels: ['User', 'Company'],
      edgeLabels: ['Follows', 'WorksAt']
    },
    (chunk) => {
      // Process filtered data
    }
  );
}
```

### Export Only Nodes

```typescript
async function exportNodesOnlyExample(client: GqldbClient) {
  await client.export(
    {
      graphName: 'myGraph',
      exportNodes: true,
      exportEdges: false
    },
    (chunk) => {
      // Only nodes in the output
    }
  );
}
```

### Export Only Edges

```typescript
async function exportEdgesOnlyExample(client: GqldbClient) {
  await client.export(
    {
      graphName: 'myGraph',
      exportNodes: false,
      exportEdges: true
    },
    (chunk) => {
      // Only edges in the output
    }
  );
}
```

## Writing to File

```typescript
import * as fs from 'fs';

async function exportToFile(client: GqldbClient) {
  const writeStream = fs.createWriteStream('export.jsonl');

  await client.export(
    {
      graphName: 'myGraph',
      batchSize: 5000
    },
    (chunk) => {
      writeStream.write(chunk.data);

      if (chunk.isFinal) {
        writeStream.end();
        console.log('Export written to export.jsonl');
      }
    }
  );
}
```

## Collecting All Data

```typescript
async function exportToArray(client: GqldbClient) {
  const nodes: any[] = [];
  const edges: any[] = [];

  await client.export(
    {
      graphName: 'myGraph',
      batchSize: 1000
    },
    (chunk) => {
      const lines = chunk.data.toString('utf-8').split('\n').filter(l => l);

      for (const line of lines) {
        const record = JSON.parse(line);
        if (record._type === 'node') {
          nodes.push(record);
        } else if (record._type === 'edge') {
          edges.push(record);
        }
      }
    }
  );

  console.log(`Collected ${nodes.length} nodes and ${edges.length} edges`);
  return { nodes, edges };
}
```

## Legacy Export Methods (Deprecated)

### exportNodes()

Stream nodes from a graph:

```typescript
import { ExportNodesResult } from 'gqldb-nodejs';

async function legacyExportNodes(client: GqldbClient) {
  await client.exportNodes(
    'myGraph',
    ['User'],      // Optional: filter by labels
    1000,          // Limit (0 = no limit)
    (result: ExportNodesResult) => {
      for (const node of result.nodes) {
        console.log(`Node: ${node.id}, Labels: ${node.labels}`);
        console.log('Properties:', node.properties);
      }

      if (!result.hasMore) {
        console.log('Export complete');
      }
    }
  );
}
```

### exportEdges()

Stream edges from a graph:

```typescript
import { ExportEdgesResult } from 'gqldb-nodejs';

async function legacyExportEdges(client: GqldbClient) {
  await client.exportEdges(
    'myGraph',
    ['Follows'],   // Optional: filter by labels
    1000,          // Limit (0 = no limit)
    (result: ExportEdgesResult) => {
      for (const edge of result.edges) {
        console.log(`Edge: ${edge.id}, ${edge.fromNodeId} -[${edge.label}]-> ${edge.toNodeId}`);
        console.log('Properties:', edge.properties);
      }

      if (!result.hasMore) {
        console.log('Export complete');
      }
    }
  );
}
```

### Deprecated Interfaces

```typescript
// @deprecated - Use export() instead
interface ExportNodesResult {
  nodes: ExportedNode[];
  hasMore: boolean;
}

// @deprecated - Use export() instead
interface ExportEdgesResult {
  edges: ExportedEdge[];
  hasMore: boolean;
}

interface ExportedNode {
  id: string;
  labels: string[];
  properties: Record<string, any>;
}

interface ExportedEdge {
  id: string;
  label: string;
  fromNodeId: string;
  toNodeId: string;
  properties: Record<string, any>;
}
```

## Error Handling

```typescript
import { ExportFailedError, GraphNotFoundError } from 'gqldb-nodejs';

async function safeExport(client: GqldbClient) {
  try {
    await client.export(
      { graphName: 'myGraph' },
      (chunk) => { /* process */ }
    );
  } catch (error) {
    if (error instanceof ExportFailedError) {
      console.error('Export failed:', error.message);
    } else if (error instanceof GraphNotFoundError) {
      console.error('Graph not found');
    } else {
      throw error;
    }
  }
}
```

## Complete Example

```typescript
import { GqldbClient, createConfig } from 'gqldb-nodejs';
import * as fs from 'fs';

async function main() {
  const client = new GqldbClient(createConfig({
    hosts: ['192.168.1.100:9000']
  }));

  try {
    await client.login('admin', 'password');

    // Create and populate a test graph
    await client.createGraph('exportDemo');
    await client.useGraph('exportDemo');

    // Insert test data
    await client.gql(`
      INSERT
        (a:User {_id: 'u1', name: 'Alice', age: 30}),
        (b:User {_id: 'u2', name: 'Bob', age: 25}),
        (c:Company {_id: 'c1', name: 'Acme Inc'}),
        (a)-[:Follows {since: '2023-01-01'}]->(b),
        (a)-[:WorksAt {role: 'Engineer'}]->(c)
    `);

    console.log('Exporting to file...');

    // Export to JSON Lines file
    const outputPath = 'graph-export.jsonl';
    const writeStream = fs.createWriteStream(outputPath);
    let totalRecords = 0;

    await client.export(
      {
        graphName: 'exportDemo',
        batchSize: 100,
        exportNodes: true,
        exportEdges: true,
        includeMetadata: true
      },
      (chunk) => {
        writeStream.write(chunk.data);

        // Count records
        const lines = chunk.data.toString('utf-8').split('\n').filter(l => l);
        totalRecords += lines.length;

        if (chunk.isFinal) {
          writeStream.end();
          console.log(`\nExport complete!`);
          console.log(`  File: ${outputPath}`);
          console.log(`  Records: ${totalRecords}`);
          if (chunk.stats) {
            console.log(`  Nodes: ${chunk.stats.nodesExported}`);
            console.log(`  Edges: ${chunk.stats.edgesExported}`);
            console.log(`  Size: ${chunk.stats.bytesWritten} bytes`);
            console.log(`  Duration: ${chunk.stats.durationMs}ms`);
          }
        }
      }
    );

    // Read and display the file
    console.log('\nExported data:');
    const content = fs.readFileSync(outputPath, 'utf-8');
    for (const line of content.split('\n').filter(l => l)) {
      console.log(JSON.parse(line));
    }

    // Clean up
    fs.unlinkSync(outputPath);
    await client.dropGraph('exportDemo');

  } finally {
    await client.close();
  }
}

main().catch(console.error);
```
