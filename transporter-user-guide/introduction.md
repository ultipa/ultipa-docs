# Introduction

**Ultipa Transporter** is a cross-platform (Windows/Mac/Linux) command-line tool designed for importing and exporting data to and from Ultipa graph database. It enables efficient data integration by supporting various data sources and formats.

## Prerequisites

- A command line terminal:
	- **Linux or MacOS:** <a target="_blank" href="https://www.gnu.org/software/bash">Bash</a>, <a target="_blank" href="https://www.zsh.org">Zsh</a>, <a target="_blank" href="https://www.tcsh.org">TCSH</a>
	- **Windows:** <a target="_blank" href="https://learn.microsoft.com/en-us/powershell">PowerShell</a>
- Download Ultipa Transporter <a target="_blank" href="/download">here</a>. No installation is required.

**Ultipa Transporter** provides two tools: **Importer** and **Exporter**.

## Importer

With the **Importer**, you can create graphs, schemas and properties in Ultipa and import data into graphs.

The Importer supports the following data sources:

#### Files

<div style="display:flex; column-gap:2%; flex-wrap:wrap;">
  <a style="display:flex; background:#fafafd; border:1px solid #ebeef0; width:48%; box-sizing:border-box; border-radius:8px; margin-bottom:2%; align-items:center; color:#000; text-decoration:none; font-weight:400;" href="/docs/transporter-user-guide/import-from-csv">
    <img style="width:15%; margin:0; max-width:50px; padding:15px;" src="https://img.ultipa.cn/img/2025-01-14-12-28-55-csv.png">
    <p style="margin:0; padding-right:20px;">CSV</p>
  </a>
  <a style="display:flex; background:#fafafd; border:1px solid #ebeef0; width:48%; box-sizing:border-box; border-radius:8px; margin-bottom:2%; align-items:center;color:#000; text-decoration:none; font-weight:400;" href="/docs/transporter-user-guide/import-from-json">
    <img style="width:15%; margin:0; max-width:50px; padding:15px;" src="https://img.ultipa.cn/img/2025-01-14-12-27-48-json.png">
    <p style="margin:0; padding-right:20px;">JSON</p>
  </a>
  <a style="display:flex; background:#fafafd; border:1px solid #ebeef0; width:48%; box-sizing:border-box; border-radius:8px; margin-bottom:2%; align-items:center;color:#000; text-decoration:none; font-weight:400;" href="/docs/transporter-user-guide/import-from-jsonl">
    <img style="width:15%; margin:0; max-width:50px; padding:15px;" src="https://img.ultipa.cn/img/2025-01-14-14-13-17-jsonl.png">
    <p style="margin:0; padding-right:20px;">JSONL</p>
  </a>
</div>

#### Relational Databases

<div style="display:flex; column-gap:2%; flex-wrap:wrap;">
  <a style="display:flex; background:#fafafd; border:1px solid #ebeef0; width:48%; box-sizing:border-box; border-radius:8px; margin-bottom:2%; align-items:center;color:#000; text-decoration:none; font-weight:400;" href="/docs/transporter-user-guide/import-from-relational-databases">
    <img style="width:15%; margin:0; max-width:50px; padding:15px;" src="https://img.ultipa.cn/img/2025-01-14-14-02-29-mysql.png">
    <p style="margin:0; padding-right:20px;">MySQL</p>
  </a>
  <a style="display:flex; background:#fafafd; border:1px solid #ebeef0; width:48%; box-sizing:border-box; border-radius:8px; margin-bottom:2%; align-items:center;color:#000; text-decoration:none; font-weight:400;" href="/docs/transporter-user-guide/import-from-relational-databases">
    <img style="width:15%; margin:0; max-width:50px; padding:15px;" src="https://img.ultipa.cn/img/2025-01-14-14-09-49-PostgreSQL.png">
    <p style="margin:0; padding-right:20px;">PostgreSQL</p>
  </a>
  <a style="display:flex; background:#fafafd; border:1px solid #ebeef0; width:48%; box-sizing:border-box; border-radius:8px; margin-bottom:2%; align-items:center;color:#000; text-decoration:none; font-weight:400;" href="/docs/transporter-user-guide/import-from-relational-databases">
    <img style="width:15%; margin:0; max-width:50px; padding:15px;" src="https://img.ultipa.cn/img/2025-01-14-14-09-52-sql-server.png">
    <p style="margin:0; padding-right:20px;">SQL Server</p>
  </a>
  <a style="display:flex; background:#fafafd; border:1px solid #ebeef0; width:48%; box-sizing:border-box; border-radius:8px; margin-bottom:2%; align-items:center;color:#000; text-decoration:none; font-weight:400;" href="/docs/transporter-user-guide/import-from-relational-databases">
    <img style="width:15%; margin:0; max-width:50px; padding:15px;" src="https://img.ultipa.cn/img/2025-01-15-12-14-23-oracle.png">
    <p style="margin:0; padding-right:20px;">Oracle</p>
  </a>
  <a style="display:flex; background:#fafafd; border:1px solid #ebeef0; width:48%; box-sizing:border-box; border-radius:8px; margin-bottom:2%; align-items:center;color:#000; text-decoration:none; font-weight:400;" href="/docs/transporter-user-guide/import-from-relational-databases">
    <img style="width:15%; margin:0; max-width:50px; padding:15px;" src="https://img.ultipa.cn/img/2025-01-15-11-55-47-snowflake.png">
    <p style="margin:0; padding-right:20px;">snowflake</p>
  </a>
</div>

#### Graph Platforms

