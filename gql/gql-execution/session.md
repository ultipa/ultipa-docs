# Session

## Overview

A session represents an active client connection to the database. Each session tracks the connected user, the current graph, and any running queries or transactions. A session can have at most one active transaction at a time.

## Showing Sessions

To show all active client sessions in the database:

```gql
SHOW SESSIONS
```

The singular form `SHOW SESSION` is also supported.

Each session provides the following metadata:

| <div table-width="20">Field</div> | Description |
| -- | -- |
| `session_id` | ID of the session. |
| `username` | The user who owns the session. |
| `current_graph` | The graph the session is currently connected to. |
| `current_query` | The query currently being executed. |
| `start_time` | The time when the session was established. |
| `elapsed_time` | The time that has elapsed since the session was established. |
| `extra_info` | Additional information about the session. |

## Killing Sessions

To terminate a specific session:

```gql
KILL SESSION <sessionId>
```

Killing a session also automatically rolls back any active transaction in that session.
