# Transactions

The GQLDB C# driver supports ACID transactions for ensuring data consistency across multiple operations.

## Transaction Methods

| Method | Description |
|--------|-------------|
| `BeginTransactionAsync(graphName, readOnly, timeout)` | Start a new transaction |
| `CommitAsync(transactionId)` | Commit a transaction |
| `RollbackAsync(transactionId)` | Rollback a transaction |
| `ListTransactionsAsync()` | List active transactions |
| `WithTransactionAsync(graphName, readOnly, fn)` | Execute function in transaction |

## Basic Transaction Usage

### Manual Transaction Management

```csharp
using Gqldb;

var config = new GqldbConfig { Hosts = { "localhost:60061" } };

using var client = new GqldbClient(config);
await client.LoginAsync("admin", "password");
await client.UseGraphAsync("myGraph");

// Begin transaction
var tx = await client.BeginTransactionAsync("myGraph");
Console.WriteLine($"Transaction ID: {tx.Id}");

try
{
    // Execute queries within transaction
    var txConfig = new QueryConfig { TransactionId = tx.Id };

    await client.GqlAsync("INSERT (n:Person {_id: 'p1', name: 'Alice'})", txConfig);
    await client.GqlAsync("INSERT (n:Person {_id: 'p2', name: 'Bob'})", txConfig);

    // Commit the transaction
    await client.CommitAsync(tx.Id);
    Console.WriteLine("Transaction committed");
}
catch
{
    // Rollback on error
    await client.RollbackAsync(tx.Id);
    Console.WriteLine("Transaction rolled back");
    throw;
}
```

### Using WithTransactionAsync()

The `WithTransactionAsync()` method provides automatic commit/rollback:

```csharp
await client.WithTransactionAsync("myGraph", readOnly: false, async txId =>
{
    var cfg = new QueryConfig { TransactionId = txId };

    // Debit from source
    await client.GqlAsync(
        "MATCH (a:Account {_id: 'acc1'}) SET a.balance = a.balance - 100", cfg
    );

    // Credit to destination
    await client.GqlAsync(
        "MATCH (a:Account {_id: 'acc2'}) SET a.balance = a.balance + 100", cfg
    );
});
// Auto-committed on success, rolled back on exception
```

## Transaction Class

```csharp
public class Transaction
{
    public ulong Id { get; set; }
    public ulong SessionId { get; set; }
    public string GraphName { get; set; }
    public bool ReadOnly { get; set; }
    public DateTime CreatedAt { get; set; }
    public TimeSpan Timeout { get; set; }

    public bool Committed { get; }
    public bool RolledBack { get; }
    public bool IsActive { get; }
    public bool IsExpired { get; }
    public TimeSpan Age { get; }
}
```

## Read-Only Transactions

For queries that only read data:

```csharp
// Begin read-only transaction
var tx = await client.BeginTransactionAsync("myGraph", readOnly: true);

try
{
    var config = new QueryConfig { TransactionId = tx.Id };

    var response = await client.GqlAsync("MATCH (n) RETURN count(n)", config);
    Console.WriteLine($"Count: {response.SingleInt()}");

    await client.CommitAsync(tx.Id);
}
catch
{
    await client.RollbackAsync(tx.Id);
    throw;
}
```

## Transaction Timeout

Set a timeout for transactions:

```csharp
// 60 second timeout
var tx = await client.BeginTransactionAsync("myGraph", timeout: 60);

// Using WithTransactionAsync
await client.WithTransactionAsync("myGraph", readOnly: false, async txId =>
{
    var cfg = new QueryConfig { TransactionId = txId };
    await client.GqlAsync("INSERT (n:Test {_id: 't1'})", cfg);
});
```

## Listing Transactions

```csharp
var transactions = await client.ListTransactionsAsync();

foreach (var txInfo in transactions)
{
    Console.WriteLine($"Transaction {txInfo.TransactionId}:");
    Console.WriteLine($"  Session: {txInfo.SessionId}");
    Console.WriteLine($"  Graph: {txInfo.GraphName}");
    Console.WriteLine($"  Read-only: {txInfo.ReadOnly}");
    Console.WriteLine($"  Duration: {txInfo.DurationMs}ms");
    Console.WriteLine($"  Internal TX ID: {txInfo.InternalTxId}");
}
```

## Transaction Patterns

### Try-Finally Pattern

```csharp
var tx = await client.BeginTransactionAsync("myGraph");
try
{
    var config = new QueryConfig { TransactionId = tx.Id };
    await client.GqlAsync("INSERT (n:Test {_id: 't1'})", config);
    await client.CommitAsync(tx.Id);
}
catch
{
    await client.RollbackAsync(tx.Id);
    throw;
}
```

### Retry Pattern

