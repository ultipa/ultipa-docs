# Transaction

## Overview

A **transaction** contains a sequence of database operations that either all succeed or fail together as a unit to guarantee the **ACID** properties:

- **Atomicity** - All operations succeed or all fail
- **Consistency** - Data remains valid after transaction
- **Isolation** - Concurrent transactions don't interfere
- **Durability** - Committed changes persist

Transactions are crucial for tasks where data integrity is paramount, such as financial transfers where you need to deduct the transfer amount from one account and increase by that amount for another account.

### Transaction Lifecycle

The lifecycle of a transaction follows a clear three-step process:

1. **START:** Start a transaction explicitly
2. **EXECUTE:** Perform database operations
3. **TERMINATE:** Commit or rollback the transaction

Write operations in a transaction remain provisional and are not finalized until a **COMMIT** is executed. Any uncommitted changes can be reverted using **ROLLBACK**.

## Transaction Control

| Statement | Description |
| -- | -- |
| `START TRANSACTION` | Start a new transaction |
| `COMMIT` | Save all changes and end transaction |
| `ROLLBACK` | Discard all changes and end transaction |
| `SAVEPOINT name` | Create a named savepoint |
| `ROLLBACK TO SAVEPOINT name` | Rollback to a savepoint |
| `RELEASE SAVEPOINT name` | Remove a savepoint |
| `SHOW TRANSACTIONS` | List active transactions |
| `STOP TRANSACTION id` | Terminate a specific transaction |

## Auto-Commit Mode

By default, each statement runs in auto-commit mode (implicit transaction). Use explicit transactions for multi-statement atomicity:

**Auto-commit (default):**

```gql
// Each INSERT is its own transaction
INSERT (:Person {name: 'Alice'})  // Commits immediately
INSERT (:Person {name: 'Bob'})    // Separate transaction
```

**Explicit transaction:**

```gql
// All or nothing
START TRANSACTION

INSERT (:Person {name: 'Alice'})
INSERT (:Person {name: 'Bob'})
MATCH (a:Person {name: 'Alice'}), (b:Person {name: 'Bob'})
INSERT (a)-[:KNOWS]->(b)

COMMIT  // All 3 operations commit together
```

## Starting Transaction

To start a new transaction for the current graph:

```gql
START TRANSACTION
```

Once a transaction is started, you can perform both read and write operations against the current graph in the transaction.

## Committing Transaction

To apply all operations within the transaction to the database and terminate the transaction:

```gql
COMMIT
```

## Rolling Back Transaction

To discard all operations within the transaction and terminate the transaction:

```gql
ROLLBACK
```

## Savepoints

Create intermediate savepoints within transactions for partial rollback.

**Partial rollback using savepoint:**

```gql
START TRANSACTION

INSERT (:Person {name: 'Alice'})
SAVEPOINT sp1

INSERT (:Person {name: 'Bob'})
SAVEPOINT sp2

INSERT (:Person {name: 'Carol'})
// Oops, Carol was a mistake
ROLLBACK TO SAVEPOINT sp2

// Alice and Bob are kept, Carol is discarded
COMMIT
```

**Multi-phase transaction with savepoints:**

```gql
START TRANSACTION

// Phase 1: Create users
INSERT (:User {name: 'User1'})
INSERT (:User {name: 'User2'})
SAVEPOINT users_created

// Phase 2: Create relationships
MATCH (u1:User {name: 'User1'}), (u2:User {name: 'User2'})
INSERT (u1)-[:FOLLOWS]->(u2)
SAVEPOINT relations_created

// Phase 3: Additional operations
// If phase 3 fails, can rollback to relations_created

COMMIT
```

## Showing Transactions

To show running transactions in the database:

```gql
SHOW TRANSACTIONS
```

## Stopping Transaction

To terminate a specific transaction (admin only):

```gql
STOP TRANSACTION 'tx-001'
```

## Examples

### Bank Transfer

The following example demonstrates a bank transfer with proper transaction control:

```gql
START TRANSACTION

MATCH (a1:Account {_id: 'a78'}), (a2:Account {_id: 'a9002'})
INSERT (a1)-[:Transfer {amount: 1000, time: now()}]->(a2)

MATCH (n:Account {_id: 'a78'})
SET n.balance = n.balance - 1000

MATCH (n:Account {_id: 'a9002'})
SET n.balance = n.balance + 1000

COMMIT
```

### Rollback on Error

If something goes wrong, rollback discards all changes:

```gql
START TRANSACTION

INSERT (:Account {id: 'A1', balance: 1000})
INSERT (:Account {id: 'A2', balance: 500})

// If something goes wrong...
ROLLBACK
```

### Atomic Multi-Operation

Create multiple nodes and relationships atomically:

```gql
START TRANSACTION

INSERT (:Person {name: 'Alice'})
INSERT (:Person {name: 'Bob'})

MATCH (a:Person {name: 'Alice'}), (b:Person {name: 'Bob'})
INSERT (a)-[:KNOWS]->(b)

COMMIT
```

## Best Practices

| Practice | Description |
| -- | -- |
| Keep transactions short | Minimize time between START TRANSACTION and COMMIT |
| Batch related operations | Group related changes in one transaction |
| Handle errors explicitly | Always have a COMMIT or ROLLBACK path |
| Avoid long-running reads | Use separate transactions for analytics |

**Good: Batch related operations**

```gql
START TRANSACTION

FOR person IN [{name: 'A'}, {name: 'B'}, {name: 'C'}]
INSERT (:Person {name: person.name})

COMMIT
```

**Bad: Split related operations**

```gql
// Avoid this pattern!
INSERT (:Order {id: 'O1'})           // Transaction 1
INSERT (:OrderItem {orderId: 'O1'})  // Transaction 2
// If Transaction 2 fails, Order exists without items!
```
