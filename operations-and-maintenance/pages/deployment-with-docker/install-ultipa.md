# Install Ultipa

You can install **Ultipa Powerhouse (v5)** on Linux machines. This guide outlines the steps to deploy a cluster using Docker and an automated deployment script.

## Cluster Overview

**Ultipa Powerhouse (v5)** is designed for high-performance, distributed graph processing and follows a modular, role-based architecture comprising the following components:

- **Name Servers:** Coordinate client requests and manage routing within the cluster.
- **Meta Servers:** Handle persistent metadata and system configuration.
- **Shard Servers:** Store and process graph data, supporting horizontal scalability.
- **HDC (High-Density Computing) Servers**: Optional. Perform advanced analytics and large-scale computations.

All server roles communicate over an internal network. For high availability and fault tolerance, each role can be deployed redundantly.

For a detailed architectural overview, see the <a target="_blank" href="/docs/graph-database/ultipa-powerhouse-v5">Ultipa Powerhouse (v5)</a>.

## System Requirements

The following hardware and software requirements must be met for deploying each server in the Ultipa cluster:

#### Operating System

- CentOS 7+, Ubuntu 18.04+, or other compatible Linux distributions.

#### Hardware Requirements

- **CPU**: x86\_64 or ARM64 (aarch64) architecture; minimum 4-core processor.
- **Memory**: At least 8 GB RAM (16 GB or more recommended).
- **Disk**: SSD recommended; minimum 100 GB of available disk space.

#### Network Configuration

- Static IP address required.
- **External service ports**: `3050`, `60061`
- **Internal cluster communication ports**: `51060`, `51061`, `56555`, `41061`, `41062`, and others depending on the number of service nodes and cluster configuration.

All required internal ports must be open to allow unrestricted node-to-node communication.

#### Prerequisite Software

- Docker Engine (latest stable version recommended)
- Shell (e.g., Bash)
- Firewall
- SSH

#### Additional Requirements

* Passwordless SSH (key-based authentication) must be configured among all cluster nodes.
* Firewall rules must allow traffic on all required ports.
* Deployment must be performed by the **root user** or a user with **sudo privileges**.

## Deployment Procedure

The following deployment procedure uses the `ultipa.sh` script. <a href="#Deployment-Script">Learn more about this script</a>

### 1. Edit the Configuration File

The `ultipa.sh` script can be uploaded to one of the cluster nodes for execution or run from a dedicated deployment host.

Then, generate an example configuration file:

```bash
./ultipa.sh cluster genconf
```

This command creates an `example.sh` configuration script in the same directory as `ultipa.sh`.

Edit `example.sh` to match your environment:

| <div table-width="40">Variable</div> | Description |
| -- | -- |
| `CLUSTER_NAME` | Name of the cluster. |
| `LICENSE_FILE_PATH`,<br>`ALGO_LICENSE_FILE_PATH` | Paths to the license files. |
| `DOCKER_MOUNT_PATH` | Path used for Docker volume mounting. |
| `SSH_USER`,<br>`SSH_PRIVATE_KEY` | SSH username and private key for accessing cluster nodes. |
| `META_IMAGE`,<br>`SHARD_IMAGE`,<br>`NAME_IMAGE`,<br>`HDC_IMAGE` | Docker image names to be pulled from a registry. |
| `META_IMAGE_TAR`,<br>`SHARD_NAME_IMAGE_TAR`,<br>`HDC_IMAGE_TAR` | Paths to local Docker image TAR files (please contact <a href="mailto:support@ultipa.com">support@ultipa.com</a> to obtain these images). |
| `NAME_SERVER_PUBLIC_START_PORT`,<br>`NAME_SERVER_LIST`<br>`META_SERVER_START_PORT`,<br>`META_SERVER_LIST`,<br>`HDC_SERVER_START_PORT`,<br>`HDC_SERVER_LIST`,<br>`SHARD_SERVER_START_PORT`,<br>`SHARD_SERVER_LIST` | Server IPs and ports:<ul><li>Each Name server uses 2 ports: <code>private_port = public_port + 1</code>.</li><li>Each Shard server uses 2 ports: <code>stream_port = shard_port + 1</code>.</li><li>Use space-separated IPs for Name, Meta, and HDC servers.</li><li>For Shard servers, use spaces to separate replicas, commas to separate shards.</li></ul> |
| `META_CONFIG`,<br>`NAME_CONFIG`,<br>`SHARD_CONFIG`,<br>`HDC_CONFIG` | Custom configurations for each server role in key-value format. You can write multiple key-value pairs on one line separated by spaces, or on separate lines. Click <a href="#Configuration-Guide">here</a> to see the full list of supported configuration options for each role. |

