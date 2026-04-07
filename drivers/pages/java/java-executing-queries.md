# Executing Queries

The GQLDB Java driver provides several methods for executing GQL queries and analyzing query execution.

## Query Methods

| Method | Description |
|--------|-------------|
| `gql()` | Execute a GQL query and return results |
| `gqlStream()` | Execute a query with streaming results |
| `explain()` | Return the execution plan for a query |
| `profile()` | Execute a query with profiling statistics |

## Basic Query Execution

### gql()

Execute a GQL query and get the complete result:

```java
import com.gqldb.*;

public void queryExample(GqldbClient client) {
    // Simple query
    Response response = client.gql("MATCH (n:User) RETURN n LIMIT 10");

    System.out.println("Columns: " + response.getColumns());
    System.out.println("Row count: " + response.getRowCount());
    System.out.println("Has more: " + response.hasMore());

    // Iterate over rows
    for (Row row : response) {
        System.out.println(row.get(0));
    }
}
```

## Query Configuration

The `QueryConfig` class allows you to customize query execution:

```java
public class QueryConfig {
    private String graphName;      // Target graph (overrides default)
    private Map<String, Object> parameters;  // Query parameters
    private long transactionId;    // Transaction ID for transactional queries
    private int timeout;           // Query timeout in seconds
    private boolean readOnly;      // Mark query as read-only
    private int maxPathResults;    // Maximum number of path results to return
}
```

### Specifying Graph

```java
// Query a specific graph
QueryConfig config = new QueryConfig();
config.setGraphName("myGraph");

Response response = client.gql("MATCH (n) RETURN n LIMIT 5", config);
```

### Query Parameters

Use parameters to safely pass values into queries:

```java
// Using parameters
QueryConfig config = new QueryConfig();
config.setParameters(Map.of("minAge", 25));

Response response = client.gql(
    "MATCH (u:User) WHERE u.age > $minAge RETURN u",
    config
);
```

### Query Timeout

Set a custom timeout for long-running queries:

```java
// 5 minute timeout
QueryConfig config = new QueryConfig();
config.setTimeout(300);  // seconds

Response response = client.gql(
    "MATCH p = (a)-[*1..10]->(b) RETURN p",
    config
);
```

### Read-Only Queries

Mark queries as read-only for optimization:

```java
QueryConfig config = new QueryConfig();
config.setReadOnly(true);

Response response = client.gql("MATCH (n) RETURN count(n)", config);
```

## Streaming Results

### gqlStream()

For large result sets, use streaming to process results incrementally:

```java
import java.util.concurrent.atomic.AtomicLong;

public void streamExample(GqldbClient client) {
    AtomicLong totalRows = new AtomicLong(0);

    QueryConfig config = new QueryConfig();
    config.setGraphName("largeGraph");

    client.gqlStream("MATCH (n) RETURN n", config, response -> {
        // Called for each batch of results
        totalRows.addAndGet(response.getRows().size());
        System.out.println("Received " + response.getRows().size() + " rows");

        for (Row row : response) {
            // Process each row
            System.out.println(row.get(0));
        }
    });

    System.out.println("Total rows processed: " + totalRows.get());
}
```

## Query Analysis

### explain()

Get the execution plan without running the query:

```java
public void explainQuery(GqldbClient client) {
    QueryConfig config = new QueryConfig();
    config.setGraphName("socialGraph");

    String plan = client.explain(
        "MATCH (a:User)-[:Follows]->(b:User) RETURN a, b",
        config
    );

    System.out.println("Execution Plan:");
    System.out.println(plan);
}
```

### profile()

Execute a query and get detailed profiling statistics:

```java
public void profileQuery(GqldbClient client) {
    QueryConfig config = new QueryConfig();
    config.setGraphName("socialGraph");

    String stats = client.profile(
        "MATCH (a:User)-[:Follows]->(b:User) RETURN a, b LIMIT 100",
        config
    );

    System.out.println("Profile Statistics:");
    System.out.println(stats);
}
```

## Working with Results

The `gql()` method returns a `Response` object. See <a href="/docs/drivers/java-response-processing">Response Processing</a> for details.

### Quick Result Access

