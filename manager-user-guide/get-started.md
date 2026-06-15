# Get Started

**Ultipa Manager** is a web-based application designed for managing Ultipa graph databases. It caters to a diverse user base including developers, data scientists, database administrators, and business professionals.

## Log in to Manager

To begin, open your browser and navigate to the address where Ultipa Manager is <a href="#Availability">deployed</a>. Log in using your Manager account. If you don't have an account, click **Create account** to register.

<center><img src="https://img.ultipa.cn/img/2025-04-07-16-11-09-manager-login.jpg" /></center>

**Related Links:**

- <a target="_blank" href="/docs/manager-user-guide/users-roles-and-authentication#Manage-Users">Managing users, roles, and groups</a>
- <a target="_blank" href="/docs/manager-user-guide/users-roles-and-authentication#Login-Authentication">Using LDAP for authentication</a>
- <a target="_blank" href="/docs/manager-user-guide/users-roles-and-authentication#Multi-Factor-Authentication-(MFA)">Enabling MFA for login</a>
- <a target="_blank" href="/docs/manager-user-guide/users-roles-and-authentication#Password-Strength">Enforing a password strength rule</a>

## Add Connections

After logging in, you will be directed to the **Instances** page, where you can add connections to your Ultipa graph databases.

Click **New Connection** and complete the following settings:

- **Hosts**: A comma-separated list of database server IPs or URLs (excluding the `http://` or `https://` protocol prefix).
  - IP example: `10.123.123.1:4801,10.123.123.2:4801,10.123.123.3:4801`
  - URL example: `b2e986b68dxxxxx.eu-south-1.cloud.ultipa.com:8443`
- **Username**: A database username of the host authentication.
- **Password**: Password of the above database user.
- **Name:** Optional. A custom name for the connection.

<center><img src="https://img.ultipa.cn/img/2025-04-08-16-45-12-connections.jpg" /></center>

**Related Links**

- <a target="_blank" href="/docs/manager-user-guide/manage-instances#Connection-Status">How to check the connection status</a>
- <a target="_blank" href="/docs/manager-user-guide/manage-instances#Share-Connections">Sharing connections with other users or groups</a>
- <a target="_blank" href="/docs/manager-user-guide/manage-instances#Oversee-Connections-as-an-Admin">Overseeing connections as an admin</a>

## Work with Your Database

From the **Instances** page, click the **Open** button on a connection card to access the corresponding database:

<center><img src="https://img.ultipa.cn/img/2025-04-08-18-24-10-db-home.jpg" /></center>

**Related Links**

- <a target="_blank" href="/docs/manager-user-guide/manage-instances#Switch-Connections">How to switch to another connection</a>

<br>

Ultipa Manager provides a comprehensive suite of features to help you interact with and manage your graph databases:

### Manage Graphs, Structure, and Data

Access and manage the graphs within your database—modify their structures and update data. <a target="_blank" href="/docs/manager-user-guide/manage-graphs-structure-and-data">Learn more</a>

### Run Queries

Execute GQL or UQL to query data, run algorithms, manipulate graphs and the database. <a target="_blank" href="/docs/manager-user-guide/run-queries">Learn more</a>

### Results Visualization

Display query results and graph data through rich visualizations with customizable layouts and styles. <a target="_blank" href="/docs/manager-user-guide/results-visualization">Learn more</a>

### HDC (High-Density Computing)

Manage HDC graphs and leverage nearly 60 graph algorithms with high-performance, in-memory computing. <a target="_blank" href="/docs/manager-user-guide/hdc">Learn more</a>

### Load Data

Import data from a variety of sources and transform them into graph structures within Ultipa. <a target="_blank" href="/docs/manager-user-guide/load-data">Learn more</a>

### Manage Database Access

Manage database users and policies (roles), and assign precise privileges across the database and Ultipa Manager. <a target="_blank" href="/docs/manager-user-guide/manage-database-access">Learn more</a>

### Develop Widgets

Build and integrate custom applications that interact with your graph data. <a target="_blank" href="/docs/manager-user-guide/develop-widgets">Learn more</a>

## Availability

### Ultipa Cloud

In the instance of Ultipa Cloud, you can access Ultipa Manager by selecting **CONNECT > Ultipa Manager**.

### On-Premises

For on-premises deployment, please reach out to us at <a href="mailto:support@ultipa.com">support@ultipa.com</a>.
