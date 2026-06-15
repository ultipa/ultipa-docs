# Auto-Sharding Rebalancing

## Overview

Auto-sharding rebalancing is a background monitor that detects data imbalance across shards and automatically triggers data migration to rebalance the cluster. The monitor runs on the Meta Server leader and is disabled by default. It can be enabled and configured per graph.

## Enabling Auto-Rebalance

To enable auto-rebalance for a graph:

```gql
ALTER GRAPH social SET AUTO_REBALANCE = {
    enabled: true,
    data_imbalance_threshold: 0.3,
    disk_usage_threshold: 0.85,
    cooldown_seconds: 3600,
    strategy: "balance"
}
```

| <div table-width="28">Parameter</div> | Default | Description |
| -- | -- | -- |
| `enabled` | `false` | Enables or disables the auto-rebalance monitor. |
| `data_imbalance_threshold` | `0.3` | Triggers rebalance when `(max - min) / avg` across shards exceeds this threshold. |
| `disk_usage_threshold` | `0.85` | Triggers rebalance when any shard's disk usage exceeds this percentage. |
| `cooldown_seconds` | `3600` | Minimum time in seconds between consecutive rebalance triggers. |
| `strategy` | `balance` | Rebalance strategy: `balance`, `quickly_expand`, or `quickly_shrink`. |

## Showing Auto-Rebalance Status

```gql
SHOW AUTO_REBALANCE
```

Returns the following fields for each configured graph:

| <div table-width="28">Field</div> | Description |
| -- | -- |
| `graph` | The graph name. |
| `enabled` | Whether auto-rebalance is enabled. |
| `data_imbalance_threshold` | Configured data imbalance threshold. |
| `disk_usage_threshold` | Configured disk usage threshold. |
| `cooldown_seconds` | Configured cooldown period. |
| `strategy` | Configured rebalance strategy. |
| `last_trigger_time` | Time of the last rebalance trigger. |
| `current_imbalance_ratio` | Current data imbalance ratio across shards. |

## Disabling Auto-Rebalance

```gql
ALTER GRAPH social DROP AUTO_REBALANCE
```

## Trigger Conditions

Rebalance is triggered when either of the following conditions is met:

1. **Data imbalance ratio** exceeds `data_imbalance_threshold`.
2. **Disk usage** on any shard exceeds `disk_usage_threshold`.

## Safety Guards

- Rebalance is not triggered during `GRAPH_SCALING`, `GRAPH_LOADING_SNAPSHOT`, or `GRAPH_CREATING` states.
- Single-shard graphs are skipped.
- Manual `ALTER GRAPH` operations pause auto-rebalance; monitoring resumes after the manual operation completes.
- On Meta Server leader failover, the new leader resumes monitoring.

## Strategies

| Strategy | Description |
| -- | -- |
| `balance` | Redistributes data evenly across all available shards. |
| `quickly_expand` | Expands data to additional shards when disk usage is high. |
| `quickly_shrink` | Consolidates data to fewer shards. |
