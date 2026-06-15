# Import from Kafka

This page demonstrates the process of importing data from Kafka topic(s) into a graph in Ultipa.

<center><img width="800" src="https://img.ultipa.cn/img/2025-03-06-11-48-10-kafka.png"></center>

> The following steps are demonstrated using PowerShell (Windows).

## Generate the Configuration File

Open the terminal program and navigate to the folder containing `ultipa-importer`. Then, run the following command and select `kafka` to generate a sample configuration file for Kafka topics:

```bash
./ultipa-importer --sample
```

<center><img style="margin-top:0;" src="https://img.ultipa.cn/img/2025-03-06-11-48-21-kafka-sample.jpg"></center>

A file named `import.sample.kafka.yml` will be generated in the same directory as `ultipa-importer`. If the file already exists, it will be overwritten.

## Modify the Configuration File

Customize the `import.sample.kafka.yml` configuration file based on your specific requirements. It includes the following sections:

- `mode`: Set to `kafka`.
- `kafka`: Configure the Kafka host address or URI for connection.
- `server`: Provide your Ultipa server details and specify the target graph (new or existing) for data import.
- `nodeConfig`: Define node schemas, where each schema corresponds to a topic. All columns are mapped to node properties sequentially.
- `edgeConfig`: Define edge schemas, where each schema corresponds to a topic. All columns are mapped to edge properties sequentially.
- `settings`: Set global import preferences and parameters.

<p tit= "import.sample.kafka.yml"></p>

```yml
# Mode options: csv/json/jsonl/rdf/graphml/bigQuery/sql/kafka/neo4j/salesforce
mode: kafka

# Kafka host configurations
kafka:
  # Host IP/URI and port
  host: "192.168.1.23:4567"

# Ultipa server configurations
server:
  # Host IP/URI and port; if it's a cluster, separate multiple hosts with commas
  host: "10.11.22.33:1234"
  username: "admin"
  password: "admin12345"
  # The new or existing graph for data import
  graphset: "myGraph"
  # If the above graph is new, specify the shards where the graph will be stored
  shards: "1,2,3"
  # If the above graph is new, specify the partition function (Crc32/Crc64WE/Crc64XZ/CityHash64) used for sharding
  partitionBy: "Crc32"
  # Path of the certificate file for TLS encryption
  crt: ""

# Node configurations
nodeConfig:
    # Specify the schema
  - schema: "Customer"
  # Specify the topic from which messages will be consumed
    topic: "customer"
    # offset: Specify where to start consuming messages in a Kafka topic partition
    # Options include:
    ## - newest: Start from the latest message
    ## - oldest(default): Start from the earliest message
    ## - index: Start from a specific offset
    ## - time: Start from a specific timestamp. Format: yyyy-mm-dd hh:mm:ss (local time) or yyyy-mm-dd hh:mm:ss -7000 (with time zone offset)
    # For large kafka topics, it is more efficient to use newest, oldest or a specified index than a timestamp
    offset: oldest
    # properties: Map kafka messages to properties; if unset, all columns are mapped sequentially
    ## name: The property name
    ## new_name: The property name; it defaults to the name above; if the type is _id/_from/_to, the property name is automatically set to _id/_from/_to
    ## type: The property value type; set to _id, _from, _to, or other supported value types like int64, float, string, etc; set to _ignore to skip importing the column
    ## prefix: Add a prefix to the values of a property; only apply to _id, _from, and _to; if a prefix is added to an _id, the same prefix must be applied to the corresponding _from and _to
    properties:
      - name: cust_no
        type: _id
        prefix:
      - name: name
        new_name:
        type: string
      - name: level
        new_name:
        type: int32
  - schema: "Merchant"
    topic: "merchant"
    offset: oldest
    properties:
      - name: merch_no
        type: _id
        prefix:
      - name: name
        new_name:
        type: string
      - name: type
        new_name:
        type: string

# Edge configurations
edgeConfig:
  - schema: "Transfers"
    topic: "transaction"
    offset: oldest
    # _from and _to types are necessary for edges
    properties:
      - name: trans_no
        new_name:
        type: string
      - name: cust_no
        type: _from
        prefix:
      - name: merch_no
        type: _to
        prefix:
      - name: time
        new_name:
        type: datetime

# Global settings
settings:
  # Path of the log file
  logPath: "./logs"
  # Number of rows included in each insertion batch
  batchSize: 10000
  # Import mode: insert/overwrite/upsert
  importMode: insert
  # Stops the importing process when error occurs
  stopWhenError: false
  # Set to true to automatically create new graph, schemas and properties
  yes: true
  # The maximum threads
  threads: 32
  # The maximum size (in MB) of each packet
  maxPacketSize: 40
  # Timezone for the timestamp values
  # timeZone: "+0200"
  # Timestamp value unit, support ms/s
  timestampUnit: s
```

## Execute Import

Execute the import by specifying the configuration file using the `--config` flag:

```bash
./ultipa-importer --config import.sample.kafka.yml
```

<center><img style="margin-top:0;" src="https://img.ultipa.cn/img/2025-03-06-11-48-41-kafka-import.png"></center>
