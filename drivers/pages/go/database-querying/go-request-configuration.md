# Database Querying

## Request Configuration

All querying methods support an optional request configuration parameter (`RequestConfi`g or `InsertRequestConfig`) to customize the behavior of requests made to the database. This parameter allows you to specify various settings, such as graphset name, timeout, and host, to tailor your requests according to your needs.

## RequestConfig

`RequestConfig` defines the information needed when sending non-insert type of requests to the database.

```go
package main

import (
  "log"

  "github.com/ultipa/ultipa-go-sdk/sdk"
  "github.com/ultipa/ultipa-go-sdk/sdk/configuration"
)

func main() {

  config, _ := configuration.NewUltipaConfig(&configuration.UltipaConfig{
    Hosts:    []string{"192.168.1.85:60061", "192.168.1.86:60061", "192.168.1.87:60061"},
    Username: "***",
    Password: "***",
  })

  conn, _ := sdk.NewUltipa(config)

  requestConfig := &configuration.RequestConfig{
    GraphName:   "miniCircle",
    RequestType: configuration.RequestType_Task,
  }

  uqlResult, err := conn.Uql("find().nodes({@account.year > 2000}) as nodes return nodes{*} limit 5", requestConfig)

  log.Print(uqlResult, err)

}
```

`RequestConfig` has the following fields:

|  Item | Type  | Default Value |  Description   |
|  ----  | ----  | ----  | ---- |
| `GraphName` | string |  | Name of the graph to use. If not set, use the `graphSetName` configured when establishing the connection. | 
| `Timeout` | int32 | 1000 | Request timeout threshold in seconds. |
| `ClusterId` | string |  | Specifies the cluster to use. | 
| `Host` | string |  | Sends the request to a designated host node, or to a random host node if not set. |
| `UseMaster` | bool | FALSE | Sends the request to the leader node to guarantee consistency read if set to true. |
| `UseControl` | bool | FALSE | Sends the request to the control node if set to true. |
| `RequestType` | RequestType or int32 | 0 | Sends the requset to a node according to the request type: <br>`RequestType_Write` or 1: to leader node <br>`RequestType_Task` or 2: to algo<br>`RequestType_Normal` or 3: to a random host  |
| `Uql` | string |  | UQL for internal program | 
| `Timezone` | string |  | The time zone to use. |
| `TimezoneOffset` | int64 |  | The amount of time that the time zone in use differs from UTC in seconds. |
| `ThreadNum` | uint32 |  | Number of threads. |
| `MaxPkgSize` | int | 10M | Max package size in bytes, for both sending and receiving. |

## InsertRequestConfig

`InsertRequestConfig` defines the settings needed when sending data insertion or deletion requests to the database.

```go
package main

import (
  ultipa "github.com/ultipa/ultipa-go-sdk/rpc"
  "github.com/ultipa/ultipa-go-sdk/sdk"
  "github.com/ultipa/ultipa-go-sdk/sdk/configuration"
  "github.com/ultipa/ultipa-go-sdk/sdk/structs"
)

func main() {

  config, _ := configuration.NewUltipaConfig(&configuration.UltipaConfig{
    Hosts:    []string{"192.168.1.85:60061", "192.168.1.86:60061", "192.168.1.87:60061"},
    Username: "***",
    Password: "***",
  })

  conn, _ := sdk.NewUltipa(config)

  requestConfig := &configuration.RequestConfig{
    GraphName: "test",
  }
  insertRequestConfig := &configuration.InsertRequestConfig{
    RequestConfig: requestConfig,
    InsertType:    ultipa.InsertType_OVERWRITE,
  }

  var nodes []*structs.Node

  newNode1 := structs.NewNode()
  newNode1.Schema = "card"
  newNode1.ID = "ULTIPA8000000000000001"
  newNode1.Set("amount", float32(3235.2))
  nodes = append(nodes, newNode1)

  newNode2 := structs.NewNode()
  newNode2.Schema = "client"
  newNode2.ID = "ULTIPA8000000000000007"
  newNode2.Set("level", int32(77))
  nodes = append(nodes, newNode2)

  conn.InsertNodesBatchAuto(nodes, insertRequestConfig)

}
```

`InsertRequestConfig` has the following fields:

|  Item | Type  | <div table-width="12">Default Value</div> |  Description   |
|  ----  | ----  | ----  | ---- |
| `GraphName` | string |  | Name of the graph to use. If not set, use the `graphSetName` configured when establishing the connection. | 
| `Timeout` | int32 | 1000 | Request timeout threshold in seconds. |
| `ClusterId` | string |  | Specifies the cluster to use. | 
| `Host` | string |  | Sends the request to a designated host node, or to a random host node if not set. |
| `UseMaster` | bool | FALSE | Sends the request to the leader node to guarantee consistency read if set to true. |
| `UseControl` | bool | FALSE | Sends the request to the control node if set to true. |
| `RequestType` | RequestType or int32 | 0 | Sends the requset to a node according to the request type: <br>`RequestType_Write` or 1: to leader node <br>`RequestType_Task` or 2: to algo<br>`RequestType_Normal` or 3: to a random host |
| `Uql` | string |  | UQL for internal program. | 
| `Timezone` | string |  | The time zone to use. |
| `TimezoneOffset` | int64 |  | The amount of time that the time zone in use differs from UTC in seconds. |
| `ThreadNum` | uint32 |  | Number of threads. |
| `MaxPkgSize` | int | 10M | Max package size in bytes, for both sending and receiving. |
| `InsertType` | ultipa.InsertType or int32 | 0 | Insert mode:<br>`InsertType_NORMAL` (or 0)<br>`InsertType_OVERWRITE` (or 1)<br> `InsertType_UPSERT` (or 2) |
| `CreateNodeIfNotExist` | bool | FALSE | Whether to create start/end nodes of an edge if the end nodes do not exist in the graph. |
| `Silent` | bool  | FALSE |  Whether to keep slient after success insertion, i.e., whether to return the inserted nodes or edges.  |

