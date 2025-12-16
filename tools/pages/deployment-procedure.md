# Deployment Procedure

## Docker Deployment

### Software Requirement

- Docker CE 19+ or equivalent Docker EE

### Installation

- Pull docker image online or load docker image offline<br>
  - Online: `docker pull [docker url]/tag:version`<br>
  - Offline: `docker load -i < 'docker image file' >`
- Get docker image ID: `docker images`
- Start docker container
<p tit= "shell" ></p> 

```shell
docker run -itd --net=host 
-v <absolute_path_to_data_folder>:/opt/ultipa-server/data 
-v <absolute_path_to_config_folder>:/opt/ultipa-server/config 
-v <absolute_path_to_log_folder>:/opt/ultipa-server/log 
-v <absolute_path_to_mlog_folder>:/opt/ultipa-server/mlog 
-v <absolute_path_to_algo_folder>:/opt/ultipa-server/algo 
-e TZ=Europe/Paris 
--name ultipa-server --ulimit nofile=90000:90000 --privileged `image ID`
docker exec -it ultipa-server bash 
start
```

Docker will report <i>'No config files found'</i> error during the first start, while at the same time, it creates an example file named <i>example.config</i> automatically. Copy and rename <i>example.config</i> to <i>server.config</i>, and modify this file by following <i>Server Configuration</i> (See below) before restarting.

- Docker run options<br>
  - Set timezone: `-e TZ=Europe/Paris`<br>
  - Increase number of open files limit: `-ulimit nofile=90000:90000 --privileged`<br>
  - Enable GDB debugging: `--cap-add=SYS_PTRACE --security-opt seccomp=unconfined`
- Common reasons that docker fails to start

| Error | Description |
| ----- | ----------- |
| Machine binding failed!!! | Failed to bind MAC address of the machine. Please make sure that the license is copied to the right location, and MAC address of new machine must be added into the license |
| License expired! Server is stopping... | License is expired, new license is required |
| Rpc BuildAndStart failed! | Server public port is occupied |

### Cluster Deployment

- Prepare cluster machines, ascertain the IP and port for inner communication and external services, ensure that every machine can access the private ports of other machines.
- It is recommended to use `ultipa_doctor_linux_v4.0 gen_config` to generate cluster configuration file, then copy the file to the corresponding machine, as detailed in documentation <i>Ultipa Doctor 4.0</i>. You may also configure the cluster manually.
- Install <i>ultipa-server</i> on every machine using Docker and start service for all machines.
- Check the following items after the deployment is finished:
  1. Process check. Every machine should have <i>ultipa-server</i> process. If not, locate the problem by checking the server log and htap log.
  2. Cluster status check. It is recommended to use `ultipa_doctor_linux_v4.0 health_check` as detailed in documentation <i>Ultipa Doctor 4.0</i>. You may also use `curl http://private_addr:private_ip/raft_admin`, the cluster is successfully deployed if the Leader is elected normally.
  3. Use Ultipa Manager (if has) to check if the cluster is displayed well.
  4. Import testing data. Enter <i>ultipa-server</i> container from any machine to execute the import: `cd example && sh import_example.sh`. 
- Note: When new cluster is being deployed, initial data of each instance must be empty, and do not copy data catalog in production environment!

## Server Configuration

### Configuration File Path

config/server.config 

### Global Configuration

section:[Server] 

| Item | Default | Description |
| ---- | ------- | ----------- |
| host | 0.0.0.0:60061 | Server listening address |
| server_id | 1 | `server_id` must be unique for cluster; single server should use the default value |
| dbpath | data | Database file storage path |
| resource_path | resource | Resources storage path, resources such as full-text dictionary |
| worker_num | 10 | Number of service threads, that is, `worker_num * 2` |
| slow_query | 5 | Threshold of slow query, 5 seconds by default |
| authorized  | true | Whether to enable authentication mode |
| use_ssl | false | Whether to enable ssl |
| ssl_key_path | ./resource/cert/ultipa.key | Valid only if ssl is enabled |
| ssl_crt_path | ./resource/cert/ultipa.crt | Valid only if ssl is enabled |
| license | ./resource/cert/ultipa.lic | License |
| mem_threshold_percent | 80 | Limit of memory usage, 80% by default. Memory protection is turned on once exceeds the limit, and requests will be terminated. |

### Log Configuration

section:[Log] 

| Item | Default | Description |
| ---- | ------- | ----------- |
| level | 3 | 1: fatal, 2: error, 3: info, 4: debug |
| stdout | true | Whether to get log on standard output |
| color | true | Whether to display colors in the terminal |
| file_retain_counts | 5 | Number of log files to retain |
| log_file_size | 200 | Maximum size of single log file, 200M by default |

### Supervisor Configuration

section:[Supervisor]

| Item | Default | Description |
| ---- | ------- | ----------- |
| stat_period | 3 | Count QPS within 3s |

### Persistence Configuration

section:[BaseDB] 

