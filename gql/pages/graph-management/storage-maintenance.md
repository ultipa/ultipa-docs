# Storage Maintenance

This page covers administrative statements that operate on the underlying storage and optimizer state of a graph: recomputing statistics, forcing a flush to durable storage, and triggering a manual compaction of the storage layer.

## ANALYZE

`ANALYZE` recomputes label and property statistics that the cost-based optimizer uses to estimate row counts and choose plans. Run it after large bulk imports or significant data churn so the planner picks up the new distribution.

```gql
ANALYZE
```

Limit `ANALYZE` to a specific node label or edge type:

```gql
ANALYZE (:Person)
ANALYZE EDGE [:Knows]
```

Nodes use parentheses (like a node pattern); edges use the `EDGE` keyword followed by brackets (like an edge pattern).

## COMPACT GRAPH

`COMPACT` triggers a manual compaction of the storage, consolidating data files and reclaiming space from deleted records. Routine compaction runs automatically in the background; the explicit form is useful before a backup, after a large `DELETE` batch, or when investigating disk usage.

```gql
-- Compact the current graph
COMPACT

-- Compact a named graph
COMPACT GRAPH myGraph

-- Short form
COMPACT myGraph
```

Compaction runs in the background; the statement returns when the work has been scheduled.
