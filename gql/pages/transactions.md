# Transactions

Ultipa GQLDB provides full ACID transaction support with snapshot isolation, savepoints, and read-your-own-writes consistency.

## Overview

Transactions group multiple read/write operations into a single atomic unit. Either all operations succeed (commit) or none of them take effect (rollback).

| Property | Behavior |
|----------|----------|
| **Atomicity** | All changes are applied together on commit, or none at all on rollback. |
| **Consistency** | The database remains in a valid state after each transaction — data integrity rules are enforced at commit time. |
| **Isolation** | Each transaction sees a consistent snapshot from the moment it started. |
| **Durability** | Committed data is persisted to storage. |

> **Without an explicit transaction**, each write takes effect immediately — there is no implicit transaction wrapping your queries. Use transactions when you need to group multiple operations atomically, require rollback capability, or need snapshot isolation.

## Transaction Control

### START TRANSACTION

Starts a new transaction. Returns a `transaction_id` and `status`.

```gql
-- Read-write transaction (default)
START TRANSACTION

-- Equivalent
BEGIN TRANSACTION

-- Read-only transaction (all write operations are rejected)
START TRANSACTION READ ONLY
```

Once `START TRANSACTION` is executed, **all subsequent queries run within that transaction** until an explicit `COMMIT` or `ROLLBACK` is issued. There is no need to pass a transaction handle — every query automatically participates in the active transaction.

### COMMIT

Applies all buffered operations atomically to storage.

```gql
COMMIT
```

### ROLLBACK

Discards all changes in the current transaction.

```gql
ROLLBACK
```

### SAVEPOINT

Creates a named snapshot within the transaction. You can later roll back to this point without discarding the entire transaction.

```gql
SAVEPOINT my_savepoint
```

### ROLLBACK TO SAVEPOINT

Rolls back all operations performed after the named savepoint was created. The savepoint itself is retained and can be rolled back to again.

```gql
ROLLBACK TO SAVEPOINT my_savepoint
```

### RELEASE SAVEPOINT

Releases a savepoint, keeping all changes made since it was created. The savepoint can no longer be rolled back to.

```gql
RELEASE SAVEPOINT my_savepoint
```

### SHOW TRANSACTIONS

Lists all active transactions with their metadata.

```gql
SHOW TRANSACTIONS
```

Returns columns: `transaction_id`, `status`, `read_only`, `start_time`.

### STOP TRANSACTION

Forcibly terminates a running transaction by ID.

```gql
STOP TRANSACTION 'tx_abc123'

-- Equivalent
KILL TRANSACTION 'tx_abc123'
```

**How is this different from COMMIT / ROLLBACK?**

- `COMMIT` and `ROLLBACK` act on your current transaction automatically — you don't need to specify an ID.
- `STOP TRANSACTION` requires an explicit transaction ID, so you can use it to terminate any transaction — including ones you don't own.
- All buffered writes are **discarded** (same as `ROLLBACK`). Nothing from the stopped transaction is saved.
- The typical workflow: run `SHOW TRANSACTIONS` to find a stuck transaction's ID, then `STOP TRANSACTION '<id>'` to kill it.

## Multi-Statement Transactions

A transaction can span multiple statements. You can either send each statement as a separate query call, or combine them into a single semicolon-separated string. Both approaches are equivalent — semicolons are only needed when packing multiple statements into one query.

**Separate queries (no semicolons):**

```gql
START TRANSACTION
INSERT (:Person {_id: 'alice', name: 'Alice'})
INSERT (:Person {_id: 'bob', name: 'Bob'})
MATCH (a:Person WHERE a._id = 'alice'), (b:Person WHERE b._id = 'bob')
INSERT (a)-[:KNOWS]->(b)
COMMIT
```

**Single query (semicolons as delimiters):**

```gql
START TRANSACTION;
INSERT (:Person {_id: 'alice', name: 'Alice'});
INSERT (:Person {_id: 'bob', name: 'Bob'});
MATCH (a:Person WHERE a._id = 'alice'), (b:Person WHERE b._id = 'bob')
INSERT (a)-[:KNOWS]->(b);
COMMIT
```

## Isolation and Consistency

### Snapshot Isolation

When a transaction begins, the database captures a point-in-time snapshot. All reads within the transaction see data as it was at that moment, regardless of what other transactions do afterward.

This means:
- Your queries always return consistent results throughout the transaction.
- Other transactions' uncommitted (or even committed) changes won't suddenly appear in your reads.
- Two transactions running at the same time won't interfere with each other's reads.

