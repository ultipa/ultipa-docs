# INSERT OVERWRITE

## Overview

The `INSERT OVERWRITE` statement allows you to overwrite existing nodes and edges in the graph. If no existing data is found, it will insert new nodes or edges instead.

In **typed graphs**, each node or edge belongs to exactly one schema, and the assigned schema cannot be changed after insertion. Attempting to overwrite a node or edge with a different schema will result in an error. When a node or edge is overwritten, the properties specified in the new definition will be updated, while any properties not included will be set to `null`.

On the other hand, when a node or edge is overwritten in **open graphs**, both its label and property are updated to the new definition.

## Overwriting Nodes

An existing node will be overwritten if `_id` is included in the property specification and its value can be found in the graph. For example:

```gql
INSERT OVERWRITE (:User {_id: "U2", name: "Jumpy88"})
```

If a node with `_id` equal to `U2` already exists in the graph, its schema/label and properties will be overwritten with the new values. If no such node exists, a new node will be inserted.

```gql
INSERT OVERWRITE (:User {name: "Jumpy88"})
```

Since the property specification does not include `_id`, a new node will be inserted into the graph.

## Overwriting Edges

An existing edge is overwritten if the `EDGE KEY` property is included in the property specification and its value can be found in the graph. In addition, the specified source and destination nodes must remain the same. 

For example, the `EDGE KEY` constraint applies to the property `eID`:

```gql
ALTER EDGE * ADD CONSTRAINT EDGE KEY ON eID STRING
```

<a target="_blank" href="/docs/gql/constraints#EDGE-KEY">Learn more about the EDGE KEY constraint →</a>

```gql
MATCH (n1:User {name: "mochaeach"}), (n2:User {name: "Brainy"})
INSERT OVERWRITE (n1)-[e:Follows {eID: "e6561"}]->(n2)
```

If an edge with `eID` equal to `e6561` already exists in the graph and its source and destination nodes are `mochaeach` and `Brainy` respectively, its schema/label and properties will be overwritten with the new values. If no such edge exists, a new edge will be inserted.
