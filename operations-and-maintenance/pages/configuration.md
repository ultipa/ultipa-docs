# Configuration

## HTTP Config API

Ultipa exposes a REST-style HTTP Config API on the metrics port (default 9091) for runtime configuration inspection and hot-update. The API is available on the Name Server alongside the `/health`, `/ready`, and `/metrics` endpoints.

### Viewing Configuration

Send a `GET` request to the `/config` endpoint to retrieve all server configuration keys with their current values and descriptions:

```bash
curl http://<name-server-host>:9091/config
```

Response:

```json
{
  "Log.level": {
    "value": "info",
    "description": "Log level (hot update)"
  },
  "Log.format": {
    "value": "text",
    "description": "Log format: text or json (hot update)"
  },
  "Server.mem_threshold_percent": {
    "value": "80.000000",
    "description": "Memory threshold percent (hot update)"
  }
}
```

Hot-updatable keys are annotated with "hot update" in the description field.

### Updating Configuration

Send a `POST` request to the `/config` endpoint to hot-update one or more configuration keys:

```bash
curl -X POST http://<name-server-host>:9091/config \
  -H 'Content-Type: application/json' \
  -d '{"Log.format": "json", "Log.level": "debug"}'
```

Response:

```json
{
  "results": {
    "Log.format": "OK",
    "Log.level": "OK"
  }
}
```

If a key does not support hot-update or is invalid, the response includes an error message for that key:

```json
{
  "results": {
    "Unknown.Key": "Unknown.Key does not support hot update."
  }
}
```

A single request can contain a mix of valid and invalid keys; each key's result is returned independently.

> Hot-updated values are in-memory only and are not persisted to config files. Values are lost on server restart. To make permanent changes, edit the server config files directly.

### Cross-Server Updates

Use key prefixes to route configuration updates to Shard Servers or Meta Servers through the Name Server:

| Prefix | Target | Description |
| -- | -- | -- |
| (none) | Name Server | Applied directly to the Name Server. |
| `Shard.` | Shard Server(s) | Stripped prefix, broadcast to all Shard Servers. |
| `Meta.` | Meta Server | Stripped prefix, forwarded to the Meta Server leader. |

A single `POST` request can contain keys for all three server types:

```bash
curl -X POST http://<name-server-host>:9091/config \
  -H 'Content-Type: application/json' \
  -d '{
    "Server.slow_query": "3000",
    "Shard.Log.file_retain_counts": "10",
    "Meta.Server.real_time_sync_meta_to_shards": "true"
  }'
```

## Hot-Updatable Configuration Keys

### Name Server Keys

| <div table-width="40">Key</div> | Default | Description |
| -- | -- | -- |
| `Log.level` | `info` | Log verbosity level: `fatal`, `error`, `info`, `debug`. |
| `Log.format` | `text` | Log output format: `text` or `json`. |
| `Log.file_retain_counts` | `5` | Maximum number of log files to retain. |
| `Log.log_file_size` | `200` | Maximum log file size in MB. |
| `Server.mem_threshold_percent` | `80` | Memory usage threshold percentage. |
| `Server.authorized` | `true` | Enables or disables authentication enforcement. |
| `Server.enable_meta_cache` | `true` | Enables or disables meta cache. |
| `Server.enable_top_list` | `true` | Enables or disables the TOP query list. |
| `Server.enable_execution_plan_cache` | `true` | Enables or disables execution plan cache. |
| `Server.slow_query` | `5000` | Slow query threshold in milliseconds. |
| `Server.default_timeout` | `300` | Default query timeout in seconds. |
| `Server.heartbeat_interval_s` | `10` | Heartbeat check interval in seconds. |
| `Network.load_balance_read_only_workloads` | `false` | Enables read-only load balancing. |
| `Network.shard_client_timeout_ms` | `10000` | Shard RPC client timeout in milliseconds. |
| `Network.meta_client_timeout_ms` | `10000` | Meta RPC client timeout in milliseconds. |
| `Session.idle_timeout_second` | `3600` | Session idle timeout in seconds. |
| `Session.count_limit` | `-1` | Maximum session count. `-1` means unlimited. |
| `Audit.file_retain_counts` | `10` | Maximum number of audit log files to retain. |
| `Audit.file_size` | `100` | Maximum audit log file size in MB. |
| `SSO.issuer` | (empty) | OIDC issuer URL. |
| `SSO.jwks_uri` | (empty) | JWKS endpoint URL. |
| `SSO.client_id` | (empty) | OAuth2 client ID. |
| `SSO.username_claim` | `sub` | JWT claim for username. |
| `SSO.clock_skew_seconds` | `30` | Clock skew tolerance in seconds. |
| `SSO.jwks_cache_ttl_seconds` | `3600` | JWKS cache TTL in seconds. |

> Changing any SSO key triggers an SSO authenticator reload.

### Shard Server Keys

These keys use the `Shard.` prefix when sent to the Name Server HTTP API.

