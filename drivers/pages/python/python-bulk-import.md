# Bulk Import

The GQLDB Python driver provides bulk import functionality for high-throughput data ingestion with optimized write performance.

## Bulk Import Methods

| Method | Description |
|--------|-------------|
| `start_bulk_import(...)` | Start a bulk import session |
| `end_bulk_import(session_id)` | End the bulk import session |
| `abort_bulk_import(session_id)` | Cancel session without final sync |
| `get_bulk_import_status(session_id)` | Get session status |

## Basic Usage

```python
from gqldb import GqldbClient, GqldbConfig
from gqldb.types import NodeData, EdgeData

config = GqldbConfig(hosts=["localhost:9000"])

with GqldbClient(config) as client:
    client.login("admin", "password")
    client.use_graph("myGraph")

    # Start bulk import session
    session = client.start_bulk_import(
        graph_name="myGraph"
    )

    print(f"Session ID: {session.session_id}")

    try:
        # Insert nodes in batches
        for batch in node_batches:
            client.insert_nodes("myGraph", batch, bulk_import_session_id=session.session_id)

        # Insert edges in batches
        for batch in edge_batches:
            client.insert_edges("myGraph", batch, bulk_import_session_id=session.session_id)

        # End session
        result = client.end_bulk_import(session.session_id)
        print(f"Import complete: {result.total_records} records, {result.message}")

    except Exception as e:
        # Abort on error
        client.abort_bulk_import(session.session_id)
        raise
```

## Starting a Bulk Import Session

### start_bulk_import()

```python
session = client.start_bulk_import(
    graph_name="myGraph",
    estimated_nodes=1000000,    # Hint for pre-allocating node ID cache
    estimated_edges=5000000,    # Hint for edge batch sizing
    memtable_size=67108864,     # Memtable size in bytes (default: 64MB)
    max_memtables=4             # Max immutable memtables before stall
)
```

### BulkImportSession Class

```python
@dataclass
class BulkImportSession:
    success: bool
    session_id: str
    message: str
```

## Ending a Bulk Import

### end_bulk_import()

Complete the bulk import session:

```python
result = client.end_bulk_import(session.session_id)

print(f"Bulk import completed:")
print(f"  Success: {result.success}")
print(f"  Total records: {result.total_records}")
print(f"  Message: {result.message}")
```

### abort_bulk_import()

Cancel without final sync (discards unflushed data):

```python
result = client.abort_bulk_import(session.session_id)
print(f"Bulk import aborted: {result.message}")
```

## Monitoring Status

### get_bulk_import_status()

```python
status = client.get_bulk_import_status(session.session_id)

print(f"Active: {status.is_active}")
print(f"Graph: {status.graph_name}")
print(f"Records: {status.record_count}")
print(f"Last checkpoint count: {status.last_checkpoint_count}")
print(f"Created at: {status.created_at}")
print(f"Last activity: {status.last_activity}")
```

## Batch Processing Pattern

```python
from gqldb.types import NodeData, EdgeData

def batch_generator(items, batch_size):
    """Yield items in batches."""
    for i in range(0, len(items), batch_size):
        yield items[i:i + batch_size]

def bulk_import_data(client, graph_name, nodes, edges, batch_size=5000):
    """Import large amounts of data efficiently."""
    session = client.start_bulk_import(
        graph_name=graph_name
    )

    try:
        # Import nodes
        total_nodes = 0
        for batch in batch_generator(nodes, batch_size):
            result = client.insert_nodes(
                graph_name, batch,
                bulk_import_session_id=session.session_id
            )
            total_nodes += result.node_count
            print(f"Imported {total_nodes} nodes...")

        # Import edges
        total_edges = 0
        for batch in batch_generator(edges, batch_size):
            result = client.insert_edges(
                graph_name, batch,
                bulk_import_session_id=session.session_id
            )
            total_edges += result.edge_count
            print(f"Imported {total_edges} edges...")

        # Complete
        result = client.end_bulk_import(session.session_id)
        return result

    except Exception as e:
        client.abort_bulk_import(session.session_id)
        raise
```

## Result Classes

### EndBulkImportResult

```python
@dataclass
class EndBulkImportResult:
    success: bool
    total_records: int
    message: str
```

### AbortBulkImportResult

```python
@dataclass
class AbortBulkImportResult:
    success: bool
    message: str
```

