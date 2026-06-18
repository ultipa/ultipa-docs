# User Management

## Overview

Create and manage database users.

## Showing Users

List all users:

```gql
SHOW USERS
```

Result columns:

| Column | Description |
| -- | -- |
| `username` | User name |
| `status` | Always `ACTIVE` for users created through DCL. |
| `roles` | List of role names assigned to the user |
| `created_at` | Timestamp when the user was created |
| `comment` | Free-form comment attached to the user (empty string if none) |

Show a specific user:

```gql
SHOW USER alice
```

## Identifying the Current User

To get information about the user authenticated for the current session, use the `CURRENT_USER` bare keyword. It returns a record with `username`, `roles`, and `is_admin` fields:

```gql
RETURN CURRENT_USER
```

Access individual fields:

```gql
RETURN CURRENT_USER.username, CURRENT_USER.is_admin
```

## Creating Users

User names are unquoted identifiers, they must start with a letter or underscore, and may contain letters, digits, and underscores after the first character. Passwords are string literals (enclosed in single quotes, double quotes, or backticks) and must be 6 to 128 characters.

```gql
CREATE USER alice PASSWORD 'secure_password_123'
```

The optional `WITH` keyword is also accepted:

```gql
CREATE USER alice WITH PASSWORD 'secure_password_123'
```

## Changing User Password

Change a user's password:

```gql
ALTER USER alice SET PASSWORD 'new_password_456'
```

## Setting a Comment

Comments are free-form descriptive metadata attached to a user (e.g., role description, team, contact info).

```gql
-- Set or update the comment
ALTER USER alice COMMENT 'Primary data engineer'

-- Clear the comment
ALTER USER alice COMMENT ''
```

## Dropping Users

```gql
DROP USER alice
```

Use `IF EXISTS` to avoid errors if the user does not exist:

```gql
DROP USER IF EXISTS alice
```
