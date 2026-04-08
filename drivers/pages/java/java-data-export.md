# Data Export

The GQLDB Java driver provides streaming export capabilities for efficiently extracting large amounts of data from the database.

## Export Methods

| Method | Description |
|--------|-------------|
| `export(ExportConfig, Consumer)` | Export graph data with full configuration |
| `export(String, Consumer)` | Export graph data with simplified configuration |

## Unified Export

### export()

Export nodes and/or edges in JSON Lines format with streaming:

```java
import com.gqldb.*;
import java.util.function.Consumer;

public void exportExample(GqldbClient client) {
    ExportConfig config = ExportConfig.builder()
        .graphName("myGraph")
        .batchSize(1000)
        .exportNodes(true)
        .exportEdges(true)
        .build();

    client.export(config, chunk -> {
        // Process each chunk of data
        String data = new String(chunk.getData(), StandardCharsets.UTF_8);
        String[] lines = data.split("\n");

        for (String line : lines) {
            if (!line.isEmpty()) {
                // Parse JSON line
                System.out.println(line);
            }
        }

        if (chunk.isFinal() && chunk.getStats() != null) {
            ExportStats stats = chunk.getStats();
            System.out.println("Export complete:");
            System.out.println("  Nodes: " + stats.getNodesExported());
            System.out.println("  Edges: " + stats.getEdgesExported());
            System.out.println("  Bytes: " + stats.getBytesWritten());
            System.out.println("  Duration: " + stats.getDurationMs() + "ms");
        }
    });
}
```

### ExportConfig Builder

```java
ExportConfig config = ExportConfig.builder()
    .graphName("myGraph")          // Required: target graph
    .batchSize(1000)               // Records per chunk
    .exportNodes(true)             // Include nodes (default: true)
    .exportEdges(true)             // Include edges (default: true)
    .nodeLabels(Arrays.asList("User", "Company"))  // Filter by node labels
    .edgeLabels(Arrays.asList("Follows", "WorksAt"))  // Filter by edge labels
    .includeMetadata(true)         // Include metadata in output
    .build();
```

### ExportChunk Class

```java
public class ExportChunk {
    byte[] getData();           // JSON Lines data
    boolean isFinal();          // Is this the last chunk?
    ExportStats getStats();     // Statistics (on final chunk)
}
```

### ExportStats Class

```java
public class ExportStats {
    long getNodesExported();
    long getEdgesExported();
    long getBytesWritten();
    long getDurationMs();
}
```

## Filtering Exports

### Export Specific Labels

```java
public void exportFilteredExample(GqldbClient client) {
    // Export only User nodes and Follows edges
    ExportConfig config = ExportConfig.builder()
        .graphName("socialGraph")
        .exportNodes(true)
        .exportEdges(true)
        .nodeLabels(Arrays.asList("User", "Company"))
        .edgeLabels(Arrays.asList("Follows", "WorksAt"))
        .build();

    client.export(config, chunk -> {
        // Process filtered data
    });
}
```

### Export Only Nodes

```java
public void exportNodesOnlyExample(GqldbClient client) {
    ExportConfig config = ExportConfig.builder()
        .graphName("myGraph")
        .exportNodes(true)
        .exportEdges(false)
        .build();

    client.export(config, chunk -> {
        // Only nodes in the output
    });
}
```

### Export Only Edges

```java
public void exportEdgesOnlyExample(GqldbClient client) {
    ExportConfig config = ExportConfig.builder()
        .graphName("myGraph")
        .exportNodes(false)
        .exportEdges(true)
        .build();

    client.export(config, chunk -> {
        // Only edges in the output
    });
}
```

## Writing to File

```java
import java.io.*;
import java.nio.charset.StandardCharsets;

public void exportToFile(GqldbClient client) throws IOException {
    try (FileOutputStream fos = new FileOutputStream("export.jsonl");
         BufferedOutputStream bos = new BufferedOutputStream(fos)) {

        ExportConfig config = ExportConfig.builder()
            .graphName("myGraph")
            .batchSize(5000)
            .build();

        client.export(config, chunk -> {
            try {
                bos.write(chunk.getData());

                if (chunk.isFinal()) {
                    bos.flush();
                    System.out.println("Export written to export.jsonl");
                }
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
        });
    }
}
```

## Simplified Export

