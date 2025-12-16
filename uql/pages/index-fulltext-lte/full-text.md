# Full-text

## Naming Conventions

Full-text index is named by developers. A same name cannot be shared between full-text indexes within a graphset.

- 2 ~ 64 characters
- Must start with letters
- Allow to use letters, underscore and numbers ( _ , A-Z, a-z, 0-9)

## Show Full-text

Returned table name: `_nodeFulltext`, `_edgeFulltext`
<br>
Returned table header: `name` | `properties` | `schema` | `status` (Name, properties, schema and status [creating|done] of full-text)

Syntax:
<p tit="Syntax"></p>

```js
// To show all full-text indexes in the current graphset (node full-texts and edge full-texts in separate tables)
show().fulltext()

// To show all full-text node indexes in the current graphset
show().node_fulltext()

// To show all full-text edge indexes in the current graphset
show().edge_fulltext()
```

## Create Full-text

Properties of <i>decimal</i> type do not support full-text index.

Syntax:
<p tit="Syntax"></p>

```js
// To create full-text index for a certain property of a certain node schema in the current graphset
create().node_fulltext(@<schema>.<property>,"<name>")

// To create full-text index for a certain property of a certain edge schema in the current graphset
create().edge_fulltext(@<schema>.<property>,"<name>")
```

Example: Create full-text index named "prodDesc" for <i>@product</i> property <i>description</i>
```js
create().node_fulltext(@product.description, "prodDesc")
```

## Drop Full-text

Deleting a property will also delete its full-text index.

Syntax:
<p tit="Syntax"></p>

```js                            
// To delete full-text index for a certain node property from the current graphset
drop().node_fulltext("<name>")

// To delete full-text index for a certain edge property from the current graphset
drop().edge_fulltext("<name>")
```

Example: Delete the full-text index named 'prodDesc'
```js
drop.().node_fulltext("prodDesc")
```

## Full-text Filter

Ultipa's full-text filter achieves high speed full-text search, it is an important implementation scenario of Ultipa filter. It uses conditional operator `contains` to judge whether a full-text index contains ALL the specified keywords. There are two criteria for judging 'contains':

- Precise search
  - the segmented words totally equal to the keywords   
  - when the library of segmented words does not contain the keywords that are being searched, it might lead to no result
- Fuzzy search
  - the segmented words begin with a keyword
  - maximize the possibility to find the nodes and edges (their properties) that contain the keywords that are being searched, but cost much time than precise search

> Fuzzy search is always recommended unless user has a clear request of precise matching.

Syntax: <span style=color:red><b>{</b></span><span style=color:blue><b>~&lt;fulltext&gt;</b></span> <span style=color:fuchsia><b>contains</b></span> <span style=color:green><b>"&lt;keyword1&gt; &lt;keyword2&gt; ..."</b></span><span style=color:red><b>}</b></span>

where space is used to separate multiple `<keyword>`, and should use backslash `\` as the prefix if has English double quotation marks in a `<keyword>`; `<keyword>` used for fuzzy matching should end with asterisk `*`.

### Node/Edge Query

Example: Find products that contain keywords 'graph' and 'database' by the full-text index named 'prodDesc'
```js
find().nodes({~prodDesc contains "graph database"}) return nodes
```

Example: Find products that contain keywords 'graph' or 'database' by the full-text index named 'prodDesc'
```js
find().nodes({~prodDesc contains "graph" || ~prodDesc contains "database"}) return nodes
```

Example: Find products that contain 'graph', and words start with 'ult' by the full-text index named 'prodDesc'
```js
find().nodes({~prodDesc contains "graph ult*"}) return nodes
```

### Template Query

Example: Fuzzy search for 10 paths that start from accounts which have segmented word 'capital*', firstly arrive accounts which have segmented word 'investment*', then arrive accounts which have segmented word 'AI*', use full-text index 'companyName'
```js
n({~companyName contains "capital*"}).e().n({~companyName contains "investment*"})
  .e().n({~companyName contains "AI*"}) as paths
return paths{*} limit 10
```

Example: Fuzzy search for 10 paths from 'Sequoia*' accounts to 'Hillhouse*' accounts within 5 steps, use full-text index 'companyName'
```js
n({~companyName contains "Sequoia*"}).e()[:5].n({~companyName contains "Hillhouse*"}) as paths
return paths{*} limit 10
```

Note: Given a GP/LP or business knowledge graph network, the query rules above are equivalent to a deep Ad hoc network of 'Sequoia' and 'Hillhouse' companies. The same operation requires massive manual interventions or batch executions in whether a manual or three-check system. Before Ultipa invented the template-based full-text search, a query like this is unthinkable! Now, this can be done with ease, elegance and in real time.

