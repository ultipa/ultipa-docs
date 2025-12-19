## Graph

This section introduces methods for managing graphs in the database.

## showGraph()

Retrieves all graphs from the database.

**Parameters**

- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `List[GraphSet]`: The list of retrieved graphs.

```python
# Retrieves all graphs and prints the names of those with over 2000 edges

graphs = Conn.showGraph()
for graph in graphs:
    if graph.totalEdges > 2000:
        print(graph.name)
```

<p tit="Output"></p> 
 
```
Display_Ad_Click
ERP_DATA2
wikiKG
```

## getGraph()

Retrieves a specified graph from the database.

**Parameters**

- `graphName: str`: Name of the graph.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `GraphSet`: The retrieved graph.

```python
# Retrieves the graph named 'miniCircle'

graph = Conn.getGraph("miniCircle")
print(graph.toJSON())
```

<p tit="Output"></p> 
 
```
{"id": "444", "name": "miniCircle", "totalNodes": 304, "totalEdges": 1961, "shards": ["1"], "partitionBy": "CityHash64", "status": "NORMAL", "description": "", "slotNum": 256}
```

## hasGraph()

Checks the existence of a specified graph in the database.

**Parameters**

- `graphName: str`: Name of the graph.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `bool`: Check result.

```python
# Checks the existence of a graph named 'miniCircle'

response = Conn.hasGraph("miniCircle")
print(response)
```

<p tit="Output"></p> 
 
```
True
```

## createGraph()

Creates a graph in the database.

**Parameters**

- `graphSet: GraphSet`: The graph to be created; the attribute `name` is mandatory, `shards`, `partitionBy` and `description` are optional.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```python
# Creates a graph

graph = GraphSet(
    name="testPythonSDK",
    shards=["1"],
    partitionBy="Crc32",
    description="testPythonSDK desc"
)
response = Conn.createGraph(graph)
print(response.status.code.name)
```

<p tit="Output"></p> 
 
```
SUCCESS
```

## createGraphIfNotExist()

Creates a graph in the database and returns whether a graph with the same name already exists.

**Parameters**

- `graphSet: GraphSet`: The graph to be created; the attribute `name` is mandatory, `shards`, `partitionBy` and `description` are optional.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `ResponseWithExistCheck`: Response of the request.

```python
graph = GraphSet(
    name="testPythonSDK",
    shards=["1"],
    partitionBy="Crc32",
    description="testPythonSDK desc"
)

result = Conn.createGraphIfNotExist(graph)

print("Does the graph already exist?", result.exist)
if result.response.status is None:
    print("Graph creation status: No response")
else:
    print("Graph creation status:", result.response.status.code.name)

time.sleep(3)

print("----- Creates the graph again -----")

result_1 = Conn.createGraphIfNotExist(graph)

print("Does the graph already exist?", result_1.exist)
if result_1.response.status is None:
    print("Graph creation status: No response")
else:
    print("Graph creation status:", result_1.response.status.code.name)
```

<p tit="Output"></p> 
 
```
Does the graph already exist? False
Graph creation status: SUCCESS
----- Creates the graph again -----
Does the graph already exist? True
Graph creation status: No response
```

## alterGraph()

Alters the name and description of a graph in the database.

**Parameters**

- `graphName: str`: Name of the graph.
- `alterGraphset: GraphSet`: A `GraphSet` object used to set new `name` and/or `description` for the graph.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```python
# Alters the name and description of the graph 'testPythonSDK'

newGraphInfo = GraphSet(name='newGraph', description="a new graph")
response = Conn.alterGraph("testPythonSDK", newGraphInfo)
print(response.status.code.name)
```

<p tit="Output"></p> 
 
```
SUCCESS
```

## dropGraph()

Deletes a specified graph from the database.

**Parameters**

- `graphName: str`: Name of the graph.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```python
# Drops the graph 'testPythonSDK'

response = Conn.dropGraph("testPythonSDK")
print(response.status.code.name)
```

<p tit="Output"></p> 
 
```
SUCCESS
```

## truncate()

Truncates (Deletes) the specified nodes or edges in a graph or truncates the entire graph. Note that truncating nodes will cause the deletion of edges attached to those affected nodes. The truncating operation retains the definition of schemas and properties in the graph.

**Parameters**

- `params: TruncateParams`: The truncate parameters; the attribute `graphName` is mandatory, `schemaName` and `dbType` are optional.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```python
# Truncates User nodes in 'myGraph'

param1 = TruncateParams(graphName="myGraph", schemaName="User", dbType=DBType.DBNODE)
response1 = Conn.truncate(param1)
print(response1.status.code.name)

# Truncates all edges in the 'myGraph'

param2 = TruncateParams(graphName="myGraph", schemaName="*", dbType=DBType.DBEDGE)
response2 = Conn.truncate(param2)
print(response2.status.code.name)

# Truncates 'myGraph'

param3 = TruncateParams(graphName="myGraph")
response3 = Conn.truncate(param3)
print(response3.status.code.name)
```

<p tit="Output"></p> 
 
```
SUCCESS
SUCCESS
SUCCESS
```

## compact()

Clears invalid and redundant data for a graph. Valid data will not be affected.

**Parameters**

- `graphName: str`: Name of the graph.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `JobResponse`: Response of the request.

```python
# Compacts the graph 'miniCircle'

requestConfig = RequestConfig(graph="miniCircle")

response = Conn.compact("miniCircle")
jobID = response.jobId

time.sleep(3)
jobs = Conn.showJob(jobID, requestConfig)
for job in jobs:
    print(job.id, "-", job.status)
```

<p tit="Output"></p> 
 
```
45 - FINISHED
45_1 - FINISHED
45_2 - FINISHED
45_3 - FINISHED
```

## Full Example

<p tit="example.py" ></p> 

```python
from ultipa import UltipaConfig, Connection, GraphSet

ultipaConfig = UltipaConfig()
# URI example: ultipaConfig.hosts = ["mqj4zouys.us-east-1.cloud.ultipa.com:60010"]
ultipaConfig.hosts = ["192.168.1.85:60061", "192.168.1.87:60061", "192.168.1.88:60061"]
ultipaConfig.username = "<username>"
ultipaConfig.password = "<password>"

Conn = Connection.NewConnection(defaultConfig=ultipaConfig)

# Creates a graph

graph = GraphSet(
    name="testPythonSDK",
    shards=["1"],
    partitionBy="Crc32",
    description="testPythonSDK desc"
)
response = Conn.createGraph(graph)
print(response.status.code.name)
```
