# Connect to Database

Once you have installed the driver and set up an Ultipa instance, you can connect your application to the database.

# Create a Connection

Creates a connection by instantiating `UltipaDriver()` with `ULTIPA.UltipaConfig`, which holds the configuration details required to connect to the database. 

<a href="#Connection-Configuration">See more connection configuration options →</a>

```ts
import { UltipaDriver } from "@ultipa-graph/ultipa-driver";
import type { ULTIPA } from "@ultipa-graph/ultipa-driver/dist/types/index.js";

let sdkUsage = async () => {
  const ultipaConfig: ULTIPA.UltipaConfig = {
    // URI example: hosts: ["xxxx.us-east-1.cloud.ultipa.com:60010"]
    hosts: ["10.xx.xx.xx:60010"],
    username: "<username>",
    password: "<password>"
  };

  const driver = new UltipaDriver(ultipaConfig);
  
  // Tests the connection
  const isSuccess = await driver.test();
  console.log(`Connection succeeds: ${isSuccess}`);
};

sdkUsage().catch(console.error);
```

<p tit="Output"></p> 

```
Connection succeeds: true
```

## Use Configuration File

This example demonstrates how to use the configuration file `.env` to establish a connection:

```ts
import { UltipaDriver } from "@ultipa-graph/ultipa-driver";
import type { ULTIPA } from "@ultipa-graph/ultipa-driver/dist/types/index.js";
import * as dotenv from "dotenv";

// Loads the .env file and overrides system environment variables
dotenv.config({override:true});

const hosts = process.env.hosts?.split(',') || [];
const username = process.env.username!;
const password = process.env.password!;

const sdkUsage = async () => {
  const ultipaConfig: ULTIPA.UltipaConfig = {
    hosts: hosts,
    username: username,
    password: password,
  };

  const conn = new UltipaDriver(ultipaConfig);

  // Tests the connection
  const isSuccess = await conn.test();
  console.log(`Connection succeeds: ${isSuccess}`);
};

sdkUsage().catch(console.error);
```

<p tit="Output"></p> 

```
Connection succeeds: true
```

Example of the `.env` file:

<p tit=".env" ></p> 

```
// hosts=xxxx.us-east-1.cloud.ultipa.com:60010
hosts=10.xx.xx.xx:60010
username=<username>
password=<password>
passwordEncrypt=MD5
defaultGraph=miniCircle
// crt=F:\\ultipa.crt
// maxRecvSize=10240
```

<a href="#Connection-Configuration">See more connection configuration options →</a>

## Connection Configuration

`UltipaConfig` or a configuration file can include the following fields:

| <div table-width="22">Field</div> | <div table-width="10">Type</div> | <div table-width="8">Default</div> | Description |
| ---- | ---- | ---- | ---- |
| `hosts` | string[] | / | **Required.** A comma-separated list of database server IPs or URLs. The protocol is automatically identified, **do not** include `https://` or `http://` as a prefix in the URL. |
| `username` | string | / | **Required.** Username of the host authentication. |
| `password` | string | / | **Required.** Password of the host authentication. |
| `defaultGraph` | string | / | Name of the graph to use by default in the database. |
| `crt` | string | / | The file path of the SSL certificate used for secure connections. |
| `passwordEncrypt` | string | `MD5` | Password encryption method of the driver. Supports `MD5`, `LDAP` and `NOTHING`. |
| `timeout` | number | Maximum | Request timeout threshold (in seconds). |
| `heartbeat` | number | 0 | The heartbeat interval (in milliseconds), used to keep the connection alive. Set to 0 to disable. |
| `maxRecvSize` | number | 32 | The maximum size (in MB) of the received data. |
