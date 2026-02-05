# Permission Levels

## Overview

Permission levels control what actions users can perform on database resources.

## Operations

| Operation | Description |
| -- | -- |
| `READ` | Query and read data |
| `INSERT` | Insert new nodes and edges |
| `UPDATE` | Update existing data |
| `DELETE` | Delete nodes and edges |
| `ADMIN` | Administrative operations (includes all above) |
| `ALL` or `*` | Alias for ADMIN - all operations |

## Resource Scopes

| Scope | Syntax | Description |
| -- | -- | -- |
| DATABASE | `ON DATABASE` | Full database access |
| GRAPH | `ON GRAPH 'name'` or `ON GRAPH *` | Access to specific or all graphs |
| NODE | `ON NODE 'label' IN GRAPH 'name'` | Access to specific node label |
| EDGE | `ON EDGE 'label' IN GRAPH 'name'` | Access to specific edge label |
| PROPERTY | `ON PROPERTY 'prop' ON 'label' IN GRAPH 'name'` | Fine-grained property access |

> **Permission Precedence:** DENY takes precedence over ALLOW.

## Examples

### Complete RBAC Setup

```gql
// Create roles
CREATE ROLE 'app_readonly'
CREATE ROLE 'app_readwrite'
CREATE ROLE 'app_admin'

// Create users
CREATE USER 'frontend_service' WITH PASSWORD 'frontend_pwd'
CREATE USER 'backend_service' WITH PASSWORD 'backend_pwd'
CREATE USER 'admin_user' WITH PASSWORD 'admin_pwd'

// Grant permissions to roles
GRANT READ ON GRAPH 'production' TO ROLE 'app_readonly'
GRANT READ, INSERT, UPDATE, DELETE ON GRAPH 'production' TO ROLE 'app_readwrite'
GRANT ALL ON GRAPH * TO ROLE 'app_admin'

// Assign roles to users
GRANT ROLE 'app_readonly' TO USER 'frontend_service'
GRANT ROLE 'app_readwrite' TO USER 'backend_service'
GRANT ROLE 'app_admin' TO USER 'admin_user'
```

### Property-Level Access Control

```gql
// HR can see salary, others cannot

// Create roles
CREATE ROLE 'hr_staff'
CREATE ROLE 'general_staff'

// General staff: can read Person but NOT salary property
GRANT READ ON NODE 'Person' IN GRAPH 'hr_data' TO ROLE 'general_staff'
GRANT READ ON PROPERTY 'name' ON 'Person' IN GRAPH 'hr_data' TO ROLE 'general_staff'
GRANT READ ON PROPERTY 'email' ON 'Person' IN GRAPH 'hr_data' TO ROLE 'general_staff'
GRANT READ ON PROPERTY 'department' ON 'Person' IN GRAPH 'hr_data' TO ROLE 'general_staff'

// HR staff: full read access including salary
GRANT READ ON NODE 'Person' IN GRAPH 'hr_data' TO ROLE 'hr_staff'
GRANT READ ON PROPERTY 'salary' ON 'Person' IN GRAPH 'hr_data' TO ROLE 'hr_staff'
```

## Best Practices

**Principle of Least Privilege**
- Grant only the minimum permissions needed
- Use specific resource grants instead of wildcards
- Regular audit of permissions

**Role Design**
- Create roles based on job functions
- Avoid user-specific permissions when possible
- Use the built-in roles (admin, reader, writer) as starting points

**Password Management**
- Enforce strong password policies (6+ characters minimum)
- Rotate service account passwords regularly
- Use separate accounts for different environments

**Account Security**
- Deactivate accounts instead of deleting for audit trails
- The admin user cannot be deleted (protected)
- The admin role is immutable

### Audit Queries

```gql
// Audit user permissions
SHOW GRANTS FOR USER 'analyst'

// List all users and their status
SHOW USERS

// List all roles
SHOW ROLES
```

### Account Management

```gql
// Rotate service account password
ALTER USER 'backend_service' SET PASSWORD 'new_secure_password_789'

// Deactivate suspicious account (preserves audit trail)
ALTER USER 'suspicious_user' SET STATUS INACTIVE

// Reactivate after investigation
ALTER USER 'suspicious_user' SET STATUS ACTIVE
```
