# UQL Query

> This page demonstrates several types of graph query on how they are composed in UQL and what does the query result look like in Ultipa Manager.

GraphSet used in this article:
- Graph model is as demonstrated by Chart1 in [Prepare Graph](https://www.ultipa.com/document/quick-start/prepare-graph)
- Graph data can be downloaded from [Data Import](https://www.ultipa.com/document/quick-start/data-import)

For those who don't have an Ultipa server environment:
- Click the 'Run' button on top of each code box to check the query result
- Or 'Copy' the code and run it in [Ultipa Playground](https://www.ultipa.com/playground) against graph 'Quick Start'

## Basic Queries

### Node Query

Query for nodes is comparable to table query in relational databases. Try to understand below UQL:

<p run-tag="true" graph="quick_start"></p>

```js
find().nodes() as myFirstQuery
return myFirstQuery{*} limit 10
```

Its literal meaning is 'find nodes and name them as <i>myFirstQuery</i>, return <i>myFirstQuery</i>, limit 10 of them', which is close enough if added with some explanations:
- Chain statement `find().nodes()` initiates a node query
- Alias <i>myFirstQuery</i> defined for the result of this node query is called by a latter statement `return`
- Symbol `{*}` following the node alias carries all the properties of node

The target of the above UQL is 'find 10 different nodes and return all their properties'. Execute this UQL in Ultipa Manager:

<center><img width=670 src="https://img.ultipa.cn/2022-07-16-15-40-51-uql-findnodes1.gif"></center>

> The fact that <i>myFirstQuery</i> are nodes all from schema `@customer` is a coincidence, or more precisely, be subject to the sequence of inserting nodes and the behavior of concurrent computing.

To query nodes of a specific schema, <i>merchant</i> for example, describe in `nodes()` as below:
<p run-tag="true" graph="quick_start"></p>

```js
find().nodes({@merchant}) as mySecondQuery
return mySecondQuery{*} limit 10
```

- The curly braces `{}` and its content held by `nodes()` (as well as `n()` and many other parameters, review [Graph Data - Describe Nodes](https://www.ultipa.com/document/quick-start/graph-data)) is called <u>filtering condition</u>

Below is the execution result of this UQL:

<center><img width=600 src="https://img.ultipa.cn/2022-07-16-16-07-40-uql-findnodes2.png"></center>

### Edge Query

In the current graph model, edges of `@transfer` exist from nodes of `@customer` to nodes of `@merchant`:

<div align=center drawio-diagram='2524' drawio-name="draw_1bdd638d0b694bc38effffcbee007417.jpg"><img src="https://img.ultipa.cn/draw/draw_1bdd638d0b694bc38effffcbee007417.jpg?v='1657988383271'"/></div>

Query for edges is quite similar to query for nodes, but using `edges()` to hold the filtering condition of edges:
<p run-tag="true" graph="quick_start"></p>

```js
find().edges({_from == "60017791850"}) as payment
return payment{*} limit 10
```

<center><img width=860 src="https://img.ultipa.cn/2022-07-16-16-52-55-uql-findedges.png"></center>

The <i>payment</i> are 10 different edges from customer Chen** (ID: 60017791850) to other nodes, the `_to` of <i>payment</i> are the IDs of merchants who receive those payments. Combine this edge query with a node query that calls the IDs of these merchants:
<p run-tag="true" graph="quick_start"></p>

```js
find().edges({_from == "60017791850"}) as payment
find().nodes({_id == payment._to}) as merchant
return merchant{*} limit 10
```

- The `._id` following the node alias calls the property `_id` of node

The above UQL returns all properties of those 10 merchants who receive transactions from Chen** (ID: 60017791850):

<center><img width=600 src="https://img.ultipa.cn/2022-07-16-17-03-15-uql-findedgesnodes.png"></center>

> Repeated values occur in the result, which are merchants with `_uuid` '117' and '119' that each appears twice, because they each receives two transactions from Chen**.

This is a typical scenario of multi-graph, in which more than one edge exist between two nodes. The 2D view in Ultipa Manager can better display this kind of scenario.

### Spread

<p run-tag="true" graph="quick_start"></p>

```js
spread().src({_id == "60017791850"}).depth(1) as transaction
return transaction{*} limit 10
```

Its literal meaning: spread from a source whose ID is 60017791850, to a depth of 1, return all properties of 10 such records.

- Command `spread()` initiates a query for edges starting from a center node `src()`, in BFS manner
- Parameter `depth()` sets the greatest depth the BFS search goes
- Alias <i>transaction</i> represents one-step paths of the found edges, namely the 'start-node, edge, end-node'
- Symbol `{*}` following the path alias carries all the properties of nodes and edges in the path

The target of the above UQL is 'find 10 different edges from customer Chen** to merchants and return all properties of Chen**, edges and merchants':

<center><img width=600 src="https://img.ultipa.cn/2022-07-16-23-54-38-uql-spread2d.png"></center>

> Query result of paths are auto visualized in 2D view in Ultipa Manager, where the multiple transactions between Chen** and the two merchants '117' and '119' are intuitively observed.

To acquire an exact number of distinct end-node merchants through the above `spread()` query, some deduplication operation can be involved before returning the final result. Another option is to use a different query command that by design searches in BFS manner but returns nodes.

### K-Hop

<p run-tag="true" graph="quick_start"></p>

```js
khop().src({_id == "60017791850"}).depth(1) as merchant
return merchant{*} limit 10
```

Its literal meaning: hop K times from a source whose ID is 60017791850, to a depth of 1, return all properties of 10 such records.

- Command `khop()` initiates a query for nodes start from a center node `src()`, in BFS manner
- Alias <i>merchant</i> represents nodes

The target of the above UQL is 'find 10 different merchants who receive payments from Chen** and return all properties of these merchants:

<center><img width=600 src="https://img.ultipa.cn/2022-07-16-21-26-42-uql-khop.png"></center>

> Two more merchants '110' and '118' are found by `khop()`, in addition to those 8 merchants found by `spread()`.

## Think in 'Template'

Template query is an advanced type of graph query by accurately describing each node and edge in a path. It employs parameters `n()`, `e()` and `nf()` aforementioned in [Graph Data](https://www.ultipa.com/document/quick-start/graph-data).

### Chains

<p run-tag="true" graph="quick_start"></p>

```js
n({_id == "60017791850"}).e().n() as transaction
return transaction{*} limit 10
```

Its literal meaning: find 1-step paths from node whose ID is 60017791850 and return all information of 10 such paths:

<center><img width=600 src="https://img.ultipa.cn/2022-07-16-23-54-42-uql-temp1step.png"></center>

> It achieves the same result as the previous query using `spread()`, as both queries searches for 1-step paths from customer Chen**.

Now consider a path that starts from Chen** and reaches a merchant via 3 edges, all edges should have transaction amount greater than 70000:

<div align=center drawio-diagram='2594' drawio-name='draw_c7090d0b4fdb40a0a3bf3ddc266d6b14.jpg'><img src="https://img.ultipa.cn/draw/draw_c7090d0b4fdb40a0a3bf3ddc266d6b14.jpg?v='1657988519667'"/></div>

<p run-tag="true" graph="quick_start"></p>

```js
n({_id == "60017791850"}).e({tran_amount > 70000})[3].n() as transChain
return transChain{*} limit 10
```

- Symbol `[3]` following `e()` indicates the number of edges in the path (same purpose as `depth()`)

<center><img width=600 src="https://img.ultipa.cn/2022-07-17-01-09-15-uql-temp3step.png"></center>
<center><i>Green circle: initial node Chen**; blue circles: terminal nodes (merchant)</i></center>

> These 10 paths diverge from the 2nd node in each of their own, merchant '111', into 3 branches, and further diverge from those three customers Zheng**, Qian** and Chu** into 10 branches, which eventually reach 8 different merchants.

If the shopping behaviors of Chen**, Zheng**, Qian** and Chu**, those who all purchase products from merchant '111', are concluded similar, then it is reasonable to recommend some of those 8 merchants at terminal node to customer Chen**, which is a typical product and merchant recommendation scenario.

> The 2D view of Ultipa Manager does not re-render the same node or edge for a different path. When all 10 paths start from Chen**, pass edge '60' and reach merchant '111', these 3 metadata are shared in the 2D view. A list view will show clearly all the metadata of each path: <center><img width=500 src="https://img.ultipa.cn/2022-07-17-01-12-29-uql-temp3steplist.png"></center>

### Circles

Edges in a path never repeat, but nodes do sometimes, which induces circles into the path.

<p run-tag="true" graph="quick_start"></p>

```js
n({@customer} as start).e({tran_date > "2020-1-1 0:0:0"})[4].n(start) as transRing
return transRing{*} limit 10
```

- The last `n()` calls the alias <i>start</i> defined in the first `n()`, so the initial node and the terminal node of the path become the same node

The target of the above UQL is 'find 10 four-step paths starting from a `@customer` node and back to this node again eventually, where each transaction happens after 2020-1-1 0:0:0, return all properties of nodes and edges in these paths':

<center><img width=600 src="https://img.ultipa.cn/2022-07-17-13-42-55-uql-temp4step.png"></center>

The list view of the query result:

<center><img width=600 src="https://img.ultipa.cn/2022-07-17-13-42-58-uql-temp4steplist.png"></center>

> In these four-step circles, both customers Chu** and Ou** purchase products from merchants '110' and '108', this provides evidence of some similarities between these two customers.

### Shortest Paths

<p run-tag="true" graph="quick_start"></p>

```js
n({_id == "60017791850"}).e()[:5].n(115) as transRange
return transRange{*} limit 1
```

- The value `:5` in the bracket can also be written as `1:5`, which specifies a flexible range of path length instead of a fixed number
- The number '115' in the last `n()` is a brief format of `{_uuid == 115}`

The target of the above UQL is 'find a path from Chen** to the node whose UUID is 115, with a length no greater than 5, return all properties of nodes and edges in the path':

<center><img width=600 src="https://img.ultipa.cn/2022-07-17-15-28-27-uql-temp5step.png"></center>

> By chance, the found path has exactly 5 edges.

A minor revision made to the path length might completely change the query target of the UQL:

<p run-tag="true" graph="quick_start"></p>

```js
n({_id == "60017791850"}).e()[*:5].n(115) as transShortest
return transShortest{*} limit 1
```

- By adding a star `*`, the value `*:5` turns the template into a <u>shortest path</u> with a length no greater than 5

The target of the above UQL is 'find a shortest path from Chen** to the node whose UUID is 115, with a length no greater than 5, return all properties of nodes and edges in the path':

<center><img width=500 src="https://img.ultipa.cn/2022-07-17-15-37-55-uql-tempshortest.png"></center>

> Shortest path suggests the most direct connection between two nodes. In general, the shorter the path, the greater its connectiveness, and the more value to analyze. For this reason, real-world entities sometimes intentionally hide themselves in exceedingly long distance away (20~30 steps) from another entity. To dig out these suspicious entites, a high-performance DBMS with HTAP-capability, ultra-deep graph traversal capability, and outstanding responsiveness is needed.

## Common Calculations

UQL can conduct a variety of calculations after finding nodes, edges and paths, via functions and clauses. This section introduces some frequently used ones, please refer to UQL manual for detail.

### Deduplicate

Revise the first example demonstrated in section <i>Chains</i> to find those 8 distinct merchants out of 10 in total:
<p run-tag="true" graph="quick_start"></p>

```js
n({_id == "60017791850"}).e().n(as payee) limit 10
with distinct payee as payeeDedup
return payeeDedup{*}
```

- Operator `distinct` deduplicates <i>payee</i> based on node ID
- Deduplication operation is composed in `with`
- Statement `limit 10` is executed before `with`, all UQL statements are executed in the order they are composed

<center><img width=600 src="https://img.ultipa.cn/2022-07-17-16-48-53-uql-distinct.png"></center>

### Count

Revise the previous example to calculate the number of distinct merchants:
<p run-tag="true" graph="quick_start"></p>

```js
n({_id == "60017791850"}).e().n(as payee) limit 10
with count(distinct payee) as cardinality
return cardinality
```

- Function `count()` calculates the number of `distinct payee`, `count()` and `distinct` are sometimes jointly used

<center><img width=600 src="https://img.ultipa.cn/2022-07-17-16-53-36-uql-countdistinct.png"></center>

### Order By

Revise the first example demonstrated in section <i>Edge Query</i> to return those 10 edges in descending order of their transaction amount:
<p run-tag="true" graph="quick_start"></p>

```js
find().edges({_from == "60017791850"}) as payment limit 10
order by payment.tran_amount desc
return payment{*}
```

- Clause keyword `order by` sorts <i>payment</i> by its property <i>tran_amount</i>
- Keyword `desc` in the end of clause `order by` means to sort in descending pattern

<center><img width=860 src="https://img.ultipa.cn/2022-07-17-17-07-29-uql-orderby.png"></center>

### Group By

Revise the second example demonstrated in section <i>Chains</i> to group those 3-step paths by their 3rd node, and count the number of paths in each group:
<p run-tag="true" graph="quick_start"></p>

```js
n({_id == "60017791850"}).e({tran_amount > 70000})[2].n(as third).e({tran_amount > 70000}).n() limit 10
group by third
return table(third.cust_name, count(third))
```

- To express the 3rd node in the path, the original template `n().e()[3].n()` is transformed into `n().e()[2].n().e().n()`
- Clause keyword `group by` divides <i>third</i> based on node ID
- Function `count()` is executed against <i>third</i> within each group
- Function `table()` merges `third.cust_name` and `count(third)` in one table to make them more convenient to check

<center><img width=600 src="https://img.ultipa.cn/2022-07-18-10-56-07-uql-groupby.png"></center>
