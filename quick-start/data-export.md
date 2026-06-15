# Data Export

> This section explains how to export data from Ultipa Graph via Ultipa Manager and Ultipa Transporter-Exporter.

## Export data via Manager

Manager can export multiple node or edge files at one time.

Files exported via Manager contain schema information, for instance: when exporting node schema `movie`, its file name would be movie_nodes.csv；exported file would be csv format, with comma `,` as column separator and `<property name>` as table header:

<center><img width=500 src="https://img.ultipa.cn/2022-07-03-14-35-55-manager-output-file.png"></center>
<center><i>Chart1: Sample file exported by Ultipa Manager</i></center>

- Export single node file:

To , we need to click "File" on the right menu, then click the "Export Nodes" in the poppup window, choose node schema `movie` and properties  `_id` and `name`, click submit：

<img src="https://img.ultipa.cn/img/2024-02-20-10-41-39-export-one-node-file.gif">
<center><i>Chart2: Export property '_id' and 'name' of node schema 'movie' under graphset miniCirlce329</i></center>

> Setting 'Limit' to -1 means to export all nodes or edges or the selected schema(s), we can also set an interger to limit the number of nodes or edges to export. Properties not selected will not be exported, i.e., Manager does not export node/edge's system properties automatically.

- Export multiple node files:

For instance, export all properties of node schema `country` and `celebrity`:

<img src="https://img.ultipa.cn/img/2024-02-20-10-57-48-export-multiple-node-files.gif">
<center><i>Chart3: Export all properties of node schema 'country' and 'celebrity' under graphset miniCirlce329</i></center>

> When exporting several files (schema) simultaneously, Manager does not support selecting properties for each schema, but automatically exporting all properties for each schema. There might be a popup window asking "Do you allow Manager to download multiple files at the same time?" in a few browsers and users will need to allow before download starts.

> The approach to exporting edge files is similar to exporting node files but selecting "Export Edges", and a meaningful export of edge data always includes exporting starting node `_from` and terminal node `_to` (or `_from_uuid` and `_to_uuid`).

## Export data via Transporter

Differnt from Manager, Transporter can export both nodes and edges at the same time instead of exporting them separately.

Files exported via Transporter are slightly different from Manager, for example, if to export node schema `movie` then its file name would be movie.node.csv; the column names in its header (if applicable) would be `<PropertyName>:<DataType>`, for instance:

<center><img width=500 src="https://img.ultipa.cn/2022-07-03-14-35-59-transporter-output-file.png"></center>
<center><i>Chart4: Sample file exported by Ultipa Transporter</i></center>

Exporting data via Ultipa Transporter's Exporter requires a YML comfiguration file which contains server's connection information, target graphset's name, schema and properties to be exported, and if to export table headers, etc.

YML configuration file are divided into 4 sections：

- Section 1 Server Information

```yml
server:
  host: "192.168.1.85:64001"
  username: "root"
  password: "root"
  graphset: "miniCircle"
  crt: ""
```

Server connection information `host`, `username`, and `password` should be provided by the server administrator; `graphset` can be a graphset to be created; `crt` can be skipped if IFS is not used for communication.

- Section 2 Node Information

```yml
nodeConfig:
  - schema: "movie"
    properties:
      - name: name
      - name: year
  - schema: "country"
    properties:
      - name: name
```

To export node/edge only requires users to state custom properties; their system propertes `_id`, `_uuid`, `_from`, `_to`, `_from_uuid`, and `_to_uuid` will be automatically exported without statement.

- Section 3 Edge Information

```yml
edgeConfig:
  - schema: "filmedIn"
```

> To only export system properties but not any custom properties, users do not have to state `properties`; when exporting all schema for edge, we can state schema as `"*"`, which is same for exporting Node as well. See <i>Transporter</i> for more.

- Section 4 Global Information

```yml
settings:
  writeHeader: true
```

> When setting `writeHeader` to true, all exported files will include table headers.

Save sections above in configuration file export_miniCircle.yml, place it with Transporter's import tool: ultipa-importer Transporter under a same directory, open the command line tool under the directory (e.g. right-click Powershell) and execute commands below:

<p tit="Command">

```bash
./ultipa-exporter --config ./export_miniCircle.yml
```

<img src="https://img.ultipa.cn/img/2023-02-27-18-19-03-transporter-export-rev.gif">

> When operating the command, if notice `bash: ./ultipa-exporter: Permission denied` appears, it suggests that relevant execution privileges are not obtained; users can execute `chmod +x ultipa-exporter` to obtain privileges required before executing `ultipa-exporter` cammands.
