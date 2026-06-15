# Ultipa Transporter

**Ultipa Transporter** is a cross-platform command-line tool suite for moving data in and out of a GQLDB graph. It runs on Linux, macOS, and Windows.

The suite consists of two tools:

- <a target="_blank" href="/docs/tools/importer">**gqldb-importer**</a>: Bulk-loads data from external sources into a GQLDB graph. Reads files, queries databases, or consumes streams; writes batched, multi-threaded inserts into the target graph.
- <a target="_blank" href="/docs/tools/exporter">**gqldb-exporter**</a>: Bulk-extracts a graph (or a labeled subset) into local files in CSV, JSON, JSONL, or GraphML format.

Both tools are configuration-driven: generate a sample YAML with `-sample`, edit it to point at your source and target, and run with `-c`.

## Supported Sources and Formats

The Importer reads from:

- <a target="_blank" href="/docs/tools/import-from-csv">CSV</a>, <a target="_blank" href="/docs/tools/import-from-json">JSON / JSONL</a>
- <a target="_blank" href="/docs/tools/import-from-sql">Relational databases</a>: MySQL, PostgreSQL, SQL Server, Oracle, Snowflake
- <a target="_blank" href="/docs/tools/import-from-neo4j">Neo4j</a>, <a target="_blank" href="/docs/tools/import-from-rdf">RDF</a>, <a target="_blank" href="/docs/tools/import-from-graphml">GraphML</a>
- <a target="_blank" href="/docs/tools/import-from-bigquery">BigQuery</a>, <a target="_blank" href="/docs/tools/import-from-hive">Hive</a>, <a target="_blank" href="/docs/tools/import-from-kafka">Kafka</a>, <a target="_blank" href="/docs/tools/import-from-salesforce">Salesforce</a>

The Exporter writes to:

- <a target="_blank" href="/docs/tools/export-to-csv">CSV</a>, <a target="_blank" href="/docs/tools/export-to-json">JSON / JSONL</a>, <a target="_blank" href="/docs/tools/export-to-graphml">GraphML</a>

A CSV directory produced by the Exporter is round-trippable: the typed-header output can be re-imported with the Importer's default `head: true` mode without writing a property configuration.

## Prerequisites

- A terminal: Bash, Zsh, or TCSH on Linux / macOS; PowerShell on Windows.
- Network connectivity from the host running the tool to the GQLDB cluster.
- The GQLDB account used by the tool must have appropriate permissions on the target graph (write for the Importer, read for the Exporter).

Download Ultipa Transporter from <a target="_blank" href="/download">here</a>. No installation is required.

## Full Configuration References

- <a target="_blank" href="/docs/tools/import-configurations">Import Configurations</a>
- <a target="_blank" href="/docs/tools/export-configurations">Export Configurations</a>
