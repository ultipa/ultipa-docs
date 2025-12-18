# GQL Execution

## Process

## Overview

Unless otherwise specified, GQL queries are executed as real-time processes. The results of processes are returned to the client once execution is complete and are not stored on the server.

## Showing Processes

To retrieve currently running processes in the database:

```gql
TOP
```

It returns the following information for each process:

| <div table-width="20">Field</div> | Description |
| -- | -- |
| `process_id` | ID of the process. |
| `process_query` | Query of the process. |
| `duration` | The duration in seconds for which the process has been running. |
| `status` | Current state of the process, which can only be `RUNNING`. |

## Stopping Processes

To stop a currently running process with id `2097156` in the database:

```gql
KILL 2097156
```
