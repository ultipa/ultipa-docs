# Result Processing

The output of the driver depends on the specific request made. Some methods, like `Uql()`, return a `Response` object, which requires you to extract the data and cast it into the corresponding driver type to serve the Go application. Other methods, like `ShowGraph()`, `ShowSchema()`, and `ShowProperty()`, return data of the driver type (`GraphSet`, `Schema`, `Property`, etc.) directly. Please read <a href="https://www.ultipa.com/doc/drivers/data-types-mapping-ultipa-and-go">Types Mapping Ultipa and Go</a> for a list of the core driver types.

## Response

The `Uql()` and some other methods return a `Response` object. `Response` has the following fields:

| <div table-width="20">Field</div> | <div table-width="25">Type</div> | Description |
| ---- | ---- | ---- |  
| `DataItemMap` | map[string]{} | Map of indexes and their corresponding data (`DataItem`). |
| `Reply` | UqlReply | Reply of the request execution, including `state`, `sizeCache`, etc. |
| `Status` | Status | Execution status of the request. |
| `Statistics` | Statistics | Statistics of the request execution, including `NodeAffected`, `EdgeAffected`, `TotalCost`, `EngineCost`, etc. |
| `ExplainPlan` | ExplainPlan | Explanation tree for the UQL statement. |
| `AliasList` | []string | List of aliases. |

If the query returns data, you can extract each item by its alias using the `Get()` or `Alias()` method. Both methods return a `DataItem` object, which embeds the query result. To map the `DataItem` to the corresponding driver type, please read <a href="https://www.ultipa.com/doc/drivers/data-types-mapping-ultipa-and-go">Types Mapping Ultipa and Go</a>.

### Get()

Retrieves data by the alias index.

**Parameters:**

- `int`: Index of the alias.

**Returns:**

- `DataItem`: The retrieved data.

```go
myQuery, err := conn.Uql("find().nodes() as n return n._id, n._uuid limit 3", requestConfig)
if err != nil {
  println(err)
}
println(utils.JSONString(myQuery.Get(0)))
```

The UQL statement returns two aliases `n._id` and `n._uuid`; the `Get()` method retrieves the alias `n._id` at index 0.

<p tit="Output"></p> 
 
```
{"Alias":"","Type":4,"Data":{"alias":"n._id","attr":{"value_type":7,"values":["VUxUSVBBODAwMDAwMDAwMDAwMDAwMQ==","VUxUSVBBODAwMDAwMDAwMDAwMDAwMg==","VUxUSVBBODAwMDAwMDAwMDAwMDAwMw=="]}}}
```

### Alias()

Retrieves data by the alias name.

**Parameters:**

- `string`: Name of the alias.

**Returns:**

- `DataItem`: The retrieved data.

```go
myQuery, err := conn.Uql("find().nodes() as n return n._id, n._uuid limit 3", requestConfig)
if err != nil {
  println(err)
}
println(utils.JSONString(myQuery.Alias("n._uuid")))
```

The UQL statement returns two aliases `n._id` and `n._uuid`; the `Alias()` method retrieves the alias `n._uuid` by its name.

<p tit="Output"></p> 
 
```
{"Alias":"","Type":4,"Data":{"alias":"n._uuid","attr":{"value_type":4,"values":["AAAAAAAAAAE=","AAAAAAAAAAI=","AAAAAAAAAAM="]}}}
```
