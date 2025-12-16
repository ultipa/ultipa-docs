# Import RDF

Acquire data from RDF file(s) and import into Ultipa graphset.

## 1. Generate sample configuration file

Execute the following command in your command line tool. 

<p tit= "Terminal" ></p> 

```bash
./ultipa-importer --sample
```

The `import.sample.rdf.yml` file will be generated in the same directory as `ultipa-importer.exe`. If a `import.sample.rdf.yml` file already exists in that directory, it will be overwritten.

## 2. Modify configuration file

The configuration file consists of three parts. Modify the configuration file according to your needs.

<p tit= "import.sample.rdf.yml" type="yaml"></p>

```yml
# Supported source type: csv/json/jsonl/rdf/bigQuery/sql/kafka/neo4j/salesforce; Only one mode can be used at a time
# SQL support: PostgreSQL/MySQL/SQLServer/Snowflake/Oracle
mode: rdf 

# rdf settings (when mode is rdf)
rdf:
  # File name for rdf source
  file: "./test_data/account.ttl"
  # rdf format (supports: "ntriples", "turtle", "rdfxml")
  format: "turtle"

# Ultipa server configurations
server:
  # Host Address or URI: Port
  host: "192.168.1.xx:60061"
  # Username
  username: "root"
  # Password
  password: "root"
  # Target graphset
  graphset: "graphName"
  # TLS Certificate file (Crt) path
  crt: ""

# Other settings
settings:
  # Log output folder path
  logPath: "./logs"
  # Number of nodes or edges to insert per batch
  batchSize: 10000
  # Import mode: overwrite, insert, or upsert
  importMode: upsert
  # Whether to create node if it does not exist when inserting edges
  createNodeIfNotExist: false
  # Whether to stop process if an error occurs
  stopWhenError: false
  # Maximum number of threads (suggested: 32)
  threads: 32
  # Maximum RPC message size in MB (default: 40MB)
  maxPacketSize: 40
  # timeZone or timeZone offset (format: +/-HHMM, e.g., +0800)
  # Default timeZone: "+0800"
  # Timestamp data unit, supports "ms" or "s" (default: "s")
  timestampUnit: "s"
```

### RDF settings

| Field | Type | <div table-width=70>Description</div> | 
| --- | --- | --- | 
| `file` | String | Path of the RDF file to be imported. Multiple files are allowed to be speicified.| 
| `format` | String | Supported formats include `ntriples`, `turtle` and `rdfxml`, corresponding to RDF file extensions `.ntl`, `.ttl` and `.xml`, respectively. Ensure the format you specify matches the RDF file to be imported. Otherwise, errors may occur during parsing. |
> To specify multiple files, configure in the following way:
<p tit= "Configuration for multiple files.yml" type="yaml"></p>

 ```yml
- file: "./test_data/file1.ttl"
   format: "turtle"
- file: "./test_data/file2.ntl"
   format: "ntriples"
``` 

### Ultipa server configuration

| <div table-width=15>Field</div> |  <div table-width=10>Type</div> | <div table-width=80>Description</div> | 
| --- | --- | --- | 
| `host` | String | IP address or URL of the source database; in case of a cluster, only one server node needs to be specified. | 
| `username` | String | Database username. | 
| `password` | String | Password of the above user. | 
| `graphset` | String | Name of the target graphset for RDF file import. If the specified graphset does not exist, it will be created automatically. | 
| `crt` | String |  Path to the certificate (CRT) file used for TLS encryption. | 

### Other settings

|  <div table-width=20>Field</div> | <div table-width=15>Type</div> |  <div table-width=15>Default</div> | <div table-width=70>Description</div> | 
| --- | --- | --- | --- |
| `logPath` | String | "./logs" | Folder path of the log output. | 
| `batchSize` | Integer | 10000 | Number of nodes or edges to insert per batch. | 
| `importMode` |String | upsert | Specifies how the data is inserted into the graph, including `overwrite`, `insert` and `upsert`. When updating nodes or edges, use the `upsert` mode to prevent overwriting existing data.  | 
| `createNodeIfNotExist` | Bool | false | If true, the system automatically creates nodes that do not exist when inserting edges. | 
| `stopWhenError` | Bool | false | If true, the import process stops when an error occurs. | 
| `threads` | Integer | 32 | The maximum number of threads. 32 is suggested. |
| `maxPacketSize` | Integer | 40 | The maximum size of data packets in MB that can be sent or received. |
| `timestampUnit` | String | s | The unit of measurement for timestamp data. Supported units are `ms` (milliseconds) and `s` (seconds). |

