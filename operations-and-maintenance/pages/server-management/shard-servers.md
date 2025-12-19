# Shard Servers

## Overview

**Shard servers** are a crucial component of the <a target="_blank" href="/docs/graph-database/ultipa-powerhouse-v5">Ultipa Powerhouse (v5)</a> architecture, typically comprising multiple servers dedicated to distributed graph storage and computation. This design enables horizontal scaling while delivering highly competitive performance.

Each shard supports **multi-replica** data storage. In the three-shard setup example below, shards `1` and `2` each have three replicas, while shard `3` has two replicas. Graphs are distributed across these shards: `Graph_1` in all three shards, `Graph_2` and `Graph_3` partially stored across the three shards, and `Graph_4` located in a single shard.

<div align=center drawio-diagram='19408' drawio-name="draw_c9f0477cfbf8493dbb59a134b19d630f.jpg"><img src="https://img.ultipa.cn/draw/draw_c9f0477cfbf8493dbb59a134b19d630f.jpg?v='1730714946152'"/></div>

## Showing Shard Servers

Retrieves information about all shard servers:

```uql
show().shard()
```

The details returned for each shard server include:

| <div table-width="15">Field</div> | Description |
| -- | -- |
| `shardId` | The unique identifier, typically numbered sequentially (1, 2, 3, ...), of each shard server. |
| `shardStatus` | Current state of the shard server, which can be `ACTIVE` or `DEAD`. |
| `replicas` | The replicas of the shard server. Each replica includes:<ul><li>`status`: The current status of the replica, which can be `ACTIVE` or `DEAD`.</li> <li>`addr`: The IP address and port of the replica.</li><li>`streamAddr`: The IP address and port of the stream service of replica.</li><li>`lastHeartbeatTime`: The timestamp of the last heartbeat sent to the meta servers by the replica.</li></ul> |

## Adding a Shard Server

After successfully deploying a new shard server, it must be registered with the meta servers before it can be utilized. This process ensures that the new shard server is recognized within the system.

Adds a Shard server `4` with three replicas:

```uql
alter().shard().add({
  shardId: 4,
  replicas: [
    {addr: "127.0.0.1:40061", streamAddr: "127.0.0.1:40023"},
    {addr: "127.0.0.2:40061", streamAddr: "127.0.0.2:40023"},
    {addr: "127.0.0.3:40061", streamAddr: "127.0.0.3:40023"}
  ]
})
```

You can also add shard servers on the server-side by running the `./ultipa.sh` script provided during <a target="_blank" href="/docs/operations-and-maintenance/install-ultipa">deployment</a>:

```bash
./ultipa.sh cluster addshard --config example.sh
```

## Altering a Shard Server

You can alter the replicas of a shard server.

Alters the replicas of the Shard server `4`:

```uql
alter().shard().replace({
  shardId: 4,
  replicas: [
    {addr: "127.0.0.1:40061", streamAddr: "127.0.0.1:40023"},
    {addr: "127.0.0.2:40061", streamAddr: "127.0.0.2:40023"}
  ]
})
```

## Deleting a Shard Server

You can unregister an inactive or obsolete shard server from the meta servers.

Deletes the shard server `1`:

```uql
alter().shard().delete({shardId: 1})
```
