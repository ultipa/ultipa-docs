# Process Query Results

Methods like `Gql()` and `Uql()` return a `Response` containing the raw query results from the database and execution metadata. To use the query results in your application, you need to **extract** and **convert** them into a usable <a target="_blank" href="/docs/drivers/go-data-structures">data structure</a>.

`Response` includes the following fields:

| <div table-width="15">Field</div> | <div table-width="22">Type</div> | Description |
| ---- | ---- | ---- |  
| `Aliases` | []`Alias` | The list of result aliases; each `Alias` includes fields `Name` and `Type`. |
| `Items` | map[string]struct{} | A map where each key is an alias name and each value is the corresponding data item. |
| `ExplainPlan` | `ExplainPlan` | The execution plan. |
| `Status` | `Status` | The status of the execution, inlcuding fields `Code` and `Message`. |
| `Statistics` | `Statistics` | Statistics related to the execution, including fields `NodeAffected`, `EdgeAffected`, `TotalCost`, and `EngineCost`. |

## Extract Query Results

To extract the query results, i.e., the `DataItem` from `Response.Items`, use the `Get()` or `Alias()` method.

### Get()

Extracts query results by the alias index.

**Parameters**

- `index: int`: Index of the alias.

**Returns**

- `DataItem`: The returned data.

```go
response, _ := driver.Gql("MATCH (n)-[e]->() RETURN n, e LIMIT 3", nil)
fmt.Println(response.Get(0))
```

The GQL query returns two aliases (`n`, `e`), the `Get()` method gets the `DataItem` of the alias `n` at index 0.

<p tit="Output"></p> 
 
```
&{ RESULT_TYPE_NODE node_table:{schemas:{schema_name:"User" properties:{property_name:"name" property_type:STRING} schema_id:2} entity_rows:{uuid:1080866109592174597 id:"U04" schema_name:"User" values:"mochaeach" schema_id:2} entity_rows:{uuid:1080866109592174597 id:"U04" schema_name:"User" values:"mochaeach" schema_id:2} entity_rows:{uuid:4179342653223075843 id:"U02" schema_name:"User" values:"Brainy" schema_id:2}} alias:"n"}
```

### Alias()

Extracts query results by the alias name.

**Parameters**

- `alias: string`: Name of the alias.

**Returns**

- `DataItem`: The returned data.

```go
response, _ := driver.Gql("MATCH (n)-[e]->() RETURN n, e LIMIT 3", nil)
fmt.Println(response.Alias("e"))
```

The GQL query returns two aliases (`n`, `e`), the `Alias()` method gets `DataItem` of the alias `e`.

<p tit="Output"></p> 
 
```
&{ RESULT_TYPE_EDGE edge_table:{schemas:{schema_name:"Follows" properties:{property_name:"createdOn" property_type:DATETIME} schema_id:2} schemas:{schema_name:"Joins" properties:{property_name:"memberNo" property_type:UINT32} schema_id:3} entity_rows:{uuid:2 schema_name:"Follows" from_uuid:1080866109592174597 to_uuid:4179342653223075843 from_id:"U04" to_id:"U02" values:"\x19\xb2\x94\x00\x00\x00\x00\x00" schema_id:2} entity_rows:{uuid:7 schema_name:"Joins" from_uuid:1080866109592174597 to_uuid:17870286619941011464 from_id:"U04" to_id:"C02" values:"\x00\x00\x00\t" schema_id:3} entity_rows:{uuid:3 schema_name:"Follows" from_uuid:4179342653223075843 to_uuid:12393908373546860548 from_id:"U02" to_id:"U03" values:"\x19\xb2\x82\x00\x00\x00\x00\x00" schema_id:2}} alias:"e"}
```

## Convert Query Results

You should use a `As<DataStructure>()` method to convert the `DataItem.entities` into the corresponding <a target="_blank" href="/docs/drivers/go-data-structures">data structure</a>.

### AsNodes()

If a query returns nodes, you can use `AsNodes()` to convert them into a list of `Node`s.

```go
requestConfig := &configuration.RequestConfig{Graph: "g1"}
response, _ := driver.Gql("MATCH (n:User) RETURN n LIMIT 2", requestConfig)
nodes, _, _ := response.Alias("n").AsNodes()
for _, node := range nodes {
  jsonData, err := json.MarshalIndent(node, "", "  ")
  if err != nil {
    fmt.Println("Error:", err)
    continue
  }
  fmt.Println(string(jsonData))
}
```

