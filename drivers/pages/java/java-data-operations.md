# Data Operations

The GQLDB Java driver provides methods for inserting and deleting nodes and edges programmatically, without writing GQL queries.

## Data Operation Methods

`insertNodes` and `insertEdges` are **overloaded** — Java's compile-time method overloading picks the path from the argument types:

| Call shape | Backed by | Returns |
|---|---|---|
| `insertNodes(graphName, nodes, …)` | gRPC `InsertNodes` RPC (high-throughput) | `InsertNodesResult` |
| `insertNodes(nodes, config?)` | GQL `INSERT` statement (convenience) | `Response` |

`insertNodesBatchAuto` / `insertEdgesBatchAuto` are alternate names for the gRPC path and continue to work (not deprecated).

| Method | Description |
|--------|-------------|
| `insertNodes(graphName, nodes, …)` | Insert nodes via gRPC (high-throughput) |
| `insertNodes(nodes, InsertConfig?)` | Insert nodes via GQL INSERT statement |
| `insertNodesBatchAuto(graphName, nodes, …)` | Alias for `insertNodes(graphName, …)` |
| `insertEdges(graphName, edges, …)` | Insert edges via gRPC (high-throughput) |
| `insertEdges(edges, InsertConfig?)` | Insert edges via GQL INSERT statement |
| `insertEdgesBatchAuto(graphName, edges, …)` | Alias for `insertEdges(graphName, …)` |
| `deleteNodes(graphName, nodeIds)` | Delete nodes by ID |
| `deleteNodes(graphName, labels, where)` | Delete nodes by label and condition |
| `deleteEdges(graphName, edgeIds)` | Delete edges by ID |
| `deleteEdges(graphName, label, where)` | Delete edges by label and condition |

### Choosing a path

| | gRPC path (`insertNodes(graphName, …)`) | GQL path (`insertNodes(nodes, …)`) |
|---|---|---|
| Backed by | gRPC `InsertNodes` RPC | GQL `INSERT` statement |
| Bulk session | Required for high throughput (`startBulkImport`) | Not required |
| Performance | High-throughput for large imports | Good for small batches |
| Custom node `_id` | Supported (`NodeData.id`) | Supported (`NodeData.id` → `_id`) |
| Custom edge `_id` | Supported (`EdgeData.id`) | Supported (`EdgeData.id` → `_id`) |
| Insert modes | NORMAL, OVERWRITE | NORMAL, OVERWRITE, UPSERT |
| Use case | ETL, data migration, bulk loading | Scripts, small batches, UPSERT |

> **Custom edge `_id` requires `WITH EDGE_ID` on the target graph.** This is a server-side prerequisite, not driver-specific — the graph must have been created with `CREATE GRAPH <name> WITH EDGE_ID` for user-supplied edge `_id`s to be honored on either path. Without it, the server auto-generates edge `_id`s and any value passed via `EdgeData.id` is ignored. See [Closed Graphs](../../../gql/pages/graph-management/closed-graphs.md) for the `WITH EDGE_ID` option.

## Inserting Nodes (gRPC Batch)

### insertNodesBatchAuto()

Insert one or more nodes into a graph via gRPC for high-throughput:

```java
import com.gqldb.*;
import java.util.*;

public void insertNodesExample(GqldbClient client) {
    List<NodeData> nodes = Arrays.asList(
        new NodeData(Arrays.asList("User"),
            Map.of("name", "Alice", "age", 30, "email", "alice@example.com")),
        new NodeData(Arrays.asList("User"),
            Map.of("name", "Bob", "age", 25)),
        new NodeData(Arrays.asList("User", "Admin"),  // Multiple labels
            Map.of("name", "Charlie", "role", "administrator"))
    );

    InsertNodesResult result = client.insertNodes("myGraph", nodes);

    System.out.println("Success: " + result.isSuccess());
    System.out.println("Node count: " + result.getNodeCount());
    System.out.println("Node IDs: " + result.getNodeIds());
    System.out.println("Message: " + result.getMessage());
}
```

### NodeData Class

