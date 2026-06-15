# Monitoring

GQLDB exposes a layered monitoring surface: logs for events, Prometheus-style metrics for time series, gRPC health checks for liveness, and GQL-visible introspection for state. This page is the index: what each surface gives you, how to enable / scrape it, and which alerts are worth wiring.

## Surfaces at a Glance

| Surface | Shape | Best for | Reference |
| -- | -- | -- | -- |
| **Logs** | Text lines on stderr or rotated log files. | Operational events, errors, startup / shutdown, memory-pressure warnings. | <a href="#logs">Logs</a> |
| **Metrics** | Prometheus-style gauges / counters via in-process collectors. | Throughput, latency, heap / GC, cache hit rate. | <a href="#metrics">Metrics</a> |
| **Health check** | gRPC `HealthService.Check` (extended with HA fields in HA mode). | Liveness / readiness for load balancers, k8s probes, oncall paging. | <a href="#health-checks">Health Checks</a> |
| **GQL introspection** | `db.version()`, `db.license()`, `db.plugins()`, `db.stats()`, `db.overview()` — called inline with `RETURN`. | Synchronous state probes from dashboards or pre-flight checks. | <a href="/docs/operations/database-info" target="_blank">Database Info</a> |
| **HA telemetry** | `SHOW HA STATUS`, `SHOW HA LOG TAIL`, `SHOW HA SNAPSHOTS`, plus `HAService.GetStatus` / `GetReplicationLag` gRPCs. | Cluster topology, leader / follower state, replication lag. | <a href="/docs/operations/clustering#inspecting-cluster-state" target="_blank">Clustering → Inspecting Cluster State</a> |
| **Query management** | `SHOW QUERIES`, `TOP QUERIES`, `KILL QUERY <id>`. | Identifying and stopping slow / runaway queries in real time. | <a href="#query-monitoring">Query Monitoring</a> |

Production monitoring is rarely a single surface. The default stack is: metrics scraped into Prometheus + Grafana, logs shipped to a search backend (Loki, OpenSearch), health checks driving the load balancer, and `SHOW HA STATUS` polled on a slower cadence for on-call dashboards.

## Logs

The fastest path to a problem is usually the log. GQLDB writes structured lines (timestamp, level, subsystem, message) to stderr by default. Configure routing and rotation at startup; see <a href="/docs/operations/database-installation#important-flags" target="_blank">Database Installation → Important Flags</a> for the full flag table.

| Flag | Default | What it does |
| -- | -- | -- |
| `-log-level` | `info` | `debug` / `info` / `warn` / `error`. Drop to `debug` during incident triage; keep at `info` in steady state. |
| `-log-file` | (stderr) | Directory for rotated log files. Empty → stderr only. |
| `-log-max-size` | `100` (MB) | Per-file size cap before rotation. |
| `-log-max-files` | `10` | Retained rotated file count. |

For ad-hoc local testing, shell redirection (`> gqldb.log 2>&1`) captures everything (stderr logs, stdout banners, panic traces) into one flat file. For production, set `-log-file` to a directory and let the rotation flags do the work; pair with a log shipper to push files into your search backend.

### Memory-Pressure Logs

A separate watermark log fires when heap usage crosses configured thresholds. Lines you'll see (rate-limited to one per 30s):

<p tit="Log"></p>

```
[MEMORY WATERMARK] heap=<n> MB >= warn threshold=<m> MB (watermark=<w> MB)
[MEMORY PRESSURE ABORT] heap=<n> MB >= abort threshold=<m> MB ... — refusing new aggregations until heap drops
[MEMORY PRESSURE CLEARED] heap=<n> MB below abort threshold=<m> MB — aggregations re-enabled
```

Enable by setting `config.MemoryWatermarkBytes` in `-config` to your process budget; default `0` disables the feature entirely. The abort threshold causes new memory-hungry operators (`GROUP BY`, `ORDER BY`, aggregations) to reject with a clean error instead of pushing the host toward the OOM killer. See <a href="#Memory-Pressure">Memory Pressure</a> below.

