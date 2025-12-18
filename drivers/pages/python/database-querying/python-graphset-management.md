# Graphset Management

This section introduces methods on a `Connection` object for managing graphsets in the database.

Each example focuses solely on the method's usage. For a complete code example, please refer to the <a href="#Full-Example">full example</a>.

## showGraph()

Retrieves all graphsets from the database.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `ResponseListGraph`: The list of all graphsets in the database.

<p tit="Python"></p> 
 
```python
# Retrieves all graphsets and prints the names of the those who have over 2000 edges

graphs = Conn.showGraph().data
for graph in graphs:
    if graph.totalEdges > 2000:
        print(graph.name)
```

<p tit="Output"></p> 
 
```python
Display_Ad_Click
ERP_DATA2
wikiKG
```

## getGraph()

Retrieves one graphset from the database by its name.

**Parameters:**

- `str`: Name of the graphset.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `ResponseGraph`: The retrieved graphset.

<p tit="Python"></p> 
 
```python
# Retrieves the graphsets named 'wikiKG' and prints all its information

graph = Conn.getGraph("wikiKG")
print(graph.toJSON())
```

<p tit="Output"></p> 
 
```python
{"description": "", "id": "13844", "name": "wikiKG", "status": "MOUNTED", "totalEdges": "167799", "totalNodes": "44449"}
```

## createGraph()

Creates a new graphset in the database.

**Parameters:**

- `GraphSet`: The graphset to be created; the field `name` must be set, `description` is optional.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UltipaResponse`: Result of the request.

<p tit="Python"></p> 

```python
# Creates one graphset and prints the error code

graph = GraphSet(
    name="testPythonSDK",
    description="testPythonSDK desc"
)
response = Conn.createGraph(graph)
print(response.status.code)
```

A new graphset `testPythonSDK` is created in the database, and the driver prints:

<p tit="Output"></p> 
 
```python
0
```

## createGraphIfNotExist()

Creates a new graphset in the database, handling cases where the given graphset name already exists by ignoring the error.

**Parameters:**

- `GraphSet`: The graphset to be created; the field `name` must be set, `description` is optional.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `bool`: Whether the graph already exists.
- `UltipaResponse` or `None`: Result of the request; returns `None` if the graph already exists.

<p tit="Python"></p> 

```python
# Creates one graphset and prints the error code

graph = GraphSet(
    name="testPythonSDK",
    description="testPythonSDK desc"
)

response1 = Conn.createGraphIfNotExist(graph)
if response1[0] is False:
    print("Code =", response1[1].status.code)
else:
    print("No response")

# Attempts to create the same graphset again and prints the error code

response2 = Conn.createGraphIfNotExist(graph)
if response2[0] is False:
    print("Code =", response2[1].status.code)
else:
    print("No response")
```

A new graphset `testPythonSDK` is created in the database, and the driver prints:

<p tit="Output"></p> 
 
```python
Code = 0
No response
```

## dropGraph()

Drops one graphset from the database by its name.

**Parameters:**

- `str`: Name of the graphset.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UltipaResponse`: Result of the request.

<p tit="Python"></p> 
 
```python
# Creates one graphset and then drops it, prints the result

graph = GraphSet(
    name="testPythonSDK",
    description="testPythonSDK desc"
)

response1 = Conn.createGraph(graph)
print(response1.status.code)

response2 = Conn.dropGraph("testPythonSDK")
print(response2.status.code)
```

<p tit="Output"></p> 
 
```python
0
0
```

## alterGraph()

Alters the name and description of one existing graphset in the database by its name.

**Parameters:**

- `GraphSet`: The existing graphset to be altered; the field `name` must be set.
- `GraphSet`: The new configuration for the existing graphset; either or both of the fields `name` and `description` must be set.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UltipaResponse`: Result of the request.

<p tit="Python"></p> 
 
```python
# Renames the graphset 'testPythonSDK' to 'newGraph', sets a description for it, and prints the result