## 3. Execute import

The import process uses the <a href="#Prepare-the-Configuration-File">configuration file</a> specified by the `-config` parameter to import RDF data into the target server and display it in the Ultipa graph structure.

<p tit= "Terminal" ></p> 

```bash
./ultipa-importer --config import.sample.rdf.yml
```

## 4. Mapping rules and import example in Ultipa Graph

### Mapping rules in Ultipa graph

- Subjects are mapped to nodes.
- Predicates are mapped:
	- To node property names when the objects are literals.
	- To edges when the objects act as subjects in other triples. 
- Objects are mapped to property values if they are not subjects in other triples.
- Node schemas are set according to the subject prefix, with the following considerations:
	- Blank subjects, treated as blank nodes, are inserted into the "default" schema. 
    - Subject without a prefix are assigned schema names starting from `ns0`, with subsequent schemas incrementing sequentially (e.g., `ns1`, `ns2`, etc.).
- Edge schemas are set according to the predicate prefix.
- If the schema name is shorter than 2 characters, the system will duplicate it for schema creation (e.g., the schema 'a' is duplicated as 'aa').

### Import example

In this example, an RDF file in the format of `.ttl` is imported.

<p tit= "UltipaGraph.ttl"></p> 

```bash
@prefix ultipaVoc: <http://ultipa.com/vocab/sw#> .
@prefix ultipaInd: <http://ultipa.com/ind#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
@prefix ex: <http://example.org/> .

ultipaInd:pythonSDK ultipaVoc:name "SDK" ;
         a ultipaVoc:UltipaTool ;
         ultipaVoc:version "4.3.0.1" ;
         ultipaVoc:releaseDate "2023-03-06" ;
         ultipaVoc:runsOn ultipaInd:UltipaGraph432 .

ultipaInd:transporter233 ultipaVoc:name "Transporter" ;
         a ultipaVoc:UltipaTool ;
         ultipaVoc:version "4.3.1" ;
         ultipaVoc:releaseDate "2023-07-20" ;
         ultipaVoc:runsOn ultipaInd:UltipaGraph432 .

ultipaInd:manager3028 ultipaVoc:name "UltipaManager" ;
         a ultipaVoc:UltipaTool ;
         ultipaVoc:version "4.3.0.2" ;
         ultipaVoc:releaseDate "2023-05-29" ;
         ultipaVoc:runsOn ultipaInd:UltipaGraph432 .

ultipaInd:UltipaGraph432 ultipaVoc:name "UltipaGraph" ;
         a ultipaVoc:GraphPlatform , ultipaVoc:InspiringPlatform ;
         ultipaVoc:version "4.3.2" .

# Normal nodes
ex:subject1 ex:predicate1 "normal string literal" .
ex:subject2 ex:predicate2 "another string literal" .

# Blank nodes
_:blankNode1 ex:predicate3 "string literal for blank node" .
ex:subject3 ex:predicate4 _:blankNode2 .

# Literals
ex:subject4 ex:predicate5 "365"^^xsd:integer .
ex:subject5 ex:predicate6 "true"^^xsd:boolean .
ex:subject6 ex:predicate7 "3.14"^^xsd:float .
ex:subject7 ex:predicate8 "2024-08-21T00:00:00Z"^^xsd:dateTime .
```

<center><img width="800" src="https://img.ultipa.cn/img/2024-10-17-15-56-35-All-paths-and-nodes.png "></center>
<center><i>From RDF to Ultipa</i></center>

## Export CSV

Export CSV files (without header) from Ultipa graphset <i>shareholding</i> to folder <i>exportData</i> located in SFTP or local directory:

<center><img width="800" src="https://img.ultipa.cn/img/2023-12-12-14-48-34-ultipa-csv.png"></center>
<center><i>From Ultipa to CSV</i></center>

## 1. Generate sample configuration file

<p run-tag="false" graph="" tit= "Terminal" ></p>

```bash
./ultipa-exporter --sample
```

## 2. Modify configuration file

<p tit= "export.sample.yml" type="yaml"></p>