| Item | Default | Description |
| ---- | ------- | ----------- |
| db_buffer_size | 512 | Size of db buffer, 512M by default is recommend|
| lru_cache | false | Whether to use lru cache |
| lru_cache_size | 5000000 | Size of lru cache |

### Engine Configuration

section:[Engine] 

| Item | Default | Description |
| ---- | ------- | ----------- |
| template_max_depth | 10 | Maximum template query depth, 10 by default is recommended |
| super_node_size | 100000 | Super node size, 100000 by default means that any node with 100000 or more neighbors is regarded as super node  |
| ab_timeout | 15 | AB query timeout, 15 seconds by default, which can also be set via SDK request interface |
| default_max_depth | 30 | Maximum query depth, 30 by default is recommended |
| load_direction_mode | 1 | 1: Two-direction load<br>2: Single-direction load (a-->b)<br>3: Single-direction load (b<--a)<br>(Use the default, no need to change) |

### HTAP

section:[HTAP] 

| Item | Default | Description |
| ---- | ------- | ----------- |
| private_addr | 127.0.0.1:60161 | Private address, IP and port for inter-cluster communication, the port must be unique with the server port |
| conf | 127.0.0.1:60161\|127.0.0.1:60061:1,<br>127.0.0.1:60162\|127.0.0.1:60062:3,<br>127.0.0.1:60163\|127.0.0.1:60063:1 | Cluster configuration,127.0.0.1:60161\|127.0.0.1:60061:1. The first <i>ip:port</i> is `private_addr`, the second <i>ip:port:role</i> is `public_addr:role`. `conf` of all machines must be consistent |
| data_path | data/htap | Cluster data storage path |
| election_timeout | 5000 | Election timeout, the allowed range is 5000ms to 30000ms+. When there is heartbeat delay due to pressure, the election timeout can be turned up appropriately. |
| election_heartbeat_factor | 10 | Ratio of election timeout to heartbeat time |
| snapshot_interval | 3600 | Interval to compress log, 3600 seconds by default |

## Detailed Cluster Configuration

### Raft

Raft normally uses odd number of nodes, such as 3, 5, 7, etc. That is because Raft can only serve when more than half of the nodes are online, and 'more than half' means `N/2+1` rather than `N/2`. For example, it requires >=2 nodes online for 3-node cluster, and >=3 nodes online for 5-node cluster.

For clusters with an even number of nodes, Raft requires 2-node cluster's 2 nodes both online, and 4-node cluster has >=3 nodes online. 

Although even number of nodes consume more hardware resources than odd number of nodes but bring worse availability, in some strong consistency scenarios, even number of nodes have more advantages in data disaster tolerance to guarantee data safety.

In Ultipa system, each GraphSet has a Raft group, and each Raft group is completely independent with different Leader and Follower. 

Note: Newly created GraphSet cannot be used immediately until Raft cluster elects the Leader. The delay is determined by the configured election time. 

### Role

- Role 0: Node cannot provide reads when it is Follower, it is used for consistent reads
- Role 1: Node can provide reads when it is Follower, it is used for load balancing reads
- Role 2: Algorithm node which can run algorithms, but cannot participate in load balancing reads
- Role 3: Algorithm node which can participate in load balancing reads
- Role 4: Backup node which only synchronizes data, but does not participate in elections

| Role | Unreadable as Follower | Readable as Follower | Algorithm Node | Backup Node | 
| ---- | ---- | ---- | ---- | ---- |
|  0  |  Y  |  N  |  N  |  N  |
|  1  |  N  |  Y  |  N  |  N  |
|  2  |  N  |  N  |  Y  |  N  |
|  3  |  N  |  Y  |  Y  |  N  |
|  4  |  N  |  N  |  N  |  Y  |

Notes:

- Node of role 2, 3 or 4 cannot be elected as the Leader.
- The number of algorithm nodes (role 2 or 3) in a cluster cannot exceed 50%.

### Election Timeout

To avoid simultaneous elections initiated by several nodes, Raft sets random election timeout:

Actual Election Timeout = random(election_timeout, 2*election_timeout)<br>
Heartbeat Time = max(election_timeout/election_heartbeat_factor, 10) 

## Cluster Operation

### Log

Cluster log: htap-yyyymmdd-HHMMSS.log<br>
Server log: server-yyyymmdd-HHMMSS.log

Logs begin with [HTAP] in server log are related to cluster synchronization, to view them: `cat server-yyyymmdd-HHMMSS.log |grep "[HTAP]"`

### Operation Tool 

<i>ultipa_cluster_cli</i> 

<i>Please use it with extra caution!</i>

#### Add Node

The initial data of the node to be added must be the same with other nodes. Start the newly joined node while ensuring the <i>data/htapp</i> directory is empty, otherwise new data may not be synchronized.

`ultipa_cluster_cli add --peer="$peer_being_added" --conf="$current_conf"`

```
./ultipa_cluster_cli add \ 
--peer="127.0.0.1:60163|127.0.0.1:60063:1" \ 
--conf="127.0.0.1:60161|127.0.0.1:60061:1,\ 
            127.0.0.1:60162|127.0.0.1:60062:1" 
```

