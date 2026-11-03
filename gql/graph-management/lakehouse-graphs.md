# Lakehouse Graphs

## Overview

A **lakehouse graph** lets you query existing Parquet files as a graph without importing their rows into native GQLDB storage. A mapping file identifies the node ids, edge endpoints, labels, and properties. Source data stays in the lake; GQLDB builds identifiers, caches, and compute topology for queries.

**Recommended version:** GQLDB **6.2.157 or later**. The examples and behavior in this guide were verified with 6.2.157.

This guide takes you from two small Parquet files to a graph you can query, visualize, and refresh. For all mapping options, supported queries, automatic refresh, permissions, and operational limits, see <a href="/docs/gql/lakehouse-reference">Lakehouse Reference</a>.

## Prerequisites

- GQLDB installed on the machine that will read the files. See <a href="/docs/quick-start/install-and-connect">Install & Connect</a>.
- Python 3 with PyArrow, used only to create the example files.
- GQLDB Manager or the CLI to run the GQL statements.
- An operator who can configure the directories GQLDB may read. With RBAC enabled, declaration requires `CREATE_GRAPH` and database-level `DECLARE_LAKE_GRAPH`; queries require `READ`, compute management requires `MANAGE_COMPUTE`, and manual refresh requires database-level `ALTER_GRAPH`. The example uses the administrator account.

Lake graphs are **read-only**. To change their data, publish new source partitions and refresh. Native writable graphs can coexist in the same database.

## 1. Create Example Files

Create a working directory named `lakehouse-demo` and open a terminal there. Create a Python environment and install PyArrow:

**macOS / Linux:**

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install pyarrow
```

**Windows PowerShell:**

```powershell
py -m venv .venv
.venv\Scripts\python.exe -m pip install pyarrow
```

Save this as `make_lake_demo.py` in your working directory:

```python
import json
from pathlib import Path
import pyarrow as pa
import pyarrow.parquet as pq

lake = Path("lake").resolve()
(lake / "people").mkdir(parents=True, exist_ok=True)
(lake / "knows").mkdir(parents=True, exist_ok=True)

pq.write_table(pa.table({
    "person_id": ["a", "b", "c"],
    "name": ["Alice", "Bob", "Charlie"],
    "city": ["London", "Berlin", "Paris"],
}), lake / "people" / "p1.parquet")

pq.write_table(pa.table({
    "src": ["a", "b"], "dst": ["b", "c"], "amount": [10, 20],
}), lake / "knows" / "p1.parquet")

mapping = {
    "root": ".",
    "dangling": "skip",
    "nodes": [{
        "files": "people/*.parquet", "id_column": "person_id",
        "label": "Person", "properties": ["name", "city"],
    }],
    "edges": [{
        "files": "knows/*.parquet", "from_column": "src",
        "to_column": "dst", "label": "KNOWS", "properties": ["amount"],
    }],
}
(lake / "social.json").write_text(json.dumps(mapping, indent=2))
print("Mapping path:", (lake / "social.json").as_posix())
```

Run `python make_lake_demo.py` in the activated environment. On Windows, run `.venv\Scripts\python.exe make_lake_demo.py`. Keep the printed absolute mapping path for step 3.

This creates three people and two relationships: Alice → Bob → Charlie. Run the setup script once in a fresh directory; do not overwrite loaded partitions while the graph is open.

## 2. Start GQLDB with Access to the Files

From the same working directory, start a separate database for this example:

```bash
ultipa-gqldb -db ./demo.gdb -port 60061 -rbac -admin-pass myPassword -lake-allowed-roots ./lake
```

Keep this terminal running. If port `60061` is already in use, choose another port and use it in your client connection too.

`-lake-allowed-roots` permits the server to read the mapping and data under `lake`. Without an allowed root, lake declarations are refused. The paths refer to the **server's filesystem**; if GQLDB runs remotely or in a container, place or mount the files there.

Open Manager, connect to this server as `admin` with the password you chose, and open its query editor. For a local database, use desktop Manager with host `localhost` and port `60061`. See <a href="/docs/tools/manager">GQLDB Manager</a> for connection instructions.

## 3. Declare and Inspect the Graph

Replace the path below with the absolute mapping path printed by the Python script. On Windows, use forward slashes in the GQL string, such as `C:/lakehouse-demo/lake/social.json`.

```gql
CREATE GRAPH social WITH LAKE MAPPING '/absolute/path/lakehouse-demo/lake/social.json'
USE GRAPH social
MATCH (n:Person) RETURN count(n)
```

The count is `3`. Inspect the graph and its labels:

```gql
SHOW GRAPHS
SHOW NODE LABELS
SHOW EDGE LABELS
```

The `social` graph has three nodes and two edges. The mapping persists with the database; declaring it again after a restart is unnecessary.

## 4. Enable Compute and Query Paths

Enable compute and inspect its state:

```gql
ALTER GRAPH social SET COMPUTE ENABLED
SHOW COMPUTE STATUS ON GRAPH social
```

The topology builds in the background. Repeat the status statement until it reports `READY`, then run:

```gql
MATCH p = (a:Person {_id: 'a'})-[:KNOWS]->{1,2}(b:Person)
RETURN p
```

The query returns the paths Alice → Bob and Alice → Bob → Charlie. In Manager, open the result's **graph view** to visualize the relationships.

Return properties instead when you want a table:

```gql
MATCH (a:Person {_id: 'a'})-[e:KNOWS]->(b:Person)
RETURN a.name, b.name, e.amount
```

This returns Alice, Bob, and `10`. Simple scans and counts can run without compute; neighborhood traversal and algorithms need a ready topology. Some query variants are restricted; see the <a href="/docs/gql/lakehouse-reference#Query-Support">query support matrix</a>.

## 5. Add a Partition and Refresh

Save this as `add_partition.py` beside the first script:

```python
from pathlib import Path
import pyarrow as pa
import pyarrow.parquet as pq

