# Downloads and Exports

This section introduces methods on a `Connection` object for downloading algorithm result files and exporting nodes and edges from a graphset. 

Each example focuses solely on the method's usage. For a complete code example, please refer to the <a href="#Full-Example">full example</a>.

## downloadAlgoResultFile()

Downloads one result file from an algorithm task in the current graph.
 
**Parameters:**

- `str`: Name of the file.
- `str`: ID of the algorithm task that generated the file.
- `Callable[[bytes]`: Callback function that accepts bytes.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `None`.

<p tit="Python"></p> 

```python
requestConfig = RequestConfig(graphName="miniCircle")

# Runs the Louvain algorithm in graphset 'miniCircle' and prints the task ID

response = Conn.uql("algo(louvain).params({phase1_loop_num: 20, min_modularity_increase: 0.001}).write({file:{filename_community_id: 'communityID', filename_ids: 'ids', filename_num: 'num'}})", requestConfig);
taskTable = response.alias("_task").asTable()
taskID = taskTable.rows[0][0]
print("taskID =", taskID)

time.sleep(3)

filename = 'communityID'

# Define the callback function to handle file download

def handle_down_algo_file(stream: bytes):
    text = stream.decode('utf-8')
    with open(filename, 'a', encoding='utf-8') as f:
        writer = csv.writer(f)
        if ',' in text:
            writer.writerow(text.strip().split(','))
        else:
            writer.writerow([text])

# Execute file download using the callback

cb = lambda stream: handle_down_algo_file(stream)
Conn.downloadAlgoResultFile(filename, taskID, cb, requestConfig)
```

<p tit= "Output" ></p> 

```python
taskID = 78620
```

> The file `communityID` is downloaded to the same directory as the file you executed.

## downloadAllAlgoResultFile()

Downloads all result files from an algorithm task in the current graph.
 
**Parameters:**

- `str`: ID of the algorithm task that generated the file.
- `Callable[[bytes]`: Callback function that accepts bytes.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `None`.

<p tit="Python"></p> 

```python
requestConfig = RequestConfig(graphName="miniCircle")

# Runs the Louvain algorithm in graphset 'miniCircle' and prints the task ID

response = Conn.uql("algo(louvain).params({phase1_loop_num: 20, min_modularity_increase: 0.001}).write({file:{filename_community_id: 'communityID', filename_ids: 'ids', filename_num: 'num'}})", requestConfig);
taskTable = response.alias("_task").asTable()
taskID = taskTable.rows[0][0]
print("taskID =", taskID)

time.sleep(3)

# Define the callback function to handle file download

def handle_down_all_algo_file(stream: bytes, filename):
    text = stream.decode('utf-8')
    with open(filename, 'a', encoding='utf-8') as f:
        writer = csv.writer(f)
        if ',' in text:
            writer.writerow(text.strip().split(','))
        else:
            writer.writerow([text])

# Execute file download using the callback

cb = lambda stream,filename: handle_down_all_algo_file(stream,filename)
Conn.downloadAllAlgoResultFile(taskID, cb, requestConfig)
```

<p tit= "Output" ></p> 

```Python
taskId = 1509
```

> The files `communityID`, `ids` and `num` are downloaded to the same directory as the file you executed.

## export()

Exports nodes and edges from the current graph.

**Parameters:**

- `Export`: Configurations for the export request, including `dbType:DBType`, `limit:int`, `schemaName:str` and `selectPropertiesName:List[str]`.
- `Callable[[List[Node], List[Edge]], None]`: Callback function that accepts the nodes and edges.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `None`.

<p tit="Python"></p> 

```python
# Exports 10 nodes of schema 'account' with selected properties in graphset 'miniCircle' and prints their information

requestConfig = RequestConfig(graphName="miniCircle")

exportRequest = Export(
    dbType=DBType.DBNODE,
    limit=10,
    schemaName="account",
    selectPropertiesName=["_id", "_uuid", "name", "year"]
)

# Define the callback function to handle the export

def handle_export(nodes: List[Node], edges: List[Edge]):
    if nodes is not None:
        df = pd.DataFrame(nodes)
        df.to_excel(exportRequest.schemaName + ".xlsx", index=False)
    if edges is not None:
        df = pd.DataFrame(edges)
        df.to_excel(exportRequest.schemaName + ".xlsx", index=False)

Conn.export(exportRequest, handle_export, requestConfig)
```

> The file `account.xlsx` is exported to the same directory as the file you executed.

## Full Example

<p tit="example.py"></p>

```python
import csv

from ultipa import Connection, UltipaConfig
from ultipa.configuration.RequestConfig import RequestConfig

ultipaConfig = UltipaConfig()
# URI example: ultipaConfig.hosts = ["mqj4zouys.us-east-1.cloud.ultipa.com:60010"]
ultipaConfig.hosts = ["192.168.1.85:60061", "192.168.1.87:60061", "192.168.1.88:60061"]
ultipaConfig.username = "<username>"
ultipaConfig.password = "<password>"

Conn = Connection.NewConnection(defaultConfig=ultipaConfig)

requestConfig = RequestConfig(graphName="miniCircle")

# Runs the Louvain algorithm in graphset 'miniCircle' and prints the task ID

response = Conn.uql("algo(louvain).params({phase1_loop_num: 20, min_modularity_increase: 0.001}).write({file:{filename_community_id: 'communityID', filename_ids: 'ids', filename_num: 'num'}})", requestConfig);
taskTable = response.alias("_task").asTable()
taskID = taskTable.rows[0][0]
print("taskID =", taskID)

time.sleep(3)

# Define the callback function to handle file download

def handle_down_all_algo_file(stream: bytes, filename):
    text = stream.decode('utf-8')
    with open(filename, 'a', encoding='utf-8') as f:
        writer = csv.writer(f)
        if ',' in text:
            writer.writerow(text.strip().split(','))
        else:
            writer.writerow([text])

# Execute file download using the callback

cb = lambda stream,filename: handle_down_all_algo_file(stream,filename)
Conn.downloadAllAlgoResultFile(taskID, cb, requestConfig)
```
