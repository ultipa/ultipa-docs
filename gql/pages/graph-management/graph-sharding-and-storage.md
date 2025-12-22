# Graph Sharding and Storage

## Overview

The graph data is physically stored on the **shard servers** that constitute the <a target="_blank" href="/docs/graph-database/powerhouse-v5">Ultipa database deployment</a>. Depending on your setup, you can run one or multiple shard servers. 

When creating a graph, you can designate one or multiple shard servers to store its nodes and edges in a distributed manner. This sharded architecture enables **horizontal scaling** of your data volume while maintaining high-performance querying.

## Graph Sharding

To create a typed graph `g1`, the graph data will be distributed across three shards `[1,2,3]` using the `CityHash64` hash function:

```gql
CREATE GRAPH g1 { 
  NODE User ({name STRING, age UINT32}),
  NODE Club ({name STRING, score FLOAT}),
  EDGE Joins ()-[{joinedDate DATE}]->()
}
PARTITION BY HASH(CityHash64) SHARDS [1]
```

The keyword `PARTITION BY` specifies the hash function, and `SHARDS` specifies the shard ID list:

- **Hash function:** A hash function (`Crc32`, `Crc64WE`, `Crc64XZ`, or `CityHash64`) computes the hash value for the sharding key (i.e., nodes' `_id`), which is essential for sharding the graph data. For more information, refer to <a target="_blank" href="https://en.wikipedia.org/wiki/Cyclic_redundancy_check">Crc</a> and <a target="_blank" href="https://github.com/google/cityhash">CityHash</a>.
- **Shard ID list:** A list of shard server IDs indicating where the graph data will be stored.

Both keywords are optional. By default, the graph data is to be distributed to all shards using `Crc32`.

To create an open graph `g2`, the graph data will be stored on shard `[1]` only:

```gql
CREATE GRAPH g2 ANY SHARDS [1]
```

## Graph Data Migration

Graph data migration may become necessary sometime — whether to more shards when existing ones become overloaded, or to distribute data across additional geographical locations. Conversely, migrating to fewer shards can free up underutilized resources, reduce costs, and simplify management.

To migrate graph `g3` to shards `[1,4,5]`:

```gql
ALTER GRAPH g3 ON SHARDS [1,4,5]
```

This is equivalent to:

```gql
ALTER GRAPH g3 ON SHARDS [1,4,5] PARTITION CONFIG {strategy: "balance"}
```

The default **migration strategy** is `balance`, which redistributes the graph data evenly across the new shards. In addition, you may specify one of the following strategies:

- `quickly_expand`: Quickly migrates some data from existing shards to newly added shards. The new shard list must include all current shards.
- `quickly_shrink`: Quickly migrates data from removed shards to the remaining shards. The new shard list must be a sub list of the current shards.

Assuming graph `g3` is currently distributed across shards `[1,2]`, to quickly migrate it to `[1,2,4]`:

```gql
ALTER GRAPH myGraph ON SHARDS [1,2,4] PARTITION CONFIG {strategy: "quickly_expand"}
```

To quickly migrate `g3` from shards `[1,2]` to `[1]`:

```gql
ALTER GRAPH myGraph ON SHARDS [1] PARTITION CONFIG {strategy: "quickly_shrink"}
```
