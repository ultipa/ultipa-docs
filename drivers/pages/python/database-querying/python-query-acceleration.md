# Query Acceleration

This section introduces methods on a `Connection` object for managing the LTE status for properties, and their indexes and full-text indexes. These mechanisms can be employed to <a href="/docs/uql/acceleration">accelerate queries</a>.

Each example focuses solely on the method's usage. For a complete code example, please refer to the <a href="#Full-Example">full example</a>.

## LTE

### lte()

Loads one custom property of nodes or edges to the computing engine for query acceleration.

**Parameters:**

- `DBType`: Type of the property (node or edge).
- `str`: Name of the property.
- `str` (Optional): Name of the schema; all schemas are specified when it is ignored.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UltipaResponse`: Result of the request.

<p tit="Python"></p> 
 
```Python
# Loads the edge property @relatesTo.type to engine in graphset 'UltipaTeam' and prints error code

requestConfig = RequestConfig(graphName="UltipaTeam")

response = Conn.lte(DBType.DBEDGE, 'type', 'relatesTo', requestConfig)
print(response.status.code)
```

<p tit="Output:" ></p> 
 
```Python
0
```

### ufe()

Unloads one custom property of nodes or edges from the computing engine to save the memory.

**Parameters:**

- `DBType`: Type of the property (node or edge).
- `str`: Name of the property.
- `str` (Optional): Name of the schema; all schemas are specified when it is ignored.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit="Python"></p> 
 
```Python
# Unloads the edge property @relatesTo.type from engine in graphset 'UltipaTeam' and prints error code

requestConfig = RequestConfig(graphName="UltipaTeam")

response = Conn.ufe(DBType.DBEDGE, 'type', 'relatesTo', requestConfig)
print(response.status.code)
```

<p tit="Output"></p> 
 
```Python
0
```

## Index

### showIndex()

Retrieves all indexes of node and edge properties from the current graphset.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List[Index]`: The list of all indexes retrieved in the current graphset.

<p tit="Python"></p> 
 
```Python
# Retrieves indexes in graphset 'Ad_Click' and prints their information

requestConfig = RequestConfig(graphName="Ad_Click")

indexList = Conn.showIndex(requestConfig)
for index in indexList:
  print(index.toJSON())
```

<p tit="Output"></p> 
 
```Python
{"DBType": 0, "name": "shopping_level", "properties": "shopping_level", "schema": "user", "size": "4608287", "status": "done"}
{"DBType": 0, "name": "price", "properties": "price", "schema": "ad", "size": "5416241", "status": "done"}
{"DBType": 1, "name": "time", "properties": "time", "schema": "clicks", "size": "12811267", "status": "done"}
```

### showNodeIndex()

Retrieves all indexes of node properties from the current graphset.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List[Index]`: The list of all node indexes retrieved in the current graphset.

<p tit="Python"></p> 
 
```Python
# Retrieves node indexes in graphset 'Ad_Click' and prints their information

requestConfig = RequestConfig(graphName="Ad_Click")

indexList = Conn.showNodeIndex(requestConfig)
for index in indexList:
  print(index.toJSON())
```

<p tit="Output"></p> 
 
```Python
{"DBType": 0, "name": "shopping_level", "properties": "shopping_level", "schema": "user", "size": "4608287", "status": "done"}
{"DBType": 0, "name": "price", "properties": "price", "schema": "ad", "size": "5416241", "status": "done"}
```

### showEdgeIndex()

Retrieves all indexes of edge properties from the current graphset.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List[Index]`: The list of all edge indexes retrieved in the current graphset.

<p tit="Python"></p> 
 
```Python
# Retrieves edge indexes in graphset 'Ad_Click' and prints their information

requestConfig = RequestConfig(graphName="Ad_Click")
indexList = Conn.showEdgeIndex(requestConfig)

for index in indexList:
  print(index.toJSON())
```

<p tit="Output"></p> 
 
```Python
{"DBType": 1, "name": "time", "properties": "time", "schema": "clicks", "size": "12811267", "status": "done"}
```

### createIndex()

Creates a new index in the current graphset.

**Parameters:**

- `DBType`: Type of the property (node or edge).
- `str`: Name of the property.
- `str` (Optional): Name of the schema.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UltipaResponse`: Result of the request.

<p tit="Python"></p> 
 
```Python
# Creates indexes for all node properties 'name' in graphset 'Ad_Click' and prints the error code

requestConfig = RequestConfig(graphName="Ad_Click")

response = Conn.createIndex(DBType.DBNODE, 'name', None, requestConfig)
print(response.status.code)
```

<p tit="Output"></p> 
 
```Python
0
```

### dropIndex()

Drops indexes in the current graphset.

**Parameters:**

- `DBType`: Type of the property (node or edge).
- `str`: Name of the property.
- `str` (Optional): Name of the schema.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UltipaResponse`: Result of the request.

