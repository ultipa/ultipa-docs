# Introduction

## What is UQL

**Ultipa Graph Query Language**, or **UQL**, is a high-performance query and management language exclusive to Ultipa Graph Database and Graph Computing Engine.

UQL supports the insertion, deletion, and updating of metadata, querying of graph data (metadata, paths, and subgraphs), management of graphset, schema, property, index, process and task, user, privilege and policy, and other features within the Ultipa Graph system.

UQL can be invoked via **Ultipa CLI** (Command Line Tool), **Ultipa Manager** (a highly visualized graph database query and management interface), **Ultipa Drivers** (Ultipa SDKs and APIs), and the <a target=blank href="https://youtu.be/97lxSg_fsuc?si=fW67u6UurgNw6f6u">Visual Studio Code</a>.

## How UQL Operates 

When a formatted UQL statement is sent to the Ultipa server, it undergoes parsing and optimization before being assigned to the high-performance graph computing engine for execution. The query result is then processed, assembled, and ultimately returned to the user.

<div align=center drawio-diagram='13934' drawio-name='draw_b79ac09b0eb541c9b3d6b93fca144921.jpg'><img src="https://img.ultipa.cn/draw/draw_b79ac09b0eb541c9b3d6b93fca144921.jpg?v='1702980883235'"/></div>

## How UQL is Designed

The design of UQL is rooted in a profound comprehension of graphs and the industry's requirements for scalable graph systems. It embraces a semantic assembly logic that mirrors the cognitive processes of the human brain, making it easy to read, write, and learn. 

> **UQL vs. SQL**<br>UQL naturally addresses SQL's limitations in expressing high-dimensional data and its combinations, as well as the complexity and inefficiency in path filtering. It also tackles the challenges associated with understanding and maintaining code.

Like most database languages, UQL encompasses features for DQL, DDL, DML and DCL:

- **DQL** (Data Query Language): Retrieve data such as nodes, edges, paths and subgraphs from the graph database.
- **DDL** (Data Definition Language): Define graph structure (schema and properties), create indexes, etc.
- **DML** (Data Manipulation Language): Add, modify, and delete data and other content within the graphset.
- **DCL** (Data Control Language): Manage access to the database and its objects, granting or revoking permissions to users for specific operations.

As a graph query language, UQL aligns with the **GQL** international standard in terms of overall functionality and compatibility. The development of the GQL standard is spearheaded by LDBC (Linked Data Benchmark Council) and is expected to be released in 2024.

> Ultipa is a member of LDBC and has been actively involved in the development of the GQL standard.

## UQL Components

This is an example of a UQL statement:

<b><span style="color:green">n(</span><span style="color:black">{_id == "CA001"}</span><span style="color:green">).e(</span><span style="color:black">{time > prev_e.time}</span><span style="color:green">)[3].n(</span><span style="color:red">as </span><span style="color:black">target</span><span style="color:green">)</span><br><span style="color:orange">group by </span><span style="color:black">target.level<br></span><span style="color:orange">with </span><span style="color:blue">count(</span><span style="color:black">target</span><span style="color:blue">) </span><span style="color:red">as </span><span style="color:black">quantity </span><br><span style="color:orange">order by </span><span style="color:black">quantity </span><span style="color:magenta">desc </span><br><span style="color:orange">return </span><span style="color:black">target.level, quantity </span> <span style="color:orange">limit </span><span style="color:black">10</span></b>

Which contains,

- <b>Chained Clause: </b> It follows the style of `[command].[method].[method]...`, such as <span style="color:green"><b> n(</b></span><span style="color:black"><b>...</b></span><span style="color:green"><b>).e(</b></span><span style="color:black"><b>...</b></span><span style="color:green"><b>)[3].n(</b></span><span style="color:black"><b>...</b></span><span style="color:green"><b>)</b></span>. This clause is commonly used for retrieving data from the graph or executing insertion, update or deletion. 
- <b>Keyword Clause:</b> It begins with a keyword like <span style="color:orange"><b>group by</b></span>, <span style="color:orange"><b>with</b></span>, <span style="color:orange"><b>order by</b></span>, <span style="color:orange"><b>return</b></span> and <span style="color:orange"><b>limit</b></span>. This clause is used to process, assemble or return the results.
- <b>Custom Alias: </b>Defined with the keyword <font color=red><b>as</b></font>, as seen in the example with <b>target</b> and <b>quantity</b>. These aliases are used to store and transfer temporary results between clauses.
- <b>System Alias: </b>Used without definition, as demonstrated with <b>prev_e</b> in the example. These aliases can store and transfer temporary results within a clause.
- <b>Function: </b> Used to perform various calculations on the temporary results. A function should be applied within a clause, as illustrated by <span style="color:blue"><b>count(</b></span><span style="color:black"><b>...</b></span><span style="color:blue"><b>)</b></span> in the example. 

> UQL supports escape character `\`, tab `\t`, carriage return line feed `\r\n`, and comment delimiters `//`, `/*` and `*/`.

## Change Log (v4.3 → v4.4)

### Server Updates

- Optimized in-memory storage, reducing data memory usage by up to 33%

### New Features

- Introduced a new graph data type GRAPH.
- Added new aggregation functions `percentileCont()` and `percentileDisc()`.
- Added new type conversion function `toGraph()`.
- Added new SET clause.

### Modifications

- Renamed the query command `graph()` to `subgraph()`

The UQL (Ultipa Query Language) is created and designed by Ultipa Team.

Documentation license: <a href="https://creativecommons.org/licenses/by-nc-sa/4.0/" target="blank">Creative Commons 4.0</a>
