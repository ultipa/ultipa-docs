# Data Export

The GQLDB Python driver provides streaming export capabilities for efficiently extracting large amounts of data from the database.

## Export Methods

| Method | Description |
|--------|-------------|
| `export(config, callback)` | Export graph data with full configuration |
| `export_nodes(graph_name, labels, limit, callback)` | Export nodes (deprecated) |
| `export_edges(graph_name, labels, limit, callback)` | Export edges (deprecated) |

## Unified Export

### export()

Export nodes and/or edges in JSON Lines format with streaming:

```python
from gqldb import GqldbClient, GqldbConfig
from gqldb.response import ExportConfig

config = GqldbConfig(hosts=["192.168.1.100:9000"])

with GqldbClient(config) as client:
    client.login("admin", "password")

    export_config = ExportConfig(
        graph_name="myGraph",
        batch_size=1000,
        export_nodes=True,
        export_edges=True
    )

    def process_chunk(chunk):
        data = chunk.get_data_as_string()
        lines = data.strip().split('\n')

        for line in lines:
            if line:
                print(line)

        if chunk.is_final and chunk.has_stats():
            stats = chunk.stats
            print(f"\nExport complete:")
            print(f"  Nodes: {stats.nodes_exported}")
            print(f"  Edges: {stats.edges_exported}")
            print(f"  Bytes: {stats.bytes_written}")
            print(f"  Duration: {stats.duration_ms}ms")

    client.export(export_config, process_chunk)
```

### ExportConfig Class

```python
from dataclasses import dataclass
from typing import List

@dataclass
class ExportConfig:
    graph_name: str = ""           # Target graph
    batch_size: int = 0            # Records per chunk
    export_nodes: bool = True      # Include nodes
    export_edges: bool = True      # Include edges
    node_labels: List[str] = None  # Filter by node labels
    edge_labels: List[str] = None  # Filter by edge labels
    include_metadata: bool = False # Include metadata in output
```

### ExportChunk Class

```python
@dataclass
class ExportChunk:
    data: bytes                    # JSON Lines data
    is_final: bool                 # Is this the last chunk?
    stats: Optional[ExportStats]   # Statistics (on final chunk)

    def get_data_as_string(self) -> str: ...
    def has_stats(self) -> bool: ...
```

### ExportStats Class

```python
@dataclass
class ExportStats:
    nodes_exported: int
    edges_exported: int
    bytes_written: int
    duration_ms: int
```

## Filtering Exports

### Export Specific Labels

```python
from gqldb.response import ExportConfig

# Export only User nodes and Follows edges
export_config = ExportConfig(
    graph_name="socialGraph",
    export_nodes=True,
    export_edges=True,
    node_labels=["User", "Company"],
    edge_labels=["Follows", "WorksAt"]
)

client.export(export_config, process_chunk)
```

### Export Only Nodes

```python
export_config = ExportConfig(
    graph_name="myGraph",
    export_nodes=True,
    export_edges=False
)

client.export(export_config, process_chunk)
```

### Export Only Edges

```python
export_config = ExportConfig(
    graph_name="myGraph",
    export_nodes=False,
    export_edges=True
)

client.export(export_config, process_chunk)
```

## Writing to File

```python
from gqldb.response import ExportConfig

def export_to_file(client, graph_name, output_path):
    """Export graph data to a JSON Lines file."""
    export_config = ExportConfig(
        graph_name=graph_name,
        batch_size=5000,
        export_nodes=True,
        export_edges=True
    )

    with open(output_path, 'wb') as f:
        def write_chunk(chunk):
            f.write(chunk.data)

            if chunk.is_final:
                f.flush()
                if chunk.has_stats():
                    print(f"Export complete: {chunk.stats.nodes_exported} nodes, "
                          f"{chunk.stats.edges_exported} edges")

        client.export(export_config, write_chunk)

# Usage
export_to_file(client, "myGraph", "export.jsonl")
```

## Collecting to Memory

