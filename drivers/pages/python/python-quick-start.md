# Quick Start

This guide helps you get started with the GQLDB Python driver.

## Requirements

- Python 3.9 or higher
- pip package manager

## Installation

Install the GQLDB Python driver using pip:

```bash
pip install ultipa
```

For development with additional tools:

```bash
pip install ultipa[dev]
```

## Basic Usage

```python
from gqldb import GqldbClient, GqldbConfig

# Create configuration
config = GqldbConfig(
    hosts=["localhost:9000"],
    timeout=30
)

# Create client and connect
with GqldbClient(config) as client:
    # Authenticate
    client.login("username", "password")

    # Create a graph
    client.create_graph("myGraph")
    client.use_graph("myGraph")

    # Insert data
    client.gql("""
        INSERT (a:Person {_id: "p1", name: "Alice", age: 30}),
               (b:Person {_id: "p2", name: "Bob", age: 25}),
               (a)-[:Knows {since: 2020}]->(b)
    """)

    # Query data
    response = client.gql("MATCH (n:Person) RETURN n.name, n.age")

    for row in response:
        print(f"{row.get_string(0)}: {row.get_int(1)}")

    # Clean up
    client.drop_graph("myGraph")

# Client is automatically closed when exiting the context
```

## Connection with SSL/TLS

```python
from gqldb import GqldbClient, GqldbConfig
from gqldb.config import create_ssl_context

# Create SSL context
ssl_ctx = create_ssl_context(
    cert_file="/path/to/client.crt",
    key_file="/path/to/client.key",
    ca_file="/path/to/ca.crt",
    verify=True
)

config = GqldbConfig(
    hosts=["localhost:9000"],
    ssl_context=ssl_ctx
)

with GqldbClient(config) as client:
    client.login("username", "password")
    # ... use the client
```

## Using the Config Builder

```python
from gqldb.config import ConfigBuilder

config = (ConfigBuilder()
    .hosts("localhost:9000", "192.168.1.101:9000")
    .timeout(60)
    .default_graph("myGraph")
    .pool_size(20)
    .retry_count(5)
    .build())

with GqldbClient(config) as client:
    client.login("admin", "password")
    # ... use the client
```

## Complete Example

```python
from gqldb import GqldbClient, GqldbConfig
from gqldb.errors import GqldbError, GraphNotFoundError

def main():
    config = GqldbConfig(
        hosts=["localhost:9000"],
        timeout=30,
        default_graph="socialNetwork"
    )

    try:
        with GqldbClient(config) as client:
            # Login
            session = client.login("admin", "password")
            print(f"Logged in with session ID: {session.id}")

            # Check if graph exists, create if not
            try:
                client.get_graph_info("socialNetwork")
                print("Graph exists")
            except GraphNotFoundError:
                client.create_graph("socialNetwork")
                print("Created graph")

            client.use_graph("socialNetwork")

            # Insert some data
            client.gql("""
                INSERT (alice:User {_id: "u1", name: "Alice", email: "alice@example.com"}),
                       (bob:User {_id: "u2", name: "Bob", email: "bob@example.com"}),
                       (charlie:User {_id: "u3", name: "Charlie", email: "charlie@example.com"}),
                       (alice)-[:Follows]->(bob),
                       (bob)-[:Follows]->(charlie),
                       (charlie)-[:Follows]->(alice)
            """)

            # Query users
            response = client.gql("MATCH (u:User) RETURN u.name, u.email ORDER BY u.name")
            print("\nUsers:")
            for row in response:
                print(f"  {row.get_string(0)} - {row.get_string(1)}")

            # Count relationships
            count_response = client.gql("MATCH ()-[r:Follows]->() RETURN count(r)")
            print(f"\nTotal follows: {count_response.single_int()}")

            # Find paths
            path_response = client.gql("""
                MATCH p = (a:User)-[:Follows*1..2]->(b:User)
                WHERE a._id = "u1"
                RETURN p
                LIMIT 5
            """)
            paths = path_response.alias("p").as_paths()
            print(f"\nPaths from Alice: {len(paths)}")

            # Clean up
            client.drop_graph("socialNetwork")
            print("\nGraph dropped")

    except GqldbError as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()
```

## Next Steps

- <a href="/docs/drivers/python-configuration">Configuration</a> - Learn about all configuration options
- <a href="/docs/drivers/python-connection-and-session">Connection and Session</a> - Detailed connection management
- <a href="/docs/drivers/python-executing-queries">Executing Queries</a> - Query methods and options
- <a href="/docs/drivers/python-response-processing">Response Processing</a> - Working with query results
