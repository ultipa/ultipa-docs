# Transactions

The GQLDB Python driver supports ACID transactions for ensuring data consistency across multiple operations.

## Transaction Methods

| Method | Description |
|--------|-------------|
| `begin_transaction(graph_name, read_only, timeout)` | Start a new transaction |
| `commit(transaction_id)` | Commit a transaction |
| `rollback(transaction_id)` | Rollback a transaction |
| `list_transactions()` | List active transactions |
| `with_transaction(graph_name, fn, read_only, timeout)` | Execute function in transaction |

## Basic Transaction Usage

### Manual Transaction Management

```python
from gqldb import GqldbClient, GqldbConfig

config = GqldbConfig(hosts=["192.168.1.100:9000"])

with GqldbClient(config) as client:
    client.login("admin", "password")
    client.use_graph("myGraph")

    # Begin transaction
    tx = client.begin_transaction("myGraph")
    print(f"Transaction ID: {tx.id}")

    try:
        # Execute queries within transaction
        from gqldb.client import QueryConfig
        tx_config = QueryConfig(transaction_id=tx.id)

        client.gql("INSERT (n:Person {_id: 'p1', name: 'Alice'})", tx_config)
        client.gql("INSERT (n:Person {_id: 'p2', name: 'Bob'})", tx_config)

        # Commit the transaction
        client.commit(tx.id)
        print("Transaction committed")

    except Exception as e:
        # Rollback on error
        client.rollback(tx.id)
        print(f"Transaction rolled back: {e}")
        raise
```

### Using with_transaction()

The `with_transaction()` method provides automatic commit/rollback:

```python
def transfer_funds(tx_id: int):
    """Transfer funds between accounts."""
    from gqldb.client import QueryConfig
    config = QueryConfig(transaction_id=tx_id)

    # Debit from source
    client.gql(
        "MATCH (a:Account {_id: 'acc1'}) SET a.balance = a.balance - 100",
        config
    )

    # Credit to destination
    client.gql(
        "MATCH (a:Account {_id: 'acc2'}) SET a.balance = a.balance + 100",
        config
    )

# Execute with automatic commit/rollback
client.with_transaction("myGraph", transfer_funds)
```

## Transaction Class

```python
from dataclasses import dataclass

@dataclass
class Transaction:
    id: int                    # Transaction ID
    session_id: int           # Session ID
    graph_name: str           # Graph name
    read_only: bool           # Is read-only
    created_at: float         # Creation timestamp
    timeout: float            # Timeout in seconds

    @property
    def is_committed(self) -> bool: ...
    @property
    def is_rolled_back(self) -> bool: ...
    @property
    def is_active(self) -> bool: ...
    def age(self) -> float: ...
    def is_expired(self) -> bool: ...
```

## Read-Only Transactions

For queries that only read data:

```python
# Begin read-only transaction
tx = client.begin_transaction("myGraph", read_only=True)

try:
    from gqldb.client import QueryConfig
    config = QueryConfig(transaction_id=tx.id)

    # Execute read queries
    response = client.gql("MATCH (n) RETURN count(n)", config)
    print(f"Count: {response.single_int()}")

    # Commit (or rollback - same effect for read-only)
    client.commit(tx.id)
except Exception:
    client.rollback(tx.id)
    raise
```

## Transaction Timeout

Set a timeout for transactions:

```python
# 60 second timeout
tx = client.begin_transaction("myGraph", timeout=60)

# Using with_transaction with timeout
client.with_transaction(
    "myGraph",
    lambda tx_id: do_work(tx_id),
    timeout=120  # 2 minutes
)
```

## Listing Transactions

```python
# List all active transactions
transactions = client.list_transactions()

for tx_info in transactions:
    print(f"Transaction {tx_info.id}:")
    print(f"  Graph: {tx_info.graph_name}")
    print(f"  Read-only: {tx_info.read_only}")
    print(f"  Created: {tx_info.created_at}")
```

## Transaction Patterns

### Try-Finally Pattern

```python
tx = client.begin_transaction("myGraph")
try:
    # Do work
    from gqldb.client import QueryConfig
    config = QueryConfig(transaction_id=tx.id)
    client.gql("INSERT (n:Test {_id: 't1'})", config)
    client.commit(tx.id)
except Exception:
    client.rollback(tx.id)
    raise
```

### Context Manager Pattern

```python
from contextlib import contextmanager

@contextmanager
def transaction(client, graph_name, read_only=False, timeout=0):
    """Context manager for transactions."""
    tx = client.begin_transaction(graph_name, read_only, timeout)
    try:
        yield tx
        client.commit(tx.id)
    except Exception:
        client.rollback(tx.id)
        raise

# Usage
with transaction(client, "myGraph") as tx:
    from gqldb.client import QueryConfig
    config = QueryConfig(transaction_id=tx.id)
    client.gql("INSERT (n:Test {_id: 't1'})", config)
# Auto-committed on success, rolled back on exception
```

