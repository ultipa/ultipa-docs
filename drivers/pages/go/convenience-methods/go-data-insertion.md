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
      <td rowspan=2>The property values must be assigned using Go data types that correspond to the Ultipa supported property types (see <a href="#Property-Type-Mapping">Property Type Mapping</a>).</td>
    </tr>
    <tr>
      <td><code>insertNodesBatchAuto()</code><br><code>insertEdgesBatchAuto()</code></td>
      <td>Inserts large volumes of nodes or edges of different schemas.</td>
    </tr>
  </tbody>
</table>

## Property Type Mapping

The mappings between Ultipa property types and Go data types are as follows:

| <div table-width="25">Ultipa Property Type</div> | <div table-width="25">Go Data Type</div> | Examples |
| -- | -- | -- |
| `INT32` | `int32` | `18` |
| `UINT32` | `uint32` | `18` |
| `INT64` | `int64` | `18` |
| `UINT64` | `uint64` | `18` |
| `FLOAT` | `float32` | `170.5` |
| `DOUBLE` | `float64` | `65.32` |
| `DECIMAL` | `int32`, `int64`, `float32`, `float64`, `uint32`, `uint64`, or `string`| `18`, `170.5`, `"65.32"` |
| `STRING` | `string` | `"John Doe"` |
| `TEXT` | `string` | `"John Doe"` |
| `LOCAL_DATETIME` | `string`<sup>[1]</sup> | `"1993-05-06 09:11:02"` |
| `ZONED_DATETIME` | `string`<sup>[1]</sup> | `"1993-05-06 09:11:02-0800"` |
| `DATE` | `string`<sup>[1]</sup> | `"1993-05-06"` |
| `LOCAL_TIME` | `string`<sup>[1]</sup> | `"09:11:02"` |
| `ZONED_TIME` | `string`<sup>[1]</sup> | `"09:11:02-0800"` |
| `DATETIME` | `string`<sup>[2]</sup> | `"1993-05-06"` |
| `TIMESTAMP` | `string`<sup>[2]</sup>, or `int` |  `"1993-05-06"`, `"1715169600"` |
| `YEAR_TO_MONTH` | `string` | `P2Y5M`, `-P1Y5M` |
| `DAY_TO_SECOND` | `string` | `P3DT4H`, `-P1DT2H3M4.12S` |
| `BOOL` | `Boolean` | `true`, `false` |
| `BOOL` | `bool` | `true` or `false` |
| `POINT` | `string`, `NewPoint` | `"point({latitude: 132.1, longitude: -1.5})"`, `types.NewPoint(132.1, -1.5)` |
| `LIST` | `slice` | `["tennis", "violin"]` |
| `SET` | `slice` | `[2004, 3025, 1025]` |

<sup>[1]</sup> Supported **date** formats include `YYYY-MM-DD` and `YYYYMMDD`. Supported **time** formats include `HH:MM:SS[.fraction]` and `HHMMSS[.fraction]`. Date and time components are joined by either a space or the letter `T`. Supported **timezone** formats include `±HH:MM` and `±HHMM`. 

<sup>[2]</sup> Supported date string formats include `[YY]YY-MM-DD HH:MM:SS`, `[YY]YY-MM-DD HH:MM:SSZ`, `[YY]YY-MM-DDTHH:MM:SSZ`, `[YY]YY-MM-DDTHH:MM:SSXX`, `[YY]YY-MM-DDTHH:MM:SSXXX`, `[YY]YY-MM-DD HH:MM:SS.SSS` and their variations.

## Example Graph Structure

The examples in this section demonstrate the insertion and deletion of nodes and edges in a graph based on the following schema and property definitions:

<div align=center drawio-diagram='24581' drawio-name="draw_6f637ebde5f543648a80da5cbe25bcaa.jpg"><img src="https://img.ultipa.cn/draw/draw_6f637ebde5f543648a80da5cbe25bcaa.jpg?v='1755680708549'"/></div>

To create this graph structure, see the example provided <a target="_blank" href="/docs/drivers/go-schema-and-property#Full-Example">here</a>.

## InsertNodes()

Inserts nodes to a schema in the graph.
 
**Parameters**

- `schemaName: string`: Schema name.
- `nodes: []*structs.Node`: The list of nodes to be inserted. 
- `config: *configuration.InsertRequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Inserts two 'user' nodes into the graph 'social'

requestConfig := &configuration.RequestConfig{
    Graph: "social",
}

insertRequestConfig := &configuration.InsertRequestConfig{
    RequestConfig: requestConfig,
}

nodes := []*structs.Node{
    {
    	ID: "U1",
    	Values: &structs.Values{
      		Data: map[string]interface{}{
        		"name":            "Alice",
        		"age":             18,
        		"score":           65.32,
        		"birthday":        "1993-05-04",
        		"active":          0,
        		"location":        "point({latitude: 132.1, longitude: -1.5})",
        		"interests":       []string{"tennis", "violin"},
        		"permissionCodes": []int32{2004, 3025, 1025},
      		},
    	},
    },
    {
    	ID: "U2",
    	Values: &structs.Values{
      		Data: map[string]interface{}{
        		"name": "Bob",
      		},
    	},
  	},
}

response, _ := driver.InsertNodes("user", nodes, insertRequestConfig)
if response.Status.Code.String() == "SUCCESS" {
    fmt.Println(response.Status.Code)
} else {
    fmt.Println(response.Status.Message)
}
```

