# Database Functions

## Overview

Database functions provide access to database metadata and statistics.

## db.stats()

Returns database statistics as a map containing node count, edge count, and other metadata.

**Syntax:**

```
db.stats() -> map
```

**Example:**

```gql
RETURN db.stats() AS stats
```

Result:

| stats |
| -- |
| {nodes: 15000, edges: 45000, labels: ["Person", "Company", "Product"], edgeTypes: ["KNOWS", "WORKS_AT", "BOUGHT"]} |

**Access individual statistics:**

```gql
LET stats = db.stats()
RETURN stats.nodes AS node_count, stats.edges AS edge_count
```

Result:

| node_count | edge_count |
| -- | -- |
| 15000 | 45000 |