Use the simplified method for basic exports:

```java
public void simpleExportExample(GqldbClient client) {
    // Export all nodes and edges from a graph
    client.export("myGraph", chunk -> {
        System.out.println("Received " + chunk.getData().length + " bytes");

        if (chunk.isFinal()) {
            System.out.println("Export complete");
        }
    });
}
```

## Collecting All Data

```java
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.*;

public Map<String, List<Map<String, Object>>> exportToMemory(GqldbClient client) {
    List<Map<String, Object>> nodes = new ArrayList<>();
    List<Map<String, Object>> edges = new ArrayList<>();
    ObjectMapper mapper = new ObjectMapper();

    ExportConfig config = ExportConfig.builder()
        .graphName("myGraph")
        .batchSize(1000)
        .build();

    client.export(config, chunk -> {
        String data = new String(chunk.getData(), StandardCharsets.UTF_8);
        String[] lines = data.split("\n");

        for (String line : lines) {
            if (line.isEmpty()) continue;

            try {
                Map<String, Object> record = mapper.readValue(line, Map.class);
                String type = (String) record.get("_type");

                if ("node".equals(type)) {
                    nodes.add(record);
                } else if ("edge".equals(type)) {
                    edges.add(record);
                }
            } catch (Exception e) {
                System.err.println("Failed to parse: " + line);
            }
        }
    });

    System.out.println("Collected " + nodes.size() + " nodes and " + edges.size() + " edges");

    Map<String, List<Map<String, Object>>> result = new HashMap<>();
    result.put("nodes", nodes);
    result.put("edges", edges);
    return result;
}
```

## Complete Example

```java
import com.gqldb.*;
import java.io.*;
import java.nio.charset.StandardCharsets;

public class DataExportExample {
    public static void main(String[] args) {
        GqldbConfig config = GqldbConfig.builder()
            .hosts("localhost:60061")
            .build();

        try (GqldbClient client = new GqldbClient(config)) {
            client.login("admin", "password");

            // Create and populate a test graph
            client.createGraph("exportDemo");
            client.useGraph("exportDemo");

            // Insert test data
            client.gql("INSERT " +
                "(a:User {_id: 'u1', name: 'Alice', age: 30}), " +
                "(b:User {_id: 'u2', name: 'Bob', age: 25}), " +
                "(c:Company {_id: 'c1', name: 'Acme Inc'}), " +
                "(a)-[:Follows {since: '2023-01-01'}]->(b), " +
                "(a)-[:WorksAt {role: 'Engineer'}]->(c)"
            );

            System.out.println("Exporting to file...");

            // Export to JSON Lines file
            String outputPath = "graph-export.jsonl";
            long[] totalRecords = {0};

            try (FileOutputStream fos = new FileOutputStream(outputPath)) {
                ExportConfig exportConfig = ExportConfig.builder()
                    .graphName("exportDemo")
                    .batchSize(100)
                    .exportNodes(true)
                    .exportEdges(true)
                    .includeMetadata(true)
                    .build();

                client.export(exportConfig, chunk -> {
                    try {
                        fos.write(chunk.getData());

                        // Count records
                        String data = new String(chunk.getData(), StandardCharsets.UTF_8);
                        long count = data.lines().filter(l -> !l.isEmpty()).count();
                        totalRecords[0] += count;

                        if (chunk.isFinal()) {
                            fos.flush();
                            System.out.println("\nExport complete!");
                            System.out.println("  File: " + outputPath);
                            System.out.println("  Records: " + totalRecords[0]);

                            if (chunk.getStats() != null) {
                                ExportStats stats = chunk.getStats();
                                System.out.println("  Nodes: " + stats.getNodesExported());
                                System.out.println("  Edges: " + stats.getEdgesExported());
                                System.out.println("  Size: " + stats.getBytesWritten() + " bytes");
                                System.out.println("  Duration: " + stats.getDurationMs() + "ms");
                            }
                        }
                    } catch (IOException e) {
                        throw new RuntimeException(e);
                    }
                });
            }

            // Read and display the file
            System.out.println("\nExported data:");
            try (BufferedReader reader = new BufferedReader(new FileReader(outputPath))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    System.out.println(line);
                }
            }

            // Clean up
            new File(outputPath).delete();
            client.dropGraph("exportDemo");

        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
```
