# Reserved Words

Reserved keywords in UQL are terms with predefined meanings that influence query behavior. These words cannot be used as identifiers for aliases, schemas, properties, or other user-defined elements.

The following are reserved keywords in UQL:

| Category | <div table-width=70>Words</div> |
| ---- | ---- |
| System Property | `_id`, `_uuid`, `_from`, `_to`, `_from_uuid`, `_to_uuid` |
| System Table Alias | `_graph`, `_graph_shard_N` `_nodeSchema`, `_nodeSchema_shard_N` `_edgeSchema`, `_edgeSchema_shard_N`, `_graphCount`, `_nodeProperty`, `_nodeProperty_shard_N`, `_edgeProperty`, `_edgeProperty_shard_N`, `_nodeIndex`, `_edgeIndex`, `_nodeFulltext`, `_edgeFulltext`, `_statistic`, `_top`, `_job`, `_policy`, `_user`, `_privilege`, `_algoList`, `_extaList`, `_hdcGraphList`, `_projectionList`, `_vector`, `_nodeVectorIndex`, `_edgeVectorIndex`, `_backupList` |
| System Alias | `this`，`prev_n`，`prev_e` |
| Operator<sup>[1]</sup> | `IN`, `NIN`, `CONTAINS`, `XOR`, `DISTINCT`, `IS NULL`, `IS NOT NULL` |
| Statement<sup>[1]</sup> | `GROUP BY`, `ORDER BY`, `SKIP`, `LIMIT`, `WHERE`, `RETURN`, `WITH`, `UNCOLLECT`, `UNION`, `UNION ALL`, `CALL`, `OPTIONAL`, `EXPLAIN` |
| Modifiers<sup>[1]</sup> | `AS`, `ASC`, `DESC` |
| Expression<sup>[1]</sup> | `CASE`, `WHEN`, `THEN`, `ELSE`, `END` |

<sup>[1]</sup> Those reserved words are case-insensitive.

## Escaping Identifiers

In UQL, special characters or keywords may interfere with the proper recognition of an identifier. To handle this, such identifiers are escaped by enclosing them in backquotes (<code>`</code>). This ensures that the identifier is treated as a literal value, rather than a keyword or malformed syntax.

When a schema or property name contains characters other than letters (A-Z, a-z), numbers (0-9) and underscores (`_`), it must be enclosed in backquotes (<code>`</code>) for correct recognition when it is being utilized.

In this example, the schema name `club-member` has to be escaped:

```uql
find().nodes({@`club-member`}) as n
return n
```

In this example, the property name `height.meter` has to be escaped:

```uql
find().nodes({`height.meter` > 10}) as n
return n
```

In this example, the alias `my-Nodes` has to be escaped:

```uql
find().nodes() as `my-Nodes`
return `my-Nodes`
```