Example:

<p tit="example.sh"></p>

```sh
CLUSTER_NAME="ultipa-v5-cluster"

LICENSE_FILE_PATH="./ultipa.lic"
ALGO_LICENSE_FILE_PATH="./ultipa_algo.lic"

DOCKER_MOUNT_PATH="/data/docker_mounts"

SSH_USER="root"
SSH_PRIVATE_KEY="/root/.ssh/id_rsa"

META_IMAGE="<repository>/<image>:<tag>"
SHARD_IMAGE="<repository>/<image>:<tag>"
NAME_IMAGE="<repository>/<image>:<tag>"
HDC_IMAGE="<repository>/<image>:<tag>"

META_IMAGE_TAR=""
SHARD_NAME_IMAGE_TAR=""
HDC_IMAGE_TAR=""

NAME_SERVER_PUBLIC_START_PORT="61060"
NAME_SERVER_LIST="192.168.189.129"

META_SERVER_START_PORT="51060"
META_SERVER_LIST="192.168.189.130"

HDC_SERVER_START_PORT="56555"
HDC_SERVER_LIST="192.168.189.128"

SHARD_SERVER_START_PORT="41061"
SHARD_SERVER_LIST="192.168.189.131 192.168.189.132, 192.168.189.133"

META_CONFIG=""
NAME_CONFIG=""
SHARD_CONFIG=""
HDC_CONFIG=""
```

### 2. Upload License Files

Upload the Ultipa license files `ultipa.lic` and `ultipa_algo.lic` to the directory as specified by `LICENSE_FILE_PATH` and `ALGO_LICENSE_FILE_PATH` in `example.sh`.

### 3. Deploy the Cluster

Deploy all components (Meta, Name, Shard, HDC):

```bash
./ultipa.sh cluster create --config example.sh
```

### 4. Verify Cluster Status

Check if all services are running:

```bash
./ultipa.sh cluster stat --config example.sh
```

Expected output:

```bash
------- meta status ------- :
192.168.189.130 51060: root          78       1  2 07:18 ?        00:00:48 ./meta-server
------- name status ------- :
192.168.189.129 61061 :root          79       1  2 07:18 ?        00:00:44 ./name-server
------- shard status ------- :
192.168.189.131 41061 1 :   root          81       1  2 07:20 ?        00:00:52 ./shard-server
192.168.189.132 41063 1 :   root          79       1  2 07:20 ?        00:00:51 ./shard-server
192.168.189.133 41065 2 :   root          80       1  2 07:20 ?        00:00:47 ./shard-server
------- hdc status ------- :
192.168.189.128 56555 :root          81       1  2 07:19 ?        00:00:44 ./hdc-server
```

### 5. Access the Cluster

Once the cluster is deployed, you can connect to it through the Name Server endpoints (e.g., `http://192.168.1.101:61060`).

To manage your graph databases more easily, you can also deploy Ultipa Manager. See the guide <a target="_blank" href="/docs/database-administration/install-ultipa-manager">Install Ultipa Manager</a>.

## Deployment Script

Ultipa provides a deployment script, `ultipa.sh`, to automate the setup and configuration of the cluster environment. Click <a href="https://img.ultipa.cn/resources/ultipa.sh">here</a> to download it.

The following are the available commands in the `ultipa.sh` deployment script:

#### Image Management Commands

`./ultipa.sh image upload --config example.sh`
- Uploads Docker images (Meta/Name/Shard/HDC) to all cluster nodes for offline deployment. The corresponding `*_IMAGE_TAR` variables must be set in `example.sh`.

`./ultipa.sh image info --config example.sh`
- Shows image names/tags for Meta, Name, Shard, and HDC servers.

`./ultipa.sh image delete --config example.sh`
- Deletes only the Ultipa images defined in `example.sh`.

`./ultipa.sh image DELALL --config example.sh`
- Dangerous! Deletes all images from `docker-registry.ultipa-inc.org:5000` on all nodes.

#### Cluster Lifecycle Commands

