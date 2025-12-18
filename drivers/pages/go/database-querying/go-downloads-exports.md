# Downloads and Exports

This section introduces methods on a `Connection` object for downloading algorithm result files and exporting nodes and edges from a graphset. 

Each example focuses solely on the method's usage. For a complete code example, please refer to the <a href="#Full-Example">full example</a>.

## DownloadAlgoResultFile()

Downloads one result file from an algorithm task in the current graph.
 
**Parameters:**

- `string`: Name of the file.
- `string`: ID of the algorithm task that generated the file.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.
- `func`: Function that receives the request result.

**Returns:**

- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

```go
requestConfig := &configuration.RequestConfig{
  UseMaster: true,
  GraphName: "miniCircle",
}

// Runs the Louvain algorithm in graphset 'miniCircle' and prints the task ID

_, err1 := conn.Uql("algo(louvain).params({phase1_loop_num: 20, min_modularity_increase: 0.001}).write({file:{filename_community_id: 'communityID', filename_ids: 'ids', filename_num: 'num'}})",
  requestConfig)
if err1 != nil {
  println(err1)
}

time.Sleep(5 * time.Second)

myTask, _ := conn.ShowTask("louvain", structs.TaskStatusDone, requestConfig)
myTaskID := myTask[0].TaskInfo.TaskID
println("TaskID is:", myTaskID)

receive := func(data []byte) error {
  var fileName = "communityID"
  filePath := fileName
  file, err := os.Create(filePath)
  if err != nil {
    return err
  }
  defer file.Close()
  _, err = file.Write(data)
  if err != nil {
    return err
  }
  return nil
}

myDownload := conn.DownloadAlgoResultFile("communityID", utils.JSONString(myTaskID), requestConfig, receive)
if myDownload != nil {
  println(myDownload)
} else {
  println("File is downloaded")
}
```

<p tit="Output"></p> 
 
```
TaskID is: 65483
File is downloaded
```

## DownloadAllAlgoResultFile()

Downloads all result files from an algorithm task in the current graph.
 
**Parameters:**

- `string`: ID of the algorithm task that generated the file(s).
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.
- `func`: Function that receives the request result.

**Returns:**

- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

```go
requestConfig := &configuration.RequestConfig{
  UseMaster: true,
  GraphName: "miniCircle",
}

// Runs the Louvain algorithm in graphset 'miniCircle' and prints the task ID

_, err1 := conn.Uql("algo(louvain).params({phase1_loop_num: 20, min_modularity_increase: 0.001}).write({file:{filename_community_id: 'communityID', filename_ids: 'ids', filename_num: 'num'}})",
  requestConfig)
if err1 != nil {
  println(err1)
}

time.Sleep(5 * time.Second)

myTask, _ := conn.ShowTask("louvain", structs.TaskStatusDone, requestConfig)
myTaskID := myTask[0].TaskInfo.TaskID
println("TaskID is:", myTaskID)

receive := func(data []byte, filename string) error {
  file, err := os.OpenFile(filename, os.O_CREATE|os.O_WRONLY|os.O_APPEND, os.ModePerm)
  if err != nil {
    panic(err)
  }
  defer file.Close()
  _, err = file.Write(data)
  return nil
}

myDownload := conn.DownloadAllAlgoResultFile(utils.JSONString(myTaskID), requestConfig, receive)
if myDownload != nil {
  println(myDownload)
} else {
  println("Files are downloaded")
}
```

<p tit="Output"></p> 
 
```
TaskID is: 65838
Files are downloaded
```

## Export()

Exports nodes and edges from the current graph.

**Parameters:**

- `ExportRequest`: Configurations for the export request, including `dbType:ULTIPA.DBType`, `schemaName:string`, `limit:number` and `selectPropertiesName:string[]`.
- `Listener`: Listener for the export process.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

