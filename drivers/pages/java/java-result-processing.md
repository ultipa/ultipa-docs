# Result Processing

The results from database read and write operations must be properly processed before being utilized in your application.

# Return a Response

Methods such as `gql()` and `uql()` return a `Response` object. To serve the application, you need to first extract the `DataItem` from the `Response` object, and then transform it into an appropriate <a target="_blank" href="/docs/drivers/java-driver-data-classes">driver data class</a>.

A `Response` object includes the following attributes:

| <div table-width="15">Attribute</div> | <div table-width="22">Type</div> | Description |
| ---- | ---- | ---- |  
| `aliases` | List<`Alias`> | The list of result aliases; each `Alias` includes attributes `name` and `type`. |
| `items` | Map<String, `DataItem`> |  A map where each key is an alias name and each value is the corresponding data item. |
| `explainPlan` | `ExplainPlan` | The execution plan. |
| `status` | `Status` | The status of the execution, inlcuding attributes `code` and `message`. |
| `statistics` | `Statistics` | Statistics related to the execution, including attributes `nodeAffected`, `edgeAffected`, `totalCost`, and `engineCost`. |

### Extract DataItem

To extract `DataItem` from a `Response` object, use the `get()` or `alias()` method.

A `DataItem` object includes the following attributes:

| <div table-width="15">Attribute</div> | <div table-width="25">Type</div> | Description |
| ---- | ---- | ---- |  
| `alias` | String | The alias name. |
| `type` | `Ultipa.ResultType` | The type of the results. |
| `entities` | List | The list of result entities. |

#### get()

Retrieves data by the alias index.

**Parameters**

- `index: int`: Index of the alias.

**Returns**

- `DataItem`: The returned data.

```java
Response response = driver.gql("MATCH (n)-[e]->() RETURN n, e LIMIT 3");
System.out.println(response.get(0).getAlias());
System.out.println(response.get(0).getType());
System.out.println(response.get(0).getEntities());
```

The GQL query returns two aliases (`n`, `e`), and the `get()` method gets the `DataItem` of the alias `n` at index 0.

<p tit="Output"></p> 
 
```
n
RESULT_TYPE_NODE
[Node(uuid=72059793061183504, id=ULTIPA800000000000003B, schema=account, values={industry=Publishing, name=Velox, gender=female, year=1976}), Node(uuid=648520545364606993, id=ULTIPA800000000000003E, schema=account, values={industry=Food&Beverage, name=Claire, gender=female, year=1989}), Node(uuid=720578139402534937, id=ULTIPA8000000000000050, schema=account, values={industry=Education, name=Holly, gender=male, year=2000})]
```

#### alias()

Retrieves data by the alias name.

**Parameters**

- `name: String`: Name of the alias.

**Returns**

- `DataItem`: The returned data.

```java
Response response = driver.gql("MATCH (n)-[e]->() RETURN n, e LIMIT 3");
System.out.println(response.alias("e").getAlias());
System.out.println(response.alias("e").getType());
System.out.println(response.alias("e").getEntities());
```

The GQL query returns two aliases (`n`, `e`), and the `alias()` method gets `DataItem` of the alias `e`.

<p tit="Output"></p> 
 
```
e
RESULT_TYPE_EDGE
[Edge(uuid=139, fromUuid=6269012880322985990, toUuid=-7998395137233256453, from=ULTIPA800000000000000E, to=ULTIPA800000000000000D, schema=agree, values={targetPost=905, timestamp=1572662452, datetime=2018-10-14T06:27:42}), Edge(uuid=378, fromUuid=72059793061183493, toUuid=8214567919347040275, from=ULTIPA800000000000003B, to=ULTIPA800000000000000F, schema=follow, values={}), Edge(uuid=531, fromUuid=72059793061183493, toUuid=4827864298099310661, from=ULTIPA800000000000003B, to=ULTIPA80000000000003F4, schema=wishlist, values={toUuid=1012, uuid=1368, fromUuid=59, timestamp=Sat Mar 23 17:09:12 CST 2019, datetime=2019-03-23T17:09:12})]
```

### Transform DataItem

You should use a `as<DataStructure>()` method to convert the `DataItem.entities` into the corresponding <a target="_blank" href="/docs/drivers/java-driver-data-classes">driver data class</a>.

For example, the GQL query contained in the request below retrieves 3 nodes from the graph, the `asNodes()` method is used to convert the `DataItem` associated with the alias `n` into a list of `Node` objects: 

```java
Response response = driver.gql("MATCH (n) RETURN n LIMIT 3");
List<Node> nodeList = response.alias("n").asNodes();
for (Node node : nodeList) {
    System.out.println(node.getID());
}
```

The following lists all the transformation methods available on `DataItem`. Please note the applicable `DataItem.type` and `DataItem.alias` of each method.