<p tit="Python"></p> 
 
```Python
# Drops the index of the node property @ad.name in graphset 'Ad_Click' and prints the error code

requestConfig = RequestConfig(graphName="Ad_Click")

response = Conn.dropIndex(DBType.DBNODE, 'name', 'ad', requestConfig)
print(response.status.code)
```

<p tit="Output"></p> 
 
```Python
0
```

## Full-text

### showFulltext()

Retrieves all full-text indexes of node and edge properties from the current graphset.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List[Index]`: The list of all full-text indexes retrieved in the current graphset.

<p tit="Python"></p> 
 
```Python
# Retrieves the first full-text index returned in graphset 'miniCircle' and prints its information

requestConfig = RequestConfig(graphName="miniCircle")

fulltextList = Conn.showFulltext(requestConfig)
print(fulltextList[0].toJSON())
```

<p tit="Output"></p> 
 
```Python
{"DBType": 0, "name": "genreFull", "properties": "genre", "schema": "movie", "size": "", "status": "done"}
```

### showNodeFulltext()

Retrieves all full-text indexes of node properties from the current graphset.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List[Index]`:  The list of all full-text indexes of node properties retrieved in the current graphset.

<p tit="Python"></p> 
 
```Python
# Retrieves the first node full-text index of node properties returned in graphset 'miniCircle' and prints its information

requestConfig = RequestConfig(graphName="miniCircle")

nodeFulltextList = Conn.showNodeFulltext(requestConfig)
print(nodeFulltextList[0].toJSON())
```

<p tit="Output"></p> 
 
```Python
{"DBType": 0, "name": "genreFull", "properties": "genre", "schema": "movie", "size": "", "status": "done"}
```

### showEdgeFulltext()

Retrieves all full-text indexes of edge properties of edge properties from the current graphset.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List[Index]`: The list of all edge full-text indexes of edge properties retrieved in the current graphset.

<p tit="Python"></p> 
 
```Python
# Retrieves the first edge full-text index of edge properties returned in graphset 'miniCircle' and prints its information

requestConfig = RequestConfig(graphName="miniCircle")

edgeFulltextList = Conn.showEdgeFulltext(requestConfig)
print(edgeFulltextList[0].toJSON())
```

<p tit="Output"></p> 
 
```Python
{"DBType": 1, "name": "nameFull", "properties": "content", "schema": "review", "size": "", "status": "done"}
```

### createFulltext()

Creates a new full-text index in the current graphset.

**Parameters:**

- `DBType`: Type of the property (node or edge).
- `str`: Name of the schema.
- `str`: Name of the property.
- `str`: Name of the full-text index.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit="Python"></p> 
 
```Python
# Creates full-text index called 'movieName' for the property @movie.name in graphset 'miniCircle' and prints the error code

requestConfig = RequestConfig(graphName="miniCircle")

response = Conn.createFulltext(DBType.DBNODE, 'movie', 'name', 'movieName', requestConfig)
print(response.status.code)
```

<p tit="Output"></p> 
 
```Python
0
```

### dropFulltext()

Drops a full-text index in the current graphset.

**Parameters:**

- `DBType`: Type of the property (node or edge).
- `str`: Name of the full-text index.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UltipaResponse`: Result of the request.

<p tit="Python"></p> 
 
```Python
# Drops the node full-index 'movieName' in graphset 'miniCircle' and prints the error code

requestConfig = RequestConfig(graphName="miniCircle")

response = Conn.dropFulltext(ultipa.DBType.DBNODE,'movieName',requestConfig)
print(response.status.code)
```

<p tit="Output"></p> 
 
```python
0
```

## Full Example

<p tit="example.py" ></p> 

```python
from ultipa import Connection, UltipaConfig
from ultipa.configuration.RequestConfig import RequestConfig

ultipaConfig = UltipaConfig()
# URI example: ultipaConfig.hosts = ["mqj4zouys.us-east-1.cloud.ultipa.com:60010"]
ultipaConfig.hosts = ["192.168.1.85:60061", "192.168.1.87:60061", "192.168.1.88:60061"]
ultipaConfig.username = "<username>"
ultipaConfig.password = "<password>"

Conn = Connection.NewConnection(defaultConfig=ultipaConfig)

# Request configurations
requestConfig = RequestConfig(graphName="Ad_Click")

# Retrieves all indexes in graphset 'Ad_Click' and prints their information
indexList = Conn.showIndex(requestConfig)
for index in indexList:
  print(index.toJSON())
```
