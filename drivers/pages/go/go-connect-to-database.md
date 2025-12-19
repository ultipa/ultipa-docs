## Connect to Database

Once you have installed the driver and set up an Ultipa instance, you can connect your application to the database.

## Create a Connection

Creates a connection by instantiating `NewUltipaDriver()` with `UltipaConfig`, which holds the configuration details required to connect to the database. 

<a href="#Connection-Configuration">See more connection configuration options →</a>

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

## Use Configuration File

This example demonstrates how to use the configuration file `config.yml` to establish a connection:

```go
package main

import (
	"log"

	"github.com/ultipa/ultipa-go-driver/v5/sdk"
	"github.com/ultipa/ultipa-go-driver/v5/sdk/configuration"
)

func main() {
	config, _ := configuration.LoadConfigFromYAML("./config.yml")

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

Example of the `config.yml` file:

<p tit="config.yml"></p> 
 
```yml
# hosts: ["mqj4zouys.us-east-1.cloud.ultipa.com:60010"]
hosts: 
  - "10.xx.xx.xx:60010"
  - "10.xx.xx.xx:60010"
  - "10.xx.xx.xx:60010"
username: "<username>"
password: "<password>"
default_graph: "miniCircle"
crt: 
max_recv_size: 
```

<a href="#Connection-Configuration">See more connection configuration options →</a>

## Connection Configuration

`UltipaConfig` or a configuration file can include the following fields:

| <div table-width="22">Field</div> | <div table-width="10">Type</div> | <div table-width="8">Default</div> | Description |
| ---- | ---- | ---- | ---- |
| `Hosts` | []string | / | **Required.** A comma-separated list of database server IPs or URLs. The protocol is automatically identified, do not include `https://` or `http://` as a prefix in the URL. |
| `Username` | string | / | **Required.** Username of the host authentication. |
| `Password` | string | / | **Required.** Password of the host authentication. |
| `DefaultGraph` | string | / | Name of the graph to use by default in the database. |
| `Crt` | []byte | / | The file path of the SSL certificate used for secure connections. |
| `PasswordEncrypt` | string | `MD5` | Password encryption method of the driver. Supports `MD5`, `LDAP` and `NOTHING`. |
| `Timeout` | int32 | Maximum | Request timeout threshold (in seconds). |
| `Heartbeat` | int | 0 | The heartbeat interval (in milliseconds), used to keep the connection alive. Set to 0 to disable. |
| `MaxRecvSize` | int | 32 | The maximum size (in MB) of the received data. |
