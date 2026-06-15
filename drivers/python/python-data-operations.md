# Data Operations

The GQLDB Python driver provides methods for inserting, updating, and deleting nodes and edges in the graph.

## Data Methods

`insert_nodes` and `insert_edges` are **dual-shape** — Python dispatches on the type of the first argument at runtime:

| Call shape | Backed by | Returns |
|---|---|---|
| `insert_nodes(graph_name, nodes, …)` | gRPC `InsertNodes` RPC (high-throughput) | `InsertNodesResult` |
| `insert_nodes(nodes, config=None)` | GQL `INSERT` statement (convenience) | `Response` |

`insert_nodes_batch_auto` / `insert_edges_batch_auto` are alternate names for the gRPC path and continue to work (not deprecated).

| Method | Description |
|--------|-------------|
| `insert_nodes(graph_name, nodes, …)` | Insert nodes via gRPC (high-throughput) |
| `insert_nodes(nodes, config=None)` | Insert nodes via GQL INSERT statement |
| `insert_nodes_batch_auto(graph_name, nodes, …)` | Alias for `insert_nodes(graph_name, …)` |
| `insert_edges(graph_name, edges, …)` | Insert edges via gRPC (high-throughput) |
| `insert_edges(edges, config=None)` | Insert edges via GQL INSERT statement |
| `insert_edges_batch_auto(graph_name, edges, …)` | Alias for `insert_edges(graph_name, …)` |
| `delete_nodes(graph_name, node_ids, labels, where)` | Delete nodes |
| `delete_edges(graph_name, edge_ids, label, where)` | Delete edges |

### Choosing a path

| | gRPC path (`insert_nodes(graph_name, …)`) | GQL path (`insert_nodes(nodes, …)`) |
|---|---|---|
| Backed by | gRPC `InsertNodes` RPC | GQL `INSERT` statement |
| Bulk session | Required for high throughput (`start_bulk_import`) | Not required |
| Performance | High-throughput for large imports | Good for small batches |
| Custom node `_id` | Supported (`NodeData.id`) | Supported (`NodeData.id` → `_id`) |
| Custom edge `_id` | Supported (`EdgeData.id`) | Supported (`EdgeData.id` → `_id`) |
| Insert modes | NORMAL, OVERWRITE | NORMAL, OVERWRITE, UPSERT |
| Use case | ETL, data migration, bulk loading | Scripts, small batches, UPSERT |

> **Custom edge `_id` requires `WITH EDGE_ID` on the target graph.** This is a server-side prerequisite — the graph must have been created with `CREATE GRAPH <name> WITH EDGE_ID` for user-supplied edge `_id`s to be honored on either path. Without it, the server auto-generates edge `_id`s and any value passed via `EdgeData.id` is ignored.

## Inserting Nodes (gRPC Batch)

### insert_nodes_batch_auto()

Insert multiple nodes into a graph:

```python
from gqldb import GqldbClient, GqldbConfig, NodeData

config = GqldbConfig(hosts=["localhost:9000"])

with GqldbClient(config) as client:
    client.login("admin", "password")
    client.use_graph("myGraph")

    # Create node data
    nodes = [
        NodeData(
            labels=["User"],
            properties={"name": "Alice", "age": 30, "email": "alice@example.com"}
        ),
        NodeData(
            labels=["User"],
            properties={"name": "Bob", "age": 25, "email": "bob@example.com"}
        ),
        NodeData(
            labels=["User", "Admin"],
            properties={"name": "Charlie", "age": 35}
        )
    ]

    # Insert nodes
    result = client.insert_nodes("myGraph", nodes)

    print(f"Success: {result.success}")
    print(f"Inserted: {result.node_count} nodes")
    print(f"Node IDs: {result.node_ids}")
```

### NodeData Class

```python
from dataclasses import dataclass, field
from typing import List, Dict, Any

@dataclass
class NodeData:
    id: str = ""                      # Optional custom node _id (auto-generated when empty)
    labels: List[str] = field(default_factory=list)
    properties: Dict[str, Any] = field(default_factory=dict)
```

A non-empty `id` is written as `_id` on the inserted node (both gRPC and GQL paths).

### Insert Options

```python
from gqldb.types import BulkCreateNodesOptions

options = BulkCreateNodesOptions(
    overwrite=True          # Overwrite if exists
)

result = client.insert_nodes("myGraph", nodes, options)
```

## Inserting Edges

### insert_edges()

Insert multiple edges into a graph:

```python
from gqldb import EdgeData

edges = [
    EdgeData(
        label="Follows",
        from_node_id="u1",
        to_node_id="u2",
        properties={"since": "2023-01-15"}
    ),
    EdgeData(
        label="Follows",
        from_node_id="u2",
        to_node_id="u3",
        properties={"since": "2023-06-20"}
    ),
    EdgeData(
        label="Knows",
        from_node_id="u1",
        to_node_id="u3",
        properties={"years": 5}
    )
]

result = client.insert_edges("myGraph", edges)

print(f"Success: {result.success}")
print(f"Inserted: {result.edge_count} edges")
print(f"Skipped: {result.skipped_count}")
```