<p tit="Output"></p> 
 
```
SUCCESS
```

## InsertEdges()

Inserts edges to a schema in the graph.
 
**Parameters**

- `schemaName: string`: Schema name.
- `edges: []*structs.Edge`: The list of edges to be inserted; the fields `From` and `To` of each Edge are mandatory.
- `config: *configuration.InsertRequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Inserts two 'follows' edges to the graph 'social'

requestConfig := &configuration.RequestConfig{
    Graph: "social",
}

insertRequestConfig := &configuration.InsertRequestConfig{
    RequestConfig: requestConfig,
}

edges := []*structs.Edge{
    {
    	From: "U1",
    	To:   "U2",
    	Values: &structs.Values{
      		Data: map[string]interface{}{
        		"createdOn": "2024-5-6",
        		"weight":    3.2,
      		},
    	},
  	},
  	{
    	From: "U2",
    	To:   "U1",
    	Values: &structs.Values{
      		Data: map[string]interface{}{
        		"createdOn": 1715169600,
      		},
    	},
  	},
}

response, _ := driver.InsertEdges("follows", edges, insertRequestConfig)
if response.Status.Code.String() == "SUCCESS" {
    fmt.Println(response.Status.Code)
} else {
    fmt.Println(response.Status.Message)
}
```
<p tit="Output"></p> 
 
```
SUCCESS
```

## InsertNodesBatchBySchema()

Inserts nodes to a schema in the graph through gRPC. This method is optimized for bulk insertion.

**Parameters**

- `schema: *structs.Schema`: The target schema; the fields `Name` is mandatory, `Properties` includes partial or all properties defined for the corresponding schema in the graph. 
- `nodes: []*structs.Node`: The list of nodes to be inserted.
- `config: *configuration.InsertRequestConfig` (Optional): Request configuration.

**Returns**

- `InsertResponse`: Result of the request.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Inserts two 'user' nodes into the graph 'social'

requestConfig := &configuration.RequestConfig{
  Graph: "social",
}

insertRequestConfig := &configuration.InsertRequestConfig{
  RequestConfig: requestConfig,
}

schema := &structs.Schema{
  Name: "user",
  Properties: []*structs.Property{
    {Name: "name", Type: ultipa.PropertyType_STRING},
    {Name: "age", Type: ultipa.PropertyType_INT32},
    {Name: "score", Type: ultipa.PropertyType_DECIMAL, DecimalExtra: &structs.DecimalExtra{Precision: 25, Scale: 10}},
    {Name: "birthday", Type: ultipa.PropertyType_DATE},
    {Name: "active", Type: ultipa.PropertyType_BOOL},
    {Name: "location", Type: ultipa.PropertyType_POINT},
    {Name: "interests", Type: ultipa.PropertyType_LIST, SubTypes: []ultipa.PropertyType{ultipa.PropertyType_STRING}},
    {Name: "permissionCodes", Type: ultipa.PropertyType_SET, SubTypes: []ultipa.PropertyType{ultipa.PropertyType_INT32}},
  },
}

nodes := []*structs.Node{
  {
    ID: "U1",
    Values: &structs.Values{
      Data: map[string]interface{}{
        "name":            "Alice",
        "age":             18,
        "score":           65.32,
        "birthday":        "1993-05-04",
        "active":          false,
        "location":        types.NewPoint(132.1, -1.5),
        "interests":       []string{"tennis", "violin"},
        "permissionCodes": []int32{2004, 3025, 1025},
      },
    },
  },
  {
    ID: "U2",
    Values: &structs.Values{
      Data: map[string]interface{}{
        "name": "Bob",
      },
    },
  },
}

insertResponse, err := driver.InsertNodesBatchBySchema(schema, nodes, insertRequestConfig)
if err != nil {
  log.Fatalf("Insert failed: %v", err)
}