```csharp
async Task ExecuteWithRetry(
    GqldbClient client, string graphName,
    Func<ulong, Task> fn, int maxRetries = 3)
{
    Exception? lastError = null;

    for (int attempt = 0; attempt < maxRetries; attempt++)
    {
        try
        {
            await client.WithTransactionAsync(graphName, readOnly: false, fn);
            return;
        }
        catch (GqldbException e)
        {
            lastError = e;
            if (attempt < maxRetries - 1)
            {
                var waitTime = 100 * (int)Math.Pow(2, attempt);
                Console.WriteLine($"Transaction failed, retrying in {waitTime}ms...");
                await Task.Delay(waitTime);
            }
        }
    }

    throw lastError!;
}

// Usage
await ExecuteWithRetry(client, "myGraph", async txId =>
{
    var cfg = new QueryConfig { TransactionId = txId };
    await client.GqlAsync("INSERT (n:Test {_id: 't1'})", cfg);
});
```

## Error Handling

```csharp
using Gqldb;

try
{
    var tx = await client.BeginTransactionAsync("myGraph");
    // ... do work
    await client.CommitAsync(tx.Id);
}
catch (GqldbException e) when (e.Message.Contains("not found"))
{
    Console.WriteLine("Transaction not found (may have timed out)");
}
catch (GqldbException e) when (e.Message.Contains("transaction"))
{
    Console.WriteLine($"Transaction failed: {e.Message}");
}
catch (GqldbException e)
{
    Console.WriteLine($"GQLDB error: {e.Message}");
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

    using var client = new GqldbClient(config);
    await client.LoginAsync("admin", "password");
    await client.CreateGraphAsync("txDemo");
    await client.UseGraphAsync("txDemo");

    // Setup: Create initial data
    await client.GqlAsync(@"
        INSERT (acc1:Account {_id: 'acc1', name: 'Alice', balance: 1000}),
               (acc2:Account {_id: 'acc2', name: 'Bob', balance: 500})
    ");

    Console.WriteLine("=== Initial Balances ===");
    var response = await client.GqlAsync(
        "MATCH (a:Account) RETURN a.name, a.balance ORDER BY a.name"
    );
    foreach (var row in response.Rows)
    {
        Console.WriteLine($"  {row.GetString(0)}: ${row.GetInt(1)}");
    }

    // Successful transaction
    Console.WriteLine("\n=== Transfer $200 from Alice to Bob ===");
    await client.WithTransactionAsync("txDemo", readOnly: false, async txId =>
    {
        var cfg = new QueryConfig { TransactionId = txId };
        await client.GqlAsync(
            "MATCH (a:Account {_id: 'acc1'}) SET a.balance = a.balance - 200", cfg
        );
        await client.GqlAsync(
            "MATCH (a:Account {_id: 'acc2'}) SET a.balance = a.balance + 200", cfg
        );
    });

    Console.WriteLine("Transaction committed");
    response = await client.GqlAsync(
        "MATCH (a:Account) RETURN a.name, a.balance ORDER BY a.name"
    );
    foreach (var row in response.Rows)
    {
        Console.WriteLine($"  {row.GetString(0)}: ${row.GetInt(1)}");
    }

    // Failed transaction (rollback)
    Console.WriteLine("\n=== Attempted Transfer with Error ===");
    try
    {
        await client.WithTransactionAsync("txDemo", readOnly: false, async txId =>
        {
            var cfg = new QueryConfig { TransactionId = txId };
            await client.GqlAsync(
                "MATCH (a:Account {_id: 'acc1'}) SET a.balance = a.balance - 100", cfg
            );
            throw new InvalidOperationException("Simulated error - rollback!");
        });
    }
    catch (InvalidOperationException e)
    {
        Console.WriteLine($"Error caught: {e.Message}");
    }

    Console.WriteLine("After rollback:");
    response = await client.GqlAsync(
        "MATCH (a:Account) RETURN a.name, a.balance ORDER BY a.name"
    );
    foreach (var row in response.Rows)
    {
        Console.WriteLine($"  {row.GetString(0)}: ${row.GetInt(1)}");
    }

    // Manual transaction management
    Console.WriteLine("\n=== Manual Transaction ===");
    var tx = await client.BeginTransactionAsync("txDemo");
    Console.WriteLine($"Started transaction {tx.Id}");

    try
    {
        var cfg = new QueryConfig { TransactionId = tx.Id };
        await client.GqlAsync(
            "MATCH (a:Account {_id: 'acc1'}) SET a.balance = a.balance - 50", cfg
        );

        Console.WriteLine($"  Active: {tx.IsActive}");
        Console.WriteLine($"  Age: {tx.Age.TotalSeconds:F2}s");

        await client.CommitAsync(tx.Id);
        Console.WriteLine("  Committed");
    }
    catch
    {
        await client.RollbackAsync(tx.Id);
        Console.WriteLine("  Rolled back");
        throw;
    }

    // List transactions (should be empty now)
    Console.WriteLine("\n=== Active Transactions ===");
    var activeTxs = await client.ListTransactionsAsync();
    Console.WriteLine($"  Count: {activeTxs.Count}");

    // Cleanup
    await client.DropGraphAsync("txDemo");
}
```