### EdgeData Class

```python
from dataclasses import dataclass, field
from typing import Dict, Any

@dataclass
class EdgeData:
    id: str = ""                   # Optional custom edge _id (requires WITH EDGE_ID graph)
    label: str = ""                # Edge label (type)
    from_node_id: str = ""         # Source node ID
    to_node_id: str = ""           # Target node ID
    properties: Dict[str, Any] = field(default_factory=dict)
```

A non-empty `id` is written as `_id` on the inserted edge (both gRPC and GQL paths). The target graph must have been created with `WITH EDGE_ID` for the server to honor user-supplied edge `_id`s.

### Edge Insert Options

```python
from gqldb.types import BulkCreateEdgesOptions

options = BulkCreateEdgesOptions(
    skip_invalid_nodes=True   # Skip edges with invalid endpoints
)

result = client.insert_edges("myGraph", edges, options)
```

## GQL-based Insert (Convenience)

### insert_nodes() / insert_edges()

These convenience methods generate and execute GQL `INSERT` statements. They don't require a bulk import session and use the session's current graph:

```python
client.use_graph("myGraph")

nodes = [
    NodeData(labels=["Person"], properties={"name": "Alice", "age": 30}),
    NodeData(labels=["Person"], properties={"name": "Bob", "age": 25}),
    # Custom _id via the id field
    NodeData(id="p3", labels=["Person"], properties={"name": "Charlie"}),
]
client.insert_nodes(nodes)

edges = [
    EdgeData(label="Knows", from_node_id="id1", to_node_id="id2", properties={"since": 2024}),
    # Custom _id (requires graph created WITH EDGE_ID)
    EdgeData(id="tx-001", label="Knows", from_node_id="id1", to_node_id="id3", properties={"since": 2025}),
]
client.insert_edges(edges)
```

> GQL `INSERT` only supports a single label per node; if `NodeData.labels` has multiple entries, only the first is used in the GQL path. Use the gRPC path for multi-label nodes.

## Per-call Configuration (InsertConfig)

The GQL-path `insert_nodes(nodes, …)` / `insert_edges(edges, …)` accept an optional `InsertConfig` for per-call graph routing and insert mode, without changing session state:

```python
from gqldb import InsertConfig, InsertType

# Target a specific graph without use_graph()
cfg = InsertConfig(
    graph_name="myGraph",
    insert_type=InsertType.OVERWRITE,   # NORMAL (default), OVERWRITE, or UPSERT
    timeout=60,                         # optional per-call timeout (seconds)
)
client.insert_nodes(nodes, cfg)
client.insert_edges(edges, cfg)
```

### InsertType semantics

| Value | Emitted GQL | On duplicate `_id` |
|---|---|---|
| `NORMAL` (default) | `INSERT` | Error |
| `OVERWRITE` | `INSERT OVERWRITE` | Replaces the entity wholesale — properties not in the write are **lost** |
| `UPSERT` | `UPSERT` | Merges properties — properties not in the write are **preserved** |

`OVERWRITE` and `UPSERT` are different semantics on existing rows; they are not interchangeable.

All other convenience methods accept `QueryConfig` the same way:

```python
from gqldb import QueryConfig

client.create_node_label("User", props, config=QueryConfig(graph_name="graphA"))
client.show_node_labels(config=QueryConfig(graph_name="graphB"))
client.gql("MATCH (n) RETURN n", config=QueryConfig(graph_name="graphC", timeout=10))
```

Passing a per-call config is thread-safe: multiple threads can target different graphs via their own config objects without interfering.

## Deleting Nodes

### delete_nodes()

Delete nodes from the graph:

```python
# Delete by IDs
result = client.delete_nodes(
    "myGraph",
    node_ids=["u1", "u2", "u3"]
)
print(f"Deleted: {result.deleted_count} nodes")

# Delete by labels
result = client.delete_nodes(
    "myGraph",
    labels=["TempUser"]
)

# Delete with WHERE clause
result = client.delete_nodes(
    "myGraph",
    labels=["User"],
    where="n.age < 18"
)

# Combine filters
result = client.delete_nodes(
    "myGraph",
    node_ids=["u1", "u2"],
    labels=["User"],
    where="n.status = 'inactive'"
)
```

## Deleting Edges

### delete_edges()

Delete edges from the graph:

```python
# Delete by IDs
result = client.delete_edges(
    "myGraph",
    edge_ids=["e1", "e2"]
)
print(f"Deleted: {result.deleted_count} edges")

# Delete by label
result = client.delete_edges(
    "myGraph",
    label="TempConnection"
)

# Delete with WHERE clause
result = client.delete_edges(
    "myGraph",
    label="Follows",
    where="e.since < '2020-01-01'"
)
```

## Using GQL for Data Operations

You can also use GQL queries for data operations:

```python
# Insert with GQL
client.gql("""
    INSERT (a:User {_id: 'u1', name: 'Alice'}),
           (b:User {_id: 'u2', name: 'Bob'}),
           (a)-[:Follows {since: '2024-01-01'}]->(b)
""")

# Update with GQL
client.gql("MATCH (u:User {_id: 'u1'}) SET u.age = 31")

# Delete with GQL
client.gql("MATCH (u:User {_id: 'u1'}) DELETE u")
```

