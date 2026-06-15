# Result Processing

The output of the driver depends on the specific request made. Some methods, like `uql()`, return a `UltipaResponse` object, which requires you to extract the data and cast it into the corresponding driver type to serve the Python application. Other methods, like `showGraph()`, `showSchema()`, and `showProperty()`, return data of the driver type (`GraphSet`, `Schema`, `Property`, etc.) directly. Please read <a href="https://www.ultipa.com/doc/drivers/data-types-mapping-ultipa-and-python">Types Mapping Ultipa and Python</a> for a list of the core driver types.

## UltipaResponse

The `uql()` and some other methods return a `UltipaResponse` object. `UltipaResponse` has the following fields:

| <div table-width="20">Field</div> | <div table-width="25">Type</div> | Description |
| ---- | ---- | ---- |  
| `aliases` | List[ResultAlias] | List of aliases; each has name and type of the data. |
| `items` | Dict | Map of aliases and their corresponding data (`DataItem`). |
| `explainPlan` | List[ExplainPlan] | Explanation tree for the UQL statement. |
| `status` | Status | Execution status of the request. |
| `statistics` | UltipaStatistics | Statistics of the request execution, including `nodeAffected`, `edgeAffected`, `totalCost`, `engineCost`, etc. |
| `req` | ReturnReq | Request details, including `graph_name`, `uql`, `host`, `Retry` and `uqlIsExtra`. |

If the query returns data, you can extract each item by its alias using the `get()` or `alias()` method. Both methods return a `DataItem` object, which embeds the query result. To map the `DataItem` to the corresponding driver type, please read <a href="https://www.ultipa.com/doc/drivers/data-types-mapping-ultipa-and-python">Types Mapping Ultipa and Python</a>.

### get()

Retrieves data by the alias index.

**Parameters:**

- `int`: Index of the alias.

**Returns:**

- `DataItem`: The retrieved data.

```python
response = Conn.uql("find().nodes() as n return n._id, n._uuid limit 3")
print(response.get(0).toJSON())
```

The UQL statement returns two aliases `n._id` and `n._uuid`; the `get()` method retrieves the alias `n._id` at index 0.

<p tit="Output"></p> 
 
```
{"alias": "n._id", "data": {"name": "n._id", "type": 4, "type_desc": "ATTR", "values": ["U1", "U2", "U3"]}, "type": "ATTR"}
```

### alias()

Retrieves data by the alias name.

**Parameters:**

- `str`: Name of the alias.

**Returns:**

- `DataItem`: The retrieved data.

```python
response = Conn.uql("find().nodes() as n return n._id, n._uuid limit 3")
print(response.alias('n._uuid').toJSON())
```

The UQL statement returns two aliases `n._id` and `n._uuid`; the `alias()` method retrieves the alias `n._uuid` by its name.

<p tit="Output"></p> 
 
```
{"alias": "n._uuid", "data": {"name": "n._uuid", "type": 4, "type_desc": "ATTR", "values": [1, 2, 3]}, "type": "ATTR"}
```
