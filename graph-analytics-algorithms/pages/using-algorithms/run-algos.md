# Run Algorithms

You can run algorithms in Ultipa Manager, Ultipa CLI, or Ultipa Driver (Restful API/Python/NodeJS/Java/Go).

## Algo Command

The UQL clause to run algorithm starts with the command `algo()`, the name of the algorithm is to be specified in the parentheses.

Example: `algo(degree)`

## Parameter Configuration

Configure the algorithm parameters in `params()` and wrap the key-value pairs into an object format.

Example: `algo(degree).params({ direction: 'in', order: 'asc' })`

`params()` cannot be omitted even if all parameters are not set.

Example: `algo(degree).params()`

## Node/Edge Filter

Some algorithms (e.g., Degree Centrality, PageRank, K-Hop All, Louvain) support the usage of `node_filter()` and `edge_filter()` to specify the nodes or edges to participate in the calcualatin.

```uql
// Compute the degree of the node with UUID 1 in the subgraph composed of @account nodes
algo(degree).params({ 
  uuids: 1
}).node_filter({@account}) as d
return d
```

## Execution Methods

Ultipa algorithm supports four types of execution methods, and you need to specify one method when running an algorithm:

| <div table-width="11">Execution Method</div> | <div table-width="10">Execution Parameter</div> | Description | <div table-width="18">Further Processing <sup>(1)</sup></div> | 
| --- | --- | --- | --- |
| Task Writeback | `write()` | Run the algorithm as <a href="/docs/uql/backend-task">task</a>; you can specify that algorithm results are written back to file (RPC interface) or property, and any algorithm statistics, if available, are written to task information | Not supported |
| Direct Return | / | Return algorithm results and statistics directly | Not supported |
| Stream Return | `stream()` | Return algorithm results as data stream | Supported |
| Stats Return | `stats()` | Return algorithm statistics as data stream | Not Supported |

<sup>(1)</sup> This means to use the alias(es) defined for the `algo()` clause in subsequent UQL clauses other than the RETURN clause.

### 1. Task Writeback: File, Property 

Task writeback includes <b>file writeback</b> and <b>property writeback</b>. Performing both file and property writeback simultaneously is not supported. During file or property writeback, any available statistics are also written back to the algorithm task.

#### 1.1 File Writeback

To write the algorithm results back to one or more files, you need to configure the filenames. The written back files has no header, and each row of data is separated by a comma. The algorithm statistics (if any) are also written back to the algorithm task information.

Syntax: Wrap the `file` object in `write()`, the configuration items in the `file` object are detailed in the introduction of each algorithm

```uql
algo(connected_component).params({
  cc_type: 1
}).write({
  file:{ 
    filename_ids: 'f1',
    filename_num: 'f2'
  }
})
```

> You may use <i>.csv</i> or <i>.txt</i> as the file suffix, or to ignore it.

#### 1.2 Property Writeback

To write the algorithm results back to one or more node or edge properties, you need to configure the property names. The algorithm statistics (if any) are also written back to the algorithm task information.

Property writeback is a full-volume operation, i.e., written back to all nodes or edges in the current graph, so you do not need to specify a schema when providing property names. For either schema, if the provided write-back property does not exist, the property is automatically created; if a write-back property already exists but the data type is inconsistent, the write-back of the property under that schema would fail. For nodes or edges with calculation results, the algorithm result is written to the properties; for those with no result, write 0, empty string, and so on based on the data type of the algorithm result.

Syntax: Wrap the `db` object in `write()`, the configuration items in the `db` object are detailed in the introduction of each algorithm

```uql
algo(closeness_centrality).params().write({
  db:{
    property: "centrality"
  }
})
```

### 2. Direct Return

For algorithms with statistics, it is supported to define two aliases, the first is the algorithm result alias and the second is the statistics alias, the order cannot be modified. If the algorithm does not have any statistics, only one alias can be defined.

Syntax: Define alias(es) directly and assemble it with a RETURN clause

```uql
algo(degree).params({
  direction: 'out'
}) as a1, a2 
return a1, a2
```

### 3. Stream Return

Only one alias can be defined, which generally represents the algorithm result. After defining an alias for an algorithm statement, you may continue writing other UQL clauses and using that alias, but assembling UQL clauses that insert, modify, or delete metadata with operations is not supported.

Syntax: Use `stream()` and define an alias

```uql
algo(closeness_centrality).params().stream() as cc
where cc.centrality > 0.5
return cc._uuid
```

### 4. Stats Return

Only one alias can be defined, which represents statistics. After defining an alias for an algorithm statement, you may return the statistics.

Syntax: Use `stats()` and define an alias

```uql
algo(lpa).params({
  node_label_property: @default.name,
  k: 1,
  loop_num: 5
}).stats() as labelCount 
return labelCount
```