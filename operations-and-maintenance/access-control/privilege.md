# Privilege

## Overview

Privileges are a fundamental access control mechanism that define the operations a user is authorized to perform within a database. They play a critical role in enforcing security by restricting access to specific actions, such as querying data, modifying records, or administering the system. Privileges can be granted to roles (or policies), or assigned directly to individual users.

Ultipa defines privileges at three levels—**System**, **Graph**, and **Property**—to support fine-grained access control.

## Showing Privileges

To list all defined graph and system privileges:

```uql
show().privilege()
```

This will return a table `_privilege`, as shown below:

| graphPrivileges | systemPrivileges |
| -- | -- |
| ["READ","INSERT","UPSERT","UPDATE","DELETE","CREATE_SCHEMA","DROP_SCHEMA","ALTER_SCHEMA","SHOW_SCHEMA","RELOAD_SCHEMA","CREATE_PROPERTY","DROP_PROPERTY","ALTER_PROPERTY","SHOW_PROPERTY","CREATE_FULLTEXT","DROP_FULLTEXT","SHOW_FULLTEXT","CREATE_INDEX","DROP_INDEX","SHOW_INDEX","LTE","UFE","CLEAR_JOB","STOP_JOB","SHOW_JOB","ALGO","CREATE_PROJECT","SHOW_PROJECT","DROP_PROJECT","CREATE_HDC_GRAPH","SHOW_HDC_GRAPH","DROP_HDC_GRAPH","COMPACT_HDC_GRAPH","SHOW_VECTOR_INDEX","CREATE_VECTOR_INDEX","DROP_VECTOR_INDEX","SHOW_CONSTRAINT","CREATE_CONSTRAINT","DROP_CONSTRAINT"] | ["TRUNCATE","COMPACT","CREATE_GRAPH","SHOW_GRAPH","DROP_GRAPH","ALTER_GRAPH","TOP","KILL","STAT","SHOW_POLICY","CREATE_POLICY","DROP_POLICY","ALTER_POLICY","SHOW_USER","CREATE_USER","DROP_USER","ALTER_USER","SHOW_PRIVILEGE","SHOW_META","SHOW_SHARD","ADD_SHARD","DELETE_SHARD","REPLACE_SHARD","SHOW_HDC_SERVER","ADD_HDC_SERVER","DELETE_HDC_SERVER","LICENSE_UPDATE","LICENSE_DUMP","GRANT","REVOKE","SHOW_BACKUP","CREATE_BACKUP","SHOW_VECTOR_SERVER","ADD_VECTOR_SERVER","DELETE_VECTOR_SERVER"] |

## System Privileges

System privileges encompass operations for managing various aspects of the database, including graphs, processes, privileges, policies, users, servers, and more.

Ultipa supports the following system privileges:

| <div table-width="30">Privilege</div> | Description |
| -- | -- |
| `TRUNCATE` | Truncates graphs in database. |
| `COMPACT` | Compacts graphs in database. |
| `CREATE_GRAPH` | Creates graphs in database. |
| `SHOW_GRAPH` | Shows graphs in database. |
| `DROP_GRAPH` | Drops graphs in database. |
| `ALTER_GRAPH` | Alters graphs in database. |
| `TOP` | Shows processes in database. |
| `KILL` | Kills processes in database. |
| `STAT` | Shows database statistics. |
| `SHOW_POLICY` | Shows roles (policies) in database. |
| `CREATE_POLICY` | Creates roles (policies) in database. |
| `DROP_POLICY` | Drops roles (policies) in database. |
| `ALTER_POLICY` | Alters roles (policies) in database. |
| `SHOW_USER` | Shows users in database. |
| `CREATE_USER` | Creates users in database. |
| `DROP_USER` | Drops users in database. |
| `ALTER_USER` | Alters users in database. |
| `SHOW_PRIVILEGE` | Shows privileges in database. |
| `GRANT` | Grants privileges and roles (policies). |
| `REVOKE` | Revokes privileges and roles (policies). |
| `SHOW_META` | Show meta servers of the database. |
| `SHOW_SHARD` | Show shard servers of the database. |
| `ADD_SHARD` | Adds shard servers to the database. |
| `REPLACE_SHARD` | Alters the replica addresses of a shard server. |
| `DELETE_SHARD` | Deletes shard servers from the database. |
| `SHOW_HDC_SERVER` | Show HDC servers of the database. |
| `ADD_HDC_SERVER` | Adds HDC servers to the database. |
| `DELETE_HDC_SERVER` | Deletes HDC servers from the database. |
| `SHOW_VECTOR_SERVER` | Show vector servers of the database. |
| `ADD_VECTOR_SERVER` | Adds vector servers to the database. |
| `DELETE_VECTOR_SERVER` | Deletes vector servers from the database. |
| `LICENSE_UPDATE` | Updates license of the database. |
| `LICENSE_DUMP` | Dumps license of the database. |
| `SHOW_BACKUP` | Shows backups of the database. |
| `CREATE_BACKUP` | Creates backups for the database. |
| `PITR_RESTORE` | Restores the database to a point in time. |
| `CREATE_PROCEDURE` | Creates stored procedures in graphs. |
| `DROP_PROCEDURE` | Drops stored procedures in graphs. |
| `SHOW_PROCEDURE` | Shows stored procedures in graphs. |
| `CALL_PROCEDURE` | Calls stored procedures in graphs. |

