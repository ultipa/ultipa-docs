# Import from Neo4j

This page demonstrates the process of importing data from a Neo4j database into a graph in Ultipa.

<center><img width="800" src="https://img.ultipa.cn/img/2025-03-05-11-35-23-neo4j.png"></center>

> The following steps are demonstrated using PowerShell (Windows).

## Generate the Configuration File

Open the terminal program and navigate to the folder containing `ultipa-importer`. Then, run the following command and select `neo4j` to generate a sample configuration file for Neo4j:

```bash
./ultipa-importer --sample
```

<center><img style="margin-top:0;" src="https://img.ultipa.cn/img/2025-03-05-11-36-46-neo4j-sample.png"></center>

A file named `import.sample.neo4j.yml` will be generated in the same directory as `ultipa-importer`. If the file already exists, it will be overwritten.

## Modify the Configuration File

Customize the `import.sample.neo4j.yml` configuration file based on your specific requirements. It includes the following sections:

- `mode`: Set to `neo4j`.
- `neo4j`: Configure the connection to your Neo4j database.
- `server`: Provide your Ultipa server details and specify the target graph (new or existing) for data import.
- `nodeConfig`: Define node schemas, where each schema corresponds to a label. Columns in the query results are mapped to node properties.
- `edgeConfig`: Define edge schemas, where each schema corresponds to a relationship. Columns in the query results are mapped to edge properties.
- `settings`: Set global import preferences and parameters.

<p tit= "import.sample.neo4j.yml"></p>

```yml
# Mode options: csv/json/jsonl/rdf/graphml/bigQuery/sql/kafka/neo4j/salesforce
mode: neo4j

# Neo4j server configurations
neo4j:
  # Host Address or URI, "neo4j://xxx:" or "neo4j+s://xxx"
  host: "neo4j+s://123xxx.databases.neo4j.io"
  username: "user123"
  password: "password123"
  # Database name
  database: "trading"

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
    # Specify a node label in Neo4j
    label: "customer"
    # Set a condition (if needed) to query nodes using the variable 'n'
    where: n.level > 0
    # Set a limit (if needed) to restrict returned records
    limit:
    # properties: Map properties of nodes/edges in Neo4j to properties of nodes/edges in Ultipa
    ## name: The field name in Neo4j database;, which serves as the property name in Ultipa; to use Neo4j's identity, start, or end properties, set the name as <id>, <start>, or <end>
    ## new_name: The property name; it defaults to the name above; if the type is _id/_from/_to, the property name is automatically set to _id/_from/_to
    ## type: The property value type; set to _id, _from, _to, or other supported value types like int64, float, string, etc; set to _ignore to skip importing the column
    ## prefix: Add a prefix to the values of a property; only apply to _id, _from, and _to; if a prefix is added to an _id, the same prefix must be applied to the corresponding _from and _to
    properties:
      - name: <id>
        type: _id
        prefix:
      - name: cust_no
        new_name:
        type: string
      - name: name
        new_name:
        type: string
      - name: level
        new_name:
        type: int32
  - schema: "Merchant"
    label: "merchant"
    properties:
      - name : <id>
        type: _id
        prefix:
      - name: merch_no
        new_name:
        type: string
      - name: name
        new_name:
        type: string
      - name: type
        new_name:
        type: string

# Edge configurations
edgeConfig:
  - schema: "Transfers"
    # Specify a relationship type in Neo4j
    relationship: "transfers"
    # Set a condition (if needed) to query relationships using the variable 'r'
    where:
    # _from and _to types are necessary for edges
    properties:
      - name: <start>
        type: _from
        prefix:
      - name: <end>
        type: _to
        prefix:
      - name: trans_no
        new_name:
        type: string
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
./ultipa-importer --config import.sample.neo4j.yml
```

<center><img style="margin-top:0;" src="https://img.ultipa.cn/img/2025-03-05-11-36-49-neo4j-import.png"></center>
