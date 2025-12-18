# Prepare Graph

> This page introduces how to create graph model, insert and modify graph data in Ultipa Manager. Demonstrations are given as both UI operations and UQLs.

## Graph Model

Graph model in Ultipa Graph means the <u>schemas and properties</u> of a graphset:

<center><img src="https://img.ultipa.cn/img/2024-02-20-10-15-45-graph-model.png"></center>
<center><i>Chart1: Graph model of graphset 'retail' displayed in Ultipa Manager</i></center>

### How to Run UQL

```uql
create().graph("retail_test")
```

The above UQL will create graphset <i>retail_test</i> as its literal meaning describes.
<br>
In Ultipa Manager, a UQL, take this 'create graph' as an example, can be composed in the CLI box (Chart2) or assembled via UI operations (Chart3):

<center><img src="https://img.ultipa.cn/img/2024-02-19-12-05-01-create-graph.gif"></center>
<center><i>Chart2: Create graphset by composing UQL in CLI box</i></center>

<center><img src="https://img.ultipa.cn/img/2024-02-19-12-05-06-create-graph-ui.gif"></center>
<center><i>Chart3: Create graphset via UI operations</i></center>

> To switch to the new graphset after it is created, click the 'Select' button of the graphset as shown in Chart3. This is not achieved by UQL, but a function of SDK employed by Ultipa Manager.

### Create Graph Model

<center><img src="https://img.ultipa.cn/img/2024-02-19-14-02-04-graph-modelling.gif"></center>
<center><i>Chart4: Create graph model via UI operations</i></center>

Chart4 shows a minimal procedure of creating graph model. It essentially assembles two UQLs that create a node schema and a property via UI:
```uql
// Create node schema 'customer'
create().node_schema("customer")

// create property 'balance' under node schema 'customer', with data type 'float'
create().node_property(@customer, "balance", float)
```

Features of these UQLs:
- Start with command `create()`
- The following `node_schema()`, `node_property()`, ... are parameters, connecting to the command by dot '.'
- A schema should be created prior to its properties
- Users only create <u>Custom Properties</u>, but not <u>System Properties</u> (see below explanations)

Please create all the schemas and their properties listed in Chart1.

Details of creating graph model can be found in documentation of [GraphSet](/docs/uql/graphset), [Schema](/docs/uql/schema), [Property](/docs/uql/property).

## Metadata

Metadata is a general term for <u>nodes and edges</u> in the graph, it is also another term for graph data.

### Insert Nodes

<center><img src="https://img.ultipa.cn/img/2024-02-19-14-24-19-insert-node.gif"></center>
<center><i>Chart5: Insert node via UI operations</i></center>

Nodes have two system properties `_id` and `_uuid`, they both are the <u>unique identifiers</u> inhered in each node, but with different data type.

Click and read about [Unique Identifier](/docs/uql/unique-identifier) of metadata.

Below UQLs all insert some node(s) into schema <i>customer</i>:
```uql
// insert a node, all custom properties set to null, '_id' and `_uuid` auto-generated
insert().into(@customer).nodes({})

// insert two nodes, all custom properties set to null, '_id' and `_uuid` auto-generated
insert().into(@customer).nodes([{},{}])

// insert a node with 'cust_name' set to 'Jason', all the other custom properties set to null, '_id' and `_uuid` auto-generated
insert().into(@customer).nodes({cust_name: "Jason"})

// insert a node with '_id' set to 'CU001', all custom properties set to null, `_uuid` auto-generated
insert().into(@customer).nodes({_id: "CU001"})

// insert a node, designate both 'cust_name' and '_id', all the other custom properties set to null, `_uuid` auto-generated
insert().into(@customer).nodes({cust_name: "Jason", _id: "CU001"})
...
```

Features of these UQLs:
- Start with command `insert()`
- Declare schema in `into()`, organize property values of each node as an object in `nodes()`
- Custom properties not provided will be set to null
- `_id` and `_uuid ` not provided will be auto-generated

