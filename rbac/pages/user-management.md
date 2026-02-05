# User Management

## Overview

Create and manage database users. Usernames must be 1-64 characters, alphanumeric with underscores and dashes. Passwords must be 6-128 characters.

## User Statements

| Statement | Description |
| -- | -- |
| `CREATE USER` | Create a new user |
| `ALTER USER SET PASSWORD` | Change user password |
| `ALTER USER SET STATUS` | Activate or deactivate user |
| `ALTER USER RENAME TO` | Rename a user |
| `DROP USER` | Delete a user |
| `SHOW USERS` | List all users |
| `SHOW USER` | Show specific user details |

## Creating Users

```gql
CREATE USER 'analyst' WITH PASSWORD 'secure_password_123'
```

## Altering Users

**Change password:**

```gql
ALTER USER 'analyst' SET PASSWORD 'new_password_456'
```

**Deactivate a user:**

```gql
ALTER USER 'analyst' SET STATUS INACTIVE
```

**Reactivate a user:**

```gql
ALTER USER 'analyst' SET STATUS ACTIVE
```

**Rename a user:**

```gql
ALTER USER 'analyst' RENAME TO 'senior_analyst'
```

## Dropping Users

```gql
DROP USER 'analyst'
```

Use `IF EXISTS` to avoid errors:

```gql
DROP USER IF EXISTS 'analyst'
```

## Showing Users

**List all users:**

```gql
SHOW USERS
```

Result:

| username | status | created_at |
| -- | -- | -- |
| admin | ACTIVE | 2024-01-01T00:00:00 |
| analyst | ACTIVE | 2024-01-15T10:30:00 |

**Show specific user:**

```gql
SHOW USER analyst
```
