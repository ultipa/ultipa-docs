# Connection and Session

The GQLDB C# driver manages connections through a connection pool and provides session-based authentication.

## Session Methods

| Method | Description |
|--------|-------------|
| `LoginAsync(username, password)` | Authenticate and create a session |
| `LogoutAsync()` | Terminate the current session |
| `PingAsync()` | Check connection and return latency |
| `GetSession()` | Get the current session |
| `IsLoggedIn` | Check if logged in |

## Creating a Client

```csharp
using Gqldb;

var config = new GqldbConfig { Hosts = { "localhost:60061" } };

// Using IDisposable (recommended)
using var client = new GqldbClient(config);
await client.LoginAsync("username", "password");
// ... use the client
// Client is automatically disposed

// Manual management
var client2 = new GqldbClient(config);
try
{
    await client2.LoginAsync("username", "password");
    // ... use the client
}
finally
{
    client2.Dispose();
}
```

## Authentication

### LoginAsync()

Authenticate with the server and create a session:

```csharp
using Gqldb;

var config = new GqldbConfig { Hosts = { "localhost:60061" } };

using var client = new GqldbClient(config);

// Login returns a Session object
var session = await client.LoginAsync("admin", "password");

Console.WriteLine($"Session ID: {session.Id}");
Console.WriteLine($"Logged in: {client.IsLoggedIn}");
```

### Login with Default Graph

```csharp
var config = new GqldbConfig
{
    Hosts = { "localhost:60061" },
    DefaultGraph = "myGraph"
};

using var client = new GqldbClient(config);

// Automatically uses myGraph after login
await client.LoginAsync("admin", "password");

// No need to call UseGraphAsync()
var response = await client.GqlAsync("MATCH (n) RETURN count(n)");
```

### LogoutAsync()

Terminate the current session:

```csharp
using var client = new GqldbClient(config);
await client.LoginAsync("admin", "password");

// Do work...

// Explicit logout
await client.LogoutAsync();
Console.WriteLine($"Logged in: {client.IsLoggedIn}");  // False
```

## Connection Health

### PingAsync()

Check the connection and get latency:

```csharp
using var client = new GqldbClient(config);
await client.LoginAsync("admin", "password");

// Returns latency in nanoseconds
var latencyNs = await client.PingAsync();
var latencyMs = latencyNs / 1_000_000.0;

Console.WriteLine($"Connection latency: {latencyMs:F2}ms");
```

## Session Information

### GetSession()

Get the current session:

```csharp
using var client = new GqldbClient(config);
await client.LoginAsync("admin", "password");

var session = client.GetSession();
if (session != null)
{
    Console.WriteLine($"Session ID: {session.Id}");
    Console.WriteLine($"Default graph: {session.DefaultGraph}");
    Console.WriteLine($"Server version: {session.ServerVersion}");
    Console.WriteLine($"Roles: {string.Join(", ", session.Roles)}");
    Console.WriteLine($"Age: {session.Age}");
    Console.WriteLine($"Idle: {session.IdleDuration}");
}
```

### Session Class

```csharp
public class Session
{
    public ulong Id { get; set; }
    public string ServerVersion { get; set; }
    public List<string> Roles { get; set; }
    public string DefaultGraph { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime LastActivity { get; set; }
    public bool IsCluster { get; set; }
    public string ClusterId { get; set; }
    public int PartitionCount { get; set; }

    public bool HasRole(string role);
    public TimeSpan IdleDuration { get; }
    public TimeSpan Age { get; }
}
```

## Connection Pool

The driver maintains a connection pool for efficient resource usage:

```csharp
var config = new GqldbConfig
{
    Hosts = { "localhost:60061" },
    PoolSize = 20,  // Connections per host
    HealthCheckInterval = TimeSpan.FromSeconds(30)
};

using var client = new GqldbClient(config);
await client.LoginAsync("admin", "password");
// Connections are managed automatically
```

## Error Handling

```csharp
using Gqldb;

var config = new GqldbConfig { Hosts = { "localhost:60061" } };

try
{
    using var client = new GqldbClient(config);
    try
    {
        await client.LoginAsync("admin", "wrong_password");
    }
    catch (GqldbException e) when (e.Message.Contains("login"))
    {
        Console.WriteLine("Invalid credentials");
    }
}
catch (GqldbException e)
{
    Console.WriteLine($"GQLDB error: {e.Message}");
}
```

## Reconnection Pattern

```csharp
using Gqldb;

async Task<GqldbClient> ConnectWithRetry(GqldbConfig config, int maxRetries = 5)
{
    for (int attempt = 0; attempt < maxRetries; attempt++)
    {
        try
        {
            var client = new GqldbClient(config);
            await client.LoginAsync("admin", "password");
            return client;
        }
        catch (GqldbException)
        {
            if (attempt < maxRetries - 1)
            {
                var waitTime = (int)Math.Pow(2, attempt);
                Console.WriteLine($"Connection failed, retrying in {waitTime}s...");
                await Task.Delay(waitTime * 1000);
            }
            else
            {
                throw;
            }
        }
    }

    throw new GqldbException("All connection attempts failed");
}

async Task EnsureConnected(GqldbClient client)
{
    try
    {
        await client.PingAsync();
        if (!client.IsLoggedIn)
        {
            await client.LoginAsync("admin", "password");
        }
    }
    catch (GqldbException)
    {
        await client.LoginAsync("admin", "password");
    }
}
```

## Complete Example

```csharp
using Gqldb;

async Task Main()
{
    var config = new GqldbConfig
    {
        Hosts = { "localhost:60061", "192.168.1.101:9000" },
        TimeoutSeconds = 30,
        PoolSize = 10,
        RetryCount = 3
    };

    try
    {
        using var client = new GqldbClient(config);

        // Login
        var session = await client.LoginAsync("admin", "password");
        Console.WriteLine($"Connected! Session ID: {session.Id}");

        // Check connection
        var latency = await client.PingAsync() / 1_000_000.0;
        Console.WriteLine($"Latency: {latency:F2}ms");

        // Get session info
        var currentSession = client.GetSession();
        if (currentSession != null)
        {
            Console.WriteLine($"Default graph: {currentSession.DefaultGraph}");
        }

        // Check login status
        Console.WriteLine($"Logged in: {client.IsLoggedIn}");

        // Do some work
        var response = await client.GqlAsync("RETURN 1 + 1 AS result");
        Console.WriteLine($"Result: {response.SingleInt()}");

        // Logout
        await client.LogoutAsync();
        Console.WriteLine($"Logged out. Still logged in: {client.IsLoggedIn}");
    }
    catch (GqldbException e)
    {
        Console.WriteLine($"Error: {e.Message}");
    }
}
```
