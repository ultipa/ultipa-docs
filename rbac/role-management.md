# Role Management

## Overview

Create roles to group permissions, then assign roles to users. Roles make it easy to manage access for groups of users with similar responsibilities.

**Built-in System Roles:**

| Role | Description | Permissions held |
| -- | -- | -- |
| `admin` | Full superuser access to all operations | `ADMIN` on database |
| `reader` | Read-only access to all data | `READ` |
| `writer` | Write access to all data | `INSERT`, `UPDATE`, `DELETE` |
| `data_admin` | Full data access (read, insert, update, delete, merge) | `ALL_DATA` |
| `analyst` | Run procedures and algorithms, and read results | `EXECUTE_PROCEDURE`, `EXECUTE_ALGORITHM`, `SHOW_PROCEDURE`, `SHOW_SCHEMA` |
| `schema_admin` | Schema administration (DDL) | `ADMIN` on `GRAPH *` |
| `backup_admin` | Backup and restore operations | `BACKUP`, `RESTORE`, `SHOW_SCHEMA` |
| `procedure_admin` | Stored procedure lifecycle management | `CREATE_PROCEDURE`, `DROP_PROCEDURE`, `EXECUTE_PROCEDURE`, `SHOW_PROCEDURE` |
| `ops_admin` | Operations (task/query management, statistics) | `MANAGE_TASK`, `MANAGE_QUERY`, `ANALYZE`, `SHOW_SCHEMA` |
| `security_admin` | User, role, and grant management | `USER_MANAGEMENT`, `ROLE_MANAGEMENT`, `GRANT_MANAGEMENT`, `SHOW_SCHEMA` |

Run `SHOW GRANTS FOR ROLE <name>` to see exactly what a built-in role holds. System roles cannot be deleted.

Three of them are narrower than their names suggest, and a role is often combined with another:

- **`analyst` cannot write algorithm results.** It runs, streams and reports, but `.write` mode needs `UPDATE` on the whole graph. Grant an analyst that writes results the `writer` role as well, or `UPDATE` on the graph.
- **`schema_admin` holds `ADMIN` on `GRAPH *`, which is graph scope.** It does not cover the account statements, `BACKUP`, `RESTORE`, `LOAD CSV`, or seeing other accounts' queries, transactions and tasks — those need the right at **database** scope. Use `security_admin` for accounts, `backup_admin` for backup and restore, and `ops_admin` for queries and tasks.
- **`backup_admin` is also what `LOAD CSV` needs**, because `LOAD CSV` reads files on the server and fetches URLs: it requires `RESTORE` at database scope, and the `INTO` form additionally requires `INSERT` on the graph.

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