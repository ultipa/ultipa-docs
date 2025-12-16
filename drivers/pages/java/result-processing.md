# Result Processing

The output of the driver depends on the specific request made. Some methods, like `uql()`, return a `Response` object, which requires you to extract the data and cast it into the corresponding driver type to serve the Java application. Other methods, like `showGraph()`, `showSchema()`, and `showProperty()`, return data of the driver type (`GraphSet`, `Schema`, `Property`, etc.) directly. Please read <a href="https://www.ultipa.com/doc/drivers/data-types-mapping-ultipa-and-java">Types Mapping Ultipa and Java</a> for a list of the core driver types.

## Response

The `uql()` and some other methods return a `Response` object. `Response` has the following fields:

| <div table-width="20">Field</div> | <div table-width="25">Type</div> | Description |
| ---- | ---- | ---- |  
| `aliases` | List\<Alias> | List of aliases; each has name and type of the data. |
| `items` | Map\<String, DataItem> | Map of aliases and their corresponding data (`DataItem`). |
| `insertNodesReply` | Ultipa.InsertNodesReply | Result of batch node insertions. |
| `insertEdgesReply` | Ultipa.InsertEdgesReply | Result of batch edge insertions. |
| `exportData` | ExportData | Result of data export operations. |
| `explainPlan` | ExplainPlan | Explanation tree for the UQL statement. |
| `status` | Status | Execution status of the request. |
| `statistics` | Statistics | Statistics of the request execution, including `nodeAffected`, `edgeAffected`, `totalCost`, `engineCost`, etc. |

If the query returns data, you can extract each item by its alias using the `get()` or `alias()` method. Both methods return a `DataItem` object, which embeds the query result. To map the `DataItem` to the corresponding driver type, please read <a href="https://www.ultipa.com/doc/drivers/data-types-mapping-ultipa-and-java">Types Mapping Ultipa and Java</a>.

### get()

Retrieves data by the alias index.

**Parameters:**

- `Integer`: Index of the alias.

**Returns:**

- `DataItem`: The retrieved data.

<p tit= "Java" ></p> 
 
```java
Response response = client.uql("find().nodes() as n return n._id, n._uuid limit 3");
System.out.println(response.get(0).toJson());
```

The UQL statement returns two aliases `n._id` and `n._uuid`; the `get()` method retrieves the alias `n._id` at index 0.

<p tit= "Output" ></p> 
 
```bash
["{\"type\":\"STRING\",\"values\":[\"u604131\",\"u604510\",\"u604614\"],\"name\":\"n._id\"}"]
```

### alias()

Retrieves data by the alias name.

**Parameters:**

- `String`: Name of the alias.

**Returns:**

- `DataItem`: The retrieved data.

<p tit= "Java" ></p> 
 
```java
Response response = client.uql("find().nodes() as n return n._id, n._uuid limit 3");
System.out.println(response.alias("n._uuid").toJson());
```

The UQL statement returns two aliases `n._id` and `n._uuid`; the `alias()` method retrieves the alias `n._uuid` by its name.

<p tit= "Output" ></p> 
 
```bash
["{\"type\":\"UINT64\",\"values\":[\"1\",\"2\",\"3\"],\"name\":\"n._uuid\"}"]
```
