# Change Data Capture (CDC)

## Overview

Change Data Capture (CDC) publishes real-time INSERT, UPDATE, and DELETE events to Apache Kafka topics. This enables downstream consumers such as data warehouses, search indexes, and event-driven architectures to react to graph data changes in near real-time.

CDC is disabled by default and can be enabled per Shard Server via configuration.

## Configuration

Add the following section to `shard-server.config`:

```ini
[CDC]
enabled = true
kafka_brokers = localhost:9092
topic_prefix = ultipa_cdc
batch_size = 100
flush_interval_ms = 1000
capture_operations = INSERT,UPDATE,DELETE
capture_schemas =
```

| <div table-width="22">Parameter</div> | Default | Description |
| -- | -- | -- |
| `enabled` | `false` | Enables or disables CDC publishing. |
| `kafka_brokers` | `localhost:9092` | Kafka broker addresses (comma-separated). |
| `topic_prefix` | `ultipa_cdc` | Prefix for Kafka topic names. |
| `batch_size` | `100` | Maximum events per batch sent to Kafka. |
| `flush_interval_ms` | `1000` | Maximum wait time in milliseconds before flushing a batch. |
| `capture_operations` | `INSERT,UPDATE,DELETE` | Operations to capture (comma-separated). |
| `capture_schemas` | (empty) | Schemas to capture. Empty means all schemas. |

All CDC settings are hot-updatable via the [HTTP Config API](/operations-and-maintenance/configuration):

```bash
# Enable CDC
curl -X POST http://<name-server-host>:9091/config \
  -H "Content-Type: application/json" \
  -d '{"CDC.enabled": "true"}'

# Filter to specific operations and schemas
curl -X POST http://<name-server-host>:9091/config \
  -d '{"CDC.capture_operations": "INSERT,DELETE", "CDC.capture_schemas": "Person"}'
```

## Topic Naming

Topics follow the pattern `{topic_prefix}.{graph_name}.{db_type}`:

- `ultipa_cdc.myGraph.nodes` — node events for `myGraph`
- `ultipa_cdc.myGraph.edges` — edge events for `myGraph`

## Event Format

Each event is a JSON message with the following structure:

### Node Events

```json
{
  "op": "INSERT",
  "timestamp": 1740000000000,
  "graph": "myGraph",
  "schema": "Person",
  "db_type": "node",
  "key": {
    "_id": "node1",
    "_uuid": 12345
  },
  "before": null,
  "after": {"name": "Alice", "age": 30}
}
```

### Edge Events

Edge events include additional key fields for endpoint references:

```json
{
  "op": "UPDATE",
  "timestamp": 1740000000000,
  "graph": "myGraph",
  "schema": "Knows",
  "db_type": "edge",
  "key": {
    "_id": "edge1",
    "_uuid": 67890,
    "_from": "person1",
    "_to": "person2",
    "_from_uuid": 12345,
    "_to_uuid": 23456
  },
  "before": {"weight": 0.5},
  "after": {"weight": 0.8}
}
```

### Operation Types

| Operation | `before` | `after` | Description |
| -- | -- | -- | -- |
| `INSERT` | `null` | Property values | A new node or edge was created. |
| `UPDATE` | Old property values | New property values | An existing node or edge was modified. |
| `DELETE` | Last known property values | `null` | A node or edge was deleted. |

## Prerequisites

CDC requires the Kafka client library to be available on the Shard Server. If the library is not found, CDC remains disabled gracefully without affecting server operation. Refer to the installation guide for setup instructions.