`./ultipa.sh cluster create --config example.sh`
- Performs full cluster deployment: creates containers for Meta, Name, Shard, and HDC servers; configures each component; starts the cluster; and registers Shards and HDCs.

`./ultipa.sh cluster start --server name --config example.sh`
- Starts specific server types (e.g., `--server shard`) or all if `--server` is omitted.

`./ultipa.sh cluster stop --server name --config example.sh`
- Gracefully stops specific server types (e.g., ``--server hdc``) or all if `--server` is omitted.

`./ultipa.sh cluster destroy --config example.sh`
- Destructive! Removes all containers and data directories.

`./ultipa.sh cluster update --config example.sh`
- Updates all containers using the images specified in `example.sh`. This process stops the cluster, recreates the containers with the new images, and then restarts the cluster.

#### Cluster Configuration & Inspection

`./ultipa.sh cluster reconfig --config example.sh`
- Applies configuration changes from `example.sh` without restarting the cluster. Use this after modifying `*_CONFIG` variables (e.g., `META_CONFIG`). It updates the specified configuration items across all configuration files for the corresponding server role.

`./ultipa.sh cluster info --config example.sh`
- Displays cluster connection details.

`./ultipa.sh cluster stat --config example.sh`
- Checks runtime status of all servers.

`./ultipa.sh cluster addhdc --config example.sh`
- Adds new HDC servers to the cluster. Use this after modifying the `HDC_SERVER_LIST` variable in `example.sh`.

`./ultipa.sh cluster addshard --config example.sh`
- Adds new Shard servers to an existing cluster. Use this after modifying the `SHARD_SERVER_LIST` variable in `example.sh`.

#### Utility Commands

`./ultipa.sh cluster genconf`
- Generates a template `example.sh` with default values.

`./ultipa.sh lic upload --config example.sh`
- Uploads updated `ultipa.lic` and `ultipa_algo.lic` to Meta servers.

## Server Configurations

The configuration files of each component are located at `/data/docker_mounts/<container_name>/conf/`. I.e., `meta-server.config`, `name-server.config`, `shard-server.config`, and `hdc-server.config`.

Modifications to the configuration items will take effect only after the corresponding server is rebooted, unless hot updates are supported.

### Meta Server

#### Server

| <div table-width="20">Item</div> | <div table-width="15">Default</div> | Description |
| -- | -- | -- |
| `addr` | `127.0.0.1:50061` | Meta server listening address. |
| `dbpath` | `data` | Directory where database files are stored. |
| `license` | `./resource/cert/ultipa.lic` | Directory where the server license file is stored. |
| `algo_license` | `./resource/cert/ultipa_algo.lic` | Directory where the algorithm license file is stored. |
| `db_backup_path` | `backup_data` | Directory for storing backup files. **Note:** If this directory is not mounted, the backup files will be lost during the next update. |
| `real_time_sync_meta_to_shards` | `true` | If `true`, Meta servers automatically synchronizes with shards. If `false`, synchronization happens only on the next heartbeat if `heartbeat_sync_meta_to_shards` is true.
| `heartbeat_sync_meta_to_shards` | `false` | If `true`, Meta servers send a snapshot to shards upon detecting outdated versions during heartbeat. If `false`, snapshots are not sent during heartbeat. |

#### Log

| <div table-width="20">Item</div> | <div table-width="15">Default</div> | Description |
| -- | -- | -- |
| `level` | `3` | Log level: `1` = fatal, `2` = error, `3` = info, `4` = debug. |
| `stdout` | `true` | Whether to output logs to standard output. |
| `color` | `true` | Whether to display colors in the terminal. |
| `file_retain_counts` | `5` | Number of log files to retain. |
| `log_file_size` | `200` | Maximum size (in MB) of a single log file. |

#### BaseDB

| <div table-width="20">Item</div> | <div table-width="15">Default</div> | Description |
| -- | -- | -- |
| `db_buffer_size` | `512` | Memory table buffer size in MB. Recommended to keep the default setting. |

#### HTAP

| <div table-width="20">Item</div> | <div table-width="15">Default</div> | Description |
| -- | -- | -- |
| `conf` | `127.0.0.1:50061,127.0.0.1:50062,127.0.0.1:50063` | Addresses for all replicas, separated by commas. The `conf` configuration must be identical for all replicas. |
| `election_timeout` | `5000` | Election timeout in milliseconds. The range is `5000` to `30000+`. If the cluster experiences high pressure, increasing the election timeout may help mitigate heartbeat delays. |
| `snapshot_interval` | `3600` | Interval for log compression in seconds. |