| <div table-width="45">Key</div> | Default | Description |
| -- | -- | -- |
| `Shard.Server.disk_min_free_mb` | - | Minimum free disk space in MB. |
| `Shard.Log.file_retain_counts` | `5` | Maximum number of Shard log files. |
| `Shard.Log.log_file_size` | `200` | Maximum Shard log file size in MB. |
| `Shard.ComputeEngine.default_timeout` | - | Compute engine timeout in seconds. |
| `Shard.ComputeEngine.default_max_depth` | - | Maximum traversal depth. |
| `Shard.ComputeEngine.parallel_threshold` | - | Parallel execution threshold. |
| `Shard.Network.shard_client_timeout_ms` | `10000` | Shard RPC timeout in milliseconds. |
| `Shard.Network.meta_client_timeout_ms` | `10000` | Meta RPC timeout in milliseconds. |
| `Shard.PITR.barrier_interval_s` | - | Recovery point interval in seconds. |
| `Shard.PITR.retention_hours` | - | Recovery point retention in hours. |

### Meta Server Keys

These keys use the `Meta.` prefix when sent to the Name Server HTTP API.

| <div table-width="50">Key</div> | Default | Description |
| -- | -- | -- |
| `Meta.Server.real_time_sync_meta_to_shards` | - | Enables real-time meta sync to Shard Servers. |
| `Meta.Server.heartbeat_sync_meta_to_shards` | - | Enables heartbeat meta sync to Shard Servers. |
| `Meta.Server.enable_ddl_shard_health_check` | - | Enables DDL health pre-check. |
| `Meta.Log.file_retain_counts` | `5` | Maximum number of Meta log files. |
| `Meta.Log.log_file_size` | `200` | Maximum Meta log file size in MB. |

## Storage Engine Configuration

The storage engine configuration is set in `shard-server.config` under the `[StorageEngine]` section. Some parameters support hot-update via the HTTP Config API using the `Shard.StorageEngine.` prefix.

### Hot-Updatable Parameters

#### DB-Level Options

| <div table-width="45">Key</div> | Default | Description |
| -- | -- | -- |
| `max_background_flushes` | `2` | Maximum concurrent flush threads. |
| `max_background_compactions` | `0` (auto) | Maximum concurrent compaction threads. `0` uses CPU core count. |
| `bytes_per_sync` | `0` | Periodically sync SST writes (bytes). `0` disables. |
| `wal_bytes_per_sync` | `0` | Periodically sync WAL writes (bytes). `0` disables. |

#### Column-Family-Level Options

| <div table-width="45">Key</div> | Default | Description |
| -- | -- | -- |
| `level0_file_num_compaction_trigger` | `4` | L0 file count to trigger compaction. |
| `level0_slowdown_writes_trigger` | `20` | L0 file count to slow down writes. |
| `level0_stop_writes_trigger` | `36` | L0 file count to stop writes. |
| `max_bytes_for_level_base` | `256` | L1 total size target in MB. |
| `target_file_size_base` | `256` | L1 SST file size target in MB. |
| `compression` | `snappy` | Compression for non-bottommost levels: `none`, `snappy`, `lz4`, `zstd`. Only affects new SST files. |
| `bottommost_compression` | (empty) | Compression for the bottommost level. Empty means same as `compression`. |

#### Block Cache

| <div table-width="45">Key</div> | Default | Description |
| -- | -- | -- |
| `block_cache_size` | `1024` | Block cache size in MB. Dynamically resized without restart. |

#### Example

```bash
curl -X POST http://<name-server-host>:9091/config \
  -H 'Content-Type: application/json' \
  -d '{
    "Shard.StorageEngine.max_background_flushes": "4",
    "Shard.StorageEngine.compression": "lz4",
    "Shard.StorageEngine.block_cache_size": "2048"
  }'
```

### Restart-Only Parameters

The following parameters require a server restart to take effect:

| <div table-width="45">Parameter</div> | Default | Description |
| -- | -- | -- |
| `block_size` | `4` | Block size in KB. |
| `cache_index_and_filter_blocks` | `false` | Place index/filter blocks in block cache. |
| `pin_l0_filter_and_index_blocks_in_cache` | `false` | Pin L0 index blocks in cache. |
| `enable_pipelined_write` | `false` | Enable pipelined write. |
| `use_direct_io_for_flush_and_compaction` | `false` | Use direct I/O for compaction. |
| `min_write_buffer_number_to_merge` | `1` | Number of memtables to merge before flush. |

### High-Performance Configuration Template

```ini
[StorageEngine]
db_buffer_size = 512
max_db_buffer_number = 5
enable_block_cache = true
block_cache_size = 4096

# Background threads
max_background_flushes = 4
max_background_compactions = 8

# L0 triggers
level0_file_num_compaction_trigger = 8
level0_slowdown_writes_trigger = 40
level0_stop_writes_trigger = 64
max_bytes_for_level_base = 512
target_file_size_base = 128

# Compression: lz4 for speed, zstd for bottom level
compression = lz4
bottommost_compression = zstd

# Periodic sync to avoid I/O spikes
bytes_per_sync = 1048576
wal_bytes_per_sync = 524288

# Pipelined write + memtable merge
enable_pipelined_write = true
min_write_buffer_number_to_merge = 2

# Larger block size to reduce index overhead
block_size = 16
cache_index_and_filter_blocks = true
```
