# Projections

## Overview

A **projection** is a materialized subset of nodes and edges of a graph. Projections accelerate queries and algorithms by holding the relevant entities in an in-memory representation, separate from the underlying graph storage.

Projections are not auto-updated. When the underlying graph changes, the system flips the projection's `stale` flag automatically, but the materialized data remains as it was at the last build until you explicitly run `REFRESH PROJECTION`. Queries against a stale projection still execute — they just see the older snapshot.

> The materialized topology (the actual cached node and edge data) of projections lives **in memory**. After a database restart, the projections still appear in `SHOW PROJECTIONS`, but the topology cache is empty — it is rebuilt on first access or by an explicit `REFRESH PROJECTION`.

## Showing Projections

Show all projections on the current graph:

```gql
SHOW PROJECTIONS
```

Each projection provides the following metadata:

| Field | Description |
| -- | -- |
| `name` | Projection name. |
| `node_count` | Number of nodes captured. |
| `edge_count` | Number of edges captured. |
| `memory` | Approximate memory used by the projection. |
| `stale` | Whether underlying data has changed since the last build. |
| `last_refresh` | Timestamp of the last build or refresh. |

Show detailed metadata for one projection:

```gql
DESCRIBE PROJECTION social_graph

-- DESC is a shorthand for DESCRIBE
DESC PROJECTION social_graph
```

The returned properties are:

| Property | Description |
| -- | -- |
| `name` | Projection name. |
| `node_count` | Number of nodes captured. |
| `edge_count` | Number of edges captured. |
| `memory` | Approximate memory used by the projection. |
| `stale` | Whether underlying data has changed since the last build. |
| `created_at` | Timestamp when the projection was created. |
| `last_refresh` | Timestamp of the last build or refresh. |
| `node_labels` | Node label specs, rendered in source form (e.g., `:Person.{name, age}, :Company.{*}`). Only present when node labels are configured. |
| `edge_labels` | Edge label specs, rendered the same way. Only present when edge labels are configured. |

## Creating Projections

```syntax
<create projection statement> ::=
  "CREATE PROJECTION" <projection name> 
  "WITH NODE" <label specifications> [ "EDGE" <label specifications> ]

<label specifications> ::= 
    <label specification> [ { "," <label specification> }... ]
  | "*" 

<label specification> ::= ":" <label name> [ ".{" ( "*" | <property list> ) "}" ]

<property list> ::= <property name> [ { "," <property name> }... ] 
```

A label can be specified in three ways depending on how much data should be materialized:

| Form | What's materialized | Memory |
| -- | -- | -- |
| `:Label` | Topology only — node/edge `_id`s and the label. No property values. | Smallest |
| `:Label.{*}` | Topology plus **all** properties of the label. | Largest |
| `:Label.{p1, p2}` | Topology plus **only the listed** properties. | In between |

Choose based on what downstream queries or algorithms will actually read.

Project all `User` nodes and `Follows` edges into a projection named `social_graph`:

```gql
CREATE PROJECTION social_graph WITH NODE :User EDGE :Follows
```

Multiple labels can be listed per side:

```gql
CREATE PROJECTION user_and_club
  WITH NODE :User, :Club
       EDGE :Follows, :Joins
```

Use the `*` wildcard to include every label:

```gql
CREATE PROJECTION all_proj WITH NODE * EDGE *
```

A projection can be node-only — useful for algorithms that operate on a node set without edges:

```gql
CREATE PROJECTION user_only WITH NODE :User
```

Append property list to a label to include only specific properties; use `.{*}` to include all properties:

```gql
-- All properties of User
CREATE PROJECTION full_props WITH NODE :User.{*} EDGE *

-- Only the name property of User
CREATE PROJECTION partial_props WITH NODE :User.{name} EDGE *
```

## Refreshing Projections

A projection becomes **stale** when the underlying nodes or edges change after the projection was built. `REFRESH PROJECTION` rebuilds the projection from current data:

```gql
REFRESH PROJECTION social_graph
```

The staleness flag is reported by `SHOW PROJECTIONS`.

## Dropping Projections

```gql
DROP PROJECTION social_graph
```

Use `IF EXISTS` to avoid errors when the projection may not exist:

```gql
DROP PROJECTION IF EXISTS social_graph
```

## Querying on a Projection

Use `[OPTIONAL] MATCH ... ON <projection>` statement to route execution through a projection's cache instead of the full graph:

Pattern matching on a projection:

```gql
MATCH (a:User)-[:Follows]->(b:User) ON social_graph
RETURN a.name, b.name
```

Optional match on a projection:

```gql
OPTIONAL MATCH (a:User)-[:Follows]->(b:User)
         WHERE a.age > 30
         ON social_graph
RETURN a.name, b.name
```

## Running Algorithms on a Projection

Algorithm call on a projection:

```gql
CALL algo.degree() ON social_graph YIELD nodeId, score
```

The inline `CALL { … }` subquery form does **not** accept `ON`.