<p tit="Output"></p> 
 
```
{
  "ID": "U4",
  "UUID": 6557243256474697731,
  "Schema": "User",
  "Values": {
    "Data": {
      "name": "mochaeach"
    }
  }
}
{
  "ID": "U2",
  "UUID": 7926337543195328514,
  "Schema": "User",
  "Values": {
    "Data": {
      "name": "Brainy"
    }
  }
}
```

### AsFirstNode()

If a query returns nodes, you can use `AsFirstNode()` to convert the first returned node into a `Node`.

```go
requestConfig := &configuration.RequestConfig{Graph: "g1"}
response, _ := driver.Gql("MATCH (n:User) RETURN n", requestConfig)
node, _ := response.Alias("n").AsFirstNode()
jsonData, err := json.MarshalIndent(node, "", "  ")
if err != nil {
  fmt.Println("Error:", err)
}
fmt.Println(string(jsonData))
```

<p tit="Output"></p> 
 
```
{
  "ID": "U4",
  "UUID": 6557243256474697731,
  "Schema": "User",
  "Values": {
    "Data": {
      "name": "mochaeach"
    }
  }
}
```

### AsEdges()

If a query returns edges, you can use `AsEdges()` to convert them into a list of `Edge`s.

```go
requestConfig := &configuration.RequestConfig{Graph: "g1"}
response, _ := driver.Gql("MATCH ()-[e]->() RETURN e LIMIT 2", requestConfig)
edges, _, _ := response.Alias("e").AsEdges()
for _, edge := range edges {
  jsonData, err := json.MarshalIndent(edge, "", "  ")
  if err != nil {
    fmt.Println("Error:", err)
    continue
  }
  fmt.Println(string(jsonData))
}
```

<p tit="Output"></p> 
 
```
{
  "UUID": 2,
  "FromUUID": 6557243256474697731,
  "ToUUID": 7926337543195328514,
  "From": "U4",
  "To": "U2",
  "Schema": "Follows",
  "Values": {
    "Data": {
      "createdOn": "2024-02-10"
    }
  }
}
{
  "UUID": 3,
  "FromUUID": 7926337543195328514,
  "ToUUID": 17870285520429383683,
  "From": "U2",
  "To": "U3",
  "Schema": "Follows",
  "Values": {
    "Data": {
      "createdOn": "2024-02-01"
    }
  }
}
```

### AsFirstEdge()

If a query returns edges, you can use `AsFirstEdge()` to convert the first returned edge into an `Edge`.

```go
requestConfig := &configuration.RequestConfig{Graph: "g1"}
response, _ := driver.Gql("MATCH ()-[e]->() RETURN e LIMIT 2", requestConfig)
edge, _ := response.Alias("e").AsFirstEdge()
jsonData, err := json.MarshalIndent(edge, "", "  ")
if err != nil {
  fmt.Println("Error:", err)
}
fmt.Println(string(jsonData))
```

<p tit="Output"></p> 
 
```
{
  "UUID": 2,
  "FromUUID": 6557243256474697731,
  "ToUUID": 7926337543195328514,
  "From": "U4",
  "To": "U2",
  "Schema": "Follows",
  "Values": {
    "Data": {
      "createdOn": "2024-02-10"
    }
  }
}
```

### AsGraph()

If a query returns paths, you can use `AsGraph()` to convert them into a `Graph`.

```go
requestConfig := &configuration.RequestConfig{Graph: "g1"}
response, _ := driver.Gql("MATCH p = ()-[]->() RETURN p LIMIT 2", requestConfig)
graph, _ := response.Alias("p").AsGraph()
fmt.Println("Unique nodes UUID:")
for _, node := range graph.Nodes {
  fmt.Println(node.UUID)
}
fmt.Println("Unique edges UUID:")
for _, edge := range graph.Edges {
  fmt.Println(edge.UUID)
}
fmt.Println("All paths:")
for i, path := range graph.Paths {
  fmt.Println("Path", i, "has nodes", path.NodeUUIDs, "and edges", path.EdgeUUIDs)
}
```

