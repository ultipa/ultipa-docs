# Monitoring

GQLDB exposes a layered monitoring surface: logs for events, Prometheus-style metrics for time series, gRPC health checks for liveness, and GQL-visible introspection for state. This page is the index: what each surface gives you, how to enable / scrape it, and which alerts are worth wiring.

## Surfaces at a Glance

| Surface | Shape | Best for |
| -- | -- | -- |
| <a href="#Logs">**Logs**</a> | Text lines on stderr or rotated log files. | Operational events, errors, startup / shutdown. |
| <a href="#Metrics">**Metrics**</a> | Prometheus-style gauges / counters via in-process collectors. | Throughput, latency, heap / GC, cache hit rate. |
| <a href="#Health-Checks">**Health check**</a> | gRPC `HealthService.Check` (extended with HA fields in HA mode). | Liveness / readiness for load balancers, k8s probes, oncall paging. |
| <a href="/docs/operations/database-info" target="_blank">**Database Info**</a> | Functions `db.version()`, `db.license()`, `db.plugins()`, `db.stats()`, `db.overview()`, etc. | Synchronous state probes from dashboards or pre-flight checks. |
| <a href="/docs/operations/clustering#Inspecting-Cluster-State" target="_blank">**HA telemetry**</a> | `SHOW HA STATUS`, `SHOW HA LOG TAIL`, `SHOW HA SNAPSHOTS`, plus `HAService.GetStatus` / `GetReplicationLag` gRPCs. | Cluster topology, leader / follower state, replication lag. |
| <a href="/docs/gql/query-management" target="_blank">**Query management**</a> | `SHOW QUERIES`, `KILL QUERY <id>`. | Identifying and stopping slow / runaway queries in real time. |

Production monitoring is rarely a single surface. The default stack is: metrics scraped into Prometheus + Grafana, logs shipped to a search backend (Loki, OpenSearch), health checks driving the load balancer, and `SHOW HA STATUS` polled on a slower cadence for on-call dashboards.

For a starting alert set built on these surfaces, see <a href="#Alert-Worthy-Signals">Alert-Worthy Signals</a>.

## Logs

The fastest path to a problem is usually the log. GQLDB writes structured lines (timestamp, level, subsystem, message) to stderr by default. Configure routing and rotation at startup; see <a href="/docs/operations/database-installation#See-All-Flags" target="_blank">Database Installation → See All Flags</a> for the full flag table.

| Flag | Default | What it does |
| -- | -- | -- |
| `-log-level` | `info` | `debug` / `info` / `warn` / `error`. Drop to `debug` during incident triage; keep at `info` in steady state. |
| `-log-format` | `text` | Output format: `text` or `json`. Use `json` for ingestion by log shippers / search backends. |
| `-log-source` | `false` | Include the source `file:line` in each log line. Useful for debugging; adds overhead in steady state. |
| `-log-file` | (stderr) | Directory for rotated log files. Empty → stderr only. |
| `-log-max-size` | `100` (MB) | Per-file size cap before rotation. |
| `-log-max-files` | `10` | Retained rotated file count. |

For ad-hoc local testing, shell redirection (`> gqldb.log 2>&1`) captures everything (stderr logs, stdout banners, panic traces) into one flat file. For production, set `-log-file` to a directory and let the rotation flags do the work; pair with a log shipper to push files into your search backend.

## Metrics

GQLDB runs an in-process `Monitor` that aggregates metrics from registered `MetricsCollector`s on a configurable interval (default 10s). Two collectors are built-in: **query** and **hardware**. Metric names are Prometheus-style (`ultipagqldb_*`) with `gauge` or `counter` types. Scrape them via the Prometheus endpoint (see [Scraping](#scraping)).

### Reading Metrics with SHOW STATS

`SHOW STATS` returns a snapshot of the collected metrics in-band as a query result — one row per metric, with columns `category`, `metric`, and `value`. Pass a category to filter to a single collector:

```gql
SHOW STATS              -- all metrics
SHOW STATS QUERY        -- query throughput / latency / errors
SHOW STATS HARDWARE     -- heap, GC, goroutines, CPU
```

Only the registered collectors have data, so `QUERY` and `HARDWARE` are the categories that return rows. Use `SHOW STATS` for ad-hoc checks from a GQL session; use the Prometheus endpoint for continuous monitoring.

### Query Metrics

Emitted by the `QueryCollector`:

| Name | Type | What it measures |
| -- | -- | -- |
| `ultipagqldb_queries_total` | Counter | Cumulative queries served since process start. |
| `ultipagqldb_query_latency_avg_ms` | Gauge | Rolling average query latency in milliseconds. |
| `ultipagqldb_queries_active` | Gauge | Currently executing query count. |
| `ultipagqldb_query_errors_total` | Counter | Cumulative query errors. |
| `ultipagqldb_queries_per_second` | Gauge | Recent QPS. |

### Hardware / Runtime Metrics

Emitted by the `HardwareCollector`:

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

## Alert-Worthy Signals

A starting alert set:

| Alert | Rule | Why |
| -- | -- | -- |
| **Server down** | `up{job="gqldb"} == 0` for > 1 min. | Process or scrape endpoint gone. |
| **No leader (HA)** | `SHOW HA STATUS` returns no `leader` for > 1 election timeout. | Cluster can't accept writes. |
| **Replication lag high** | `lag_bytes` > workload ceiling for > 5 min. | Follower falling behind; failover would lose data. |
| **Error rate climbing** | `rate(ultipagqldb_query_errors_total[5m]) / rate(ultipagqldb_queries_total[5m]) > 0.05`. | Workload regression or client misuse. |
| **Latency spike** | `ultipagqldb_query_latency_avg_ms` above a baseline percentile. | Slow query, contention, or stale stats. |
| **Memory near limit** | `ultipagqldb_heap_alloc_bytes` approaching `-mem-limit-bytes` for > 5 min. | Risk of OOM or rejected operations. |
| **GC pause climbing** | `rate(ultipagqldb_gc_pause_total_ns[5m])` above baseline. | Heap pressure or large allocations. |
| **Cache hit rate dropping** | Plan cache hit rate < 50 %. | Workload is parameter-thin — promote query parameterization on the client. |

Tune the thresholds to your workload; the rule shapes above are the starting point.
