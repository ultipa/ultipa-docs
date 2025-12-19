# Data Insertion

This section introduces methods for the insertion of nodes and edges.

<table>
  <thead>
    <tr>
      <th width="20%">Methods</th>
      <th width="15%">Mechanism</th>
      <th width="20%">Use Case</th>
      <th>Note</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>insertNodes()</code><br><code>insertEdges()</code></td>
      <td>Uses UQL under the hood.</td>
      <td>Inserts a small number of nodes or edges.</td>
      <td></td>
    </tr>
    <tr>
      <td><code>insertNodesBatchBySchema()</code><br><code>insertEdgesBatchBySchema()</code></td>
      <td rowspan=2>Uses gRPC to send data directly to the server.</td>
      <td>Inserts large volumes of nodes or edges of the same schema.</td>
      <td rowspan=2>The property values must be assigned using Python data types that correspond to the Ultipa supported property types (see <a href="#Property-Type-Mapping">Property Type Mapping</a>).</td>
    </tr>
    <tr>
      <td><code>insertNodesBatchAuto()</code><br><code>insertEdgesBatchAuto()</code></td>
      <td>Inserts large volumes of nodes or edges of different schemas.</td>
    </tr>
  </tbody>
</table>

# Property Type Mapping

The mappings between Ultipa property types and Python data types are as follows:

| <div table-width="25">Ultipa Property Type</div> | <div table-width="25">Python Data Type</div> | Examples |
| -- | -- | -- |
| `INT32`, `UINT32`, `INT64`, `UINT64` | `int` | `18` |
| `FLOAT`, `DOUBLE` | `float` | `170.5` |
| `DECIMAL` | `Decimal` | `65.32` | 
| `STRING`, `TEXT` | `str` | `"John Doe"` |
| `LOCAL_DATETIME` | `str`<sup>[1]</sup> | `"1993-05-06 09:11:02"` |
| `ZONED_DATETIME` | `str`<sup>[1]</sup> | `"1993-05-06 09:11:02-0800"` |
| `DATE` | `str`<sup>[1]</sup> | `"1993-05-06"` |
| `LOCAL_TIME` | `str`<sup>[1]</sup> | `"09:11:02"` |
| `ZONED_TIME` | `str`<sup>[1]</sup> | `"09:11:02-0800"` |
| `DATETIME` | `str`<sup>[2]</sup> | `"1993-05-06"` |
| `TIMESTAMP` | `str`<sup>[2]</sup>, `int` | `"1993-05-06"`, `1715169600` |
| `YEAR_TO_MONTH` | `str` | `"P2Y5M"`, `"-P1Y5M"` |
| `DAY_TO_SECOND` | `str` | `"P3DT4H"`, `"-P1DT2H3M4.12S"` |
| `BOOL` | `bool` | `True`, `False` |
| `POINT` | `str` | `"point({latitude: 132.1, longitude: -1.5})"` |
| `LIST` | `list` | `["tennis", "violin"]` |
| `SET` | `set` | `[2004, 3025, 1025]` |

<sup>[1]</sup> Supported **date** formats include `YYYY-MM-DD` and `YYYYMMDD`. Supported **time** formats include `HH:MM:SS[.fraction]` and `HHMMSS[.fraction]`. Date and time components are joined by either a space or the letter `T`. Supported **timezone** formats include `±HH:MM` and `±HHMM`. 

<sup>[2]</sup> Supported date string formats include `[YY]YY-MM-DD HH:MM:SS`, `[YY]YY-MM-DD HH:MM:SSZ`, `[YY]YY-MM-DDTHH:MM:SSZ`, `[YY]YY-MM-DDTHH:MM:SSXX`, `[YY]YY-MM-DDTHH:MM:SSXXX`, `[YY]YY-MM-DD HH:MM:SS.SSS` and their variations.

## Example Graph Structure

The examples in this section demonstrate the insertion and deletion of nodes and edges in a graph based on the following schema and property definitions:

<div align=center drawio-diagram='21996' drawio-name="draw_d2206b47d3ee474f8f022e26f184d5a2.jpg"><img src="https://img.ultipa.cn/draw/draw_d2206b47d3ee474f8f022e26f184d5a2.jpg?v='1755156187937'"/></div>

To create this graph structure, see the example provided <a target="_blank" href="/docs/drivers/python-schema-and-property#Full-Example">here</a>.

## insertNodes()

Inserts nodes to a schema in the graph.
 
**Parameters**

- `nodes: List[Node]`: The list of nodes to be inserted. 
- `schemaName: str`: Schema name.
- `config: InsertRequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```python
# Inserts two 'user' nodes into the graph 'social'

insertRequestConfig = InsertRequestConfig(graph="social")

nodes = [
    Node(id="U1", values={
        "name": "Alice",
        "age": 18,
        "score": 65.32,
        "birthday": "1993-05-04",
        "active": 0,
        "location": "point({latitude: 132.1, longitude: -1.5})",
        "interests": ["tennis", "violin"],
        "permissionCodes": [2004, 3025, 1025]
    }),
    Node(id="U2", values={
        "name": "Bob"
    })
]

