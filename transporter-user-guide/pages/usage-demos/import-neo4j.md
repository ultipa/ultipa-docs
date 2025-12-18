# Import Neo4j

Acquire data with labels <i>person</i>, <i>company</i> and <i>holding</i> in Neo4j database <i>test</i>, import into Ultipa graphset <i>shareholding</i>:

<center><img width="800" src="https://img.ultipa.cn/img/2023-12-12-09-37-13-neo4j.png"></center>
<center><i>From Neo4j to Ultipa</i></center>

## 1. Generate sample configuration file

<p tit="Terminal">

```bash
./ultipa-importer --sample
```

## 2. Modify configuration file

<p tit="import.sample.neo4j.yml"></p>

```yml
# Configure data source type
mode: neo4j

# Configure data source information
neo4j:
  host: "192.168.1.1:5432"
  username: "admin"
  password: "abcd1234"
  database: "test"

# Configure Ultipa server
server:
  # Ultipa server, use comma ',' to separate multiple server nodes of cluster
  host: "192.168.2.149:60075"
  username: "admin"
  password: "abcd1234"
  # Graphset name, or use graphset 'default' by default
  graphset: "shareholding"
  # The directory of the SSL certificate when both Ultipa server and client-end are in SSL mode
  crt: ""

# Configure node data
nodeConfig:
  - schema: "human"
    label: "person"
    where: n.type = 1
    properties:
      - name: id
        type: _id
      - name: name
        type: string
  - schema: "firm"
    label: "company"
    where: n.type = 3
    properties:
      - name: id
        type: _id
      - name: name
        type: string

# Configure edge data
edgeConfig:
  - schema: "hold"
    relationship: "holding"
    where: NOT n:obsolete
    properties:
      - name: from
        type: _from
      - name: to
        type: _to
      - name: shareInt
        type: int32
        new_name: share
        
# Configure global settings
settings:
  batchSize: 10000
  importMode: insert
  # auto-create graph, schema, and properties if not existent
  yes: true
```

## 3. Execute import

<p tit="Terminal">

```bash
./ultipa-importer --config ./import.sample.neo4j.yml
```

> In case auto-increment IDs (identity) in Neo4j are to be imported as node IDs in Ultipa, replace `id`, `from` and `to` in the above yml file with `<id>`, `<start>` and `<end>`.