Details of inserting metadata can be found in documentation of [Insert](/docs/uql/insert), [Overwrite](/docs/uql/overwrite), [Upsert](/docs/uql/upsert).

### Insert Edges

<center><img src="https://img.ultipa.cn/img/2024-02-19-14-50-50-insert-edge.gif"></center>
<center><i>Chart6: Insert edge via UI operations</i></center>

Edges have only `_uuid` inhered as unique identifier, but have another 4 inhered system properties, namely, <u>start and end node ID</u> of edge `_from`&`_to`, `_from_uuid`&`_to_uuid`, at least one pair of which must be designated when inserting an edge.

Below UQLs all insert some edge(s) into schema <i>transfer</i>, pointing from 'CU001' or 'CU002' to 'MC001':
```uql
// insert an edge, all custom properties set to null, `_uuid` auto-generated
insert().into(@transfer).edges({_from: "CU001", _to: "MC001"})

// insert two edges, all custom properties set to null, `_uuid` auto-generated
insert().into(@transfer).edges([{_from: "CU001", _to: "MC001"},{_from: "CU002", _to: "MC001"}])

// insert an edge with 'tran_amount' set to '1000', all the other custom properties set to null, `_uuid` auto-generated
insert().into(@transfer).edges({_from: "CU001", _to: "MC001", tran_amount: "1000"})

// insert an edge with '_uuid' set to '1', all custom properties set to null
insert().into(@transfer).edges({_from: "CU001", _to: "MC001", _uuid: 1})

// insert an edge, designate both 'tran_amount' and '_uuid', all the other custom properties set to null
insert().into(@transfer).edges({_from: "CU001", _to: "MC001", tran_amount: "Jason", _uuid: "CU001"})

...
```

Similar to inserting nodes, these UQLs have below features:
- Start with command `insert()`
- Declare schema in `into()`, organize property values of each edge as an object in `edges()`
- Custom properties not provided will be set to null
- `_uuid` not provided will be auto-generated
- Must provide `_from` and `_to` (or `_from_uuid` and `_to_uuid`) that represent nodes already existent

Details of inserting metadata can be found in documentation of [Insert](/docs/uql/insert), [Overwrite](/docs/uql/overwrite), [Upsert](/docs/uql/upsert).

For batch import of data from CSV files or other databases, please refer to article [Data Import](/docs/quick-start/data-import).

### Update Metadata

<center><img src="https://img.ultipa.cn/img/2024-02-19-15-00-07-edit-node.gif"></center>
<center><i>Chart7: Update node via UI operations</i></center>

More UQL examples that update node(s) or edge(s):
```uql
// update 'type' of all nodes to 'IV'
update().nodes().set({type: "IV"})

// update 'type' of node whose '_id' is 'CU001' to 'IV'
update().nodes({_id == "CU001"}).set({type: "IV"})

// update 'type' of nodes whose 'merchant_name' contains 'Beijing' to 'IV'
update().nodes({merchant_name contains "Beijing"}).set({type: "IV"})

// update 'result' of all edges to 'success'
update().edges().set({result: "success"})

// update 'result' of edge whose '_uuid' is '1' to 'success'
update().edges({_uuid == 1}).set({result: "success"})

// update 'result' of 'transfer' edges initiated by 'CU001' to 'success'
update().edges({@transfer._from == "CU001"}).set({result: "success"})
...
```

Features of these UQLs:
- Start with command `update()`
- Describe in `nodes()` or `edges()` the metadata to be updated (review article [Graph Data](/docs/quick-start/graph-data) on how to describe nodes and edges in UQL)
- Organize in an object in `set()` the property values to be updated, properties not provided will not be updated
- `_id` and `_uuid` are not allowed to be updated

> Command `update()` is used to modify property values of metadata, but not to rename properties. Renaming properties, schemas, or graphsets belongs to the category of modifying graph models, see details in documentation of [GraphSet](/docs/uql/graphset), [Schema](/docs/uql/schema), [Property](/docs/uql/property).
