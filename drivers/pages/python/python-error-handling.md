# Error Handling

The GQLDB Python driver provides a comprehensive set of exception classes for handling different failure scenarios. All exceptions extend the base `GqldbError` class.

## Base Exception Class

```python
from gqldb.errors import GqldbError

class GqldbError(Exception):
    """Base exception for GQLDB errors."""

    def __init__(self, message: str, code: int = 0, cause: Exception | None = None):
        super().__init__(message)
        self.code = code
        self.cause = cause
```

All GQLDB exceptions include:
- `message`: Human-readable error description (via `str(e)` or `args[0]`)
- `code`: Numeric error code
- `cause`: Original exception that caused this error (if applicable)

## Exception Categories

### Configuration Errors

| Exception | Description |
|-----------|-------------|
| `NoHostsError` | No hosts configured in the client |
| `InvalidTimeoutError` | Invalid timeout value specified |

```python
from gqldb import GqldbConfig
from gqldb.errors import NoHostsError

try:
    config = GqldbConfig(hosts=[])  # Empty hosts
    config.validate()
except ValueError as e:
    print("Configuration error: No hosts configured")
```

### Connection Errors

| Exception | Description |
|-----------|-------------|
| `NoConnectionError` | No connection available |
| `ConnectionClosedError` | Connection has been closed |
| `ConnectionFailedError` | Failed to establish connection |
| `AllHostsFailedError` | All configured hosts are unreachable |
| `HealthCheckFailedError` | Health check failed |

```python
from gqldb import GqldbClient, GqldbConfig
from gqldb.errors import ConnectionFailedError, AllHostsFailedError
import time

def connect_with_retry(config: GqldbConfig, max_retries: int = 3) -> GqldbClient:
    """Connect with retry logic."""
    for i in range(max_retries):
        try:
            client = GqldbClient(config)
            client.login("user", "pass")
            return client
        except ConnectionFailedError:
            print(f"Connection attempt {i + 1} failed, retrying...")
            time.sleep(1 * (i + 1))  # Exponential backoff
        except AllHostsFailedError:
            print("All hosts unreachable")
            raise

    raise ConnectionFailedError()
```

### Session Errors

| Exception | Description |
|-----------|-------------|
| `NotLoggedInError` | Operation requires authentication |
| `LoginFailedError` | Login failed (wrong credentials) |
| `LogoutFailedError` | Logout operation failed |
| `SessionExpiredError` | Session has expired |
| `InvalidSessionError` | Invalid session |

```python
from gqldb.errors import NotLoggedInError, SessionExpiredError

def ensure_logged_in(client):
    """Ensure the client is logged in."""
    try:
        client.gql("MATCH (n) RETURN count(n)")
    except (NotLoggedInError, SessionExpiredError):
        print("Session expired, re-authenticating...")
        client.login("user", "pass")
```

### Transaction Errors

| Exception | Description |
|-----------|-------------|
| `NoTransactionError` | No active transaction |
| `TransactionFailedError` | Transaction operation failed |
| `TransactionNotFoundError` | Transaction not found (may have timed out) |
| `TransactionAlreadyOpenError` | Transaction already open |

```python
from gqldb.errors import TransactionFailedError, TransactionNotFoundError

def safe_transaction(client, graph_name, fn):
    """Execute a transaction with error handling."""
    try:
        client.with_transaction(graph_name, fn)
    except TransactionFailedError as e:
        print(f"Transaction failed: {e}")
    except TransactionNotFoundError:
        print("Transaction timed out before completion")
```

### Query Errors

| Exception | Description |
|-----------|-------------|
| `QueryFailedError` | Query execution failed |
| `QueryTimeoutError` | Query timed out |
| `InvalidQueryError` | Invalid query syntax |
| `EmptyQueryError` | Query string is empty |

```python
from gqldb.errors import EmptyQueryError, QueryFailedError, QueryTimeoutError

def execute_query(client, query):
    """Execute a query with error handling."""
    try:
        return client.gql(query)
    except EmptyQueryError:
        print("Query cannot be empty")
    except QueryTimeoutError:
        print("Query timed out")
    except QueryFailedError as e:
        print(f"Query failed: {e}")
    return None
```

### Graph Errors

| Exception | Description |
|-----------|-------------|
| `GraphNotFoundError` | Graph does not exist |
| `GraphExistsError` | Graph already exists |
| `CreateGraphFailedError` | Failed to create graph |
| `DropGraphFailedError` | Failed to drop graph |

```python
from gqldb.errors import GraphNotFoundError, GraphExistsError

def ensure_graph(client, graph_name):
    """Ensure a graph exists."""
    try:
        client.get_graph_info(graph_name)
        print(f"Graph {graph_name} exists")
    except GraphNotFoundError:
        try:
            client.create_graph(graph_name)
            print(f"Created graph {graph_name}")
        except GraphExistsError:
            # Race condition: another process created it
            print(f"Graph {graph_name} was created by another process")
```

### Data Errors

| Exception | Description |
|-----------|-------------|
| `InsertFailedError` | Insert operation failed |
| `DeleteFailedError` | Delete operation failed |
| `ExportFailedError` | Export operation failed |

