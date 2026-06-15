# Query Management

Most GQL queries are executed as real-time operations: results are returned to the client once execution is complete and are not stored on the server. Some operations — such as algorithm write modes, imports, and exports — run as background tasks instead, returning a `task_id` and persisting their results on the server. The system tracks both, providing commands to list and cancel running queries and to monitor, stop, or delete tasks.

## Showing Queries

Lists all currently running queries across all connections. This command is never blocked by concurrency limits.

```gql
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

## Killing Queries

Cancels a running query by its ID. The query transitions to `canceling` status and stops at the next cancellation checkpoint.

```gql
KILL QUERY 'q1'
```

Use `SHOW QUERIES` to find the `query_id` of the query you want to cancel.

## Background Tasks

Certain operations run as background tasks, such as algorithm execution. Tasks are tracked by the server and can be monitored, stopped, or deleted.

### Showing Tasks

List all tasks:

```gql
SHOW TASKS
```

| Field | Description |
| -- | -- |
| `task_id` | Unique task identifier (e.g., `task_550e8400-...`). |
| `type` | Task type: `algorithm`, `import`, or `export`. |
| `query` | The query or command that created the task. |
| `status` | Current status: `pending`, `running`, `completed`, `failed`, or `cancelled`. |
| `started_at` | When the task started executing. |
| `progress` | Completion percentage (0–100). |

Show a specific task:

```gql
SHOW TASK 'task_550e8400-e29b-41d4-a716-446655440000'
```

### Stopping a Task

Cancel a running task:

```gql
STOP 'task_550e8400-e29b-41d4-a716-446655440000'
```

### Deleting a Task

Remove a task from the registry and delete its result files:

```gql
DELETE TASK 'task_550e8400-e29b-41d4-a716-446655440000'
```

## Query Defaults

| Setting | Default | Description |
| -- | -- | -- |
| Query timeout | 30 seconds (driver) | The query timeout is set by the client driver (default 30 seconds). If the client sends no timeout, the server falls back to its `-default-timeout` flag (default 5 minutes). |
| Read concurrency slots | 16 | Maximum concurrent read queries (e.g., `MATCH`, aggregations). |
| Write concurrency slots | 4 | Maximum concurrent write queries (e.g., `INSERT`, `DELETE`, `SET`). |

When all slots are occupied, new queries block until a slot becomes available or the query context is cancelled. Management commands (`SHOW QUERIES`, `KILL QUERY`, `EXPLAIN`) bypass the concurrency limits and always respond immediately.
