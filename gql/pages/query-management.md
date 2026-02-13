# Query Management

GQL queries are executed as real-time operations. Results are returned to the client once execution is complete and are not stored on the server. The system tracks all running queries and provides commands to list and cancel them.

## SHOW QUERIES

Lists all currently running queries. This command is never blocked by concurrency limits.

```gql
-- List all running queries
SHOW QUERIES

-- Equivalent
TOP QUERIES

-- Shorthand
TOP
```

Returns a table with the following columns:

| Field | Description |
| -- | -- |
| `query_id` | The unique identifier of the query (e.g., `q1`, `q2`). |
| `query_text` | The query text, truncated to 100 characters. |
| `start_time` | The time the query started executing. |
| `duration_ms` | How long the query has been running, in milliseconds. |
| `status` | Current state of the query: `running` or `canceling`. |

## KILL QUERY

Cancels a running query by its ID. The query transitions to `canceling` status and stops at the next cancellation checkpoint.

```gql
KILL QUERY 'q1'
```

Use `SHOW QUERIES` to find the `query_id` of the query you want to cancel.

## Concurrency Control

The system uses separate concurrency limits for read and write queries:

| Query Type | Default Slots | Description |
| -- | -- | -- |
| Read | 16 | Queries that only read data (e.g., `MATCH`, aggregations). |
| Write | 4 | Queries that modify data (e.g., `INSERT`, `DELETE`, `SET`). |

When all slots are occupied, new queries block until a slot becomes available or the query context is cancelled. Management commands (`SHOW QUERIES`, `KILL QUERY`) bypass the concurrency limits and always respond immediately.