```go
// Exports 10 nodes of schema 'account' with selected properties in graphset 'miniCircle' and prints the result
type MyListener struct {
  Properties []string
}

func (l *MyListener) ProcessNodes(nodes []*structs.Node) error {
  file, err := os.Create("node.csv")
  if err != nil {
    panic(err)
  }
  defer file.Close()
  writer := csv.NewWriter(file)
  defer writer.Flush()
  if nodes != nil {
    for _, node := range nodes {
      var sliceString []string
      for _, key := range l.Properties {
        vv := ConvertDataToString(node.Values.Data[key])
        sliceString = append(sliceString, vv)
      }
      err := writer.Write(sliceString)
      if err != nil {
        panic(err)
      }
    }
  }
  return nil
}

func (l *MyListener) ProcessEdges(edges []*structs.Edge) error {
  file, err := os.Create("edge.csv")
  if err != nil {
    panic(err)
  }
  defer file.Close()
  writer := csv.NewWriter(file)
  defer writer.Flush()
  if edges != nil {
    for _, node := range edges {
      var sliceString []string
      for _, key := range l.Properties {
        vv := ConvertDataToString(node.Values.Data[key])
        sliceString = append(sliceString, vv)
      }
      err := writer.Write(sliceString)
      if err != nil {
        panic(err)
      }
    }
  }
  return nil
}

func ConvertDataToString(value interface{}) string {
  switch value.(type) {
  case int32:
    v := value.(int32)
    str := strconv.FormatInt(int64(v), 10)
    return str
  case string:
    v := value.(string)
    return v
  case int64:
    v := value.(string)
    return v
  case []interface{}:
    var slic []string
    for _, val := range value.([]interface{}) {
      if vv, ok := val.(string); ok {
        slic = append(slic, vv)
      }
      if vv, ok := val.(int32); ok {
        vvv := strconv.FormatInt(int64(vv), 10)
        slic = append(slic, vvv)
      }
    }
    result := strings.Join(slic, ",")
    return result
  }
  return ""
}

func main() {

  config, _ := configuration.NewUltipaConfig(&configuration.UltipaConfig{
    Hosts:    []string{"192.168.1.85:60611", "192.168.1.87:60611", "192.168.1.88:60611"},
    Username: "root",
    Password: "root",
  })

  conn, _ := sdk.NewUltipa(config)

  requestConfig := &configuration.RequestConfig{
    UseMaster: true,
    GraphName: "miniCircle",
  }

  var request = ultipa.ExportRequest{
    Schema:           "account",
    SelectProperties: []string{"_id", "_uuid", "year", "name"},
    DbType:           ultipa.DBType_DBNODE,
    Limit:            10,
  }

  myExport := conn.Export(&request, &MyListener{request.SelectProperties}, requestConfig)
  if myExport != nil {
    println(myExport)
  } else {
    println("File is exported")
  }
```

<p tit="Output"></p> 
 
```
File is exported
```

## Full Example

```go
package main

import (
  "os"
  "time"

  "github.com/ultipa/ultipa-go-sdk/sdk"
  "github.com/ultipa/ultipa-go-sdk/sdk/configuration"
  "github.com/ultipa/ultipa-go-sdk/sdk/structs"
  "github.com/ultipa/ultipa-go-sdk/utils"
)

func main() {

  // Connection configurations
  //URI example: Hosts:=[]string{"mqj4zouys.us-east-1.cloud.ultipa.com:60010"}
  config, _ := configuration.NewUltipaConfig(&configuration.UltipaConfig{
    Hosts:    []string{"192.168.1.85:60061", "192.168.1.86:60061", "192.168.1.87:60061"},
    Username: "***",
    Password: "***",
  })

  // Establishes connection to the database
  conn, _ := sdk.NewUltipa(config)

  // Request configurations
  requestConfig := &configuration.RequestConfig{
    UseMaster: true,
    GraphName: "miniCircle",
  }

  // Runs the Louvain algorithm and prints the task ID
  _, err1 := conn.Uql("algo(louvain).params({phase1_loop_num: 20, min_modularity_increase: 0.001}).write({file:{filename_community_id: 'communityID', filename_ids: 'ids', filename_num: 'num'}})",
    requestConfig)
  if err1 != nil {
    println(err1)
  }

  time.Sleep(5 * time.Second)

  myTask, _ := conn.ShowTask("louvain", structs.TaskStatusDone, requestConfig)
  myTaskID := myTask[0].TaskInfo.TaskID
  println("TaskID is:", myTaskID) 

  // Downloads all files generated by the above algorithm task and prints the download response
  receive := func(data []byte, filename string) error {
    file, err := os.OpenFile(filename, os.O_CREATE|os.O_WRONLY|os.O_APPEND, os.ModePerm)
    if err != nil {
      panic(err)
    }
    defer file.Close()
    _, err = file.Write(data)
    return nil
  }

  myDownload := conn.DownloadAllAlgoResultFile(utils.JSONString(myTaskID), requestConfig, receive)
  if myDownload != nil {
    println(myDownload)
  } else {
    println("Files are downloaded")
  }

}
```