#### Transaction

| <div table-width="25">Item</div> | <div table-width="9">Default</div> | Description |
| -- | -- | -- |
| `graph_transaction_limit` | `1` | The maximum number of concurrent transactions allowed per graph. Set to `-1` for no limit. |

### Name Server

#### Server

| <div table-width="20">Item</div> | <div table-width="15">Default</div> | <div table-width="8">Hot Update</div> | Description |
| -- | -- | -- | -- |
| `addr` | `0.0.0.0:60061` | N | Name server listening address. Ultipa Client connects using this address. |
| `private_addr` | `127.0.0.1:60161` | N | Internal communication address between Name servers and Shard servers. All Shard servers must access this address. |
| `id` | `1` | N | Name server ID, in the range `[1–255]`. Each Name server must have a unique ID. |
| `meta_server_addrs` | `127.0.0.1:50061,127.0.0.1:50062,127.0.0.1:50063` | N |	Meta cluster addresses. |
| `data_path` |	`data` | N | Directory where data files are stored. |
| `worker_num` | `10` |	N | Number of service threads. Total threads = `worker_num` * 2. |
| `slow_query` | `5` | Y | Threshold for logging slow queries (in seconds). |
| `authorized` | `true` | N	| Whether to enable authentication, including username/password and permission checks. |
| `use_ssl` | `false` | `N` | Whether to enable SSL. |
| `ssl_key_path` | `./resource/cert/ultipa.key` | N | Path to SSL private key. Required if SSL is enabled. |
| `ssl_crt_path` | `./resource/cert/ultipa.crt` | N | Path to SSL certificate. Required if SSL is enabled. |
| `mem_threshold_percent` |	`80` | Y | Memory usage threshold (%). When exceeded, memory protection is enabled and requests are terminated. |
| `max_rpc_msgsize` | `4` | N | Maximum size (in MB) of an RPC message. |
| `max_rpc_batchnum` | `5000` | N | Maximum number of entries per RPC batch. |
| `enable_meta_cache` | `false` | Y | When enabled, metadata is cached on the Name server and not refreshed in real-time. DDL and DCL changes are synchronized after one heartbeat, but it is recommended to wait for two heartbeats before using the changes to avoid potential errors. Meanwhile, the Name server also synchronizes user information from the Meta server, allowing login and permission checks to be handled locally. |
| `heartbeat_interval_s` | `3` | N | Heartbeat interval in seconds. |
| `default_timeout` | `15` | N | Default request timeout in seconds. Can also be set via SDK request APIs. |

#### Log

| <div table-width="20">Item</div> | <div table-width="15">Default</div> | Description |
| -- | -- | -- |
| `level` | `3` | Log level: `1` = fatal, `2` = error, `3` = info, `4` = debug. |
| `stdout` | `true` | Whether to output logs to standard output. |
| `color` | `true` | Whether to display colors in the terminal. |
| `file_retain_counts` | `5` | Number of log files to retain. |
| `log_file_size` | `200` | Maximum size (in MB) of a single log file. |

#### Network

| <div table-width="20">Item</div> | <div table-width="15">Default</div> | Description |
| -- | -- | -- |
| `brpc_max_body_size` | `2147483648` |	Maximum size of a BRPC message in bytes. |
| `load_balance_read_only_workloads` | `false` | When disabled, read requests are sent only to the Shard leader; when enabled, read requests are load-balanced across all Shard replicas. |
| `shard_client_timeout_ms` | `900000` | Timeout (in milliseconds) for connecting to the Shard server. |
| `meta_client_timeout_ms` | `900000` | Timeout (in milliseconds) for connecting to the Meta server. |

#### Session

| <div table-width="25">Item</div> | <div table-width="9">Default</div> | Description |
| -- | -- | -- |
| `idle_timeout_second` | `600` | The duration (in seconds) without detecting a client heartbeat before an idle transaction is automatically terminated. |

### Shard Server

#### Server

