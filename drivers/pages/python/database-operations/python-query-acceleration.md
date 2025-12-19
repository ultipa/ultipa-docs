# Query Acceleration

This section introduces methods for managing various indexes and LTE status for properties in graphs.

## Index

### showIndex()

Retrieves all indexes from the graph.

**Parameters**

- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `List[Index]`: The list of retrieved indexes.

```python
# Retrieves indexes in the graph 'miniCircle'

requestConfig = RequestConfig(graph="miniCircle")

indexList = Conn.showIndex(requestConfig)
for index in indexList:
    print(index.toJSON())
```

<p tit="Output"></p> 
 
```
{"id": "1", "name": "age_index", "properties": "year", "schema": "account", "status": "DONE", "size": null, "dbType": "DBNODE"}
{"id": "2", "name": "test_index", "properties": "year,float", "schema": "account", "status": "DONE", "size": null, "dbType": "DBNODE"}
{"id": "1", "name": "targetPostInd", "properties": "targetPost", "schema": "disagree", "status": "DONE", "size": null, "dbType": "DBEDGE"}
```

### showNodeIndex()

Retrieves all node indexes from the graph.

**Parameters**

- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `List[Index]`: The list of retrieved indexes.

```python
# Retrieves node indexes in the graph 'miniCircle'

requestConfig = RequestConfig(graph="miniCircle")

indexList = Conn.showNodeIndex(requestConfig)
for index in indexList:
    print(index.toJSON())
```

<p tit="Output"></p> 
 
```
{"id": "1", "name": "age_index", "properties": "year", "schema": "account", "status": "DONE", "size": null, "dbType": "DBNODE"}
{"id": "2", "name": "test_index", "properties": "year,float", "schema": "account", "status": "DONE", "size": null, "dbType": "DBNODE"}
```

### showEdgeIndex()

Retrieves all edge indexes from the graph.

**Parameters**

- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `List[Index]`: The list of retrieved indexes.

```python
# Retrieves edge indexes in the graph 'miniCircle'

requestConfig = RequestConfig(graph="miniCircle")

indexList = Conn.showEdgeIndex(requestConfig)
for index in indexList:
    print(index.toJSON())
```

<p tit="Output"></p> 
 
```
{"id": "1", "name": "targetPostInd", "properties": "targetPost", "schema": "disagree", "status": "DONE", "size": null, "dbType": "DBEDGE"}
```

### dropIndex()

Drops a specified index from the graph.

**Parameters**

- `dbType: DBType`: Type of the index (node or edge).
- `indexName: str`: Name of the index.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```python
# Drops the node index 'test_index' from the graph 'miniCircle'

requestConfig = RequestConfig(graph="miniCircle")

response = Conn.dropIndex(DBType.DBNODE, "test_index", requestConfig)
print(response.status.code.name)
```

<p tit="Output"></p> 
 
```
SUCCESS
```

### dropNodeIndex()

Drops a specified node index from the graph.

**Parameters**

- `indexName: str`: Name of the index.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```python
# Drops the node index 'test_index' from the graph 'miniCircle'

requestConfig = RequestConfig(graph="miniCircle")

response = Conn.dropNodeIndex("test_index", requestConfig)
print(response.status.code.name)
```

<p tit="Output"></p> 
 
```
SUCCESS
```

### dropEdgeIndex()

Drops a specified edge index from the graph.

**Parameters**

- `indexName: str`: Name of the index.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```python
# Drops the edge index 'targetPostInd' from the graph 'miniCircle'

requestConfig = RequestConfig(graph="miniCircle")

response = Conn.dropEdgeIndex("targetPostInd", requestConfig)
print(response.status.code.name)
```

<p tit="Output"></p> 
 
```
SUCCESS
```

## Full-text

### showFulltext()

Retrieves all full-text indexes from the graph.

**Parameters**

- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `List[Index]`: The list of retrieved full-text indexes.

```python
# Retrieves full-text indexes in the graph 'miniCircle'

requestConfig = RequestConfig(graph="miniCircle")

fulltextList = Conn.showFulltext(requestConfig)
for fulltext in fulltextList:
    print(fulltext.toJSON())
```

<p tit="Output"></p> 
 
```
{"id": null, "name": "name", "properties": "name", "schema": "account", "status": "DONE", "size": null, "dbType": "DBNODE"}
{"id": null, "name": "Content", "properties": "content", "schema": "review", "status": "DONE", "size": null, "dbType": "DBEDGE"}
```

### showNodeFulltext()

Retrieves all node full-text indexes from the graph.

**Parameters**

- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `List[Index]`: The list of retrieved full-text indexes.

```python
# Retrieves node full-text indexes in the graph 'miniCircle'

requestConfig = RequestConfig(graph="miniCircle")

fulltextList = Conn.showNodeFulltext(requestConfig)
for fulltext in fulltextList:
    print(fulltext.toJSON())
```

<p tit="Output"></p> 
 
```
{"id": null, "name": "name", "properties": "name", "schema": "account", "status": "DONE", "size": null, "dbType": "DBNODE"}
```

### showEdgeFulltext()

Retrieves all edge full-text indexes from the graph.

**Parameters**

- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `List[Index]`: The list of retrieved full-text indexes.

```python
# Retrieves edge full-text indexes in the graph 'miniCircle'

requestConfig = RequestConfig(graph="miniCircle")

fulltextList = Conn.showEdgeFulltext(requestConfig)
for fulltext in fulltextList:
    print(fulltext.toJSON())
```

