# Configuration

The GQLDB Go driver uses the `Config` struct for client configuration. You can create configurations directly or use the `ConfigBuilder` for a fluent interface.

## Config Struct

### Direct Configuration

```go
import (
    "time"

    gqldb "github.com/ultipa/ultipa-go-driver/v6"
)

config := &gqldb.Config{
    Hosts:        []string{"localhost:60061"},
    Username:     "admin",
    Password:     "password",
    DefaultGraph: "myGraph",
    Timeout:      30 * time.Second,
}
```

### Configuration Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `Hosts` | `[]string` | `["localhost:60061"]` | Server addresses in "host:port" format |
| `Username` | `string` | `""` | Username for authentication |
| `Password` | `string` | `""` | Password for authentication |
| `DefaultGraph` | `string` | `""` | Default graph to use after login |
| `Timeout` | `time.Duration` | `30s` | Query timeout |
| `MaxRecvSize` | `int` | `67108864` | Maximum receive message size (64MB) |
| `TLSConfig` | `*tls.Config` | `nil` | TLS configuration for secure connections |
| `PoolSize` | `int` | `10` | Connection pool size per host |
| `HealthCheckInterval` | `time.Duration` | `30s` | Health check interval |
| `RetryCount` | `int` | `3` | Number of retries for failed requests |
| `RetryDelay` | `time.Duration` | `100ms` | Delay between retries |

## ConfigBuilder

The `ConfigBuilder` provides a fluent interface for creating configurations:

```go
config := gqldb.NewConfigBuilder().
    Hosts("localhost:60061", "192.168.1.101:9000").
    Username("admin").
    Password("password").
    DefaultGraph("myGraph").
    Timeout(60 * time.Second).
    MaxRecvSize(128 * 1024 * 1024).  // 128MB
    PoolSize(20).
    HealthCheckInterval(15 * time.Second).
    RetryCount(5).
    RetryDelay(500 * time.Millisecond).
    Build()
```

### Builder Methods

| Method | Description |
|--------|-------------|
| `Hosts(hosts ...string)` | Set server hosts |
| `Username(username string)` | Set authentication username |
| `Password(password string)` | Set authentication password |
| `DefaultGraph(graph string)` | Set default graph |
| `Timeout(timeout time.Duration)` | Set query timeout |
| `TimeoutSeconds(seconds int)` | Set timeout in seconds (convenience) |
| `MaxRecvSize(bytes int)` | Set max receive message size |
| `TLS(config *tls.Config)` | Set TLS configuration |
| `PoolSize(size int)` | Set connection pool size |
| `HealthCheckInterval(interval time.Duration)` | Set health check interval |
| `RetryCount(count int)` | Set retry count |
| `RetryDelay(delay time.Duration)` | Set retry delay |
| `Build()` | Build and return the configuration |

## Default Configuration

Use `DefaultConfig()` to get a configuration with default values:

```go
config := gqldb.DefaultConfig()
config.Hosts = []string{"localhost:60061"}
```

## TLS Configuration

### Basic TLS

```go
import (
    "crypto/tls"

    gqldb "github.com/ultipa/ultipa-go-driver/v6"
)

tlsConfig := &tls.Config{
    InsecureSkipVerify: false,  // Set to true only for development
}

config := &gqldb.Config{
    Hosts:     []string{"localhost:60061"},
    TLSConfig: tlsConfig,
}
```

### TLS with Certificates

```go
import (
    "crypto/tls"
    "crypto/x509"
    "os"
)

// Load CA certificate
caCert, err := os.ReadFile("/path/to/ca.crt")
if err != nil {
    log.Fatal(err)
}

caCertPool := x509.NewCertPool()
caCertPool.AppendCertsFromPEM(caCert)

// Load client certificate
cert, err := tls.LoadX509KeyPair("/path/to/client.crt", "/path/to/client.key")
if err != nil {
    log.Fatal(err)
}

tlsConfig := &tls.Config{
    Certificates: []tls.Certificate{cert},
    RootCAs:      caCertPool,
}

config := gqldb.NewConfigBuilder().
    Hosts("localhost:60061").
    TLS(tlsConfig).
    Build()
```

### Disabling Certificate Verification

```go
// For development/testing only
tlsConfig := &tls.Config{
    InsecureSkipVerify: true,
}

config := &gqldb.Config{
    Hosts:     []string{"localhost:60061"},
    TLSConfig: tlsConfig,
}
```

## Multiple Hosts

Configure multiple hosts for high availability:

```go
config := &gqldb.Config{
    Hosts: []string{
        "localhost:60061",
        "192.168.1.101:9000",
        "192.168.1.102:9000",
    },
    RetryCount: 3,
    RetryDelay: 500 * time.Millisecond,
}
```

## Configuration Validation

The configuration is validated when creating a client:

```go
config := &gqldb.Config{
    Hosts: []string{},  // Empty hosts - will fail validation
}

client, err := gqldb.NewClient(config)
if err != nil {
    // err will be gqldb.ErrNoHosts
    log.Printf("Invalid config: %v", err)
}

// Manual validation
if err := config.Validate(); err != nil {
    log.Printf("Validation failed: %v", err)
}
```

## Complete Example

```go
package main

import (
    "context"
    "crypto/tls"
    "log"
    "os"
    "time"

    gqldb "github.com/ultipa/ultipa-go-driver/v6"
)

func createProductionConfig() *gqldb.Config {
    // Load TLS certificates
    cert, err := tls.LoadX509KeyPair(
        "/etc/gqldb/client.crt",
        "/etc/gqldb/client.key",
    )
    if err != nil {
        log.Fatal(err)
    }

    tlsConfig := &tls.Config{
        Certificates: []tls.Certificate{cert},
    }

    return gqldb.NewConfigBuilder().
        Hosts(
            "gqldb-1.prod.example.com:9000",
            "gqldb-2.prod.example.com:9000",
            "gqldb-3.prod.example.com:9000",
        ).
        TLS(tlsConfig).
        Timeout(60 * time.Second).
        PoolSize(50).
        RetryCount(5).
        RetryDelay(time.Second).
        HealthCheckInterval(10 * time.Second).
        Build()
}

func createDevelopmentConfig() *gqldb.Config {
    return &gqldb.Config{
        Hosts:    []string{"localhost:60061"},
        Timeout:  30 * time.Second,
        PoolSize: 5,
    }
}

func main() {
    var config *gqldb.Config

    if os.Getenv("ENV") == "production" {
        config = createProductionConfig()
    } else {
        config = createDevelopmentConfig()
    }

    client, err := gqldb.NewClient(config)
    if err != nil {
        log.Fatalf("Failed to create client: %v", err)
    }
    defer client.Close()

    ctx := context.Background()
    _, err = client.Login(ctx, "admin", "password")
    if err != nil {
        log.Fatalf("Login failed: %v", err)
    }

    // ... use the client
}
```