### Read-Your-Own-Writes (RYOW)

Within a transaction, you can immediately read data you just wrote. This is critical for patterns like inserting nodes and then creating edges between them:

```gql
START TRANSACTION
INSERT (:Person {_id: 'alice', name: 'Alice'})
INSERT (:Person {_id: 'bob', name: 'Bob'})
-- MATCH can see the nodes just inserted above
MATCH (a:Person WHERE a._id = 'alice'), (b:Person WHERE b._id = 'bob')
INSERT (a)-[:KNOWS]->(b)
COMMIT
```

When reading data inside a transaction, the database checks in this order:

1. **Pending changes** in the current transaction (inserts, updates, deletes not yet committed)
2. **Snapshot cache** (data already read once in this transaction)
3. **Storage** (persisted data from before the transaction started)

## Savepoints

Savepoints create named snapshots within a transaction. This enables partial rollback without discarding the entire transaction.

```gql
START TRANSACTION

INSERT (:Person {_id: 'p1', name: 'Alice'})
SAVEPOINT sp1                                -- snapshot: {Alice}

INSERT (:Person {_id: 'p2', name: 'Bob'})
SAVEPOINT sp2                                -- snapshot: {Alice, Bob}

INSERT (:Person {_id: 'p3', name: 'Charlie'})
ROLLBACK TO SAVEPOINT sp1                    -- restore to {Alice}, sp2 invalidated

-- Only Alice exists now
COMMIT
```

Savepoint rules:

- **Ordering**: Savepoints created after a rolled-back savepoint are automatically invalidated.
- **Reuse**: After `ROLLBACK TO SAVEPOINT sp1`, `sp1` is still available for another rollback.
- **Release**: `RELEASE SAVEPOINT sp1` keeps changes and frees the snapshot memory.
- **Nesting**: Multiple savepoints can be created at different points in the transaction.

## Transaction Administration

### Transaction Defaults

| Setting | Default | Description |
|---------|---------|-------------|
| Max transactions | 10,000 | Maximum concurrent transactions before rejection |
| Transaction TTL | 1 hour | Auto-terminate transactions older than this |
| Cleanup interval | 1 minute | How often the database checks for expired transactions |

### Transaction Statuses

| Status | Meaning |
|--------|---------|
| `active` | Transaction is running |
| `committed` | Transaction was committed successfully |
| `rolledback` | Transaction was rolled back |
| `stopped` | Transaction was forcibly terminated via `STOP/KILL` |
| `timeout` | Transaction exceeded its TTL and was auto-terminated |

### Monitoring

```gql
-- List all transactions
SHOW TRANSACTIONS

-- Force-stop a specific transaction
STOP TRANSACTION 'tx_abc123'
```

## Limitations

- **No nested transactions** — Only one active transaction at a time. Use savepoints for partial rollback instead.
- **Read-only enforcement** — `READ ONLY` transactions reject all write operations.

## Examples

### Basic Insert and Query

```gql
START TRANSACTION
INSERT (:Person {_id: 'alice', name: 'Alice', age: 30})
INSERT (:Person {_id: 'bob', name: 'Bob', age: 25})
-- Read-your-own-writes: MATCH sees the uncommitted inserts
MATCH (p:Person) RETURN p.name, p.age
COMMIT
```

### Inserting Nodes and Edges

```gql
START TRANSACTION
INSERT (:Person {_id: 'alice', name: 'Alice'})
INSERT (:Person {_id: 'bob', name: 'Bob'})
MATCH (a:Person WHERE a._id = 'alice'), (b:Person WHERE b._id = 'bob')
INSERT (a)-[:KNOWS]->(b)
COMMIT
```

### Savepoint Workflow

```gql
START TRANSACTION

INSERT (:Person {_id: 'p1', name: 'Alice'})
SAVEPOINT before_bob

INSERT (:Person {_id: 'p2', name: 'Bob'})
INSERT (:Person {_id: 'p3', name: 'Charlie'})

-- Oops, undo Bob and Charlie
ROLLBACK TO SAVEPOINT before_bob

-- Only Alice will be committed
COMMIT
```

### Rollback

```gql
START TRANSACTION
INSERT (:Person {_id: 'p1', name: 'Alice'})
INSERT (:Person {_id: 'p2', name: 'Bob'})
-- Changed my mind, discard everything
ROLLBACK
```

### Administrative Commands

```gql
-- See what's running
SHOW TRANSACTIONS

-- Kill a hung transaction
STOP TRANSACTION 'tx_550e8400-e29b-41d4-a716-446655440000'
```