# Spark Connector

## Overview

Ultipa Spark Connector provides integration between Ultipa and Apache Spark through the Spark DataSource V2 API, enabling reading and writing of graph data as Spark DataFrames. It supports full-scan reads, GQL query reads, node/edge writes with INSERT, UPSERT, and OVERWRITE modes, and all Ultipa property types.

The connector supports Scala, Python, Java, and R. The examples in this guide are written in Scala.

## Installation

### Prerequisites

- Ultipa v5.x
- Spark 3.4+ with Scala 2.12
- Java 11+

### Import Dependency

Add the following dependency to your `pom.xml`:

```xml
<dependencies>
  <dependency>
    <groupId>com.ultipa</groupId>
    <artifactId>ultipa-spark-connector</artifactId>
    <version>2.0.0</version>
  </dependency>
</dependencies>
```

Or use the fat JAR directly with `spark-submit`:

```bash
spark-submit --jars ultipa-spark-connector-2.0.0.jar your-app.jar
```

## Reading

### Read by Node Schema

Read all nodes of a schema into a DataFrame:

```scala
val persons = spark.read.format("ultipa")
  .option("host", "10.0.0.1")
  .option("port", "60061")
  .option("user", "root")
  .option("password", "root")
  .option("graph", "social")
  .option("entityType", "node")
  .option("schema", "Person")
  .load()

persons.show()
```

### Read by Edge Schema

Read all edges of a schema into a DataFrame:

```scala
val follows = spark.read.format("ultipa")
  .option("host", "10.0.0.1")
  .option("port", "60061")
  .option("user", "root")
  .option("password", "root")
  .option("graph", "social")
  .option("entityType", "edge")
  .option("schema", "Follows")
  .load()
```

### Read via GQL Query

Read data using a GQL query statement:

```scala
val results = spark.read.format("ultipa")
  .option("host", "10.0.0.1")
  .option("port", "60061")
  .option("user", "root")
  .option("password", "root")
  .option("graph", "social")
  .option("query", "MATCH (n:Person) WHERE n.age > 25 RETURN n._id, n.name, n.age")
  .load()
```

## Writing

### Write Nodes

Write a DataFrame as nodes using `SaveMode.Append` (INSERT):

```scala
df.write.format("ultipa")
  .option("host", "10.0.0.1")
  .option("port", "60061")
  .option("user", "root")
  .option("password", "root")
  .option("graph", "social")
  .option("entityType", "node")
  .option("schema", "Person")
  .mode(SaveMode.Append)
  .save()
```

### Write Edges

```scala
df.write.format("ultipa")
  .option("host", "10.0.0.1")
  .option("port", "60061")
  .option("user", "root")
  .option("password", "root")
  .option("graph", "social")
  .option("entityType", "edge")
  .option("schema", "Follows")
  .mode(SaveMode.Append)
  .save()
```

### Write Modes

| Mode | Behavior |
| -- | -- |
| `SaveMode.Append` | Inserts new data. |
| `SaveMode.Overwrite` | Drops existing data of the schema and re-inserts. |
| Custom `writeMode=upsert` | Upserts data. Edges require a key constraint. |

To use upsert mode:

```scala
df.write.format("ultipa")
  .option("host", "10.0.0.1")
  .option("port", "60061")
  .option("user", "root")
  .option("password", "root")
  .option("graph", "social")
  .option("entityType", "node")
  .option("schema", "Person")
  .option("writeMode", "upsert")
  .mode(SaveMode.Append)
  .save()
```

## Options

### General Options

| <div table-width="18">Option</div> | Default | Description |
| -- | -- | -- |
| `host` | | IP address of the Ultipa server. |
| `port` | `60061` | Port number of the Ultipa server. |
| `user` | | Username for authentication. |
| `password` | | Password for authentication. |
| `graph` | | Name of the graph to connect to. |
| `useTls` | `false` | Enables TLS encryption. |
| `certPath` | | Path to the TLS certificate file. |

### Read Options

| <div table-width="18">Option</div> | Default | Description |
| -- | -- | -- |
| `entityType` | | Entity type to read: `node` or `edge`. |
| `schema` | | Schema name to read. |
| `query` | | GQL query statement for reading data. |

### Write Options

| <div table-width="18">Option</div> | Default | Description |
| -- | -- | -- |
| `entityType` | | Entity type to write: `node` or `edge`. |
| `schema` | | Schema name to write to. Non-existent schemas are created automatically. |
| `writeMode` | `insert` | Write mode: `insert` or `upsert`. |
| `batchSize` | `10000` | Number of records per batch write. |

## Data Type Conversion

| Ultipa Property Type | Spark Data Type |
| -- | -- |
| `int32`, `uint32` | `IntegerType` |
| `int64`, `uint64` | `LongType` |
| `float` | `FloatType` |
| `double` | `DoubleType` |
| `string`, `text` | `StringType` |
| `bool` | `BooleanType` |
| `datetime`, `timestamp` | `TimestampType` |
| `date` | `DateType` |
| `blob` | `BinaryType` |
| `decimal` | `DecimalType` |
| `list` | `ArrayType(StringType)` |
| `map` | `MapType(StringType, StringType)` |
| `point`, `point3d` | `StringType` (WKT format) |
| `record` | `StringType` (JSON format) |
