## Result Processing

The results from database read and write operations must be properly processed before being utilized in your application.

## Return a Response

Methods such as `gql()` and `uql()` return a `Response` object. To serve the application, you need to first extract the `DataItem` from the `Response` object, and then transform it into an appropriate <a target="_blank" href="/docs/drivers/python-driver-data-classes">driver data class</a>.

A `Response` object includes the following attributes:

| <div table-width="15">Attribute</div> | <div table-width="22">Type</div> | Description |
| ---- | ---- | ---- |  
| `aliases` | List[`Alias`] | The list of result aliases; each `Alias` includes attributes `name` and `type`. |
| `items` | Dict[str, `DataItem`] | A dictionary where each key is an alias name and each value is the corresponding data item. |
| `explainPlan` | `ExplainPlan` | The execution plan. |
| `status` | `Status` | The status of the execution, inlcuding attributes `code` and `message`. |
| `statistics` | `Statistics` | Statistics related to the execution, including attributes `nodeAffected`, `edgeAffected`, `totalCost`, and `engineCost`. |

### Extract DataItem

To extract `DataItem` from a `Response` object, use the `get()` or `alias()` method.

A `DataItem` object includes the following attributes:

| <div table-width="15">Attribute</div> | <div table-width="25">Type</div> | Description |
| ---- | ---- | ---- |  
| `alias` | str | The alias name. |
| `type` | `ResultType` | The type of the results. |
| `entities` | any | The result entities. |

#### get()

Retrieves data by the alias index.

**Parameters**

- `index: int`: Index of the alias.

**Returns**

- `DataItem`: The returned data.

```python
response = Conn.gql("MATCH (n)-[e]->() RETURN n, e LIMIT 3")
print(response.get(0).toJSON())
```

The GQL query returns two aliases (`n`, `e`), and the `get()` method gets the `DataItem` of the alias `n` at index 0.

<p tit="Output"></p> 
 
```
{"alias": "n", "entities": [{"uuid": 72059793061183504, "id": "ULTIPA800000000000003B", "schema": "account", "values": {"gender": "female", "industry": "Publishing", "name": "Velox", "year": 1976}}, {"uuid": 648520545364606993, "id": "ULTIPA800000000000003E", "schema": "account", "values": {"gender": "female", "industry": "Food&Beverage", "name": "Claire", "year": 1989}}, {"uuid": 720578139402534937, "id": "ULTIPA8000000000000050", "schema": "account", "values": {"gender": "male", "industry": "Education", "name": "Holly", "year": 2000}}], "type": "NODE"}
```

#### alias()

Retrieves data by the alias name.

**Parameters**

- `alias: str`: Name of the alias.

**Returns**

- `DataItem`: The returned data.

```python
response = Conn.gql("MATCH (n)-[e]->() RETURN n, e LIMIT 3")
print(response.alias("e").toJSON())
```

The GQL query returns two aliases (`n`, `e`), and the `alias()` method gets `DataItem` of the alias `e`.

<p tit="Output"></p> 
 
```
{"alias": "e", "entities": [{"schema": "agree", "uuid": 139, "fromId": "ULTIPA800000000000000E", "toId": "ULTIPA800000000000000D", "fromUuid": 6269012880322985990, "toUuid": 7998395137233256453, "values": {"targetPost": 905, "timestamp": 1572662452, "datetime": "2019-11-02 18:40:52"}}, {"schema": "agree", "uuid": 167, "fromId": "ULTIPA800000000000000E", "toId": "ULTIPA800000000000000F", "fromUuid": 6269012880322985990, "toUuid": 8214567919347040263, "values": {"targetPost": 1419, "timestamp": 1554431053, "datetime": "2019-04-05 18:24:13"}}, {"schema": "agree", "uuid": 15, "fromId": "ULTIPA8000000000000065", "toId": "ULTIPA8000000000000067", "fromUuid": 6629300850512625701, "toUuid": 5764609722057490465, "values": {"targetPost": 1374, "timestamp": 1552775174, "datetime": "2019-03-17 14:26:14"}}], "type": "EDGE"}
```

### Transform DataItem

You should use a `as<DataStructure>()` method to convert the `DataItem.entities` into the corresponding <a target="_blank" href="/docs/drivers/python-driver-data-classes">driver data class</a>.

For example, the GQL query contained in the request below retrieves 3 nodes from the graph, the `asNodes()` method is used to convert the `DataItem` associated with the alias `n` into a list of `Node` objects: 

<p tit= "Python" ></p>
 
```python
response = Conn.gql("MATCH (n) RETURN n LIMIT 3")
nodeList = response.alias('n').asNodes()
for node in nodeList:
    print(node.getID())
```

The following lists all the transformation methods available on `DataItem`. Please note the applicable `DataItem.type` and `DataItem.alias` of each method.

