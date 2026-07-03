# Response Processing

The GQLDB Python driver provides the `Response` and `Row` classes for working with query results. This guide covers how to extract and convert data from query responses.

## Response Class

The `gql()` method returns a `Response` object containing query results:

```python
from gqldb import GqldbClient, GqldbConfig

config = GqldbConfig(hosts=["localhost:9000"])

with GqldbClient(config) as client:
    client.login("admin", "password")
    client.use_graph("myGraph")

    response = client.gql("MATCH (n:User) RETURN n.name, n.age")

    print(f"Columns: {response.columns}")        # ["n.name", "n.age"]
    print(f"Row count: {response.row_count}")    # Number of rows
    print(f"Has more: {response.has_more}")      # Pagination indicator
    print(f"Warnings: {response.warnings}")      # Any query warnings
    print(f"Rows affected: {response.rows_affected}")  # For write operations
```

### Response Attributes and Methods

| Attribute/Method | Return Type | Description |
|------------------|-------------|-------------|
| `columns` | `List[str]` | Column names from the query |
| `rows` | `List[Row]` | List of result rows |
| `row_count` | `int` | Total number of rows |
| `has_more` | `bool` | Whether more results are available |
| `warnings` | `List[str]` | Query warnings |
| `rows_affected` | `int` | Rows affected by write operations |
| `dml_stats` | `Optional[DmlStats]` | Per-category data-modification counts, or `None` for non-DML queries |
| `time_cost_ns` | `int` | Engine-side total time (parse + plan + execute), in nanoseconds |
| `disk_cost_ns` | `int` | Engine-side time spent in the storage layer, in nanoseconds |
| `compute_cost_ns` | `int` | Engine-side time spent in the in-memory compute engine, in nanoseconds |
| `is_empty()` | `bool` | Whether response has no rows |
| `first()` | `Optional[Row]` | First row or None |
| `last()` | `Optional[Row]` | Last row or None |

### DML statistics

For data-modifying queries (`INSERT` / `SET` / `REMOVE` / `DELETE` / `MERGE`), `response.dml_stats` carries a `DmlStats` breaking the change down by category. It is `None` when the query wasn't data-modifying — a pure read, or an older server that doesn't report the field. `None` means "not a DML query", **not** "changed nothing"; a DML query that matched no rows still returns a populated `DmlStats` with zero counts. `rows_affected` remains the sum across all categories.

`DmlStats` is exported from the top-level `gqldb` package:

```python
from gqldb import DmlStats

@dataclass
class DmlStats:
    inserted_nodes: int = 0
    inserted_edges: int = 0
    deleted_nodes: int = 0
    deleted_edges: int = 0
    set_nodes: int = 0
    set_edges: int = 0
```

| Field | Type | Description |
|-------|------|-------------|
| `inserted_nodes` | `int` | Nodes created |
| `inserted_edges` | `int` | Edges created |
| `deleted_nodes` | `int` | Nodes deleted |
| `deleted_edges` | `int` | Edges deleted |
| `set_nodes` | `int` | Nodes updated (`SET` / `REMOVE`) |
| `set_edges` | `int` | Edges updated (`SET` / `REMOVE`) |

```python
response = client.gql("""
    INSERT (a:User {_id: 'u1', name: 'Alice'}),
           (b:User {_id: 'u2', name: 'Bob'}),
           (a)-[:Follows]->(b)
""")

stats = response.dml_stats
if stats is not None:
    print(f"Nodes inserted: {stats.inserted_nodes}")   # 2
    print(f"Edges inserted: {stats.inserted_edges}")   # 1
    print(f"Total affected: {response.rows_affected}") # 3
else:
    print("Not a data-modifying query")
```

### Query cost fields

Every `Response` exposes engine-side timing, read from the server's result set. These measure work **inside the engine only** — network transfer and client-side processing are not included. All three are integers in nanoseconds and default to `0`; an old server that doesn't report them (or a streaming query before its final batch) leaves them at `0`, which means "not reported", not "took zero time".

| Field | Meaning |
|-------|---------|
| `time_cost_ns` | Total wall-clock time: parse + plan + execute |
| `disk_cost_ns` | Subset of the total spent in the storage / LSM layer |
| `compute_cost_ns` | Subset spent in the in-memory compute engine (k-hop, shortest path, `algo.*`); `0` when the query didn't use the compute accelerator |

```python
response = client.gql("MATCH (n:User) RETURN n LIMIT 100")

print(f"Total engine time: {response.time_cost_ns / 1e6:.2f} ms")
print(f"  storage:  {response.disk_cost_ns / 1e6:.2f} ms")
print(f"  compute:  {response.compute_cost_ns / 1e6:.2f} ms")
```

## Row Class

Each row contains values that can be accessed by index:

```python
response = client.gql("MATCH (n:User) RETURN n.name, n.age, n.active")

for row in response:
    # Access by index
    name = row.get(0)      # First column
    age = row.get(1)       # Second column
    active = row.get(2)    # Third column

    # Typed accessors
    name_str = row.get_string(0)    # Returns str
    age_int = row.get_int(1)        # Returns int
    active_bool = row.get_bool(2)   # Returns bool

    print(f"{name_str}, age {age_int}, active: {active_bool}")
```

### Row Methods

| Method | Return Type | Description |
|--------|-------------|-------------|
| `get(index)` | `Any` | Get value at index |
| `get_string(index)` | `str` | Get value as string |
| `get_int(index)` | `int` | Get value as integer |
| `get_float(index)` | `float` | Get value as float |
| `get_bool(index)` | `bool` | Get value as boolean |

## Iterating Results

### Using for loop

```python
response = client.gql("MATCH (n) RETURN n")

# Response implements __iter__
for row in response:
    print(row.get(0))
```

### Using for_each

```python
def process_row(row, index):
    print(f"Row {index}: {row.get(0)}")

response.for_each(process_row)
```

### Using map

```python
names = response.map(lambda row: row.get_string(0))
print(f"Names: {names}")
```

## Quick Access Methods

### First and Last Row

```python
first = response.first()  # First row or None
last = response.last()    # Last row or None

if first:
    print(f"First result: {first.get(0)}")
```

### Check if Empty

```python
if response.is_empty():
    print("No results found")
```

### Single Value

For queries that return a single row with a single column:

```python
count_response = client.gql("MATCH (n) RETURN count(n)")
count = count_response.single_value()  # Returns the single value

# Typed single value accessors
count_int = count_response.single_int()      # As int
count_str = count_response.single_string()   # As string
```

## Converting to Dictionaries

### to_dicts()

Convert rows to a list of dictionaries:

```python
response = client.gql("MATCH (u:User) RETURN u.name AS name, u.age AS age")
users = response.to_dicts()

# Result: [{"name": "Alice", "age": 30}, {"name": "Bob", "age": 25}]
for user in users:
    print(f"{user['name']} is {user['age']} years old")
```

### to_json()

Convert to JSON string:

```python
json_str = response.to_json()
print(json_str)
```

### Get Value by Column Name

```python
response = client.gql("MATCH (u:User) RETURN u.name AS name, u.age AS age")

for row in response:
    name = response.get_by_name(row, "name")
    age = response.get_by_name(row, "age")
    print(f"{name}: {age}")
```

## Accessing Result Columns

Query results are organized by columns (aliases). To extract typed data such as nodes, edges, paths, tables, or attributes, you must first select a column using `alias()` (by name) or `get()` (by index). These return an `AliasResult` object with type-specific extraction methods.

### alias()

Select a column by its alias name:

```python
response = client.gql("MATCH (u:User)-[e:Follows]->(f:User) RETURN u, e, f")

# Access by alias name
users = response.alias("u").as_nodes()
edges = response.alias("e").as_edges()
friends = response.alias("f").as_nodes()
```

### get()

Select a column by its positional index:

```python
response = client.gql("MATCH (u:User) RETURN u, u.name")

# Access by index
nodes, schemas = response.get(0).as_nodes()
names = response.get(1).as_attr()
```

### AliasResult Class

The `AliasResult` object returned by `alias()` and `get()` provides the following methods:

| Method | Return Type | Description |
|--------|-------------|-------------|
| `as_nodes()` | `Tuple[List[Node], Dict]` | Extract nodes and schemas |
| `as_edges()` | `Tuple[List[Edge], Dict]` | Extract edges and schemas |
| `as_paths()` | `List[Path]` | Extract paths |
| `as_table()` | `Table` | Extract as a table |
| `as_attr()` | `Attr` | Extract as attribute values |

## Extracting Graph Elements

### as_nodes()

Extract nodes from a specific column of the response using `alias()` or `get()`:

```python
from gqldb import Node

response = client.gql("MATCH (u:User) RETURN u")
nodes, schemas = response.alias("u").as_nodes()

# Access nodes
for node in nodes:
    print(f"ID: {node.id}")
    print(f"Labels: {node.labels}")
    print(f"Properties: {node.properties}")

# Access inferred schemas
for label, schema in schemas.items():
    print(f"Schema for {label}: {schema}")
```

### Node Class

```python
@dataclass
class Node:
    id: str
    labels: List[str]
    properties: Dict[str, Any]
```

### as_edges()

Extract edges from a specific column of the response using `alias()` or `get()`:

```python
from gqldb import Edge

response = client.gql("MATCH ()-[e:Follows]->() RETURN e")
edges, schemas = response.alias("e").as_edges()

for edge in edges:
    print(f"ID: {edge.id}")
    print(f"Label: {edge.label}")
    print(f"From: {edge.from_node_id}")
    print(f"To: {edge.to_node_id}")
    print(f"Properties: {edge.properties}")
```

