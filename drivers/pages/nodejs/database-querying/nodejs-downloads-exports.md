# Downloads and Exports

This section introduces methods on a `Connection` object for downloading algorithm result files and exporting nodes and edges from a graphset.

Each example focuses solely on the method's usage. For a complete code example, please refer to the <a href="#Full-Example">full example</a>.

## downloadAlgoResultFile()

Downloads one result file from an algorithm task in the current graph.
 
**Parameters:**

- `string`: Name of the file.
- `string`: ID of the algorithm task that generated the file.
- `DownloadFileResultListener`: Listener for the download process.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit= "TypeScript" ></p> 
 
```ts
let requestConfig = <RequestType.RequestConfig>{
  useMaster: true,
  graphSetName: "miniCircle",
};

// Runs the Louvain algorithm in graphset 'miniCircle' and prints the task ID

let resp = await conn.uql(
  "algo(louvain).params({phase1_loop_num: 20, min_modularity_increase: 0.001}).write({file:{filename_community_id: 'communityID', filename_ids: 'ids', filename_num: 'num'}})",
  requestConfig
);
let myTask = await conn.showTask(
  "louvain",
  RequestType.TASK_STATUS.TASK_DONE,
  requestConfig
);

let myTaskID = myTask.data.map((item) => item.task_info.task_id)[0];
console.log("taskID = ", myTaskID);

let myDownload = await conn.downloadAlgoResultFile(
  "communityID",
  myTaskID,
  function (chunkData) {
    fsPromises
      .writeFile(`E:/NodeJs/Algo/communityID`, chunkData)
      .then(() => {
        console.log("Download write success");
      })
      .catch((err) => {
        console.error("Download write error", err);
      });
  },
  {
    graphSetName: "miniCircle",
    stream: {
      onData(data) {
        console.log("Success");
      },
      onEnd() {},
      onError(error) {
        console.error("Download write error");
      },
    },
  }
);
```

<p tit= "Output" ></p> 
 
```java
taskID =  60085
Success
Download write success
```

## downloadAllAlgoResultFile()

Downloads all result files from an algorithm task in the current graph.
 
**Parameters:**

- `string`: ID of the algorithm task that generated the file(s).
- `DownloadFileResultListener`: Listener for the download process.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit= "TypeScript" ></p> 
 
```ts
let requestConfig = <RequestType.RequestConfig>{
  useMaster: true,
  graphSetName: "miniCircle",
};

// Runs the Louvain algorithm in graphset 'miniCircle' and prints the task ID

let resp = await conn.uql(
  "algo(louvain).params({phase1_loop_num: 20, min_modularity_increase: 0.001}).write({file:{filename_community_id: 'communityID', filename_ids: 'ids', filename_num: 'num'}})",
  requestConfig
);
let myTask = await conn.showTask(
  "louvain",
  RequestType.TASK_STATUS.TASK_DONE,
  requestConfig
);

let myTaskID = myTask.data.map((item) => item.task_info.task_id)[0];
console.log("taskID = ", myTaskID);

let myDownload = await conn.downloadAllAlgoResultFile(
  myTaskID,
  function (chunkData) {
    fsPromises
      .writeFile(`E:/NodeJs/Algo/LovainResult`, chunkData)
      .then(() => {
        console.log("Download write success");
      })
      .catch((err) => {
        console.error("Download write error", err);
      });
  },
  {
    graphSetName: "miniCircle",
    stream: {
      onData(data) {},
      onEnd() {},
      onError(error) {
        console.error("Download write error");
      },
    },
  }
);
```

<p tit= "Output" ></p> 
 
```java
taskID =  60088
Download write success
Download write success
Download write success
```

## export()

Exports nodes and edges from the current graph.

**Parameters:**

- `RequestType.ExportRequest`: Configurations for the export request, including `dbType:ULTIPA.DBType`, `schemaName:string`, `limit:number` and `selectPropertiesName:string[]`.
- `ExportListener`: Listener for the export process.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.


<p tit= "TypeScript" ></p> 
 
```ts
// Exports 10 nodes of schema 'account' with selected properties in graphset 'miniCircle' and prints their information

let requestConfig = <RequestType.RequestConfig>{
  useMaster: true,
  graphSetName: "miniCircle",
};

let resp = await conn.export(
  {
    dbType: ULTIPA.DBType.DBNODE,
    schemaName: "account",
    limit: 10,
    selectPropertiesName: ["_id", "_uuid", "name", "year"],
  },
  async (n, e) => {
    console.log(n);
  },
  {
    graphSetName: "miniCircle",
    stream: {
      onData(data) {},
      onEnd() {},
      onError(error) {
        console.error("Download write error");
      },
    },
  }
);

```

<p tit= "Output" ></p> 
 
```java
[
  Node {
    id: 'ULTIPA8000000000000001',
    uuid: '1',
    schema: 'account',
    values: { name: 'Yu78', year: 1978 }
  },
  Node {
    id: 'ULTIPA8000000000000002',
    uuid: '2',
    schema: 'account',
    values: { name: 'jibber-jabber', year: 1989 }
  },
  Node {
    id: 'ULTIPA8000000000000003',
    uuid: '3',
    schema: 'account',
    values: { name: 'mochaeach', year: 1982 }
  },
  Node {
    id: 'ULTIPA8000000000000004',
    uuid: '4',
    schema: 'account',
    values: { name: 'Win-win0', year: 2007 }
  },
  Node {
    id: 'ULTIPA8000000000000005',
    uuid: '5',
    schema: 'account',
    values: { name: 'kevinh', year: 1973 }
  },
  Node {
    id: 'ULTIPA8000000000000006',
    uuid: '6',
    schema: 'account',
    values: { name: 'alexyhel', year: 1974 }
  },
  Node {
    id: 'ULTIPA8000000000000007',
    uuid: '7',
    schema: 'account',
    values: { name: 'hooj', year: 1986 }
  },
  Node {
    id: 'ULTIPA8000000000000008',
    uuid: '8',
    schema: 'account',
    values: { name: 'vv67', year: 1990 }
  },
  Node {
    id: 'ULTIPA8000000000000009',
    uuid: '9',
    schema: 'account',
    values: { name: '95smith', year: 1988 }
  },
  Node {
    id: 'ULTIPA800000000000000A',
    uuid: '10',
    schema: 'account',
    values: { name: 'jo', year: 1992 }
  }
]
```

## Full Example

<p tit= "TypeScript" ></p> 

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

  // Runs the Louvain algorithm and prints the task ID
  let resp = await conn.uql(
    "algo(louvain).params({phase1_loop_num: 20, min_modularity_increase: 0.001}).write({file:{filename_community_id: 'communityID', filename_ids: 'ids', filename_num: 'num'}})",
    requestConfig
  );
  let myTask = await conn.showTask(
    "louvain",
    RequestType.TASK_STATUS.TASK_DONE,
    requestConfig
  );
  let myTaskID = myTask.data.map((item) => item.task_info.task_id)[0];
  console.log("taskID = ", myTaskID);

  // Downloads all files generated by the above algorithm task and prints the download response
  let myDownload = await conn.downloadAllAlgoResultFile(
    myTaskID,
    function (chunkData) {
      fsPromises
        .writeFile(`C:/NodeJs/tw/LovainResult`, chunkData)
        .then(() => {
          console.log("Download write success");
        })
        .catch((err) => {
          console.error("Download write error", err);
        });
    },
    {
      graphSetName: "miniCircle",
      stream: {
        onData(data) {},
        onEnd() {},
        onError(error) {
          console.error("Download write error");
        },
      },
    }
  );
};

sdkUsage().then(console.log).catch(console.log);
```
