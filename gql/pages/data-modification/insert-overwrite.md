# INSERT OVERWRITE

## Overview

The `INSERT OVERWRITE` statement allows you to overwrite existing nodes in the graph. If no existing node with the same `_id` is found, it inserts a new node instead.

The overwrite operation works by deleting the existing node with the same `_id` first, then inserting the new node. This means all properties and labels of the existing node are replaced with the new definition.

## Overwriting Nodes

An existing node will be overwritten if `_id` is included in the property specification and a node with that `_id` exists in the graph:

```gql
INSERT OVERWRITE (:User {_id: "U2", name: "Jumpy88"})
```

If a node with `_id` equal to `U2` already exists, it will be deleted and replaced with the new node. If no such node exists, a new node will be inserted.

If `_id` is not specified, a new node is always inserted:

```gql
INSERT OVERWRITE (:User {name: "Jumpy88"})
```

Since the property specification does not include `_id`, a new node will be inserted with a system-generated `_id`.