<div style="display:flex; column-gap:2%; flex-wrap:wrap;">
  <a style="display:flex; background:#fafafd; border:1px solid #ebeef0; width:48%; box-sizing:border-box; border-radius:8px; margin-bottom:2%; align-items:center;color:#000; text-decoration:none; font-weight:400;" href="/docs/transporter-user-guide/import-from-neo4j">
    <img style="width:15%; margin:0; max-width:50px; padding:15px;" src="https://img.ultipa.cn/img/2025-01-14-14-17-30-neo4j.png">
    <p style="margin:0; padding-right:20px;">Neo4j</p>
  </a>
  <a style="display:flex; background:#fafafd; border:1px solid #ebeef0; width:48%; box-sizing:border-box; border-radius:8px; margin-bottom:2%; align-items:center;color:#000; text-decoration:none; font-weight:400;" href="/docs/transporter-user-guide/import-from-graphml">
    <img style="width:15%; margin:0; max-width:50px; padding:15px;" src="https://img.ultipa.cn/img/2025-01-14-14-20-05-graphml.png">
    <p style="margin:0; padding-right:20px;">GraphML</p>
  </a>
  <a style="display:flex; background:#fafafd; border:1px solid #ebeef0; width:48%; box-sizing:border-box; border-radius:8px; margin-bottom:2%; align-items:center;color:#000; text-decoration:none; font-weight:400;" href="/docs/transporter-user-guide/import-from-rdf">
    <img style="width:15%; margin:0; max-width:50px; padding:15px;" src="https://img.ultipa.cn/img/2025-01-14-14-21-11-rdf.png">
    <p style="margin:0; padding-right:20px;">RDF</p>
  </a>
</div>

#### Others

<div style="display:flex; column-gap:2%; flex-wrap:wrap;">
  <a style="display:flex; background:#fafafd; border:1px solid #ebeef0; width:48%; box-sizing:border-box; border-radius:8px; margin-bottom:2%; align-items:center;color:#000; text-decoration:none; font-weight:400;" href="/docs/transporter-user-guide/import-from-bigquery">
    <img style="width:15%; margin:0; max-width:50px; padding:15px;" src="https://img.ultipa.cn/img/2025-01-14-14-51-49-bigquery.png">
    <p style="margin:0; padding-right:20px;">BigQuery</p>
  </a>
  <a style="display:flex; background:#fafafd; border:1px solid #ebeef0; width:48%; box-sizing:border-box; border-radius:8px; margin-bottom:2%; align-items:center;color:#000; text-decoration:none; font-weight:400;" href="/docs/transporter-user-guide/import-from-kafka">
    <img style="width:15%; margin:0; max-width:50px; padding:15px;" src="https://img.ultipa.cn/img/2025-01-14-14-51-46-Kafka.png">
    <p style="margin:0; padding-right:20px;">Kafka</p>
  </a>
  <a style="display:flex; background:#fafafd; border:1px solid #ebeef0; width:48%; box-sizing:border-box; border-radius:8px; margin-bottom:2%; align-items:center;color:#000; text-decoration:none; font-weight:400;" href="/docs/transporter-user-guide/import-from-salesforce">
    <img style="width:15%; margin:0; max-width:50px; padding:15px;" src="https://img.ultipa.cn/img/2025-01-15-12-15-59-salesforce.png">
    <p style="margin:0; padding-right:20px;">Salesforce</p>
  </a>
</div>

## Exporter

With the **Exporter**, you can export entire or partial graphs from Ultipa.

The Exporter supports the following data sources:

#### Files

<div style="display:flex; column-gap:2%; flex-wrap:wrap;">
  <a style="display:flex; background:#fafafd; border:1px solid #ebeef0; width:48%; box-sizing:border-box; border-radius:8px; margin-bottom:2%; align-items:center;color:#000; text-decoration:none; font-weight:400;" href="/docs/transporter-user-guide/export-to-csv">
    <img style="width:15%; margin:0; max-width:50px; padding:15px;" src="https://img.ultipa.cn/img/2025-01-14-12-28-55-csv.png">
    <p style="margin:0; padding-right:20px;">CSV</p>
  </a>
  <a style="display:flex; background:#fafafd; border:1px solid #ebeef0; width:48%; box-sizing:border-box; border-radius:8px; margin-bottom:2%; align-items:center;color:#000; text-decoration:none; font-weight:400;" href="/docs/transporter-user-guide/export-to-json">
    <img style="width:15%; margin:0; max-width:50px; padding:15px;" src="https://img.ultipa.cn/img/2025-01-14-12-27-48-json.png">
    <p style="margin:0; padding-right:20px;">JSON</p>
  </a>
  <a style="display:flex; background:#fafafd; border:1px solid #ebeef0; width:48%; box-sizing:border-box; border-radius:8px; margin-bottom:2%; align-items:center;color:#000; text-decoration:none; font-weight:400;" href="/docs/transporter-user-guide/export-to-jsonl">
    <img style="width:15%; margin:0; max-width:50px; padding:15px;" src="https://img.ultipa.cn/img/2025-01-14-14-13-17-jsonl.png">
    <p style="margin:0; padding-right:20px;">JSONL</p>
  </a>
</div>

#### Graph Platforms

<div style="display:flex; column-gap:2%; flex-wrap:wrap;">
  <a style="display:flex; background:#fafafd; border:1px solid #ebeef0; width:48%; box-sizing:border-box; border-radius:8px; margin-bottom:2%; align-items:center;color:#000; text-decoration:none; font-weight:400;" href="/docs/transporter-user-guide/export-to-graphml">
    <img style="width:15%; margin:0; max-width:50px; padding:15px;" src="https://img.ultipa.cn/img/2025-01-14-14-20-05-graphml.png">
    <p style="margin:0; padding-right:20px;">GraphML</p>
  </a>
</div>