```java
public class NodeData {
    // Constructors
    public NodeData(List<String> labels, Map<String, Object> properties);
    public NodeData(String id, List<String> labels, Map<String, Object> properties);

    // Factory methods
    static NodeData create(String label);
    static NodeData create(String label, Map<String, Object> properties);
    static NodeData create(List<String> labels, Map<String, Object> properties);

    // Factories that set a custom _id
    static NodeData createWithId(String id, String label);
    static NodeData createWithId(String id, String label, Map<String, Object> properties);
    static NodeData createWithId(String id, List<String> labels, Map<String, Object> properties);

    // Fluent builder
    NodeData withProperty(String key, Object value);

    String getId();                          // empty string when unset
    List<String> getLabels();
    Map<String, Object> getProperties();
}
```

A non-empty `id` is written as `_id` on the inserted node (both gRPC and GQL paths).

### InsertNodesResult Class

```java
public class InsertNodesResult {
    boolean isSuccess();
    List<String> getNodeIds();
    long getNodeCount();
    String getMessage();
}
```

### Insert Options

Control node insertion behavior:

```java
// Overwrite existing nodes with same ID
InsertNodesResult result = client.insertNodes("myGraph", nodes, true);
```

### Insert with Bulk Import Session

For high-throughput inserts, use bulk import:

```java
public void insertWithBulkImport(GqldbClient client) {
    // Start bulk import session
    BulkImportSession session = client.startBulkImport("myGraph");

    try {
        // Insert nodes using the session
        InsertNodesResult result = client.insertNodes(
            "myGraph", nodes, false, session.getSessionId()
        );

        // End the session
        client.endBulkImport(session.getSessionId());
    } catch (Exception e) {
        client.abortBulkImport(session.getSessionId());
        throw e;
    }
}
```

## Inserting Edges (gRPC Batch)

### insertEdgesBatchAuto()

Insert one or more edges into a graph via gRPC for high-throughput:

```java
import com.gqldb.*;
import java.util.*;

public void insertEdgesExample(GqldbClient client) {
    List<EdgeData> edges = Arrays.asList(
        new EdgeData("Follows", "user1", "user2",
            Map.of("since", "2024-01-15")),
        new EdgeData("Follows", "user2", "user3",
            Map.of()),
        new EdgeData("Knows", "user1", "user3",
            Map.of("strength", 0.8))
    );

    InsertEdgesResult result = client.insertEdges("myGraph", edges);

    System.out.println("Success: " + result.isSuccess());
    System.out.println("Edge count: " + result.getEdgeCount());
    System.out.println("Edge IDs: " + result.getEdgeIds());
    System.out.println("Skipped: " + result.getSkippedCount());
    System.out.println("Message: " + result.getMessage());
}
```

### EdgeData Class

```java
public class EdgeData {
    public EdgeData(String label, String fromNodeId, String toNodeId,
                    Map<String, Object> properties);
    public EdgeData(String id, String label, String fromNodeId, String toNodeId,
                    Map<String, Object> properties);

    // Factory methods
    static EdgeData create(String label, String fromNodeId, String toNodeId);
    static EdgeData create(String label, String fromNodeId, String toNodeId,
                           Map<String, Object> properties);

    // Factories that set a custom _id
    static EdgeData createWithId(String id, String label,
                                 String fromNodeId, String toNodeId);
    static EdgeData createWithId(String id, String label,
                                 String fromNodeId, String toNodeId,
                                 Map<String, Object> properties);

    EdgeData withProperty(String key, Object value);

    String getId();                          // empty string when unset
    String getLabel();
    String getFromNodeId();
    String getToNodeId();
    Map<String, Object> getProperties();
}
```

A non-empty `id` is written as `_id` on the inserted edge (both gRPC and GQL paths). The target graph must have been created with `WITH EDGE_ID` for the server to honor user-supplied edge `_id`s.

### InsertEdgesResult Class

```java
public class InsertEdgesResult {
    boolean isSuccess();
    List<String> getEdgeIds();
    long getEdgeCount();
    String getMessage();
    long getSkippedCount();  // Edges skipped due to missing nodes
}
```

### Edge Insert Options

