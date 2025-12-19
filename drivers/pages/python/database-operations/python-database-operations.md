## Database Operations

## Overview and Request Configuration

After <a target="_blank" href="/docs/drivers/python-connection">establishing the connection</a>, you are ready to use methods on the `Connection` object to send requests from the application to operate the database.

If you are familiar with <a target="_blank" href="/docs/gql">GQL</a> (Graph Query Language) or <a target="_blank" href="/docs/uql">UQL</a> (Ultipa Query Language), you can execute queries using the `gql()` or `uql()` method. For more information, refer to the following:

- <a target="_blank" href="/docs/drivers/python-gql-execution">GQL Execution</a>
- <a target="_blank" href="/docs/drivers/python-uql-execution">UQL Execution</a>

The driver also provides the following dedicated methods for key database operations:

- <a target="_blank" href="/docs/drivers/python-graph">Graph</a>
- <a target="_blank" href="/docs/drivers/python-schema-and-property">Schema and Property</a>
- <a target="_blank" href="/docs/drivers/python-data-insertion">Data Insertion</a>
- <a target="_blank" href="/docs/drivers/python-query-acceleration">Query Acceleration</a>
- <a target="_blank" href="/docs/drivers/python-hdc-graph-and-algorithm">HDC Graph and Algorithm</a>
- <a target="_blank" href="/docs/drivers/python-process-and-job">Process and Job</a>
- <a target="_blank" href="/docs/drivers/python-access-control">Access Control</a>
- <a target="_blank" href="/docs/drivers/python-data-export">Data Export</a>

## Request Configuration

Requests to **read the database** are configured using <a href="#RequestConfig">RequestConfig</a>, while those to **write the database** use <a href="#InsertRequestConfig">InsertRequestConfig</a>.

### RequestConfig

The `RequestConfig` class includes the following attributes:

| <div table-width="20">Attribute</div> | <div table-width="8">Type</div> | <div table-width="8">Default</div> | Description |
|  ----  | ----  | ----  | ---- |
| `graph` | str | / | Name of the graph to use. If not specified, the graph defined in `UltipaConfig.defaultGraph` will be used. |
| `timeout` | int | / | Request timeout threshold (in seconds); it overwrites the `UltipaConfig.timeout`. |
| `host` | str | / | Specifies a host in a database cluster to execute the request. |
| `thread` | int | / | Number of threads for the request. |
| `timezone` | str | / | Name of the timezone, e.g., `Europe/Paris`. Defaults to the local timezone if not specified. |
| `timezoneOffset` | str | / | The offset from UTC, specified in the format `±<hh>:<mm>` or `±<hh><mm>` (e.g., `+02:00`, `-0430`). If both `timezone` and `timezoneOffset` are provided, `timezoneOffset` takes precedence. |

### InsertRequestConfig

The `InsertRequestConfig` class includes all attributes of the <a href="#RequestConfig">RequestConfig</a> class, along with the following:

| <div table-width="15">Attribute</div> | <div table-width="15">Type</div> | <div table-width="12">Default</div> | Description |
|  ----  | ----  | ----  | ---- |
| `insertType` | `Ultipa.InsertType` | `NORMAL` | The insertion mode. Supports `NORMAL`, `UPSERT`, and `OVERWRITE`. |
| `silent` | bool | `True` | Whether to return the `_id` or `_uuid` of the operated nodes or edges. Sets to `Ture` to not return, and `False` to return. |
