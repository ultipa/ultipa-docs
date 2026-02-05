# Best Practices

## Overview

Security best practices for Role-Based Access Control.

## Principle of Least Privilege

- Grant only the minimum permissions needed
- Use specific resource grants instead of wildcards
- Regular audit of permissions

```gql
// Good: Specific graph access
GRANT READ ON GRAPH 'production' TO ROLE 'analyst'

// Avoid: Wildcard access unless truly needed
GRANT READ ON GRAPH * TO ROLE 'analyst'
```

## Role Design

- Create roles based on job functions
- Avoid user-specific permissions when possible
- Use the built-in roles (admin, reader, writer) as starting points

```gql
// Create roles for job functions
CREATE ROLE 'data_analyst' DESCRIPTION 'Read-only access for analytics'
CREATE ROLE 'data_engineer' DESCRIPTION 'Read and write for ETL pipelines'
CREATE ROLE 'app_service' DESCRIPTION 'Application service account'
```

## Password Management

- Enforce strong password policies (6+ characters minimum)
- Rotate service account passwords regularly
- Use separate accounts for different environments

```gql
// Rotate service account password
ALTER USER 'backend_service' SET PASSWORD 'new_secure_password_789'
```

## Account Security

- Deactivate accounts instead of deleting for audit trails
- The admin user cannot be deleted (protected)
- The admin role is immutable

```gql
// Deactivate suspicious account (preserves audit trail)
ALTER USER 'suspicious_user' SET STATUS INACTIVE

// Reactivate after investigation
ALTER USER 'suspicious_user' SET STATUS ACTIVE
```

## Regular Audits

Regularly audit user permissions and access:

```gql
// Audit user permissions
SHOW GRANTS FOR USER 'analyst'

// List all users and their status
SHOW USERS

// List all roles
SHOW ROLES

// Check specific role permissions
SHOW GRANTS FOR ROLE 'data_analyst'
```

## Environment Separation

Use separate accounts for different environments:

```gql
// Development
CREATE USER 'app_dev' WITH PASSWORD 'dev_password'
GRANT READ, INSERT, UPDATE, DELETE ON GRAPH 'dev_graph' TO USER 'app_dev'

// Staging
CREATE USER 'app_staging' WITH PASSWORD 'staging_password'
GRANT READ, INSERT, UPDATE, DELETE ON GRAPH 'staging_graph' TO USER 'app_staging'

// Production (more restrictive)
CREATE USER 'app_prod' WITH PASSWORD 'prod_password'
GRANT ROLE 'app_readonly' TO USER 'app_prod'
```
