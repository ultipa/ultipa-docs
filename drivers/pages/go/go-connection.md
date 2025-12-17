# Connection

After <a href="https://www.ultipa.com/doc/drivers/go-installation">installing the Ultipa Go SDK</a> and setting up a running Ultipa instance, you should be able to connect your application to the Ultipa graph database.

## Code Configuration Connection

### Connect to a Cluster

<p tit= "Go" ></p> 
 
```go
func TestMisc(t *testing.T) {
  config := configuration.NewUltipaConfig(&configuration.UltipaConfig{
    Hosts: []string{"192.168.1.85:60061", "192.168.1.86:60061", "192.168.1.87:60061"},
    Username: "***",
    Password: "***",
  })

  conn, _ := sdk.NewUltipa(config)

  testResult, _ := conn.Test()
  println(testResult)
}
```

### Connect to Ultipa Cloud

<p tit= "Go" ></p> 
 
```go
func GetClient1(hosts []string, graphName string) (*api.UltipaAPI, error) {
   var err error
   config, _ := configuration.NewUltipaConfig(&configuration.UltipaConfig{
      Hosts:        []string{"xaznryn5s.us-east-1.cloud.ultipa.com:60010"},
      Username:     "***",
      Password:     "***",
      DefaultGraph: "Sample_Graphset",
      Debug:        true,
   })
   client, err = sdk.NewUltipa(config)
   if err != nil {
      log.Fatalln(err)
   }
   return client, err
}
```

## Configuration Items

Below are all the configuration items available for `UltipaConfig`:

| <div table-width="20">Item</div> | <div table-width="12">Type</div> | <div table-width="8">Default</div> | Description |
|  ----  | ----  | ----  | ---- |
| Hosts | []string |  | Database host addresses or URI (excluding `https://` or `http://`). For clusters, multiple addresses are separated by commas. Required. |
| Username | string |  | Username of the host authentication. Required. |
| Password | string |  | Password of the host authentication. Required. |
| PasswordEncrypt | string | MD5 | Password encryption method of the driver. Supports `MD5`, `LDAP` and `NOTHING`. `NOTHING` is used when the content is blank. |
| DefaultGraph | string |  | Name of the graph in the database to use by default. | 
| Crt | []byte |  | Certificate file for encrypted messages. | 
| MaxRecvSize | int | 10MB |  Maximum size in megabytes when receiving data. |
| Consistency | bool | FALSE | Whether to use the leader node to ensure consistency read. |
| CurrentGraph | string | default | Name of the current graphset. | 
| CurrentClusterId | string |  | Cluster ID of the nameserver. | 
| Timeout | int32 | 1000 | Request timeout threshold in seconds. |
| Debug | bool | FALSE | Whether to use the debug mode. | 
| HeartBeat | int | 0 | Heartbeat interval in milliseconds for all instances, set 0 to disable heartbeat. |

## YAML Configuration File

A YAML configuration file stores the necessary server information for connecting to the Ultipa graph database.

|  Variable in YAML | Item in UltipaConfig  |
|  ----  | ----  | 
| hosts | Hosts |  
| username | Username |
| password | Password |
| default_graph | DefaultGraph |
| crt | Crt |
| max_recv_size | MaxRecvSize |
| consistency | Consistency |
| current_graph | CurrentGraph |
| current_cluster_id | CurrentClusterId | 
| timeout | Timeout |
| debug | Debug |
| heart_beat | HeartBeat |

A driver is created with the configurations specified using the YAML file. The YAML file should be placed under the path of current Go file.

Example of a YAML configuration file 'testConfig.yml': 
<p tit= "YAML" ></p> 
 
```yml
hosts: 
  - "192.168.1.85:60061"
  - "192.168.1.86:60061"
  - "192.168.1.87:60061"
username: ***
password: ***
default_graph: amz
timeout:: 300
```

<p tit= "Go" ></p> 
 
```go
func TestMisc(t *testing.T) {
  config, _ := configuration.LoadConfigFromYAML("./testConfig.yml")

  conn, _ := sdk.NewUltipa(config)
  testResult, _ := conn.Test()
  println(testResult)
}
```