```java
// Skip edges where source or target node doesn't exist
InsertEdgesResult result = client.insertEdges("myGraph", edges, true);

System.out.println("Inserted: " + result.getEdgeCount());
System.out.println("Skipped: " + result.getSkippedCount());
```

## GQL-based Insert (Convenience)

### insertNodes(nodes) / insertEdges(edges)

These overloads generate and execute GQL `INSERT` statements and return the raw `Response`. They don't require a bulk import session and use the session's current graph (override via `InsertConfig.graphName`):

```java
import com.gqldb.*;
import java.util.*;

// Simple insert using session graph
client.useGraph("myGraph");

List<NodeData> nodes = Arrays.asList(
    new NodeData(Arrays.asList("Person"), Map.of("name", "Alice", "age", 30)),
    new NodeData(Arrays.asList("Person"), Map.of("name", "Bob", "age", 25)),
    // Custom _id via the 3-arg constructor
    new NodeData("p3", Arrays.asList("Person"), Map.of("name", "Charlie"))
);
client.insertNodes(nodes);

List<EdgeData> edges = Arrays.asList(
    new EdgeData("Knows", "id1", "id2", Map.of("since", 2024)),
    // Custom _id via the 5-arg constructor (requires graph created WITH EDGE_ID)
    new EdgeData("tx-001", "Knows", "id1", "id3", Map.of("since", 2025))
);
client.insertEdges(edges);
```

> GQL `INSERT` only supports a single label per node; if `NodeData.labels` has multiple entries, only the first is used in the GQL path. Use the gRPC path for multi-label nodes.

## Per-call Configuration (InsertConfig)

The GQL-path `insertNodes(nodes, …)` / `insertEdges(edges, …)` accept an optional `InsertConfig` for per-call graph routing and insert mode, without changing session state:

```java
import com.gqldb.*;
import com.gqldb.types.InsertType;

// Target a specific graph without useGraph()
InsertConfig cfg = new InsertConfig();
cfg.setGraphName("myGraph");
cfg.setInsertType(InsertType.OVERWRITE);  // NORMAL (default), OVERWRITE, or UPSERT
cfg.setTimeout(60);                       // Optional per-call timeout (seconds)

client.insertNodes(nodes, cfg);
client.insertEdges(edges, cfg);
```

### InsertConfig Options

`InsertConfig` extends `QueryConfig` with one additional field:

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `graphName` | `String` | `null` | Target graph (uses session default if null) |
| `insertType` | `InsertType` | `NORMAL` | `NORMAL`, `OVERWRITE`, or `UPSERT` (see below) |
| `timeout` | `int` | `0` | Per-call timeout in seconds (0 = use client default) |

### InsertType Semantics

| Value | Emitted GQL | On duplicate `_id` |
|---|---|---|
| `NORMAL` (default) | `INSERT` | Error |
| `OVERWRITE` | `INSERT OVERWRITE` | Replaces the entity wholesale — properties not in the write are **lost** |
| `UPSERT` | `UPSERT` | Merges properties — properties not in the write are **preserved** |

`OVERWRITE` and `UPSERT` are different semantics on existing rows; they are not interchangeable.

All other convenience methods also accept `QueryConfig` for per-call graph routing:

```java
QueryConfig qc = new QueryConfig();
qc.setGraphName("graphA");

client.showNodeLabels(qc);
client.createNodeLabel("User", props, qc);
client.gql("MATCH (n) RETURN n", qc);
```

Passing a per-call config is thread-safe: multiple threads can target different graphs via their own config objects without interfering.

## Deleting Nodes

### deleteNodes()

Delete nodes from a graph:

```java
import com.gqldb.*;
import java.util.*;

public void deleteNodesExample(GqldbClient client) {
    // Delete specific nodes by ID
    DeleteResult result1 = client.deleteNodes("myGraph", Arrays.asList("user1", "user2"));
    System.out.println("Deleted " + result1.getDeletedCount() + " nodes");

    // Delete nodes by label and condition
    DeleteResult result2 = client.deleteNodes(
        "myGraph",
        Arrays.asList("TempUser"),  // labels
        "age < 18"                   // where clause
    );
    System.out.println("Deleted " + result2.getDeletedCount() + " underage users");
}
```

