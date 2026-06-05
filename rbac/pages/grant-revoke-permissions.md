# Grant & Revoke Permissions

## Overview

Ultipa GQLDB provides 40 fine-grained permission operations organized by category. Each operation can be applied at one or more scopes: the database, a specific graph, a node label, an edge label, or a stored procedure within a graph.

Use `GRANT` to add permissions and `REVOKE` to remove them. Permissions are granted to roles, and roles are then assigned to users.

## Scopes

Scopes form a hierarchy from broad to specific:

| Scope syntax | Level | Description |
| -- | -- | -- |
| `ON DATABASE` | 1 | All graphs and database-wide operations |
| `ON GRAPH <name>` | 2 | Specific graph |
| `ON GRAPH *` | 2 | All graphs |
| `ON GRAPH <name> NODE <label>` | 3 |Specific node label within a graph |
| `ON GRAPH <name> EDGE <label>` | 3 | Specific edge label within a graph |
| `ON GRAPH <name> PROCEDURE <name>` | 3 | Specific stored procedure within a graph |
| `ON GRAPH <name> PROCEDURE *` | 3 | All stored procedures within a graph |

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
