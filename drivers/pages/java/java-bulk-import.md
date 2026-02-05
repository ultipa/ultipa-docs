# Bulk Import

The GQLDB Java driver provides a bulk import service for high-throughput data ingestion. Bulk import optimizes performance by batching operations and reducing overhead.

## Bulk Import Methods

| Method | Description |
|--------|-------------|
| `startBulkImport()` | Start a bulk import session |
| `checkpoint()` | Flush accumulated data to disk |
| `endBulkImport()` | End the session with a final checkpoint |
| `abortBulkImport()` | Cancel the session without saving |
| `getBulkImportStatus()` | Get the current status of a session |

## Starting a Bulk Import Session

### startBulkImport()

Initialize a bulk import session for a graph:

```java
import com.gqldb.*;

public void startBulkImportExample(GqldbClient client) {
    // Basic start with manual checkpointing
    BulkImportSession session = client.startBulkImport("myGraph");
    System.out.println("Session ID: " + session.getSessionId());
    System.out.println("Success: " + session.isSuccess());

    // Start with auto-checkpoint every 10,000 records
    BulkImportSession autoSession = client.startBulkImport("myGraph", 10000);

    // Start with full options
    BulkImportSession optimizedSession = client.startBulkImport(
        "myGraph",
        10000,      // checkpointEvery: auto-checkpoint every 10,000 records
        1000000,    // estimatedNodes: hint for pre-allocating node ID cache
        5000000     // estimatedEdges: hint for edge batch sizing
    );
}
```

### BulkImportSession Class

```java
public class BulkImportSession {
    boolean isSuccess();
    String getSessionId();
    String getMessage();
}
```

## Inserting Data During Bulk Import

Use the session ID with `insertNodes()` and `insertEdges()`:

```java
public void bulkInsertExample(GqldbClient client) {
    BulkImportSession session = client.startBulkImport("myGraph", 50000);

    try {
        // Insert nodes in batches
        for (int batch = 0; batch < 100; batch++) {
            List<NodeData> nodes = generateNodeBatch(batch, 1000);  // 1000 nodes per batch

            client.insertNodes("myGraph", nodes, false, session.getSessionId());
        }

        // Insert edges in batches
        for (int batch = 0; batch < 100; batch++) {
            List<EdgeData> edges = generateEdgeBatch(batch, 5000);  // 5000 edges per batch

            client.insertEdges("myGraph", edges, false, session.getSessionId());
        }

        // End with final checkpoint
        EndBulkImportResult result = client.endBulkImport(session.getSessionId());
        System.out.println("Imported " + result.getTotalRecords() + " records");

    } catch (Exception e) {
        // Abort on error
        client.abortBulkImport(session.getSessionId());
        throw e;
    }
}
```

## Checkpoints

### checkpoint()

Manually flush accumulated data to disk for durability:

```java
public void checkpointExample(GqldbClient client) {
    BulkImportSession session = client.startBulkImport("myGraph");

    // Insert some data...
    client.insertNodes("myGraph", nodes1, false, session.getSessionId());

    // Checkpoint to ensure data is persisted
    CheckpointResult result = client.checkpoint(session.getSessionId());

    System.out.println("Checkpoint success: " + result.isSuccess());
    System.out.println("Records since start: " + result.getRecordCount());
    System.out.println("Records since last checkpoint: " + result.getLastCheckpointCount());
    System.out.println("Message: " + result.getMessage());

    // Continue importing...
    client.insertNodes("myGraph", nodes2, false, session.getSessionId());

    // Final checkpoint and end
    client.endBulkImport(session.getSessionId());
}
```

### CheckpointResult Class

```java
public class CheckpointResult {
    boolean isSuccess();
    long getRecordCount();          // Total records since session start
    long getLastCheckpointCount();  // Records since last checkpoint
    String getMessage();
}
```

## Ending a Bulk Import

### endBulkImport()

Complete the session with a final checkpoint:

```java
public void endBulkImportExample(GqldbClient client) {
    BulkImportSession session = client.startBulkImport("myGraph");

    // ... insert data ...

    EndBulkImportResult result = client.endBulkImport(session.getSessionId());

    System.out.println("Success: " + result.isSuccess());
    System.out.println("Total records: " + result.getTotalRecords());
    System.out.println("Message: " + result.getMessage());
}
```

### EndBulkImportResult Class

```java
public class EndBulkImportResult {
    boolean isSuccess();
    long getTotalRecords();
    String getMessage();
}
```