#### Remove Node

`ultipa_cluster_cli remove --peer="$peer_being_removed" --conf="$current_conf"`

```
./ultipa_cluster_cli remove \ 
--peer="127.0.0.1:60163|127.0.0.1:60063:1" \ 
--conf="127.0.0.1:60161|127.0.0.1:60061:1,\ 
					  127.0.0.1:60162|127.0.0.1:60062:1,\ 
            127.0.0.1:60163|127.0.0.1:60063:1" 
```

#### Modify Cluster Node

`ultipa_cluster_cli change_conf --conf="$current_conf" --new_conf="$new_conf" `

#### Create Snapshot, Compress Log

`ultipa_cluster_cli snapshot_leader --peer="$target_peer" `

#### Change Leader

`ultipa_cluster_cli change_leader --peer="$target_leader" --conf="$current_conf" `

#### Resynchronization

When a node has data inconsistency, it has to be reset. Strictly follow the steps below to resynchronize data. Note: The following operations must be performed on the node that needs to be resynchronized! 

1. Use <i>ultipa_cluster_cli</i> to remove the node to be resynchronized
2. Stop the node to be resynchronized: `./ultipa-server stop`
3. Delete the entire data directory of the node to be resynchronized
4. Restart the node to be resynchronized
5. Use <i>ultipa_cluster_cli</i> to add the node to be resynchronized

### Cluster Monitoring

Monitoring page: http://private_host:private_port/raft_admin 

## Cluster FAQs

1\. Common Errors

- <i>This follower is not readable</i>: Read request was sent to an unreadable node.<br>
- <i>This follower is loading snapshot</i>: Node is loading snapshot, services temporarily unavailable.<br>
- <i>This peer is not leader, please redirect to the leader peer</i>: Node is not leader.<br>
- <i>This raft cluster has no leader</i>: No Leader was elected in cluster.

2\. If the following error occurs when restarting <i>ultipa-server</i>, it indicates that server may have data inconsistency due to abnormal exit during the log apply process. For data consistency, use `./ultipa-server -d -safe` startup to repair data automatically.

```
[HTAP] IMPORTANT! xxx pre_applied_index xxx != applied_index xxx, there might be data inconsistencies. 
[HTAP] Run ./ultipa-server -d -safe to safe-start the server. 
```

If `./ultipa-server -d -safe` fails to start, please strictly follow the corresponding steps to resynchronize.

```
[HTAP] safe-start failed! Please Resync this peer according to the document!
```

3\. Error <i>'reject term_unmatched AppendEntries'</i> occurs when restarting 

It indicates that the cluster status of the node is incorrect, which may be caused by the deletion of the htap directory. Since the last <i>prev_log_term</i> of the node is recorded in the cluster, and <i>local_prev_log_term</i> becomes 0 after the data is deleted locally, data synchronization is rejected as <i>local_prev_log_term</i> < <i>prev_log_term</i>.

When there is problem with the cluster status of the node, use <i>ultipa_cluster_cli</i> to resynchronize.

4\. Modify the configuration file and restart in order to change the listening IP or port of the node does not take effect. It is because cluster has already recorded the node's information, so you need to use `ultipa_cluster_cli change_conf` to update cluster information after the restart.

```
./ultipa_cluster_cli change_conf \ 
--conf="127.0.0.1:60161|127.0.0.1:60061:1,\ 
127.0.0.1:60162|127.0.0.1:60062:1,\
127.0.0.1:60163|127.0.0.1:60063:1" \ 
--new_conf="127.0.0.1:60261|127.0.0.1:60061:1,\ 
            127.0.0.1:60262|127.0.0.1:60062:1,\ 
            127.0.0.1:60263|127.0.0.1:60063:1" 
```

5\. Modify the configuration file and restart in order to change role does not take effect. It is because cluster has already cached this configuration, so you need to use `ultipa_cluster_cli change_conf` to update cluster information after the restart.

```
./ultipa_cluster_cli change_conf \ 
--conf="127.0.0.1:60161|127.0.0.1:60061:2,\ 
        127.0.0.1:60162|127.0.0.1:60062:1,\ 
        127.0.0.1:60163|127.0.0.1:60063:1" \ 
--new_conf="127.0.0.1:60161|127.0.0.1:60061:1,\ 
            127.0.0.1:60162|127.0.0.1:60062:1,\ 
            127.0.0.1:60163|127.0.0.1:60063:1" 
```

6\. If deletes htap directory without deleting GraphSet data directory, there will be problem when you use <i>ultipa_cluster_cli</i> tool to remove node and re-add node after the service is restarted. It is because data is synchronized from scratch due to the deletion of htap directory, and while data directory is not deleted, there will be data inconsistency due to duplicate execution logs! Thus, remember to delete all GraphSet data directories (including global) when you delete htap directory!

7\. When neither htap directory nor data directory is deleted, data will be synchronized from the last location when node is removed and re-added by using <i>ultipa_cluster_cli</i> tool. It is because the cluster still remembers the location when synchronizing log last time.
