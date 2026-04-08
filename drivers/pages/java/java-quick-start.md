# Quick Start

The GQLDB Java driver is a gRPC-based client library for interacting with GQLDB graph database. It requires **Java 8 or later**.

## Install the Driver

Add the dependency to your Maven `pom.xml`:

```xml
<dependency>
    <groupId>com.ultipa</groupId>
    <artifactId>ultipa-gqldb-driver</artifactId>
    <version>6.0.6</version>
</dependency>
```

Or for Gradle, add to `build.gradle`:

```groovy
implementation 'com.ultipa:ultipa-gqldb-driver:6.0.6'
```

> Replace `6.0.6` with a specific version. Check <a href="https://mvnrepository.com/artifact/com.ultipa/ultipa-gqldb-driver" target="_blank">Maven Central</a> for the latest version.

## Connect to Database

You need a running GQLDB instance to use the driver. Create a client and authenticate:

```java
import com.gqldb.GqldbClient;
import com.gqldb.GqldbConfig;
import com.gqldb.Session;

public class QuickStart {
    public static void main(String[] args) {
        // Create configuration
        GqldbConfig config = GqldbConfig.builder()
            .hosts("localhost:60061")
            .defaultGraph("myGraph")
            .build();

        // Create client (implements AutoCloseable)
        try (GqldbClient client = new GqldbClient(config)) {
            // Authenticate
            Session session = client.login("username", "password");
            System.out.println("Logged in successfully");

            // Test connection with ping
            long latency = client.ping();
            System.out.println("Ping latency: " + latency + "ns");

        } // Client automatically closed
    }
}
```

## Query the Database

Use the `gql()` method to execute GQL queries:

```java
import com.gqldb.*;

public class QueryExample {
    public static void main(String[] args) {
        GqldbConfig config = GqldbConfig.builder()
            .hosts("localhost:60061")
            .defaultGraph("myGraph")
            .build();

        try (GqldbClient client = new GqldbClient(config)) {
            client.login("username", "password");

            // Execute a GQL query
            Response response = client.gql("MATCH (n) RETURN n LIMIT 10");

            // Process results
            System.out.println("Columns: " + response.getColumns());
            System.out.println("Row count: " + response.getRowCount());

            for (Row row : response) {
                System.out.println(row.get(0));
            }
        }
    }
}
```

## Create a Graph

Create a new graph in the database:

```java
import com.gqldb.*;
import com.gqldb.types.GraphType;

public class CreateGraphExample {
    public static void main(String[] args) {
        GqldbConfig config = GqldbConfig.builder()
            .hosts("localhost:60061")
            .build();

        try (GqldbClient client = new GqldbClient(config)) {
            client.login("username", "password");

            // Create an open (schema-less) graph
            client.createGraph("myNewGraph", GraphType.OPEN, "My graph description");
            System.out.println("Graph created successfully");

            // Use the graph
            client.useGraph("myNewGraph");
        }
    }
}
```

## Insert Data

Insert nodes and edges into a graph:

```java
import com.gqldb.*;
import java.util.*;

public class InsertDataExample {
    public static void main(String[] args) {
        GqldbConfig config = GqldbConfig.builder()
            .hosts("localhost:60061")
            .defaultGraph("myGraph")
            .build();

        try (GqldbClient client = new GqldbClient(config)) {
            client.login("username", "password");

            // Create node data
            List<NodeData> nodes = Arrays.asList(
                new NodeData(Arrays.asList("User"),
                    Map.of("name", "Alice", "age", 30)),
                new NodeData(Arrays.asList("User"),
                    Map.of("name", "Bob", "age", 25))
            );

            // Insert nodes
            InsertNodesResult nodeResult = client.insertNodes("myGraph", nodes);
            System.out.println("Inserted " + nodeResult.getNodeCount() + " nodes");

            // Create edge data
            List<EdgeData> edges = Arrays.asList(
                new EdgeData("Follows", "user1", "user2", Map.of())
            );

            // Insert edges
            InsertEdgesResult edgeResult = client.insertEdges("myGraph", edges);
            System.out.println("Inserted " + edgeResult.getEdgeCount() + " edges");
        }
    }
}
```

## Process Query Results

The `gql()` method returns a `Response` object with methods to extract different data types:

```java
import com.gqldb.*;

public class ProcessResultsExample {
    public static void main(String[] args) {
        GqldbConfig config = GqldbConfig.builder()
            .hosts("localhost:60061")
            .defaultGraph("myGraph")
            .build();

        try (GqldbClient client = new GqldbClient(config)) {
            client.login("username", "password");

            // Query nodes
            Response response = client.gql("MATCH (u:User) RETURN u LIMIT 5");

            // Extract as Node objects via alias
            NodeResult nodeResult = response.alias("u").asNodes();
            for (Node node : nodeResult.getNodes()) {
                System.out.println("Node: " + node.getId() +
                    ", Labels: " + node.getLabels() +
                    ", Properties: " + node.getProperties());
            }

            // Or convert to maps
            List<Map<String, Object>> maps = response.toMaps();
            System.out.println(maps);
        }
    }
}
```

## Use Transactions

Execute multiple operations atomically:

```java
import com.gqldb.*;

public class TransactionExample {
    public static void main(String[] args) {
        GqldbConfig config = GqldbConfig.builder()
            .hosts("localhost:60061")
            .build();

        try (GqldbClient client = new GqldbClient(config)) {
            client.login("username", "password");

            // Use withTransaction for automatic commit/rollback
            String result = client.withTransaction("myGraph", txId -> {
                client.gqlInTransaction("INSERT (n:User {_id: \"u1\", name: \"Alice\"})", txId);
                client.gqlInTransaction("INSERT (n:User {_id: \"u2\", name: \"Bob\"})", txId);
                return "Transaction completed";
            });

            System.out.println(result);
        }
    }
}
```

## Next Steps

- <a href="/docs/drivers/java-configuration">Configuration</a> - Learn about all configuration options
- <a href="/docs/drivers/java-connection-and-session">Connection and Session</a> - Detailed connection management
- <a href="/docs/drivers/java-executing-queries">Executing Queries</a> - Query methods and options
- <a href="/docs/drivers/java-response-processing">Response Processing</a> - Working with query results
