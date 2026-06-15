# Installing Algorithms

Algorithms for HDC and distributed versions are managed differently, resulting in distinct installation methods. 

## HDC Algorithms

HDC algorithms are provided as hot-pluggable plugins, enabling installation, update, and removal without causing server downtime. Each package includes a **.so** file and a **.yml** configuration file, requiring independent installations on each HDC server.

### Installation Methods

You can install HDC algorithms in different ways:

- **Ultipa Manager**: If you're using the GDBMS of Ultipa, install algorithms directly via the <a target="_blank" href="/docs/manager-user-guide/hdc">HDC module</a> interface.
- **Ultipa CLI**: This cross-platform command line interface allows you to install algorithms using the <a target="_blank" href="/docs/tools/cli">install algo</a> command.
- **SDKs**: For programmatic access, refer to the relevant algorithm management section for your preferred SDK language:
  - <a target="_blank" href="/docs/drivers/java-algorithm-management">Java</a>
  - <a target="_blank" href="/docs/drivers/python-algorithm-management">Python</a>
  - <a target="_blank" href="/docs/drivers/go-algorithm-management">Go</a>
  - <a target="_blank" href="/docs/drivers/nodejs-algorithm-management">Node.js</a>
  - <a target="_blank" href="/docs/drivers/csharp-algorithm-management">C#</a>
  
### Showing HDC Algorithms

To view the algorithms installed on an HDC server like `hdc-server-1`:

<div tab="code">

```gql
SHOW HDC ALGO ON "hdc-server-1"
```

```uql
show().hdc("hdc-server-1")
```

</div>

The returns include the `_algoList` table, which lists all algorithms installed on the specified HDC server. It includes the following fields:

| <div table-width="23">Field</div> | Description |
| -- | -- |
| `name` | Name of the algorithm. |
| `type` | Type of the algorithm, which can be `algo` or specific system algorithms like `pathfind` and `khop`. System algorithms come pre-installed on the HDC server, enabling essential graph queries and other functions. |
| `write_support_type` | Supported writeback execution modes. |
| `can_rollback` | Indicates `true` for algorithms with updates that allow rollback. |
| `params` | Includes `parameters`, `write_to_file_parameters` and `write_to_db_parameters`. |

## Distributed Algorithms

Distributed algorithms in Ultipa Powerhouse (v5) come pre-installed as part of the deployment package, so no additional installation is needed. These algorithms are readily available for use without further setup.
