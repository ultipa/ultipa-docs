# Executing Queries

The GQLDB Python driver provides methods for executing GQL queries with various options including streaming, query explanation, and profiling.

## Query Methods

| Method | Description |
|--------|-------------|
| `gql(query, config)` | Execute a GQL query and return results |
| `gql_stream(query, config, callback)` | Execute a query with streaming results |
| `explain(query, config)` | Get the execution plan for a query |
| `profile(query, config)` | Execute with profiling and get statistics |

## Basic Query Execution

### gql()

Execute a GQL query and return the results:

```python
from gqldb import GqldbClient, GqldbConfig

config = GqldbConfig(hosts=["localhost:9000"])

with GqldbClient(config) as client:
    client.login("admin", "password")
    client.use_graph("myGraph")

    # Simple query
    response = client.gql("MATCH (n:Person) RETURN n.name, n.age")

    print(f"Columns: {response.columns}")
    print(f"Row count: {response.row_count}")

    for row in response:
        name = row.get_string(0)
        age = row.get_int(1)
        print(f"{name}: {age}")
```

## QueryConfig

Configure query execution with `QueryConfig`:

```python
from gqldb.client import QueryConfig

# Create query configuration
query_config = QueryConfig(
    graph_name="myGraph",      # Target graph
    parameters={"limit": 10},  # Query parameters
    timeout=60,                # Query timeout in seconds
    read_only=True             # Read-only transaction
)

response = client.gql(
    "MATCH (n:Person) RETURN n LIMIT $limit",
    query_config
)
```

### QueryConfig Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `graph_name` | `str` | `""` | Target graph (uses session default if empty) |
| `parameters` | `Dict[str, Any]` | `{}` | Query parameters |
| `transaction_id` | `int` | `0` | Transaction ID for transactional queries |
| `timeout` | `int` | `0` | Query timeout in seconds (0 = use client default) |
| `read_only` | `bool` | `False` | Execute as read-only |
| `max_path_results` | `int` | `0` | Maximum number of path results to return (0 = unlimited) |

## Parameterized Queries

Use parameters to safely pass values:

```python
from gqldb.client import QueryConfig

# Using parameters
config = QueryConfig(
    parameters={
        "name": "Alice",
        "min_age": 25
    }
)

response = client.gql(
    "MATCH (n:Person) WHERE n.name = $name AND n.age >= $min_age RETURN n",
    config
)
```

## Streaming Results

### gql_stream()

For large result sets, use streaming to process results in chunks:

```python
def process_chunk(response):
    """Process each chunk of results."""
    for row in response:
        print(f"Processing: {row.get(0)}")

client.gql_stream(
    "MATCH (n) RETURN n",
    callback=process_chunk
)
```

### Streaming with Configuration

```python
from gqldb.client import QueryConfig

config = QueryConfig(
    graph_name="largeGraph",
    timeout=300  # 5 minutes for large queries
)

results = []

def collect_results(response):
    for row in response:
        results.append(row.get(0))

client.gql_stream(
    "MATCH (n:DataPoint) RETURN n.value",
    config,
    collect_results
)

print(f"Collected {len(results)} values")
```

## Query Explanation

### explain()

Get the execution plan without running the query:

```python
plan = client.explain("MATCH (a)-[r]->(b) WHERE a.name = 'Alice' RETURN b")
print("Execution plan:")
print(plan)
```

### Explain with Configuration

```python
from gqldb.client import QueryConfig

config = QueryConfig(graph_name="myGraph")
plan = client.explain(
    "MATCH (n:Person)-[:Knows]->{1,3}(m:Person) RETURN m",
    config
)
print(plan)
```

## Query Profiling

### profile()

Execute a query and get performance statistics:

```python
stats = client.profile("MATCH (n:Person) RETURN n LIMIT 100")
print("Profile statistics:")
print(stats)
```

### Profile Complex Queries

```python
from gqldb.client import QueryConfig

config = QueryConfig(
    graph_name="socialNetwork",
    timeout=120
)

stats = client.profile(
    "MATCH (a:User)-[:Follows]->{1,3}(b:User) RETURN DISTINCT b LIMIT 1000",
    config
)
print(stats)
```

## Query Within Transaction

Execute queries within a transaction:

```python
from gqldb.client import QueryConfig

# Start a transaction
tx = client.begin_transaction("myGraph")

try:
    # Execute queries in the transaction
    config = QueryConfig(transaction_id=tx.id)

    client.gql("INSERT (n:Person {_id: 'p1', name: 'Alice'})", config)
    client.gql("INSERT (n:Person {_id: 'p2', name: 'Bob'})", config)

    # Commit the transaction
    client.commit(tx.id)
except Exception as e:
    # Rollback on error
    client.rollback(tx.id)
    raise
```

## Working with Different Data Types

```python
# Insert various data types
client.gql("""
    INSERT (n:DataNode {
        _id: 'dn1',
        int_val: 42,
        float_val: 3.14159,
        bool_val: true,
        string_val: 'hello',
        list_val: [1, 2, 3],
        map_val: {key: 'value'},
        date_val: DATE('2024-01-15'),
        point_val: POINT(37.7749, -122.4194)
    })
""")

# Query and retrieve
response = client.gql("MATCH (n:DataNode) RETURN n")
nodes, schemas = response.alias("n").as_nodes()

for node in nodes:
    print(f"ID: {node.id}")
    print(f"Properties: {node.properties}")
```

## Error Handling

```python
from gqldb.errors import (
    GqldbError,
    QueryFailedError,
    EmptyQueryError,
    QueryTimeoutError
)

try:
    response = client.gql("MATCH (n) RETURN n")
except EmptyQueryError:
    print("Query cannot be empty")
except QueryTimeoutError:
    print("Query timed out")
except QueryFailedError as e:
    print(f"Query failed: {e}")
except GqldbError as e:
    print(f"GQLDB error: {e}")
```

## Complete Example

```python
from gqldb import GqldbClient, GqldbConfig
from gqldb.client import QueryConfig
from gqldb.errors import GqldbError

def main():
    config = GqldbConfig(
        hosts=["localhost:9000"],
        timeout=30
    )

    with GqldbClient(config) as client:
        client.login("admin", "password")
        client.create_graph("queryDemo")
        client.use_graph("queryDemo")

        # Insert test data
        client.gql("""
            INSERT (alice:Person {_id: 'p1', name: 'Alice', age: 30}),
                   (bob:Person {_id: 'p2', name: 'Bob', age: 25}),
                   (charlie:Person {_id: 'p3', name: 'Charlie', age: 35}),
                   (alice)-[:Knows]->(bob),
                   (bob)-[:Knows]->(charlie)
        """)

        # Basic query
        print("=== Basic Query ===")
        response = client.gql("MATCH (n:Person) RETURN n.name, n.age ORDER BY n.age")
        for row in response:
            print(f"  {row.get_string(0)}: {row.get_int(1)}")

        # Parameterized query
        print("\n=== Parameterized Query ===")
        query_config = QueryConfig(parameters={"min_age": 28})
        response = client.gql(
            "MATCH (n:Person) WHERE n.age >= $min_age RETURN n.name",
            query_config
        )
        for row in response:
            print(f"  {row.get_string(0)}")

        # Aggregation
        print("\n=== Aggregation ===")
        response = client.gql("MATCH (n:Person) RETURN count(n), avg(n.age), max(n.age)")
        row = response.first()
        if row:
            print(f"  Count: {row.get_int(0)}")
            print(f"  Avg age: {row.get_float(1):.1f}")
            print(f"  Max age: {row.get_int(2)}")

        # Path query
        print("\n=== Path Query ===")
        response = client.gql("""
            MATCH p = (a:Person)-[:Knows]->{1,2}(b:Person)
            WHERE a.name = 'Alice'
            RETURN p
        """)
        paths = response.alias("p").as_paths()
        for path in paths:
            names = [n.properties.get("name", n.id) for n in path.nodes]
            print(f"  Path: {' -> '.join(names)}")

        # Explain query
        print("\n=== Query Plan ===")
        plan = client.explain("MATCH (a)-[r]->(b) RETURN a, r, b LIMIT 10")
        print(plan)

        # Profile query
        print("\n=== Query Profile ===")
        stats = client.profile("MATCH (n:Person) RETURN n")
        print(stats)

        # Streaming (for demonstration)
        print("\n=== Streaming ===")
        count = [0]

        def count_rows(resp):
            count[0] += len(resp.rows)

        client.gql_stream("MATCH (n) RETURN n", callback=count_rows)
        print(f"  Streamed {count[0]} rows")

        # Cleanup
        client.drop_graph("queryDemo")

if __name__ == "__main__":
    main()
```