response = Conn.insertNodes(nodes, "user", insertRequestConfig)
if response.status.code.name == "SUCCESS":
    print(response.status.code.name)
else:
    print(response.status.message)
```

<p tit="Output"></p> 

```
SUCCESS
```

## insertEdges()

Inserts edges to a schema in the graph.
 
**Parameters**

- `edges: List[Edge]`: The list of edges to be inserted; the attributes `fromId` and `toId` of each `Edge` are mandatory. 
- `schemaName: str`: Schema name.
- `config: InsertRequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```python
# Inserts two 'follows' edges to the graph 'social'

insertRequestConfig = InsertRequestConfig(graph="social")

edges = [
    Edge(fromId="U1", toId="U2", values={"createdOn": "2024-5-6", "weight": 3.2}),
    Edge(fromId="U2", toId="U1", values={"createdOn": 1715169600})
]

response = Conn.insertEdges(edges, "follows", insertRequestConfig)
if response.status.code.name == "SUCCESS":
    print(response.status.code.name)
else:
    print(response.status.message)
```

<p tit="Output"></p> 

```
SUCCESS
```

## insertNodesBatchBySchema()

Inserts nodes to a schema in the graph through gRPC. This method is optimized for bulk insertion.

**Parameters**

- `schema: Schema`: The target schema; the attribute `name` is mandatory, `properties` includes partial or all properties defined for the corresponding schema in the graph. 
- `nodes: List<Node>`: The list of nodes to be inserted.
- `config: InsertRequestConfig` (Optional): Request configuration.

**Returns**

- `InsertResponse`: Response of the insertion request.

```python
# Inserts two 'user' nodes into the graph 'social'

insertRequestConfig = InsertRequestConfig(graph="social")

schema = Schema(
    name="user",
    properties=[
        Property(name="name", type=UltipaPropertyType.STRING),
        Property(name="age", type=UltipaPropertyType.INT32),
        Property(name="score", type=UltipaPropertyType.DECIMAL, decimalExtra=DecimalExtra(25, 10)),
        Property(name="birthday", type=UltipaPropertyType.DATE),
        Property(name="active", type=UltipaPropertyType.BOOL),
        Property(name="location", type=UltipaPropertyType.POINT),
        Property(name="interests", type=UltipaPropertyType.LIST, subType=[UltipaPropertyType.STRING]),
        Property(name="permissionCodes", type=UltipaPropertyType.SET, subType=[UltipaPropertyType.INT32])
    ]
)

nodes = [
    Node(id="U1", values={
        "name": "Alice",
        "age": 18,
        "score": 65.32,
        "birthday": "1993-05-04",
        "active": 0,
        "location": "point({latitude: 132.1, longitude: -1.5})",
        "interests": ["tennis", "violin"],
        "permissionCodes": [2004, 3025, 1025]
    }),
    Node(id="U2", values={
        "name": "Bob",
    })
]

insertResponse = Conn.insertNodesBatchBySchema(schema, nodes, insertRequestConfig)
if insertResponse.errorItems:
    print("Error items:", insertResponse.errorItems)
else:
    print("All nodes inserted successfully")
```

<p tit="Output"></p> 

```
All nodes inserted successfully
```

## insertEdgesBatchBySchema()

Inserts edges to a schema in the graph through gRPC. This method is optimized for bulk insertion.

**Parameters**

- `schema: Schema`: The target schema; the attribute `name` is mandatory, `properties` includes partial or all properties defined for the corresponding schema in the graph.
- `edges: List[Edge]`: The list of edges to be inserted; the attributes `fromId` and `toId` of each `Edge` are mandatory.
- `config: InsertRequestConfig` (Optional): Request configuration.

**Returns**

- `InsertResponse`: Response of the insertion request.

```python
# Inserts two 'follows' edges into the graph 'social'

insertRequestConfig = InsertRequestConfig(graph="social")

schema = Schema(
    name="follows",
    properties=[
        Property(name="createdOn", type=UltipaPropertyType.TIMESTAMP),
        Property(name="weight", type=UltipaPropertyType.FLOAT)
    ]
)

edges = [
    Edge(fromId="U1", toId="U2", values={
        "createdOn": "2024-5-6",
        "weight": 3.2
    }),
    Edge(fromId="U2", toId="U1", values={
        "createdOn": 1715169600
    })
]

insertResponse = Conn.insertEdgesBatchBySchema(schema, edges, insertRequestConfig)
if insertResponse.errorItems:
    print("Error items:", insertResponse.errorItems)
else:
    print("All edges inserted successfully")
```

<p tit="Output"></p> 

```
All edges inserted successfully
```

## insertNodesBatchAuto()

Inserts nodes to one or multipe schemas in the graph through gRPC. This method is optimized for bulk insertion.

**Parameters**

