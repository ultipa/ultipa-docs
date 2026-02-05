# Configuration

The GQLDB Node.js driver provides flexible configuration options through the `GqldbConfig` interface, `ConfigBuilder` class, and `createConfig()` helper function.

## Configuration Options

The `GqldbConfig` interface supports the following options:

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `hosts` | `string[]` | `['192.168.1.100:9000']` | Server hosts in `host:port` format |
| `username` | `string` | - | Username for authentication |
| `password` | `string` | - | Password for authentication |
| `defaultGraph` | `string` | - | Default graph to use for queries |
| `timeout` | `number` | `30000` | Query timeout in milliseconds |
| `maxRecvSize` | `number` | `67108864` | Maximum receive message size in bytes (64MB) |
| `tlsOptions` | `tls.ConnectionOptions` | - | TLS options for secure connections |
| `poolSize` | `number` | `10` | Connection pool size per host |
| `healthCheckInterval` | `number` | `30000` | Health check interval in milliseconds |
| `retryCount` | `number` | `3` | Number of retries for failed requests |
| `retryDelay` | `number` | `100` | Delay between retries in milliseconds |

## Using createConfig()

The simplest way to create a configuration with sensible defaults:

```typescript
import { createConfig, GqldbClient } from 'gqldb-nodejs';

// Minimal configuration
const config = createConfig({
  hosts: ['192.168.1.100:9000']
});

// Full configuration
const fullConfig = createConfig({
  hosts: ['server1:9000', 'server2:9000'],
  username: 'admin',
  password: 'secret',
  defaultGraph: 'myGraph',
  timeout: 60000,        // 60 seconds
  maxRecvSize: 128 * 1024 * 1024,  // 128MB
  poolSize: 20,
  retryCount: 5,
  retryDelay: 200
});

const client = new GqldbClient(config);
```

## Using ConfigBuilder

For a fluent API approach, use the `ConfigBuilder` class:

```typescript
import { ConfigBuilder, GqldbClient } from 'gqldb-nodejs';

const config = new ConfigBuilder()
  .hosts('server1:9000', 'server2:9000')
  .username('admin')
  .password('secret')
  .defaultGraph('myGraph')
  .timeout(60000)
  .poolSize(20)
  .retryCount(5)
  .retryDelay(200)
  .build();

const client = new GqldbClient(config);
```

### ConfigBuilder Methods

| Method | Description |
|--------|-------------|
| `hosts(...hosts: string[])` | Set the server hosts |
| `username(username: string)` | Set the authentication username |
| `password(password: string)` | Set the authentication password |
| `defaultGraph(graph: string)` | Set the default graph |
| `timeout(ms: number)` | Set query timeout in milliseconds |
| `timeoutSeconds(seconds: number)` | Set query timeout in seconds (convenience) |
| `maxRecvSize(bytes: number)` | Set maximum receive message size |
| `tls(options: tls.ConnectionOptions)` | Set TLS options |
| `poolSize(size: number)` | Set connection pool size |
| `healthCheckInterval(ms: number)` | Set health check interval |
| `retryCount(count: number)` | Set number of retries |
| `retryDelay(ms: number)` | Set delay between retries |
| `build()` | Build and return the configuration |

## TLS/SSL Configuration

For secure connections, configure TLS options:

```typescript
import { createConfig, GqldbClient } from 'gqldb-nodejs';
import * as fs from 'fs';

const config = createConfig({
  hosts: ['secure-server:9000'],
  tlsOptions: {
    ca: fs.readFileSync('/path/to/ca.crt'),
    cert: fs.readFileSync('/path/to/client.crt'),
    key: fs.readFileSync('/path/to/client.key'),
    rejectUnauthorized: true
  }
});

const client = new GqldbClient(config);
```

Or using ConfigBuilder:

```typescript
import { ConfigBuilder, GqldbClient } from 'gqldb-nodejs';
import * as fs from 'fs';

const config = new ConfigBuilder()
  .hosts('secure-server:9000')
  .tls({
    ca: fs.readFileSync('/path/to/ca.crt'),
    rejectUnauthorized: true
  })
  .build();

const client = new GqldbClient(config);
```

## Environment Variables

You can load configuration from environment variables:

```typescript
import { createConfig, GqldbClient } from 'gqldb-nodejs';

const config = createConfig({
  hosts: process.env.GQLDB_HOSTS?.split(',') || ['192.168.1.100:9000'],
  username: process.env.GQLDB_USERNAME,
  password: process.env.GQLDB_PASSWORD,
  defaultGraph: process.env.GQLDB_DEFAULT_GRAPH,
  timeout: parseInt(process.env.GQLDB_TIMEOUT || '30000', 10)
});

const client = new GqldbClient(config);
```

## Configuration Validation

Both `createConfig()` and `ConfigBuilder.build()` validate the configuration:

- `hosts` must be a non-empty array
- `timeout` must be non-negative
- `maxRecvSize` must be positive (defaults to 64MB if invalid)
- `poolSize` must be positive (defaults to 10 if invalid)

```typescript
import { createConfig, validateConfig } from 'gqldb-nodejs';

// Manual validation
const config = {
  hosts: ['192.168.1.100:9000']
};

try {
  validateConfig(config);
  console.log('Configuration is valid');
} catch (error) {
  console.error('Invalid configuration:', error.message);
}
```

## Default Configuration

The driver provides default values through `DEFAULT_CONFIG`:

```typescript
import { DEFAULT_CONFIG } from 'gqldb-nodejs';

console.log(DEFAULT_CONFIG);
// {
//   hosts: ['192.168.1.100:9000'],
//   timeout: 30000,
//   maxRecvSize: 67108864,  // 64MB
//   poolSize: 10,
//   healthCheckInterval: 30000,
//   retryCount: 3,
//   retryDelay: 100
// }
```
