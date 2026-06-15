# Exporter

## Overview

`gqldb-exporter` is the bulk-export tool of the Ultipa Transporter suite. It reads nodes and edges from a GQLDB graph and writes them to local files in a chosen format.

## Supported Formats

- <a target="_blank" href="/docs/tools/export-to-csv">CSV</a>
- <a target="_blank" href="/docs/tools/export-to-json">JSON / JSONL</a>
- <a target="_blank" href="/docs/tools/export-to-graphml">GraphML</a>

## Workflow

`gqldb-exporter` is configuration-driven. The typical workflow is:

1. Generate a sample configuration for the output format.
2. Edit the configuration to point at the source graph and the output directory.
3. Run the export.

```bash
# 1. Generate a sample configuration (writes ./export.sample.<format>.yml)
./gqldb-exporter -sample csv

# 2. Rename / edit it
mv export.sample.csv.yml my-export.yml

# 3. Run the export
./gqldb-exporter -c my-export.yml
```

Use `-sample all` to generate sample configurations for every supported format at once.

See <a target="_blank" href="/docs/tools/export-configurations">Export Configurations</a> for the full configuration reference.

## Flags

| Flag | Description |
| --- | --- |
| `-c`, `-config` | Path to the configuration file. Default: `config.yml`. |
| `-sample` | Generate a sample configuration file for an output format (`csv`, `json`, `jsonl`, `graphml`, or `all`) and exit. |
| `-connect` | Test the server connection only; do not export. |
| `-host` | Override `server.host` from the config. |
| `-username` | Override `server.username` from the config. |
| `-password` | Override `server.password` from the config. |
| `-graph` | Override `server.graphset` from the config. |
| `-level` | Override the log level: `debug`, `info`, `warn`, `error`. |
| `-v`, `-verbose` | Enable verbose output. |