if insertResponse != nil && len(insertResponse.ErrorItems) > 0 {
  fmt.Println("Error items:", insertResponse.ErrorItems)
} else {
  fmt.Println("All nodes inserted successfully")
}
```

<p tit="Output"></p> 
 
```
All nodes inserted successfully
```

## InsertEdgesBatchBySchema()

Inserts edges to a schema in the graph through gRPC. This method is optimized for bulk insertion.

**Parameters**

- `schema: *structs.Schema`: The target schema; the fields `Name` is mandatory, `Properties` includes partial or all properties defined for the corresponding schema in the graph. 
- `edges: []*structs.Edge`: The list of edges to be inserted; the fields `From` and `To` of each Edge are mandatory.
- `config: *configuration.InsertRequestConfig` (Optional): Request configuration.

**Returns**

- `InsertResponse`: Result of the request.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Inserts two 'follows' edges into the graph 'social'

requestConfig := &configuration.RequestConfig{
  Graph: "social",
}

insertRequestConfig := &configuration.InsertRequestConfig{
  RequestConfig: requestConfig,
}

schema := &structs.Schema{
  Name: "follows",
  Properties: []*structs.Property{
    {Name: "createdOn", Type: ultipa.PropertyType_TIMESTAMP},
    {Name: "weight", Type: ultipa.PropertyType_FLOAT},
  },
}

edges := []*structs.Edge{
  {
    From: "U1",
    To:   "U2",
    Values: &structs.Values{
      Data: map[string]interface{}{
        "createdOn": "2024-5-6",
        "weight":    float32(3.2),
      },
    },
  },
  {
    From:   "U2",
    To:     "U1",
    Values: &structs.Values{},
  },
}

insertResponse, err := driver.InsertEdgesBatchBySchema(schema, edges, insertRequestConfig)
if err != nil {
  log.Fatalf("Insert failed: %v", err)
}

if insertResponse != nil && len(insertResponse.ErrorItems) > 0 {
  fmt.Println("Error items:", insertResponse.ErrorItems)
} else {
  fmt.Println("All edges inserted successfully")
}
```
<p tit="Output"></p> 
 
```
All edges inserted successfully
```

## InsertNodesBatchAuto()

Inserts nodes to one or multipe schemas in the graph through gRPC. This method is optimized for bulk insertion.

**Parameters**

- `nodes: []*structs.Node`: The list of nodes to be inserted; the field `Schema` of each `Node` are mandatory, the `Values` includes partial or all properties defined for the corresponding schema in the graph.
- `config: *configuration.InsertRequestConfig` (Optional): Request configuration.

**Returns**

- `map[string]*http.InsertResponse`: The schema name, and response of the insertion request. 
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Inserts two 'user' nodes and a 'product' node into the graph 'social'

requestConfig := &configuration.RequestConfig{
  Graph: "social",
}

insertRequestConfig := &configuration.InsertRequestConfig{
  RequestConfig: requestConfig,
}

nodes := []*structs.Node{
  {
    Schema: "user",
    ID:     "U1",
    Values: &structs.Values{
      Data: map[string]interface{}{
        "name":            "Alice",
        "age":             18,
        "score":           65.32,
        "birthday":        "1993-05-04",
        "active":          false,
        "location":        types.NewPoint(132.1, -1.5),
        "interests":       []string{"tennis", "violin"},
        "permissionCodes": []int32{2004, 3025, 1025},
      },
    },
  },
  {
    Schema: "user",
    ID:     "U2",
    Values: &structs.Values{
      Data: map[string]interface{}{
        "name": "Bob",
      },
    },
  },
  {
    Schema: "product",
    Values: &structs.Values{
      Data: map[string]interface{}{
        "name":  "Wireless Earbud",
        "price": float32(93.2),
      },
    },
  },
}

result, err := driver.InsertNodesBatchAuto(nodes, insertRequestConfig)
if err != nil {
  log.Fatalf("Insert failed: %v", err)
}

for schemaName, insertResponse := range result {
  if len(insertResponse.ErrorItems) > 0 {
    fmt.Println("Error items of", schemaName, "nodes:", insertResponse.ErrorItems)
  } else {
    fmt.Println("All", schemaName, "nodes inserted successfully")
  }
}
```

<p tit="Output"></p> 
 
```
All product nodes inserted successfully
All user nodes inserted successfully
```

## InsertEdgesBatchAuto()

Inserts edges to one or multipe schemas in the graph through gRPC. This method is optimized for bulk insertion.

**Parameters**

- `edges: []*structs.Edge`: The list of edges to be inserted; the fields `Schema`, `From`, and `To` of each `Edge` are mandatory, `Values` includes partial or all properties defined for the corresponding schema in the graph.
- `config: *configuration.InsertRequestConfig` (Optional): Request configuration.

**Returns**

- `map[string]*http.InsertResponse`: The schema name, and response of the insertion request. 
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Inserts two 'follows' edges and a 'purchased' edge into the graph 'social'

requestConfig := &configuration.RequestConfig{
    Graph: "social",
}

insertRequestConfig := &configuration.InsertRequestConfig{
  	RequestConfig: requestConfig,
}

edges := []*structs.Edge{
  	{
    	Schema: "follows",
    	From:   "U1",
    	To:     "U2",
    	Values: &structs.Values{
      		Data: map[string]interface{}{
        		"createdOn": "2024-5-6",
        		"weight":    float32(3.2),
      		},
    	},
  	},
  	{
    	Schema: "follows",
    	From:   "U2",
    	To:     "U1",
    	Values: &structs.Values{
      		Data: map[string]interface{}{
        		"createdOn": 1715169600,
      		},
    	},
  	},
  	{
    	Schema: "purchased",
    	From:   "U2",
    	To:     "684bd6a70000020020000001",
  	},
}

result, err := driver.InsertEdgesBatchAuto(edges, insertRequestConfig)
if err != nil {
  	log.Fatalf("Insert failed: %v", err)
}

for schemaName, insertResponse := range result {
  	if len(insertResponse.ErrorItems) > 0 {
    	fmt.Println("Error items of", schemaName, "edges:", insertResponse.ErrorItems)
  	} else {
    	fmt.Println("All", schemaName, "edges inserted successfully")
  	}
}
```

