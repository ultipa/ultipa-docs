# Grant & Revoke Permissions

## Overview

Assign or remove permissions from users and roles. Use `GRANT` to add permissions and `REVOKE` to remove them.

## Grant Statements

| Statement | Description |
| -- | -- |
| `GRANT ROLE TO USER` | Assign role to user |
| `REVOKE ROLE FROM USER` | Remove role from user |
| `GRANT ON DATABASE` | Grant database-wide permission |
| `GRANT ON GRAPH` | Grant graph-level permission |
| `SHOW GRANTS` | Show all grants |

## Assigning Roles to Users

**Grant role to user:**

```gql
GRANT ROLE 'data_reader' TO USER 'analyst'
```

**Revoke role from user:**

```gql
REVOKE ROLE 'data_reader' FROM USER 'analyst'
```

## Granting Permissions to Roles

**Read access to a graph:**

```gql
GRANT READ ON GRAPH 'social_network' TO ROLE 'data_reader'
```

**Write access to a graph:**

```gql
GRANT INSERT, UPDATE, DELETE ON GRAPH 'social_network' TO ROLE 'data_writer'
```

**Full access to all graphs:**

```gql
GRANT ALL ON GRAPH * TO ROLE 'admin'
```

**Database-wide read access:**

```gql
GRANT READ ON DATABASE TO ROLE 'data_reader'
```

## Fine-Grained Permissions

**Access to specific node label:**

```gql
GRANT READ ON NODE 'Person' IN GRAPH 'social_network' TO ROLE 'analytics'
```

**Access to specific edge label:**

```gql
GRANT READ ON EDGE 'KNOWS' IN GRAPH 'social_network' TO ROLE 'analytics'
```

**Access to specific property:**

```gql
GRANT READ ON PROPERTY 'salary' ON 'Person' IN GRAPH 'hr_data' TO ROLE 'hr_manager'
```

## Revoking Permissions

```gql
REVOKE INSERT ON GRAPH 'social_network' FROM ROLE 'data_writer'
```

## Showing Grants

**Show all grants:**

```gql
SHOW GRANTS
```

**Show grants for specific user:**

```gql
SHOW GRANTS FOR USER 'analyst'
```

Result:

| operation | scope | resource | effect |
| -- | -- | -- | -- |
| READ | GRAPH | social_network | ALLOW |
| READ | GRAPH | products | ALLOW |

**Show grants for specific role:**

```gql
SHOW GRANTS FOR ROLE 'data_reader'
```
