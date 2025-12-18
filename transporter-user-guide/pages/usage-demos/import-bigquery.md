# Import BigQuery

Acquire data from tables <i>entity</i> and <i>relation</i> in BigQuery project <i>transporter-demo-388303</i>, import into Ultipa graphset <i>shareholding</i>:

<center><img width="800" src="https://img.ultipa.cn/img/2023-12-11-16-13-39-bigquery.png"></center>
<center><i>From BigQuery to Ultipa</i></center>

## 1. Generate sample configuration file

<p run-tag="false" graph="" tit= "Terminal" ></p>

```bash
./ultipa-importer --sample
```

## 2. Modify configuration file

<p tit="import.sample.bigQuery.yml" type="yaml"></p>

```yml
# Configure data source type
mode: bigQuery

bigQuery:
  # string of project id on BigQuery
  projectID: "transporter-demo-388303"	
  # the json file that stores KEY of Service Account used to access the project on BigQuery
  cert: "./transporter-demo-388303-fe9e5800c1b8.json"

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

<p run-tag="false" graph="" tit= "Terminal" ></p>

```bash
./ultipa-importer --config ./import.sample.bigQuery.yml
```

> `projectID`: Create BigQuery project in Google Cloud and acquire project ID<br><center><img src="https://img.ultipa.cn/img/2023-05-30-12-25-57-projectid.png"></center><br>`cert`: Create Service Account with <b>BigQuery Admin</b> privilege and generate KEY in <b>JSON</b> format<br><center><img src="https://img.ultipa.cn/img/2023-05-30-18-28-31-admin.png"><img src="https://img.ultipa.cn/img/2023-05-30-12-25-53-cert.png"></center>