<p tit="Output"></p> 
 
```
All follows edges inserted successfully
All purchased edges inserted successfully
```

## Full Example

```go
package main

import (
	"fmt"
	"log"

	"github.com/ultipa/ultipa-go-driver/v5/sdk"
	"github.com/ultipa/ultipa-go-driver/v5/sdk/configuration"
	"github.com/ultipa/ultipa-go-driver/v5/sdk/structs"
	"github.com/ultipa/ultipa-go-driver/v5/sdk/types"
)

func main() {
	config := &configuration.UltipaConfig{
		// URI example:	Hosts: []string{"mqj4zouys.us-east-1.cloud.ultipa.com:60010"},
		Hosts:    []string{"192.168.1.85:60061", "192.168.1.87:60061", "192.168.1.88:60061"},
		Username: "<usernmae>",
		Password: "<password>",
	}

	driver, err := sdk.NewUltipaDriver(config)
	if err != nil {
		log.Fatalln("Failed to connect to Ultipa:", err)
	}

	// Inserts two 'user' nodes, a 'product' node, two 'follows' edges, and a 'purchased' edge into the graph 'social'

	requestConfig := &configuration.RequestConfig{
		Graph: "social",
	}

	insertRequestConfig := &configuration.InsertRequestConfig{
		RequestConfig: requestConfig,
	}

	nodes := []*structs.Node{
		{
			Schema: "user",
			ID:     "U1",
			Values: &structs.Values{
				Data: map[string]interface{}{
					"name":            "Alice",
					"age":             18,
					"score":           65.32,
					"birthday":        "1993-05-04",
					"active":          false,
					"location":        types.NewPoint(132.1, -1.5),
					"interests":       []string{"tennis", "violin"},
					"permissionCodes": []int32{2004, 3025, 1025},
				},
			},
		},
		{
			Schema: "user",
			ID:     "U2",
			Values: &structs.Values{
				Data: map[string]interface{}{
					"name": "Bob",
				},
			},
		},
		{
			Schema: "product",
			ID:     "P1",
			Values: &structs.Values{
				Data: map[string]interface{}{
					"name":  "Wireless Earbud",
					"price": float32(93.2),
				},
			},
		},
	}

	edges := []*structs.Edge{
		{
			Schema: "follows",
			From:   "U1",
			To:     "U2",
			Values: &structs.Values{
				Data: map[string]interface{}{
					"createdOn": "2024-5-6",
					"weight":    float32(3.2),
				},
			},
		},
		{
			Schema: "follows",
			From:   "U2",
			To:     "U1",
			Values: &structs.Values{
				Data: map[string]interface{}{
					"createdOn": 1715169600,
				},
			},
		},
		{
			Schema: "purchased",
			From:   "U2",
			To:     "P1",
		},
	}

	result_n, err := driver.InsertNodesBatchAuto(nodes, insertRequestConfig)
	if err != nil {
		log.Fatalf("Insert failed: %v", err)
	}

	for schemaName, insertResponse := range result_n {
		if len(insertResponse.ErrorItems) > 0 {
			fmt.Println("Error items of", schemaName, "nodes:", insertResponse.ErrorItems)
		} else {
			fmt.Println("All", schemaName, "nodes inserted successfully")
		}
	}

	result_e, err := driver.InsertEdgesBatchAuto(edges, insertRequestConfig)
	if err != nil {
		log.Fatalf("Insert failed: %v", err)
	}

	for schemaName, insertResponse := range result_e {
		if len(insertResponse.ErrorItems) > 0 {
			fmt.Println("Error items of", schemaName, "edges:", insertResponse.ErrorItems)
		} else {
			fmt.Println("All", schemaName, "edges inserted successfully")
		}
	}
}
```
