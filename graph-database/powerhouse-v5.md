# Ultipa Powerhouse (v5)

**Ultipa Powerhouse (v5)**, implemented in C++, introduces a novel hybrid architecture that delivers high-performance graph computing with exceptional scalability.

## Architecture

<center><img style="max-width:80%;" src="https://img.ultipa.cn/img/2024-10-23-14-02-57-v5-Architecture.jpg" /><br><span style="color:#999;">Ultipa Powerhouse (v5) Architecture</span><br><br></center>

Graph processing systems often face trade-offs between data locality and computational efficiency. Traditional distributed computing clusters, though horizontally scalable, struggle to maintain optimal data locality due to their generic design. Conversely, specialized high-density computing (HDC) clusters excel in memory efficiency but may lack the scalability and flexibility required for diverse and elastic graph workloads.

The Ultipa Powerhouse (v5) bridges this gap, seamlessly integrating the best of scalability and performance. It ensures efficient graph traversal and computation, catering to the demands of large-scale, enterprise-grade graphs (billions of nodes), while providing the flexibility required for elastic and dynamic workloads.

The four main components in the architecture of Ultipa Powerhouse (v5) are:

- <a href="#Shard-Servers">Shard Servers</a>
- <a href="#HDC-Servers">HDC Servers</a>
- <a href="#Name-Servers">Name Servers</a>
- <a href="#Meta-Servers">Meta Servers</a>

### Shard Servers

**Sharding** refers to the process of dividing a large graph in the database into smaller chunks called shards, which are stored across multiple servers (or instances). This allows the database to scale horizontally, increasing its total storage capacity.

Key concepts in sharding include:

- `sharding_key`: A specific property of data in the graph, such as `_id`, used to determine how the data will be distributed across multiple shards.
- `sharding_function`: A function that takes the `sharding_key` as input and maps it to a shard where the data will be stored.
- `shard_id`: A unique identifier, typically numbered sequentially (`1`, `2`, `3`, ...), assigned to each shard.

Ultipa's sharding logic is **node-centric**, with each shard containing a balanced, unique subset of nodes in the graph. The `shard_id` that a node is distributed to is computed as:

<center>
<math>
    <mo>shard_id = sharding_function (sharding_key)</mo>
</math>
</center><br>

Each edge is stored twice along with its two endpoints for efficient graph traversal: as an outgoing edge in node `A`'s shard (`A->B`) and as an incoming edge in node `B`'s shard (B<-A).

Each shard server also handles computation. With intelligent sharding, high performance graph queries and distributed algorithms are achieved by **maximizing data locality** and **minimizing cross-instance communication overhead**. Direct access to local data enables on-shard computation, avoiding expensive data transfers and providing ultra-fast performance.

Each shard has **multi-replica** data storage, maintaining multiple data copies (replicas). This strategy strengthens overall resilience, ensuring high availability, fault tolerance, and better reliability.

Overall, the storage-computing coupled shard servers yield highly competitive performance over most centralized or distributed graph systems while with automated and much better horizontal scalability.

### HDC Servers

The HDC (High-Density Computing) servers offer **elastic computing power** that dynamically adjusts resources, adding or removing graphs from the memory space based on computational needs.

HDC accesses and loads graphs from the shard servers and allows **real-time data synchronization** (configurable) and **selective data ingestion** (based on schema, properties or filtering conditions). This makes it more flexible and accurate compared to projection-based frameworks, which may have stale or outdated data.

The HDC servers support over 100 graph algorithms and queries, delivering performance that is exponentially (10x or more) faster than shard servers, especially for deep query and algorithmic operations.

### Name Servers

The name servers focuse on processing client requests efficiently. Its main responsibilities include:

- **GQL (ISO Standard)** and **UQL (Ultipa Native)**: Parses GQL/UQL queries, optimizes them to improve efficiency, and executes the optimized queries to retrieve results.
- **Load Balancing**: Distributes incoming requests efficiently across multiple servers, ensuring system stability and preventing overload on a single server.
- **Execution Plan:** Develops and organizes the steps required to execute queries efficiently, improving overall performance.
- **Protocols:** Defines communication methods and rules used between components and servers, ensuring proper interactions.
- **MapReduce:** Supports large-scale, parallel data processing by dividing tasks and distributing them across servers for faster computation.
- **Transaction Management:** Ensures that transactions are consistent, reliable, and atomic, maintaining database integrity.

### Meta Servers

The meta servers are responsible for overall system coordination, integrity, and optimization. Its key functions include:

- **Global Info**: Manages structure and meta-data about the entire graph, enabling coordinated processing.
- **Job Management**: Handles the scheduling, execution, and monitoring of jobs (tasks), ensuring that they are efficiently processed.
- **Access Control**: Manages user permissions and security controls, ensuring only authorized users have access to data and operations.
- **High Availability:** Uses the RAFT consensus algorithm to manage replicas and ensure consistency across distributed components.
- **Service Register:** Manages the registry of services within the system, helping to coordinate different services and components for smooth operation.
- **Shard Management:** Oversees the distribution, allocation, and scaling of shards, ensuring data is evenly distributed and accessible.

## Supported Products

Ultipa Powerhouse (v5) comes with an all-encompassing toolkit designed to optimize and accelerate your graph experience — from querying, analysis, and visualization to seamless data migration, effortless deployment, and smooth integration with external applications. These tools are crafted to supercharge productivity, simplifying the management and interaction with even the most complex graph data.

Highlighted products include:

- <a target="_blank" href="/docs/gql/">GQL</a>: The ISO-compliant Graph Query Language (GQL), setting the global standard.
- <a target="_blank" href="/docs/uql">UQL</a>: Ultipa Query Language (UQL) tailored for unmatched graph database performance.
- <a target="_blank" href="/docs/graph-analytics-algorithms">Ultipa Graph Analytics & Algorithms</a>: Featuring over 50 standard graph algorithms designed for data science excellence.
- <a target="_blank" href="/docs/manager-user-guide">Ultipa Manager</a>: A highly visual, intuitive graph database management system (GDBMS) for effortless database control.
- <a target="_blank" href="/docs/transporter-user-guide">Ultipa Transporter</a>: A robust data import/export tool supporting a wide range of data sources and formats like MySQL, PostgreSQL, SQL Server, BigQuery, Neo4j, Kafka, CSV, JSON/JSONL, GraphML, and RDF.
- <a target="_blank" href="/docs/drivers">Ultipa Drivers</a>: Full-fledged API/SDKs enabling seamless application development, supporting Java, Go, Python, NodeJS, C#, and RESTful API.
- <a target="_blank" href="/docs/tools/cli">Ultipa CLI</a>: A cross-platform command-line interface (CLI) for executing GQL and UQL queries across Windows, Mac, and Linux environments.

## References

To learn more about Ultipa Powerhouse (v5) and review testing reports, read our paper, *<a  target="_blank" href="https://dl.acm.org/doi/pdf/10.1145/3663741.3664790">A Unified Graph Framework for Storage-Compute Coupled Cluster and High-Density Computing Cluster</a>*.