| <div table-width="15">Method</div> | <div table-width="10"><code>DataItem.type</code></div> | <div table-width="10"><code>DataItem.alias</code></div> | <div table-width="10">Returns</div> | Description |
| -- | -- | -- | -- | -- |
| `asNodes()` | NODE | Any | List<`Node`> | Converts to a list of `Node` objects. |
| `asFirstNode()` | NODE | Any | `Node` | Converts the first returned entity to a `Node` object. |
| `asEdges()` | EDGE | Any | List<`Edge`> | Converts to a list of `Edge` objects. |
| `asFirstEdge()` | EDGE | Any | `Edge` | Converts the first returned entity to an `Edge` object. |
| `asGraph()` | GRAPH | Any | `Graph` | Converts to a `Graph` object. |
| `asGraphSets()` | TABLE |  `_graph` | List<`GraphSet`> | Converts to a list of `GraphSet` objects. |
| `asSchemas()` | TABLE | `_nodeSchema`, `_edgeSchema` | List<`Schema`> | Converts to a list of `Schema` objects. |
| `asProperties()` | TABLE | `_nodeProperty`, `_edgeProperty` | List<`Property`> | Converts to a list of `Property` objects. |
| `asAttr()` | ATTR | Any | `Attr` | Converts to an `Attr` object. |
| `asTable()` | TABLE | Any | `Table` | Converts to a `Table` object. |
| `asHDCGraphs()` | TABLE | `_hdcGraphList` | List<`HDCGraph`> | Converts to a list of `HDCGraph` objects. |
| `asAlgos()` | TABLE | `_algoList` | List<`Algo`> | Converts to a list of `Algo` objects. |
| `asProjections()` | TABLE | `_projectionList` | List<`Projection`> | Converts to a list of `Projection` objects. |
| `asIndexes()` | TABLE | `_nodeIndex`, `_edgeIndex`, `_nodeFulltext`, `_edgeFulltext` | List<`Index`> | Converts to a list of `Index` objects. |
| `asPrivilieges()` | TABLE | `_privilege` | List<`Priviliege`> | Converts to a list of `Priviliege` objects. |
| `asPolicies()` | TABLE | `_policy` | List<`Policy`> | Converts to a list of `Policy` objects. |
| `asUsers()` | TABLE | `_user` | List<`User`> | Converts to a list of `User` objects. |
| `asProcesses()` | TABLE | `_top` | List<`Process`> | Converts to a list of `Process` objects. |
| `asJobs()` | TABLE | `_job` | List<`Job`> | Converts to a list of `Job` objects. |

## Return a ResponseWithExistCheck

Methods such as `createGraphIfNotExist()` return a `ResponseWithExistCheck` object.

A `ResponseWithExistCheck` object includes the following attributes:

| <div table-width="15">Attribute</div> | <div table-width="15">Type</div> | Description |
| ---- | ---- | ---- |  
| `exist` | Boolean | Whether the object to create already exist. |
| `response` | `Response` | Main response of the method. |

## Return an InsertResponse

Some data insertion methods such as `insertNodesBatchBySchema()` and `insertNodesBatchAuto()` return an `InsertResponse` object.

An `InsertResponse` object includes the following attributes:

| <div table-width="15">Attribute</div> | <div table-width="15">Type</div> | Description |
| ---- | ---- | ---- |  
| `ids` | List\<String\>| The list of `_id`s of the inserted nodes; note that the list is empty when `InsertRequestConfig.silent` is `True`. |
| `uuids` | List\<Long\> | The list of `_uuid`s of the inserted edges; note that the list is empty when `InsertRequestConfig.silent` is `True`. |
| `errorItems` | Map<Integer, `InsertErrorCode`> | A map containing error details, where each key represents the index of a node or edge with an error, and the value is the error code. |
| `status` | `Status` | The status of the execution, inlcuding attributes `code` and `message`. |
| `statistics` | `Statistics` | Statistics releated to the execution, including attributes `nodeAffected`, `edgeAffected`, `totalCost`, and `engineCost`. |

## Return a JobResponse

Methods such as `createFulltext()` return a `JobResponse` object.

A `JobResponse` object includes the following attributes:

| <div table-width="15">Attribute</div> | <div table-width="15">Type</div> | Description |
| ---- | ---- | ---- |  
| `jobId` | String | ID of the job of the execution. |
| `status` | `Status` | The status of the execution, inlcuding attributes `code` and `message`. |
| `statistics` | `Statistics` | Statistics releated to the execution, including attributes `nodeAffected`, `edgeAffected`, `totalCost`, and `engineCost`. |

## Return Driver Data Classes

Some methods return either a single instance or a list of <a target="_blank" href="/docs/drivers/java-driver-data-classes">driver data class</a>, which can be used directly. For example:

- The `getGraph()` method returns a single `GraphSet` object.
- The `showGraph()` method returns `List<GraphSet>`.
