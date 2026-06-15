# Running Algorithms

Ultipa graph algorithms can be executed using both GQL and UQL via Ultipa Manager, Ultipa CLI, or by integrating Ultipa Drivers into your applications. Drivers are available for Java, Python, Go, Node.js, and C#.

## Algorithm Results

The results of an algorithm's execution include a primary result and optionally a statistical summary.

- **Primary result** delivers the algorithm’s core outputs, such as node rankings, pairwise similarities, or calculated metrics.
- **Statistical summary**, when available, offers aggregated insights, including averages, sums, or distribution details, to support further analysis of the primary results.

## Execution Modes

Algorithms can be executed in one of the six execution modes: **File Writeback**, **DB Writeback**, **Stats Writeback**, **Full Return**, **Stream Return**, and **Stats Return**. 

An algorithm may support one or more of these execution methods. For details, refer to the individual algorithm page.

Overall, the HDC and distributed algorithm versions differ in their support for these execution modes:

| Execution Mode | HDC Algorithm | Distributed Algorithm |
| -- | -- | -- |
| **File Writeback** | Yes | Yes |
| **DB Writeback** | Yes | Yes |
| **Stats Writeback** | Yes | / |
| **Full Return** | Yes | / |
| **Stream Return** | Yes | / |
| **Stats Return** | Yes | / |

We will introduce each execution mode below, along with their syntax. Note that regardless of whether an algorithm runs on an HDC graph or a distributed projection, the syntax remains the same.

### File Writeback

In this mode, the algorithm runs as a job, writing its primary result to one or more files and, when available, saving the statistical summary to the job for later access. This is useful for handling large outputs that don't need to be returned directly to the client, especially when offline storage or later processing is required.

<div tab="code">

<p tit="GQL Syntax"></p>

```gql
CALL algo.<algoName>.write("<hdcGraphName_or_projName>", {
  <param>: <value>,
  ...
}, {
  file: {
    filename: "<fileName>"
  }
})
```

<p tit="UQL Syntax"></p>

```uql
algo(<algoName>).params({
  projection: "<hdcGraphName_or_projName>",
  <param>: <value>,
  ...
}).write({
  file: {
    filename: "<fileName>"
  }
})
```

</div>

**Details**

- You can specify the file extension (like `.csv` or `.txt`) in `<fiileName>` or leave it unspecified, in which case the system may use a default or a generic format.

### DB Writeback

In this mode, the algorithm runs as a job, writing certain columns from its primary result directly to designated node properties within the database for permanent storage and, when available, saving the statistical summary to the job. This allows data to be readily accessible for future queries or analyses.

<div tab="code">

<p tit="GQL Syntax"></p>

```gql
CALL algo.<algoName>.write("<hdcGraphName_or_projName>", {
  <param>: <value>,
  ...
}, {
  db: {
    property: "<propertyName>"
  }
})
```

<p tit="UQL Syntax"></p>

```uql
algo(<algoName>).params({
  projection: "<hdcGraphName_or_projName>",
  <param>: <value>,
  ...
}).write({
  db: {
    property: "<propertyName>"
  }
})
```

</div>

**Details**

- The system creates the specified property for all labels (schemas) if it does not already exist. 
- If the property exists with the right type, its values will be overwritten. If the type is incorrect, the DB writeback fails.
- For nodes with algorithm results, those values are stored in the properties; nodes without results receive a default, such as 0 or an empty string, depending on the result type.

### Stats Writeback

In this mode, the algorithm runs as a job. The statistical summary from the execution are saved along with the job.

<div tab="code">

<p tit="GQL Syntax"></p>

```gql
CALL algo.<algoName>.write("<hdcGraphName>", {
  <param>: <value>,
  ...
}, {
  stats: {}
})
```

<p tit="UQL Syntax"></p>

```uql
algo(<algoName>).params({
  projection: "<hdcGraphName>",
  <param>: <value>,
  ...
}).write({
  stats: {}
})
```

</div>

### Full Return

In this mode, the algorithm runs as a real-time process. The algorithm completes execution and then returns the full primary result in a single response to the client.

<div tab="code">

<p tit="GQL Syntax"></p>

```gql
CALL algo.<algoName>.run("<hdcGraphName>", {
  <param>: <value>,
  ...
}) YIELD <resultsAlias>
RETURN <resultsAlias>
```

<p tit="UQL Syntax"></p>

```uql
exec{
  algo(<algoName>).params({
    <param>: <value>,
    ...
  }) as <resultsAlias>
  return <resultsAlias>
} on <hdcGraphName>
```

</div>

### Stream Return

In this mode, the algorithm runs as a real-time process. The primary result is streamed progressively to the client as they are generated. This mode optimizes resource usage and provides faster access to results, beneficial for applications needing immediate feedback.
 
<div tab="code">

<p tit="GQL Syntax"></p>

```gql
CALL algo.<algoName>.stream("<hdcGraphName>", {
  <param>: <value>,
  ...
}) YIELD <resultsAlias>
RETURN <resultsAlias>
```

<p tit="UQL Syntax"></p>

```uql
exec{
  algo(<algoName>).params({
    <param>: <value>,
    ...
  }).stream() as <resultsAlias>
  return <resultsAlias>
} on <hdcGraphName>
```
 
</div>

### Stats Return

In this mode, the algorithm runs as a real-time process. After execution completes, it returns the statistical summary to the client.

<div tab="code">

<p tit="GQL Syntax"></p>

```gql
CALL algo.<algoName>.stats("<hdcGraphName>", {
  <param>: <value>,
  ...
}) YIELD <statsAlias>
RETURN <statsAlias>
```

<p tit="UQL Syntax"></p>

```uql
exec{
  algo(<algoName>).params({
    <param>: <value>,
    ...
  }).stats() as <statsAlias>
  return <statsAlias>
} on <hdcGraphName>
```

</div>
