# Importer

## Overview

`gqldb-importer` is the bulk-import tool of the Ultipa Transporter suite. It reads from external sources and writes nodes and edges into a GQLDB graph in batched, multi-threaded fashion.

## Supported Sources

- <a target="_blank" href="/docs/tools/import-from-csv">CSV</a>
- <a target="_blank" href="/docs/tools/import-from-json">JSON / JSONL</a>
- <a target="_blank" href="/docs/tools/import-from-sql">Relational databases</a> (MySQL, PostgreSQL, SQL Server, Oracle, Snowflake)
- <a target="_blank" href="/docs/tools/import-from-neo4j">Neo4j</a>
- <a target="_blank" href="/docs/tools/import-from-bigquery">BigQuery</a>
- <a target="_blank" href="/docs/tools/import-from-kafka">Kafka</a>
- <a target="_blank" href="/docs/tools/import-from-hive">Hive</a>
- <a target="_blank" href="/docs/tools/import-from-salesforce">Salesforce</a>
- <a target="_blank" href="/docs/tools/import-from-rdf">RDF</a>
- <a target="_blank" href="/docs/tools/import-from-graphml">GraphML</a>

## Workflow

`gqldb-importer` is configuration-driven. The typical workflow is:

1. Generate a sample configuration for the source type.
2. Edit the configuration to point at your source data and the target server.
3. Run the import.

```bash
# 1. Generate a sample configuration (writes ./import.sample.<type>.yml)
./gqldb-importer -sample csv

# 2. Rename / edit it
mv import.sample.csv.yml my-import.yml

# 3. Run the import
./gqldb-importer -c my-import.yml
```

Use `-sample all` to generate sample configurations for every supported source at once.

See <a target="_blank" href="/docs/tools/import-configurations">Import Configurations</a> for the full configuration reference.

## Flags

| Flag | Description |
| --- | --- |
| `-c`, `-config` | Path to the configuration file. Default: `config.yml`. |
| `-sample` | Generate a sample configuration file for a source type (`csv`, `json`, `jsonl`, `sql`, `neo4j`, `bigQuery`, `kafka`, `hive`, `salesforce`, `rdf`, `graphml`, or `all`) and exit. |
| `-connect` | Test the server connection only; do not import. |
| `-preview` | Read and display the first N rows of each source without importing. |
| `-abort-session` | Abort an existing bulk-import session before starting a new one. |
| `-host` | Override `server.host` from the config. |
| `-username` | Override `server.username` from the config. |
| `-password` | Override `server.password` from the config. |
| `-graph` | Override `server.graph` from the config. |
| `-level` | Override the log level: `debug`, `info`, `warn`, `error`. |
| `-v`, `-verbose` | Enable verbose output. |
