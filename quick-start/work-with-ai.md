# 5. Work with an AI Agent

Everything you have done so far by hand, provisioning instances, loading data, running queries and algorithms, an AI agent can do for you in natural language. The **Ultipa MCP** server exposes your GQLDB instance (local or Cloud) as tools for MCP-compatible AI clients like Claude, Cursor, and VS Code.

Instead of writing GQL, you describe the outcome and the agent picks the right tool, composes the query, and returns the answer.

## Connect the MCP Server

If your instance is running on Ultipa Cloud, get an **API key** from <a target="_blank" href="https://dbaas.ultipa.com/settings">Settings > API Keys</a>. When creating a key, select the permissions `Instance:Read`, `Instance:Write`, `Instance:Delete`, and `Instance:Credentials`. If your instance is running locally, you do not need to prepare anything.

Add the GQLDB MCP to your AI agent. Setup depends on your client; here are the two most common.

### Claude Code

Add the server with `claude mcp add`. 

If you have a local instance, run:

```bash
claude mcp add ultipa --scope user \
  --env ULTIPA_HOST=localhost:60061 \
  --env ULTIPA_USERNAME=admin \
  --env ULTIPA_PASSWORD=myPassword \
  -- npx -y @ultipa-graph/gqldb-mcp
```

If you are using Ultipa Cloud, use your API key:

```bash
claude mcp add ultipa-cloud --scope user \
  --env ULTIPA_CLOUD_API_KEY=<your_api_key> \
  -- npx -y @ultipa-graph/gqldb-mcp
```

Verify with `claude mcp list` and restart Claude Code.

### Claude Desktop / Cursor / Other Stdio Clients

Add an entry under `mcpServers` in your client's MCP config. The same JSON works everywhere; only the file location differs.

If you have a local instance, add:

```json
{
  "mcpServers": {
    "ultipa": {
      "command": "npx",
      "args": ["-y", "@ultipa-graph/gqldb-mcp"],
      "env": {
        "ULTIPA_HOST": "localhost:60061",
        "ULTIPA_USERNAME": "admin",
        "ULTIPA_PASSWORD": "myPassword"
      }
    }
  }
}
```

If you are using Ultipa Cloud, use your API key:
 
```json
{
  "mcpServers": {
    "ultipa": {
      "command": "npx",
      "args": ["-y", "@ultipa-graph/gqldb-mcp"],
      "env": {
        "ULTIPA_CLOUD_API_KEY": "<your_api_key>"
      }
    }
  }
}
```

Restart the client after editing.

## Talk to Your Graph

Once connected, just ask. The agent routes each request to the right tool: running queries, importing files, executing algorithms, or managing instances.

**Basic inspection:**

- "Test connection to my instance."
- "List all graphs on my instance."
- "What kinds of nodes and edges exist in the `default` graph?"

**Explore and query:**

- "Who does Alice follow, and who follows her back?"
- "Explain this query before running it: `MATCH (u:User {city: 'London'}) RETURN u`."

**Load data:**

- "Import the nodes in `/Users/me/data/users.csv` into `default` as `User` nodes."
- "Write three new `User` nodes named Dave, Erin, and Frank."

**Analyze:**

- "Run PageRank on `default` over the `Follows` edges and return the top 3."
- "Who are the most influential users in the graph?"

**Cloud operations (Ultipa Cloud only):**

- "Show CPU and memory for my instance over the last 10 minutes."
- "Pause my instance."
- "Resume my instance."

## What the Agent Can Reach

Under the hood the MCP server groups its tools into:

- **Data plane**: `run_gql_query`, `explain_query`, `run_algo`, `import_data`, `write_data`, `create_graph`, `describe_schema`, and more. Works with both Cloud and self-managed instances.
- **Control plane**: instance lifecycle, metrics, logs, firewall, backups, and billing. Ultipa Cloud only.
- **Docs**: `lookup_docs`, which lets the agent ground its GQL in the authoritative documentation before it runs anything.

See the full tool catalog and troubleshooting table in <a href="/docs/tools/mcp" target="_blank">Ultipa MCP</a>.

---

That completes the round trip: install, load, query, analyze, and operate, all the way to natural language. For where to go next, see <a href="/docs/quick-start/next-steps" target="_blank">Next Steps</a>.
