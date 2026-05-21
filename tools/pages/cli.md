# Ultipa CLI

## Overview

`gqldb-cli` is the official command-line client for connecting to a GQLDB server. It supports three execution modes:

- **Interactive shell:** Launches an interactive shell when no statement source is provided.
- **Single statement:** Executes one statement with `-e` and exits.
- **Script file:** Executes statements from a `.gql` file with `-f` and exits.

## Usages

Start a session against a local database server:

```bash
gqldb-cli -h localhost:60061 -u <username> -p <password> -g <graphName>
```

The command launches an **interactive shell** where you can type GQL statements one at a time and see results immediately. Exit with `\q`, `exit`, or Ctrl+D.

To change the result format in the interactive shell, pass `--format` at launch — it applies to every statement run during the session. There is no in-shell command to switch formats mid-session; exit and relaunch to use a different format.

```bash
gqldb-cli -h localhost:60061 -u <username> -p <password> -g <graphName> --format json
```

You can pass `-o` to write all result outputs to a file, so you won't see results in the terminal as you type:

```bash
gqldb-cli -h localhost:60061 -u <username> -p <password> -g <graphName> -o session.log
```

`--format` and `-o` can be combined, so every statement's result is written to the file in the chosen format:

```bash
gqldb-cli -h localhost:60061 -u <username> -p <password> -g <graphName> --format json -o session.json
```

With `-e`, the CLI does not enter the interactive shell — it connects, runs the single statement, prints the result, and exits:

```bash
gqldb-cli -h localhost:60061 -u <username> -p <password> -g <graphName> --format json \
  -e "MATCH (n) RETURN n LIMIT 5"
```

With `-f`, the CLI does not enter the interactive shell either — it connects, runs every statement in a file in order, prints the results, and exits:

```bash
gqldb-cli -h localhost:60061 -u <username> -p <password> -g <graphName> --format json \
  --format csv -o results.csv \
  -f inspect_users.gql
```

Example `inspect_users.gql` file:

<p tit="inspect_users.gql"></p>

```gql
MATCH (u:User) RETURN count(u) AS totalUsers;
MATCH (u:User) RETURN u.id, u.name, u.email ORDER BY u.name LIMIT 20;
MATCH (u:User) WHERE u.email IS NULL RETURN u.id, u.name;
```

Statements are separated by `;`. Results from all three queries are appended to `results.csv` in order.

Connect to a multi-node cluster over TLS:

```bash
gqldb-cli --ssl --ca ca.pem --cert client.pem --key client.key \
  -h node1:60061,node2:60061,node3:60061 \
  -u root -p
```

## Options

### Connection

| Flag | Description |
| --- | --- |
| `-h`, `--host` | Server `host:port`, comma-separated for multiple endpoints. Default: `localhost:60061`. |
| `-u`, `--username` | Username for authentication. |
| `-p`, `--password` | Password for authentication. |
| `-g`, `--graph` | Default graph name. Default: `default`. |
| `--timeout` | Query timeout in seconds. Default: `30`. |

### TLS/SSL

| Flag | Description |
| --- | --- |
| `--ssl` | Enable TLS connection. |
| `--cert` | Path of client certificate file (PEM). |
| `--key` | Path of client private key file (PEM). |
| `--ca` | Path of CA certificate file (PEM). |

### Execution

| Flag | Description |
| --- | --- |
| `-e`, `--execute STRING` | Execute a single statement and exit. |
| `-f`, `--file FILE` | Execute statements from a file and exit. |

### Output

| Flag | Description |
| --- | --- |
| `--format` | Output format: `table` (default), `json`, `csv`, or `tsv`. |
| `-o`, `--output` | Write output to a file instead of stdout. |

### General

| Flag | Description |
| --- | --- |
| `-V`, `--version` | Show version and exit. |
| `--verbose` | Print connection diagnostics (target host, graph, TLS state, authenticated user) before the result. |