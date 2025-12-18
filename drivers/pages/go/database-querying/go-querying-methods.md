# Querying Methods

Once the connection is established, you can send requests to query the database through various methods on the `Connection` object, categorized as follows:

<table>
  <tbody style="vertical-align: top;">
    <tr style="background-color: #edf2f8">
      <td colspan="2"><b><center>General Purpose Methods</b></center></td>
    </tr>
    <tr>
      <td colspan="2"><a href="https://www.ultipa.com/doc/drivers/go-uql-execution/"><b>UQL Execution</b></a><ul>
        <li>Uql()</li>
        <li>UqlStream()</li></ul></td>
    </tr>
    <tr style="background-color: #edf2f8">
      <td colspan="2"><b><center>Task Specific Methods<b></center></td>
    </tr>
    <tr>
      <td><a href="https://www.ultipa.com/doc/drivers/go-graphset-management"><b>Graphset Management</b></a><ul>
        <li>ShowGraph()</li>
        <li>GetGraph()</li>
        <li>CreateGraph()</li>
        <li>CreateGraphIfNotExist()</li>
        <li>DropGraph()</li>
        <li>AlterGraph()</li>
        <li>Truncate()</li>
        <li>Compact()</li>
        <li>HasGraph()</li>
        <li>UnmountGraph()</li>
        <li>MountGraph()</li></ul></td>
      <td><a href="https://www.ultipa.com/doc/drivers/go-schema-and-property-management"><b>Schema and Property Management</a></b><ul>
        <li>ShowSchema()</li>
        <li>GetSchema()</li>
        <li>ShowNodeSchema()</li>
        <li>ShowEdgeSchema()</li>
        <li>GetNodeSchema()</li>
        <li>GetEdgeSchema()</li>
        <li>CreateSchema()</li>
        <li>CreateSchemaIfNotExist()</li>
        <li>AlterSchema()</li>
        <li>DropSchema()</li>
        <li>ShowProperty()</li>
        <li>ShowNodeProperty()</li>
        <li>ShowEdgeProperty()</li>
        <li>GetProperty()</li>
        <li>GetNodeProperty()</li>
        <li>GetEdgeProperty()</li>
        <li>CreateProperty()</li>
        <li>CreatePropertyIfNotExist()</li>
        <li>AlterProperty()</li>
        <li>DropProperty()</li></ul></td>
    </tr>
    <tr>
      <td><a href="https://www.ultipa.com/doc/drivers/go-data-insertion-and-deletion"><b>Data Insertion and Deletion</a></b><ul>
        <li>InsertNodes()</li>
        <li>InsertEdges()</li>
        <li>InsertNodesBatchBySchema()</li>
        <li>InsertEdgesBatchBySchema()</li>
        <li>InsertNodesBatchAuto()</li>
        <li>InsertEdgesBatchAuto()</li>
        <li>DeleteNodes()</li>
        <li>DeleteEdges()</li></ul></td>
      <td><a href="https://www.ultipa.com/doc/drivers/go-query-acceleration"><b>Query Acceleration</a></b><ul>
        <li>Lte()</li>
        <li>Ufe()</li>
        <li>ShowIndex()</li>
        <li>ShowNodeIndex()</li>
        <li>ShowEdgeIndex()</li>
        <li>CreateIndex()</li>
        <li>DropIndex()</li>
        <li>ShowFullText()</li>
        <li>ShowNodeFullText()</li>
        <li>ShowEdgeFullText()</li>
        <li>CreateFullText()</li>
        <li>DropFullText()</li></ul></td>
    </tr>
    <tr>
      <td><a href="https://www.ultipa.com/doc/drivers/go-algorithm-management"><b>Algorithm Management</a></b><ul>
        <li>ShowAlgo()</li>
        <li>InstallAlgo()</li>
        <li>UninstallAlgo()</li>
        <li>ShowExta()</li>
        <li>InstallExta()</li>
        <li>UninstallExta()</li></ul></td>
      <td><a href="https://www.ultipa.com/doc/drivers/go-downloads-and-exports"><b>Downloads and Exports</a></b><ul>
        <li>DownloadAlgoResultFile()</li>
        <li>DownloadAllAlgoResultFile()</li>
        <li>Export()</li></ul></td>
    </tr>
    <tr>
      <td><a href="https://www.ultipa.com/doc/drivers/go-process-and-task-management"><b>Process and Task Management</a></b><ul>
        <li>Top()</li>
        <li>Kill()</li>
        <li>ShowTask()</li>
        <li>ClearTask()</li>
        <li>StopTask()</li></ul></td>
      <td><a href="https://www.ultipa.com/doc/drivers/go-access-management"><b>Access Management</a></b><ul>
        <li>ShowPrivilege()</li>
        <li>ShowPolicy()</li>
        <li>GetPolicy()</li>
        <li>CreatePolicy()</li>
        <li>AlterPolicy()</li>
        <li>DropPolicy()</li>
        <li>ShowUser()</li>
        <li>GetUser()</li>
        <li>CreateUser()</li>
        <li>AlterUser()</li>
        <li>DropUser()</li>
        <li>GrantPolicy()</li>
        <li>RevokePolicy()</li></ul></td>
    </tr>
    <tr>
      <td><a href="https://www.ultipa.com/doc/drivers/go-others"><b>Others</a></b><ul>
        <li>Stats()</li>
        <li>Test()</li></ul></td>
      <td></td>
    </tr>
  </tbody>
</table>

The task specific methods eliminate the need to explicitly write UQL. The following two examples use the `Uql()` and `ShowNodeProperty()` methods respectively to retrieve the `club-member` node schema and print its associated properties. Notice that the latter is easier to write and returns the result as a list of `Property` directly. While with `Uql()`, you need to extract the data from `Response` and cast it into `Property`.

<p tit="Go"></p> 

```go
// Uses the Uql() method
myTest, err := conn.Uql("show().node_schema(@`club-member`)", requestConfig)
if err != nil {
  println(err)
}

nodeInfo, err1 := myTest.Alias("_nodeSchema").AsSchemas()
if err != nil {
  println(err1)
}
printers.PrintSchema(nodeInfo)

// Uses the ShowNodeProperty() method
nodeSimp, err2 := conn.ShowNodeProperty("club-member", requestConfig)
if err != nil {
  println(err2)
}
if nodeSimp != nil {
  for _, item := range nodeSimp {
    println(item.Name)
  }
}
```

However, the `Uql()` method serves all querying purposes and can be utilized when the task specific methods are not privided, such as for node, edge or path queries.

Lastly, if you are retrieving a large amount of data from the database, it is recommended to use the <a href="https://www.ultipa.com/doc/drivers/go-uql-execution#uqlStream()">the `UqlStream()` method</a> to processes the result set incrementally.