<p tit="Output"></p> 
 
```
Unique nodes UUID:
6557243256474697731
7926337543195328514
17870285520429383683
Unique edges UUID:
2
3
All paths:
Path 0 has nodes [6557243256474697731 7926337543195328514] and edges [2]
Path 1 has nodes [7926337543195328514 17870285520429383683] and edges [3]
```

### AsGraphSets()

If a query retrieves graphs (graphsets) in the database, you can use `AsGraphSets()` to convert them into a list of `GraphSet`s.

```go
response, _ := driver.Gql("SHOW GRAPH", nil)
graphsets, _ := response.Get(0).AsGraphSets()
for _, graphset := range graphsets {
  fmt.Println(graphset.Name)
}
```

<p tit="Output"></p> 
 
```
g1
miniCircle
amz
```

### AsSchemas()

If a query retrieves node or edge schemas defined in a graph, you can use `AsSchemas()` to convert them into a list of `Schema`s.

```go
requestConfig := &configuration.RequestConfig{Graph: "miniCircle"}
response, _ := driver.Gql("SHOW NODE SCHEMA", requestConfig)
schemas, _ := response.Get(0).AsSchemas()
for _, schema := range schemas {
  fmt.Println(schema.Name)
}
```

<p tit="Output"></p> 
 
```
default
account
celebrity
country
movie
```

### AsProperties()

If a query retrieves node or edge properties defined in a graph, you can use `AsProperties()` to convert them into a list of `Property`s.

```go
requestConfig := &configuration.RequestConfig{Graph: "miniCircle"}
response, _ := driver.Gql("SHOW NODE account PROPERTY", requestConfig)
properties, _ := response.Get(0).AsProperties()
for _, property := range properties {
  fmt.Println(property.Name)
}
```

<p tit="Output"></p> 
 
```
_id
gender
year
industry
name
```

### AsAttr()

If a query returns results like property values, expressions, or computed values, you can use `AsAttr()` to convert them into an `Attr`.

```go
requestConfig := &configuration.RequestConfig{Graph: "g1"}
response, _ := driver.Gql("MATCH (n:User) LIMIT 2 RETURN n.name", requestConfig)
attr, _ := response.Alias("n.name").AsAttr()
jsonData, err := json.MarshalIndent(attr, "", "  ")
if err != nil {
  fmt.Println("Error:", err)
}
fmt.Println(string(jsonData))
```

<p tit="Output"></p> 
 
```
{
  "Name": "n.name",
  "PropertyType": 7,
  "ResultType": 4,
  "Values": [
    "mochaeach",
    "Brainy"
  ]
}
```

### AsTable()

If a query uses the `table()` function to return a set of rows and columns, you can use `AsTable()` to convert them into a `Table`.

```go
requestConfig := &configuration.RequestConfig{Graph: "g1"}
response, _ := driver.Gql("MATCH (n:User) LIMIT 2 RETURN table(n._id, n.name) AS result", requestConfig)
table, _ := response.Get(0).AsTable()
jsonData, err := json.MarshalIndent(table, "", "  ")
if err != nil {
  fmt.Println("Error:", err)
}
fmt.Println(string(jsonData))
```

<p tit="Output"></p> 
 
```
{
  "Name": "result",
  "Headers": [
    {
      "Name": "n._id",
      "PropertyType": 7
    },
    {
      "Name": "n.name",
      "PropertyType": 7
    }
  ],
  "Rows": [
    [
      "U4",
      "mochaeach"
    ],
    [
      "U2",
      "Brainy"
    ]
  ]
}
```

### AsHDCGraphs()

If a query retrieves HDC graphs of a graph, you can use `AsHDCGraphs()` to convert them into a list of `HDCGraph`s.

```go
requestConfig := &configuration.RequestConfig{Graph: "g1"}
response, _ := driver.Gql("SHOW HDC GRAPH", requestConfig)
hdcGraphs, _ := response.Get(0).AsHDCGraphs()
for _, hdchdcGraph := range hdcGraphs {
  fmt.Println(hdchdcGraph.Name)
}
```

<p tit="Output"></p> 
 
```
g1_hdc_full
g1_hdc_nodes
```

### AsAlgos()

