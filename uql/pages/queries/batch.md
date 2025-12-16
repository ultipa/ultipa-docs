# BATCH

## Overview

The `BATCH` clause partitions data into smaller batches, where each batch collects data into an array. These arrays are then processed sequentially by the following clause. The `BATCH` clause is helpful when dealing with large datasets that may overwhelm memory resources, potentially leading to system crashes. While this strategy can result in a slight performance sacrifice, it significantly reduces memory usage. This approach is particularly beneficial when passing a large number of start nodes into a path query, ensuring efficient and stable query execution.

## Syntax

The `BATCH` clause should follow the definition of an alias, except when a `LIMIT` or `SKIP` clause intervenes:

<p tit="Syntax"></p> 

```js
`<clause>` as `<alias>` `<LIMIT/SKIP clause?>` BATCH `<batch-size>`
`<clause>`
```

Where `<batch-size>` is the amount of data in each batch.

## Examples

```js
find().nodes({@post}) as nodes LIMIT 1000 BATCH 100
khop().n(nodes as a).le()[2].n() as b 
GROUP BY a 
WITH avg(b.length) as len
RETURN a._uuid, len ORDER BY len DESC LIMIT 10
```

This UQL puts 1000 @post nodes into 10 batches, each containing 100 nodes. Nodes in each batch are automatically collected into an array and passed into the `khop()` query, which is executed for 10 times independently. Afterward, the final results of the `khop()` query are combined and used in the subsequent clauses.

```js
find().nodes({@user.age_level == 4}) as users
BATCH 100
n(users).e().n({@ad} as ads)
GROUP BY ads.cate
RETURN table(ads.cate, count(ads.cate))
```

This UQL puts all @user nodes of the no.4 age group into batches, each containing 100 nodes. Nodes in each batch are automatically collected into an array and passed into the path template query, which is executed for multiple times independently. Afterward, the final results of the path template query are combined and used in the subsequent clauses.
null
