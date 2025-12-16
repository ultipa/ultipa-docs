# Release Notes

> This page provides the release notes for Ultipa Graph Database and Ultipa Graph Analytics & Algorithms since 2022. These notes detail major features, bug fixes, performance improvements, and other changes introduced in each version.

## beta.5.0.7 Release (2024-10-11)

- Introduced more predicates to GQL.
- Introduced more functions to GQL.
- Fixed known bugs in GQL.

## beta.5.0.6 Release (2024-09-26)

- Introduced more statements to GQL.
- Introduced more expressions to GQL.
- Introduced more operators to GQL.
- Fixed known bugs in GQL.

## v4.5.7 Release (2024-09-14)

- Introduced advanced configurations for server license CPU cores. You can now flexibly control the maximum and minimum CPU cores available based on different time ranges, as well as view the total count of CPU cores.
- Fixed known bugs.

## beta.5.0.5 Release (2024-08-30)

- GQL is now supported.

## v4.5.5 Release (2024-08-21)

- Introduced `MATCH`, `CREATE` and `MERGE` clauses in UQL.
- Introduced the Schema Overview algorithm.

## v4.5.3 Release (2024-07-25)

- Fixed issues where the step is set to 0 in template queries.
- Refactored the `SET` clause.
- Fixed unknown bugs.

## beta.5.0.4 Release (2024-07-04)

- Introduced three new graph algorithms: Text Rank, K1 Coloring and Conductance.
- The system property `_uuid` can no longer be assigned by users.
- The start and end nodes of edges cannot be altered any more.
- Introduced composite property index.

## beta.5.0.3 Release (2024-06-26)

- Introduced the synchronization mechanism between meta server and shard.
- A UQL query now can only be concluded with the `RETRUN` `UNION` or `LIMIT` clause.

## beta.5.0.2 Release (2024-06-06)

- `_id` and `schema._id` now support LTE.
- Introduced composite property index.
- The usage of `@*` is now disabled in index creation.
- Introduced `nodetach()`, `delete().nodes().nodetach()` will not delete edges that attached to the deleted nodes.
- Fixed crash issue caused by the deletion of graphsets.
- `limit()` in template queries now applies to each single start node.

## beta.5.0.1 Release (2024-05-23)

- Fixed the crash issue occurred because some schemas did not support float data types.
- The LTE and turnOn operations have been modified to run as task.
- Introduced `zip` operator.
- Introduced speed cache.
- Refactored caching functionalities. The logic for adding, deleting, and modifying graphsets has been changed.

## v4.4.44 Release (2024-05-13)

- Resolved issues regarding LTE.
- Fixed known bugs.

## v4.4.41 Release (2024-04-23)

- Optimized memory usage of the graph topological structure.
- Enhanced the efficiency of template aggregation.
- Resolved the startup consistency issue.
- Fixed known bugs.

## beta5.0.0 Release (2024-04-18)

- The initial beta release of Ultipa Graph v5! Introduced shard, meta server, and hdc server.
- Task is updated to Job.

## v4.4.34 Release (2024-03-28)

- Introduced the `edge_schema_property` parameter to the Closeness Centrality and Harmonic Centrality algorithms.
- Fixed known bugs.

## v4.4.31 Release (2024-03-25)

- Resolved the issue of performing a Cartesian product when returning aggregate functions along with heterologous data.
- Optimized the filtering of the `decimal` type properties.
- Fixed known bugs.

## v4.4.27 Release (2024-02-29)

- Resolved the parsing error occurred when the schema name contains the character ".".
- Fixed known bugs.

## v4.4.23 Release (2024-02-19)

- `db.backup.create()` has been adjusted to be as a system privilege.
- Resolved the bug occurred when index is created for the property used in `CASE`.
- Fixed known bugs.

## v4.4.21 Release (2024-01-20)

- The `UNCOLLECT` clause now supports multiple expressions.
- Fixed known bugs.

## v4.4.20 Release (2023-12-27)

- Introduced `SET` clause, e.g., `find().nodes(1) as n SET n.value = 10, n.age = 12 return n{*}`.
- Fixed known bugs.

## v4.4.19 Release (2023-12-14)

- Introduced `percentile_cont` and `percentile_disc` functions.
- Optimized `toGraph` function to support lists containing `PATH` or `GRAPH` type elements and to allow multiple parameters without restrictions on their order.

## v4.4.15 Release (2023-11-21)

- Optimized the efficiency of template aggregation.
- Introduced `GRAPH` data structure.
- Introduced `toGraph` function.

## v4.3.94 Release (2023-11-13)

- Introduced `blob` type to properties.
- The `expireDate` field in the `stats()` return now supports displaying "Long Term."
- Introduced new operators `KhopTemplateCount`, `KhopTemplateGroupCount`, `TemplateCount`, and `OptionalTemplateCount`. They are visible when using the `EXPLAIN` prefix.
- Introduced new type conversion functions: `toSet()`, `toDouble()` and `toDecimal()`.
- Added `extra` in the returns of the `show().schema()` clause to show the precision and scale information of `decimal` properties.
- Added `size` in the returns of the `show().index()` clause to show the size of the index in bytes.
- Introduced the `TRY` prefix.
- New supported syntax: `n(<filter?> as nodes) as paths return nodes{*}, paths{*}`
- Updated the incremental backup functionalities:
  - Create backup: `db.backup.create("<backup_name>")`
  - Show backups: `db.backup.show("<backup_name?>")`
  - Restore backup: `db.backup.restore("<backup_name>", <backup_id?>)`
