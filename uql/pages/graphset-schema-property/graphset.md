# Graphset

## Overview

An Ultipa Graph instance allows for the existence of multiple graphsets. Each graphset includes the definition of the graph structure (schemas and properties), graph metadata (nodes and edges), various indexes, processes, tasks, and so on. Sometimes, the terms "graphset" and "graph" are used interchangeably.

A graphset named ***default*** is automatically created during the creation of an Ultipa Graph instance. This *default* graphset is initially empty and can be freely utilized. However, the *default* graphset is not allowed to be altered (name and description), dropped, or unmounted.

> In a cluster environment, the unmounting, mounting, and truncating UQLs will be sent to the leader node for execution.

## Show Graph

```js
// Show all graphsets in the instance (via listGraph API)
show().graph()

// Show all graphsets in the instance (via listGraph API)
show().graph("")

// Show the graphset named Sample in the instance
show().graph("Sample")
```

Example result:

| <div table-width=5>id</div> | <div table-width=10>name</div> | totalNodes | totalEdges | <div table-width=25>description</div> | status |
| -- | -- | -- | -- | -- | -- |
| 0 | default | 0 | 0 | System default graph! | MOUNTED |
| 1 | Sample | 112 | 125 | | MOUNTED |

The status of a graphset can be `mounted`, `unmounted` or `mounting`. Large graphsets may take some time to finish mounting.

A mounted graphset displays the total number of nodes and edges within it. An unmounted graphset displays 0 for both `totalNodes` and `totalEdges`. During the unmounting process, the graphset displays the number of nodes and edges that are currently mounted.

## Create Graph

```js
// Create a graphset named social, and provide description
create().graph("social", "Campus social graph")

// Create a graphset named social
create().graph("social")

// Create multiple graphsets at one time
create()
  .graph("social")
  .graph("transaction", "Bank Card Transaction")
```

### Naming Conventions

Here are the naming conventions for graphsets:

- Contains 2 to 64 characters.
- Must start with letters.
- Allowed characters include letters (A-Z, a-z), underscore (`_`), and numbers (0-9).

You cannot have two graphsets with the same name.

### Use TRY

Create three graphsets at the same time, but one of the names (*default*) is duplicated with an existing graphset.

```js
create().graph("newGraph_1").graph("default").graph("newGraph_2")
```

The creation of the graphset *newGraph_1*, which was specified before the duplicated graphset, succeeds. However, the one (*newGraph_2*) specified after the duplicated graphset fails, with the error message `Duplicated db name!` returned.

```js
TRY create().graph("newGraph_1").graph("default").graph("newGraph_2")
```

The creation of the graphsets is the same as above, though the error message is shielded by the `TRY` prefix, while returning the message `SUCCEED`.

## Alter Graph

```js
// Alter name and description of the graphset currently named "miniCircle"
alter().graph("miniCircle").set({name: "movieCommunity", description: "Unix Movie Platform"})

// Remove description of the graphset named "movieCommunity"
alter().graph("movieCommunity").set({description: ""})

// Rename the graphset named "movieCommunity"
alter().graph("movieCommunity").set({name: "movComm"})
```

## Unmount Graph

You may unmount temporarily unused graphsets (except the *default* graphset) to save instance memory. For example, the LTE-ed properties will be unloaded from the memory.

When a graph is unmounted, it’s not allowed to modify or read the schemas, properties, data, etc. within the graph. Unmounted graph can only be mounted, altered or dropped.

```js
// Unmount a graphset named "LDCC" from the instance memory
unmount().graph("LDCC")
```

## Mount Graph

Newly created graphsets are mounted by default. You may need to manually re-mount any unmounted graphsets.

When a graphset is remounted, its previously LTE-ed properties will be reloaded into the memory; the indexes and full-text indexes will also be automatically recreated as before.

```js
// Mount a graphset named "LDCC" back to the instance memory
mount().graph("LDCC")
```

## Drop Graph

Dropping a graphset means to delete the entire graphset. The *default* graphset cannot be dropped.

```js
// Drop the graphset named "test0831"
drop().graph("test0831")

// Drop multiple graphsets at one time
drop().graph("test0831").graph("test0925")
```

## Truncate Graph

Truncating a graphset only deletes the specified data within the graph, while the graphset itself and its structure (schemas & properties) are retained.

```js
// Truncate all nodes and edges in the graphset named "PowerGrid"
truncate().graph("PowerGrid")

// Truncate all @bus nodes (and their adjacent edges) in the graphset named "PowerGrid"
truncate().graph("PowerGrid").nodes(@bus)
                                     
// Truncate all @connectsTo edges in the graphset named "PowerGrid"
truncate().graph("PowerGrid").edges(@connectsTo)

// Truncate all nodes (and edges) in the graphset named "PowerGrid"
truncate().graph("PowerGrid").nodes("*")

// Truncate all edges in the graphset named "PowerGrid"
truncate().graph("PowerGrid").edges("*")
```

> Note that deleting a node leads to the removal of all edges that are connected to it.

## Compact Graph

Compacting a graphset clears invalid and redundant data from the graph on the server disk but does not make any changes to other valid data. 

```js
// Compact the graphset named "PowerGrid"
compact().graph("PowerGrid")
```

> Operations related to data manipulation can generate redundant data, such as old records retained after an update or deletion operation. It's suggested to regularly compact graphsets to improve query efficiency.