<p tit="Output"></p> 
 
```
{"id": null, "name": "Content", "properties": "content", "schema": "review", "status": "DONE", "size": null, "dbType": "DBEDGE"}
```

### createFulltext()

Creates a full-text index in the graph.

**Parameters**

- `dbType: DBType`: Type of the full-text index (node or edge).
- `schemaName: str`: Name of the schema.
- `propertyName: str`: Name of the property.
- `indexName: str`: Name of the full-text index.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `JobResponse`: Response of the request.

```python
# Creates a full-text index 'moviePlot' for the property 'plot' of the 'movie' nodes

requestConfig = RequestConfig(graph="miniCircle")

response = Conn.createFulltext(DBType.DBNODE, 'movie', 'plot', 'moviePlot', requestConfig)
jobID = response.jobId

time.sleep(3)
jobs = Conn.showJob(jobID, requestConfig)
for job in jobs:
    print(job.id, "-", job.status)
```

<p tit="Output"></p> 
 
```
66 - FINISHED
66_1 - FINISHED
66_2 - FINISHED
66_3 - FINISHED
```

### createNodeFulltext()

Creates a node full-text index in the graph.

**Parameters**

- `schemaName: str`: Name of the schema.
- `propertyName: str`: Name of the property.
- `indexName: str`: Name of the full-text index.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `JobResponse`: Response of the request.

```python
# Creates a full-text index 'moviePlot' for the property 'plot' of the 'movie' nodes

requestConfig = RequestConfig(graph="miniCircle")

response = Conn.createNodeFulltext('movie', 'plot', 'moviePlot', requestConfig)
jobID = response.jobId

time.sleep(3)
jobs = Conn.showJob(jobID, requestConfig)
for job in jobs:
    print(job.id, "-", job.status)
```

<p tit="Output"></p> 
 
```
68 - FINISHED
68_1 - FINISHED
68_2 - FINISHED
68_3 - FINISHED
```

### createEdgeFulltext()

Creates an edge full-text index in the graph.

**Parameters**

- `schemaName: str`: Name of the schema.
- `propertyName: str`: Name of the property.
- `indexName: str`: Name of the full-text index.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `JobResponse`: Response of the request.

```python
# Creates a full-text index 'agreeNotes' for the property 'notes' of the 'agree' edges

requestConfig = RequestConfig(graph="miniCircle")

response = Conn.createEdgeFulltext('agree', 'notes', 'agreeNotes', requestConfig)
jobID = response.jobId

time.sleep(3)
jobs = Conn.showJob(jobID, requestConfig)
for job in jobs:
    print(job.id, "-", job.status)
```

<p tit="Output"></p> 
 
```
69 - FINISHED
69_1 - FINISHED
69_2 - FINISHED
69_3 - FINISHED
```

### dropFulltext()

Drops a full-text index from the graph.

**Parameters**

- `dyType: DBType`: Type of the full-text index (node or edge).
- `fulltextName: str`: Name of the full-text index.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```python
# Drops the node full-index 'moviePlot' from the graph 'miniCircle'

requestConfig = RequestConfig(graph="miniCircle")

response = Conn.dropFulltext(DBType.DBNODE, 'moviePlot',requestConfig)
print(response.status.code.name)
```

<p tit="Output"></p> 
 
```
SUCCESS
```

## LTE

### lte()

Loads a property to the computing engine.

**Parameters**

- `dbType: DBType`: Type of the property (node or edge).
- `propertyName: str`: Name of the property.
- `schemaName: str`: Name of the schema.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `JobResponse`: Response of the request.

```python
# Loads the property 'year' of 'account' nodes to the computing engine

requestConfig = RequestConfig(graph="miniCircle")

response = Conn.lte(DBType.DBNODE, "year", "account", requestConfig)
jobID = response.jobId

time.sleep(3)
jobs = Conn.showJob(jobID, requestConfig)
for job in jobs:
    print(job.id, "-", job.status)
```

<p tit="Output"></p> 
 
```
53 - FINISHED
53_1 - FINISHED
53_2 - FINISHED
53_3 - FINISHED
```

### ufe()

Unloads a property from the computing engine.

**Parameters**

- `dbType: DBType`: Type of the property (node or edge).
- `propertyName: str`: Name of the property.
- `schemaName: str`: Name of the schema.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```python
# Unloads the property 'year' of 'account' nodes from the computing engine

requestConfig = RequestConfig(graph="miniCircle")

response = Conn.ufe(DBType.DBNODE, "year", "account", requestConfig)
print(response.status.code.name)
```

<p tit="Output"></p> 
 
```
SUCCESS
```

## Full Example

<p tit="example.py" ></p> 

```python
from ultipa import UltipaConfig, Connection, RequestConfig

ultipaConfig = UltipaConfig()
# URI example: ultipaConfig.hosts = ["mqj4zouys.us-east-1.cloud.ultipa.com:60010"]
ultipaConfig.hosts = ["192.168.1.85:60061", "192.168.1.87:60061", "192.168.1.88:60061"]
ultipaConfig.username = "<username>"
ultipaConfig.password = "<password>"

Conn = Connection.NewConnection(defaultConfig=ultipaConfig)

# Retrieves indexes in the graph 'miniCircle'

requestConfig = RequestConfig(graph="miniCircle")

indexList = Conn.showIndex(requestConfig)
for index in indexList:
    print(index.toJSON())
```