### Retry Pattern

```python
import time
from gqldb.errors import TransactionFailedError

def execute_with_retry(client, graph_name, fn, max_retries=3):
    """Execute a transactional function with retry logic."""
    last_error = None

    for attempt in range(max_retries):
        try:
            client.with_transaction(graph_name, fn)
            return  # Success
        except TransactionFailedError as e:
            last_error = e
            if attempt < max_retries - 1:
                wait_time = 0.1 * (2 ** attempt)  # Exponential backoff
                print(f"Transaction failed, retrying in {wait_time}s...")
                time.sleep(wait_time)

    raise last_error

# Usage
def my_transaction(tx_id):
    from gqldb.client import QueryConfig
    config = QueryConfig(transaction_id=tx_id)
    client.gql("INSERT (n:Test {_id: 't1'})", config)

execute_with_retry(client, "myGraph", my_transaction)
```

## Error Handling

```python
from gqldb.errors import (
    GqldbError,
    TransactionFailedError,
    TransactionNotFoundError,
    NoTransactionError
)

try:
    tx = client.begin_transaction("myGraph")
    # ... do work
    client.commit(tx.id)

except TransactionNotFoundError:
    print("Transaction not found (may have timed out)")

except TransactionFailedError as e:
    print(f"Transaction failed: {e}")

except GqldbError as e:
    print(f"GQLDB error: {e}")
    # Attempt rollback
    try:
        client.rollback(tx.id)
    except Exception:
        pass
```

## Complete Example

```python
from gqldb import GqldbClient, GqldbConfig
from gqldb.client import QueryConfig
from gqldb.errors import GqldbError, TransactionFailedError

def main():
    config = GqldbConfig(
        hosts=["192.168.1.100:9000"],
        timeout=30
    )

    with GqldbClient(config) as client:
        client.login("admin", "password")
        client.create_graph("txDemo")
        client.use_graph("txDemo")

        # Setup: Create initial data
        client.gql("""
            INSERT (acc1:Account {_id: 'acc1', name: 'Alice', balance: 1000}),
                   (acc2:Account {_id: 'acc2', name: 'Bob', balance: 500})
        """)

        print("=== Initial Balances ===")
        response = client.gql("MATCH (a:Account) RETURN a.name, a.balance ORDER BY a.name")
        for row in response:
            print(f"  {row.get_string(0)}: ${row.get_int(1)}")

        # Successful transaction
        print("\n=== Transfer $200 from Alice to Bob ===")

        def transfer(tx_id):
            cfg = QueryConfig(transaction_id=tx_id)
            client.gql("MATCH (a:Account {_id: 'acc1'}) SET a.balance = a.balance - 200", cfg)
            client.gql("MATCH (a:Account {_id: 'acc2'}) SET a.balance = a.balance + 200", cfg)

        client.with_transaction("txDemo", transfer)

        print("Transaction committed")
        response = client.gql("MATCH (a:Account) RETURN a.name, a.balance ORDER BY a.name")
        for row in response:
            print(f"  {row.get_string(0)}: ${row.get_int(1)}")

        # Failed transaction (rollback)
        print("\n=== Attempted Transfer with Error ===")

        def failed_transfer(tx_id):
            cfg = QueryConfig(transaction_id=tx_id)
            client.gql("MATCH (a:Account {_id: 'acc1'}) SET a.balance = a.balance - 100", cfg)
            raise ValueError("Simulated error - rollback!")

        try:
            client.with_transaction("txDemo", failed_transfer)
        except ValueError as e:
            print(f"Error caught: {e}")

        print("After rollback:")
        response = client.gql("MATCH (a:Account) RETURN a.name, a.balance ORDER BY a.name")
        for row in response:
            print(f"  {row.get_string(0)}: ${row.get_int(1)}")

        # Manual transaction management
        print("\n=== Manual Transaction ===")
        tx = client.begin_transaction("txDemo")
        print(f"Started transaction {tx.id}")

        try:
            cfg = QueryConfig(transaction_id=tx.id)
            client.gql("MATCH (a:Account {_id: 'acc1'}) SET a.balance = a.balance - 50", cfg)

            # Check transaction status
            print(f"  Active: {tx.is_active}")
            print(f"  Age: {tx.age():.2f}s")

            client.commit(tx.id)
            print("  Committed")
        except Exception as e:
            client.rollback(tx.id)
            print(f"  Rolled back: {e}")

        # List transactions (should be empty now)
        print("\n=== Active Transactions ===")
        active_txs = client.list_transactions()
        print(f"  Count: {len(active_txs)}")

        # Cleanup
        client.drop_graph("txDemo")

if __name__ == "__main__":
    main()
```