## Metrics

GQLDB runs an in-process `Monitor` that aggregates metrics from registered `MetricsCollector`s on a configurable interval (default 10s). Three collectors are built-in: **query**, **hardware**, **cache**. Metric names are Prometheus-style (`ultipagqldb_*`) with `gauge` or `counter` types.

### Query Metrics (`QueryCollector`)

| Name | Type | What it measures |
| -- | -- | -- |
| `ultipagqldb_queries_total` | Counter | Cumulative queries served since process start. |
| `ultipagqldb_query_latency_avg_ms` | Gauge | Rolling average query latency in milliseconds. |
| `ultipagqldb_queries_active` | Gauge | Currently executing query count. |
| `ultipagqldb_query_errors_total` | Counter | Cumulative query errors. |
| `ultipagqldb_queries_per_second` | Gauge | Recent QPS. |

### Hardware / Runtime Metrics (`HardwareCollector`)

| Name | Type | What it measures |
| -- | -- | -- |
| `ultipagqldb_heap_alloc_bytes` | Gauge | Currently allocated heap. Cross-check against `-mem-limit-bytes`. |
| `ultipagqldb_heap_sys_bytes` | Gauge | Heap memory obtained from the OS. |
| `ultipagqldb_heap_objects` | Gauge | Live heap object count. |
| `ultipagqldb_gc_cycles_total` | Counter | Completed GC cycles. |
| `ultipagqldb_gc_pause_total_ns` | Counter | Cumulative GC pause time. Watch for upward inflection. |
| `ultipagqldb_goroutines` | Gauge | Live goroutine count. Sustained climb = leak. |
| `ultipagqldb_num_cpu` | Gauge | CPU count available to the process. |

Hardware samples are cached for 1 s — multiple `Snapshot()` calls inside a second return the same numbers, avoiding repeated `runtime.ReadMemStats` cost.

### Cache Metrics (`CacheCollector`)

Tracks the AST cache and plan cache:

- **Hits / misses / hit rate** for each — low hit rate on the plan cache means the workload is parameter-thin (each query is unique), warranting query parameterization on the client side rather than tuning here.
- **Entries** — current cache size; bounded by the cache's eviction policy.

### Scraping

The metrics endpoint is served by the gRPC server layer. Point your Prometheus job at the configured endpoint (consult the install or your operator); a default config typically scrapes every 15–30 s.

A snapshot is collected on demand each scrape — the 10s collection ticker is a pacing hint, not a hard cadence. Metric timestamps are server-side, so clock skew between scrapers shows up as a per-metric attribute.

### Custom Collectors

`Monitor.RegisterCollector(collector MetricsCollector)` accepts any type implementing the `MetricsCollector` interface (`Name`, `Category`, `Collect`). Vendor / customer-deployed plugins can add their own metric family without touching the server build.

## Health Checks

Standard gRPC `HealthService.Check` returns `SERVING` / `NOT_SERVING`. In HA mode, the response metadata is extended with:

| Field | Meaning |
| -- | -- |
| `role` | `leader`, `follower`, `learner`, or `witness`. |
| `lag_bytes` | Replication lag in bytes for this node. |
| `compute_ready` | Whether the compute engine has finished its topology build for the bound graph. |

Compatible with any standard gRPC health probe (k8s readiness/liveness, ELB/NLB target groups, grpc-health-probe). The base SERVING / NOT_SERVING behavior is preserved for tooling that doesn't know about the HA extension.

Use it as **liveness** (server responds at all). Use **`compute_ready = true`** + a sensible `lag_bytes` ceiling as **readiness** if you don't want a node to take traffic before its caches are warm.

## HA / Cluster Monitoring

For HA deployments, the cluster-level dashboard should poll a small set of signals:

| Signal | Source | Alert if … |
| -- | -- | -- |
| Leader present | `SHOW HA STATUS` row with `role = leader` | No row with `role = leader` for > 1 election timeout. |
| Voter reachability | `reachable` column | Any voter `reachable = false` for > 30 s. |
| Replication lag | `lag_bytes`, `GetReplicationLag` | Lag growing monotonically, or above a workload-specific ceiling. |
| Term churn | `term` column | Term incrementing faster than expected — election flapping. |
| Snapshot age | `SHOW HA SNAPSHOTS` `taken_at` | Oldest snapshot retained beyond your recovery window. |

See <a href="/docs/operations/clustering" target="_blank">Clustering</a> for the full HA admin surface.

## Query Monitoring

Real-time visibility into running queries via `SHOW QUERIES`, `TOP QUERIES`, and `KILL QUERY <id>`. These management statements bypass concurrency limits and share a dedicated execution path, so they always respond even when the database is saturated. Required permission: `OpManageQuery` (admin-tier by default; see <a href="/docs/rbac" target="_blank">Access Control</a>).

Long-running operators (filter, `ORDER BY`, `UNION`, k-hop) check the cancellation flag frequently, so `KILL QUERY` takes effect promptly rather than waiting for the operator to finish.

Full syntax, return columns, and concurrency-slot model: <a href="/docs/gql/query-management" target="_blank">Query Management</a>.

## Memory Pressure

Optional watermark monitor that turns hard-to-debug "process suddenly OOMs" into "operators reject cleanly with a known error before that happens."

| Config key | Meaning |
| -- | -- |
| `config.MemoryWatermarkBytes` | Process heap budget in bytes. `0` disables the watermark. |
| `config.MemoryWatermarkRatio` | Fraction of budget where the WARN log fires (default ≈ 0.75). |
| `config.MemoryAbortRatio` | Fraction of budget where memory-hungry operators start rejecting (default ≈ 0.9). |

Set in `-config` YAML; the flag set doesn't expose these directly. Once enabled:

1. **Warn:** when heap crosses `MemoryWatermarkRatio × MemoryWatermarkBytes`, the `[MEMORY WATERMARK]` log fires (rate-limited to 30 s between emissions).
2. **Abort:** when heap crosses `MemoryAbortRatio × MemoryWatermarkBytes`, the `[MEMORY PRESSURE ABORT]` log fires once and new aggregations / `GROUP BY` / `ORDER BY` operators reject with a clean error.
3. **Recovery:** when heap drops below the abort threshold, `[MEMORY PRESSURE CLEARED]` logs once and operators re-enable automatically.

Pair with the `ultipagqldb_heap_alloc_bytes` metric for dashboard-driven alerting — the watermark log is for postmortem context; the metric is what your alert manager reads.

## Alert-Worthy Signals

A starting alert set:

| Alert | Rule | Why |
| -- | -- | -- |
| **Server down** | `up{job="gqldb"} == 0` for > 1 min. | Process or scrape endpoint gone. |
| **No leader (HA)** | `SHOW HA STATUS` returns no `leader` for > 1 election timeout. | Cluster can't accept writes. |
| **Replication lag high** | `lag_bytes` > workload ceiling for > 5 min. | Follower falling behind; failover would lose data. |
| **Error rate climbing** | `rate(ultipagqldb_query_errors_total[5m]) / rate(ultipagqldb_queries_total[5m]) > 0.05`. | Workload regression or client misuse. |
| **Latency spike** | `ultipagqldb_query_latency_avg_ms` above a baseline percentile. | Slow query, contention, or stale stats. |
| **Memory pressure** | `[MEMORY PRESSURE ABORT]` in logs **or** `ultipagqldb_heap_alloc_bytes` above abort threshold. | Aggregations will reject. |
| **GC pause climbing** | `rate(ultipagqldb_gc_pause_total_ns[5m])` above baseline. | Heap pressure or large allocations. |
| **Cache hit rate dropping** | Plan cache hit rate < 50 %. | Workload is parameter-thin — promote query parameterization on the client. |

Tune the thresholds to your workload; the rule shapes above are the starting point.

