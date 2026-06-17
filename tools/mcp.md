# Ultipa MCP

## Overview

Ultipa MCP is a <a target="_blank" href="https://modelcontextprotocol.io">Model Context Protocol</a> server that exposes Ultipa Cloud and self-managed GQLDB instances as tools for MCP-compatible AI clients (Claude, Cursor, Windsurf, VS Code, Cline, etc.). It lets the agent provision and operate instances, run GQL queries, manage backups, view metrics, and more — all through natural language.

The server runs locally as a stdio process launched by the MCP client. Each entry in the client's MCP config points at one Ultipa target.

## Auth

Each Ultipa MCP server entry uses one of two auth paths:

| Path | Use it if | Env vars |
| --- | --- | --- |
| **Ultipa Cloud** | You manage instances via <a target="_blank" href="https://dbaas.ultipa.com">Ultipa Cloud</a> | `ULTIPA_CLOUD_API_KEY` (create at **Ultipa Cloud → Settings → API Keys**) |
| **Direct instance** | You have admin credentials to a GQLDB instance | `ULTIPA_HOST` + `ULTIPA_USERNAME` + `ULTIPA_PASSWORD`, optional `ULTIPA_GRAPH` |

To target both, or multiple direct instances, add more entries — see [Multiple Targets](#Multiple-Targets).

The Ultipa Cloud API key needs scopes matching the tools you'll use:

| Permission | What it unlocks |
| --- | --- |
| `instances:read` | All read tools (list, get, metrics, …). |
| `instances:write` | State changes (create, pause, restart, upgrade, set log level, schedule backups, …). |
| `instances:delete` | `delete_instance`, `delete_backup`. |
| `instances:credentials` | `get_instance_credentials`. Also required by the data-plane tools under Ultipa Cloud account mode, because they fetch credentials per call. |
| `billing:read` | The billing tools (all read-only). |

## Install

How you add Ultipa MCP depends on your client:

- **Claude Desktop** → [one-click extension](#Claude-Desktop-One-click-Extension) (easiest), or [manual config](#Manual-config-any-stdio-client)
- **Cursor, Windsurf, VS Code, other stdio clients** → [manual config](#Manual-Config)

Every path needs one Ultipa target: either an **Ultipa Cloud** API key or a **Direct instance** (host + username + password). See [Auth](#Auth).

### Claude Desktop (One-click Extension)

1. Download `ultipa-mcp.mcpb` from <a target="_blank" href="https://www.ultipa.com/download">Download Center</a>.
2. Open the file, or drag it into **Settings → Extensions** in Claude Desktop. The bundle ships its own server runtime, so no Node or npm install is required.
3. When prompted, enter **either** your Ultipa Cloud API key **or** the direct-instance host / username / password (leave the other fields blank), then enable the extension.

To update, install a newer `.mcpb`; to remove, delete it from **Settings → Extensions**.

> Team / Enterprise admins can upload the `.mcpb` in organization settings to make it a one-click install for the whole org.

### Manual Config

Add an entry under `mcpServers` in your MCP client's config. The same JSON shape works in any stdio MCP client; only the file path differs:

- **Claude Desktop:** `claude_desktop_config.json` via Settings → Developer → Edit Config
- **Cursor:** `~/.cursor/mcp.json`
- **Windsurf:** `~/.codeium/windsurf/mcp_config.json`
- **VS Code MCP extensions:** see the extension's docs.

With an Ultipa Cloud API key:

```json
{
  "mcpServers": {
    "ultipa-cloud": {
      "command": "npx",
      "args": ["-y", "ultipa-mcp"],
      "env": {
        "ULTIPA_CLOUD_API_KEY": "uc_..."
      }
    }
  }
}
```

For a direct instance:

```json
{
  "mcpServers": {
    "ultipa-direct": {
      "command": "npx",
      "args": ["-y", "ultipa-mcp"],
      "env": {
        "ULTIPA_HOST": "<host>:<port>",
        "ULTIPA_USERNAME": "admin",
        "ULTIPA_PASSWORD": "<password>",
        "ULTIPA_GRAPH": "default"
      }
    }
  }
}
```

Restart your client after editing.

### Multiple Targets

Each MCP server entry points at one Ultipa target. Add as many entries as you need, with descriptive names. The agent sees each entry as its own toolset and picks based on what you ask (e.g. "query staging" routes to the `ultipa-staging` entry).

```json
{
  "mcpServers": {
    "ultipa-cloud": {
      "command": "npx",
      "args": ["-y", "ultipa-mcp"],
      "env": {
        "ULTIPA_CLOUD_API_KEY": "uc_..."
      }
    },
    "ultipa-staging": {
      "command": "npx",
      "args": ["-y", "ultipa-mcp"],
      "env": {
        "ULTIPA_HOST": "staging.internal:60061",
        "ULTIPA_USERNAME": "admin",
        "ULTIPA_PASSWORD": "..."
      }
    },
    "ultipa-prod": {
      "command": "npx",
      "args": ["-y", "ultipa-mcp"],
      "env": {
        "ULTIPA_HOST": "prod.internal:60061",
        "ULTIPA_USERNAME": "admin",
        "ULTIPA_PASSWORD": "..."
      }
    }
  }
}
```

## Examples

Once the server is connected, talk to the agent in natural language, it picks the right tool (and target entry, if you have multiple) from the request. Examples:

**Provisioning and lifecycle:**

- "Spin up a new free-trial instance in Virginia, smallest size, name it `sandbox`."
- "What sizes are available in Frankfurt and how much do they cost per hour?"
- "Pause every instance whose name starts with `dev-`."
- "Upgrade `sandbox` to the latest GQLDB version."
- "Delete the instance `old-demo`."

**Operations and observability:**

- "Show CPU and memory for `prod-cluster` over the last 6 hours."
- "Tail the last 200 lines of logs from `prod-cluster` and tell me if anything looks wrong."
- "Set `prod-cluster` to `debug` log level for now."
- "What's my public IP, and add it to the firewall on `staging`?"

**Backups:**

- "Create an on-demand backup of `prod-cluster` and wait for it to finish."
- "Schedule daily backups for `prod-cluster` at 02:00 UTC daily."
- "Restore `staging` from the most recent backup of `prod-cluster`."

**Data plane (GQL, schema, import):**

- "Connect to `ultipa-staging` and list all graphs."
- "On the `social` graph, describe the schema and tell me which node types are missing indexes."
- "Run `MATCH (u:User)-[:FOLLOWS]->(v:User) RETURN count(*)` on the `social` graph."
- "Explain this query before running it: `MATCH (n:User {city: 'Tokyo'}) RETURN n LIMIT 100`."
- "Import the nodes in `/Users/me/data/users.csv` into the `social` graph as `User` nodes."
- "Run PageRank on the `social` graph over the `FOLLOWS` edges and return the top 20."
- "Who are the most influential users in the graph? List top 10."

**Account and billing:**

- "What's my current Ultipa Cloud balance and this month's usage?"
- "Show my balance transactions from the last 30 days."

**Docs:**

- "Look up the Ultipa docs on graph algorithms and summarize what's available for community detection."

## Tools

### Control Plane

Requires Ultipa Cloud (`ULTIPA_CLOUD_API_KEY`).

#### Account

| Tool | What it does |
| --- | --- |
| `get_account` | Authenticated account profile (email, name, balance flags). |

#### Instance Lifecycle

| Tool | What it does |
| --- | --- |
| `list_instances` | List all instances on the account. |
| `get_instance` | Fetch one instance by ID. |
| `list_deleted_instances` | List deleted instances (not returned by `list_instances`). |
| `create_instance` | Provision a new instance (name, region, sizeId). |
| `rename_instance` | Change an instance's display name. |
| `pause_instance` | Pause a running instance. |
| `resume_instance` | Resume a paused instance. |
| `restart_instance` | Restart the instance. |
| `upgrade_version` | Upgrade to the latest GQLDB version. |
| `delete_instance` | Delete an instance. Requires the instance name as confirmation. |
| `get_instance_credentials` | Fetch admin username and password of the instance. |
| `reset_admin_password` | Rotate the admin DB password. Breaks existing connections. |
| `list_regions` | List supported regions and their Manager URLs. |
| `list_instance_sizes` | List available sizes and pricing. |
| `get_latest_version` | Latest available GQLDB version. |
| `get_trial_status` | Free-trial eligibility. Pre-check before creating a free-trial instance. |
| `get_enterprise_status` | Enterprise-tier eligibility. Pre-check before creating an enterprise instance. |
| `get_operations_lock` | Whether instance ops are globally locked (maintenance / freeze). |
| `wait_for_instance_status` | Explicit polling helper. Rarely needed. |

#### Metrics, Logs, and Alerts

| Tool | What it does |
| --- | --- |
| `get_live_metrics` | Current CPU / memory / disk / network snapshot. |
| `get_metrics_history` | Historical metrics over the last N minutes (default 60, max 14 days). |
| `get_instance_logs` | Recent container logs (default 100 lines, max 1000). |
| `set_log_level` | Set GQLDB log level (debug / info / warn / error). |
| `list_alerts` | All alerts across the account's instances. |
| `list_instance_alerts` | Alerts for a single instance. |

#### Firewall

| Tool | What it does |
| --- | --- |
| `get_my_ip` | Public IP of the machine running Ultipa MCP (pair with `add_firewall_rule` to allow `${ip}/32`). |
| `list_firewall_rules` | IP-allowlist rules for an instance. |
| `add_firewall_rule` | Add a CIDR to the allowlist. |
| `remove_firewall_rule` | Remove a rule by its CIDR. |

#### Backups

| Tool | What it does |
| --- | --- |
| `list_backups` | List backups for an instance. |
| `create_backup` | Trigger an on-demand backup (default 10-minute timeout). |
| `restore_backup` | Restore from a completed backup. **Destructive: overwrites current data.** |
| `delete_backup` | Permanently delete a backup snapshot. |
| `set_backup_schedule` | Set or update an automated backup schedule. |
| `clear_backup_schedule` | Remove the schedule (existing backups kept). |

#### Billing

| Tool | What it does |
| --- | --- |
| `get_balance` | Current account balance and billing flags. |
| `list_transactions` | Balance transactions (top-ups, charges, refunds). |
| `get_usage` | Monthly usage-based billing summary. |
| `get_payment_method` | Saved card info. To add or change a card, go to <a target="_blank" href="https://dbaas.ultipa.com">Ultipa Cloud</a> → Billing — the Stripe card flow can't be driven via MCP. |
| `get_auto_reload` | Current auto-reload settings. |

### Data plane

Works with either Ultipa Cloud or a direct instance.

| Tool | What it does |
| --- | --- |
| `test_connection` | Quick health check on the target GQLDB instance. |
| `run_gql_query` | Execute a GQL query and return results. |
| `explain_query` | Return the execution plan without running the query. |
| `run_algo` | Run a built-in graph algorithm — centrality, community detection, similarity, pathfinding, graph embeddings, etc. Same execution as `run_gql_query`; separate so the agent surfaces the algorithm catalog for analytical questions. |
| `list_graphs` | List all graphs on the instance. |
| `describe_schema` | Detect graph mode (OPEN / CLOSED / ONTOLOGY) and run schema introspection. |
| `create_graph` | Create a new graph (OPEN / CLOSED / ONTOLOGY). |
| `delete_graph` | Drop a graph. |
| `write_data` | Run a GQL DML statement the agent composes by hand. For files on the user's machine, use `import_data` instead. |
| `import_data` | Bulk-write structured nodes and edges via the driver's gRPC bulk-insert path. A host file path to a CSV, JSON, or JSONL file is strongly preferred. |
| `write_procedure` | Create a stored procedure. |
| `get_db_version` | Live GQLDB version reported by the instance. |
| `get_db_license` | GQLDB edition and license info. |
| `reload_db_stats` | Rebuild the instance's stored statistics. |

### Docs

Works with either Ultipa Cloud or a direct instance.

| Tool | What it does |
| --- | --- |
| `lookup_docs` | Fetch Ultipa documentation pages by topic. Lets the agent ground GQLDB features and GQL composition in authoritative reference. |

## Troubleshooting

| Symptom | Likely cause / fix |
| --- | --- |
| `ENOENT: no such file or directory` from `import_data` with `filePath` | The path is on your agent's sandbox, not the MCP host. Drag the file into your terminal to copy its real host path, or paste the file content via `csv` mode. |
| Edge insert rejected with "EDGE_ID disabled" or custom `_id` not allowed | The graph has edge `_id` disabled. Run `ALTER GRAPH <name> SET EDGE_ID ENABLED` via `run_gql_query`, or drop the `_id` from your edge data. |
| `instances:credentials` permission required (data plane fails on a Cloud target) | Your `ULTIPA_CLOUD_API_KEY` is missing the `instances:credentials` scope. Regenerate the key with that scope at Ultipa Cloud → Settings → API Keys. |
| `list_instances` shows nothing even though you have an instance | You're targeting a direct instance (env vars only), not a Cloud account. `list_instances` only sees Cloud instances. Call `test_connection` (omit `id`) to confirm the direct instance is reachable. |
| `create_instance` succeeded but `adminPassword` is missing in the response | The Cloud REST `POST /v1/instances` returns the password exactly once. If you missed it, call `get_instance_credentials` (requires the `instances:credentials` scope). |
| MCP launches but exits immediately with "needs at least one auth mode" | Neither `ULTIPA_CLOUD_API_KEY` nor the direct trio (`ULTIPA_HOST` + `ULTIPA_USERNAME` + `ULTIPA_PASSWORD`) is set. Add them to your MCP client's `env` block. |
| MCP launches but exits with "Direct instance config is incomplete" | You set one or two of the direct env vars; all three (`ULTIPA_HOST`, `ULTIPA_USERNAME`, `ULTIPA_PASSWORD`) are required together. |
| `import_data` very slow or truncated in `csv` or arrays mode | The agent's output rate is the bottleneck. Provide a host file path so the MCP uses `filePath` mode (constant tokens), or fall back to Ultipa Manager → Data Integration for very large imports. |
| Claude Desktop extension installed but no Ultipa tools appear | Credentials weren't entered at install. Open **Settings → Extensions → Ultipa**, add a Cloud API key or the direct-instance host / username / password, and re-enable. |

For agent-side trace debugging, set `ULTIPA_MCP_DEBUG=1` in the MCP env to log every tool call name and latency to stderr.
