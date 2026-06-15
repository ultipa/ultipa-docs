# Graph Management

The GQLDB Java driver provides methods to create, delete, list, and manage graphs in the database.

## Graph Methods

| Method | Description |
|--------|-------------|
| `createGraph(name, graphType, description)` | Create a new graph |
| `dropGraph(name, ifExists)` | Delete a graph |
| `useGraph(name)` | Set the current graph for the session |
| `listGraphs()` | List all available graphs |
| `getGraphInfo(name)` | Get information about a specific graph |
| `createOpenGraph(name)` | Create a schema-less graph |
| `createClosedGraph(name)` | Create a schema-enforced graph |
| `createGraphIfNotExist(name, graphType, description)` | Create graph only if it doesn't exist |
| `hasGraph(name)` | Check if a graph exists |
| `alterGraph(oldName, newName)` | Rename a graph |
| `truncate(graphName)` | Remove all data from a graph |

## Graph Types

GQLDB supports three graph types defined in the `GraphType` enum:

```java
import com.gqldb.types.GraphType;

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

```java
import com.gqldb.*;
import com.gqldb.types.GraphType;

public void createGraphExample(GqldbClient client) {
    // Create an open (schema-less) graph
    client.createGraph("myGraph", GraphType.OPEN, "My first graph");
    System.out.println("Graph created");

    // Create a closed (schema-enforced) graph
    client.createGraph("strictGraph", GraphType.CLOSED, "Schema-enforced graph");

    // Create with default type (OPEN) and no description
    client.createGraph("simpleGraph");
}
```

**Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `name` | `String` | required | Name of the graph |
| `graphType` | `GraphType` | `GraphType.OPEN` | Type of the graph |
| `description` | `String` | `""` | Optional description |

## Deleting Graphs

### dropGraph()

Delete a graph from the database:

```java
public void dropGraphExample(GqldbClient client) {
    // Drop a graph (throws exception if not found)
    client.dropGraph("myGraph");
    System.out.println("Graph dropped");

    // Drop if exists (no error if graph doesn't exist)
    client.dropGraph("maybeGraph", true);
    System.out.println("Graph dropped if it existed");
}
```

**Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `name` | `String` | required | Name of the graph to delete |
| `ifExists` | `boolean` | `false` | If true, don't error if graph doesn't exist |

## Using a Graph

### useGraph()

Set the current graph for the session:

```java
public void useGraphExample(GqldbClient client) {
    // Set the active graph
    client.useGraph("myGraph");
    System.out.println("Now using myGraph");

    // Subsequent queries will target this graph by default
    Response response = client.gql("MATCH (n) RETURN count(n)");
    System.out.println("Node count: " + response.singleLong());
}
```

## Listing Graphs

### listGraphs()

Retrieve all graphs in the database:

```java
import com.gqldb.GraphInfo;
import java.util.List;

public void listGraphsExample(GqldbClient client) {
    List<GraphInfo> graphs = client.listGraphs();

    System.out.println("Found " + graphs.size() + " graphs:");
    for (GraphInfo graph : graphs) {
        System.out.println("- " + graph.getName() + " (" + graph.getGraphType() + "): " +
            graph.getDescription());
        System.out.println("  Nodes: " + graph.getNodeCount() + ", Edges: " + graph.getEdgeCount());
    }
}
```

### GraphInfo Class

```java
public class GraphInfo {
    String getName();
    GraphType getGraphType();
    String getDescription();
    long getNodeCount();
    long getEdgeCount();
}
```

## Getting Graph Information

### getGraphInfo()

Get detailed information about a specific graph:

```java
public void getGraphInfoExample(GqldbClient client) {
    GraphInfo info = client.getGraphInfo("myGraph");

    System.out.println("Graph Name: " + info.getName());
    System.out.println("Type: " + info.getGraphType());
    System.out.println("Description: " + info.getDescription());
    System.out.println("Node Count: " + info.getNodeCount());
    System.out.println("Edge Count: " + info.getEdgeCount());
}
```

## Convenience Methods

### createOpenGraph() / createClosedGraph()

Shorthand methods for creating graphs with a specific type:

```java
// Create an open (schema-less) graph
client.createOpenGraph("flexGraph");