### Type Errors

| Exception | Description |
|-----------|-------------|
| `InvalidTypeError` | Invalid type |
| `TypeConversionError` | Type conversion failed |
| `UnsupportedTypeError` | Unsupported type |

## Error Handling Patterns

### Comprehensive Try-Except

```python
from gqldb import GqldbClient, GqldbConfig
from gqldb.errors import GqldbError

def handle_all_errors(client):
    """Handle all types of errors."""
    try:
        client.login("user", "pass")
        client.gql("MATCH (n) RETURN n")
    except GqldbError as e:
        # All driver exceptions
        print(f"GQLDB Error [{type(e).__name__}]: {e}")
        if e.cause:
            print(f"Caused by: {e.cause}")
    except Exception as e:
        # Other exceptions
        print(f"Unexpected error: {e}")
```

### Error Recovery with Retry

```python
import time
from gqldb.errors import GqldbError

def with_retry(operation, max_retries=3, retryable_exceptions=None):
    """Execute an operation with retry logic."""
    if retryable_exceptions is None:
        retryable_exceptions = (ConnectionFailedError,)

    last_error = None

    for attempt in range(1, max_retries + 1):
        try:
            return operation()
        except GqldbError as e:
            last_error = e

            is_retryable = isinstance(e, retryable_exceptions)

            if not is_retryable or attempt == max_retries:
                raise

            print(f"Attempt {attempt} failed, retrying...")
            time.sleep(1 * attempt)

    raise last_error

# Usage
from gqldb.errors import ConnectionFailedError

result = with_retry(
    lambda: client.gql("MATCH (n) RETURN n LIMIT 100"),
    max_retries=3,
    retryable_exceptions=(ConnectionFailedError,)
)
```

### Graceful Degradation

```python
from gqldb.errors import QueryFailedError

def get_data_with_fallback(client):
    """Get data with fallback to simpler query."""
    try:
        # Try the main query
        return client.gql("MATCH (n:User) RETURN n")
    except QueryFailedError as e:
        if "timeout" in str(e).lower():
            # Fall back to a simpler query
            print("Full query timed out, using limited query")
            return client.gql("MATCH (n:User) RETURN n LIMIT 100")
        raise
```

### Cleanup on Error

```python
def transaction_with_cleanup(client, graph_name):
    """Execute transaction with guaranteed cleanup."""
    tx = None

    try:
        tx = client.begin_transaction(graph_name)

        from gqldb.client import QueryConfig
        config = QueryConfig(transaction_id=tx.id)

        client.gql("INSERT (n:Test {_id: 't1'})", config)
        client.gql("INSERT (n:Test {_id: 't2'})", config)

        client.commit(tx.id)
        tx = None  # Transaction completed

    finally:
        if tx is not None:
            # Transaction was started but not committed
            try:
                client.rollback(tx.id)
            except Exception as rollback_error:
                print(f"Rollback failed: {rollback_error}")
```

## Complete Example

```python
from gqldb import GqldbClient, GqldbConfig
from gqldb.client import QueryConfig
from gqldb.errors import (
    GqldbError,
    LoginFailedError,
    GraphNotFoundError,
    TransactionFailedError,
    QueryFailedError
)

def main():
    config = GqldbConfig(
        hosts=["localhost:9000"],
        timeout=30
    )

    try:
        with GqldbClient(config) as client:
            # Login with error handling
            try:
                client.login("admin", "password")
                print("Logged in successfully")
            except LoginFailedError:
                print("Invalid credentials")
                return

            # Ensure graph exists
            graph_name = "errorDemo"
            try:
                client.get_graph_info(graph_name)
            except GraphNotFoundError:
                client.create_graph(graph_name)
                print("Created graph")

            client.use_graph(graph_name)

            # Transaction with error handling
            def do_inserts(tx_id):
                cfg = QueryConfig(transaction_id=tx_id)
                client.gql(
                    "INSERT (n:User {_id: 'u1', name: 'Alice'})",
                    cfg
                )
                # Simulate potential error
                import random
                if random.random() < 0.3:
                    raise RuntimeError("Random failure for demo")

            try:
                client.with_transaction(graph_name, do_inserts)
                print("Transaction succeeded")
            except TransactionFailedError:
                print("Transaction failed, changes rolled back")
            except RuntimeError as e:
                print(f"Error during transaction: {e}")

            # Query with timeout handling
            try:
                query_config = QueryConfig(timeout=5)
                response = client.gql("MATCH (n) RETURN n", query_config)
                print(f"Found {response.row_count} results")
            except QueryFailedError as e:
                if "timeout" in str(e).lower():
                    print("Query timed out, trying with limit")
                    limited = client.gql("MATCH (n) RETURN n LIMIT 10")
                    print(f"Found {limited.row_count} results (limited)")
                else:
                    print(f"Query error: {e}")

            # Cleanup
            client.drop_graph(graph_name, if_exists=True)

    except GqldbError as e:
        # Catch-all for unexpected errors
        print(f"GQLDB Error: [{type(e).__name__}] {e}")
        if e.cause:
            print(f"Root cause: {e.cause}")

    print("Done")

if __name__ == "__main__":
    main()
```
