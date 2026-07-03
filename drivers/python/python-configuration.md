# Configuration

The GQLDB Python driver uses `GqldbConfig` for client configuration. You can create configurations directly or use the `ConfigBuilder` for a fluent interface.

## GqldbConfig

### Direct Configuration

```python
from gqldb import GqldbConfig

config = GqldbConfig(
    hosts=["localhost:9000"],
    username="admin",
    password="password",
    default_graph="myGraph",
    timeout=30
)
```

### Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `hosts` | `List[str]` | `["localhost:9000"]` | Server addresses in "host:port" format |
| `username` | `str` | `""` | Username for authentication |
| `password` | `str` | `""` | Password for authentication |
| `default_graph` | `str` | `""` | Default graph to use after login |
| `timeout` | `int` | `30` | Query timeout in seconds |
| `max_recv_size` | `int` | `67108864` | Maximum receive message size (64MB) |
| `ssl_context` | `ssl.SSLContext` | `None` | SSL context for secure connections |
| `pool_size` | `int` | `10` | Reserved — accepted and validated but not yet wired to a runtime connection pool |
| `health_check_interval` | `float` | `30.0` | Health check interval in seconds |
| `retry_count` | `int` | `3` | Reserved — accepted and validated but not yet consumed by an automatic retry mechanism |
| `retry_delay` | `float` | `0.1` | Reserved — pairs with `retry_count`; not yet consumed at runtime |

> **Note:** `pool_size`, `retry_count`, and `retry_delay` are currently reserved settings. They are validated and stored, but the driver does not yet act on them at runtime (no active connection pooling or automatic request retry is performed). Set them for forward-compatibility, but do not rely on them changing behavior today.

## ConfigBuilder

The `ConfigBuilder` provides a fluent interface for creating configurations:

```python
from gqldb.config import ConfigBuilder

config = (ConfigBuilder()
    .hosts("localhost:9000", "192.168.1.101:9000")
    .username("admin")
    .password("password")
    .default_graph("myGraph")
    .timeout(60)
    .max_recv_size(128 * 1024 * 1024)  # 128MB
    .pool_size(20)
    .health_check_interval(15.0)
    .retry_count(5)
    .retry_delay(0.5)
    .build())
```

### Builder Methods

| Method | Description |
|--------|-------------|
| `hosts(*hosts)` | Set server hosts |
| `username(username)` | Set authentication username |
| `password(password)` | Set authentication password |
| `default_graph(graph)` | Set default graph |
| `timeout(seconds)` | Set query timeout |
| `max_recv_size(bytes)` | Set max receive message size |
| `ssl(ssl_context)` | Set SSL context |
| `pool_size(size)` | Set connection pool size (reserved — not yet wired) |
| `health_check_interval(seconds)` | Set health check interval |
| `retry_count(count)` | Set retry count (reserved — not yet consumed) |
| `retry_delay(seconds)` | Set retry delay (reserved — not yet consumed) |
| `build()` | Build and validate the configuration |

## SSL/TLS Configuration

### Using create_ssl_context

```python
from gqldb import GqldbConfig
from gqldb.config import create_ssl_context

# Create SSL context with certificates
ssl_ctx = create_ssl_context(
    cert_file="/path/to/client.crt",
    key_file="/path/to/client.key",
    ca_file="/path/to/ca.crt",
    verify=True
)

config = GqldbConfig(
    hosts=["localhost:9000"],
    ssl_context=ssl_ctx
)
```

### SSL Context Options

| Parameter | Type | Description |
|-----------|------|-------------|
| `cert_file` | `str` | Path to client certificate file |
| `key_file` | `str` | Path to client private key file |
| `ca_file` | `str` | Path to CA certificate file |
| `verify` | `bool` | Whether to verify server certificates |

### Disabling Certificate Verification

```python
# For development/testing only
ssl_ctx = create_ssl_context(verify=False)

config = GqldbConfig(
    hosts=["localhost:9000"],
    ssl_context=ssl_ctx
)
```

### Using Custom SSL Context

```python
import ssl

# Create custom SSL context
ssl_ctx = ssl.create_default_context()
ssl_ctx.load_cert_chain("/path/to/client.crt", "/path/to/client.key")
ssl_ctx.load_verify_locations("/path/to/ca.crt")

config = GqldbConfig(
    hosts=["localhost:9000"],
    ssl_context=ssl_ctx
)
```

## Multiple Hosts

Configure multiple hosts for high availability:

```python
config = GqldbConfig(
    hosts=[
        "localhost:9000",
        "192.168.1.101:9000",
        "192.168.1.102:9000"
    ],
    retry_count=3,
    retry_delay=0.5
)
```

## Configuration Validation

The configuration is validated when calling `build()` on ConfigBuilder or when creating a GqldbClient:

```python
from gqldb import GqldbConfig

# This will raise ValueError
try:
    config = GqldbConfig(hosts=[])  # Empty hosts
    config.validate()
except ValueError as e:
    print(f"Invalid config: {e}")

# Manual validation
config = GqldbConfig(hosts=["localhost:9000"])
config.validate()  # Raises ValueError if invalid
```

## Complete Example

```python
from gqldb import GqldbClient, GqldbConfig
from gqldb.config import ConfigBuilder, create_ssl_context

def create_production_config():
    """Create configuration for production environment."""
    ssl_ctx = create_ssl_context(
        cert_file="/etc/gqldb/client.crt",
        key_file="/etc/gqldb/client.key",
        ca_file="/etc/gqldb/ca.crt"
    )

    return (ConfigBuilder()
        .hosts(
            "gqldb-1.prod.example.com:9000",
            "gqldb-2.prod.example.com:9000",
            "gqldb-3.prod.example.com:9000"
        )
        .ssl(ssl_ctx)
        .timeout(60)
        .pool_size(50)
        .retry_count(5)
        .retry_delay(1.0)
        .health_check_interval(10.0)
        .build())

def create_development_config():
    """Create configuration for development environment."""
    return GqldbConfig(
        hosts=["localhost:9000"],
        timeout=30,
        pool_size=5
    )

# Usage
import os

if os.environ.get("ENV") == "production":
    config = create_production_config()
else:
    config = create_development_config()

with GqldbClient(config) as client:
    client.login("admin", "password")
    # ... use the client
```
