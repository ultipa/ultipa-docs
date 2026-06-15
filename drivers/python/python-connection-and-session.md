# Connection and Session

The GQLDB Python driver manages connections through a connection pool and provides session-based authentication.

## Session Methods

| Method | Description |
|--------|-------------|
| `login(username, password)` | Authenticate and create a session |
| `logout()` | Terminate the current session |
| `ping()` | Check connection and return latency |
| `get_session()` | Get the current session |
| `is_logged_in()` | Check if logged in |

## Creating a Client

```python
from gqldb import GqldbClient, GqldbConfig

config = GqldbConfig(hosts=["localhost:9000"])

# Using context manager (recommended)
with GqldbClient(config) as client:
    client.login("username", "password")
    # ... use the client
# Client is automatically closed

# Manual management
client = GqldbClient(config)
try:
    client.login("username", "password")
    # ... use the client
finally:
    client.close()
```

## Authentication

### login()

Authenticate with the server and create a session:

```python
from gqldb import GqldbClient, GqldbConfig

config = GqldbConfig(hosts=["localhost:9000"])

with GqldbClient(config) as client:
    # Login returns a Session object
    session = client.login("admin", "password")

    print(f"Session ID: {session.id}")
    print(f"Logged in: {client.is_logged_in()}")
```

### Login with Default Graph

```python
config = GqldbConfig(
    hosts=["localhost:9000"],
    default_graph="myGraph"
)

with GqldbClient(config) as client:
    # Automatically uses myGraph after login
    client.login("admin", "password")

    # No need to call use_graph()
    response = client.gql("MATCH (n) RETURN count(n)")
```

### logout()

Terminate the current session:

```python
with GqldbClient(config) as client:
    client.login("admin", "password")

    # Do work...

    # Explicit logout
    client.logout()
    print(f"Logged in: {client.is_logged_in()}")  # False
```

## Connection Health

### ping()

Check the connection and get latency:

```python
with GqldbClient(config) as client:
    client.login("admin", "password")

    # Returns latency in nanoseconds
    latency_ns = client.ping()
    latency_ms = latency_ns / 1_000_000

    print(f"Connection latency: {latency_ms:.2f}ms")
```

## Session Information

### get_session()

Get the current session:

```python
with GqldbClient(config) as client:
    client.login("admin", "password")

    session = client.get_session()
    if session:
        print(f"Session ID: {session.id}")
        print(f"Default graph: {session.default_graph}")
```

### is_logged_in()

Check if there is an active session:

```python
with GqldbClient(config) as client:
    print(f"Before login: {client.is_logged_in()}")  # False

    client.login("admin", "password")
    print(f"After login: {client.is_logged_in()}")   # True

    client.logout()
    print(f"After logout: {client.is_logged_in()}")  # False
```

## Connection Pool

The driver maintains a connection pool for efficient resource usage:

```python
config = GqldbConfig(
    hosts=["localhost:9000"],
    pool_size=20,  # Connections per host
    health_check_interval=30.0  # Health check every 30 seconds
)

with GqldbClient(config) as client:
    client.login("admin", "password")
    # Connections are managed automatically
```

## Error Handling

```python
from gqldb import GqldbClient, GqldbConfig
from gqldb.errors import (
    GqldbError,
    LoginFailedError,
    ConnectionFailedError,
    AllHostsFailedError
)

config = GqldbConfig(hosts=["localhost:9000"])

try:
    with GqldbClient(config) as client:
        try:
            client.login("admin", "wrong_password")
        except LoginFailedError:
            print("Invalid credentials")

except ConnectionFailedError:
    print("Could not connect to server")
except AllHostsFailedError:
    print("All configured hosts are unreachable")
except GqldbError as e:
    print(f"GQLDB error: {e}")
```

## Reconnection Pattern

```python
import time
from gqldb import GqldbClient, GqldbConfig
from gqldb.errors import ConnectionFailedError, SessionExpiredError

def connect_with_retry(config: GqldbConfig, max_retries: int = 5):
    """Connect to GQLDB with retry logic."""
    for attempt in range(max_retries):
        try:
            client = GqldbClient(config)
            client.login("admin", "password")
            return client
        except ConnectionFailedError:
            if attempt < max_retries - 1:
                wait_time = 2 ** attempt  # Exponential backoff
                print(f"Connection failed, retrying in {wait_time}s...")
                time.sleep(wait_time)
            else:
                raise

    raise ConnectionFailedError()

def ensure_connected(client: GqldbClient):
    """Ensure the client is connected and logged in."""
    try:
        client.ping()
        if not client.is_logged_in():
            client.login("admin", "password")
    except (ConnectionFailedError, SessionExpiredError):
        client.login("admin", "password")
```

## Complete Example

```python
from gqldb import GqldbClient, GqldbConfig
from gqldb.errors import GqldbError, LoginFailedError

def main():
    config = GqldbConfig(
        hosts=["localhost:9000", "192.168.1.101:9000"],
        timeout=30,
        pool_size=10,
        retry_count=3
    )

    try:
        with GqldbClient(config) as client:
            # Login
            session = client.login("admin", "password")
            print(f"Connected! Session ID: {session.id}")

            # Check connection
            latency = client.ping() / 1_000_000
            print(f"Latency: {latency:.2f}ms")

            # Get session info
            current_session = client.get_session()
            if current_session:
                print(f"Default graph: {current_session.default_graph}")

            # Check login status
            print(f"Logged in: {client.is_logged_in()}")

            # Do some work
            response = client.gql("RETURN 1 + 1 AS result")
            print(f"Result: {response.single_int()}")

            # Logout
            client.logout()
            print(f"Logged out. Still logged in: {client.is_logged_in()}")

    except LoginFailedError:
        print("Login failed - check credentials")
    except GqldbError as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()
```
