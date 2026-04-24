# Error Handling

The GQLDB C# driver uses the `GqldbException` class for all driver-related errors. All exceptions include a message and an optional error code.

## Base Exception Class

```csharp
using Gqldb;

public class GqldbException : Exception
{
    public int Code { get; }

    public GqldbException(string message, int code = 0, Exception? innerException = null)
        : base(message, innerException)
    {
        Code = code;
    }
}
```

All GQLDB exceptions include:
- `Message`: Human-readable error description
- `Code`: Numeric error code
- `InnerException`: Original exception that caused this error (if applicable)

## Exception Categories

### Configuration Errors

| Scenario | Description |
|----------|-------------|
| No hosts | No hosts configured in the client |
| Invalid timeout | Invalid timeout value specified |

```csharp
using Gqldb;

try
{
    var config = new GqldbConfig { Hosts = { } };
    config.Validate();
}
catch (Exception e)
{
    Console.WriteLine("Configuration error: No hosts configured");
}
```

### Connection Errors

| Scenario | Description |
|----------|-------------|
| Connection failed | Failed to establish connection |
| All hosts failed | All configured hosts are unreachable |
| Health check failed | Health check failed |

```csharp
using Gqldb;

async Task<GqldbClient> ConnectWithRetry(GqldbConfig config, int maxRetries = 3)
{
    for (int i = 0; i < maxRetries; i++)
    {
        try
        {
            var client = new GqldbClient(config);
            await client.LoginAsync("user", "pass");
            return client;
        }
        catch (GqldbException e)
        {
            Console.WriteLine($"Connection attempt {i + 1} failed: {e.Message}");
            if (i < maxRetries - 1)
            {
                await Task.Delay(1000 * (i + 1));
            }
            else
            {
                throw;
            }
        }
    }

    throw new GqldbException("All connection attempts failed");
}
```

### Session Errors

| Scenario | Description |
|----------|-------------|
| Not logged in | Operation requires authentication |
| Login failed | Login failed (wrong credentials) |
| Session expired | Session has expired |

```csharp
async Task EnsureLoggedIn(GqldbClient client)
{
    try
    {
        await client.GqlAsync("MATCH (n) RETURN count(n)");
    }
    catch (GqldbException e) when (
        e.Message.Contains("not logged in") ||
        e.Message.Contains("session expired"))
    {
        Console.WriteLine("Session expired, re-authenticating...");
        await client.LoginAsync("user", "pass");
    }
}
```

### Transaction Errors

| Scenario | Description |
|----------|-------------|
| Transaction failed | Transaction operation failed |
| Transaction not found | Transaction not found (may have timed out) |
| Transaction already open | Transaction already open |

```csharp
async Task SafeTransaction(GqldbClient client, string graphName, Func<ulong, Task> fn)
{
    try
    {
        await client.WithTransactionAsync(graphName, readOnly: false, fn);
    }
    catch (GqldbException e) when (e.Message.Contains("transaction"))
    {
        Console.WriteLine($"Transaction error: {e.Message}");
    }
}
```

### Query Errors

| Scenario | Description |
|----------|-------------|
| Query failed | Query execution failed |
| Query timeout | Query timed out |
| Empty query | Query string is empty |

```csharp
async Task<Response?> ExecuteQuery(GqldbClient client, string query)
{
    try
    {
        return await client.GqlAsync(query);
    }
    catch (GqldbException e) when (e.Message.Contains("empty"))
    {
        Console.WriteLine("Query cannot be empty");
    }
    catch (GqldbException e) when (e.Message.Contains("timeout"))
    {
        Console.WriteLine("Query timed out");
    }
    catch (GqldbException e)
    {
        Console.WriteLine($"Query failed: {e.Message}");
    }
    return null;
}
```

### Graph Errors

| Scenario | Description |
|----------|-------------|
| Graph not found | Graph does not exist |
| Graph exists | Graph already exists |

```csharp
async Task EnsureGraph(GqldbClient client, string graphName)
{
    try
    {
        await client.GetGraphInfoAsync(graphName);
        Console.WriteLine($"Graph {graphName} exists");
    }
    catch (GqldbException e) when (e.Message.Contains("not found"))
    {
        try
        {
            await client.CreateGraphAsync(graphName);
            Console.WriteLine($"Created graph {graphName}");
        }
        catch (GqldbException e2) when (e2.Message.Contains("exists"))
        {
            Console.WriteLine($"Graph {graphName} was created by another process");
        }
    }
}
```

### Data Errors

| Scenario | Description |
|----------|-------------|
| Insert failed | Insert operation failed |
| Delete failed | Delete operation failed |
| Export failed | Export operation failed |
| Type conversion | Type conversion failed |

## Error Handling Patterns

### Comprehensive Try-Catch

