# UPSERT

## Overview

The `UPSERT` statement allows you to update existing nodes and edges in the graph. If no existing data is found, it will insert new nodes or edges instead.

In **typed graphs**, each node or edge belongs to exactly one schema, and the assigned schema cannot be changed after insertion. Attempting to update a node or edge with a different schema will result in an error. When a node or edge is updated, the properties specified in the new definition will be updated, while any properties not included remain unchanged.

On the other hand, when a node or edge is overwritten in **open graphs**, both its label and property are updated to the new definition.

## Updating Nodes

An existing node will be updated if `_id` is included in the property specification and its value can be found in the graph. For example:

```gql
UPSERT (:User {_id: "U2", name: "Jumpy88"})
```

If a node with `_id` equal to `U2` already exists in the graph, its schema/label and properties will be updated with the new values. If no such node exists, a new node will be inserted.

```gql
UPSERT (:User {name: "Jumpy88"})
```

Since the property specification does not include `_id`, a new node will be inserted into the graph.

## Updating Edges

An existing edge is updated if the `EDGE KEY` property is included in the property specification and its value can be found in the graph. In addition, the specified source and destination nodes must remain the same. 

For example, the `EDGE KEY` constraint applies to the property `eID`:

```gql
ALTER EDGE * ADD CONSTRAINT EDGE KEY ON eID STRING
```

<a target="_blank" href="/docs/gql/constraints#EDGE-KEY">Learn more about the EDGE KEY constraint →</a>

```gql
MATCH (n1:User {name: "mochaeach"}), (n2:User {name: "Brainy"})
UPSERT (n1)-[e:Follows {eID: "e6561"}]->(n2)
```

If an edge with `eID` equal to `e6561` already exists in the graph and its source and destination nodes are `mochaeach` and `Brainy` respectively, its schema/label and properties will be updated with the new values. If no such edge exists, a new edge will be inserted.
