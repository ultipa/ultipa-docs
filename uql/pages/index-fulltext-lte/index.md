# Index

Index is the short form of property index. An index has the same name and schema with the property it references.

## Show Index

Returned table name: `_nodeIndex`, `_edgeIndex`
<br>
Returned table header: `name` | `properties` | `schema` | `status` | `size` (Name, properties, schema, status [creating|done] and byte length of index)

Syntax:
<p tit="Syntax"></p>

```js
// To show all indexes in the current graphset (node indexes and edges indexes in separate tables)
show().index() 

// To show all node indexes in the current graphset
show().node_index()

// To show all edge indexes in the current graphset
show().edge_index()
```

> You may need to <a href="/docs/uql/graphset#Compact-Graph">compact the graph</a> in order to see the right size of the index.

## Create Index

System properties UID, FROM and TO and custom properties of <i>decimal</i> type do not support index.

Syntax:
<p tit="Syntax"></p>

```js
// To create index for a certain property of a certain node schema in the current graphset
create().node_index(@<schema>.<property>)

// To create index for a certain property of all node schemas (if has) in the current graphset
create().node_index(@*.<property>)

// To create index for a certain property of a certain edge schema in the current graphset
create().edge_index(@<schema>.<property>)

// To create index for a certain property of all edge schemas (if has) in the current graphset
create().edge_index(@*.<property>)

// To create index for multiple node/edge properties using the four methods above
create()
  .node_index(@<schema>.<property>)
  .node_index(@*.<property>)
  .edge_index(@<schema>.<property>)
  .edge_index(@*.<property>)
  ...
```

Example: Create index for <i>@card</i> property <i>balance</i>
```js
create().node_index(@card.balance)
```

Example: Create index for <i>@transaction</i> property <i>amount</i>
```js
create().edge_index(@transaction.amount)
```

## Drop Index

Deleting a property will also delete its index.

Syntax:
<p tit="Syntax"></p>

```js
// To delete index for a certain property of a certain node schema from the current graphset
drop().node_index(@<schema>.<property>)

// To delete index for a certain property of all node schemas (if has) from the current graphset
drop().node_index(@*, <property>)

// To delete index for a certain property of a certain edge schema from the current graphset
drop().edge_index(@<schema>.<property>)

// To delete index for a certain property of all edge schemas (if has) from the current graphset
drop().edge_index(@*, <property>)

// To delete index for multiple node/edge properties using the four methods above
drop()
  .node_index(@<schema>.<property>)
  .node_index(@*, <property>)
  .edge_index(@<schema>.<property>)
  .edge_index(@*, <property>)
  ...
```

Example: Delete the index for <i>@card</i> property <i>balance</i>
```js
drop().node_index(@card.balance)
```

Example: Delete the index for <i>@transaction</i> property <i>amount</i>
```js
drop().edge_index(@transaction.amount)
```


