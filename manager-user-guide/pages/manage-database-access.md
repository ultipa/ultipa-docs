# Manage Database Access

Click **Auth** in the left sidebar to manage database access.

<center><img src="https://img.ultipa.cn/img/2025-04-15-11-46-29-auth.jpg"></center>

## User

You can manage database users in the **User** tab. For each user, you can configure the following:

- **Name:** The username.
- **Password:** The user's password, which must be between 6 to 64 characters in length.
- **System Privileges:** Select and grant system privileges to the user.
- **GraphSet Privileges:** Select and grant graphset privileges to the user. You can specify different privilege sets for individual graphs.
- **Policy:** Select and grant the policies (roles) to the user.
- **Manager Privileges:** Select and grant permissions for actions available in the Ultipa Manager UI. Note that these privileges affect only the user interface—they do not restrict the user from performing the same actions via GQL or UQL. For example, even if the `Create Graph` option is unchecked in Manager privileges, the user can still create graphs if granted the `CREATE_GRAPH` system privilege.

> **Note:** You must have the appropriate privileges to manage database users.

## Policy

You can manage database policies (roles) in the **Policy** tab. A policy is a set of privileges designed for a specific user role, often encompassing multiple privileges and other policies. For each policy, you can configure the following:

- **Name:** The name of the policy.
- **System Privileges:** Select and grant system privileges to the policy.
- **GraphSet Privileges:** Select and grant graphset privileges to the policy. You can specify different privilege sets for individual graphs.
- **Policy:** Select and grant the policies (roles) to the policy.

> **Note:** You must have the appropriate privileges to manage database policies.
