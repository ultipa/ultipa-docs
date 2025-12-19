# Vector Servers

## Overview

The **vector servers** can be deployed alongside Ultipa Powerhouse (v5), providing support for vector indexing and search.

## Showing Vector Servers

Retrieves information about all vector servers:

<div tab="code">

```gql
SHOW VECTOR SERVER
```

```uql
show().vector()
```

</div>

Retrieves information about the vector server named `vector_server_1`:

```uql
show().vector("vector_server_1")
```

The information about vector servers is organized into a table named `_vector`, including the following fields:

| <div table-width="18">Field</div> | Description |
| -- | -- |
| `name` | Name of the vector server. |
| `addr` | IP address and port of the vector server. |
| `status` | Current state of the vector server, which can be `ACTIVE` or `DEAD`. |
| `last_heartbeat` | Timestamp of the last heartbeat sent to the meta servers by the vector server. |

## Adding a Vector Server

After successfully deploying a new vector server, it must be registered with the meta servers before it can be utilized. This process ensures that the new vector server is recognized within the system.

The following example adds a vector server with the name `vector_server_1` and the address `127.0.0.1:55555`:

<div tab="code">

```gql
ADD VECTOR SERVER "vector_server_1" AT "127.0.0.1:55555"
```

```uql
alter().vector().add({name: "vector_server_1", addr: "127.0.0.1:55555"})
```

</div>

## Deleting a Vector Server

You can unregister an inactive or obsolete vector server from the meta servers.

The following example deletes the vector server with the name `vector_server_1`:

<div tab="code">

```gql
DELETE VECTOR SERVER "vector_server_1"
```

```uql
alter().vector().delete({name: "vector_server_1"})
```

</div>