```csharp
using Gqldb;

async Task HandleAllErrors(GqldbClient client)
{
    try
    {
        await client.LoginAsync("user", "pass");
        await client.GqlAsync("MATCH (n) RETURN n");
    }
    catch (GqldbException e)
    {
        Console.WriteLine($"GQLDB Error [{e.Code}]: {e.Message}");
        if (e.InnerException != null)
        {
            Console.WriteLine($"Caused by: {e.InnerException.Message}");
        }
    }
    catch (Exception e)
    {
        Console.WriteLine($"Unexpected error: {e.Message}");
    }
}
```

### Error Recovery with Retry

```csharp
using Gqldb;

async Task<T> WithRetry<T>(
    Func<Task<T>> operation, int maxRetries = 3)
{
    Exception? lastError = null;

    for (int attempt = 1; attempt <= maxRetries; attempt++)
    {
        try
        {
            return await operation();
        }
        catch (GqldbException e)
        {
            lastError = e;

            if (attempt == maxRetries)
                throw;

            Console.WriteLine($"Attempt {attempt} failed, retrying...");
            await Task.Delay(1000 * attempt);
        }
    }

    throw lastError!;
}

// Usage
var result = await WithRetry(
    () => client.GqlAsync("MATCH (n) RETURN n LIMIT 100")
);
```

### Graceful Degradation

```csharp
async Task<Response> GetDataWithFallback(GqldbClient client)
{
    try
    {
        return await client.GqlAsync("MATCH (n:User) RETURN n");
    }
    catch (GqldbException e) when (e.Message.Contains("timeout"))
    {
        Console.WriteLine("Full query timed out, using limited query");
        return await client.GqlAsync("MATCH (n:User) RETURN n LIMIT 100");
    }
}
```

### Cleanup on Error

```csharp
async Task TransactionWithCleanup(GqldbClient client, string graphName)
{
    Transaction? tx = null;

    try
    {
        tx = await client.BeginTransactionAsync(graphName);

        var config = new QueryConfig { TransactionId = tx.Id };
        await client.GqlAsync("INSERT (n:Test {_id: 't1'})", config);
        await client.GqlAsync("INSERT (n:Test {_id: 't2'})", config);

        await client.CommitAsync(tx.Id);
        tx = null;  // Transaction completed
    }
    finally
    {
        if (tx != null)
        {
            try
            {
                await client.RollbackAsync(tx.Id);
            }
            catch (Exception rollbackError)
            {
                Console.WriteLine($"Rollback failed: {rollbackError.Message}");
            }
        }
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
        Hosts = { "localhost:60061" },
        TimeoutSeconds = 30
    };

    try
    {
        using var client = new GqldbClient(config);

        // Login with error handling
        try
        {
            await client.LoginAsync("admin", "password");
            Console.WriteLine("Logged in successfully");
        }
        catch (GqldbException e)
        {
            Console.WriteLine("Invalid credentials");
            return;
        }

        // Ensure graph exists
        var graphName = "errorDemo";
        try
        {
            await client.GetGraphInfoAsync(graphName);
        }
        catch (GqldbException)
        {
            await client.CreateGraphAsync(graphName);
            Console.WriteLine("Created graph");
        }

        await client.UseGraphAsync(graphName);

        // Transaction with error handling
        try
        {
            await client.WithTransactionAsync(graphName, readOnly: false, async txId =>
            {
                var cfg = new QueryConfig { TransactionId = txId };
                await client.GqlAsync(
                    "INSERT (n:User {_id: 'u1', name: 'Alice'})", cfg
                );

                // Simulate potential error
                var random = new Random();
                if (random.NextDouble() < 0.3)
                {
                    throw new InvalidOperationException("Random failure for demo");
                }
            });
            Console.WriteLine("Transaction succeeded");
        }
        catch (GqldbException)
        {
            Console.WriteLine("Transaction failed, changes rolled back");
        }
        catch (InvalidOperationException e)
        {
            Console.WriteLine($"Error during transaction: {e.Message}");
        }

        // Query with timeout handling
        try
        {
            var queryConfig = new QueryConfig { Timeout = 5 };
            var response = await client.GqlAsync("MATCH (n) RETURN n", queryConfig);
            Console.WriteLine($"Found {response.RowCount} results");
        }
        catch (GqldbException e) when (e.Message.Contains("timeout"))
        {
            Console.WriteLine("Query timed out, trying with limit");
            var limited = await client.GqlAsync("MATCH (n) RETURN n LIMIT 10");
            Console.WriteLine($"Found {limited.RowCount} results (limited)");
        }
        catch (GqldbException e)
        {
            Console.WriteLine($"Query error: {e.Message}");
        }

        // Cleanup
        await client.DropGraphAsync(graphName, ifExists: true);
    }
    catch (GqldbException e)
    {
        Console.WriteLine($"GQLDB Error: [{e.GetType().Name}] {e.Message}");
        if (e.InnerException != null)
        {
            Console.WriteLine($"Root cause: {e.InnerException.Message}");
        }
    }

    Console.WriteLine("Done");
}
```
