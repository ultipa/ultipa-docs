# G.V()

## Overview

**G.V()** is an all-in-one graph database client to write, debug, test and analyze results for your property-graph database. It offers a rich UI with smart autocomplete, graph visualization, editing and connection management. It's compatible with Ultipa and many more.

You can download G.V() from <a target="_blank" href="https://gdotv.com">here</a>.

**References**

- <a target="_blank" href="https://gdotv.com/blog/ultipa-graph-announcement/">G.V() now supports Ultipa Graph Database</a>
- <a target="_blank" href="https://gdotv.com/docs/#ultipa-graph">G.V() Documentation</a>

## Set up Connection

To connect to your Ultipa Graph, all you need is the hostname, login credentials, and to select your graph name. You can see how quick it is:

<center><img src="https://img.ultipa.cn/img/2025-10-08-17-52-47-ultipa-graph-connection.gif"></center>

## Graph Visualization from GQL Queries

You can run your GQL queries through our own Query Manager within G.V(). For example, you can try running the following query in G.V() to see the `Transaction` nodes between the Client `Carlos Sawyer` and other `Client` nodes:

```gql
MATCH p = (s:Client {NAME: "Carlos Sawyer"})-[]->(e:Transaction)-[]->(c:Client)
RETURN p LIMIT 1000
```

<center><img src="https://img.ultipa.cn/img/2025-10-08-17-58-55-ultipa-gql-query.png"></center>

## Data Model Visualization

G.V() extracts the schema directly from your Ultipa Graph to create the Graph Data Model:

<center><img width="80%" src="https://img.ultipa.cn/img/2025-10-08-18-00-39-ultipa-graph-data-model.png"></center>

## No-code Data Exploration

If you’re just wanting to do a quick exploration of your data and you’d like to take an easier route than writing GQL queries – you can use G.V()’s Data Explorer to explore your graph data without writing any code at all.

Just select the nodes and relationships you want from drop down menus. You can even add filters at the same time – no manual querying required.

<center><img src="https://img.ultipa.cn/img/2025-10-08-18-05-39-ultipa-graph-data-explorer.gif"></center>