// Create a closed (schema-enforced) graph
client.createClosedGraph("strictGraph");

// With QueryConfig for targeting a specific graph context
client.createOpenGraph("flexGraph", new QueryConfig());
```

### createGraphIfNotExist()

Create a graph only if it doesn't already exist:

```java
// Returns true if created, false if already existed
boolean created = client.createGraphIfNotExist("myGraph", GraphType.OPEN, "My graph");

if (created) {
    System.out.println("Graph created");
} else {
    System.out.println("Graph already exists");
}
```

### hasGraph()

Check whether a graph exists:

```java
if (client.hasGraph("myGraph")) {
    System.out.println("Graph exists");
} else {
    System.out.println("Graph does not exist");
}
```

### alterGraph()

Rename a graph:

```java
client.alterGraph("oldName", "newName");
System.out.println("Graph renamed");

// With QueryConfig
client.alterGraph("oldName", "newName", new QueryConfig());
```

### truncate()

Remove all data from a graph while keeping the graph itself:

```java
client.truncate("myGraph");
System.out.println("All data removed from graph");

// With QueryConfig
client.truncate("myGraph", new QueryConfig());
```

## Exception Handling

```java
import com.gqldb.*;

public void safeGraphOperations(GqldbClient client) {
    try {
        // Try to create a graph
        client.createGraph("newGraph");
    } catch (GraphExistsException e) {
        System.out.println("Graph already exists");
    } catch (GqldbException e) {
        System.err.println("Failed to create graph: " + e.getMessage());
    }

    try {
        // Try to get graph info
        GraphInfo info = client.getGraphInfo("unknownGraph");
    } catch (GraphNotFoundException e) {
        System.out.println("Graph not found");
    }

    try {
        // Try to drop a graph
        client.dropGraph("oldGraph");
    } catch (GraphNotFoundException e) {
        System.out.println("Graph does not exist");
    } catch (GqldbException e) {
        System.err.println("Failed to drop graph: " + e.getMessage());
    }
}
```

## Complete Example

```java
import com.gqldb.*;
import com.gqldb.types.GraphType;
import java.util.List;

public class GraphManagementExample {
    public static void main(String[] args) {
        GqldbConfig config = GqldbConfig.builder()
            .hosts("localhost:9000")
            .build();

        try (GqldbClient client = new GqldbClient(config)) {
            client.login("admin", "password");

            // List existing graphs
            System.out.println("Existing graphs:");
            List<GraphInfo> existingGraphs = client.listGraphs();
            for (GraphInfo g : existingGraphs) {
                System.out.println("  - " + g.getName());
            }

            // Create a new graph
            String graphName = "demoGraph";
            try {
                client.createGraph(graphName, GraphType.OPEN, "Demo graph for testing");
                System.out.println("Created graph: " + graphName);
            } catch (GraphExistsException e) {
                System.out.println("Graph " + graphName + " already exists");
            }

            // Use the graph
            client.useGraph(graphName);

            // Get graph info
            GraphInfo info = client.getGraphInfo(graphName);
            System.out.println("Graph info: " + info.getName() +
                " (nodes: " + info.getNodeCount() + ", edges: " + info.getEdgeCount() + ")");

            // Insert some data
            client.gql("INSERT (n:User {_id: \"u1\", name: \"Alice\"})");
            client.gql("INSERT (n:User {_id: \"u2\", name: \"Bob\"})");

            // Check updated counts
            GraphInfo updatedInfo = client.getGraphInfo(graphName);
            System.out.println("Graph now has " + updatedInfo.getNodeCount() + " nodes");

            // Clean up - drop the demo graph
            client.dropGraph(graphName);
            System.out.println("Dropped graph: " + graphName);

        } catch (GqldbException e) {
            System.err.println("Error: " + e.getMessage());
        }
    }
}
```
