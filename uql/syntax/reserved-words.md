# Reserved Words

The following words are reserved by the Ultipa Graph system and should not be used when naming schema, property and alias:

| Category | <div table-width=70>Words</div> |
| ---- | ---- |
| System Property | `_id`, `_uuid`, `_from`, `_to`, `_from_uuid`, `_to_uuid` |
| System Table Alias | `_graph`, `_nodeSchema`, `_edgeSchema`, `_nodeProperty`, `_edgeProperty`, `_nodeIndex`, `_edgeIndex`, `_nodeFulltext`, `_edgeFulltext`, `_statistic`, `_top`, `_task`, `_policy`, `_user`, `_privilege`, `_algoList`, `_extaList` |
| System Alias | `this`，`prev_n`，`prev_e` |
| Operator, Clause<sup>(1)</sup> | `IN`, `NIN`, `CONTAINS`, `XOR`, `DISTINCT`, `IS NULL`, `IS NOT NULL`, `AS`, `ASC`, `DESC`, `GROUP BY`, `ORDER BY`, `SKIP`, `LIMIT`, `WHERE`, `RETURN`, `WITH`, `UNCOLLECT`, `UNION`, `UNION ALL`, `CALL`, `SET` |
| Function Keyword<sup>(1)</sup> | `CASE`, `WHEN`, `THEN`, `ELSE`, `END` |
| Prefix<sup>(1)</sup> | `EXEC TASK`, `EXPLAIN`, `PROFILE`, `DEBUG`, `OPTIONAL`, `TRY` |

<sup>(1)</sup> Words that are case insensitive