| <div table-width="20">Item</div> | <div table-width="15">Default</div> | Description |
| -- | -- | -- |
| `addr` | `127.0.0.1:40061` | Shard server listening address. |
| `stream_addr` | `$addr.ip:$addr.port+100`	| Listening address for the stream service. |
| `shard_id` | `1` | Unique shard ID in the range `[1–255]`. Must not be duplicated. |
| `meta_server_addrs` | `127.0.0.1:50061,127.0.0.1:50062,127.0.0.1:50063` | Meta cluster addresses. |
| `dbpath` | `shard_data` | Directory for database storage files. |
| `db_backup_path` | `backup_data` | Directory for storing backup files. |
| `resource_path` | `resource` | Path to the resource directory. |
| `slow_query` | `5` | Threshold for logging slow queries (in seconds). |
| `mem_threshold_percent` |	`80` | Memory usage threshold (%). When exceeded, memory protection is enabled and requests are terminated. |
| `heartbeat_interval_s` | `3` | Heartbeat interval in seconds. |

#### Log

| <div table-width="20">Item</div> | <div table-width="15">Default</div> | Description |
| -- | -- | -- |
| `level` | `3` | Log level: `1` = fatal, `2` = error, `3` = info, `4` = debug. |
| `stdout` | `true` | Whether to output logs to standard output. |
| `color` | `true` | Whether to display colors in the terminal. |
| `file_retain_counts` | `5` | Number of log files to retain. |
| `log_file_size` | `200` | Maximum size (in MB) of a single log file. |

#### StorageEngine

| <div table-width="20">Item</div> | <div table-width="13">Default</div> | Description |
| -- | -- | -- |
| `db_buffer_size` | `512` | Memory table buffer size in MB. Recommended to keep the default setting. |
| `max_db_buffer_number` | `5` | Maximum number of memory tables. Increasing this (e.g., to `10`) can speed up bulk imports. |
| `enable_block_cache` | `true` | Enables block-level caching. |
| `block_cache_size` | `1024` |	Block cache size in MB. Only takes effect if `enable_block_cache=true`. It's recommended to allocate 30%–50% of available system memory. |
| `enable_prefix_bloom_filter` | `true` | Improves read performance at the cost of higher memory usage. |
| `enable_partition_index_filter` | `false` | Reduces memory usage of bloom filters but may decrease read performance in some scenarios. |
| `disable_auto_compactions` | `false` | Disables automatic compactions. Recommended to set to true during large-scale data imports. |
| `disable_page_cache` | `false` | If the block cache is sufficiently large, page cache can be disabled. |
| `node_key_mapping_num` | `5000000` | Number of cached node keys (`_id`). |
| `edge_key_mapping_num` | `5000000` | Number of cached edge keys (`_uuid`). |
| `transaction_mode` | 0 | Whether transactions are enabled: `0` = disabled, `1` = enabled. |

#### ComputeEngine

| <div table-width="20">Item</div> | <div table-width="15">Default</div> | Description |
| -- | -- | -- |
| `engine_type` | `default` | Type of the compute engine; only `default` is supported now. |
| `enable_graph_cache` | `false` | Enables graph cache; when `engine_type=speed`, node cache and edge cahce will also be enabled. |
| `graph_cache_size` | `1024` | Size of the graph cache in MB; applies only when `engine_type=default`; recommended to increase if memory allows. |
| `graph_cache_bucket_number` | `1024` | Number of cache buckets; applies only when `engine_type=default`. |
| `graph_cache_max_memory_policy` | `lru` |	Eviction policy for graph cache when max memory is reached; applies only when `engine_type=default`.<br><br>Eviction policies:<ul><li><code>lru</code>: Prioritizes the retention of hotspot data; with the same amount of data, this structure occupies the largest amount of memory.</li><li><code>unlimited</code>: In this case, the <code>graph_cache_size</code> does not take effect, which means that there is no memory size limit, so it may cause an Out-of-Memory Error (OOM); with the same amount of data, the memory usage of this structure is minimal</li><li><code>noeviction</code>: A safer variant of <code>unlimited</code>; once the memory limit is reached, it stops adding new data to the cache without evicting existing data.</li></ul> |
| `enable_node_cache` | `false` | Enables node cache; applies only when `engine_type=default`. |
| `enable_edge_cache` | `false` | Enables edge cache; applies only when `engine_type=default`. |
| `node_cache_size` | `1024` | Size of the node cache in MB; applies only when `engine_type=default`; recommended to increase if memory allows. |
| `edge_cache_size` | `1024` | Size of the edge cache in MB; applies only when `engine_type=default`; recommended to increase if memory allows. |
| `default_timeout`	| `15` | Request timeout in seconds; SDKs can override this setting per request. |
| `default_max_depth` | `30` | Maximum traversal depth; the default setting is generally sufficient. |

