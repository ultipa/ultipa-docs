# GQLDB Manager

GQLDB Manager is the visual interface for connecting to GQLDB, running GQL queries, and exploring your results as a graph. If you have already started Community Edition, your next step is to connect Manager to your database.

## Choose How to Connect

| Your database | Use | What you need |
| --- | --- | --- |
| Community Edition running on your computer | **Desktop Manager** | Download the app for macOS, Linux, or Windows. Connect to `localhost:60061`. |
| An Ultipa Cloud instance | **Cloud-hosted Manager** | Sign in or register for an Ultipa account, then use the instance endpoint and database credentials. |
| A self-managed instance reachable from the hosted Manager's servers | **Cloud-hosted Manager** | An Ultipa account, a reachable database endpoint, and database credentials. |

The hosted Manager connects to the database from Ultipa's servers. Entering `localhost` or `127.0.0.1` there points to the cloud server, not your computer. A private LAN address is also insufficient without a network route from the hosted service. Use desktop Manager for a local database; a browser login does not create that network route.

## Connect to Community Edition on Your Computer

1. Open the <a href="/download" target="_blank">Download Center</a> and find **GQLDB Manager** under **Tools**.
2. Expand the download options and choose the package for your operating system and architecture. Desktop builds are available for macOS, Linux, and Windows. Sign in or register for an Ultipa account when prompted to download.
3. Open the desktop app and add a connection. For the instance created in <a href="/docs/quick-start/install-and-connect" target="_blank">Install & Connect</a>, enter:

   | Field | Value |
   | --- | --- |
   | Host | `localhost` |
   | Port | `60061` |
   | Username | `admin` |
   | Password | The password you set with `-admin-pass` (`myPassword` in the Quick Start example) |

4. Save and open the connection, then select the `default` graph. Keep the database process running while you use Manager.

Desktop Manager can also connect to a database on another host that your computer can reach. Use that host's address and configured port instead of `localhost`.

For the macOS Gatekeeper workaround, see <a href="/docs/quick-start/install-and-connect" target="_blank">Install & Connect</a>.

## Use the Cloud-Hosted Manager

1. Open <a href="https://mgr-eu.ultipa.com/connections" target="_blank">GQLDB Manager in Europe</a>.
2. Sign in with your Ultipa account, or register if you do not have one. Your Ultipa account signs you into Manager; the database connection uses separate database credentials.
3. Add a connection with your database host, port, username, and password. Use an endpoint reachable from the hosted Manager's servers, rather than your computer's `localhost`. Match the connection's TLS setting to your database endpoint.
4. Save and open the connection, select your graph, and run a query.

For Ultipa Cloud, the simplest path is **Connect to Manager** on your instance's details page at <a href="https://dbaas.ultipa.com" target="_blank">Ultipa Cloud</a>. It fills in the connection details; supply the database password from **Connection Info**.

## See Your First Graph

In Manager's query editor, first confirm the connection:

```gql
RETURN db.version()
```

On a fresh Community Edition instance, select the `default` graph and run this statement once to create two example nodes and a relationship:

```gql
INSERT (alice:ManagerDemo {name: "Alice"}),
       (bob:ManagerDemo {name: "Bob"}),
       (alice)-[:KNOWS]->(bob)
```

Then return the path:

```gql
MATCH p = (:ManagerDemo)-[:KNOWS]->(:ManagerDemo)
RETURN p
LIMIT 20
```

Open the result's **graph view** to explore the two nodes and their relationship. Returning a node or path gives Manager graph data to visualize; returning only a count or name produces a table value.

For a larger example, continue with <a href="/docs/quick-start/load-data" target="_blank">Load Your Data</a> and <a href="/docs/quick-start/query-data" target="_blank">Query Your Data</a>.

## If the Connection Fails

- **Connection refused:** confirm that GQLDB is still running and that the host and port match its startup settings.
- **Connection times out:** check whether the database is reachable from the machine running Manager. For a database on your laptop, use desktop Manager.
- **Sign-in fails:** distinguish your Ultipa account from your database username and password. Use the database credentials in the connection form.
- **Results show only a table:** return nodes or a path, as in the example above, and open graph view.
