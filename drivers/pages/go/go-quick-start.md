# Go

## Quick Start

The Ultipa Go driver is the official library that allows you to interact with Ultipa from a Go application. It requires **Go 1.13 or later**.

## Install the Driver

After initializing a local Go module, you can add the latest <a target="_blank" href="https://pkg.go.dev/github.com/ultipa/ultipa-go-driver/v5">Ultipa Go driver</a> as a dependency:

```bash
go get github.com/ultipa/ultipa-go-driver/v5@latest
```

## Connect to Database

You need a running Ultipa database to use the driver. The easiest way to get an instance is via <a target="_blank" href="http://cloud.ultipa.com/">Ultipa Cloud</a> (free trial available), or you can use an on-premises deployment if you already have one.

Creates a connection and tests the connection:

<p tit="Go"></p> 

```go
package main

import (
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

    // Tests the connection
	isSuccess, _ := driver.Test(nil)
	println("Connection succeeds:", isSuccess)
}
```

<p tit="Output"></p> 

```
Connection succeeds: true
```

<a target="_blank" href="/docs/drivers/go-connect">More info on database connection →</a>

## Query the Database

**GQL** is the international standardized query language for graph databases. You can use the driver's `Gql()` method to send GQL queries and fully operate the database. If you're new to GQL, check out the <a target="_blank" href="/docs/quick-start/what-is-gql">GQL Quick Start</a> or the <a target="_blank" href="/docs/gql">GQL documentation</a> for a detailed orientation.

<a target="_blank" href="/docs/drivers/go-query">More info on querying the database →</a>

### Create a Graph

To create a new graph in the database:

<p tit="Go"></p> 

```go
package main

import (
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

    // Creates a new open graph named 'g1'
	response, _ := driver.Gql("CREATE GRAPH g1 ANY", nil)
	fmt.Println(response.Status.Code)
}
```

<p tit="Output"></p> 

```
SUCCESS
```

### Insert Nodes and Edges

To insert nodes and edges into a graph:

<p tit="Go"></p> 

```go
package main

import (
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
		DefaultGraph: "g1", // Sets the default graph to 'g1'
	}

	driver, err := sdk.NewUltipaDriver(config)
	if err != nil {
		log.Fatalln("Failed to connect to Ultipa:", err)
	}

	// Inserts nodes and edges into graph the 'g1'
	response, _ := driver.Gql(`INSERT 
		(u1:User {_id: 'U1', name: 'rowlock'}),
		(u2:User {_id: 'U2', name: 'Brainy'}),
		(u3:User {_id: 'U3', name: 'purplechalk'}),
		(u4:User {_id: 'U4', name: 'mochaeach'}),
		(u5:User {_id: 'U5', name: 'lionbower'}),
		(u1)-[:Follows {createdOn: DATE('2024-01-05')}]->(u2),
		(u4)-[:Follows {createdOn: DATE('2024-02-10')}]->(u2),
		(u2)-[:Follows {createdOn: DATE('2024-02-01')}]->(u3),
		(u3)-[:Follows {createdOn: DATE('2024-05-03')}]->(u5)`, nil)
	fmt.Println(response.Status.Code)
}
```

<p tit="Output"></p> 

```
SUCCESS
```

### Retrieve Nodes

To retrieve nodes from a graph:

