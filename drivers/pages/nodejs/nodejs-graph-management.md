# Graph Management

The GQLDB Node.js driver provides methods to create, delete, list, and manage graphs in the database.

## Graph Types

GQLDB supports three graph types defined in the `GraphType` enum:

```typescript
import { GraphType } from '@ultipa-graph/ultipa-driver';

GraphType.OPEN      // Schema-less graph (default)
GraphType.CLOSED    // Schema-enforced graph
GraphType.ONTOLOGY  // Ontology-enabled graph
```

| Type | Description |
|------|-------------|
| `OPEN` | Schema-less graph where any node/edge labels and properties are allowed |
| `CLOSED` | Schema-enforced graph where labels and properties must be predefined |
| `ONTOLOGY` | Graph with ontology support for semantic modeling |

## Creating Graphs

### createGraph()

Create a new graph in the database:

```typescript
import { GqldbClient, createConfig, GraphType } from '@ultipa-graph/ultipa-driver';

async function createGraphExample(client: GqldbClient) {
  // Create an open (schema-less) graph
  await client.createGraph('myGraph', GraphType.OPEN, 'My first graph');
  console.log('Graph created');

  // Create a closed (schema-enforced) graph
  await client.createGraph('strictGraph', GraphType.CLOSED, 'Schema-enforced graph');

  // Create with default type (OPEN) and no description
  await client.createGraph('simpleGraph');
}
```

**Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `name` | `string` | required | Name of the graph |
| `graphType` | `GraphType` | `GraphType.OPEN` | Type of the graph |
| `description` | `string` | `''` | Optional description |

## Deleting Graphs

### dropGraph()

Delete a graph from the database:

```typescript
async function dropGraphExample(client: GqldbClient) {
  // Drop a graph (throws error if not found)
  await client.dropGraph('myGraph');
  console.log('Graph dropped');

  // Drop if exists (no error if graph doesn't exist)
  await client.dropGraph('maybeGraph', true);
  console.log('Graph dropped if it existed');
}
```

**Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `name` | `string` | required | Name of the graph to delete |
| `ifExists` | `boolean` | `false` | If true, don't error if graph doesn't exist |

## Using a Graph

### useGraph()

Set the current graph for the session:

```typescript
async function useGraphExample(client: GqldbClient) {
  // Set the active graph
  await client.useGraph('myGraph');
  console.log('Now using myGraph');

  // Subsequent queries will target this graph by default
  const response = await client.gql('MATCH (n) RETURN count(n)');
  console.log('Node count:', response.singleNumber());
}
```

After calling `useGraph()`, all queries without an explicit `graphName` in their config will target this graph.

## Listing Graphs

### listGraphs()

Retrieve all graphs in the database:

```typescript
import { GraphInfo } from '@ultipa-graph/ultipa-driver';

async function listGraphsExample(client: GqldbClient) {
  const graphs: GraphInfo[] = await client.listGraphs();

  console.log(`Found ${graphs.length} graphs:`);
  for (const graph of graphs) {
    console.log(`- ${graph.name} (${graph.graphType}): ${graph.description}`);
    console.log(`  Nodes: ${graph.nodeCount}, Edges: ${graph.edgeCount}`);
  }
}
```

### GraphInfo Interface

```typescript
interface GraphInfo {
  name: string;
  graphType: GraphType;
  description: string;
  nodeCount: number;
  edgeCount: number;
}
```

## Getting Graph Information

### getGraphInfo()

Get detailed information about a specific graph:

```typescript
async function getGraphInfoExample(client: GqldbClient) {
  const info = await client.getGraphInfo('myGraph');

  console.log('Graph Name:', info.name);
  console.log('Type:', info.graphType);
  console.log('Description:', info.description);
  console.log('Node Count:', info.nodeCount);
  console.log('Edge Count:', info.edgeCount);
}
```

## Error Handling

```typescript
import {
  GraphNotFoundError,
  GraphExistsError,
  CreateGraphFailedError,
  DropGraphFailedError
} from '@ultipa-graph/ultipa-driver';

async function safeGraphOperations(client: GqldbClient) {
  try {
    // Try to create a graph
    await client.createGraph('newGraph');
  } catch (error) {
    if (error instanceof GraphExistsError) {
      console.log('Graph already exists');
    } else if (error instanceof CreateGraphFailedError) {
      console.error('Failed to create graph:', error.message);
    }
  }

  try {
    // Try to get graph info
    const info = await client.getGraphInfo('unknownGraph');
  } catch (error) {
    if (error instanceof GraphNotFoundError) {
      console.log('Graph not found');
    }
  }

  try {
    // Try to drop a graph
    await client.dropGraph('oldGraph');
  } catch (error) {
    if (error instanceof GraphNotFoundError) {
      console.log('Graph does not exist');
    } else if (error instanceof DropGraphFailedError) {
      console.error('Failed to drop graph:', error.message);
    }
  }
}
```

## Complete Example

```typescript
import { GqldbClient, createConfig, GraphType } from '@ultipa-graph/ultipa-driver';

async function main() {
  const client = new GqldbClient(createConfig({
    hosts: ['localhost:9000']
  }));

  try {
    await client.login('admin', 'password');

    // List existing graphs
    console.log('Existing graphs:');
    const existingGraphs = await client.listGraphs();
    for (const g of existingGraphs) {
      console.log(`  - ${g.name}`);
    }

    // Create a new graph
    const graphName = 'demoGraph';
    try {
      await client.createGraph(graphName, GraphType.OPEN, 'Demo graph for testing');
      console.log(`Created graph: ${graphName}`);
    } catch (error) {
      if (error.name === 'GraphExistsError') {
        console.log(`Graph ${graphName} already exists`);
      } else {
        throw error;
      }
    }

    // Use the graph
    await client.useGraph(graphName);

    // Get graph info
    const info = await client.getGraphInfo(graphName);
    console.log('Graph info:', info);

    // Insert some data
    await client.gql('INSERT (n:User {_id: "u1", name: "Alice"})');
    await client.gql('INSERT (n:User {_id: "u2", name: "Bob"})');

    // Check updated counts
    const updatedInfo = await client.getGraphInfo(graphName);
    console.log(`Graph now has ${updatedInfo.nodeCount} nodes`);

    // Clean up - drop the demo graph
    await client.dropGraph(graphName);
    console.log(`Dropped graph: ${graphName}`);

  } finally {
    await client.close();
  }
}

main().catch(console.error);
```
