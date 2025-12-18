# Algorithm Management

This section introduces methods on a `Connection` object for managing <a href="/docs/graph-analytics-algorithms">Ultipa graph algorithms</a> and custom algorithms (EXTA) in the instance.

Each example focuses solely on the method's usage. For a complete code example, please refer to the <a href="#Full-Example">full example</a>.

## Ultipa Graph Algorithms

### showAlgo()

Retrieves all Ultipa graph algorithms installed in the instance.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Algo[]`: The list of all algorithms retrieved.

<p tit="TypeScript"></p> 
 
```ts
// Retrieves all Ultipa graph algorithms installed and prints the information of the first returned one

let resp = await conn.showAlgo();

let algo_list = resp.data.map((item) => item.param);
console.log("First algorithm retrieved: ", algo_list[0]);
```
<p tit="Output"></p> 
 
```java
First algorithm retrieved:  {
  name: 'bipartite',
  description: 'bipartite check',
  version: '1.0.1',
  parameters: {},
  result_opt: '56'
}
```

### installAlgo()

Installs an Ultipa graph algorithm in the instance.

**Parameters:**

- `string`: File path of the algo installation package (*.so*).
- `string`: File path of the configuration file (*.yml*).
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit="TypeScript"></p> 
 
```ts
// Installs the algorithm LPA and uses the leader node to guarantee consistency, and prints the error code

let requestConfig = <RequestType.RequestConfig>{
  useMaster: true,
};

let resp = await conn.installAlgo(
  "E:/NodeJs/Algo/libplugin_lpa.so",
  "E:/NodeJs/Algo/lpa.yml"
);
console.log(resp.status.code_desc);
```
<p tit="Output"></p> 
 
```java
["libplugin_lpa.so","lpa.yml"] upload finished!
SUCCESS
```

### uninstallAlgo()

Uninstalls an Ultipa graph algorithm in the instance.

**Parameters:**

- `string`: Name of the algorithm.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit="TypeScript"></p> 
 
```ts
// Uninstalls the algorithm LPA and prints the error code

let resp = await conn.uninstallAlgo("lpa");
console.log(resp.status.code_desc);
```
<p tit="Output"></p> 
 
```java
SUCCESS
```

## EXTA

### showExta()

Retrieves all extas installed in the instance.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Exta[]`: The list of all extas retrieved.

<p tit="TypeScript"></p> 
 
```ts
// Retrieves all extas installed and prints the information of the first returned one

let resp = await conn.showExta();
console.log(resp.data);
```
<p tit="Output"></p> 
 
```java
[
  {
    name: 'page_rank 1',
    author: 'xxx',
    version: 'beta.4.4.41-b4.4.0-tv-ui',
    detail: 'base:\n' +
      '  category: ExtaExample\n' +
      '  cn:\n' +
      '    name: page_rank\n' +
      '    desc: null\n' +
      '  en:\n' +
      '    name: page_rank\n' +
      '    desc: null\n' +
      '\n' +
      'other_param:\n' +
      '\n' +
      '    \n' +
      'param_form:\n' +
      '\n' +
      'write:\n' +
      '\n' +
      'return:\n' +
      '\n' +
      'media:\n'
  }
]
```

### installExta()

Installs an exta in the instance.

**Parameters:**

- `string`: File path of the exta installation package (*.so*).
- `string`: File path of the configuration file (*.yml*).
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit="TypeScript"></p> 
 
```ts
// Installs the exta page_rank and uses the leader node to guarantee consistency, and prints the error code

let requestConfig = <RequestType.RequestConfig>{
  useMaster: true,
};

let resp = await conn.installExta(
  "E:/NodeJs/Exta/libexta_page_rank.so",
  "E:/NodeJs/Exta/page_rank.yml",
  requestConfig
);
console.log(resp.status.code_desc);
```
<p tit="Output"></p> 
 
```java
["libexta_page_rank.so","page_rank.yml"] upload finished!
SUCCESS
```

### uninstallExta()

Uninstalls an exta in the instance.

**Parameters:**

- `string`: Name of the exta.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit="TypeScript"></p> 
 
```ts
// Uninstalls the exta page_rank and prints the error code

let resp = await conn.uninstallExta("page_rank");
console.log(resp.status.code_desc);
```
<p tit="Output"></p> 
 
```java
SUCCESS
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

  // Installs the algorithm LPA
  let resp = await conn.installAlgo(
    "E:/NodeJs/Algo/libplugin_lpa.so",
    "E:/NodeJs/Algo/lpa.yml",
    requestConfig
  );
  console.log(resp.status.code_desc);
};

sdkUsage().then(console.log).catch(console.log);
```
