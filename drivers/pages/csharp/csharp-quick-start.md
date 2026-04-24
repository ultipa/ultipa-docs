# Quick Start

This guide helps you get started with the GQLDB C# driver. It requires **.NET 6.0 or higher**.

## Installation

Install the GQLDB C# driver via NuGet:

```bash
dotnet add package GqldbDriver
```

> Check <a href="https://www.nuget.org/packages/GqldbDriver" target="_blank">NuGet</a> for the latest version. To install a specific version: `dotnet add package GqldbDriver --version 6.0.0`

## Basic Usage

```csharp
using Gqldb;

// Create configuration
var config = new GqldbConfig
{
    Hosts = { "localhost:60061" },
    TimeoutSeconds = 30
};

// Create client and connect
using var client = new GqldbClient(config);

// Authenticate
await client.LoginAsync("username", "password");

// Create a graph
await client.CreateGraphAsync("myGraph");
await client.UseGraphAsync("myGraph");

// Insert data
await client.GqlAsync(@"
    INSERT (a:Person {_id: 'p1', name: 'Alice', age: 30}),
           (b:Person {_id: 'p2', name: 'Bob', age: 25}),
           (a)-[:Knows {since: 2020}]->(b)
");

// Query data
var response = await client.GqlAsync("MATCH (n:Person) RETURN n.name, n.age");

foreach (var row in response.Rows)
{
    Console.WriteLine($"{row.GetString(0)}: {row.GetInt(1)}");
}

// Clean up
await client.DropGraphAsync("myGraph");
```

## Connection with TLS

```csharp
using Gqldb;

var config = new GqldbConfig
{
    Hosts = { "localhost:60061" },
    UseTls = true
};

using var client = new GqldbClient(config);
await client.LoginAsync("username", "password");
// ... use the client
```

## Using the Config Builder

```csharp
using Gqldb;

var config = new ConfigBuilder()
    .Hosts("localhost:60061", "192.168.1.101:9000")
    .Timeout(60)
    .DefaultGraph("myGraph")
    .PoolSize(20)
    .RetryCount(5)
    .Build();

using var client = new GqldbClient(config);
await client.LoginAsync("admin", "password");
// ... use the client
```

## Complete Example

```csharp
using Gqldb;
using Gqldb.Types;

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

        // Login
        var session = await client.LoginAsync("admin", "password");
        Console.WriteLine($"Logged in with session ID: {session.Id}");

        // Check if graph exists, create if not
        if (!await client.HasGraphAsync("socialNetwork"))
        {
            await client.CreateGraphAsync("socialNetwork");
            Console.WriteLine("Created graph");
        }

        await client.UseGraphAsync("socialNetwork");

        // Insert some data
        await client.GqlAsync(@"
            INSERT (alice:User {_id: 'u1', name: 'Alice', email: 'alice@example.com'}),
                   (bob:User {_id: 'u2', name: 'Bob', email: 'bob@example.com'}),
                   (charlie:User {_id: 'u3', name: 'Charlie', email: 'charlie@example.com'}),
                   (alice)-[:Follows]->(bob),
                   (bob)-[:Follows]->(charlie),
                   (charlie)-[:Follows]->(alice)
        ");

        // Query users
        var response = await client.GqlAsync(
            "MATCH (u:User) RETURN u.name, u.email ORDER BY u.name"
        );
        Console.WriteLine("\nUsers:");
        foreach (var row in response.Rows)
        {
            Console.WriteLine($"  {row.GetString(0)} - {row.GetString(1)}");
        }

        // Count relationships
        var countResponse = await client.GqlAsync(
            "MATCH ()-[r:Follows]->() RETURN count(r)"
        );
        Console.WriteLine($"\nTotal follows: {countResponse.SingleInt()}");

        // Find paths
        var pathResponse = await client.GqlAsync(@"
            MATCH p = (a:User)-[:Follows]->{1,2}(b:User)
            WHERE a._id = 'u1'
            RETURN p
            LIMIT 5
        ");
        var paths = pathResponse.Alias("p").AsPaths();
        Console.WriteLine($"\nPaths from Alice: {paths.Count}");

        // Clean up
        await client.DropGraphAsync("socialNetwork");
        Console.WriteLine("\nGraph dropped");
    }
    catch (GqldbException e)
    {
        Console.WriteLine($"Error: {e.Message}");
    }
}
```

## Next Steps

- <a href="/docs/drivers/csharp-configuration">Configuration</a> - Learn about all configuration options
- <a href="/docs/drivers/csharp-connection-and-session">Connection and Session</a> - Detailed connection management
- <a href="/docs/drivers/csharp-executing-queries">Executing Queries</a> - Query methods and options
- <a href="/docs/drivers/csharp-response-processing">Response Processing</a> - Working with query results
