# Connection and Session

This guide covers creating a client connection, authentication, session management, and connection lifecycle.

## Creating a Client

Create a `GqldbClient` instance with a configuration object:

```typescript
import { GqldbClient, createConfig } from 'gqldb-nodejs';

const config = createConfig({
  hosts: ['192.168.1.100:9000'],
  defaultGraph: 'myGraph'
});

const client = new GqldbClient(config);
```

The client establishes gRPC connections to the specified hosts. Multiple hosts can be provided for high availability.

## Authentication

### Login

Authenticate with the database using `login()`:

```typescript
import { GqldbClient, createConfig, Session } from 'gqldb-nodejs';

async function connect() {
  const client = new GqldbClient(createConfig({
    hosts: ['192.168.1.100:9000']
  }));

  try {
    // Login returns a Session object
    const session: Session = await client.login('username', 'password');
    console.log('Session ID:', session.id);
    console.log('Logged in successfully');

  } catch (error) {
    if (error.name === 'LoginFailedError') {
      console.error('Authentication failed:', error.message);
    }
    throw error;
  }
}
```

### Logout

End the current session with `logout()`:

```typescript
async function disconnect(client: GqldbClient) {
  try {
    await client.logout();
    console.log('Logged out successfully');
  } catch (error) {
    if (error.name === 'NotLoggedInError') {
      console.log('No active session');
    }
  }
}
```

### Check Login Status

Use `isLoggedIn()` to check if there's an active session:

```typescript
if (client.isLoggedIn()) {
  console.log('Client is authenticated');
} else {
  console.log('Client needs to login');
}
```

### Get Current Session

Retrieve the current session with `getSession()`:

```typescript
const session = client.getSession();
if (session) {
  console.log('Session ID:', session.id);
} else {
  console.log('No active session');
}
```

## Connection Health

### Ping

Test the connection and measure latency with `ping()`:

```typescript
async function testConnection(client: GqldbClient) {
  try {
    const latencyNs = await client.ping();
    console.log(`Connection alive, latency: ${latencyNs}ns (${latencyNs / 1_000_000}ms)`);
  } catch (error) {
    console.error('Connection failed:', error.message);
  }
}
```

### Health Check

Check the health status of the server:

```typescript
import { GqldbClient, HealthStatus } from 'gqldb-nodejs';

async function checkHealth(client: GqldbClient) {
  const status = await client.healthCheck();

  switch (status) {
    case HealthStatus.SERVING:
      console.log('Server is healthy');
      break;
    case HealthStatus.NOT_SERVING:
      console.log('Server is not serving');
      break;
    case HealthStatus.UNKNOWN:
      console.log('Health status unknown');
      break;
  }
}
```

### Health Watch

Monitor health status changes with streaming:

```typescript
import { GqldbClient, HealthStatus } from 'gqldb-nodejs';

function watchHealth(client: GqldbClient) {
  const watcher = client.watch();

  watcher.on('status', (status: HealthStatus) => {
    console.log('Health status changed:', HealthStatus[status]);
  });

  watcher.on('error', (error) => {
    console.error('Watch error:', error.message);
  });

  watcher.on('end', () => {
    console.log('Health watch ended');
  });

  // Stop watching after 60 seconds
  setTimeout(() => {
    watcher.stop();
  }, 60000);

  return watcher;
}
```

## Closing the Client

Always close the client when done to release resources:

```typescript
async function main() {
  const client = new GqldbClient(createConfig({
    hosts: ['192.168.1.100:9000']
  }));

  try {
    await client.login('username', 'password');

    // ... perform operations ...

  } finally {
    // close() will logout if needed and release connections
    await client.close();
  }
}
```

The `close()` method:
- Logs out if there's an active session
- Closes all gRPC service clients
- Releases connection resources

## Get Client Configuration

Retrieve the current configuration:

```typescript
const config = client.getConfig();
console.log('Hosts:', config.hosts);
console.log('Default graph:', config.defaultGraph);
console.log('Timeout:', config.timeout);
```

## Complete Example

```typescript
import { GqldbClient, createConfig, HealthStatus } from 'gqldb-nodejs';

async function main() {
  // Create client with configuration
  const client = new GqldbClient(createConfig({
    hosts: ['192.168.1.100:9000'],
    timeout: 30000,
    defaultGraph: 'myGraph'
  }));

  try {
    // Authenticate
    const session = await client.login('admin', 'password');
    console.log('Logged in, session ID:', session.id);

    // Check connection
    const latency = await client.ping();
    console.log(`Ping: ${latency / 1_000_000}ms`);

    // Check health
    const health = await client.healthCheck();
    console.log('Health:', HealthStatus[health]);

    // Verify session
    console.log('Is logged in:', client.isLoggedIn());
    console.log('Current session:', client.getSession()?.id);

    // Perform database operations...
    const response = await client.gql('MATCH (n) RETURN count(n) AS total');
    console.log('Total nodes:', response.singleNumber());

  } catch (error) {
    console.error('Error:', error.message);
    throw error;
  } finally {
    // Clean up
    await client.close();
    console.log('Connection closed');
  }
}

main().catch(console.error);
```

## Error Handling

Common connection and session errors:

| Error | Description |
|-------|-------------|
| `LoginFailedError` | Authentication failed (wrong credentials) |
| `LogoutFailedError` | Logout operation failed |
| `NotLoggedInError` | Operation requires authentication |
| `SessionExpiredError` | Session has expired |
| `InvalidSessionError` | Session is invalid |
| `ConnectionFailedError` | Failed to connect to server |
| `AllHostsFailedError` | All configured hosts are unreachable |
| `HealthCheckFailedError` | Health check operation failed |

```typescript
import {
  GqldbClient,
  LoginFailedError,
  ConnectionFailedError,
  NotLoggedInError
} from 'gqldb-nodejs';

async function safeConnect(client: GqldbClient) {
  try {
    await client.login('username', 'password');
  } catch (error) {
    if (error instanceof LoginFailedError) {
      console.error('Invalid credentials');
    } else if (error instanceof ConnectionFailedError) {
      console.error('Cannot connect to server');
    } else {
      throw error;
    }
  }
}
```