### Edge Class

```python
@dataclass
class Edge:
    id: str
    label: str
    from_node_id: str
    to_node_id: str
    properties: Dict[str, Any]
```

### as_paths()

Extract paths from a specific column of the response using `alias()` or `get()`:

```python
from gqldb import Path

response = client.gql("MATCH p = (a)->{1,3}(b) RETURN p LIMIT 10")
paths = response.alias("p").as_paths()

for path in paths:
    print(f"Path nodes: {len(path.nodes)}")
    print(f"Path edges: {len(path.edges)}")

    # Print path
    for i, node in enumerate(path.nodes):
        print(f"  Node: {node.id}")
        if i < len(path.edges):
            print(f"    -[{path.edges[i].label}]->")
```

### Path Class

```python
@dataclass
class Path:
    nodes: List[Node]
    edges: List[Edge]
```

## Table Format

### as_table()

Get a specific column of the response as a generic table using `alias()` or `get()`:

```python
response = client.gql("MATCH (u:User) RETURN u.name, u.age")
table = response.get(0).as_table()

print(f"Headers: {[h.name for h in table.headers]}")
print(f"Rows: {table.rows}")
```

### Table and Header Classes

```python
@dataclass
class Table:
    name: str
    headers: List[Header]
    rows: List[List[Any]]

@dataclass
class Header:
    name: str
    type: PropertyType
```

## Attribute Extraction

### as_attr()

Extract values from a specific column using `alias()` or `get()`:

```python
response = client.gql("MATCH (u:User) RETURN u.age AS age")
age_attr = response.alias("age").as_attr()

print(f"Column name: {age_attr.name}")
print(f"Type: {age_attr.type}")
print(f"Values: {age_attr.values}")

# Calculate statistics
ages = [v for v in age_attr.values if isinstance(v, (int, float))]
if ages:
    avg_age = sum(ages) / len(ages)
    print(f"Average age: {avg_age}")
```

### Attr Class

```python
@dataclass
class Attr:
    name: str
    type: PropertyType
    values: List[Any]
```

## Complete Example

```python
from gqldb import GqldbClient, GqldbConfig
from gqldb.errors import GqldbError

def main():
    config = GqldbConfig(
        hosts=["localhost:9000"],
        default_graph="socialNetwork"
    )

    with GqldbClient(config) as client:
        client.login("admin", "password")

        # Setup test data
        client.create_graph("socialNetwork")
        client.use_graph("socialNetwork")
        client.gql("""
            INSERT (a:User {_id: 'u1', name: 'Alice', age: 30}),
                   (b:User {_id: 'u2', name: 'Bob', age: 25}),
                   (c:User {_id: 'u3', name: 'Charlie', age: 35}),
                   (a)-[:Follows {since: '2023-01'}]->(b),
                   (b)-[:Follows {since: '2023-03'}]->(c),
                   (c)-[:Follows {since: '2023-06'}]->(a)
        """)

        # Query nodes
        print("=== Query Nodes ===")
        node_response = client.gql("MATCH (u:User) RETURN u LIMIT 5")
        nodes, schemas = node_response.alias("u").as_nodes()
        for node in nodes:
            print(f"User {node.id}: {node.properties.get('name')}")

        # Query with multiple columns
        print("\n=== Query Columns ===")
        col_response = client.gql(
            "MATCH (u:User) RETURN u.name AS name, u.age AS age ORDER BY u.age DESC LIMIT 3"
        )
        users = col_response.to_dicts()
        print(f"Top 3 oldest users: {users}")

        # Query paths
        print("\n=== Query Paths ===")
        path_response = client.gql(
            "MATCH p = (a:User)-[:Follows]->{1,2}(b:User) RETURN p LIMIT 3"
        )
        paths = path_response.alias("p").as_paths()
        for path in paths:
            route = " -> ".join(n.properties.get("name", n.id) for n in path.nodes)
            print(f"Path: {route}")

        # Aggregate query
        print("\n=== Aggregate Query ===")
        count_response = client.gql("MATCH (n) RETURN count(n)")
        print(f"Total nodes: {count_response.single_int()}")

        # Extract attribute values
        print("\n=== Attribute Extraction ===")
        age_response = client.gql("MATCH (u:User) RETURN u.age AS age")
        ages = age_response.alias("age").as_attr()
        numeric_ages = [v for v in ages.values if isinstance(v, (int, float))]

        if numeric_ages:
            print(f"Ages: {numeric_ages}")
            print(f"Min age: {min(numeric_ages)}")
            print(f"Max age: {max(numeric_ages)}")

        # Cleanup
        client.drop_graph("socialNetwork")

if __name__ == "__main__":
    main()
```
