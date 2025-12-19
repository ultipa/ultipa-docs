# Meta Servers

## Overview

**Meta servers** are responsible for the overall system coordination, integrity, and optimization in the <a target="_blank" href="/docs/graph-database/ultipa-powerhouse-v5">Ultipa Powerhouse (v5)</a> architecture.

## Showing Meta Servers

Retrieves information about all meta servers:

```uql
show().meta()
```

The query result displays the address and status (either `ALIVE` or `DEAD`) of each meta server, along with their roles as either leader or follower in a cluster setup.

Here is an example of the output:

<p tit="Result"></p>

```
{"status":{"clusterInfo":{"leaderAddress":"127.0.1.20:61094","followers":[{"address":"127.0.1.21:61094","status":"ALIVE"},{"address":"127.0.1.22:61094","status":"ALIVE"}]}}}
```