**Method Overloads:**

| Method | Description |
|--------|-------------|
| `deleteNodes(graphName, nodeIds)` | Delete by specific IDs |
| `deleteNodes(graphName, labels, whereClause)` | Delete by labels and condition |

### DeleteResult Class

```java
public class DeleteResult {
    boolean isSuccess();
    long getDeletedCount();
    String getMessage();
}
```

## Deleting Edges

### deleteEdges()

Delete edges from a graph:

```java
public void deleteEdgesExample(GqldbClient client) {
    // Delete specific edges by ID
    DeleteResult result1 = client.deleteEdges("myGraph", Arrays.asList("e1", "e2"));
    System.out.println("Deleted " + result1.getDeletedCount() + " edges");

    // Delete edges by label and condition
    DeleteResult result2 = client.deleteEdges(
        "myGraph",
        "Follows",           // label
        "since < \"2020-01-01\""  // where clause
    );
    System.out.println("Deleted " + result2.getDeletedCount() + " old follow relationships");
}
```

**Method Overloads:**

| Method | Description |
|--------|-------------|
| `deleteEdges(graphName, edgeIds)` | Delete by specific IDs |
| `deleteEdges(graphName, label, whereClause)` | Delete by label and condition |

## Exception Handling

```java
import com.gqldb.*;

public void safeDataOperations(GqldbClient client, List<NodeData> nodes) {
    try {
        client.insertNodes("myGraph", nodes);
    } catch (GraphNotFoundException e) {
        System.err.println("Graph does not exist");
    } catch (GqldbException e) {
        System.err.println("Insert failed: " + e.getMessage());
    }

    try {
        client.deleteNodes("myGraph", Arrays.asList("node1"));
    } catch (GqldbException e) {
        System.err.println("Delete failed: " + e.getMessage());
    }
}
```

## Complete Example

```java
import com.gqldb.*;
import java.util.*;

public class DataOperationsExample {
    public static void main(String[] args) {
        GqldbConfig config = GqldbConfig.builder()
            .hosts("localhost:9000")
            .build();

        try (GqldbClient client = new GqldbClient(config)) {
            client.login("admin", "password");

            // Create test graph
            client.createGraph("dataOpsDemo");

            // Insert users
            List<NodeData> users = Arrays.asList(
                new NodeData(Arrays.asList("User"),
                    Map.of("name", "Alice", "age", 30)),
                new NodeData(Arrays.asList("User"),
                    Map.of("name", "Bob", "age", 25)),
                new NodeData(Arrays.asList("User"),
                    Map.of("name", "Charlie", "age", 35)),
                new NodeData(Arrays.asList("TempUser"),
                    Map.of("name", "Temp1")),
                new NodeData(Arrays.asList("TempUser"),
                    Map.of("name", "Temp2"))
            );

            InsertNodesResult nodeResult = client.insertNodes("dataOpsDemo", users);
            System.out.println("Inserted " + nodeResult.getNodeCount() + " users");

            // Insert relationships
            List<EdgeData> relationships = Arrays.asList(
                new EdgeData("Follows", "alice", "bob", Map.of()),
                new EdgeData("Follows", "bob", "charlie", Map.of()),
                new EdgeData("Knows", "alice", "charlie", Map.of("years", 5))
            );

            InsertEdgesResult edgeResult = client.insertEdges("dataOpsDemo", relationships);
            System.out.println("Inserted " + edgeResult.getEdgeCount() + " relationships");

            // Delete temporary users
            DeleteResult deleteResult = client.deleteNodes(
                "dataOpsDemo",
                Arrays.asList("TempUser"),
                null
            );
            System.out.println("Deleted " + deleteResult.getDeletedCount() + " temporary users");

            // Verify remaining data
            client.useGraph("dataOpsDemo");
            Response countResponse = client.gql("MATCH (n) RETURN count(n)");
            System.out.println("Remaining nodes: " + countResponse.singleLong());

            // Clean up
            client.dropGraph("dataOpsDemo");

        } catch (GqldbException e) {
            System.err.println("Error: " + e.getMessage());
        }
    }
}
```