If a query retrieves algorithms installed on an HDC server of the database, you can use `AsAlgos()` to convert them into a list of `Algo`s.

```go
response, _ := driver.Gql("SHOW HDC ALGO ON 'hdc-server-1'", nil)
algos, _ := response.Get(0).AsAlgos()
for _, algo := range algos {
  if algo.Type != "algo" {
    continue
  }
  fmt.Println(algo.Name)
}
```

<p tit="Output"></p> 
 
```
bipartite
fastRP
```

### AsProjections()

If a query retrieves projections of a graph, you can use `AsProjections()` to convert them into a list of `Projection`s.

```go
requestConfig := &configuration.RequestConfig{Graph: "g1"}
response, _ := driver.Gql("SHOW PROJECTION", requestConfig)
projections, _ := response.Get(0).AsProjections()
for _, projection := range projections {
  fmt.Println(projection.Name)
}
```

<p tit="Output"></p> 
 
```
distG1
distG1_nodes
```

### AsIndexes()

If a query retrieves node or edge indexes of a graph, you can use `AsIndexes()` to convert them into a list of `Index`s.

```go
requestConfig := &configuration.RequestConfig{Graph: "g1"}
response, _ := driver.Gql("SHOW NODE INDEX", requestConfig)
indexes, _ := response.Get(0).AsIndexes()
for _, index := range indexes {
  jsonData, err := json.MarshalIndent(index, "", "  ")
  if err != nil {
    fmt.Println("Error:", err)
    continue
  }
  fmt.Println(string(jsonData))
}
```

<p tit="Output"></p> 
 
```
{
  "Id": "1",
  "Name": "User_name",
  "Properties": "name(1024)",
  "Schema": "User",
  "Status": "DONE",
  "DBType": 0
}
```

### AsPrivileges()

If a query retrieves privileges defined in Ultipa, you can use `AsPrivileges()` to convert them into a list of `Privilege`s.

```go
response, _ := driver.Uql("show().privilege()", nil)
privileges, _ := response.Get(0).AsPrivileges()

var graphPrivileges []string
var systemPrivileges []string

for _, privilege := range privileges {
  if privilege.Level == structs.GraphPrivilege {
    graphPrivileges = append(graphPrivileges, privilege.Name)
  } else {
    systemPrivileges = append(systemPrivileges, privilege.Name)
  }
}
```

<p tit="Output"></p> 
 
```
Graph Privileges: [READ INSERT UPSERT UPDATE DELETE CREATE_SCHEMA DROP_SCHEMA ALTER_SCHEMA SHOW_SCHEMA RELOAD_SCHEMA CREATE_PROPERTY DROP_PROPERTY ALTER_PROPERTY SHOW_PROPERTY CREATE_FULLTEXT DROP_FULLTEXT SHOW_FULLTEXT CREATE_INDEX DROP_INDEX SHOW_INDEX LTE UFE CLEAR_JOB STOP_JOB SHOW_JOB ALGO CREATE_PROJECT SHOW_PROJECT DROP_PROJECT CREATE_HDC_GRAPH SHOW_HDC_GRAPH DROP_HDC_GRAPH COMPACT_HDC_GRAPH SHOW_VECTOR_INDEX CREATE_VECTOR_INDEX DROP_VECTOR_INDEX SHOW_CONSTRAINT CREATE_CONSTRAINT DROP_CONSTRAINT]
System Privileges: [TRUNCATE COMPACT CREATE_GRAPH SHOW_GRAPH DROP_GRAPH ALTER_GRAPH CREATE_GRAPH_TYPE SHOW_GRAPH_TYPE DROP_GRAPH_TYPE TOP KILL STAT SHOW_POLICY CREATE_POLICY DROP_POLICY ALTER_POLICY SHOW_USER CREATE_USER DROP_USER ALTER_USER SHOW_PRIVILEGE SHOW_META SHOW_SHARD ADD_SHARD DELETE_SHARD REPLACE_SHARD SHOW_HDC_SERVER ADD_HDC_SERVER DELETE_HDC_SERVER LICENSE_UPDATE LICENSE_DUMP GRANT REVOKE SHOW_BACKUP CREATE_BACKUP SHOW_VECTOR_SERVER ADD_VECTOR_SERVER DELETE_VECTOR_SERVER]
```

