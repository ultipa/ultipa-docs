# Operations

This section covers GQLDB administration and operations, including the tasks an operator does to keep a running database healthy, observable, and recoverable. The focus is **how to operate the database**, distinct from how to query it.

## What's in Scope

- **Install & deploy:** installing GQLDB Community or Commercial Edition, sizing a host, picking a deployment topology (single-node, 3-node HA, 2-data + witness), and bringing the database up for the first time. See <a href="/docs/operations/database-installation" target="_blank">Database Installation</a> and <a href="/docs/operations/deployment-topologies" target="_blank">Deployment Topologies</a>.
- **Operate a cluster:** observing leader / follower state, replication lag, planned failover, adding and removing voters, and recovering from quorum loss. See <a href="/docs/operations/clustering" target="_blank">Clustering</a>.
- **Cloud & marketplace:** running GQLDB as a managed service on Ultipa Cloud (DBaaS) or as a self-managed AMI from AWS Marketplace — what each path handles for you, what you still run, and when to pick which. See <a href="/docs/operations/cloud-deployments" target="_blank">Cloud Deployments</a>.
- **Inspect a running database:** version, license, loaded plugins, per-graph statistics, schema, and current-graph context. See <a href="/docs/operations/database-info" target="_blank">Database Info</a>.
- **Backup & restore:** taking hot full and incremental backups at graph or database scope, listing and verifying archives, dropping catalog entries, restoring with or without overwrite. See <a href="/docs/operations/backup-restore" target="_blank">Backup & Restore</a>.
- **Monitoring:** logs, Prometheus-style metrics, gRPC health checks, HA telemetry, query monitoring, memory-pressure watermark, alert-worthy signals. See <a href="/docs/operations/monitoring" target="_blank">Monitoring</a>.
- **Performance:** indexes, compute engine, edge `_id`, memory and WAL flags, statistics freshness, storage hardware, HA read routing, bulk import. A catalog of levers with links to canonical references. See <a href="/docs/operations/performance" target="_blank">Performance</a>.

## What's NOT in This Section

| Topic | Where it lives |
| -- | -- |
| GQL syntax for query / DML / DDL statements unrelated to operations | <a href="/docs/gql" target="_blank">ISO GQL</a> |
| Driver-side API for admin calls | <a href="/docs/drivers" target="_blank">Ultipa Drivers</a> |
| Role / permission management for admin operations | <a href="/docs/rbac" target="_blank">Access Control</a> |
| Compute engine internals & tuning | <a href="/docs/computing-engine" target="_blank">Computing Engine</a> |
| AI / vector index ops (e.g., `ai.rebuild_index`) | <a href="/docs/ai-and-vectors" target="_blank">AI &amp; Vectors</a> |

Pages here are operator-focused: when to run a command, what to watch for, what to do if it fails, not the full syntax reference. Each page cross-links to the underlying GQL statement page for the canonical grammar.