## Aborting a Bulk Import

### abortBulkImport()

Cancel a session without saving uncommitted data:

```java
public void abortBulkImportExample(GqldbClient client) {
    BulkImportSession session = client.startBulkImport("myGraph");

    try {
        // ... insert data ...

        if (someErrorCondition) {
            AbortBulkImportResult result = client.abortBulkImport(session.getSessionId());
            System.out.println("Abort success: " + result.isSuccess());
            System.out.println("Message: " + result.getMessage());
            return;
        }

        client.endBulkImport(session.getSessionId());

    } catch (Exception e) {
        client.abortBulkImport(session.getSessionId());
        throw e;
    }
}
```

### AbortBulkImportResult Class

```java
public class AbortBulkImportResult {
    boolean isSuccess();
    String getMessage();
}
```

## Checking Bulk Import Status

### getBulkImportStatus()

Get the current status of a bulk import session:

```java
public void checkStatusExample(GqldbClient client) {
    BulkImportSession session = client.startBulkImport("myGraph");

    // ... insert some data ...

    BulkImportStatus status = client.getBulkImportStatus(session.getSessionId());

    System.out.println("Is active: " + status.isActive());
    System.out.println("Graph name: " + status.getGraphName());
    System.out.println("Record count: " + status.getRecordCount());
    System.out.println("Last checkpoint count: " + status.getLastCheckpointCount());
    System.out.println("Created at: " + new Date(status.getCreatedAt()));
    System.out.println("Last activity: " + new Date(status.getLastActivity()));
}
```

### BulkImportStatus Class

```java
public class BulkImportStatus {
    boolean isActive();
    String getGraphName();
    long getRecordCount();
    long getLastCheckpointCount();
    long getCreatedAt();      // Timestamp in milliseconds
    long getLastActivity();   // Timestamp in milliseconds
}
```

## Complete Example

```java
import com.gqldb.*;
import java.util.*;

public class BulkImportExample {
    public static void main(String[] args) {
        GqldbConfig config = GqldbConfig.builder()
            .hosts("192.168.1.100:9000")
            .build();

        try (GqldbClient client = new GqldbClient(config)) {
            client.login("admin", "password");

            // Create graph for bulk import
            client.createGraph("bulkDemo");

            // Start bulk import session
            BulkImportSession session = client.startBulkImport(
                "bulkDemo",
                10000,      // checkpoint every 10,000 records
                100000,     // estimated nodes
                500000      // estimated edges
            );

            System.out.println("Started bulk import session: " + session.getSessionId());

            // Generate and insert nodes
            for (int batch = 0; batch < 10; batch++) {
                List<NodeData> nodes = new ArrayList<>();
                for (int i = 0; i < 10000; i++) {
                    int id = batch * 10000 + i;
                    nodes.add(new NodeData(
                        "user" + id,
                        Arrays.asList("User"),
                        Map.of("name", "User " + id, "index", id)
                    ));
                }

                client.insertNodes("bulkDemo", nodes, false, session.getSessionId());
                System.out.println("Inserted batch " + (batch + 1) + "/10");
            }

            // Check status
            BulkImportStatus status = client.getBulkImportStatus(session.getSessionId());
            System.out.println("Current status: " + status.getRecordCount() + " records");

            // Manual checkpoint
            CheckpointResult checkpoint = client.checkpoint(session.getSessionId());
            System.out.println("Checkpoint: " + checkpoint.getRecordCount() + " records saved");

            // Generate and insert edges
            List<EdgeData> edges = new ArrayList<>();
            for (int i = 0; i < 50000; i++) {
                edges.add(new EdgeData(
                    "edge" + i,
                    "Knows",
                    "user" + i,
                    "user" + ((i + 1) % 100000),
                    Map.of()
                ));
            }
            client.insertEdges("bulkDemo", edges, false, session.getSessionId());

            // End bulk import
            EndBulkImportResult result = client.endBulkImport(session.getSessionId());
            System.out.println("Bulk import completed: " + result.getTotalRecords() + " records");

            // Verify
            client.useGraph("bulkDemo");
            Response countResponse = client.gql("MATCH (n) RETURN count(n)");
            System.out.println("Total nodes: " + countResponse.singleLong());

            // Clean up
            client.dropGraph("bulkDemo");

        } catch (GqldbException e) {
            System.err.println("Error: " + e.getMessage());
        }
    }
}
```
