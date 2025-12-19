## HDC Graph and Algorithm

This section introduces methods for managing HDC graph and HDC algorithms. Note that these methods require the deployment of HDC servers for the database.

## HDC Graph

### showHDCGraph()

Retrieves all HDC graphs created from the graph.

**Parameters**

- `config?: RequestConfig`: Request configuration.

**Returns**

- `HDCGraph[]`: The list of retrieved HDC graphs.

 ```ts
// Retrieves all HDC graphs of the graph 'miniCircle'
const requestConfig: RequestConfig = { graph: "miniCircle" };
const hdcGraphs = await driver.showHDCGraph(requestConfig);
for (const hdcGraph of hdcGraphs) {
  console.log(`${hdcGraph.name} on ${hdcGraph.hdcServerName}`);
}
```

<p tit="Output"></p> 
 
```
miniCircle_hdc_graph on hdc-server-1
miniCircle_hdc_graph2 on hdc-server-2
```

### createHDCGraphBySchema()

Creates an HDC graph for the graph.

**Parameters**

- `builder: HDCBuilder`: The HDC graph to be created; the fields `hdcGraphName` and `hdcServerName` are mandatory, `nodeSchema`, `edgeSchema`, `syncType`, `direction`, `loadId`, and `isDefault` are optional.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `JobResponse`: Response of the request.

 ```ts
// Creates an HDC graph named 'test_hdc_graph' for the graph 'miniCircle'

const requestConfig: RequestConfig = { graph: "miniCircle" };

const nodeSchema = new Map<string, string[]>([["*", ["*"]]]);
const edgeSchema = new Map<string, string[]>([
  ["direct", ["*"]],
  ["review", ["value", "content"]]
]);

const hdcBuilder = {
  hdcGraphName: "test_hdc_graph",
  hdcServerName: "hdc-server-1",
  nodeSchema: nodeSchema,
  edgeSchema: edgeSchema,
  syncType: HDCSyncType.STATIC
};

const response = await driver.createHDCGraphBySchema(hdcBuilder, requestConfig);
const jobID = response.jobId;

await new Promise(resolve => setTimeout(resolve, 3000));

const jobs = await driver.showJob(jobID, requestConfig);
for (const job of jobs) {
  console.log(`${job.id} - ${job.status}`);
}
```

<p tit="Output"></p> 
 
```
61 - FINISHED
61_1 - FINISHED
```

### dropHDCGraph()

Deletes a specified HDC graph of the graph.

**Parameters**

- `hdcGraphName: string`: Name of the HDC graph.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `Response`: Response of the request.

 ```ts
// Drops the HDC graph 'miniCircle_hdc_graph2' of the graph 'miniCircle'
const requestConfig: RequestConfig = { graph: "miniCircle" };
const response = await driver.dropHDCGraph("miniCircle_hdc_graph2", requestConfig);
console.log(response.status?.message)
```

<p tit="Output"></p> 
 
```
SUCCESS
```

## HDC Algorithms

### showHDCAlgo()

Retrieves all HDC algorithms installed on an HDC server.

**Parameters**

- `hdcServerName: string`: Name of the HDC server.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `Algo[]`: The list of retrieved HDC algorithms.

 ```ts
// Retrieves all HDC algorithms installed on the HDC server 'hdc-server-1'
const algos = await driver.showHDCAlgo("hdc-server-1");
for (const algo of algos) {
  if (algo.type == "algo") {
    console.log(
      `${algo.name} supports writeback types: ${algo.writeSupportType}`
    );
  }
}
```

<p tit="Output"></p> 
 
```
fastRP supports writeback types: DB,FILE
struc2vec supports writeback types: DB,FILE
```

### installHDCAlgo()

Installs an HDC algorithm on an HDC server.

**Parameters**

- `files: string[]`: List of the paths of the installation files, the package file (.so) is necessary while the configuration file (.yml) is optional.
- `hdcServerName: string`: Name of the HDC server.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `Response`: Response of the request.

 ```ts
// Installs the HDC algorithm LPA on the HDC server 'hdc-server-1'
const response = await driver.installHDCAlgo(["algo/libplugin_lpa.so","algo/lpa.yml"], "hdc-server-1");
console.log(response.status?.message);
```

<p tit="Output"></p> 
 
```
Install Algo {
  fileName: 'libplugin_lpa.so',
  chunkLength: 21538544,
  md5: '3add4934073fb4e8012be37b3e2ab2be'
}
End and sending sum:  libplugin_lpa.so 21538544
Install Algo {
  fileName: 'lpa.yml',
  chunkLength: 8037,
  md5: '456c358b6b1f6f79bcf995422ff0ab9b'
}
End and sending sum:  lpa.yml 8037
["libplugin_lpa.so","lpa.yml"] upload finished!
SUCCESS
```

### uninstallHDCAlgo()

Uninstalls an HDC algorithm from an HDC server.

**Parameters**

- `algoName: string`: Name of the algorithm.
- `hdcServerName: string`: Name of the HDC server.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `Response`: Response of the request.

 ```ts
// Uninstalls the HDC algorithm LPA from the HDC server 'hdc-server-1'
const response = await driver.uninstallHDCAlgo("lpa", "hdc-server-1");
console.log(response.status?.message);
```

<p tit="Output"></p> 
 
```
SUCCESS
```

### rollbackHDCAlgo()

Rolls back a specified HDC algorithm on an HDC server.

**Parameters**

- `algoName: string`: Name of the algorithm.
- `hdcServerName: string`: Name of the HDC server.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `Response`: Response of the request.

 ```ts
// Rolls back the HDC algorithms LPA on the HDC server 'hdc-server-1'
const response = await driver.rollbackHDCAlgo("lpa", "hdc-server-1");
console.log(response.status?.message);
```

<p tit="Output"></p> 
 
```
SUCCESS
```

## Full Example

<p tit="Example.ts"></p> 

```ts
import { UltipaDriver } from "@ultipa-graph/ultipa-driver";
import { ULTIPA } from "@ultipa-graph/ultipa-driver/dist/types/index.js";

let sdkUsage = async () => {
  const ultipaConfig: ULTIPA.UltipaConfig = {
    // URI example: hosts: ["xxxx.us-east-1.cloud.ultipa.com:60010"]
    hosts: ["10.xx.xx.xx:60010"],
    username: "<username>",
    password: "<password>"
  };

  const driver = new UltipaDriver(ultipaConfig);

  // Installs the HDC algorithm LPA on the HDC server 'hdc-server-1'
  const response = await driver.installHDCAlgo(
    [
      "algo/libplugin_lpa.so", 
      "algo/lpa.yml"
    ], "hdc-server-1");
  console.log(response.status?.message);
};

sdkUsage().catch(console.error);
```
