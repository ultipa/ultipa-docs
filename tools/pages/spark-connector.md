# Spark Connector

## Overview

Ultipa Spark Connector provides integration between Ultipa and Apache Spark through Ultipa Java SDK, facilitating the reading or writing of data from and to Ultipa within the Spark environment.

Built on the latest Spark DataSource API, Ultipa Spark Connector supports different languages for interacting with Spark, including Scala, Python, Java, and R. The examples provided in this manual are written in Scala; minor syntax adjustments may be required for other languages.

## Installation

### Prerequisites

Before installing the Ultipa Spark Connector, ensure you have the right versions of Ultipa and Spark:

- Ultipa v4.x (v4.3 and above), whether run as a single instance, or as a cluster
- Spark 2.4.8 with Scala 2.12

### Import Dependency

To import the dependency of the Ultipa Spark Connector, add the following code to your *pom.xml* file:

<p tit= "prom.xml" ></p>

```xml
<dependencies>
  <dependency>
    <groupId>com.ultipa</groupId>
    <artifactId>ultipa-spark-connector</artifactId>
    <version>1.0.0</version>
  </dependency>
</dependencies>
```

## Reading

You can read data from Ultipa into a Spark DataFrame by a node schema, an edge schema or a UQL query statement.

Spark does not support all property data types in Ultipa. Refer to the <a href="#Data-Type-Conversion">Data Type Conversion</a> table for details.

### Read by Node Schema

Retrieve `_id` and all custom properties of nodes belonging to the specified schema.

Example: Read all nodes in the graphset *Test* with the schema *Person*

<p tit= "Scala" ></p>

```scala
import org.apache.spark.sql.{SaveMode, SparkSession}

val spark = SparkSession.builder().getOrCreate()

val df = spark.read.format("com.ultipa.spark.DataSource")
  .option("hosts","192.168.1.56:63940,192.168.1.57:63940,192.168.1.58:63940")
  .option("auth.username","root")
  .option("auth.password","root")
  .option("graph","Test")
  .option("nodes","Person")
  .load()

df.show()
```

Result:

| \_id | name | gender |
| -- | -- | -- |
| U001 | Alice | female |
| U002 | Bruce | male |
| U003 | Joe | male |

### Read by Edge Schema

Retrieve `_from`, `_to` and all custom properties of edges belonging to the specified schema.

Example: Read all edges in the graphset *Test* with the schema *Follows*

<p tit= "Scala" ></p>

```scala
import org.apache.spark.sql.{SaveMode, SparkSession}

val spark = SparkSession.builder().getOrCreate()

val df = spark.read.format("com.ultipa.spark.DataSource")
  .option("hosts","192.168.1.56:63940,192.168.1.57:63940,192.168.1.58:63940")
  .option("auth.username","root")
  .option("auth.password","root")
  .option("graph","Test")
  .option("edges","Follows")
  .load()

df.show()
```

Result:

| \_from | \_to | <div table-width="35">since</div> | level |
| -- | -- | -- | -- |
| U001 | U002 | 2019-12-15 12:10:09 | 1 |
| U003 | U001 | 2021-1-20 09:15:02 | 2 |

### Read by UQL

Retrieve data using a UQL query statement. The UQL query for reading must contain the RETURN clause, and you can return data with the type of ATTR or TABLE. Other types such as NODE, EDGE and PATH are not supported. <a href="https://www.ultipa.com/docs/uql/data-types#Returned-Data">Learn more about the types of returned data</a>

Example: Read data in the graphset *Test* returned by a UQL statement

<p tit= "Scala" ></p>

```scala
import org.apache.spark.sql.{SaveMode, SparkSession}

val spark = SparkSession.builder().getOrCreate()

val df = spark.read.format("com.ultipa.spark.DataSource")
  .option("hosts","192.168.1.56:63940,192.168.1.57:63940,192.168.1.58:63940")
  .option("auth.username","root")
  .option("auth.password","root")
  .option("graph","Test")
  .option("query","find().nodes() as n return n.name, n.gender")
  .load()

df.show()
```

Result:

| n.name | n.gender |
| -- | -- |
| Alice | female |
| Bruce | male |
| Joe | male |

## Writing

You can write a Spark DataFrame into Ultipa as either nodes or edges belonging to a single schema. Each column within the DataFrame will be mapped as a property of the nodes or edges, with the column name serving as the property name (except for the `_id` of nodes, and the `_from`/`_to` of edges). Non-existent properties will be created during the writing process.

The data type of each property is determined by the data type of the corresponding column within the DataFrame. Refer to the <a href="#Data-Type-Conversion">Data Type Conversion</a> table for details.

### Write by Node Schema

Example: Write a DataFrame to the *Person* nodes in the graphset *Test*

<p tit= "Scala" ></p>

