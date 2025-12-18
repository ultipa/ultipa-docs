# Import JSONL

Read node files <i>person.jsonl</i> and <i>company.jsonl</i> and edge file <i>holding.jsonl</i> from SFTP or local directory, import into Ultipa graphset <i>shareholding</i>:

<center><img width="800" src="https://img.ultipa.cn/img/2023-12-12-18-16-16-json.png"></center>
<center><i>From JSONL to Ultipa</i></center>

## 1. Generate sample configuration file

<p run-tag="false" graph="" tit= "Terminal" ></p>

```bash
./ultipa-importer --sample
```

## 2. Modify configuration file

<p tit="import.sample.json.yml" type="yaml"></p>

```yml
# Configure data source type
mode: jsonl

# Configure SFTP information where the files locate, or read from a local direcotry by default
sftp:
  host: 10.132.3.136:22
  username: admin
  password: abcd1234
  # Path of key, configuring this will ignore the 'username' and 'password'
  key:  ./my_secret

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
    file: /Data/person.jsonl
    properties:
      - name: id
        type: _id
      - name: name
        type: string
      - name: type
        type: _ignore
  - schema: "firm"
    file: /Data/company.jsonl
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
    file: /Data/holding.jsonl
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
./ultipa-importer --config ./import.sample.jsonl.yml
```
