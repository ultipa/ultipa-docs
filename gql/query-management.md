# Query Management

## Overview

Most GQL queries are executed as **real-time operations**: results are returned to the client once execution is complete and are not stored on the server. A few long-running operations run as **background tasks** instead, returning a `task_id` immediately while the work continues on the server.

The system tracks both real-time queries and tasks, providing commands to list and cancel running queries and to monitor, stop, or delete tasks.

## Real-time Queries

### Showing Queries

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

### Killing Queries

Cancels a running query by its ID. The query transitions to `canceling` status and stops at the next cancellation checkpoint.

```gql
KILL QUERY 'q1'
```

Use `SHOW QUERIES` to find the `query_id` of the query you want to cancel.

## Background Tasks

The following operations run as tasks automatically:

- **Write-mode algorithms**: `CALL algo.*.write()`
- **Graph compaction**: `COMPACT GRAPH`
- **Graph copy**: `CREATE GRAPH … AS COPY OF …`

You can also submit any query as a task explicitly with [`EXEC`](#Submitting-a-Task-with-EXEC).

### Submitting a Task with EXEC

`EXEC <query>` runs a query as an asynchronous background task: it returns immediately with a task id instead of holding the connection open until the query finishes. This suits long-running writes that would otherwise run synchronously, such as large bulk inserts or property backfills.

```gql
-- Bulk insert: many rows in one statement
EXEC INSERT (:Person {name: 'Alice'}),
            (:Person {name: 'Bob'}),
            (:Person {name: 'Carol'}),
            ...

-- Backfill embeddings on every Document that lacks one
EXEC MATCH (n:Document) WHERE n.embedding IS NULL SET n.embedding = ai.embed(n.content)
```

`EXEC` returns `task_id` and `message`.

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