```java
// Get first row
Optional<Row> firstRow = response.first();

// Get last row
Optional<Row> lastRow = response.last();

// Check if empty
if (response.isEmpty()) {
    System.out.println("No results");
}

// Get single value from single-row, single-column result
Response countResponse = client.gql("MATCH (n) RETURN count(n)");
long count = countResponse.singleLong();
System.out.println("Total: " + count);
```

### Convert to Maps

```java
Response response = client.gql("MATCH (u:User) RETURN u.name AS name, u.age AS age");
List<Map<String, Object>> users = response.toMaps();
// [{"name": "Alice", "age": 30}, {"name": "Bob", "age": 25}]
```

### Extract Graph Elements

```java
// Get nodes
Response nodeResponse = client.gql("MATCH (n:User) RETURN n");
NodeResult nodeResult = nodeResponse.alias("n").asNodes();
for (Node node : nodeResult.getNodes()) {
    System.out.println("Node: " + node.getId());
}

// Get edges
Response edgeResponse = client.gql("MATCH ()-[e:Follows]->() RETURN e");
EdgeResult edgeResult = edgeResponse.alias("e").asEdges();
for (Edge edge : edgeResult.getEdges()) {
    System.out.println("Edge: " + edge.getId());
}

// Get paths
Response pathResponse = client.gql("MATCH p = (a)-[*]->(b) RETURN p");
List<Path> paths = pathResponse.alias("p").asPaths();
```

## Transactional Queries

Execute queries within a transaction:

```java
public void transactionalQuery(GqldbClient client) {
    Transaction tx = client.beginTransaction("myGraph");

    try {
        // Execute queries in transaction using gqlInTransaction
        client.gqlInTransaction("INSERT (n:User {_id: \"u1\", name: \"Alice\"})", tx.getId());
        client.gqlInTransaction("INSERT (n:User {_id: \"u2\", name: \"Bob\"})", tx.getId());

        // Or use QueryConfig with transactionId
        QueryConfig config = new QueryConfig();
        config.setTransactionId(tx.getId());
        Response response = client.gql("MATCH (u:User) RETURN count(u)", config);

        client.commit(tx.getId());
        System.out.println("Transaction committed");

    } catch (Exception e) {
        client.rollback(tx.getId());
        System.err.println("Transaction rolled back: " + e.getMessage());
    }
}
```

See <a href="/docs/drivers/java-transactions">Transactions</a> for more details.

## Exception Handling

```java
import com.gqldb.*;

public Response safeQuery(GqldbClient client, String query) {
    try {
        return client.gql(query);
    } catch (EmptyQueryException e) {
        System.err.println("Query string is empty");
    } catch (QueryFailedException e) {
        System.err.println("Query failed: " + e.getMessage());
    } catch (GraphNotFoundException e) {
        System.err.println("Graph does not exist");
    } catch (GqldbException e) {
        System.err.println("Error: " + e.getMessage());
    }
    return null;
}
```

## Complete Example

```java
import com.gqldb.*;
import java.util.Map;

public class QueryExample {
    public static void main(String[] args) {
        GqldbConfig config = GqldbConfig.builder()
            .hosts("localhost:9000")
            .defaultGraph("socialNetwork")
            .build();

        try (GqldbClient client = new GqldbClient(config)) {
            client.login("admin", "password");

            // Explain the query first
            String plan = client.explain(
                "MATCH (a:User)-[:Follows]->(b:User) WHERE a.age > $minAge RETURN a, b"
            );
            System.out.println("Query Plan: " + plan);

            // Execute with parameters
            QueryConfig queryConfig = new QueryConfig();
            queryConfig.setParameters(Map.of("minAge", 25));
            queryConfig.setTimeout(30);
            queryConfig.setReadOnly(true);

            Response response = client.gql(
                "MATCH (a:User)-[:Follows]->(b:User) WHERE a.age > $minAge RETURN a, b LIMIT 10",
                queryConfig
            );

            System.out.println("Found " + response.getRowCount() + " relationships");

            // Process results
            for (Row row : response) {
                Object userA = row.get(0);
                Object userB = row.get(1);
                System.out.println(userA + " follows " + userB);
            }

        } catch (GqldbException e) {
            System.err.println("Error: " + e.getMessage());
        }
    }
}
```
