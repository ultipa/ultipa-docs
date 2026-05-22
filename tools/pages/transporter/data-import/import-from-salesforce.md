# Import from Salesforce

This page walks through importing data from Salesforce into a graph using `gqldb-importer`. The importer authenticates against the Salesforce REST API, runs one SOQL query per node/edge type, and streams the result records into the graph.

## Usage Guides

### Prepare Salesforce Credentials

You need three pieces of information from Salesforce:

1. **Instance URL** — your org's My Domain URL, e.g., `https://your-instance.salesforce.com`.
2. **Username** and **password** — the user account the importer will authenticate as. The account must have at least read access on every object referenced by the import queries.
3. **Security token** — generated from the Salesforce user settings (Personal Settings → Reset My Security Token). Required for API logins from outside trusted IP ranges.

### Generate Configuration File

```bash
./gqldb-importer -sample salesforce
```

A file named `import.sample.salesforce.yml` will be created in the current directory. Rename it before editing so a re-run of `-sample salesforce` doesn't clobber your changes:

```bash
mv import.sample.salesforce.yml import.salesforce.yml
```

### Modify Configuration File

Edit `import.salesforce.yml`. Salesforce-specific configuration lives under the top-level `salesforce:` block; see the <a target="_blank" href="/docs/tools/import-configurations">Import Configurations</a> for the rest of the file (`server`, `settings`).

<p tit="config snippet"></p>

```yml
salesforce:
  url: "https://your-instance.salesforce.com"
  username: "sf_user@example.com"
  password: "sf_password"
  token: "security_token"

  nodes:
    - schema: "Account"
      query: "SELECT Id, Name, Industry FROM Account LIMIT 1000"
      id_column: "Id"

  edges:
    - schema: "CONTACT_OF"
      query: "SELECT Id, AccountId, Name FROM Contact LIMIT 1000"
      from_column: "Id"
      to_column: "AccountId"
```

### Execute Import

```bash
./gqldb-importer -c import.salesforce.yml
```

## Writing the SOQL Queries

Each query is plain <a target="_blank" href="https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm">SOQL</a>. The field names returned by `SELECT` are what `id_column`, `from_column`, `to_column`, and `properties` reference.

**Node query** — return one record per node, with one column acting as the node `_id`:

```sql
-- Maps directly to id_column: "Id", schema: "Account"
SELECT Id, Name, Industry, AnnualRevenue
FROM Account
WHERE Type = 'Customer'
```

**Edge query** — return one record per edge, with columns for the source and destination `_id`s:

```sql
-- Maps to from_column: "Id", to_column: "AccountId", schema: "CONTACT_OF"
SELECT Id, AccountId, Email
FROM Contact
WHERE AccountId != null
```

A few practical tips:

- Salesforce object IDs (`Id`, `AccountId`, etc.) are already globally unique within an org — no `prefix` needed to avoid collisions.
- SOQL does not support `JOIN`. To build edges between two unrelated objects, run one query per side or use Salesforce's lookup-relationship syntax (`Account.Name` from `Contact`).
- The Salesforce REST API enforces per-org rate limits — large imports may need pagination via SOQL's `LIMIT` / `OFFSET` or a `WHERE Id >` cursor.
