# Role-Based Access Control

## Overview

Role-Based Access Control (RBAC) allows you to manage users, roles, and permissions to control access to your database.

## Key Concepts

- **Users**: Individual accounts that can connect to the database. Authentication is either by a local password (`CREATE USER … PASSWORD`) or, optionally, by binding against an external LDAP / Active Directory.
- **Roles**: Named groups of permissions that can be assigned to users. Ultipa GQLDB ships with 10 system roles.
- **Permissions**: Fine-grained operations on resources at the database, graph, node-label, edge-label, or procedure level.

## Quick Start

```gql
-- Create a role
CREATE ROLE data_analyst

-- Create a user
CREATE USER alice PASSWORD 'secure_password_123'

-- Grant a permission to the role
GRANT READ ON GRAPH production TO ROLE data_analyst

-- Assign the role to the user
GRANT ROLE data_analyst TO USER alice
```

See the following pages for detailed information:

- <a href="/docs/rbac/user-management">User Management</a>
- <a href="/docs/rbac/role-management">Role Management</a>
- <a href="/docs/rbac/grant-revoke-permissions">Grant & Revoke Permissions</a>
- <a href="/docs/rbac/ldap-authentication">LDAP / Active Directory</a>
- <a href="/docs/rbac/best-practices">Best Practices</a>

## Error Codes

RBAC and authentication errors use codes in the `7000`–`7999` range:

| Code | Description |
| -- | -- |
| `7000` | Permission denied |
| `7001` | Authentication failed (invalid credentials) |
| `7002` | Session expired |
| `7003` | Role not found |
| `7004` | User not found |
| `7005` | User account disabled |
| `7006` | Invalid permission specification |
| `7007` | Role in use (assigned to users) |
| `7008` | Cannot delete system role |
| `7009` | User already exists |
| `7010` | Role already exists |
| `7011` | Session not found |
| `7012` | Invalid password |
| `7013` | Cannot delete admin user |
| `7014` | System graph protected |
| `7015` | Insufficient privilege |
