# Database Querying

## Request Configuration

All querying methods support an optional request configuration parameter (`RequestConfig` or `InsertRequestConfig`) to customize the behavior of requests made to the database. This parameter allows you to specify various settings, such as graphset name, timeout, and host, to tailor your requests according to your needs.

## RequestConfig

`RequestConfig` defines the settings needed when sending non-insert requests to the database.

<p tit= "TypeScript" ></p> 
 
```ts
import { ConnectionPool } from "@ultipa-graph/ultipa-node-sdk";
import { RequestType } from "@ultipa-graph/ultipa-node-sdk/dist/types";

let sdkUsage = async () => {
  //URI example: hosts="mqj4zouys.us-east-1.cloud.ultipa.com:60010"
  let hosts = [
    "192.168.1.85:60061", 
    "192.168.1.86:60061", 
    "192.168.1.87:60061"
  ];
  let username = "***";
  let password = "***";
  let connPool = new ConnectionPool(hosts, username, password);

  let conn = await connPool.getActive();
  let isSuccess = await conn.test();
  console.log(isSuccess);
  
  // Specifies 'amz' as the target graphset and sets to use the leader node of the cluster 
  let requestConfig = <RequestType.RequestConfig>{
    graphSetName: "amz",
    useMaster: true,
  };
  
  let uqlResult = await conn.uql(`find().nodes([1]) as n return n.name`, requestConfig);
  console.log(uqlResult.data?.alias("n.name").asAttrs());  
  
};

sdkUsage().then(console.log).catch(console.log);
```
`RequestConfig` has the following fields:

| <div table-width="18">Item</div> | <div table-width="22">Type</div> | Description |
|  ----  | ----  | ---- |
| `graphSetName` | string | Name of the graph to use. If not set, use the `graphSetName` configured when establishing the connection. |
| `timeout` | number | Request timeout threshold in seconds. |
| `clusterID` | string | Specifies the cluster to use. | 
| `timeZone` | string | The time zone to use. |
| `timeZoneOffset` | number | The amount of time that the time zone in use differs from UTC in minutes. |
| `timestampToString` | boolean | Whether to convert timestamp to string. |
| `threadNum` | number | Number of threads. |
| `stream` | Stream | Returns the result in stream. |
| `retry` | object | The retry configuration when request fails. Two keys are available: `current` and `max`, both of the number type. |
| `useHost` | string | Sends the request to a designated host node, or to a random host node if not set. |
| `useMaster` | boolean | Sends the request to the leader node to guarantee consistency read if set to true. |
| `package_limit` | number | The limit to the number of packages returned. |
| `forceRefresh` | boolean | Whether to refresh the cluster information. |
| `logUql` | boolean | Whether to print the UQL. |


## InsertRequestConfig

`InsertRequestConfig` defines the settings needed when sending data insertion or deletion requests to the database.

<p tit= "TypeScript" ></p> 
 
```ts
import { ConnectionPool, ULTIPA } from "@ultipa-graph/ultipa-node-sdk";
import { RequestType } from "@ultipa-graph/ultipa-node-sdk/dist/types";

let sdkUsage = async () => {

  //URI example: hosts="mqj4zouys.us-east-1.cloud.ultipa.com:60010"
  let hosts = [
    "192.168.1.85:60061", 
    "192.168.1.86:60061", 
    "192.168.1.87:60061"
  ];
  let username = "***";
  let password = "***";
  let connPool = new ConnectionPool(hosts, username, password);

  // Connects to the 'default' graphset
  let conn = await connPool.getActive();
  let isSuccess = await conn.test();
  console.log(isSuccess);
  
  let node1 = new ULTIPA.Node();
  node1.schema = "card";
  node1.id = "ULTIPA8000000000000001";
  node1.values = {balance: Number(3235.2)};
  
  let node2 = new ULTIPA.Node();
  node2.schema = "client";
  node2.id = "ULTIPA800000000000000B";
  node2.values = {level: Number(7)};

  let nodes = [node1, node2];

  // Inserts the two nodes above into graphset 'test' under the overwrite mode
  let insertRequestConfig = <RequestType.InsertRequestConfig>{
    graphSetName: "test",
    insertType: ULTIPA.InsertType.INSERT_TYPE_OVERWRITE,
  };
  let uqlResult = await conn.insertNodesBatchAuto(nodes, insertRequestConfig);

  console.log(uqlResult.status.code);
  
};

sdkUsage().then(console.log).catch(console.log);
```

`InsertRequestConfig` has the following fields:

| <div table-width="18">Item</div> | <div table-width="22">Type</div> | Description |
|  ----  | ----  | ---- |
| `graphSetName` | string[] | Name of the graph to use. If not set, use the `graphSetName` configured when establishing the connection. |
| `timeout` | number | Request timeout threshold in seconds. |
| `clusterID` | string | Specifies the cluster to use. | 
| `timeZone` | string | The time zone to use. |
| `timeZoneOffset` | number | The amount of time that the time zone in use differs from UTC in minutes. |
| `timestampToString` | boolean | Whether to convert timestamp to string. |
| `threadNum` | number | Number of threads. |
| `stream` | Stream | Returns the result in stream. |
| `retry` | object | The retry configuration when request fails. Two keys are available: `current` and `max`, both of the number type. |
| `useHost` | string | Sends the request to a designated host node, or to a random host node if not set. |
| `useMaster` | boolean | Sends the request to the leader node to guarantee consistency read if set to true. |
| `package_limit` | number | The limit to the number of packages returned. |
| `forceRefresh` | boolean | Whether to refresh the cluster information. |
| `logUql` | boolean | Whether to print the UQL. |
| `insertType` | ULTIPA.InsertType | Insert mode (INSERT_TYPE_NORMAL, INSERT_TYPE_UPSERT, INSERT_TYPE_OVERWRITE). |
| `createNodeIfNotExist` | boolean | Whether to create start/end nodes of an edge if the end nodes do not exist in the graph. |
| `silent` | boolean | Whether to keep slient after successful insertion.Returns _id and _uuid of the newly inserted data when set to false. |

