# HDC Servers

## Overview

**HDC (High-Density Computing) servers** in the <a href="/docs/graph-database/powerhouse-v5">Ultipa Powerhouse (v5)</a> architecture are the computing nodes optimized for maximum performance and efficiency.

A graph can be loaded from the physical storage of Shard servers into the memory of an HDC server, creating a **HDC graph**. On these HDC graphs you can execute graph queries and algorithms with enhanced performance.

## Showing HDC Servers

Retrieves information about all HDC servers:

<div tab="code">

```gql
SHOW HDC SERVER
```

```uql
show().hdc()
```

</div>

Retrieves information about the HDC server named `hdc-server-1`:

```uql
show().hdc("hdc-server-1")
```

The information about HDC servers is organized into the following tables:

- `_hdc`: Shows the basic infomation of HDC servers, including `name`, `addr` (IP address and port of the HDC server), `status` (`ACTIVE` or `DEAD`), and `last_heartbeat` (timestamp of the last heartbeat sent to the meta servers by the HDC server).
- `_hdcGraphList`: Lists all HDC graphs hosted by each HDC server.

When retrieving a specific HDC server using `show().hdc("<hdcServerName>")`, two supplementary tables are returned:

- `_hdcGraphStats`: Lists all HDC graphs created on `<hdcServerName>` with their statistics.
- `_algoList`: Lists all algorithms installed on `<hdcServerName>`.

## Adding an HDC Server

After successfully deploying a new HDC server, it must be registered with the meta servers before it can be utilized. This process ensures that the new HDC server is recognized within the system.

To add an HDC server named `hdc-server-2` at `127.0.0.1:55555`:

<div tab="code">

```gql
ADD HDC SERVER "hdc-server-2" AT "127.0.0.1:55555"
```

```uql
alter().hdc().add({name: "hdc-server-2", addr: "127.0.0.1:55555"})
```

</div>

You can also add HDC servers on the server-side by running the `./ultipa.sh` script provided during <a target="_blank" href="/docs/operations-and-maintenance/install-ultipa">deployment</a>:

```bash
./ultipa.sh cluster addhdc --config example.sh
```

## Deleting an HDC Server

You can unregister an inactive or obsolete HDC server from the meta servers.

To delete the HDC server named `hdc-server-2`:

<div tab="code">

```gql
REMOVE HDC SERVER "hdc-server-2"
```

```uql
alter().hdc().delete({name: "hdc-server-2"})
```

</div>
