# Connection and Session

This guide covers creating a client connection, authentication, session management, and connection lifecycle.

## Creating a Client

Create a `GqldbClient` instance with a configuration object:

```java
import com.gqldb.GqldbClient;
import com.gqldb.GqldbConfig;

GqldbConfig config = GqldbConfig.builder()
    .hosts("localhost:9000")
    .defaultGraph("myGraph")
    .build();

GqldbClient client = new GqldbClient(config);
```

The client establishes gRPC connections to the specified hosts. The client implements `AutoCloseable` for use with try-with-resources.

## Authentication

### Login

Authenticate with the database using `login()`:

```java
import com.gqldb.GqldbClient;
import com.gqldb.GqldbConfig;
import com.gqldb.Session;

GqldbConfig config = GqldbConfig.builder()
    .hosts("localhost:9000")
    .build();

try (GqldbClient client = new GqldbClient(config)) {
    // Login returns a Session object
    Session session = client.login("username", "password");
    System.out.println("Session ID: " + session.getId());
    System.out.println("Logged in successfully");

} catch (LoginFailedException e) {
    System.err.println("Authentication failed: " + e.getMessage());
}
```

### Logout

End the current session with `logout()`:

```java
public void disconnect(GqldbClient client) {
    try {
        client.logout();
        System.out.println("Logged out successfully");
    } catch (NotLoggedInException e) {
        System.out.println("No active session");
    }
}
```

### Check Login Status

Use `isLoggedIn()` to check if there's an active session:

```java
if (client.isLoggedIn()) {
    System.out.println("Client is authenticated");
} else {
    System.out.println("Client needs to login");
}
```

### Get Current Session

Retrieve the current session with `getSession()`:

```java
Session session = client.getSession();
if (session != null) {
    System.out.println("Session ID: " + session.getId());
} else {
    System.out.println("No active session");
}
```

## Connection Health

### Ping

Test the connection and measure latency with `ping()`:

```java
public void testConnection(GqldbClient client) {
    try {
        long latencyNs = client.ping();
        System.out.println("Connection alive, latency: " + latencyNs + "ns (" +
            (latencyNs / 1_000_000.0) + "ms)");
    } catch (Exception e) {
        System.err.println("Connection failed: " + e.getMessage());
    }
}
```

### Health Check

Check the health status of the server:

```java
import com.gqldb.GqldbClient;
import com.gqldb.types.HealthStatus;

public void checkHealth(GqldbClient client) {
    HealthStatus status = client.healthCheck();

    switch (status) {
        case SERVING:
            System.out.println("Server is healthy");
            break;
        case NOT_SERVING:
            System.out.println("Server is not serving");
            break;
        case UNKNOWN:
            System.out.println("Health status unknown");
            break;
    }
}
```

### Health Watch

Monitor health status changes with streaming:

```java
import com.gqldb.GqldbClient;
import com.gqldb.types.HealthStatus;

public void watchHealth(GqldbClient client) {
    GqldbClient.HealthWatcher watcher = client.watch(status -> {
        System.out.println("Health status changed: " + status);
    });

    // Let it run for some time
    try {
        Thread.sleep(60000);  // 60 seconds
    } catch (InterruptedException e) {
        Thread.currentThread().interrupt();
    }

    // Stop watching
    watcher.stop();

    // Check for errors
    if (watcher.hasError()) {
        System.err.println("Watch error: " + watcher.getError().getMessage());
    }
}
```

## Closing the Client

Always close the client when done to release resources. The client implements `AutoCloseable`:

```java
// Using try-with-resources (recommended)
try (GqldbClient client = new GqldbClient(config)) {
    client.login("username", "password");
    // ... perform operations ...
}  // Client automatically closed

// Manual close
GqldbClient client = new GqldbClient(config);
try {
    client.login("username", "password");
    // ... perform operations ...
} finally {
    client.close();
}
```

The `close()` method:
- Logs out if there's an active session
- Shuts down the gRPC channel
- Releases connection resources

## Get Client Configuration

Retrieve the current configuration:

```java
GqldbConfig config = client.getConfig();
System.out.println("Hosts: " + config.getHosts());
System.out.println("Default graph: " + config.getDefaultGraph());
System.out.println("Timeout: " + config.getTimeout());
```

## Complete Example

```java
import com.gqldb.*;
import com.gqldb.types.HealthStatus;

public class ConnectionExample {
    public static void main(String[] args) {
        // Create client with configuration
        GqldbConfig config = GqldbConfig.builder()
            .hosts("localhost:9000")
            .timeout(30)
            .defaultGraph("myGraph")
            .build();

        try (GqldbClient client = new GqldbClient(config)) {
            // Authenticate
            Session session = client.login("admin", "password");
            System.out.println("Logged in, session ID: " + session.getId());

            // Check connection
            long latency = client.ping();
            System.out.println("Ping: " + (latency / 1_000_000.0) + "ms");

            // Check health
            HealthStatus health = client.healthCheck();
            System.out.println("Health: " + health);

            // Verify session
            System.out.println("Is logged in: " + client.isLoggedIn());
            System.out.println("Current session: " + client.getSession().getId());

            // Perform database operations
            Response response = client.gql("MATCH (n) RETURN count(n) AS total");
            System.out.println("Total nodes: " + response.singleLong());

        } catch (GqldbException e) {
            System.err.println("Error: " + e.getMessage());
        }

        System.out.println("Connection closed");
    }
}
```

## Exception Handling

Common connection and session exceptions:

| Exception | Description |
|-----------|-------------|
| `LoginFailedException` | Authentication failed (wrong credentials) |
| `NotLoggedInException` | Operation requires authentication |
| `SessionExpiredException` | Session has expired |
| `ConnectionFailedException` | Failed to connect to server |
| `AllHostsFailedException` | All configured hosts are unreachable |

```java
import com.gqldb.*;

public void safeConnect(GqldbClient client) {
    try {
        client.login("username", "password");
    } catch (LoginFailedException e) {
        System.err.println("Invalid credentials");
    } catch (ConnectionFailedException e) {
        System.err.println("Cannot connect to server");
    } catch (GqldbException e) {
        System.err.println("Unexpected error: " + e.getMessage());
    }
}
```
