# Import CSV

## Header without Type

Read node files <i>person.csv</i> and <i>company.csv</i> and edge file <i>holding.csv</i> from SFTP or local directory, import into Ultipa graphset <i>shareholding</i>:

<center><img width="800" src="https://img.ultipa.cn/img/2023-12-14-10-25-03-csv-header.png"></center>
<center><i>From CSV (Header w/o Type) to Ultipa</i></center>

### 1. Generate sample configuration file

<p run-tag="false" graph="" tit= "Terminal" ></p>

```bash
./ultipa-importer --sample
```

### 2. Modify configuration file

<p tit= "import.sample.csv.yml" type="yaml"></p>

```yml
# Configure data source type
mode: csv

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
    file: /Data/person.csv
    head: true
    properties:
      - name: id
        type: _id
      - name: name
        type: string
      - name: type
        type: _ignore
  - schema: "firm"
    file: /Data/company.csv
    head: true
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
    file: /Data/holding.csv
    head: true
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

### 3. Execute import

<p run-tag="false" graph="" tit= "Terminal" ></p>

```bash
./ultipa-importer --config ./import.sample.csv.yml
```

## Header with Type

Read node files <i>person.csv</i> and <i>company.csv</i> and edge file <i>holding.csv</i> from SFTP or local directory, import into Ultipa graphset <i>shareholding</i>:

<center><img width="800" src="https://img.ultipa.cn/img/2023-12-14-10-25-08-csv-header-type.png"></center>
<center><i>From CSV (Header with Type) to Ultipa</i></center>

### 1. Generate sample configuration file

<p run-tag="false" graph="" tit= "Terminal" ></p>

```bash
./ultipa-importer --sample
```

### 2. Modify configuration file

<p tit= "import.sample.csv.yml" type="yaml"></p>

```yml
# Configure data source type
mode: csv

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
    file: /Data/person.csv
    head: true
    properties:
      - name: type
        type: _ignore
  - schema: "firm"
    file: /Data/company.csv
    head: true
    properties:
      - name: type
        type: _ignore
        
# Configure edge data
edgeConfig:
  - schema: "hold"
    file: /Data/holding.csv
    head: true
        
# Configure global settings
settings:
  batchSize: 10000
  importMode: insert
  # auto-create graph, schema, and properties if not existent
  yes: true
```

### 3. Execute import

<p run-tag="false" graph="" tit= "Terminal" ></p>

```bash
./ultipa-importer --config ./import.sample.csv.yml
```

## Headerless

Read node files <i>person.csv</i> and <i>company.csv</i> and edge file <i>holding.csv</i> from SFTP or local directory, import into Ultipa graphset <i>shareholding</i>:

<center><img width="800" src="https://img.ultipa.cn/img/2023-12-14-10-25-14-csv.png"></center>
<center><i>From CSV (Headerless) to Ultipa</i></center>

### 1. Generate sample configuration file

<p run-tag="false" graph="" tit= "Terminal" ></p>

```bash
./ultipa-importer --sample
```

### 2. Modify configuration file

<p tit= "import.sample.csv.yml" type="yaml"></p>

```yml
# Configure data source type
mode: csv

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
    file: /Data/person.csv
    head: false
    properties:
      - name: _id
        type: _id
      - name: name
        type: string
      - name: _ignore
        type: _ignore
  - schema: "firm"
    file: /Data/company.csv
    head: false
    properties:
      - name: _id
        type: _id
      - name: name
        type: string
      - name: _ignore
        type: _ignore
        
# Configure edge data
edgeConfig:
  - schema: "hold"
    file: /Data/holding.csv
    head: false
    properties:
      - name: _from
        type: _from
      - name: _to
        type: _to
      - name: share
        type: int32
        
# Configure global settings
settings:
  batchSize: 10000
  importMode: insert
  # auto-create graph, schema, and properties if not existent
  yes: true
```

### 3. Execute import

<p run-tag="false" graph="" tit= "Terminal" ></p>

```bash
./ultipa-importer --config ./import.sample.csv.yml
```

## Folder

Read CSV files in SFTP or local directory, import into Ultipa graphset <i>shareholding</i>. Individual configuration of file is not supported, use name of target schemas to name the files, and use the name and type of target properties to describe headers:

<center><img width="800" src="https://img.ultipa.cn/img/2023-12-14-10-25-19-csv-folder.png"></center>
<center><i>From CSV (Folder) to Ultipa</i></center>

### 1. Generate sample configuration file

<p run-tag="false" graph="" tit= "Terminal" ></p>

```bash
./ultipa-importer --sample
```

### 2. Modify configuration file

<p tit= "import.sample.csv.yml" type="yaml"></p>

```yml
# Configure data source type
mode: csv

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
  - dir: /Data/importData
        
# Configure edge data
edgeConfig:
  - dir: /Data/importData
        
# Configure global settings
settings:
  batchSize: 10000
  importMode: insert
  # auto-create graph, schema, and properties if not existent
  yes: true
```

### 3. Execute import

<p run-tag="false" graph="" tit= "Terminal" ></p>

```bash
./ultipa-importer --config ./import.sample.csv.yml
```
