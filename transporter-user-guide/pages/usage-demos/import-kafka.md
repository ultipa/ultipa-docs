# Import Kafka

Acquire data from Kafka streams <i>entity_1</i>, <i>entity_3</i> and <i>relation_holding</i>, import into Ultipa graphset <i>shareholding</i>:

<center><img width="800" src="https://img.ultipa.cn/img/2023-12-12-11-30-17-kafka.png"></center>
<center><i>From Kafka to Ultipa</i></center>

## 1. Generate sample configuration file

<p tit="Terminal">

```bash
./ultipa-importer --sample
```

## 2. Modify configuration file

<p tit="import.sample.kafka.yml" type="yaml"></p>

```yml
# Configure data source type
mode: kafka

# Configure data source information
kafka:
  host: "192.168.1.1:5432"

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
    topic: "entity_1"
    offset: newest
    properties:
      - name: id
        type: _id
      - name: name
        type: string
      - name: type
        type: _ignore
  - schema: "firm"
    topic: "entity_3"
    offset: newest
    properties:
      - name: id
        type: _id
      - name: name
        type: string
      - name: type
        type: _ignore

# Configure edge data
edgeConfig:
  - schema: "hold"
    topic: "relation_holding"
    offset: newest
    properties:
      - name: from
        type: _from
      - name: to
        type: _to
      - name: shareInt
        type: int32
        new_name: share
      - name: type
        type: _ignore
        
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
./ultipa-importer --config ./import.sample.kafka.yml
```
