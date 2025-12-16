# Database Querying

## Request Configuration

All querying methods support an optional request configuration parameter (`RequestConfig` or `InsertRequestConfig`) to customize the behavior of requests made to the database. This parameter allows you to specify various settings, such as graphset name, timeout, and host, to tailor your requests according to your needs.

## RequestConfig

`RequestConfig` defines the settings needed when sending non-insert requests to the database.

<p tit="Example.py" ></p> 

```python
from ultipa import Connection, UltipaConfig
from ultipa.configuration.RequestConfig import RequestConfig

ultipaConfig = UltipaConfig()
# URI example: ultipaConfig.hosts = ["mqj4zouys.us-east-1.cloud.ultipa.com:60010"]
ultipaConfig.hosts = ["192.168.1.85:60061", "192.168.1.87:60061", "192.168.1.88:60061"]
ultipaConfig.username = "<username>"
ultipaConfig.password = "<password>"
ultipaConfig.defaultGraph = "default"

Conn = Connection.NewConnection(defaultConfig=ultipaConfig)

requestConfig = RequestConfig(graphName = "UltipaTeam")

schemas = Conn.showSchema(requestConfig)
for schema in schemas:
    print(schema.name, "type:", schema.DBType, "total", schema.total)
```

`RequestConfig` has the following fields:

| <div table-width="20">Field</div> | <div table-width="10">Type</div> | <div table-width="7">Default</div> | Description |
|  ----  | ----  | ----  | ---- |
| `graphName` | str | | Name of the graph to use, or the `defaultGraph` configured when establishing the connection if not set. |
| `timeoutWithSeconds` | int | 3600 | Timeout in seconds for the request, or the `timeoutWithSeconds` configured when establishing the connection if not set. |
| `useHost` | str | | Sends the request to a designated host node, or to a random host node if not set. |
| `useMaster` | bool | false | Sends the request to the leader node to guarantee consistency read if set to true. |
| `threadNum` | int |  | Number of threads. |
| `retry` | Retry | | Number of retries, including `current` (optional; defaults to 0) and `max` (optional; defaults to 3). Here, `current` represents the initial retry count, `max` is the maximum allowable retries. |
| `timeZone` | str | | Timezone, e.g., Europe/Paris, or the `timeZone` configured when establishing the connection if not set. |
| `timeZoneOffset` | int/str | | How far the target timezone is from UTC, either in seconds (if an integer) or a 5-character string such as +0700 and -0430; or the `timeZoneOffset` configured when establishing the connection if not set. |

## InsertRequestConfig

`InsertRequestConfig` defines the settings needed when sending data insertion or deletion requests to the database.

<p tit="Example.py" ></p> 
 
```python
from ultipa.configuration.InsertRequestConfig import InsertRequestConfig
from ultipa import Connection, UltipaConfig, Node
from ultipa.structs import InsertType

ultipaConfig = UltipaConfig()
# URI example: ultipaConfig.hosts = ["mqj4zouys.us-east-1.cloud.ultipa.com:60010"]
ultipaConfig.hosts = ["192.168.1.85:60061", "192.168.1.87:60061", "192.168.1.88:60061"]
ultipaConfig.username = "<username>"
ultipaConfig.password = "<password>"

Conn = Connection.NewConnection(defaultConfig=ultipaConfig)

# Specifies 'test' as the target graphset and sets the insert mode to OVERWRITE
insertRequestConfig = InsertRequestConfig(
    insertType=InsertType.OVERWRITE,
    graphName="test"
)

nodes = [
    Node(schema="client", id="CLIENT00001"),
    Node(schema="card", id="CARD00004")
]
  
Conn.insertNodesBatchAuto(nodes, insertRequestConfig)
```

`InsertRequestConfig` has the following fields:

| <div table-width="20">Field</div> | <div table-width="10">Type</div> | <div table-width="7">Default</div> | Description |
|  ----  | ----  | ----  | ---- |
| `graphName` | str | | Name of the graph to use, or the `defaultGraph` configured when establishing the connection if not set. |
| `timeout` | int | 3600 | Timeout in seconds for the request, or the `timeout` configured when establishing the connection if not set. |
| `retry` | Retry | | Number of retries, including `current` (optional; defaults to 0) and `max` (optional; defaults to 3). Here, `current` represents the initial retry count, `max` is the maximum allowable retries. |
| `useHost` | str |  | Sends the request to a designated host node, or to a random host node if not set. |
| `useMaster` | bool | False | Sends the request to the leader node to guarantee consistency read if set to true. |
| `insertType` | InsertType | `NORMAL` | Insert mode (`NORMAL`, `UPSERT`, `OVERWRITE`) |
| `silent` | bool | True | Whether to keep silent after success insertion, i.e., whether to return the inserted nodes or edges. |
| `createNodeIfNotExist` | bool | False | Whether to create start/end nodes of an edge if the end nodes do not exist in the graph. |
| `timeZone` | str | | Timezone in standard format, or the `timeZone` configured when establishing the connection if not set. |
| `timeZoneOffset` | int/str | | How far the target timezone is from UTC, either in seconds (if an integer) or a 5-character string such as +0700 and -0430; or the `timeZoneOffset` configured when establishing the connection if not set. |
