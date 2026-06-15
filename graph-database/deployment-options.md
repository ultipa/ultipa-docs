# Deployment Options

Ultipa offers flexible deployment options to suit your needs: **Ultipa Cloud** and **On-Premises Deployment**.

Choose the deployment option that best aligns with your operational needs and resources. Whether you prefer the flexibility of the cloud or the control of on-premises deployment, Ultipa provides the tools and features to support your data management requirements.

## Ultipa Cloud

<center><img src="https://img.ultipa.cn/img/2025-01-09-18-08-47-Powerhouse-cloud.png"><br>
<span style="color:#999;">Database instances created in Ultipa Cloud<br><br></span></center>

Ultipa Cloud is a cloud-based graph database service which simplifies the deployment and management of graph databases, allowing users to focus on data handling and application development rather than infrastructure management. This service combines the power of Ultipa's advanced graph database technology with the convenience and flexibility of a cloud-based solution.

To get started with Ultipa Cloud, nagivate to <a target="_blank" href="https://cloud.ultipa.com/">cloud.ultipa.com</a>. **FREE TRIAL** is offered now.

## On-Premises Deployment

If you prefer to have full control over your data and infrastructure, the on-premises deployment option is ideal. With this choice, you can install and manage Ultipa on your own servers, giving you complete autonomy over your setup, data security, and performance optimization.

The recommended setup of Ultipa Powerhouse is as follows:

<table>
  <thead>
    <tr>
      <th style="width:15%;"></th>
      <th>Shards + HDCs</th>
      <th>Shards Only</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>Applicability</strong></td>
      <td>Real-time writes, offline data real-time computation, analytical processing</td>
      <td>Other requirements</td>
    </tr>
    <tr>
      <td rowspan="3"><strong>Scenario Examples</strong></td>
      <td>Supercomputing center</td>
      <td>Shallow graph queries</td>
    </tr>
    <tr>
      <td>Offline or near-real-time graph computation</td>
      <td>Graph warehouse, metadata reading/writing</td>
    </tr>
    <tr>
      <td>Index calculation, audit models</td>
      <td>General purpose database</td>
    </tr>
     <tr>
      <td><strong>Summary</strong></td>
      <td>The HDC computation servers address the performance bottlenecks associated with low-memory shard architecture, enabling more efficient handling of massive data computation. It is designed for high-efficiency AP calculations and offline data processing, effectively meeting the distributed compuation demands of large graphs.</td>
      <td>Although mainly dependent on disk and network I/O, the architecture can still handle complex multi-layer queries and distributed aggregation tasks with high efficiency. It can serve as a general purpose database for developing applications such as websites and apps.</td>
    </tr>
  </tbody>
</table>

<span style="color:#999;"><i>* Name severs and meta servers are compulsory in the deployment.</i></span>

To speak to an Ultipa expert, send us a message at <a href="mailto:support@ultipa.com">support@ultipa.com</a>.
