# Monitoring

## Prometheus Metrics

Ultipa exposes a `/metrics` HTTP endpoint on each server (default port 9091) in Prometheus text format, enabling integration with Prometheus and Grafana dashboards.

### Enabling Metrics

The metrics endpoint is available by default on the HTTP Config API port.

### Available Metrics

| <div table-width="35">Metric</div> | Description |
| -- | -- |
| `ultipa_active_queries` | Number of currently executing queries. |
| `ultipa_active_sessions` | Number of active client sessions. |
| `ultipa_uptime_seconds` | Server uptime in seconds. |
| `ultipa_memory_usage_bytes` | Current memory usage in bytes. |
| `ultipa_total_queries` | Total number of queries executed since startup. |
| `ultipa_total_errors` | Total number of query errors since startup. |
| `ultipa_shard_count` | Number of shard groups in the cluster. |
| `ultipa_plan_cache_hits` | Plan cache hit count. |
| `ultipa_plan_cache_misses` | Plan cache miss count. |
| `ultipa_plan_cache_size` | Current plan cache size. |
| `ultipa_cpu_usage_percent` | CPU utilization percentage. |
| `ultipa_open_file_descriptors` | Number of open file descriptors. |
| `ultipa_disk_usage_bytes` | Disk usage in bytes. |
| `ultipa_server_ready` | Server readiness status (1 = ready, 0 = not ready). |

### Prometheus Configuration

Add the following to your `prometheus.yml`:

```yaml
scrape_configs:
  - job_name: 'ultipa'
    static_configs:
      - targets: ['<name-server-host>:9091', '<shard-server-host>:9091']
```

## Structured JSON Logging

Ultipa supports configurable log format for integration with log aggregation systems like ELK or Splunk.

### Configuration

Add the following to any server config file:

```ini
[Log]
log_format = json
```

| <div table-width="15">Parameter</div> | Default | Hot-Updatable | Description |
| -- | -- | -- | -- |
| `log_format` | `text` | Yes | Log output format: `text` or `json`. |

JSON log entries include ISO 8601 timestamps, log level, and structured message fields.

## Audit Logging

Audit logging records security-relevant events such as logins, DDL operations, and privilege changes to separate log files.

### Configuration

Add the following section to `name-server.config`:

```ini
[Audit]
enabled = true
audit_query = false
```

| <div table-width="18">Parameter</div> | Default | Hot-Updatable | Description |
| -- | -- | -- | -- |
| `enabled` | `false` | Yes | Enables or disables audit logging. |
| `audit_query` | `false` | Yes | When enabled, also logs individual query executions. |

### Audit Events

Audit log entries include the user, client IP, timestamp, and operation details. Events include:

- User login/logout
- DDL operations (CREATE/DROP GRAPH, ALTER SCHEMA, etc.)
- Privilege and role changes
- Backup and restore operations