- Deleted `rpc Backup (BackupRequest) returns (BackupReply)` interface in proto.
- Introduced graph privileges `CREAT_BACKUP`, `RESTORE_BACKUP`, and `SHOW_BACKUP`.

## v4.3.80 Release (2023-10-30)

- Introduced incremental backup functionalities:
  - Create backup: `db.backup.create("<backup_path>")`
  - Show backups: `db.backup.show("<backup_path>")`
  - Restore backup: `db.backup.restore("<backup_path>", backup_id?)`
- Introduced `set` type to properties.

## v4.3.77 Release (2023-10-19)

- Introduced `decimal` type to properties.
- Added `extra` in the returns of the `show().property()` clause to show the precision and scale information of `decimal` properties.
- Introduced new string functions: `trim()`, `ltrim()`, `rtrim()`, `left()`, `right()`, `substring()`, `reverse()` and `replace()`.
- Introduced string concatenation using the operator `+`, e.g., `return 'a'+'b'`.

## v4.3.74 Release (2023-09-25)

- Introduced `JSON_decode` and `JSON_merge` functions.
- Fixed known bugs.

## v4.3.71 Release (2023-09-18)

- Introduced property encryption. E.g., `create().node_property(@default, "name", string).encrypt()`, `encrypt()` encrypts the node property `@default.name` with `AES128`. Only support for `string` and `text` types.
- Fixed issues related to trigger.

## v4.3.65 Release (2023-08-31)

- Introduced property privileges.
- The `show().property()` clause now indicates whether read and write operations are permitted for each property.

## v4.3.60 Release (2023-08-18)

- Introduced the trigger functionality.
- Introduced new features to the `point` type, including using `.` to extract the coordinate values (e.g., `nodes.pointType.x`, `nodes.pointType.y`), and new function `pointInPolygon`.

## v4.3.58 Release (2023-07-28)

- Enhanced rules for template queries.
- The LPA and HANP algorithms now support multiple properties.
- Fixed some bugs in algorithms.

## v4.3.56 Release (2023-07-19)

- Addressed some abnormal crash problems.
- Improved EXTA interface performance.
- Resolved EXTA installation issue in ARM architecture.

## v4.2.66 Release (2023-06-27)

- Updates were made to the monitor.
- Fixed known bugs.

## v4.3.51 Release (2023-06-13)

- Resolved the memory leak issue in the algorithms.
- Fixed known bugs.

## v4.3.49 Release (2023-05-29)

- Aggregation functions now ignore null values.
- Added `ListData` tag in proto.
- Introduced new spatial function `point`.
- Server.config configuration parameters `private_addr` and `public_addr` now support domain names.
- Fixed the issue of memory not being released under ARM architecture by changing the memory allocator to jemalloc and limiting the huge page size.

## v4.2.65 Release (2023-05-11)

- Resolved memory leak in "ultipa.lic" certificate timing monitoring.
- Fixed out-of-memory (OOM) bug in K-hop queries.
- Fixed crash issue in the Eigenvector Centrality algorithm.

## v4.3.31 Release (2023-04-25)

- Fixed the bug causing random results in list filtering.
- Optimized aggregate functions.
- Fixed known bugs.

## v4.3.26 Release (2023-04-11)

- Renamed `distinct` function to `dedup`, `DISTINCT` is now an operator keyword.
- Refactored the `UNION`, `WITH` and `RETURN` clauses.
- Resolved parsing issues related to special characters.

## v4.3.22 Release (2023-03-31)

- Introduced `is_null` field in `AttrListData`.
- Modified the proto.
- Fixed issues related to inserting and updating properties of the `point` type.

## v4.3.12 Release (2023-03-15)

- Introduced the `point` type to properties.
- Introduced `listContains` and `distance` functions.
- The `OPTIONAL` prefix now supports more clauses, including `find().nodes()`, `find().edges()` and `k-hop()`.
- Resolved inconsistency issues between memory and disk when inserting data with a mix of `_uuid` and `_id` specifications.
- Fixed bugs related to the `list` type.
- Updated EXTA functionalities.
- Introduced `is_null` tag in proto.
- Introduced the `Backup` interface in proto for creating backups of the entire database to a specified directory.
- Added new startup parameter `-restore` in `ultipa-server` to restore data from backup file directory.

## v4.2.59 Release (2023-02-23)

- Resolved crashes related to lists.
- Resolved bugs related to null values in aggregation functions.
- Merged HTAP log and server log into a single file.

## v4.2.53 Release (2023-02-06)

