# Query the Database

# Querying Methods

After <a target="_blank" href="/docs/drivers/go-connect">connecting to the database</a>, you can use the driver's `Gql()` or `Uql()` method to execute GQL or UQL queries to fully interact with your database.

> **GQL** (ISO-standard Graph Query Language) and **UQL** (Ultipa’s proprietary query language) can both operate the database. You don’t need to be an expert in GQL or UQL to use the driver, but having a basic understanding will make it easier. To learn more, see <a target="_blank" href="/docs/quick-start/what-is-gql">GQL Quick Start</a>, <a target="_blank" href="/docs/gql">GQL documentation</a>, or <a target="_blank" href="/docs/uql">UQL documentation</a>.

| <div table-width="10">Method</div> | Parameters | <div table-width="14">Returns</div> |
| -- | -- | -- |
| `Gql()` | <ul><li><code>gql: string</code>: The GQL query to be executed.</li><li><code>config: *configuration.RequestConfig</code>: Request configuration.</li></ul> | `Response`, `error` |
| `Uql()` | <ul><li><code>uql: string</code>: The UQL query to be executed.</li><li><code>config: *configuration.RequestConfig</code>: Request configuration.</li></ul> | `Response`, `error` |

### Request Configuration

`RequestConfig` includes the following fields:

| <div table-width="18">Field</div> | <div table-width="10">Type</div> | <div table-width="8">Default</div> | Description |
|  ----  | ----  | ----  | ---- |
| `Graph` | string | / | Name of the graph to use. If not specified, the graph defined in `UltipaConfig.DefaultGraph` will be used. |
| `Timeout` | int32 | / | Request timeout threshold (in seconds); it overwrites the `UltipaConfig.Timeout`. |
| `Host` | string | / | Specifies a host in a database cluster to execute the request. |
| `Thread` | uint32 | / | Number of threads for the request. |
| `Timezone` | string | / | Name of the timezone, e.g., `Europe/Paris`. Defaults to the local timezone if not specified. |
| `TimezoneOffset` | string | / | The offset from UTC, specified in the format `±<hh>:<mm>` or `±<hh><mm>` (e.g., `+02:00`, `-0430`). If both `Timezone` and `TimezoneOffset` are provided, `TimezoneOffset` takes precedence. |

### Graph Selection

Since each Ultipa database instance can host multiple graphs, **most queries—including CRUD operations—require specifying the target graph.**

There are two ways to specify the graph for a request:

1. **Default graph at connection:** When connecting to the database, you can optionally set a default graph using `UltipaConfig.DefaultGraph`.
2. **Per-Request Graph:** For a specific query, set `RequestConfig.Graph` to select the graph. This overrides any `UltipaConfig.DefaultGraph`.

## Create a Graph

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

## Insert Nodes and Edges

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

## Update Nodes and Edges

To update a node's property value in a graph:

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
	}

	driver, err := sdk.NewUltipaDriver(config)
	if err != nil {
		log.Fatalln("Failed to connect to Ultipa:", err)
	}

	// Updates name of the user U1 in the graph 'g1'
	requestConfig := &configuration.RequestConfig{Graph: "g1"}
	response, _ := driver.Gql("MATCH (n:User {_id: 'U1'}) SET n.name = 'RowLock99' RETURN n", requestConfig)
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

<p tit="Output"></p> 

```
{
  "ID": "U1",
  "UUID": 15276212135063977986,
  "Schema": "User",
  "Values": {
    "Data": {
      "name": "RowLock99"
    }
  }
}
```

## Delete Nodes and Edges