oldGraph = GraphSet('testPythonSDK')
newGraph = GraphSet(name='newGraph1', description="a new graph")

response = Conn.alterGraph(oldGraph, newGraph)
print(response.status.code)
```

<p tit="Output"></p> 
 
```python
0
```

## truncate()

Truncates (Deletes) the specified nodes or edges in the given graphset or truncates the entire graphset. Note that truncating nodes will cause the deletion of edges attached to those affected nodes. The truncating operation retains the definition of schemas and properties while deleting the data.

**Parameters:**

- `Truncate`: The object to truncate; the field `graphName` must be set, `dbType` and `schema` are optional, but `schema` cannot be set without the setting of `dbType`.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UltipaResponse`: Result of the request.

<p tit="Python"></p> 
 
```python
# Truncates @person nodes in the graphset 'exKG' and prints the error code

target1 = Truncate(graphName="exKG", schema="person", dbType=DBType.DBNODE)
response1 = Conn.truncate(target1)
print(response1.status.code)

# Truncates all edges in the graphset 'exKG' and prints the error code	

target2 = Truncate(graphName="exKG", schema="*", dbType=DBType.DBEDGE)
response2 = Conn.truncate(target2)
print(response2.status.code)

# Truncates the graphset 'exKG' and prints the error code

target3 = Truncate(graphName="exKG")
response3 = Conn.truncate(target3)
print(response3.status.code)
```

<p tit="Output"></p> 
 
```python
0
0
0
```

## compact()

Compacts a graphset by clearing its invalid and redundant data on the server disk. Valid data will not be affected.

**Parameters:**

- `str`: Name of the graphset.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UltipaResponse`: Result of the request.

<p tit="Python"></p> 
 
```python
# Compacts the graphset 'miniCircle' and prints the error code

response = Conn.compact("miniCircle")
print(response.status.code)
```

<p tit="Output"></p> 
 
```python
0
```

## hasGraph()

Checks the existence of a graphset in the database by its name.

**Parameters:**

- `str`: Name of the graphset.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `bool`: Result of the request.

<p tit="Python"></p> 
 
```python
# Checks the existence of graphset 'miniCircle' and prints the result

response = Conn.hasGraph("miniCircle")
print(response)
```

<p tit="Output"></p> 
 
```python
True
```

## unmountGraph()

Unmounts a graphset to save database memory.

**Parameters:**

- `str`: Name of the graphset.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UltipaResponse`: Result of the request.

<p tit="Python"></p> 
 
```python
# Unmounts the graphsets 'miniCircle' and prints its status

Conn.unmountGraph("miniCircle")

time.sleep(2)
graph = Conn.getGraph("miniCircle")
print(graph.data.status)
```

<p tit="Output"></p> 
 
```python
UNMOUNTED
```

## mountGraph()

Mounts a graphset to the database memory.

**Parameters:**

- `str`: Name of the graphset.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UltipaResponse`: Result of the request.

<p tit="Python"></p> 
 
```python
# Mounts the graphsets 'miniCircle' and prints its status

Conn.mountGraph("miniCircle")

time.sleep(2)
graph = Conn.getGraph("miniCircle")
print(graph.data.status)
```

<p tit="Output"></p> 
 
```python
MOUNTED
```

## Full Example

<p tit="example.py" ></p> 

```python
from ultipa import Connection, UltipaConfig, Truncate

ultipaConfig = UltipaConfig()
# URI example: ultipaConfig.hosts = ["mqj4zouys.us-east-1.cloud.ultipa.com:60010"]
ultipaConfig.hosts = ["192.168.1.85:60061", "192.168.1.87:60061", "192.168.1.88:60061"]
ultipaConfig.username = "<username>"
ultipaConfig.password = "<password>"

Conn = Connection.NewConnection(defaultConfig=ultipaConfig)

target = Truncate(graphName="exKG")
response = Conn.truncate(target)
print(response.status.code)
```