#### Pregel

| <div table-width="20">Item</div> | <div table-width="15">Default</div> | Description |
| -- | -- | -- |
| `num_send_workers` | `-1` | Number of worker threads used to send messages during Pregel computation. |

#### HTAP

| <div table-width="20">Item</div> | <div table-width="15">Default</div> | Description |
| -- | -- | -- |
| `conf` | `127.0.0.1:40061,127.0.0.1:40062,127.0.0.1:40063` | Addresses for all replicas, separated by commas. |
| `election_timeout` | `5000` | Election timeout in milliseconds. The range is `5000` to `30000+`. If the cluster experiences high pressure, increasing the election timeout may help mitigate heartbeat delays. |
| `snapshot_interval` | `3600` | Interval for log compression in seconds. |

#### Network

| <div table-width="20">Item</div> | <div table-width="15">Default</div> | Description |
| -- | -- | -- |
| `brpc_max_body_size` | `2147483648` | Maximum size of a BRPC message in bytes. |
| `shard_client_timeout_ms` | `900000` | Timeout (in milliseconds) for connecting to the Shard server. |
| `meta_client_timeout_ms` | `900000` | Timeout (in milliseconds) for connecting to the Meta server. |

### HDC Server

#### Server

| <div table-width="20">Item</div> | <div table-width="15">Default</div> | Description |
| -- | -- | -- |
| `addr` | `0.0.0.0:55555` | HDC server listening address. |
| `server_name` | `hdc-server-1` | Name of the HDC server. |
| `meta_server_addrs` | `127.0.0.1:50061,127.0.0.1:50062,127.0.0.1:50063` | Meta cluster addresses. |
| `data_path` | `data` | Directory where database files are stored. |
| `worker_num` | `10` |	Number of worker threads. Recommended to match the number of CPU cores. |
| `cache_load_size` | `1000000` | Number of points to load into HDC cache per batch. Maximum: `10,000,000`. |
| `cache_load_pool_size` | `5` | Number of cache pools, adjust to balance memory usage and performance. |
| `slow_query` | `5` | Threshold for logging slow queries (in seconds). |
| `authorized` | `true` | Whether to enable authentication, including username/password and permission checks. |
| `use_ssl` | `false` |	Whether to enable SSL. |
| `ssl_key_path` | `./resource/cert/ultipa.key` | Path to SSL private key. Required if SSL is enabled. |
| `ssl_crt_path` | `./resource/cert/ultipa.crt` | Path to SSL certificate. Required if SSL is enabled. |
| `mem_threshold_percent` | `80` | Memory usage threshold (%). When exceeded, memory protection is enabled and requests are terminated. |
| `max_rpc_msgsize` | `4` |	Maximum size (in MB) of an RPC message. |
| `max_rpc_batchnum` | `5000` | Maximum number of entries per RPC batch. |

#### Log

| <div table-width="20">Item</div> | <div table-width="15">Default</div> | Description |
| -- | -- | -- |
| `level` | `3` | Log level: `1` = fatal, `2` = error, `3` = info, `4` = debug. |
| `stdout` | `true` | Whether to output logs to standard output. |
| `color` | `true` | Whether to display colors in the terminal. |
| `file_retain_counts` | `5` | Number of log files to retain. |
| `log_file_size` | `200` | Maximum size (in MB) of a single log file. |

#### Computation

| <div table-width="20">Item</div> | <div table-width="15">Default</div> | Description |
| -- | -- | -- |
| `default_timeout` | `15` | Default request timeout in seconds. |
| `default_max_depth` | `30` | Maximum traversal depth. The default setting of 30 levels is generally sufficient. |

#### Network

| <div table-width="20">Item</div> | <div table-width="15">Default</div> | Description |
| -- | -- | -- |
| `brpc_max_body_size` | `2147483648` | Maximum size of a BRPC message in bytes. |
| `shard_client_timeout_ms` | `900000` | Timeout (in milliseconds) for connecting to the Shard server. |
| `meta_client_timeout_ms` | `900000` | Timeout (in milliseconds) for connecting to the Meta server. |