| <div table-width="15">Method</div> | <div table-width="10"><code>DataItem.type</code></div> | <div table-width="10"><code>DataItem.alias</code></div> | <div table-width="10">Returns</div> | Description |
| -- | -- | -- | -- | -- |
| `asNodes()` | NODE | Any | List[`Node`] | Converts to a list of `Node` objects. |
| `asFirstNode()` | NODE | Any | `Node` | Converts the first returned entity to a `Node` object. |
| `asEdges()` | EDGE | Any | List[`Edge`] | Converts to a list of `Edge` objects. |
| `asFirstEdge()` | EDGE | Any | `Edge` | Converts the first returned entity to an `Edge` object. |
| `asGraph()` | GRAPH | Any | `Graph` | Converts to a `Graph` object. |
| `asGraphSets()` | TABLE |  `_graph` | List[`GraphSet`] | Converts to a list of `GraphSet` objects. |
| `asSchemas()` | TABLE | `_nodeSchema`, `_edgeSchema` | List[`Schema`] | Converts to a list of `Schema` objects. |
| `asProperties()` | TABLE | `_nodeProperty`, `_edgeProperty` | List[`Property`] | Converts to a list of `Property` objects. |
| `asAttr()` | ATTR | Any | `Attr` | Converts to an `Attr` object. |
| `asTable()` | TABLE | Any | `Table` | Converts to a `Table` object. |
| `asHDCGraphs()` | TABLE | `_hdcGraphList` | List[`HDCGraph`] | Converts to a list of `HDCGraph` objects. |
| `asAlgos()` | TABLE | `_algoList` | List[`Algo`] | Converts to a list of `Algo` objects. |
| `asProjections()` | TABLE | `_projectionList` | List[`Projection`] | Converts to a list of `Projection` objects. |
| `asIndexes()` | TABLE | `_nodeIndex`, `_edgeIndex`, `_nodeFulltext`, `_edgeFulltext` | List[`Index`] | Converts to a list of `Index` objects. |
| `asPrivilieges()` | TABLE | `_privilege` | List[`Priviliege`] | Converts to a list of `Priviliege` objects. |
| `asPolicies()` | TABLE | `_policy` | List[`Policy`] | Converts to a list of `Policy` objects. |
| `asUsers()` | TABLE | `_user` | List[`User`] | Converts to a list of `User` objects. |
| `asProcesses()` | TABLE | `_top` | List[`Process`] | Converts to a list of `Process` objects. |
| `asJobs()` | TABLE | `_job` | List[`Job`] | Converts to a list of `Job` objects. |

## Return a ResponseWithExistCheck

Methods such as `createGraphIfNotExist()` return a `ResponseWithExistCheck` object.

A `ResponseWithExistCheck` object includes the following attributes:

| <div table-width="15">Attribute</div> | <div table-width="15">Type</div> | Description |
| ---- | ---- | ---- |  
| `exist` | bool | Whether the object to create already exist. |
| `response` | `Response` | Main response of the method. |

## Return an InsertResponse

Some data insertion methods such as `insertNodesBatchBySchema()` and `insertNodesBatchAuto()` return an `InsertResponse` object.

An `InsertResponse` object includes the following attributes:

| <div table-width="15">Attribute</div> | <div table-width="15">Type</div> | Description |
| ---- | ---- | ---- |  
| `ids` | List[str] | The list of `_id`s of the inserted nodes; note that the list is empty when `InsertRequestConfig.silent` is `True`. |
| `uuids` | List[int] | The list of `_uuid`s of the inserted edges; note that the list is empty when `InsertRequestConfig.silent` is `True`. |
| `errorItems` | Dict[int,`InsertErrorCode`] | A dictionary containing error details, where each key represents the index of a node or edge with an error, and the value is the error code. |
| `status` | `Status` | The status of the execution, inlcuding attributes `code` and `message`. |
| `statistics` | `Statistics` | Statistics releated to the execution, including attributes `nodeAffected`, `edgeAffected`, `totalCost`, and `engineCost`. |

## Return a JobResponse

Methods such as `createFulltext()` return a `JobResponse` object.

A `JobResponse` object includes the following attributes:

| <div table-width="15">Attribute</div> | <div table-width="15">Type</div> | Description |
| ---- | ---- | ---- |  
| `jobId` | str | ID of the job of the execution. |
| `status` | `Status` | The status of the execution, inlcuding attributes `code` and `message`. |
| `statistics` | `Statistics` | Statistics releated to the execution, including attributes `nodeAffected`, `edgeAffected`, `totalCost`, and `engineCost`. |

## Return Driver Data Classes

Some methods return either a single instance or a list of <a target="_blank" href="/docs/drivers/python-driver-data-classes">driver data class</a>, which can be used directly. For example:

- The `getGraph()` method returns a single `GraphSet` object.
- The `showGraph()` method returns `List[GraphSet]`.