## Graph Privileges

Graph privileges govern operations related to accessing and modifying the data and structure of specific graphs. They also include permissions for managing associated elements such as indexes, jobs, and HDC graphs.

Ultipa supports the following graph privileges:

| <div table-width="28">Privilege</div> | Description |
| -- | -- |
| `READ` | Reads data from graphs. |
| `INSERT` | Inserts nodes and edges into graphs. |
| `UPSERT` | Updates or inserts nodes and edges in graphs. |
| `UPDATE` | Updates nodes and edges in graphs. |
| `DELETE` | Deletes nodes and edges in graphs. |
| `CREATE_SCHEMA` | Creates schemas in graphs. |
| `DROP_SCHEMA` | Drops schemas in graphs. |
| `ALTER_SCHEMA` | Alters schemas in graphs. |
| `SHOW_SCHEMA` | Shows schemas in graphs. |
| `RELOAD_SCHEMA` | Reloads the total number of nodes and edges in graphs. |
| `CREATE_PROPERTY` | Creates properties in graphs. |
| `DROP_PROPERTY` | Drops properties in graphs. |
| `ALTER_PROPERTY` | Alters properties in graphs. |
| `SHOW_PROPERTY` | Shows properties in graphs. |
| `CREATE_FULLTEXT` | Creates full-text indexes in graphs. |
| `DROP_FULLTEXT` | Drop full-text indexes in graphs. |
| `SHOW_FULLTEXT` | Shows full-text indexes in graphs. |
| `CREATE_VECTOR_INDEX` | Creates vector indexes in graphs. |
| `DROP_VECTOR_INDEX` | Drop vector indexes in graphs. |
| `SHOW_VECTOR_INDEX` | Shows vector indexes in graphs. |
| `CREATE_INDEX` | Creates indexes in graphs. |
| `DROP_INDEX` | Drops indexes in graphs. |
| `SHOW_INDEX` | Shows indexes in graphs. |
| `LTE` | Loads properties from disk into the computing engine. |
| `UFE` | Unloads properties from the computing engine. |
| `CLEAR_JOB` | Clear jobs in graphs. |
| `STOP_JOB` | Stops jobs in graphs. |
| `SHOW_JOB` | Shows jobs in graphs. |
| `ALGO` | Runs algorithms for graphs. |
| `CREATE_PROJECT` | Creates distributed projections for graphs. |
| `SHOW_PROJECT` | Shows distributed projections of graphs. |
| `DROP_PROJECT` | Drops distributed projections of graphs. |
| `CREATE_HDC_GRAPH` | Creates HDC graphs. |
| `SHOW_HDC_GRAPH` | Shows HDC graphs. |
| `DROP_HDC_GRAPH` | Drops HDC graphs. |
| `COMPACT_HDC_GRAPH` | Compacts HDC graphs. |

## Property Privileges

Property privileges provide more granular control over read and write permissions to specific properties within graphs. If no property privileges are explicitly defined, all properties are granted read and write permissions by default.

Ultipa supports the following property privileges:

| <div table-width="13">Privilege</div> | Description |
| -- | -- |
| `READ` | Grants permission to read certain properties in graphs. |
| `WRITE` |	Grants permission to read and write certain properties in graphs. |
| `DENY` | Explicitly denies read and write access to certain properties. If both `DENY` and `READ` (or `WRITE`) are assigned to a property, `DENY` takes precedence. |

If the `READ` privilege for the `name` property of the `user` nodes is not granted:

| <div table-width="23">Operation</div> | Examples |
| -- | -- |
| Return the property | `MATCH (n:user) RETURN n`<br>This GQL query excludes the `name` property from the returned node information.<br><br>`MATCH (n:user) RETURN n.name`<br>This GQL query throws an error as you cannot read the `name` property. |
| Filter the property | `MATCH (n:user {name: "johndoe"}) RETURN n`<br>This GQL query throws an error as you cannot read the `name` property. |
| Export | You cannot export the properties which you cannot read. |

If the `WRITE` privilege for the `name` property of the `user` nodes is not granted:

| <div table-width="12">Operation</div> | Examples |
| -- | -- |
| Insert | `INSERT (:user {_id: "U873", name:"johndoe"})`<br>This GQL query throws an error as you cannot write the `name` property. |
| Update | `MATCH (n:user {_id: "U873"}) SET n.name = "johndoe"`<br>This GQL query throws an error as you cannot write the `name` property. |
| Delete | You can still delete properties from the graph structure even if you don't have corresponding `WRITE` property privilege, but it requires the `DROP_PROPERTY` graph privilege.  |
