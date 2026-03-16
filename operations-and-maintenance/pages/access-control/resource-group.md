# Resource Group

## Overview

A resource group defines resource quotas for users, preventing any single user from consuming all cluster resources. Administrators can create resource groups with limits on connections, concurrent queries, query timeouts, and accessible graphs, then bind users to these groups.

Users not bound to any resource group have no resource limits applied (backward compatible).

## Showing Resource Groups

To show all resource groups:

```gql
SHOW RESOURCE GROUP
```

To show a specific resource group:

```gql
SHOW RESOURCE GROUP limited_group
```

Each resource group provides the following metadata:

| <div table-width="22">Field</div> | Description |
| -- | -- |
| `name` | The name of the resource group. |
| `max_connections` | Maximum number of concurrent connections (sessions). `0` means unlimited. |
| `max_concurrent_queries` | Maximum number of concurrent queries. `0` means unlimited. |
| `max_query_timeout` | Maximum query execution time in seconds. `0` means unlimited. |
| `max_graphs` | Maximum number of graphs the user can access concurrently. `0` means unlimited. |
| `creator` | The user who created the resource group. |
| `create_time` | Creation timestamp. |

## Creating a Resource Group

To create a resource group with all options:

```gql
CREATE RESOURCE GROUP limited_group
  SET max_connections = 10,
      max_concurrent_queries = 5,
      max_query_timeout = 30,
      max_graphs = 3
```

To create a resource group with partial options (unspecified options default to `0`, meaning unlimited):

```gql
CREATE RESOURCE GROUP basic_group SET max_connections = 10
```

## Altering a Resource Group

To modify specific options of a resource group (other options remain unchanged):

```gql
ALTER RESOURCE GROUP limited_group SET max_concurrent_queries = 10
```

To reset a limit to unlimited:

```gql
ALTER RESOURCE GROUP limited_group SET max_connections = 0
```

## Dropping a Resource Group

All users must be unbound from the resource group before it can be dropped.

```gql
DROP RESOURCE GROUP limited_group
```

To suppress errors if the resource group does not exist:

```gql
DROP RESOURCE GROUP IF EXISTS limited_group
```

## Binding Users

To bind a user to a resource group:

```gql
ALTER USER analyst SET RESOURCE GROUP limited_group
```

To unbind a user from its resource group:

```gql
ALTER USER analyst REMOVE RESOURCE GROUP
```

## Resource Limits

| <div table-width="25">Limit</div> | Type | Default | Description |
| -- | -- | -- | -- |
| `max_connections` | `uint32` | `0` | Maximum concurrent sessions for the user. |
| `max_concurrent_queries` | `uint32` | `0` | Maximum queries the user can execute simultaneously. |
| `max_query_timeout` | `uint32` | `0` | Maximum query execution time in seconds. If the client sets a shorter timeout, the client's value is used. Queries exceeding this limit are automatically terminated. |
| `max_graphs` | `uint32` | `0` | Maximum number of different graphs the user can have active queries on concurrently. Accessing a graph already in the user's active list is allowed. |

A value of `0` for any limit means no restriction.

## Required Privileges

| Operation | Required Privilege |
| -- | -- |
| `CREATE RESOURCE GROUP` | `SYSTEM_CREATE_POLICY` |
| `ALTER RESOURCE GROUP` | `SYSTEM_ALTER_POLICY` |
| `SHOW RESOURCE GROUP` | `SYSTEM_SHOW_POLICY` |
| `DROP RESOURCE GROUP` | `SYSTEM_DROP_POLICY` |
| `ALTER USER SET/REMOVE RESOURCE GROUP` | `SYSTEM_ALTER_USER` |