### AsPolicies()

If a query retrieves policies (roles) defined in the database, you can use `AsPolicies()` to convert them into a list of `Policy`s.

```go
response, _ := driver.Gql("SHOW ROLE", nil)
policies, _ := response.Get(0).AsPolicies()
for _, policy := range policies {
  fmt.Println(policy.Name)
}
```

<p tit="Output"></p> 
 
```
manager
Tester
operator
superADM
```

### AsUsers()

If a query retrieves database users, you can use `AsUsers()` to convert them into a list of `User`s.

```go
response, _ := driver.Gql("SHOW USER", nil)
users, _ := response.Get(0).AsUsers()
for _, user := range users {
  fmt.Println(user.UserName)
}
```

<p tit="Output"></p> 
 
```
user01
root
johndoe
```

### AsProcesses()

If a query retrieves processes running in the database, you can use `AsProcesses()` to convert them into a list of `Process`s.

```go
response, _ := driver.Gql("TOP", nil)
processes, _ := response.Get(0).AsProcesses()
for _, process := range processes {
  jsonData, err := json.MarshalIndent(process, "", "  ")
  if err != nil {
    fmt.Println("Error:", err)
    continue
  }
  fmt.Println(string(jsonData))
}
```

<p tit="Output"></p> 
 
```
{
  "process_id": "3145773",
  "status": "RUNNING",
  "process_query": "MATCH p=()-{1,5}() RETURN p",
  "duration": "2"
}
```

### AsJobs()

If a query retrieves jobs of a graph, you can use `AsJobs()` to convert them into a list of `Job`s.

```go
requestConfig := &configuration.RequestConfig{Graph: "g1"}
response, _ := driver.Gql("SHOW JOB", requestConfig)
jobs, _ := response.Get(0).AsJobs()
for _, job := range jobs {
  jsonData, err := json.MarshalIndent(job, "", "  ")
  if err != nil {
    fmt.Println("Error:", err)
    continue
  }
  fmt.Println(string(jsonData))
}
```

<p tit="Output"></p> 
 
```
{
  "job_id": "6",
  "graph_name": "g1",
  "type": "CREATE_INDEX",
  "query": "CREATE INDEX User_name ON NODE User (name)",
  "status": "FINISHED",
  "err_msg": "",
  "result": null,
  "start_time": "2025-09-30 18:23:48",
  "end_time": "2025-09-30 18:23:49",
  "progress": ""
}
{
  "job_id": "6_1",
  "graph_name": "g1",
  "type": "CREATE_INDEX",
  "query": "",
  "status": "FINISHED",
  "err_msg": "",
  "result": null,
  "start_time": "2025-09-30 18:23:49",
  "end_time": "2025-09-30 18:23:49",
  "progress": ""
}
{
  "job_id": "6_2",
  "graph_name": "g1",
  "type": "CREATE_INDEX",
  "query": "",
  "status": "FINISHED",
  "err_msg": "",
  "result": null,
  "start_time": "2025-09-30 18:23:49",
  "end_time": "2025-09-30 18:23:49",
  "progress": ""
}
```

## Full Example

```go
package main

import (
	"encoding/json"
	"fmt"
	"log"

	"github.com/ultipa/ultipa-go-driver/v5/sdk"
	"github.com/ultipa/ultipa-go-driver/v5/sdk/configuration"
)

func main() {
	config := &configuration.UltipaConfig{
        // URI example: Hosts: []string{"xxxx.us-east-1.cloud.ultipa.com:60010"},
		Hosts:    []string{"10.xx.xx.xx:60010"},
		Username: "<username>",
		Password: "<password>",
	}

	driver, err := sdk.NewUltipaDriver(config)
	if err != nil {
		log.Fatalln("Failed to connect to Ultipa:", err)
	}

	requestConfig := &configuration.RequestConfig{Graph: "g1"}
	response, _ := driver.Gql("MATCH (n:User) RETURN n LIMIT 2", requestConfig)
	nodes, _, _ := response.Alias("n").AsNodes()
	for _, node := range nodes {
		jsonData, err := json.MarshalIndent(node, "", "  ")
		if err != nil {
			fmt.Println("Error:", err)
			continue
		}
		fmt.Println(string(jsonData))
	}
}
```
