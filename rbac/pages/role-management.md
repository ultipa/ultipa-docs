# Role Management

## Overview

Create roles to group permissions. Roles make it easy to manage access for groups of users.

**Built-in System Roles:**

| Role | Description |
| -- | -- |
| `admin` | Full database access |
| `reader` | Read-only access |
| `writer` | Read and write access |
| `schema_admin` | Schema management |

## Role Statements

| Statement | Description |
| -- | -- |
| `CREATE ROLE` | Create a new role |
| `ALTER ROLE RENAME TO` | Rename a role |
| `ALTER ROLE SET DESCRIPTION` | Update role description |
| `DROP ROLE` | Delete a role |
| `SHOW ROLES` | List all roles |
| `SHOW ROLE` | Show specific role details |

## Creating Roles

```gql
CREATE ROLE 'data_reader'
```

**With description:**

```gql
CREATE ROLE 'schema_manager' DESCRIPTION 'Can modify database schema'
```

## Altering Roles

**Rename a role:**

```gql
ALTER ROLE 'data_reader' RENAME TO 'analytics_reader'
```

**Update description:**

```gql
ALTER ROLE 'data_reader' SET DESCRIPTION 'Read-only access for analytics'
```

## Dropping Roles

```gql
DROP ROLE 'data_reader'
```

Use `IF EXISTS` to avoid errors:

```gql
DROP ROLE IF EXISTS 'data_reader'
```

## Showing Roles

**List all roles:**

```gql
SHOW ROLES
```

Result:

| name | description |
| -- | -- |
| admin | Full database access |
| reader | Read-only access |
| writer | Read and write access |
| schema_admin | Schema management |

**Show specific role:**

```gql
SHOW ROLE admin
```
