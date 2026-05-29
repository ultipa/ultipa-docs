# Database Functions

## db.version()

Returns the database version string.

```gql
RETURN db.version()
```

## db.license()

Returns license information.

```gql
RETURN db.license()
```

## db.plugins()

Returns a list of loaded plugins.

```gql
RETURN db.plugins()
```

## db.stats()

Returns statistics of the current graph, including node/edge counts, label counts, and properties.

```gql
RETURN db.stats()
```

The returned record contains the following fields:

| Field | Type | Description |
| -- | -- | -- |
| `graphName` | `STRING` | Name of the current graph |
| `nodeCount` | `INT` | Total number of nodes |
| `edgeCount` | `INT` | Total number of edges |
| `unlabeledNodeCount` | `INT` | Number of nodes without labels |
| `unlabeledEdgeCount` | `INT` | Number of edges without labels |
| `labelCounts` | `RECORD` | Node counts per label (e.g., `{"Paper": 3}`) |
| `edgeLabelCounts` | `RECORD` | Edge counts per label (e.g., `{"Cites": 2}`) |
| `nodePropertyStats` | `RECORD` | Node property counts per label (e.g., `{"Paper": {"title": 3, "score": 3}}`) |
| `edgePropertyStats` | `RECORD` | Edge property counts per label (e.g., `{"Cites": {"weight": 2}}`) |
| `unlabeledNodePropertyStats` | `RECORD` | Property counts for unlabeled nodes |
| `unlabeledEdgePropertyStats` | `RECORD` | Property counts for unlabeled edges |

```gql
LET stats = db.stats()
RETURN stats.nodeCount AS nodes, stats.edgeCount AS edges
```

## db.overview()

Returns the current graph overview with label counts and edge patterns.

```gql
RETURN db.overview()
```

The returned record contains:

| Field | Type | Description |
| -- | -- | -- |
| `labelCounts` | `LIST` | List of `{label, count, type}` records for each node/edge label |
| `edgePatterns` | `LIST` | List of `{fromLabel, edgeLabel, toLabel, edgeCount}` records describing connection patterns |

## db.node_labels()

Returns all node labels in the current graph.

```gql
RETURN db.node_labels()
```

## db.edge_labels()

Returns all edge labels in the current graph.

```gql
RETURN db.edge_labels()
```

## db.label_property()

Returns the properties defined for each label in the current graph. For closed graphs, returns schema-defined properties. For open graphs, discovers properties by scanning data.

```gql
RETURN db.label_property()
```

The returned record maps each label name to a `{type, properties}` record, where `type` is `"node"` or `"edge"` and `properties` is a list of property names.

## db.reload_stats()

Rebuilds statistics from storage for the current graph. Also registered under the aliases `db.rebuild_stats()` and `db.repair_stats()`.

```gql
RETURN db.reload_stats()
```

## Backup and Restore Functions

Refer to <a href="/docs/gql/backup-and-restore/#Backup-Functions">Backup and Restore</a>.