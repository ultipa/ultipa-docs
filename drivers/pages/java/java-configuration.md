# Configuration

The GQLDB Java driver provides flexible configuration options through the `GqldbConfig` class with a builder pattern.

## Configuration Options

The `GqldbConfig` class supports the following options:

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `hosts` | `List<String>` | `["localhost:9000"]` | Server hosts in `host:port` format |
| `username` | `String` | `null` | Username for authentication |
| `password` | `String` | `null` | Password for authentication |
| `defaultGraph` | `String` | `null` | Default graph to use for queries |
| `timeout` | `int` | `30` | Query timeout in seconds |
| `maxRecvSize` | `int` | `67108864` | Maximum receive message size in bytes (64MB) |
| `sslContext` | `SSLContext` | `null` | SSL context for secure connections |
| `poolSize` | `int` | `10` | Connection pool size per host |
| `healthCheckInterval` | `Duration` | `30s` | Health check interval |
| `retryCount` | `int` | `3` | Number of retries for failed requests |
| `retryDelay` | `Duration` | `100ms` | Delay between retries |

## Using the Builder

Create a configuration using the builder pattern:

```java
import com.gqldb.GqldbConfig;
import com.gqldb.GqldbClient;
import java.time.Duration;

// Minimal configuration
GqldbConfig config = GqldbConfig.builder()
    .hosts("192.168.1.100:9000")
    .build();

// Full configuration
GqldbConfig fullConfig = GqldbConfig.builder()
    .hosts("server1:9000", "server2:9000")
    .username("admin")
    .password("secret")
    .defaultGraph("myGraph")
    .timeout(60)                              // 60 seconds
    .maxRecvSize(128 * 1024 * 1024)          // 128MB
    .poolSize(20)
    .retryCount(5)
    .retryDelay(Duration.ofMillis(200))
    .build();

GqldbClient client = new GqldbClient(config);
```

## Builder Methods

| Method | Description |
|--------|-------------|
| `hosts(String... hosts)` | Set the server hosts |
| `hosts(List<String> hosts)` | Set the server hosts from a list |
| `username(String username)` | Set the authentication username |
| `password(String password)` | Set the authentication password |
| `defaultGraph(String graph)` | Set the default graph |
| `timeout(int seconds)` | Set query timeout in seconds |
| `maxRecvSize(int bytes)` | Set maximum receive message size |
| `sslContext(SSLContext context)` | Set SSL context for TLS |
| `poolSize(int size)` | Set connection pool size |
| `healthCheckInterval(Duration interval)` | Set health check interval |
| `retryCount(int count)` | Set number of retries |
| `retryDelay(Duration delay)` | Set delay between retries |
| `build()` | Build and validate the configuration |

## TLS/SSL Configuration

For secure connections, configure an SSL context:

```java
import com.gqldb.GqldbConfig;
import com.gqldb.GqldbClient;
import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManagerFactory;
import java.security.KeyStore;
import java.io.FileInputStream;

// Load the trust store
KeyStore trustStore = KeyStore.getInstance("JKS");
try (FileInputStream fis = new FileInputStream("/path/to/truststore.jks")) {
    trustStore.load(fis, "truststorePassword".toCharArray());
}

// Create trust manager
TrustManagerFactory tmf = TrustManagerFactory.getInstance(
    TrustManagerFactory.getDefaultAlgorithm());
tmf.init(trustStore);

// Create SSL context
SSLContext sslContext = SSLContext.getInstance("TLS");
sslContext.init(null, tmf.getTrustManagers(), null);

// Configure client with SSL
GqldbConfig config = GqldbConfig.builder()
    .hosts("secure-server:9000")
    .sslContext(sslContext)
    .build();

GqldbClient client = new GqldbClient(config);
```

## Environment Variables

You can load configuration from environment variables:

```java
import com.gqldb.GqldbConfig;
import com.gqldb.GqldbClient;
import java.util.Arrays;

String hostsEnv = System.getenv("GQLDB_HOSTS");
String[] hosts = hostsEnv != null ? hostsEnv.split(",") : new String[]{"192.168.1.100:9000"};

GqldbConfig config = GqldbConfig.builder()
    .hosts(hosts)
    .username(System.getenv("GQLDB_USERNAME"))
    .password(System.getenv("GQLDB_PASSWORD"))
    .defaultGraph(System.getenv("GQLDB_DEFAULT_GRAPH"))
    .timeout(Integer.parseInt(System.getenv().getOrDefault("GQLDB_TIMEOUT", "30")))
    .build();

GqldbClient client = new GqldbClient(config);
```

## Configuration Validation

The `build()` method validates the configuration:

- `hosts` must be non-empty
- `timeout` must be non-negative

```java
import com.gqldb.GqldbConfig;

try {
    GqldbConfig config = GqldbConfig.builder()
        .hosts()  // Empty hosts - will throw
        .build();
} catch (IllegalArgumentException e) {
    System.err.println("Invalid configuration: " + e.getMessage());
}
```

## Accessing Configuration

Retrieve configuration values from an existing config:

```java
GqldbConfig config = client.getConfig();
System.out.println("Hosts: " + config.getHosts());
System.out.println("Default graph: " + config.getDefaultGraph());
System.out.println("Timeout: " + config.getTimeout() + " seconds");
System.out.println("Max receive size: " + config.getMaxRecvSize() + " bytes");
System.out.println("Pool size: " + config.getPoolSize());
System.out.println("Retry count: " + config.getRetryCount());
```
