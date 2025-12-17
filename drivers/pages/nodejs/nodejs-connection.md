# Connection 

After <a href="https://www.ultipa.com/doc/drivers/nodejs-installation">installing the Ultipa Node.js SDK</a> and setting up a running Ultipa instance, you should be able to connect your application to the Ultipa graph database.

## ConnectionPool

Connection to Ultipa can be established by using `ConnectionPool`, which specifies the information of the connection pool needed.

Below are all the configuration items available for `ConnectionPool`:


| <div table-width="18">Item</div> | <div table-width="22">Type</div> | Description |
|  ----  | ----  | ---- |
| `hosts` | string[] | Database host addresses or host URI (excluding `"https://"` or `"http://"`). For clusters, multiple addresses are seperated by commas. Required. |
| `username` | string |  Username of the host authentication. Required. |
| `password` | string |  Password of the host authentication. Required. |
| `crt` | Buffer | Sets the local certificate file path. SSL will be used for connection. |
| `defaultConfig` | ULTIPA.UltipaConfig | Other configurations include settings for the graphset, timeout, and consistency. |
| `otherParams` | object | Two keys are available: `isHttps` and `isHttp`, both as boolean values. If both are set to `true`, HTTP is used first. If not specified, the connection tries HTTP first, and switches to HTTPS if HTTP fails. |

### Connect to a Cluster

Example of connecting to a cluster and using graphset 'default'.

<p tit= "TypeScript" ></p> 
 
```ts
import { ConnectionPool } from "@ultipa-graph/ultipa-node-sdk";
import fs from "fs";

let sdkUsage = async () => {

  let hosts = [
    "192.168.1.85:60061", 
    "192.168.1.86:60061", 
    "192.168.1.87:60061"
  ];
  let username = "***";
  let password = "***";
  let crt: Buffer;
  { // Crt is used
    let crt_file_path = "./ultipa.crt";
    crt = fs.readFileSync(crt_file_path);
  }
  let connPool = new ConnectionPool(hosts, username, password, crt);
  
  let conn = await connPool.getActive();
  let isSuccess = await conn.test();
  console.log(isSuccess);
};

sdkUsage().then(console.log).catch(console.log);
```

### Connect to Ultipa Cloud

Example of connecting to an instance on Ultipa Cloud and using graphset 'default'.

<p tit= "TypeScript" ></p> 
 
```ts
import { ConnectionPool } from "@ultipa-graph/ultipa-node-sdk";

let sdkUsage = async () => {

  let hosts = ["3xbotdjas.us-east-1.cloud.ultipa.com:60010"];
  let username = "***";
  let password = "***";
  let otherParams = {
    isHttps: true,
    isHttp: false
  };
  let connPool = new ConnectionPool(hosts, username, password, undefined, undefined, otherParams);
  
  let conn = await connPool.getActive();
  let isSuccess = await conn.test();
  console.log(isSuccess);
};

sdkUsage().then(console.log).catch(console.log);
```

## Configuration Items

Below are all the configuration items available for `UltipaConfig`:

| <div table-width="18">Item</div> | <div table-width="22">Type</div> | Description |
|  ----  | ----  | ---- |
| `graphSetName` | string | Name of the graph to use. If not set, use the `graphSetName` configured when establishing the connection. |
| `timeout` | number | Request timeout threshold in seconds. |
| `consistency` | boolean | Whether to use the leader node to ensure consistency read. |
| `useHost` | string | Sends the request to a designated host node, or to a random host node if not set. |
| `clusterID` | string | Specifies the cluster to use. |
| `timeZone` | string | The time zone to use. |
| `timeZoneOffset` | number | The amount of time that the time zone in use differs from UTC in minutes. |
| `timestampToString` | boolean | Whether to convert timestamp to string. |
| `logUql` | boolean | Whether to print the UQL. |
| `threadNum` | number | Number of threads. |
| `responseWithRequestInfo` | boolean | Whether to include request information in the response. |

