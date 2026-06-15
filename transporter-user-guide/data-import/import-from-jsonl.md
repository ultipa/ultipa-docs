# Import from JSONL

This page demonstrates the process of importing data from JSONL file(s) into a graph in Ultipa.

<center><img width="800" src="https://img.ultipa.cn/img/2025-03-05-16-52-46-jsonl.png"></center>

> The following steps are demonstrated using PowerShell (Windows).

## Prepare JSONL Files

Click to download the example JSONL files:

- <a href="https://img.ultipa.cn/img/2025-03-04-15-26-10-customer.jsonl
">customer.jsonl</a>
- <a href="https://img.ultipa.cn/img/2025-03-04-15-25-44-merchant.jsonl
">merchant.jsonl</a>
- <a href="
https://img.ultipa.cn/img/2025-03-04-15-26-24-transaction.jsonl
">transaction.jsonl</a>

You can place all the files in the same folder as `ultipa-importer`.

## Generate the Configuration File

Open the terminal program and navigate to the folder containing `ultipa-importer`. Then, run the following command and select `jsonl` to generate a sample configuration file for JSONL:

```bash
./ultipa-importer --sample
```

<center><img style="margin-top:0;" src="https://img.ultipa.cn/img/2025-03-04-15-44-00-jsonl-sample.jpg"></center>

A file named `import.sample.jsonl.yml` will be generated in the same directory as `ultipa-importer`. If the file already exists, it will be overwritten.

## Modify the Configuration File

Customize the `import.sample.jsonl.yml` configuration file based on your specific requirements. It includes the following sections:

- `mode`: Set to `jsonl`.
- `server`: Provide your Ultipa server details and specify the target graph (new or existing) for data import.
- `sftp`: Configure the SFTP server where your JSONL files are stored. If the files are on your local machine, remove this section or leave it blank.
- `nodeConfig`: Define node schemas, where each schema corresponds to a JSONL file. Columns in the file are mapped to node properties.
- `edgeConfig`: Define edge schemas, where each schema corresponds to a JSONL file. Columns in the file are mapped to edge properties.
- `settings`: Set global import preferences and parameters.

<p tit= "import.sample.jsonl.yml"></p>

```yml
# Mode options: csv/json/jsonl/rdf/graphml/bigQuery/sql/kafka/neo4j/salesforce
mode: jsonl

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

# SFTP server configurations
# If the files are on your local machine, remove this section or leave it blank
sftp:
  # Host IP/URI and port
  host:
  username:
  password:
  # SSH Key path for SFTP (if set, password will not be used)
  key:

# Node configurations
nodeConfig:
    # Specify a schema
  - schema: "Customer"
    # The file path on local machine or SFTP
    file: "./customer.jsonl"
    # properties: Map columns in file to properties; if unset, all columns will be automatically mapped
    ## name: A key identifier in the JSON file
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
    file: "./merchant.jsonl"
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
    file: "./transaction.jsonl"
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
./ultipa-importer --config import.sample.jsonl.yml
```

<center><img style="margin-top:0;" src="https://img.ultipa.cn/img/2025-03-04-15-46-12-jsonl-import.png"></center>