```python
import json
from gqldb.response import ExportConfig

def export_to_memory(client, graph_name):
    """Export graph data to memory."""
    nodes = []
    edges = []

    export_config = ExportConfig(
        graph_name=graph_name,
        batch_size=1000
    )

    def collect_data(chunk):
        data = chunk.get_data_as_string()
        for line in data.strip().split('\n'):
            if not line:
                continue
            record = json.loads(line)
            if record.get('_type') == 'node':
                nodes.append(record)
            elif record.get('_type') == 'edge':
                edges.append(record)

    client.export(export_config, collect_data)

    print(f"Collected {len(nodes)} nodes and {len(edges)} edges")
    return {'nodes': nodes, 'edges': edges}

# Usage
data = export_to_memory(client, "myGraph")
```

## Legacy Export Methods

These methods are deprecated but still available:

### export_nodes()

```python
def process_nodes(result):
    for node in result.nodes:
        print(f"Node: {node.id}, Labels: {node.labels}")
    if result.has_more:
        print("More nodes available...")

client.export_nodes(
    "myGraph",
    labels=["User"],
    limit=1000,
    callback=process_nodes
)
```

### export_edges()

```python
def process_edges(result):
    for edge in result.edges:
        print(f"Edge: {edge.id}, {edge.from_node_id} -> {edge.to_node_id}")
    if result.has_more:
        print("More edges available...")

client.export_edges(
    "myGraph",
    labels=["Follows"],
    limit=1000,
    callback=process_edges
)
```

## Complete Example

```python
from gqldb import GqldbClient, GqldbConfig
from gqldb.response import ExportConfig
from gqldb.errors import GqldbError
import json
import os

def main():
    config = GqldbConfig(
        hosts=["192.168.1.100:9000"],
        timeout=60
    )

    with GqldbClient(config) as client:
        client.login("admin", "password")

        # Create and populate test graph
        client.create_graph("exportDemo")
        client.use_graph("exportDemo")

        # Insert test data
        client.gql("""
            INSERT (a:User {_id: 'u1', name: 'Alice', age: 30}),
                   (b:User {_id: 'u2', name: 'Bob', age: 25}),
                   (c:Company {_id: 'c1', name: 'Acme Inc'}),
                   (a)-[:Follows {since: '2023-01-01'}]->(b),
                   (a)-[:WorksAt {role: 'Engineer'}]->(c)
        """)

        # Export to file
        print("=== Export to File ===")
        output_path = "graph-export.jsonl"

        export_config = ExportConfig(
            graph_name="exportDemo",
            batch_size=100,
            export_nodes=True,
            export_edges=True,
            include_metadata=True
        )

        total_records = [0]

        with open(output_path, 'wb') as f:
            def write_and_count(chunk):
                f.write(chunk.data)
                data = chunk.get_data_as_string()
                count = len([l for l in data.strip().split('\n') if l])
                total_records[0] += count

                if chunk.is_final:
                    f.flush()
                    print(f"  Records exported: {total_records[0]}")
                    if chunk.has_stats():
                        stats = chunk.stats
                        print(f"  Nodes: {stats.nodes_exported}")
                        print(f"  Edges: {stats.edges_exported}")
                        print(f"  Size: {stats.bytes_written} bytes")

            client.export(export_config, write_and_count)

        # Read and display the file
        print("\n=== Exported Data ===")
        with open(output_path, 'r') as f:
            for line in f:
                record = json.loads(line)
                print(f"  {json.dumps(record)}")

        # Export filtered data
        print("\n=== Export Only Users ===")
        filtered_config = ExportConfig(
            graph_name="exportDemo",
            export_nodes=True,
            export_edges=False,
            node_labels=["User"]
        )

        def print_users(chunk):
            for line in chunk.get_data_as_string().strip().split('\n'):
                if line:
                    record = json.loads(line)
                    print(f"  User: {record.get('properties', {}).get('name')}")

        client.export(filtered_config, print_users)

        # Export to memory
        print("\n=== Export to Memory ===")
        nodes = []
        edges = []

        memory_config = ExportConfig(
            graph_name="exportDemo",
            batch_size=1000
        )

        def collect(chunk):
            for line in chunk.get_data_as_string().strip().split('\n'):
                if not line:
                    continue
                record = json.loads(line)
                if record.get('_type') == 'node':
                    nodes.append(record)
                elif record.get('_type') == 'edge':
                    edges.append(record)

        client.export(memory_config, collect)
        print(f"  Collected: {len(nodes)} nodes, {len(edges)} edges")

        # Cleanup
        os.remove(output_path)
        client.drop_graph("exportDemo")

if __name__ == "__main__":
    main()
```
