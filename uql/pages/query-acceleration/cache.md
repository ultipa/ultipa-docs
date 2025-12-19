# Cache

## Overview

Database **caching** is a performance enhancement technique that stores frequently accessed data in the memories of shard servers, reducing reliance on the disk storage and significantly improving query response times.

### Cache Types

Ultipa supports the following cache types:

- **Graph cache**: Contains the graph topology information, speeding up graph traversal.
- **Node cache:** Includes the <a href="#LTE">LTE-ed</a> node properties, accelerating node filtering.
- **Edge cache:** Includes the <a href="#LTE">LTE-ed</a> edge properties, accelerating edge filtering.

### Server Cache Configuration

The default staus, maximum memory usage, and eviction policy of graph cache, node cache, and edge cache are defined in the  `ComputeEngine` section of each shard server's configuration. The relevant configuration items include:

- `engine_type` (`default` or `speed`)
- `enable_graph_cache`
- `graph_cache_size`
- `graph_cache_bucket_number`
- `graph_cache_max_memory_policy`
- `enable_node_cache`
- `enable_edge_cache`
- `node_cache_size`
- `edge_cache_size`

<a target="_blank" href="/docs/operations-and-maintenance/install-ultipa#Shard-Server">View configuration details</a>.

### Cache Warm-Up

When the above-mentioned `ComputeEngine > engine_type` is set to `speed`, **cache warm-up** is supported. This feature preloads data into caches before the database begins serving queries, enabling faster response times from the outset. <a href="#Warming-Up">How to warm up cache</a>

Without warming up, data is loaded into caches only when accessed for the first time by a query, meaning that initial queries won't benefit from cache acceleration.

### Clearing Cache

Cached is stored in memory temporarily and is cleared either upon server restart or through <a href="#Clearing-Cache-1">manual clearance</a>.

## Viewing Cache Status

You can view the status of a cache type for all shard servers using the `cache.<cacheType>.status()` statement.

```uql
// Views graph cache status
cache.graph.status()

// Views node cache status
cache.node.status()

// Views edge cache status
cache.edge.status()
```

It returns tables `_cache_shard_1`, `_cache_shard_2` and so on. Each table `_cache_shard_<N>` contains information about the cache type for the shard with id `<N>`, and includes the following fields:

| <div table-width="13">Field</div> | Description |
| -- | -- |
| `status` | Current state of the cache type, which can be `On` or `Off`. |
| `cache_size` | The allocated maximum size (in MB) for the cache type, i.e., the `graph_cache_size`, `node_cache_size`, or `edge_cache_size` defined in <a href="#Server-Configurations">Server Configurations</a>. |

## Turning On Cache

You can turn on a cache type for all shard servers using the `cache.<cacheType>.turnOn()` statement. This operation runs as a job, you may run `show().job(<id?>)` afterward to verify the success of the completion.

Note that cache status will revert to the original configuration as defined by `enable_graph_cache`, `enable_node_cache`, and `enable_edge_cache` upon server restart.

```uql
// Enables graph cache for all leader replicas across all graphsets
cache.graph.turnOn()

// Enables graph cache for both leader and follower replicas across all graphsets
cache.graph.turnOn({followers: true})

// Enables node cache for all leader replicas across all graphsets
cache.node.turnOn()

// Enables node cache for both leader and follower replicas across all graphsets
cache.node.turnOn({followers: true})

// Enables edge cache for all leader replicas across all graphsets
cache.edge.turnOn()

// Enables edge cache for both leader and follower replicas across all graphsets
cache.edge.turnOn({followers: true})
```

## Turning Off Cache

You can turn off a specific cache type for all shard servers using the `cache.<cacheType>.turnOff()` statement.

Note that cache status will revert to the original configuration as defined by `enable_graph_cache`, `enable_node_cache`, and `enable_edge_cache` upon server restart.

```uql
// Disables graph cache for all leader replicas across all graphsets
cache.graph.turnOff()

// Disables graph cache for both leader and follower replicas across all graphsets
cache.graph.turnOff({followers: true})

// Disables node cache for all leader replicas across all graphsets
cache.node.turnOff()

// Disables node cache for both leader and follower replicas across all graphsets
cache.node.turnOff({followers: true})

// Disables edge cache for all leader replicas across all graphsets
cache.edge.turnOff()

// Disables edge cache for both leader and follower replicas across all graphsets
cache.edge.turnOff({followers: true})
```

## Warming Up

If supported, you can load data from the current graphset into caches using the `cache.<cacheType>.warmup()` statement. The warm-up runs as a job, you may run `show().job(<id?>)` afterward to verify the success of the completion. This operation consumes memory and can only be performed when the corresponding cache type is <a href="#Turning-On-Cache">enabled</a>.

```uql
// Loads graph topology into cache for the leader replica
cache.graph.warmup()

// Loads graph topology into cache for both leader and follower replicas
cache.graph.warmup({followers: true})

// Loads all LTE-ed node properties into cache for the leader replica
cache.node.warmup()

// Loads all LTE-ed node properties into cache for both leader and follower replicas
cache.node.warmup({followers: true})

// Loads all LTE-ed edge properties into cache for the leader replica
cache.edge.warmup()

// Loads all LTE-ed edge properties into cache for both leader and follower replicas
cache.edge.warmup({followers: true})
```

## Clearing Cache

You can clear cache of the current graphset using the `cache.<cacheType>.clear()` statement. This operation frees up memory.

```uql
// Clears graph topology from cache for the leader replica
cache.graph.clear()

// Clears graph topology from cache for both leader and follower replicas
cache.graph.clear({followers: true})

// Clears all LTE-ed node properties from cache for the leader replica
cache.node.clear()

// Clears all LTE-ed node properties from cache for both leader and follower replicas
cache.node.clear({followers: true})

// Clears all LTE-ed edge properties from cache for the leader replica
cache.edge.clear()

// Clears all LTE-ed edge properties from cache for both leader and follower replicas
cache.edge.clear({followers: true})
```
