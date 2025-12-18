# Import MySQL

Acquire data from tables <i>entity</i> and <i>relation</i> in MySQL database <i>test</i>, import into Ultipa graphset <i>shareholding</i>:

<center><img width="800" src="https://img.ultipa.cn/img/2023-12-11-16-13-23-mysql.png"></center>
<center><i>From MySQL to Ultipa</i></center>

## 1. Generate sample configuration file

<p tit="Terminal">

```bash
./ultipa-importer --sample
```

## 2. Modify configuration file

<p tit="import.sample.mysql.yml" type="yaml"></p>

```yml
# Configure data source type
mode: mysql

# Configure data source information
sqlDatabase:
  host: "192.168.1.1"
  port: "5432"
  dbname: "test"
  username: "admin"
  password: "abcd1234"

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
    sql: "select id, name from entity where type = 1"
    properties:
      - name: id
        type: _id
      - name: name
        type: string
  - schema: "firm"
    sql: "select id, name from entity where type = 3"
    properties:
      - name: id
        type: _id
      - name: name
        type: string

# Configure edge data
edgeConfig:
  - schema: "hold"
    sql: "select from, to, shareInt from relation where type = 'holding'"
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
./ultipa-importer --config ./import.sample.mysql.yml
```


