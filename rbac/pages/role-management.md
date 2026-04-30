# Role Management

## Overview

Create roles to group permissions, then assign roles to users. Roles make it easy to manage access for groups of users with similar responsibilities.

**Built-in System Roles:**

| Role | Description | Inherits |
| -- | -- | -- |
| `admin` | Full superuser access to all operations | — |
| `reader` | Read-only access to all data | — |
| `writer` | Read and write access to all data | `reader` |
| `data_admin` | Full data access (read, insert, update, delete, merge) | `writer` |
| `analyst` | Read data + execute procedures and algorithms | `reader` |
| `schema_admin` | Schema administration (all DDL) | — |
| `backup_admin` | Backup and restore operations | — |
| `procedure_admin` | Stored procedure lifecycle management | — |
| `ops_admin` | Operations (task/query management, statistics) | — |
| `security_admin` | User, role, and grant management | — |

System roles cannot be deleted.

## Showing Roles

List all roles:

```gql
SHOW ROLES
```

Show a specific role:

```gql
SHOW ROLE admin
```

Result columns:

| Column | Description |
| -- | -- |
| `name` | Role name |
| `description` | Role description (empty for user-created roles) |
| `is_system` | `true` for built-in roles that cannot be deleted, `false` otherwise |
| `permissions` | Operations currently granted to the role |
| `created_at` | Timestamp when the role was created |


## Creating Roles

Role names are unquoted identifiers — they must start with a letter or underscore, and may contain letters, digits, and underscores after the first character.

```gql
CREATE ROLE data_reader
```

## Altering Roles

Rename a role:

```gql
ALTER ROLE data_reader RENAME TO analytics_reader
```

## Dropping Roles

```gql
DROP ROLE data_reader
```

Use `IF EXISTS` to avoid errors if the role does not exist:

```gql
DROP ROLE IF EXISTS data_reader
```