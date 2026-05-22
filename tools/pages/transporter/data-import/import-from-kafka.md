# Import from Kafka

This page walks through importing data from Apache Kafka into a graph using `gqldb-importer`. The importer connects to one or more brokers, consumes records from configured topics, and writes each record as a node or edge.

Records are expected to be **JSON objects** in the message value; the object's keys are mapped to property names the same way as <a target="_blank" href="/docs/tools/import-from-json">JSON imports</a>.

## Usage Guides

### Verify Connectivity

Make sure the Kafka brokers are reachable from the host where `gqldb-importer` will run, and that the configured topics already contain the records you want to import.

### Generate Configuration File

```bash
./gqldb-importer -sample kafka
```

A file named `import.sample.kafka.yml` will be created in the current directory. Rename it before editing so a re-run of `-sample kafka` doesn't clobber your changes:

```bash
mv import.sample.kafka.yml import.kafka.yml
```

### Modify Configuration File

Edit `import.kafka.yml`. Kafka-specific configuration lives under the top-level `kafka:` block; see the <a target="_blank" href="/docs/tools/import-configurations">Import Configurations</a> for the rest of the file (`server`, `settings`).

<p tit="config snippet"></p>

```yml
kafka:
  brokers:
    - "localhost:9092"

  nodes:
    - schema: "Person"
      topic: "users"
      offset: oldest          # oldest, newest
      id_column: "_id"
      properties:
        age: int32

  edges:
    - schema: "FOLLOWS"
      topic: "follows"
      offset: oldest
      from_column: "follower_id"
      to_column: "following_id"
```

- `brokers` — list of bootstrap servers. Add as many as needed; the consumer will discover the rest of the cluster from these.
- Each node / edge entry binds one topic to one schema. The importer reads message values, parses them as JSON, and maps the object keys to properties.

### Offset Behavior

The `offset` field on each entry controls where the consumer starts reading the topic:

| Value | Behavior |
| --- | --- |
| `oldest` | Start at the earliest available offset (full backfill). |
| `newest` | Start at the latest offset; only records produced after the import begins are consumed. |

### Execute Import

```bash
./gqldb-importer -c import.kafka.yml
```

## Practical Tips

- Each Kafka entry consumes one topic to completion (or until the import is stopped) — for streaming pipelines, consider running the importer as a long-lived process and tuning `settings.batch_size` for throughput.
- The message value must be a single JSON object. Records that fail to parse are skipped or abort the import depending on `settings.stop_on_error`.
- Producer-side keys are ignored. If you need the partition key to drive the node ID, materialize it into the value payload at produce time.
