# Graph Management

The GQLDB Python driver provides methods for creating, managing, and querying graph metadata.

## Graph Methods

| Method | Description |
|--------|-------------|
| `create_graph(name, graph_type, description)` | Create a new graph |
| `drop_graph(name, if_exists)` | Delete a graph |
| `use_graph(name)` | Set the current graph for the session |
| `list_graphs()` | List all available graphs |
| `get_graph_info(name)` | Get information about a specific graph |
| `create_open_graph(name)` | Create a schema-less graph |
| `create_closed_graph(name)` | Create a schema-enforced graph |
| `create_graph_if_not_exist(name, graph_type, description)` | Create graph only if it doesn't exist |
| `has_graph(name)` | Check if a graph exists |
| `alter_graph(graph_name, new_name)` | Rename a graph |
| `truncate(graph_name)` | Remove all data from a graph |

## Creating Graphs

### create_graph()

Create a new graph:

```python
from gqldb import GqldbClient, GqldbConfig
from gqldb.types import GraphType

config = GqldbConfig(hosts=["localhost:9000"])

with GqldbClient(config) as client:
    client.login("admin", "password")

    # Create a basic graph (schema-less)
    client.create_graph("myGraph")

    # Create with specific type
    client.create_graph("schemaGraph", GraphType.CLOSED)

    # Create with description
    client.create_graph(
        "socialNetwork",
        GraphType.OPEN,
        "Social network for user connections"
    )
```

### GraphType Enum

```python
from gqldb.types import GraphType

GraphType.OPEN      # Schema-less graph (default)
GraphType.CLOSED    # Schema-enforced graph
GraphType.ONTOLOGY  # Ontology-enabled graph
```

## Dropping Graphs

### drop_graph()

Delete a graph:

```python
# Drop a graph (raises error if not found)
client.drop_graph("myGraph")

# Drop with if_exists (no error if not found)
client.drop_graph("myGraph", if_exists=True)
```

## Setting Current Graph

### use_graph()

Set the current graph for the session:

```python
client.use_graph("myGraph")

# Now queries use myGraph by default
response = client.gql("MATCH (n) RETURN count(n)")
```

## Listing Graphs

### list_graphs()

Get all available graphs:

```python
graphs = client.list_graphs()

for graph in graphs:
    print(f"Name: {graph.name}")
    print(f"  Type: {graph.graph_type}")
    print(f"  Description: {graph.description}")
    print(f"  Node count: {graph.node_count}")
    print(f"  Edge count: {graph.edge_count}")
    print()
```

### GraphInfo Class

```python
from dataclasses import dataclass
from gqldb.types import GraphType

@dataclass
class GraphInfo:
    name: str
    graph_type: GraphType
    node_count: int
    edge_count: int
    description: str
```

## Getting Graph Information

### get_graph_info()

Get detailed information about a specific graph:

```python
from gqldb.errors import GraphNotFoundError

try:
    info = client.get_graph_info("myGraph")
    print(f"Graph: {info.name}")
    print(f"Type: {info.graph_type}")
    print(f"Nodes: {info.node_count}")
    print(f"Edges: {info.edge_count}")
    print(f"Description: {info.description}")
except GraphNotFoundError:
    print("Graph not found")
```

## Convenience Methods

### create_open_graph() / create_closed_graph()

Shorthand methods for creating graphs with a specific type:

```python
client.create_open_graph("flexGraph")
client.create_closed_graph("strictGraph")
```

### create_graph_if_not_exist()

Create a graph only if it doesn't already exist:

```python
created = client.create_graph_if_not_exist("myGraph", GraphType.OPEN, "My graph")
# True = created, False = already existed
```

### has_graph()

Check whether a graph exists:

```python
if client.has_graph("myGraph"):
    print("Graph exists")
```

### alter_graph()

Rename a graph:

```python
client.alter_graph("oldName", "newName")
```

### truncate()

Remove all data from a graph while keeping the graph itself:

```python
client.truncate("myGraph")
```

## Error Handling

```python
from gqldb.errors import (
    GqldbError,
    GraphNotFoundError,
    CreateGraphFailedError,
    DropGraphFailedError
)

# Handle graph already exists. Note: create_graph raises the base
# GqldbError on a duplicate name (there is no dedicated GraphExistsError
# for this path), so catch GqldbError.
try:
    client.create_graph("existingGraph")
except GqldbError:
    print("Graph already exists (or creation failed)")

# Handle graph not found (get_graph_info DOES raise GraphNotFoundError)
try:
    client.get_graph_info("nonExistentGraph")
except GraphNotFoundError:
    print("Graph not found")

# Safe graph creation — prefer the built-in helpers over try/except:
if not client.has_graph("myGraph"):
    client.create_graph("myGraph")
# ...or:
client.create_graph_if_not_exist("myGraph")

client.use_graph("myGraph")
```