To delete an edge from a graph:

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

    // Deletes the edge between users U3 and U5 in the graph 'g1'
    requestConfig := &configuration.RequestConfig{Graph: "g1"}
	response, _ := driver.Gql("MATCH ({_id: 'U1'})-[e]-({_id: 'U5'}) DELETE e", requestConfig)
	fmt.Println(response.Status.Code)
}
```

<p tit="Output"></p> 

```
SUCCESS
```

## Retrieve Nodes

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
	}

	driver, err := sdk.NewUltipaDriver(config)
	if err != nil {
		log.Fatalln("Failed to connect to Ultipa:", err)
	}

	// Retrieves 3 User nodes from the graph 'g1'
    requestConfig := &configuration.RequestConfig{Graph: "g1"}
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

## Retrieve Edges

To retrieve edges from a graph:

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
	}

	driver, err := sdk.NewUltipaDriver(config)
	if err != nil {
		log.Fatalln("Failed to connect to Ultipa:", err)
	}

	// Retrieves all incoming Follows edges of the user U2 from the graph 'g1'
	requestConfig := &configuration.RequestConfig{Graph: "g1"}
	response, _ := driver.Gql("MATCH (:User {_id: 'U2'})<-[e:Follows]-() RETURN e", requestConfig)
	edges, _, _ := response.Alias("e").AsEdges()
	for _, edge := range edges {
		jsonData, err := json.MarshalIndent(edge, "", "  ")
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
  "UUID": 1,
  "FromUUID": 15276212135063977986,
  "ToUUID": 7926337543195328514,
  "From": "U1",
  "To": "U2",
  "Schema": "Follows",
  "Values": {
    "Data": {
      "createdOn": "2024-01-05"
    }
  }
}
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

## Retrieve Paths

To retrieve paths from a graph:

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
	}

	driver, err := sdk.NewUltipaDriver(config)
	if err != nil {
		log.Fatalln("Failed to connect to Ultipa:", err)
	}

	// Retrieves 1-step paths from user U1 in the graph 'g1'
	requestConfig := &configuration.RequestConfig{Graph: "g1"}
	response, _ := driver.Gql(`
		MATCH p = (u)-[]-()
    	WHERE u._id = "U1"
    	RETURN p`, requestConfig)
	graph, _ := response.Alias("p").AsGraph()
	for _, path := range graph.GetPath() {
		jsonData, err := json.MarshalIndent(path, "", "  ")
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
  "NodeUUIDs": [
    15276212135063977986,
    7926337543195328514
  ],
  "EdgeUUIDs": [
    1
  ],
  "Nodes": {
    "15276212135063977986": {
      "ID": "U1",
      "UUID": 15276212135063977986,
      "Schema": "User",
      "Values": {
        "Data": {
          "name": "RowLock99"
        }
      }
    },
    "7926337543195328514": {
      "ID": "U2",
      "UUID": 7926337543195328514,
      "Schema": "User",
      "Values": {
        "Data": {
          "name": "Brainy"
        }
      }
    }
  },
  "Edges": {
    "1": {
      "UUID": 1,
      "FromUUID": 15276212135063977986,
      "ToUUID": 7926337543195328514,
      "From": "U1",
      "To": "U2",
      "Schema": "Follows",
      "Values": {
        "Data": {
          "createdOn": "2024-01-05"
        }
      }
    }
  }
}
```

## Streaming Return

To efficiently process large query results without loading them entirely into memory, use the streaming methods `GqlStream()` and `UqlStream()`, which deliver results incrementally.

| <div table-width="16">Method</div> | Parameters | <div table-width="12">Returns</div> |
| -- | -- | -- |
| `GqlStream()` | <ul><li><code>gql: string</code>: The GQL query to be executed.</li><li><code>cb: func(*http.Response) error</code>: A callback function that processes the <code>http.Response</code> as it streams in.</li><li><code>config: *configuration.RequestConfig</code>: Request configuration.</li></ul> | `error` |
| `UqlStream()` | <ul><li><code>uql: string</code>: The UQL query to be executed.</li><li><code>cb: func(*http.Response) error</code>: A callback function that processes the <code>http.Response</code> as it streams in.</li><li><code>config: *configuration.RequestConfig</code>: Request configuration.</li></ul> | `error` |

To stream nodes from a large graph:

<p tit="Go"></p> 

```go
package main

import (
	"fmt"
	"log"

	"github.com/ultipa/ultipa-go-driver/v5/sdk"
	"github.com/ultipa/ultipa-go-driver/v5/sdk/configuration"
	sdkhttp "github.com/ultipa/ultipa-go-driver/v5/sdk/http" // rename to avoid conflict
)

func main() {
	config := &configuration.UltipaConfig{
        // URI example: Hosts: []string{"xxxx.us-east-1.cloud.ultipa.com:60010"},
		Hosts:    []string{"10.xx.xx.xx:60010"},
		Username: "<username>",
		Password: "<password>"	
    }

	driver, err := sdk.NewUltipaDriver(config)
	if err != nil {
		log.Fatalln("Failed to connect to Ultipa:", err)
	}

	// Retrieves all account nodes from the graph 'amz'

	requestConfig := &configuration.RequestConfig{Graph: "amz"}

	var totalNodeCount int64 = 0
	fmt.Println("Stream started.")

	cb := func(response *sdkhttp.Response) error {
		nodes, _, _ := response.Get(0).AsNodes()
		chunkCount := int64(len(nodes))
		totalNodeCount += chunkCount
		for _, node := range nodes {
			fmt.Println(node.GetID())
		}
		fmt.Println("Node count so far:", totalNodeCount)

		return nil
	}

	err = driver.GqlStream("MATCH (n:account) RETURN n", cb, requestConfig)
	if err != nil {
		log.Fatalln("Stream error:", err)
	}

	fmt.Println("Stream ended.")
}
```

<p tit="Output"></p> 

```
Stream started.
ULTIPA8000000000000426
ULTIPA8000000000000439
...
Node count so far: 1024
ULTIPA80000000000003FB
ULTIPA8000000000000431
...
Node count so far: 2048
ULTIPA800000000000041A
ULTIPA8000000000000417
...
...
...
ULTIPA8000000000000403
Node count so far: 96114145
Stream ended.
```
