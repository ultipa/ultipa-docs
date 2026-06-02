# Maintenance & Ops

This section covers GQLDB administration and operations, including the tasks an operator does to keep a running database healthy, observable, and recoverable. The focus is **how to operate the database**, distinct from how to query it.

## What's in Scope

- **Health & introspection** — checking version, license, loaded plugins, current configuration; reading the graph overview and statistics.
- **Backups & restores** — taking snapshots, listing them, restoring from a backup file or directory.
- **Statistics & integrity** — rebuilding statistics that downstream optimizer / `db.node_labels()` calls depend on; validating graph integrity and cleaning up orphan edges.
- **Index management** — listing, rebuilding, and dropping property / fulltext / vector indexes; reading index health.
- **Compute engine** — enabling the engine on a graph, configuring cached properties, monitoring topology build state.
- **Task & query control** — listing running queries and tasks, killing long-runners, monitoring active transactions.
- **Bulk maintenance** — truncating labels or whole graphs, draining and rebuilding.
- **Ontology enforcement & validation** — switching modes per session, validating an existing graph against its declared ontology.

## What's NOT in This Section

| Topic | Where it lives |
| -- | -- |
| GQL syntax for any statement above (e.g., `BACKUP`, `RESTORE`, `SHOW INDEX`) | <a href="/docs/gql" target="_blank">ISO GQL</a> |
| Driver-side API for admin calls | <a href="/docs/drivers" target="_blank">Ultipa Drivers</a> |
| Role / permission management for admin operations | <a href="/docs/rbac" target="_blank">Access Control</a> |
| Compute engine internals & tuning | <a href="/docs/computing-engine" target="_blank">Computing Engine</a> |
| AI / vector index ops (e.g., `ai.rebuild_index`) | <a href="/docs/ai-and-vectors" target="_blank">AI &amp; Vectors</a> |

Pages here are operator-focused: when to run a command, what to watch for, what to do if it fails — not the full syntax reference. Each page cross-links to the underlying GQL statement page for the canonical grammar.
