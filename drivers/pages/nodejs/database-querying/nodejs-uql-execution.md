# UQL Execution

This section introduces the `uql()` and `uqlStream()` methods on a `Connection` object for querying the database using UQL.

Each example focuses solely on the method's usage. For a complete code example, please refer to the <a href="#Full-Example">full example</a>.

> UQL (Ultipa Query Language) is the language designed for fully interacting with Ultipa graph databases. For detailed information on UQL, refer to the <a href="/docs/uql/">documentation</a>.

## uql()

Executes a UQL query on the current graphset or the database and returns the result.

**Parameters:**

- `string`: The UQL query to be executed.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit="TypeScript"></p> 
 
```ts
// Retrieves 5 @movie nodes in graphset 'miniCircle' and prints their names

let requestConfig = <RequestType.RequestConfig>{
  graphSetName: "miniCircle",
  useMaster: true,
};

let resp = await conn.uql(
  "find().nodes({@movie}) as n return n{*} limit 5",
  requestConfig
);

let node_list = resp.data?.get(0).asNodes();
node_list?.forEach((node) => {
  console.log(node.get("name"));
});
```

<p tit="Output"></p> 

```java
The Shawshank Redemption
Farewell My Concubine
Léon: The Professional
Titanic
Life is Beautiful
```

For more examples, please refer to <a href="https://www.ultipa.com/doc/drivers/types-mapping-ultipa-and-nodejs">Types Mapping Ultipa and Node.js</a>.

## uqlStream()

Executes a UQL query on the current graphset or the database and returns the result incrementally, allowing handling of large datasets without loading everything into memory at once.

**Parameters:**

- `string`: The UQL query to be executed.
- `UqlResponseStream`: Listener for the streaming process.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `void`

<p tit="TypeScript"></p> 
 
```ts
// Retrieves all 1-step paths in graphset 'miniCircle'

let requestConfig = <RequestType.RequestConfig>{
  graphSetName: "miniCircle",
  useMaster: true,
};

let count = 0;
let resp = await conn.uqlStream(
  "n().e().n() as paths return paths{*}",
  {
    onData: async (res) => {
      let paths = res.data.get(0).asPaths();
      count = count + paths.length;
      console.log(count);
    },
    onEnd: () => {
      console.log("END");
    },
    onStart: () => {
      console.log("Start");
    },
    onError: (err) => {
      console.log(err);
    },
  },
  requestConfig
);
```

<p tit="Output"></p> 

```java
Start
1250
1392
END
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
    graphSetName: "miniCircle",
    useMaster: true,
  };

  // Retrieves 10 nodes and prints the _id and name property value of the first returned one
  let resp = await conn.uql(
    "find().nodes({@movie}) as n return n{*} limit 10",
    requestConfig
  );

  
  let node_list = resp.data?.get(0).asNodes();
  if (node_list && node_list.length > 0) {
    console.log(node_list[0]._id, node_list[0].get("name"));
  }
};

sdkUsage().then(console.log).catch(console.log);
```