## Result Classes

### InsertNodesResult

```python
@dataclass
class InsertNodesResult:
    success: bool
    node_ids: List[str]
    node_count: int
    message: str
```

### InsertEdgesResult

```python
@dataclass
class InsertEdgesResult:
    success: bool
    edge_ids: List[str]
    edge_count: int
    message: str
    skipped_count: int
```

### DeleteResult

```python
@dataclass
class DeleteResult:
    success: bool
    deleted_count: int
    message: str
```

## Error Handling

```python
from gqldb.errors import (
    GqldbError,
    InsertFailedError,
    DeleteFailedError,
    GraphNotFoundError
)

try:
    result = client.insert_nodes("myGraph", nodes)
    if not result.success:
        print(f"Insert warning: {result.message}")

except InsertFailedError as e:
    print(f"Insert failed: {e}")

except DeleteFailedError as e:
    print(f"Delete failed: {e}")

except GraphNotFoundError:
    print("Graph not found")

except GqldbError as e:
    print(f"GQLDB error: {e}")
```

## Complete Example

```python
from gqldb import GqldbClient, GqldbConfig, NodeData, EdgeData
from gqldb.types import BulkCreateNodesOptions, BulkCreateEdgesOptions
from gqldb.errors import GqldbError

def main():
    config = GqldbConfig(
        hosts=["localhost:9000"],
        timeout=30
    )

    with GqldbClient(config) as client:
        client.login("admin", "password")
        client.create_graph("dataOpsDemo")
        client.use_graph("dataOpsDemo")

        # Insert nodes
        print("=== Inserting Nodes ===")
        users = [
            NodeData(labels=["User"], properties={"name": "Alice", "age": 30, "active": True}),
            NodeData(labels=["User"], properties={"name": "Bob", "age": 25, "active": True}),
            NodeData(labels=["User"], properties={"name": "Charlie", "age": 35, "active": False}),
            NodeData(labels=["User", "Admin"], properties={"name": "Diana", "age": 28, "active": True}),
        ]

        options = BulkCreateNodesOptions(overwrite=True)
        result = client.insert_nodes("dataOpsDemo", users, options)
        print(f"  Inserted {result.node_count} users")

        # Insert edges
        print("\n=== Inserting Edges ===")
        relationships = [
            EdgeData(label="Follows", from_node_id="u1", to_node_id="u2", properties={"since": "2023-01"}),
            EdgeData(label="Follows", from_node_id="u2", to_node_id="u3", properties={"since": "2023-03"}),
            EdgeData(label="Follows", from_node_id="u1", to_node_id="u4", properties={"since": "2023-06"}),
            EdgeData(label="Knows", from_node_id="u3", to_node_id="u4", properties={"years": 3}),
        ]

        edge_options = BulkCreateEdgesOptions(skip_invalid_nodes=True)
        result = client.insert_edges("dataOpsDemo", relationships, edge_options)
        print(f"  Inserted {result.edge_count} relationships")

        # Verify data
        print("\n=== Current Data ===")
        response = client.gql("MATCH (n:User) RETURN n.name, n.age, n.active ORDER BY n.name")
        for row in response:
            print(f"  {row.get_string(0)}: age={row.get_int(1)}, active={row.get_bool(2)}")

        response = client.gql("MATCH ()-[e]->() RETURN type(e), count(e)")
        for row in response:
            print(f"  {row.get_string(0)}: {row.get_int(1)} edges")

        # Update with overwrite
        print("\n=== Overwrite (Update Existing) ===")
        updated_users = [
            NodeData(labels=["User"], properties={"name": "Alice", "age": 31, "active": True}),  # Update age
            NodeData(labels=["User"], properties={"name": "Eve", "age": 22, "active": True}),    # New user
        ]

        result = client.insert_nodes("dataOpsDemo", updated_users, BulkCreateNodesOptions(overwrite=True))
        print(f"  Upserted {result.node_count} users")

        # Delete inactive users
        print("\n=== Delete Inactive Users ===")
        result = client.delete_nodes(
            "dataOpsDemo",
            labels=["User"],
            where="n.active = false"
        )
        print(f"  Deleted {result.deleted_count} inactive users")

        # Delete specific edges
        print("\n=== Delete Old Relationships ===")
        result = client.delete_edges(
            "dataOpsDemo",
            label="Follows",
            where="e.since < '2023-04'"
        )
        print(f"  Deleted {result.deleted_count} old relationships")

        # Final state
        print("\n=== Final Data ===")
        response = client.gql("MATCH (n:User) RETURN n.name ORDER BY n.name")
        names = [row.get_string(0) for row in response]
        print(f"  Users: {names}")

        response = client.gql("MATCH ()-[e]->() RETURN count(e)")
        print(f"  Edges: {response.single_int()}")

        # Cleanup
        client.drop_graph("dataOpsDemo")

if __name__ == "__main__":
    main()
```
