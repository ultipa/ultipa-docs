# Data Export

This section introduces methods for exporting nodes and edges from graphs. 

## export()

Exports nodes or edges from the graph.

**Parameters**

- `exportRequest: ExportRequest`: Configurations for the export request, including fields `dbType`, `schema`, `selectProperties`, `graph`, and `limit`; sets `limit` to `-1` to export all.
- `listener: RequestType.ExportListener`: The callback function that gets executed when data is exported.

**Returns**

- Void.

<p tit="Example.ts"></p> 

```ts
import { UltipaDriver } from "@ultipa-graph/ultipa-driver";
import type { ULTIPA } from "@ultipa-graph/ultipa-driver/dist/types/index.js";
import pkg from '@ultipa-graph/ultipa-driver/src/proto/ultipa_pb.js';
const { ExportRequest, DBType } = pkg;
 
import * as fs from "fs";
import { parse } from "json2csv";
 
let sdkUsage = async () => {
  const ultipaConfig: ULTIPA.UltipaConfig = {
    // URI example: hosts: ["xxxx.us-east-1.cloud.ultipa.com:60010"]
    hosts: ["10.xx.xx.xx:60010"],
    username: "<username>",
    password: "<password>"
  };
 
  const driver = new UltipaDriver(ultipaConfig);
 
  // Exports 'account' nodes in the graph 'miniCircle'
 
  const exportRequest = new ExportRequest();
  exportRequest.setDbType(DBType.DBNODE);
  exportRequest.setSchema("account");
  exportRequest.setGraph("miniCircle");
  exportRequest.addSelectProperties("_id");
  exportRequest.addSelectProperties("name");
  exportRequest.addSelectProperties("year");
  exportRequest.setLimit(-1);
  
  const allNodes: any[] = [];
 
  await driver.export(exportRequest, {
    stream: {
      onStart: () => {
        console.log("Export started");
      },
      onData: async (data) => {
        allNodes.push(...data);
      },
      onEnd: () => {
        console.log("Export completed. Total nodes:", allNodes.length);
 
        if (allNodes.length === 0) {
          console.log("No data received.");
          return;
        }
 
        try {
          const csv = parse(allNodes);
          const filePath = "./account_nodes.csv";
          fs.writeFileSync(filePath, csv, "utf8");
          console.log(`CSV export completed: ${filePath}`);
        } catch (err) {
          console.error("Failed to write a row to CSV:", err);
        }
      }
    }
  })
};
 
sdkUsage().catch(console.error);
```

<p tit="Output"></p>

```
Export started
Export finished. Total nodes: 111
CSV export completed: ./account_nodes.csv
```

The file `account_nodes.csv` is exported to the same directory as the file you executed.
