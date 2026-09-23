# Grant & Revoke Permissions

## Overview

Ultipa GQLDB provides 40 fine-grained permission operations organized by category. Each operation can be applied at one or more scopes: the database, a specific graph, a node label, an edge label, or a stored procedure within a graph.

When a user attempts an operation, access is allowed only if one of their roles has been granted that permission for the requested scope. Otherwise it is rejected. This is **default-deny**: a user starts with no access and gains only what is explicitly granted.

- `GRANT` allows a permission.
- `REVOKE` removes a grant, returning that permission to the default-denied state.

## Scopes

Scopes form a hierarchy from broad to specific:

| Scope syntax | Level | Description |
| -- | -- | -- |
| `ON DATABASE` | 1 | All graphs and database-wide operations |
| `ON GRAPH <name>` | 2 | Specific graph |
| `ON GRAPH *` | 2 | All graphs |
| `ON GRAPH <name> NODE <label>` | 3 | Specific node label within a graph |
| `ON GRAPH <name> EDGE <label>` | 3 | Specific edge label within a graph |
| `ON GRAPH <name> PROCEDURE <name>` | 3 | Specific stored procedure within a graph |
| `ON GRAPH <name> PROCEDURE *` | 3 | All stored procedures within a graph |

### Choosing the Right Scope

A grant at graph scope does not stand in for one at database scope. These operations are checked at **database scope only**, and a grant of `ALL` or `ADMIN` on `GRAPH *` does not cover them:

| Operation | Needed at database scope for |
| -- | -- |
| `USER_MANAGEMENT`, `ROLE_MANAGEMENT`, `GRANT_MANAGEMENT` | Every account and permission statement |
| `BACKUP`, `RESTORE` | `BACKUP DATABASE`, `RESTORE DATABASE`, and `LOAD CSV` (which needs `RESTORE`) |
| `MANAGE_QUERY`, `MANAGE_TASK` | Seeing, cancelling or stopping **other accounts'** queries, transactions and tasks |

Without `MANAGE_QUERY` or `MANAGE_TASK`, an account still sees, cancels and deletes its **own** queries and tasks, and `COMMIT` / `ROLLBACK` / the savepoint statements act only on its own transaction. Passwords, credentials and API keys appear as `'***'` in the query list.

### How a Label-Scoped Grant Behaves

A grant scoped to `NODE <label>` or `EDGE <label>` narrows what the account can read, and **an unqualified query is narrowed rather than refused**. With `READ ON GRAPH socialNet NODE movie` and nothing else:

```gql
MATCH (n:movie) RETURN count(n)       -- 92, the movie nodes
MATCH (n:account) RETURN count(n)     -- permission denied
MATCH (n) RETURN count(n)             -- 92: narrowed to the permitted label, not an error
```

The last case is worth knowing: a query that names no label returns **fewer rows** instead of failing, so a result that looks short may be the permission boundary rather than missing data.

### Account Statements and Transactions

Account and permission statements cannot run inside a transaction:

```gql
START TRANSACTION
CREATE USER alice PASSWORD 'secure_password_123'
--   CREATE USER changes accounts or permissions, which cannot be done inside a transaction:
--   run it outside the transaction
```

Run them outside the transaction. `DROP USER` and `ALTER USER … RENAME TO` roll back any transactions the account had open.

## Permission Operations

List all available operations and their valid scopes:

```gql
SHOW PERMISSIONS
```

Returns columns `operation`, `description`, and `valid_scopes`.

### Data Operations

| Operation | Description | Valid Scopes |
| -- | -- | -- |
| `READ` | Query and read data | DATABASE, GRAPH, NODE, EDGE |
| `INSERT` | Insert new nodes and edges | DATABASE, GRAPH, NODE, EDGE |
| `UPDATE` | Update existing data | DATABASE, GRAPH, NODE, EDGE |
| `DELETE` | Delete nodes and edges | DATABASE, GRAPH, NODE, EDGE |
| `MERGE` | Merge (upsert) operations | DATABASE, GRAPH |
| `ALL_DATA` | All data ops (READ + INSERT + UPDATE + DELETE + MERGE) | DATABASE, GRAPH |

### Schema (DDL) Operations

