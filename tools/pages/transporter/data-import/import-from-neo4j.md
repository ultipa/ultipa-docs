# Import from Neo4j

This page walks through importing data from a Neo4j database into a graph using `gqldb-importer`. The importer connects to Neo4j over the Bolt protocol, runs one Cypher query per node/edge type, and streams the result records into the graph.

## Usage Guides

### Verify Connectivity

Make sure the Neo4j instance is reachable from the host where `gqldb-importer` will run, and that the account you'll use has read access on the database. The default Bolt port is `7687`.

### Generate Configuration File

```bash
./gqldb-importer -sample neo4j
```

A file named `import.sample.neo4j.yml` will be created in the current directory. Rename it before editing so a re-run of `-sample neo4j` doesn't clobber your changes:

```bash
mv import.sample.neo4j.yml import.neo4j.yml
```

### Modify Configuration File

Edit `import.neo4j.yml`. Neo4j-specific configuration lives under the top-level `neo4j:` block; see the <a target="_blank" href="/docs/tools/import-configurations">Import Configurations</a> for the rest of the file (`server`, `settings`).

<p tit="config snippet"></p>

```yml
neo4j:
  uri: "neo4j://localhost:7687"
  username: "neo4j"
  password: "password"
  database: "neo4j"

  nodes:
    - schema: "Person"
      query: "MATCH (n:Person) RETURN n.id AS _id, n.name AS name, n.age AS age"
      id_column: "_id"
      properties:
        age: int32

  edges:
    - schema: "KNOWS"
      query: "MATCH (a:Person)-[r:KNOWS]->(b:Person) RETURN a.id AS from_id, b.id AS to_id, r.since AS since"
      from_column: "from_id"
      to_column: "to_id"
      properties:
        since: int32
```

The `uri` accepts any scheme that the Bolt driver supports: `neo4j://`, `neo4j+s://` (TLS), `bolt://`, or `bolt+s://`. The `database` field defaults to `neo4j` on a fresh install — change it if you've created additional databases.

### Execute Import

```bash
./gqldb-importer -c import.neo4j.yml
```

## Writing the Cypher Queries

The importer treats each query as a flat record source. The aliases returned by `RETURN` are what `id_column`, `from_column`, `to_column`, and `properties` reference.

**Node query** — return one record per node, with one alias acting as the node `_id`:

<p tit="Cypher"></p>

```gql
// Maps directly to id_column: "_id", schema: "Person"
MATCH (n:Person)
RETURN n.id AS _id, n.name AS name, n.age AS age
```

**Edge query** — return one record per edge, with aliases for the source and destination `_id`s:

<p tit="Cypher"></p>

```gql
// Maps to from_column: "from_id", to_column: "to_id", schema: "KNOWS"
MATCH (a:Person)-[r:KNOWS]->(b:Person)
RETURN a.id AS from_id, b.id AS to_id, r.since AS since
```

A few practical tips:

- Always use `AS` to alias every returned value to a stable column name. The importer maps by alias, not by Cypher expression.
- Filter at the source with `WHERE` rather than pulling everything and discarding rows downstream.
- For very large graphs, split a single logical type across multiple entries (e.g., by label combination or property range) to parallelize the extraction.
- Use Neo4j's internal `id(n)` only as a last resort — internal IDs are not stable across database restarts. Prefer a user-defined property like `n.id` or `n.uuid`.
