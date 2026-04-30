# Best Practices

## Overview

Security best practices for Role-Based Access Control in Ultipa GQLDB.

## Principle of Least Privilege

Grant only the minimum permissions each role actually needs. Use specific resource grants instead of wildcards, and audit permissions regularly.

```gql
// Good: specific graph access
GRANT READ ON GRAPH production TO ROLE analyst

// Avoid: wildcard access unless truly necessary
GRANT READ ON GRAPH * TO ROLE analyst
```

## Role Design

Create roles based on job functions, not individuals. Use the built-in roles as a starting point and compose custom roles on top.

```gql
// Create roles for distinct job functions
CREATE ROLE data_analyst
CREATE ROLE data_engineer
CREATE ROLE app_service

// Compose: analyst inherits read-only access from the built-in reader role,
// then add procedure execution
GRANT EXECUTE_ALGORITHM ON DATABASE TO ROLE data_analyst
GRANT EXECUTE_PROCEDURE ON GRAPH production PROCEDURE * TO ROLE data_analyst
```

## Separate Security from Data Administration

Avoid combining data access with user/role administration in a single role.

```gql
// Security admin manages users but cannot read data
GRANT USER_MANAGEMENT ON DATABASE TO ROLE sec_admin
GRANT ROLE_MANAGEMENT ON DATABASE TO ROLE sec_admin
GRANT GRANT_MANAGEMENT ON DATABASE TO ROLE sec_admin

// Data admin manages data but cannot manage users
GRANT ALL_DATA ON DATABASE TO ROLE data_team_admin
```

## Fine-Grained DDL Control

Grant specific schema operations rather than full DDL when possible.

```gql
// Allow creating and dropping indexes but not graphs
CREATE ROLE index_manager
GRANT CREATE_INDEX ON GRAPH sales TO ROLE index_manager
GRANT DROP_INDEX ON GRAPH sales TO ROLE index_manager
GRANT SHOW_SCHEMA ON GRAPH sales TO ROLE index_manager
```

## Dedicated Backup Operator

Use the built-in `backup_admin` role for backup automation, so the backup account does not have data-read access.

```gql
CREATE USER backup_bot PASSWORD 'backup_bot_strong_password'
GRANT ROLE backup_admin TO USER backup_bot
```

## Password Management

- Enforce a minimum password length (6+ characters; the database accepts up to 128).
- Rotate service-account passwords on a schedule.
- Use distinct accounts for each environment (development, staging, production).

```gql
// Rotate a service account's password
ALTER USER backend_service SET PASSWORD 'new_secure_password_789'
```

## Regular Audits

Audit user and role permissions periodically.

```gql
// Audit a user's effective permissions
SHOW GRANTS FOR USER alice

// Audit a specific role
SHOW GRANTS FOR ROLE data_analyst

// List all users
SHOW USERS

// List all roles
SHOW ROLES

// Review the available operation catalog
SHOW PERMISSIONS
```

## Environment Separation

Use separate users and roles for each environment, with stricter rules for production.

```gql
// Development
CREATE USER app_dev PASSWORD 'dev_password_strong'
GRANT READ, INSERT, UPDATE, DELETE ON GRAPH dev_graph TO ROLE app_readwrite
GRANT ROLE app_readwrite TO USER app_dev

// Production: read-only service account
CREATE USER app_prod PASSWORD 'prod_password_strong'
GRANT ROLE reader TO USER app_prod
```
