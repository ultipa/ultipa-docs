# Result Processing

The output of the driver depends on the specific request made. Some methods, like `uql()`, return a `Response` object, which requires you to extract the data and cast it into the corresponding driver type to serve the Node.js application. Other methods, like `showGraph()`, `showSchema()`, and `showProperty()`, return data of the driver type (`GraphSet`, `Schema`, `Property`, etc.) directly. Please read <a href="https://www.ultipa.com/doc/drivers/types-mapping-ultipa-and-nodejs">Types Mapping Ultipa and Node.js</a> for a list of the core driver types.

## Response

The `uql()` and some other methods return a `Response` object. `Response` has the following fields:

| <div table-width="20">Field</div> | <div table-width="25">Type</div> | Description |
| ---- | ---- | ---- |  
| `req` | any | Request information. |
| `datas` | DataItem[] | Data items, including `data`, `type`, `type_desc`, `alias`, etc. |
| `explainPlan` | PlanNode | Explanation tree for the UQL statement. |
| `status` | Status | Execution status of the request. |
| `statistics` | Statistics | Statistics of the request execution, including `nodeAffected`, `edgeAffected`, `totalCost`, `engineCost`, etc. |

If the query returns data, you can extract each item by its alias using the `get()` or `alias()` method. Both methods return a `DataItem` object, which embeds the query result. To map the `DataItem` to the corresponding driver type, please read <a href="https://www.ultipa.com/doc/drivers/data-types-mapping-ultipa-and-nodejs">Types Mapping Ultipa and Node.js</a>.

### get()

Retrieves data by the alias index.

**Parameters:**

- `number`: Index of the alias.

**Returns:**

- `DataItem`: The retrieved data.

<p tit= "TypeScript" ></p> 
 
```ts
let resp = await conn.uql(
  "find().nodes() as n return n._id, n._uuid limit 3",
  requestConfig
);
console.log(resp.data.get(0));
console.log(resp.data.get(1));
```

The UQL statement returns two aliases `n._id` and `n._uuid`; the `get()` method retrieves the alias `n._id` at index 0.

<p tit= "Output" ></p> 
 
```bash
DataItem {
  data: {
    alias: 'n._id',
    type: 4,
    type_desc: 'RESULT_TYPE_ATTR',
    values: [
      'ULTIPA8000000000000001',
      'ULTIPA8000000000000002',
      'ULTIPA8000000000000003'
    ]
  },
  alias: 'n._id',
  type: 4,
  type_desc: 'RESULT_TYPE_ATTR'
}
```

### alias()

Retrieves data by the alias name.

**Parameters:**

- `string`: Name of the alias.

**Returns:**

- `DataItem`: The retrieved data.

<p tit= "TypeScript" ></p> 
 
```ts
let resp = await conn.uql(
  "find().nodes() as n return n._id, n._uuid limit 3",
  requestConfig
);
console.log(resp.data.alias("n._uuid"));
```

The UQL statement returns two aliases `n._id` and `n._uuid`; the `alias()` method retrieves the alias `n._uuid` by its name.

<p tit= "Output" ></p> 
 
```bash
DataItem {
  data: {
    alias: 'n._uuid',
    type: 4,
    type_desc: 'RESULT_TYPE_ATTR',
    values: [ '1', '2', '3' ]
  },
  alias: 'n._uuid',
  type: 4,
  type_desc: 'RESULT_TYPE_ATTR'
}"]
```