| Operation | Description | Valid Scopes |
| -- | -- | -- |
| `CREATE_GRAPH` | Create graphs | DATABASE, GRAPH |
| `DROP_GRAPH` | Drop graphs | DATABASE, GRAPH |
| `ALTER_GRAPH` | Alter graphs (rename, set mode, add/drop types) | GRAPH |
| `TRUNCATE_GRAPH` | Truncate graph labels | GRAPH |
| `CREATE_INDEX` | Create indexes (regular, vector, fulltext) | GRAPH |
| `DROP_INDEX` | Drop indexes | GRAPH |
| `CREATE_CONSTRAINT` | Create constraints | GRAPH |
| `DROP_CONSTRAINT` | Drop constraints | GRAPH |
| `CREATE_PROJECTION` | Create projections | GRAPH |
| `DROP_PROJECTION` | Drop projections | GRAPH |
| `CREATE_TRIGGER` | Create triggers | GRAPH |
| `DROP_TRIGGER` | Drop triggers | GRAPH |
| `CREATE_GRAPH_TYPE` | Create graph types | GRAPH |
| `DROP_GRAPH_TYPE` | Drop graph types | GRAPH |
| `SHOW_SCHEMA` | View schema metadata | DATABASE, GRAPH |
| `ALL_SCHEMA` | All DDL schema operations | DATABASE, GRAPH |

### Backup & Restore

| Operation | Description | Valid Scopes |
| -- | -- | -- |
| `BACKUP` | Backup graphs or database | DATABASE |
| `RESTORE` | Restore graphs or database | DATABASE |

### Stored Procedures & Algorithms

| Operation | Description | Valid Scopes |
| -- | -- | -- |
| `CREATE_PROCEDURE` | Create stored procedures | DATABASE, GRAPH, PROCEDURE |
| `DROP_PROCEDURE` | Drop stored procedures | DATABASE, GRAPH, PROCEDURE |
| `EXECUTE_PROCEDURE` | Execute stored procedures (`CALL`) | DATABASE, GRAPH, PROCEDURE |
| `SHOW_PROCEDURE` | View procedure definitions | DATABASE, GRAPH, PROCEDURE |
| `EXECUTE_ALGORITHM` | Execute built-in algorithms (`CALL algo.*`) | DATABASE |

### Task & Query Management

| Operation | Description | Valid Scopes |
| -- | -- | -- |
| `MANAGE_TASK` | `TOP`, `KILL`, `SHOW TASK`, `DELETE TASK` | DATABASE |
| `MANAGE_QUERY` | `TOP QUERIES`, `KILL QUERY`, `SHOW QUERIES` | DATABASE |

### Security Management

| Operation | Description | Valid Scopes |
| -- | -- | -- |
| `USER_MANAGEMENT` | `CREATE` / `ALTER` / `DROP` / `SHOW USER` | DATABASE |
| `ROLE_MANAGEMENT` | `CREATE` / `ALTER` / `DROP` / `SHOW ROLE` | DATABASE |
| `GRANT_MANAGEMENT` | `GRANT` / `REVOKE` / `SHOW GRANTS` | DATABASE |

### Infrastructure

| Operation | Description | Valid Scopes |
| -- | -- | -- |
| `MANAGE_ONTOLOGY` | Ontology management (PREFIX, CLASS, etc.) | GRAPH |
| `MANAGE_SERVICE` | Federation service management | GRAPH |
| `MANAGE_COMPUTE` | Compute engine management | GRAPH |
| `ANALYZE` | Statistics and maintenance (`ANALYZE`, `COMPACT`) | DATABASE, GRAPH |

### Wildcards

| Operation | Description |
| -- | -- |
| `*` or `ALL` | Matches all operations |
| `ADMIN` | Legacy superuser (matches all operations) |

### Functions and Procedures That Need a Right

A function or procedure that changes state is checked against the right the equivalent statement needs, not merely against the right to call it:

| Call | Right needed |
| -- | -- |
| `DB.BACKUP` | `BACKUP` |
| `DB.RESTORE` | `RESTORE` |
| The repair functions | `ANALYZE` |
| `DB.DELETE_ORPHANS_EDGES` | `DELETE` on the whole graph |
| `AI.SET_*`, `AI.SAVE_SKILL`, `AI.DROP_SKILL`, `AI.RATE`, `AI.TRACE`, `AI.TRACES` | `ADMIN` |
| `ft.load`, `ft.unload` | `CREATE_INDEX` |
| `ml.create_pipeline`, `ml.add_feature`, `ml.configure_split`, `ml.drop_pipeline`, `ml.drop_model` | `ALTER_GRAPH` |
| `ml.list_models`, `ml.list_pipelines`, and the prediction calls | `EXECUTE_ALGORITHM` |

Three consequences worth knowing:

- **A `CHECK` constraint cannot call any of them.** The condition must be a plain expression over the row's properties.
- **A trigger body cannot call a function that needs a right.** A write that fires such a trigger fails, for every account.
- **A stored procedure runs with its caller's rights**, including the rights needed by the functions its body calls. Creating the procedure still succeeds; the call is what fails.

Because `ml.list_models` and `ml.list_pipelines` need only the right to run an algorithm, any account that may run algorithms can read the model catalog — model names, pipelines, accuracy and training-set sizes.

## Granting Roles to Users

```gql
GRANT ROLE data_reader TO USER alice
```

## Revoking Roles from Users

```gql
REVOKE ROLE data_reader FROM USER alice
```

## Granting Permissions to Roles

```syntax
<grant statement> ::=
  "GRANT" <operation> [ { "," <operation> } ...] "ON" <scope> "TO" [ "ROLE" ] <role name>
```

Grant read access on a specific graph:

```gql
GRANT READ ON GRAPH social_network TO ROLE data_reader
```

Grant multiple operations in one statement:

```gql
GRANT INSERT, UPDATE, DELETE ON GRAPH social_network TO ROLE data_writer
```

Wildcard operation (all permissions):

```gql
GRANT * ON GRAPH * TO ROLE custom_admin
```

Database-wide grants:

```gql
GRANT READ ON DATABASE TO ROLE global_reader
GRANT BACKUP ON DATABASE TO ROLE backup_operator
GRANT USER_MANAGEMENT ON DATABASE TO ROLE security_team
```

Grant on all graphs:

```gql
GRANT READ ON GRAPH * TO ROLE global_reader
```

Label-level access:

```gql
GRANT READ ON GRAPH social_network NODE Person TO ROLE analytics
GRANT INSERT ON GRAPH social_network EDGE KNOWS TO ROLE analytics
```

Procedure-level access:

```gql
GRANT EXECUTE_PROCEDURE ON GRAPH sales PROCEDURE calc_revenue TO ROLE analyst
GRANT EXECUTE_PROCEDURE ON GRAPH sales PROCEDURE * TO ROLE proc_runner
```

## Revoking Permissions from Roles

```syntax
<revoke statement> ::=
  "REVOKE" <operation> [ { "," <operation> } ...] "ON" <scope> "FROM" [ "ROLE" ] <role name>
```

```gql
REVOKE INSERT ON GRAPH social_network FROM ROLE data_writer
REVOKE READ ON GRAPH social_network NODE Person FROM ROLE analytics
```

## Showing Grants

Show all grants in the database:

```gql
SHOW GRANTS
```

Show grants for a specific user (includes grants inherited from all assigned roles):

```gql
SHOW GRANTS FOR USER alice
```

Show grants for a specific role:

```gql
SHOW GRANTS FOR ROLE data_reader
```

Result columns:

| Column | Description |
| -- | -- |
| `operation` | The permission operation, e.g., `READ`, `INSERT`, `CREATE_INDEX` |
| `scope` | Scope level: `DATABASE`, `GRAPH`, `NODE`, `EDGE`, or `PROCEDURE` |
| `resource` | The specific resource the grant applies to (graph name, label, procedure name, or `*`) |
| `effect` | `ALLOW` for grants issued through GQL |

## Examples

### Complete RBAC Setup

```gql
// Create roles
CREATE ROLE app_readonly
CREATE ROLE app_readwrite
CREATE ROLE app_admin

// Create users
CREATE USER frontend_service PASSWORD 'frontend_pwd_12345'
CREATE USER backend_service PASSWORD 'backend_pwd_12345'
CREATE USER admin_user PASSWORD 'admin_pwd_12345'

// Grant permissions to roles
GRANT READ ON GRAPH production TO ROLE app_readonly
GRANT READ, INSERT, UPDATE, DELETE ON GRAPH production TO ROLE app_readwrite
GRANT * ON GRAPH * TO ROLE app_admin

// Assign roles to users
GRANT ROLE app_readonly TO USER frontend_service
GRANT ROLE app_readwrite TO USER backend_service
GRANT ROLE app_admin TO USER admin_user
```

### Label-Level Access Control

```gql
// Analytics team: read Person nodes and KNOWS edges only
CREATE ROLE analytics
GRANT READ ON GRAPH social_network NODE Person TO ROLE analytics
GRANT READ ON GRAPH social_network EDGE KNOWS TO ROLE analytics
```

### Procedure-Level Access Control

```gql
// Allow analyst to run a specific stored procedure
CREATE ROLE revenue_analyst
GRANT EXECUTE_PROCEDURE ON GRAPH sales PROCEDURE calc_revenue TO ROLE revenue_analyst
```
