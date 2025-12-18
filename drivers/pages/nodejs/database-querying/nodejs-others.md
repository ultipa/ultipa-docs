# Others

This section introduces methods on a `Connection` object for checking the database server statistics and the driver connection.

Each example focuses solely on the method's usage. For a complete code example, please refer to the <a href="#Full-Example">full example</a>.

## stats()

Retrieves database server statistics.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Stat`: The retrieved server statistics.

<p tit="TypeScript"></p> 
 
```ts
let resp = await conn.stats();
console.log("CPU usage:", resp.data.cpuUsage);
console.log("Memory usage:", resp.data.memUsage);
console.log("Expiration date:", resp.data.expiredDate);
console.log("CPU cores:", resp.data["cpuCores"]),
console.log("Company:", resp.data["company"]),
console.log("Server type:", resp.data["serverType"]),
console.log("Version:", resp.data["version"]);
```

<p tit="Output"></p> 
 
```java
CPU usage: 12.503961
Memory usage: 10356.265625
Expiration date: Thu Dec 26 23:59:59 2024
CPU cores: 80
Company: ultipa
Server type: CT
Version: htap_beta.4.5.5-b4.5.0-tv-ui
```

## test()

Tests driver and database server connection.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `boolean`: Result of the request.

<p tit="TypeScript"></p> 
 
```ts
let resp = await conn.test();
console.log(resp);
```

<p tit="Output"></p> 
 
```java
true
```

## Full Example

<p tit="TypeScript"></p> 

```ts
import { ConnectionPool, ULTIPA } from "@ultipa-graph/ultipa-node-sdk";
import { GraphExra } from "@ultipa-graph/ultipa-node-sdk/dist/connection/extra/graph.extra";
import { getEdgesPrintInfo } from "@ultipa-graph/ultipa-node-sdk/dist/printers/edge";
import { RequestType } from "@ultipa-graph/ultipa-node-sdk/dist/types";
import { ListFormat } from "typescript";

let sdkUsage = async () => {
  // Connection configurations
  //URI example: hosts="mqj4zouys.us-east-1.cloud.ultipa.com:60010"
  let hosts = [
    "192.168.1.85:60061",
    "192.168.1.86:60061",
    "192.168.1.87:60061",
  ];
  let username = "***";
  let password = "***";
  let connPool = new ConnectionPool(hosts, username, password);

  // Establishes connection to the database
  let conn = await connPool.getActive();
  let isSuccess = await conn.test();
  console.log(isSuccess);

  // Request configurations
  let requestConfig = <RequestType.RequestConfig>{
    useMaster: true,
  };

  // Test connection
  let resp = await conn.test();
  console.log(resp);  
};

sdkUsage().then(console.log).catch(console.log);
```