### BulkImportStatus

```python
@dataclass
class BulkImportStatus:
    is_active: bool
    graph_name: str
    record_count: int
    last_checkpoint_count: int
    created_at: str
    last_activity: str
```

## Error Handling

```python
from gqldb.errors import GqldbError

try:
    session = client.start_bulk_import("myGraph")

    # Do imports...

    result = client.end_bulk_import(session.session_id)

except GqldbError as e:
    print(f"Bulk import error: {e}")
    # Try to abort if session exists
    try:
        client.abort_bulk_import(session.session_id)
    except Exception:
        pass
    raise
```

## Complete Example

```python
from gqldb import GqldbClient, GqldbConfig
from gqldb.types import NodeData, EdgeData
from gqldb.errors import GqldbError
import time

def generate_test_data(num_nodes, num_edges):
    """Generate test nodes and edges."""
    nodes = [
        NodeData(
            labels=["TestNode"],
            properties={"index": i, "value": f"value_{i}"}
        )
        for i in range(num_nodes)
    ]

    edges = [
        EdgeData(
            label="TestEdge",
            from_node_id=f"n{i % num_nodes}",
            to_node_id=f"n{(i + 1) % num_nodes}",
            properties={"weight": i * 0.1}
        )
        for i in range(num_edges)
    ]

    return nodes, edges

def main():
    config = GqldbConfig(
        hosts=["localhost:9000"],
        timeout=300  # 5 minute timeout for bulk operations
    )

    with GqldbClient(config) as client:
        client.login("admin", "password")
        client.create_graph("bulkDemo")
        client.use_graph("bulkDemo")

        # Generate test data
        print("=== Generating Test Data ===")
        num_nodes = 100000
        num_edges = 500000
        nodes, edges = generate_test_data(num_nodes, num_edges)
        print(f"  Generated {len(nodes)} nodes and {len(edges)} edges")

        # Start bulk import
        print("\n=== Starting Bulk Import ===")
        start_time = time.time()

        session = client.start_bulk_import(
            graph_name="bulkDemo",
            estimated_nodes=num_nodes,
            estimated_edges=num_edges
        )
        print(f"  Session ID: {session.session_id}")

        try:
            # Import nodes in batches
            print("\n=== Importing Nodes ===")
            batch_size = 10000
            imported_nodes = 0

            for i in range(0, len(nodes), batch_size):
                batch = nodes[i:i + batch_size]
                result = client.insert_nodes(
                    "bulkDemo", batch,
                    bulk_import_session_id=session.session_id
                )
                imported_nodes += result.node_count

                # Check status periodically
                if imported_nodes % 50000 == 0:
                    status = client.get_bulk_import_status(session.session_id)
                    print(f"  Progress: {imported_nodes} nodes, records: {status.record_count}")

            print(f"  Total nodes imported: {imported_nodes}")

            # Import edges in batches
            print("\n=== Importing Edges ===")
            imported_edges = 0

            for i in range(0, len(edges), batch_size):
                batch = edges[i:i + batch_size]
                result = client.insert_edges(
                    "bulkDemo", batch,
                    bulk_import_session_id=session.session_id
                )
                imported_edges += result.edge_count

                if imported_edges % 100000 == 0:
                    print(f"  Progress: {imported_edges} edges")

            print(f"  Total edges imported: {imported_edges}")

            # End bulk import
            print("\n=== Completing Bulk Import ===")
            end_result = client.end_bulk_import(session.session_id)

            elapsed = time.time() - start_time
            print(f"  Completed in {elapsed:.2f} seconds")
            print(f"  Success: {end_result.success}")
            print(f"  Total records: {end_result.total_records}")
            print(f"  Message: {end_result.message}")

            # Verify
            print("\n=== Verification ===")
            response = client.gql("MATCH (n:TestNode) RETURN count(n)")
            print(f"  Node count: {response.single_int()}")

            response = client.gql("MATCH ()-[e:TestEdge]->() RETURN count(e)")
            print(f"  Edge count: {response.single_int()}")

        except Exception as e:
            print(f"\nError: {e}")
            print("Aborting bulk import...")
            client.abort_bulk_import(session.session_id)
            raise

        finally:
            # Cleanup
            client.drop_graph("bulkDemo")

if __name__ == "__main__":
    main()
```
