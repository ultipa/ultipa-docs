# Role-Based Access Control

## Overview

Role-Based Access Control (RBAC) allows you to manage users, roles, and permissions to control access to your database.

## Key Concepts

- **Users**: Individual accounts that can connect to the database.
- **Roles**: Named groups of permissions that can be assigned to users. Ultipa GQLDB ships with 10 system roles. 
- **Permissions**: Fine-grained operations on resources at the database, graph, node-label, edge-label, or procedure level.

## Quick Start

```gql
// Create a role
CREATE ROLE data_analyst

// Create a user
CREATE USER alice PASSWORD 'secure_password_123'

// Grant a permission to the role
GRANT READ ON GRAPH production TO ROLE data_analyst

// Assign the role to the user
GRANT ROLE data_analyst TO USER alice
```

See the following pages for detailed information:

- <a href="/docs/rbac/user-management">User Management</a>
- <a href="/docs/rbac/role-management">Role Management</a>
- <a href="/docs/rbac/grant-revoke-permissions">Grant & Revoke Permissions</a>
- <a href="/docs/rbac/best-practices">Best Practices</a>
