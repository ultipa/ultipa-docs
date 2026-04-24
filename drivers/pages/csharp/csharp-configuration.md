# Configuration

The GQLDB C# driver uses `GqldbConfig` for client configuration. You can create configurations directly or use the `ConfigBuilder` for a fluent interface.

## GqldbConfig

### Direct Configuration

```csharp
using Gqldb;

var config = new GqldbConfig
{
    Hosts = { "localhost:60061" },
    Username = "admin",
    Password = "password",
    DefaultGraph = "myGraph",
    TimeoutSeconds = 30
};
```

### Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `Hosts` | `List<string>` | `["localhost:9000"]` | Server addresses in "host:port" format |
| `Username` | `string?` | `null` | Username for authentication |
| `Password` | `string?` | `null` | Password for authentication |
| `DefaultGraph` | `string?` | `null` | Default graph to use after login |
| `TimeoutSeconds` | `int` | `30` | Query timeout in seconds |
| `MaxRecvSize` | `int` | `67108864` | Maximum receive message size (64MB) |
| `UseTls` | `bool` | `false` | Enable TLS for secure connections |
| `PoolSize` | `int` | `10` | Connection pool size per host |
| `HealthCheckInterval` | `TimeSpan` | `30s` | Health check interval |
| `RetryCount` | `int` | `3` | Number of retries for failed requests |
| `RetryDelay` | `TimeSpan` | `100ms` | Delay between retries |

## ConfigBuilder

The `ConfigBuilder` provides a fluent interface for creating configurations:

```csharp
using Gqldb;

var config = new ConfigBuilder()
    .Hosts("localhost:60061", "192.168.1.101:9000")
    .Username("admin")
    .Password("password")
    .DefaultGraph("myGraph")
    .Timeout(60)
    .MaxRecvSize(128 * 1024 * 1024)  // 128MB
    .PoolSize(20)
    .HealthCheckInterval(TimeSpan.FromSeconds(15))
    .RetryCount(5)
    .RetryDelay(TimeSpan.FromMilliseconds(500))
    .Build();
```

### Builder Methods

| Method | Description |
|--------|-------------|
| `Hosts(params string[] hosts)` | Set server hosts |
| `Username(string username)` | Set authentication username |
| `Password(string password)` | Set authentication password |
| `DefaultGraph(string graph)` | Set default graph |
| `Timeout(int seconds)` | Set query timeout |
| `MaxRecvSize(int bytes)` | Set max receive message size |
| `WithTls()` | Enable TLS |
| `PoolSize(int size)` | Set connection pool size |
| `HealthCheckInterval(TimeSpan interval)` | Set health check interval |
| `RetryCount(int count)` | Set retry count |
| `RetryDelay(TimeSpan delay)` | Set retry delay |
| `Build()` | Build and validate the configuration |

## TLS Configuration

```csharp
using Gqldb;

// Enable TLS
var config = new GqldbConfig
{
    Hosts = { "localhost:60061" },
    UseTls = true
};

// Or using builder
var config2 = new ConfigBuilder()
    .Hosts("localhost:60061")
    .WithTls()
    .Build();
```

## Multiple Hosts

Configure multiple hosts for high availability:

```csharp
var config = new GqldbConfig
{
    Hosts =
    {
        "localhost:60061",
        "192.168.1.101:9000",
        "192.168.1.102:9000"
    },
    RetryCount = 3,
    RetryDelay = TimeSpan.FromMilliseconds(500)
};
```

## Configuration Validation

The configuration is validated when calling `Build()` on ConfigBuilder or when creating a GqldbClient:

```csharp
using Gqldb;

// This will throw
try
{
    var config = new GqldbConfig { Hosts = { } };
    config.Validate();
}
catch (Exception e)
{
    Console.WriteLine($"Invalid config: {e.Message}");
}
```

## Complete Example

```csharp
using Gqldb;

GqldbConfig CreateProductionConfig()
{
    return new ConfigBuilder()
        .Hosts(
            "gqldb-1.prod.example.com:9000",
            "gqldb-2.prod.example.com:9000",
            "gqldb-3.prod.example.com:9000"
        )
        .WithTls()
        .Timeout(60)
        .PoolSize(50)
        .RetryCount(5)
        .RetryDelay(TimeSpan.FromSeconds(1))
        .HealthCheckInterval(TimeSpan.FromSeconds(10))
        .Build();
}

GqldbConfig CreateDevelopmentConfig()
{
    return new GqldbConfig
    {
        Hosts = { "localhost:60061" },
        TimeoutSeconds = 30,
        PoolSize = 5
    };
}

// Usage
var env = Environment.GetEnvironmentVariable("ENV");
var config = env == "production"
    ? CreateProductionConfig()
    : CreateDevelopmentConfig();

using var client = new GqldbClient(config);
await client.LoginAsync("admin", "password");
// ... use the client
```
