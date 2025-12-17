# Export CSV

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

```yml
# Configure the SFTP where to store the exported files, or store in a local direcotry by default
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
    properties:
      - name: name
  - schema: "firm"

# Configure edge data
edgeConfig:
  - schema: "hold"
    properties:
      - name: share
        
# Configure global settings
settings:
  writeHeader: true
  outpath: /Data/exportData
```

## 3. Execute export

<p run-tag="false" graph="" tit= "Terminal" ></p>

```bash
./ultipa-exporter --config ./export.sample.yml
```