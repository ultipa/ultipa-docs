# Standalone Mode

## Overview

Standalone mode is a simplified deployment mode that embeds the Shard Server into the Name Server process. Instead of running three separate processes (Meta Server, Shard Server, and Name Server), standalone mode requires only two processes (Meta Server and Name Server).

This mode is suitable for:

- Development and testing environments
- Single-machine deployments
- Resource-constrained environments
- Quick prototyping

> Standalone mode is not recommended for production environments as it lacks shard-level fault isolation and horizontal scaling capabilities.

## Comparison with Standard Mode

| <div table-width="20">Feature</div> | Standard Mode | Standalone Mode |
| -- | -- | -- |
| Processes required | Meta Server + Shard Server + Name Server | Meta Server + Name Server |
| Configuration complexity | Multiple server configs | Name Server config only |
| Resource usage | Higher (multiple processes) | Lower (merged processes) |
| Use case | Production, distributed | Development, single-machine |

## Configuration

Add the `[Standalone]` section to `name-server.config`:

```ini
[Standalone]
enabled = true
shard_id = 1
data_path = /data/ultipa/shard
resource_path = /data/ultipa/resource
```

| <div table-width="18">Parameter</div> | Default | Description |
| -- | -- | -- |
| `enabled` | `false` | Enables or disables standalone mode. |
| `shard_id` | `1` | Unique identifier for the embedded shard. |
| `data_path` | (empty) | Shard data storage path. Uses `Server.data_path` if empty. |
| `resource_path` | (empty) | Resource file path (e.g., full-text search dictionaries). Uses `data_path` if empty. |

### Full Configuration Example

```ini
[Server]
addr = 0.0.0.0:60061
private_addr = 127.0.0.1:60161
id = 1
meta_server_addrs = 127.0.0.1:50061
data_path = /data/ultipa
worker_num = 10
authorized = true

[Log]
level = 3
stdout = true

[Standalone]
enabled = true
shard_id = 1
data_path = /data/ultipa/shard
resource_path = /data/ultipa/resource
```

## Starting

### Using the Startup Script

```bash
cd /opt/distribute-graphdb
./start_standalone.sh
```

The script automatically copies the standalone configuration template, creates necessary data directories, starts Meta Server and Name Server, and checks process status.

### Manual Startup

```bash
# Copy standalone config template
cp config/name-server-standalone.config config/name-server.config

# Start Meta Server
./meta-server &
sleep 3

# Start Name Server (with embedded shard)
./name-server &
```

## Limitations

- Only supports `engine_type=default`. The `engine_type=speed` (SpeedCache) is not compatible with standalone mode and will cause a crash. Use `enable_graph_cache=true` with `graph_cache_max_memory_policy=s3fifo` or `lru` as an alternative.
- No shard-level fault isolation.
- No horizontal scaling.
- Migrating from standalone mode to standard mode requires data export and re-import.
