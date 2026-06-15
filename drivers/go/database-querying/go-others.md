# Others

This section introduces methods on a `Connection` object for checking the database server statistics and the driver connection.

Each example focuses solely on the method's usage. For a complete code example, please refer to the <a href="#Full-Example">full example</a>.

## Stats()

Retrieves database server statistics.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `Stat`: The retrieved server statistics.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

```go
myStat, err := conn.Stats(nil)
if err != nil {
  println(err)
}
println("CPU usage:", myStat.CPUUsage, "%")
println("Memory usage:", myStat.MemUsage)
println("Expiration date:", myStat.ExpiredDate)
println("CPU cores:", myStat.CPUCores)
println("Company:", myStat.Company)
println("Server type:", myStat.ServerType)
println("Version:", myStat.Version)
```

<p tit="Output"></p> 
 
```
CPU usage: 16.933905 %
Memory usage: 11562.433594
Expiration date: 2024-12-26 23:59:59
CPU cores: 80
Company: ultipa
Server type: CT
Version: htap_beta.4.5.5-b4.5.0-tv-ui
```

## Test()

Tests driver and database server connection.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `Response`: Result of the request.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

```go
myTest, err := conn.Test(nil)
if err != nil {
  println(err)
}
println("Test succeeds:", myTest.IsSuccess())
```

<p tit="Output"></p> 
 
```
Test succeeds: true
```

## Full Example

```go
package main

import (
  "github.com/ultipa/ultipa-go-sdk/sdk"
  "github.com/ultipa/ultipa-go-sdk/sdk/configuration"
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
  }

  // Test connection
  myTest, err := conn.Test(requestConfig)
  if err != nil {
    println(err)
  }
  println("Test succeeds:", myTest.IsSuccess())
  
};
```