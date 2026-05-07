# UPSERT

## Overview

The `UPSERT` statement allows you to update existing nodes in the graph. If no existing node with the same `_id` is found, it inserts a new node instead.

Unlike <a target="_blank" href="/docs/gql/insert-overwrite">`INSERT OVERWRITE`</a> which replaces the whole entity, `UPSERT` preserves existing properties and only updates or adds the properties supplied in the statement.

`UPSERT` is useful in import or sync workflows where the same script may be re-run: existing rows get refreshed properties without manual existence checks, and unaffected fields stay intact.

## Upserting Nodes

If a node with the specified `_id` does not exist, `UPSERT` inserts a new node:

```gql
UPSERT (:User {_id: "U2", name: "Jumpy88", level: 1})
```

If a node with `_id` as `U2` already exists, the listed properties (`name`, `level`) are written over the existing values. Properties of the existing node that are not in the write are kept as-is.

```gql
UPSERT (:User {_id: "U2", level: 2})
```

After this statement, the existing `name` of `U2` remains `"Jumpy88"`, and `level` is updated to `2`.

If `_id` is omitted from the property specification, a new node is always inserted with a system-generated `_id`:

```gql
UPSERT (:User {name: "Jumpy88"})
```