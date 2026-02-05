# Role-Based Access Control

## Overview

Role-Based Access Control (RBAC) allows you to manage users, roles, and permissions to control access to your database.

**Key Concepts:**

- **Users** - Individual accounts that can connect to the database
- **Roles** - Named groups of permissions that can be assigned to users
- **Permissions** - Specific operations (READ, INSERT, UPDATE, DELETE) on resources

**Built-in System Roles:**

| Role | Description |
| -- | -- |
| `admin` | Full database access |
| `reader` | Read-only access |
| `writer` | Read and write access |
| `schema_admin` | Schema management |

## Quick Start

```gql
// Create a role
CREATE ROLE 'data_analyst'

// Create a user
CREATE USER 'alice' WITH PASSWORD 'secure_password_123'

// Grant permissions to role
GRANT READ ON GRAPH 'production' TO ROLE 'data_analyst'

// Assign role to user
GRANT ROLE 'data_analyst' TO USER 'alice'
```

See the following pages for detailed information:

- <a href="/docs/rbac/user-management">User Management</a>
- <a href="/docs/rbac/role-management">Role Management</a>
- <a href="/docs/rbac/grant-revoke">Grant & Revoke Permissions</a>
- <a href="/docs/rbac/permission-levels">Permission Levels</a>