```scala
import org.apache.spark.sql.{SaveMode, SparkSession}

val spark = SparkSession.builder().getOrCreate()

val data = Seq(("Alice", "Teacher", 25, 1.11), ("Bob", "Worker", 30, 2.22), ("Charlie", "Officer", 35, 3.33))

val df = spark.createDataFrame(data).toDF("name", "job", "age", "income")
df.show()

df.write.format("com.ultipa.spark.DataSource")
  .option("hosts","192.168.1.56:63940,192.168.1.57:63940,192.168.1.58:63940")
  .option("auth.username","root")
  .option("auth.password","root")
  .option("graph","Test")
  .option("nodes", "Person")
  .option("nodes.id", "name")
  .save()
```

### Write by Edge Schema

Example: Write a DataFrame to the *RelatesTo* edges in the graphset *Test*

<p tit= "Scala" ></p>

```scala
import org.apache.spark.sql.{SaveMode, SparkSession}

val spark = SparkSession.builder().getOrCreate()

val data = Seq(("Alice", "Bob", "couple"), ("Bob", "Charlie", "couple"), ("Charlie", "Alice", "friend"))

val df = spark.createDataFrame(data).toDF("from", "to", "type")
df.show()

df.write.format("com.ultipa.spark.DataSource")
  .option("hosts","192.168.1.56:63940,192.168.1.57:63940,192.168.1.58:63940")
  .option("auth.username","root")
  .option("auth.password","root")
  .option("graph","Test")
  .option("edges", "RelatesTo")
  .option("edges.from", "from")
  .option("edges.to", "to")
  .save()
```

## Configurations

### Options

In the Spark API, both the `DataFrameReader` and `DataFrameWriter` classes contain the `option()` method, which you can use to specify options for read and write operation. 

Below are all the options supported in Ultipa Spark Connector:

**General Options**

| <div table-width=30>Option Key</div> | <div table-width=8>Default</div> | Description | <div table-width=10>Optional</div> |
| -- | -- | -- | -- |
| hosts | | IP address(es) of the Ultipa server or cluster (comma-separated), or the host URL (excluding  "https://" or "http://") | No |
| auth.username | | Username of the host | No |
| auth.password | | Password of the above user | No |
| graph | default | Name of the graphset you want to connect | Yes |
| connection.timeout | 15 | Timeout threshold for requests (in seconds) | Yes |
| connection.connect.timeout | 2000 | Timeout threshold for connection (in milliseconds); each host will be attempted 3 times by default | Yes |
| connection.heartbeat | 10000 | Heartbeat milliseconds for all instances, set 0 to turn off heartbeat | Yes |
| connection.max.recv.size | 41943040 | Maximum bytes of the received data | Yes |

**Read Options**

| <div table-width=18>Option Key</div> | <div table-width=8>Default</div> | Description | <div table-width=10>Optional</div> |
| -- | -- | -- | -- |
| nodes | | Name of a node schema | Yes |
| edges | | Name of an edge schema | Yes |
| query | | UQL query statement to read data | Yes |

**Write Options**

| <div table-width=18>Option Key</div> | <div table-width=8>Default</div> | Description | <div table-width=10>Optional</div> |
| -- | -- | -- | -- |
| nodes | | Name of a node schema; if the specified schema does not exist, it will be created during write | Yes |
| nodes.id | | Name of the column in the DataFrame to be as the `_id` of the nodes | Yes |
| edges | | Name of an edge schema; if the specified schema does not exist, it will be created during write | Yes |
| edges.from | | Name of the column in the DataFrame to be as the `_from` of the edges | Yes |
| edges.to | | Name of the column in the DataFrame to be as the `_to` of the edges | Yes |

### Global Configurations

You can set the options for each connection, or specify global configurations in the Spark Session to avoid retyping the options each time. To do so, you can prepend the option key with `ultipa.` in the `config()` method.

Example: set global configurations for options `hosts`, `auth.username`, `auth.password`, `graph` and `connection.timeout`

<p tit= "Scala" ></p>

```scala
import org.apache.spark.sql.{SaveMode, SparkSession}

val spark = SparkSession.builder()
  .config("ultipa.hosts", "192.168.1.56:63940,192.168.1.57:63940,192.168.1.58:63940")
  .config("ultipa.auth.username","root")
  .config("ultipa.auth.password","root")
  .config("ultipa.graph", "Test")
  .config("ultipa.connection.timeout", 600)
  .getOrCreate()

val dfPerson = spark.read.format("com.ultipa.spark.DataSource")
  .option("nodes", "Person")
  .load()
```

## Data Type Conversion

| Ultipa Property Type | Spark Data Type |
| -- | -- |
| `_id`, `_from`, `_to` | `StringType` |
| `_uuid`, `_from_uuid`, `_to_uuid` | `LongType` |
| `int32` | `IntegerType` |
| `uint32` | `LongType` |
| `int64` | `LongType` |
| `uint64` | `StringType` |
| `float` | `FloatType` |
| `double` | `DoubleType` |
| `decimal` |  |
| `string` | `StringType` |
| `text` |  |
| `datetime` | `TimestampType` |
| `timestamp` | `TimestampType` |
| `point` |  |
| `blob` | `BinaryType` |
| `list` |  |
| `set` |  |
| `ignore` | `NullType` |
| `UNSET` | `NullType` |
| _ | `StringType` |
