# Result Processing

The output of the driver depends on the specific request made. Some methods, like `Uql()`, return a `Response` object, which requires you to extract the data and cast it into the corresponding driver type to serve the C# application. Other methods, like `ShowGraph()`, `ShowSchema()`, and `ShowProperty()`, return data of the driver type (`GraphSet`, `Schema`, `Property`, etc.) directly. Please read <a target="_blank" href="/docs/drivers/data-types-mapping-ultipa-and-csharp">Types Mapping Ultipa and C#</a> for a list of the core driver types.

# Response

The `Uql()` and some other methods return a `Response` object. `Response` has the following fields:

| <div table-width="20">Field</div> | <div table-width="25">Type</div> | Description |
| ---- | ---- | ---- |  
| `UqlReply` | UqlReply | Reply of the request execution. |
| `Status` | Status | Execution status of the request. |
| `Statistics` | Statistics | Statistics of the request execution, including `NodeAffected`, `EdgeAffected`, `TotalCost`, `EngineCost`, etc. |
| `Explain` | List\<PlanNode> | Explanation tree for the UQL statement. |

If the query returns data, you can extract each item by its alias using the `Get()` or `Alias()` method. Both methods return a `DataItem` object, which embeds the query result. To map the `DataItem` to the corresponding driver type, please read <a target="_blank" href="/docs/drivers/data-types-mapping-ultipa-and-csharp">Types Mapping Ultipa and C#</a>.

### Get()

Retrieves data by the alias index.

**Parameters:**

- `int`: Index of the alias.

**Returns:**

- `DataItem`: The retrieved data.

```csharp
var res = await ultipa.Uql("find().nodes() as n return n._id, n._uuid limit 3");
Console.WriteLine(JsonConvert.SerializeObject(res.Get(0)));
```

The UQL statement returns two aliases `n._id` and `n._uuid`; the `Get()` method retrieves the alias `n._id` at index 0.

<p tit="Output"></p> 
 
```
{"Data":{"Alias":"n._id","Attr":{"ValueType":7,"Values":[[85,76,84,73,80,65,56,48,48,48,48,48,48,48,48,48,48,48,48,48,48,49],[85,76,84,73,80,65,56,48,48,48,48,48,48,48,48,48,48,48,48,48,48,50],[85,76,84,73,80,65,56,48,48,48,48,48,48,48,48,48,48,48,48,48,48,51]]}},"AliasName":"n._id","OriginalResultType":4}
```

### Alias()

Retrieves data by the alias name.

**Parameters:**

- `string`: Name of the alias.

**Returns:**

- `DataItem`: The retrieved data.

```csharp
var res = await ultipa.Uql("find().nodes() as n return n._id, n._uuid limit 3");
Console.WriteLine(JsonConvert.SerializeObject(res.Alias("n._uuid")));
```

The UQL statement returns two aliases `n._id` and `n._uuid`; the `Alias()` method retrieves the alias `n._uuid` by its name.

<p tit="Output"></p> 
 
```
{"Data":{"Alias":"n._uuid","Attr":{"ValueType":4,"Values":[[0,0,0,0,0,0,0,1],[0,0,0,0,0,0,0,2],[0,0,0,0,0,0,0,3]]}},"AliasName":"n._uuid","OriginalResultType":4}
```