- `nodes: List[Node]`: The list of nodes to be inserted; the attribute `schema` of each `Node` are mandatory, `values` includes partial or all properties defined for the corresponding schema in the graph.
- `config: InsertRequestConfig` (Optional): Request configuration.

**Returns**

- `Dict[str,InsertResponse]`: The schema name, and response of the insertion request.

```python
# Inserts two 'user' nodes and a 'product' node into the graph 'social'

insertRequestConfig = InsertRequestConfig(graph="social")

nodes = [
    Node(id="U1", schema="user", values={
        "name": "Alice",
        "age": 18,
        "score": 65.32,
        "birthday": "1993-05-04",
        "active": True,
        "location": "point({latitude: 132.1, longitude: -1.5})",
        "interests": ["tennis", "violin"],
        "permissionCodes": [2004, 3025, 1025]
    }),
    Node(id="U2", schema="user", values={
        "name": "Bob"
    }),
    Node(schema="product", values={
        "name": "Wireless Earbud",
        "price": 93.2
    })
]

result = Conn.insertNodesBatchAuto(nodes, insertRequestConfig)
for schemaName, insertResponse in result.items():
    if insertResponse.errorItems:
        print("Error items of", schemaName, "nodes:", insertResponse.errorItems)
    else:
        print("All", schemaName, "nodes inserted successfully")
```

<p tit="Output"></p> 

```
All user nodes inserted successfully
All product nodes inserted successfully
```

## insertEdgesBatchAuto()

Inserts edges to one or multipe schemas in the graph through gRPC. This method is optimized for bulk insertion.

**Parameters**

- `edges: List[Edge]`: The list of edges to be inserted; the attributes `schema`, `fromId`, and `toId` are mandatory, `values` includes partial or all properties defined for the corresponding schema in the graph.
- `config: InsertRequestConfig` (Optional): Request configuration.

**Returns**

- `Dict[str,InsertResponse]`: The schema name, and response of the insertion request.

```python
# Inserts two 'follows' edges and a 'purchased' edge into the graph 'social'

insertRequestConfig = InsertRequestConfig(graph="social")

edges = [
    Edge(schema="follows", fromId="U1", toId="U2", values={"createdOn": "2024-05-06", "weight": 3.2}),
    Edge(schema="follows", fromId="U2", toId="U1", values={"createdOn": 1715169600}),
    Edge(schema="purchased", fromId="U2", toId="689da1080000030022000005", values={})
]

result = Conn.insertEdgesBatchAuto(edges, insertRequestConfig)
for schemaName, insertResponse in result.items():
    if insertResponse.errorItems:
        print("Error items of", schemaName, "edges:", insertResponse.errorItems)
    else:
        print("All", schemaName, "edges inserted successfully")
```

<p tit="Output"></p> 

```
All follows edges inserted successfully
All purchased edges inserted successfully
```

## Full Example

<p tit="Example.py" ></p> 

```python
from ultipa import UltipaConfig, Connection, InsertRequestConfig, Node

ultipaConfig = UltipaConfig()
# URI example: ultipaConfig.hosts = ["mqj4zouys.us-east-1.cloud.ultipa.com:60010"]
ultipaConfig.hosts = ["192.168.1.85:60061", "192.168.1.87:60061", "192.168.1.88:60061"]
ultipaConfig.username = "<username>"
ultipaConfig.password = "<password>"

Conn = Connection.NewConnection(defaultConfig=ultipaConfig)

# Inserts two 'user' nodes, a 'product' node, two 'follows' edges, and a 'purchased' edge into the graph 'social'

insertRequestConfig = InsertRequestConfig(graph="social")

nodes = [
    Node(id="U1", schema="user", values={
        "name": "Alice",
        "age": 18,
        "score": 65.32,
        "birthday": "1993-05-04",
        "active": True,
        "location": "point({latitude: 132.1, longitude: -1.5})",
        "interests": ["tennis", "violin"],
        "permissionCodes": [2004, 3025, 1025]
    }),
    Node(id="U2", schema="user", values={
        "name": "Bob"
    }),
    Node(id="P1", schema="product", values={
        "name": "Wireless Earbud",
        "price": 93.2
    })
]

edges = [
    Edge(schema="follows", fromId="U1", toId="U2", values={"createdOn": "2024-05-06", "weight": 3.2}),
    Edge(schema="follows", fromId="U2", toId="U1", values={"createdOn": 1715169600}),
    Edge(schema="purchased", fromId="U2", toId="P1", values={})
]

result_n = Conn.insertNodesBatchAuto(nodes, insertRequestConfig)
for schemaName, insertResponse in result_n.items():
    if insertResponse.errorItems:
        print("Error items of", schemaName, "nodes:", insertResponse.errorItems)
    else:
        print("All", schemaName, "nodes inserted successfully")

result_e = Conn.insertEdgesBatchAuto(edges, insertRequestConfig)
for schemaName, insertResponse in result_e.items():
    if insertResponse.errorItems:
        print("Error items of", schemaName, "edges:", insertResponse.errorItems)
    else:
        print("All", schemaName, "edges inserted successfully")
```
