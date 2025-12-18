# Transaction Management

## Overview

A **transaction** contains a sequence of database operations that either all succeed or fail together as a unit to guarantee the **ACID** (Atomicity, Consistency, Isolation, and Durability) properties.

Transactions are crucial for tasks where data integrity is paramount, such as financial transfers where you need to deduct the transfer amount from one account and increase by that amount for another account.

> Currently one session only supports one running transaction.

### Transaction Lifecycle and Control

The lifecycle of a transaction follows a clear three-step process:

- **START:** Start a transaction explicitly.
- **EXECUTE:** Perform database operations.
- **TERMINATE:** Commit or rollback the transaction.
  - **COMMIT:** All operations within the transaction are permanently applied to the database.
  - **ROLLBACK:** All operations within the transaction are discarded, and the database state is reverted to its condition before the transaction began.

Write operations in a transaction remain provisional and are not finalized until a **COMMIT** is executed. Any uncommitted changes can be reverted using **ROLLBACK**.

Currently, a graph can only have one running transaction.

### Transaction Timeout

After a period of no heartbeat detected from the client, Ultipa automatically terminates the transaction through **ROLLBACK**. The timeout threshold can be configured with the `idle_timeout_second` parameter on the Name Server, with a default value of 10 minutes.

## Showing Transactions

To show running transactions in the database:

```gql
SHOW TRANSACTION
```

Each transaction provides the following essential metadata:

| <div table-width="17">Field</div> | Description |
| -- | -- |
| `graph_name` | The name of the graph the transaction is executing against. |
| `session_id` | The session ID. |
| `transaction_id` | The transaction ID. |
| `current_query` | The the last query executed in the transaction. |
| `start_time` | The time when the transaction was started. |
| `elapsed_time` | The time that has elapsed since the transaction was started. |
| `extra_info` | Extra information about the transaction. |

## Starting Transaction

To start a new transaction for the current graph:

```gql
START TRANSACTION
```

Once a transaction is started, you can perform both read and write operations against the current graph in the transaction.

## Rolling Back Transaction

To discard all operations within the transaction and terminate the transaction:

```gql
ROLLBACK
```

## Committing Transaction

To apply all operations within the transaction to the database and terminate the transaction:

```gql
COMMIT
```

## Examples

The following example demonstrates how to start a transaction and perform three operations:

- Inserts a `Transfer` edge from accounts `a78` to `a9002`.
- Updates the balance of account `a78`.
- Updates the balance of account `a9002`

Finally, commit the transaction to the database.

```gql
START TRANSACTION;

MATCH (a1:Account {_id: "a78"}), (a2:Account {_id: "a9002"})
INSERT (a1)-[:Transfer {amount: 1000, time: local_datetime("2025-11-09 03:02:11")}]->(a2);

MATCH (n:Account {_id: "a78"}) SET n.balance = n.balance - 1000;

MATCH (n:Account {_id: "a9002"}) SET n.balance = n.balance + 1000;

COMMIT;
```

Alternatively, you can roll back the transaction to discard all changes:

```gql
START TRANSACTION;

MATCH (a1:Account {_id: "a78"}), (a2:Account {_id: "a9002"})
INSERT (a1)-[:Transfer {amount: 1000, time: local_datetime("2025-11-09 03:02:11")}]->(a2);

MATCH (n:Account {_id: "a78"}) SET n.balance = n.balance - 1000;

MATCH (n:Account {_id: "a9002"}) SET n.balance = n.balance + 1000;

ROLLBACK;
```