lake = Path("lake")
pq.write_table(pa.table({
    "person_id": ["d"], "name": ["Diana"], "city": ["London"],
}), lake / "people" / "p2.parquet")
pq.write_table(pa.table({
    "src": ["c"], "dst": ["d"], "amount": [30],
}), lake / "knows" / "p2.parquet")
```

Run `python add_partition.py` in the same environment, or `.venv\Scripts\python.exe add_partition.py` on Windows. Then refresh from the query editor:

```gql
RETURN DB.REFRESH_LAKE_GRAPH('social') AS r
```

The result reports `status: success`, `newNodes: 1`, and `newEdges: 1`. With a ready compute topology, check `computeApplied` and `rebuildRequired` before relying on traversal of new rows.

```gql
MATCH (n:Person) RETURN count(n)
MATCH p = (a:Person {_id: 'a'})-[:KNOWS]->{1,3}(b:Person)
RETURN p
```

The count is now `4`, and the returned paths reach Diana. No server restart is required. Use new filenames for new partitions; loaded partitions are expected to remain immutable.

## Recovery

An inaccessible recorded source is listed as `UNAVAILABLE`; other graphs remain usable. Correct access and retry with `DB.REFRESH_LAKE_GRAPH`. After a server restart, an enabled lake graph may need `ALTER GRAPH social SET COMPUTE REBUILD` before traversal. See <a href="/docs/gql/lakehouse-reference#Catalog-and-Restart-Behavior">restart behavior</a> and <a href="/docs/gql/lakehouse-reference#Recovery">recovery procedures</a>.

## Backup and Restore

Database backups preserve lake declarations, not the external mapping files or Parquet data. Preserve those separately. See <a href="/docs/gql/lakehouse-reference#Backup-and-Restore">backup and restore details</a> before moving a database to another host.

## Licensing and Version Compatibility

Lake graphs do not consume license graph slots or node/edge quotas; native graphs keep their normal limits. For edition terms and rollback compatibility warnings, see <a href="/docs/gql/lakehouse-reference#Licensing-and-Compatibility">licensing and compatibility</a>.

## Next Steps

- <a href="/docs/gql/lakehouse-reference#Mapping-File">Mapping options</a>: multiple sources, per-row labels, properties, and dangling-edge policies.
- <a href="/docs/gql/lakehouse-reference#Automatic-Refresh">Automatic refresh</a>: take on arriving partitions on a schedule.
- <a href="/docs/gql/lakehouse-reference#Recovery">Recovery</a>: unavailable sources, refresh warnings, and restore behavior.
- <a href="/docs/gql/lakehouse-reference#Backup-and-Restore">Backup and restore</a>: preserve declarations and external files.

For a declaration failure, first check allowed roots and permissions. For an early traversal refusal, check compute readiness. The reference includes a <a href="/docs/gql/lakehouse-reference#Troubleshooting">troubleshooting table</a>.