<p tit="Go"></p> 

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
		DefaultGraph: "amz", // Optional; sets the default graph as 'amz'
	}

	driver, err := sdk.NewUltipaDriver(config)
	if err != nil {
		log.Fatalln("Failed to connect to Ultipa:", err)
	}

	// Retrieves 3 User nodes from the graph 'g1'
	requestConfig := &configuration.RequestConfig{
		Graph: "g1", // Sets the graph for the specific request as 'g1'
	}
	response, _ := driver.Gql("MATCH (u:User) RETURN u LIMIT 3", requestConfig)
	nodes, _, _ := response.Alias("u").AsNodes()
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
{
  "ID": "U5",
  "UUID": 14771808976798482436,
  "Schema": "User",
  "Values": {
    "Data": {
      "name": "lionbower"
    }
  }
}
```

## Process Query Results

The driver's `Gql()` method returns a `Response` containing the raw query results from the database and execution metadata. To use the query results in your application, you need to **extract** and **convert** them into a usable data structure.

The above node retrieval example demonstrates this by using the `Alias()` method to extract the query results and the `AsNodes()` method to convert them into a list of `Node`s:

<p tit="Go"></p> 

```go
// Retrieves 3 User nodes from the graph 'g1'
requestConfig := &configuration.RequestConfig{
  Graph: "g1", // Sets the graph for the specific request as 'g1'
}
response, _ := driver.Gql("MATCH (u:User) RETURN u LIMIT 3", requestConfig)
nodes, _, _ := response.Alias("u").AsNodes()
for _, node := range nodes {
  jsonData, err := json.MarshalIndent(node, "", "  ")
  if err != nil {
    fmt.Println("Error:", err)
    continue
  }
  fmt.Println(string(jsonData))
}
```

The conversion method you choose depends on the type of query results you receive, such as nodes, edges, paths, property values, etc. For a complete list of available conversion methods and examples, refer to <a target="_blank" href="/docs/drivers/go-query-results">here</a>.

## Convenience Methods

In addition to the `Gql()` method for executing custom GQL queries, the driver provides a suite of **convenience methods** to simplify common database operations. These methods eliminate the need to write full queries for tasks in the following categories:

- <a target="_blank" href="/docs/drivers/go-graph">Graph</a>: Show, create, alter, and delete graphs in a database instance.
- <a target="_blank" href="/docs/drivers/go-schema-and-property">Schema and Property</a>: Define and modify node and edge schemas and their properties.
- <a target="_blank" href="/docs/drivers/go-data-insertion">Data Insertion</a>: Insert nodes and edges into a graph efficiently.
- <a target="_blank" href="/docs/drivers/go-query-acceleration">Query Acceleration</a>: Manage indexes and full-text indexes to optimize query performance.
- <a target="_blank" href="/docs/drivers/go-hdc-graph-and-algorithm">HDC Graph and Algorithm</a>: Manage HDC graphs and run algorithms on them.
- <a target="_blank" href="/docs/drivers/go-process-and-job">Process and Job</a>: Monitor running processes and manage backend jobs.
- <a target="_blank" href="/docs/drivers/go-access-control">Access Control</a>: Configure user privileges and policies (roles).
- <a target="_blank" href="/docs/drivers/go-data-export">Data Export</a>: Export nodes and edges from a graph.

For example, the `ShowGraph()` retrieves all graphs in the database, it returns a list of `GraphSet`s:

<p tit="Go"></p> 

```go
package main

import (
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

	// Retrieves all graphs in the database
	graphs, _ := driver.ShowGraph(nil)
	for _, graph := range graphs {
		println(graph.Name)
	}
}

```

<p tit="Output"></p> 

```
g1
miniCircle
amz
```

For example, the `InsertNodes()` method allows you to insert nodes into a graph by providing the target schema and a list of `Node`s:

<p tit="Go"></p> 

```go
package main

import (
	"fmt"
	"log"

	"github.com/ultipa/ultipa-go-driver/v5/sdk"
	"github.com/ultipa/ultipa-go-driver/v5/sdk/configuration"
	"github.com/ultipa/ultipa-go-driver/v5/sdk/structs"
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

	// Inserts two User nodes into the graph 'g1'

	requestConfig := &configuration.RequestConfig{Graph: "g1"}
	insertRequestConfig := &configuration.InsertRequestConfig{RequestConfig: requestConfig}

	nodes := []*structs.Node{
		{
			ID: "U6",
			Values: &structs.Values{
				Data: map[string]interface{}{
					"name": "Alice",
					"age":  28,
				},
			},
		},
		{
			ID: "U7",
			Values: &structs.Values{
				Data: map[string]interface{}{
					"name": "Quars",
				},
			},
		},
	}

	response, _ := driver.InsertNodes("User", nodes, insertRequestConfig)
	fmt.Println(response.Status.Code)
}

```

<p tit="Output"></p> 

```
SUCCESS
```