- Optimized metadata structure to save memory usage.
- Improved storage and performance of modification functions.
- Introduced EXTA functionality that allows custom algorithm plugins.
- Added the `text` type to properties without text-length limit.
- Introduced `Server.docker_mem_usage_path` and `Server.memory_max_limit` in config for memory limit control in the Cloud version.
- `Timestamp` data type now allows SDK to set timezone.
- Revised naming rules for schema, property, and alias to support special characters and Chinese.
- Insert, delete, update, and some query clauses now supports the `limit()` method and `OPTIONAL` prefix.
- Introduced new functions: `dateFormat()`, `toString()`, `range()`, `ifnull()`, `reduce()`.
- Introduced the `DEBUG` prefix for performance statistics with better granularity.
- Modified the `PROFILE` prefix functionality to display each clause's time cost.
- Enhanced the display content of `EXPLAIN` prefix.
- `WHERE` clause now supports aggregate functions.
- Modified mathematical operators and functions to handle null values.
- Fixed other bugs.

## v4.3.2 Release (2023-01-12)

- Introduced the `list` type to properties.
- Introduced sub types to properties.
- Introduced null values to properties.
- Introduced `IS NULL` and `IS NOT NULL` operators.

## v4.2.40 Release (2023-01-05)

- Refactored `EXPLAIN` prefix functionalities.
- Renamed functions to use CamelCase naming convention, including changing `date_add` to `dateAdd`, `date_diff` to `dateDiff`, `date_format` to `dateFormat`, `day_of_week` to `dayOfWeek`, `array_union` to `listUnion`, `starts_with` to `startsWith` and `ends_with` to `endsWith`.
- Resolved bugs in the `between` and `listUnion` functions.
- Introduced function `ifNull`.
- Resolved issues with empty edges being included in returned paths.
- Added an error message when `truncate().graph()` is applied to an incorrect graphset.

## beta.4.2.35 Release (2022-12-08)

- Optimized the Louvain algorithm.
- Introduced the Louvain Serial algorithm.
- Optimized the algorithm efficiency when `_id` is used as label in LPA.
- Improved the error message when the specified property to be LTE-ed does not exist.
- Fixed known bugs.

## beta.4.1.53 Release (2022-11-16)

- Resolved the crash issue in the K-Core and Subgraph algorithms.
- Resolved the return issue of the `alter()` clause where the specified property does not exist.
- Fixed known bugs.

## beta.4.1.45 Release (2022-10-24)

- Optimized the file writeback feature in algorithms.
- Resolved the issue where the `EXPALIN` prefix does not print aggregate functions.
- Resolved the issue where the tasks still in the writing status are stopped by the `clear().task()` clause.
- Fixed known bugs.

## beta.4.1.31 Release (2022-09-20)

- Optimized the Degree Centrality algorithm.
- Resolving the slow speed issue in the file writeback for the Similarity algorithm.
- Fixed known bugs.

## beta.4.1.27 Release (2022-09-02)

- Optimized the `PATH` structure.
- Refactored the `find()` clause.
- Fixed known bugs.

## beta.4.1.21 Release (2022-08-10)

- Optimized the `NODE` and `EDGE` structure.
- Resolved the issue where `_id` is empty in the return of `UNION` and `UNION ALL` clauses.
- Resolved the property writeback failure for the CELF algorithm.

## beta.4.1.8 Release (2022-07-19)

- Introduced the Dijkstra's Single-Source Shortest Path, Delta-Stepping Single-Source Shortest Path, and SPFA algorithms.
- Resolved the crash issue for the LINE algorithm.
- Fixed known bugs.

## beta.4.0.233 Release (2022-07-12)

- Updated the `no_circle()` parameter of the `ab()` clause.
- Introduced the Harmonic Centrality, Eigenvector Centrality and HITS algorithms.
- Fixed known bugs.

## beta.4.0.232 Release (2022-06-30)

- Resolved the crash issue in LPA.
- Optimized the `array_union` function.
- Fixed an issue that occurred when attempting to uninstall an algorithm that was still running.
- Fixed known bugs.

## beta.4.0.220 Release (2022-06-07)

- Resolved the issue where the count reported by `show().schema()` was incorrect after deleting edges.
- Resolved the crash issue in the GraphSAGE Train algorithm.

## beta.4.0.202 Release (2022-05-06)

- Resolved the wrong return issue when the first augment of the `coalesce` function is `null`.
- Resolved the issue where `PATH` is used in the `GROUP BY` clause.
- Fixed known bugs.

## beta.4.0.187 Release (2022-04-15)

- Resolved the issue when the `ORDER BY` clause is used with the `GROUP BY` clause.
- Resolved the crash issue in the Random Walk algorithm.
- Fixed known bugs.

## beta.4.0.164 Release (2022-03-14)

- Optimized the sampling feature for the Betweenness Centrality algorithm.
- Optimized the `limit()` parameter.
- Fixed known bugs.

## beta.4.0.152 Release (2022-02-09)

- Optimized multithreading concurrency in the cluster.
- Optimized the precision of the data returned by algorithms.
- Fixed known bugs.

## beta.4.0.145 Release (2022-01-11)

- Resolved the crash issue in the Triangle Counting algorithm.
- Optimized the stats return of the Louvain and LPA algorithms.
- Fixed known bugs.
