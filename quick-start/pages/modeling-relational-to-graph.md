# Modeling: Relational to Graph

You may already have an existing project running on a relational database that you'd like to convert to a graph, or you might want to start a new graph project but are more familiar with relational models. Either way, this guide will walk you through the process of easily transforming a relational data model into a graph model.

## Introducing the Tables

Assume we have three tables in a retail business: `Customer`, `Merchant`, and `Transaction`. The `Transaction` table records customers' transaction behaviors with merchants.

<div align=center drawio-diagram='20096' drawio-name="draw_487fd50100c3412c8272a7b8824b0e06.jpg"><img src="https://img.ultipa.cn/draw/draw_487fd50100c3412c8272a7b8824b0e06.jpg?v='1736823490406'"/></div>
<center><span style="color:#999;">Relational Data Model</span></center>

| <div table-width="40">cust_no (Primary Key)</div> | name | level |
| -- | -- | -- |
| C100250090 | John Doe | 2 |
| C100250091 | Alice Carter | 3 |
| C100250092 | David Miller | 1 |

<center><span style="color:#999;">Columns in the Customer Table and Example Data</span></center>

| <div table-width="40">merch_no (Primary Key)</div> | name | type |
| -- | -- | -- |
| RS00JF1DF | Fay's Shop | IV |
| RT67KNH2R | SunnyMart | V |

<center><span style="color:#999;">Columns in the Merchant Table and Example Data</span></center>

| trans_no<br>(Primary Key) | cust_no<br>(Foreign Key) | merch_no<br>(Foreign Key) | time | <div table-widtd="10">amount</div> |
| -- | -- | -- | -- | -- |
| TR58542 | C100250090 | RS00JF1DF | 2025-01-21 09:12:56 | 123.45 |
| TR58543 | C100250091 | RT67KNH2R | 2025-01-21 10:03:23 | 87.0 |
| TR58544 | C100250090 | RT67KNH2R | 2025-01-22 13:08:10 | 255.8 |
| TR58545 | C100250092 | RS00JF1DF | 2025-01-22 13:52:12 | 85.4 |
| TR58546 | C100250090 | RS00JF1DF | 2025-01-22 14:00:52 | 88.3 |

<center><span style="color:#999;">Columns in the Transaction Table and Example Data</span></center>

## Modeling into a Graph

Graph databases are unlike relational databases that require you to establish connections between entities using foreign keys. Instead, you can model the connections directly as edges in the graph.

Building on the <a target="_blank" href="/docs/quick-start/what-is-a-graph-database#Graph-Structure">graph structure</a> introduced, here's how the transformation goes:

- **Entity tables to node types:** Map the `Customer` and `Merchant` tables, which represent entities, to node types `Customer` and `Merchant`.
- **Columns to node properties:** Transform the columns in each entity table into properties of the corresponding node type. Use the primary key as the unique identifier `_id` for each node.x
- **Relationship tables to edge types:** Map the `Transaction` table, which defines connections between entities, to an edge type named `TransfersTo`. Using a verb as the edge type name is recommended, as it better expresses the action and direction of the relationship.
- **Columns to edge properties:** Transform the columns in each relationship table into properties of the corresponding edge type. Use the foreign keys `cust_no` and `merch_no` as the system properties `_from` and `_to`, representing the `_id` of the source and destination nodes, respectively.
- **Rows to nodes and edges:** Treat each row in the tables as a node or an edge in the graph.

This effectively maps the relational data model to graph structures as shown below:

<div align=center drawio-diagram='20099' drawio-name="draw_795c7761e3894ae1961a4fe715aaae2a.jpg"><img src="https://img.ultipa.cn/draw/draw_795c7761e3894ae1961a4fe715aaae2a.jpg?v='1736823125649'"/></div>
<center><span style="color:#999;">Graph Structure</span></center><br>

And here is the graph produced:

<div align=center drawio-diagram='20100' drawio-name="draw_2b724862f1d946dfa7197b1d86b4b2a2.jpg"><img src="https://img.ultipa.cn/draw/draw_2b724862f1d946dfa7197b1d86b4b2a2.jpg?v='1736839533719'"/></div>

You can refer to <a target="_blank" href="/docs/quick-start/importing-data-to-ultipa">Importing Data to Ultipa</a> to learn how to import data into the graph database.

## Customizing the Graph Structure

The graph structure is highly flexible and can be tailored to specific analytical or operational requirements. Adjusting the structure helps better align the graph with the focus and goals of your use case.

For example, some scenarios focus on transactions as primary entities that require modeling them as nodes instead of edges. The graph structure can be adjusted as below where the `Trasaction` table is mapped into the `Transaction` node type, which connects to the `User` and `Merchant` nodes through `hasPayer` and `hasPayee` edge types:

<div align=center drawio-diagram='20103' drawio-name="draw_d9b37161647e4afb8ac4e89bfe8eb24e.jpg"><img src="https://img.ultipa.cn/draw/draw_d9b37161647e4afb8ac4e89bfe8eb24e.jpg?v='1736825331771'"/></div>
<center><span style="color:#999;">Graph Structure: Transactions as Nodes</span></center><br>

In cases where there is a need to analyze the types of merchants, you can enhance the graph structure by extracting the `type` column in the `Merchant` table and converting it into a separate node type. Instead of storing this information as a property of `Merchant` nodes, the graph structure would include `Type` nodes connected to `Merchant` nodes.

<div align=center drawio-diagram='20106' drawio-name="draw_c7cc549ef6cd43228f8038d6a13c8a12.jpg"><img src="https://img.ultipa.cn/draw/draw_c7cc549ef6cd43228f8038d6a13c8a12.jpg?v='1736826020245'"/></div>
<center><span style="color:#999;">Graph Structure: Merchant Types as Nodes</span></center><br>

Ensure the `type` column is deduplicated before converting rows into `Type` nodes.
