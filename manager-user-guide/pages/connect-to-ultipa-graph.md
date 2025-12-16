# Connect to Ultipa Graph

Upon logging in, users are directed to the <b>Instances</b> page, the central hub for managing Ultipa Graph instances. An instance refers to an individual server node.

<center><img src="https://img.ultipa.cn/img/2024-01-10-16-00-22-instances.jpg" /></center>

## New Connection

To establish a connection to Ultipa Graph, provide the following information:

### Connection 
- <b>Hosts:</b> A single server address (e.g., <i>192.168.1.85:64801</i>) or server addresses of a cluster (e.g., <i>192.168.1.85:64801,192.168.1.85:64802,192.168.1.85:64803</i>)
- <b>Username:</b> Username of a server user
- <b>Password:</b> Password of the user above
- <b>Name:</b> Custom name for the connection

### Daemon (Optional)

Daemon provides database server management functionalities, including starting, stopping and monitoring each instance. This section lists all the server nodes entered in **Connection** > **Hosts**, and you need to specify the following items for each one:

- **Port**: Port for the daemon service
- **License:** License of the server; it will be compared with the license configured for the server node

Upon saving, the corresponding Ultipa Graph version will be displayed under the connection name in the connection card (e.g., <i>htap_beta.4.4.21-b4.4.0-tv-ui</i>) if the database is up and running.

A green bar atop the connection card signifies that the database is operational; otherwise, it appears in red. Click <b>Test</b> to update the status.

## Open Connection

<center><img width=400 src="https://img.ultipa.cn/img/2024-01-10-16-01-30-open.jpg" /></center>

In the connection card, click the arrow besides the <b>Open</b> button to preview all graphsets in the database. Clicking on any of them will open the database and select that graphset as the current one. If clicks <b>Open</b> directly, it will open the database and select the last-used graphset.

## Switch Connection

After opening a database, click the second icon in the bottom left corner to return to the <b>Instances</b> page and switch connections.

<center><img width=200 src="https://img.ultipa.cn/img/2024-01-10-16-04-55-switch.jpg" /></center>

## Daemon Operations

If the daemon settings are completed, navigate to the management area by clicking the gear icon on the connection card and selecting **Cluster**:

<center><img width=400 src="https://img.ultipa.cn/img/2024-04-07-11-48-47-cluster.jpg" /></center>

From here, you can start and stop single or all server nodes:

<center><img width=400 src="https://img.ultipa.cn/img/2024-04-07-11-48-49-cluster-manage.jpg" /></center>