## Ensure Graph Exists Pattern

```python
from gqldb.errors import GqldbError, GraphNotFoundError

def ensure_graph(client, name, graph_type=None, description=""):
    """Ensure a graph exists, creating it if necessary."""
    try:
        info = client.get_graph_info(name)
        print(f"Graph '{name}' exists with {info.node_count} nodes")
        return info
    except GraphNotFoundError:
        try:
            client.create_graph(name, graph_type, description)
            print(f"Created graph '{name}'")
            return client.get_graph_info(name)
        except GqldbError:
            # Race condition: another process created it (create_graph
            # raises the base GqldbError, not a dedicated exists error)
            return client.get_graph_info(name)

# Usage
graph_info = ensure_graph(client, "myGraph", GraphType.OPEN, "My application graph")
client.use_graph("myGraph")
```

## Working with Multiple Graphs

```python
from gqldb import GqldbClient, GqldbConfig
from gqldb.client import QueryConfig

config = GqldbConfig(hosts=["localhost:9000"])

with GqldbClient(config) as client:
    client.login("admin", "password")

    # Create multiple graphs
    client.create_graph("users")
    client.create_graph("products")
    client.create_graph("orders")

    # Query specific graph without switching
    users_config = QueryConfig(graph_name="users")
    products_config = QueryConfig(graph_name="products")

    users = client.gql("MATCH (u:User) RETURN u", users_config)
    products = client.gql("MATCH (p:Product) RETURN p", products_config)

    # Or switch between graphs
    client.use_graph("users")
    # ... work with users

    client.use_graph("orders")
    # ... work with orders
```

## Complete Example

```python
from gqldb import GqldbClient, GqldbConfig
from gqldb.types import GraphType
from gqldb.errors import GqldbError, GraphNotFoundError

def main():
    config = GqldbConfig(
        hosts=["localhost:9000"],
        timeout=30
    )

    with GqldbClient(config) as client:
        client.login("admin", "password")

        # List existing graphs
        print("=== Existing Graphs ===")
        for graph in client.list_graphs():
            print(f"  {graph.name} ({graph.graph_type.name})")

        # Create graphs
        print("\n=== Creating Graphs ===")
        graphs_to_create = [
            ("socialNetwork", GraphType.OPEN, "Social connections"),
            ("productCatalog", GraphType.CLOSED, "Product information"),
            ("knowledgeBase", GraphType.ONTOLOGY, "Knowledge graph")
        ]

        for name, gtype, desc in graphs_to_create:
            try:
                client.create_graph(name, gtype, desc)
                print(f"  Created: {name}")
            except GqldbError:
                print(f"  Exists: {name}")

        # Get detailed info
        print("\n=== Graph Details ===")
        for name, _, _ in graphs_to_create:
            try:
                info = client.get_graph_info(name)
                print(f"  {info.name}:")
                print(f"    Type: {info.graph_type.name}")
                print(f"    Description: {info.description}")
                print(f"    Nodes: {info.node_count}")
                print(f"    Edges: {info.edge_count}")
            except GraphNotFoundError:
                print(f"  {name}: Not found")

        # Work with a graph
        print("\n=== Working with socialNetwork ===")
        client.use_graph("socialNetwork")

        # Insert data
        client.gql("""
            INSERT (a:User {_id: 'u1', name: 'Alice'}),
                   (b:User {_id: 'u2', name: 'Bob'}),
                   (a)-[:Follows]->(b)
        """)

        # Check updated counts
        info = client.get_graph_info("socialNetwork")
        print(f"  After insert: {info.node_count} nodes, {info.edge_count} edges")

        # Clean up
        print("\n=== Cleanup ===")
        for name, _, _ in graphs_to_create:
            client.drop_graph(name, if_exists=True)
            print(f"  Dropped: {name}")

        # Verify
        print("\n=== Final Graph List ===")
        remaining = [g.name for g in client.list_graphs()]
        print(f"  Remaining graphs: {remaining}")

if __name__ == "__main__":
    main()
```
