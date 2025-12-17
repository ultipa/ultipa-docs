# Querying Methods

Once the connection is established, you can send requests to query the database through various methods on the `Connection` object, categorized as follows:

<table>
  <tbody style="vertical-align: top;">
    <tr style="background-color: #edf2f8">
      <td colspan="2"><b><center>General Purpose Methods</b></center></td>
    </tr>
    <tr>
      <td colspan="2"><a href="https://www.ultipa.com/doc/drivers/java-uql-execution"><b>UQL Execution</b></a><ul>
        <li>uql()</li>
        <li>uqlStream()</li></ul></td>
    </tr>
    <tr style="background-color: #edf2f8">
      <td colspan="2"><b><center>Task Specific Methods<b></center></td>
    </tr>
    <tr>
      <td><a href="https://www.ultipa.com/doc/drivers/java-graphset-management"><b>Graphset Management</b></a><ul>
        <li>showGraph()</li>
        <li>getGraph()</li>
        <li>createGraph()</li>
        <li>createGraphIfNotExist()</li>
        <li>dropGraph()</li>
        <li>alterGraph()</li>
        <li>truncate()</li>
        <li>compact()</li>
        <li>hasGraph()</li>
        <li>unmountGraph()</li>
        <li>mountGraph()</li></ul></td>
      <td><a href="https://www.ultipa.com/doc/drivers/java-schema-and-property-management"><b>Schema and Property Management</a></b><ul>
        <li>showSchema()</li>
        <li>getSchema()</li>
        <li>showNodeSchema()</li>
        <li>showEdgeSchema()</li>
        <li>getNodeSchema()</li>
        <li>getEdgeSchema()</li>
        <li>createSchema()</li>
        <li>createSchemaIfNotExist()</li>
        <li>alterSchema()</li>
        <li>dropSchema()</li>
        <li>showProperty()</li>
        <li>showNodeProperty()</li>
        <li>showEdgeProperty()</li>
        <li>getProperty()</li>
        <li>getNodeProperty()</li>
        <li>getEdgeProperty()</li>
        <li>createProperty()</li>
        <li>createPropertyIfNotExist()</li>
        <li>alterProperty()</li>
        <li>dropProperty()</li></ul></td>
    </tr>
    <tr>
      <td><a href="https://www.ultipa.com/doc/drivers/java-data-insertion-and-deletion"><b>Data Insertion and Deletion</a></b><ul>
        <li>insertNodes()</li>
        <li>insertEdges()</li>
        <li>insertNodesBatchBySchema()</li>
        <li>insertEdgesBatchBySchema()</li>
        <li>insertNodesBatchAuto()</li>
        <li>insertEdgesBatchAuto()</li>
        <li>deleteNodes()</li>
        <li>deleteEdges()</li></ul></td>
      <td><a href="https://www.ultipa.com/doc/drivers/java-query-acceleration"><b>Query Acceleration</a></b><ul>
        <li>lte()</li>
        <li>ufe()</li>
        <li>showIndex()</li>
        <li>showNodeIndex()</li>
        <li>showEdgeIndex()</li>
        <li>createIndex()</li>
        <li>dropIndex()</li>
        <li>showFulltext()</li>
        <li>showNodeFulltext()</li>
        <li>showEdgeFulltext()</li>
        <li>createFulltext()</li>
        <li>dropFulltext()</li></ul></td>
    </tr>
    <tr>
      <td><a href="https://www.ultipa.com/doc/drivers/java-algorithm-management"><b>Algorithm Management</a></b><ul>
        <li>showAlgo()</li>
        <li>installAlgo()</li>
        <li>uninstallAlgo()</li>
        <li>showExta()</li>
        <li>installExta()</li>
        <li>uninstallExta()</li></ul></td>
      <td><a href="https://www.ultipa.com/doc/drivers/java-downloads-and-exports/"><b>Downloads and Exports</a></b><ul>
        <li>downloadAlgoResultFile()</li>
        <li>downloadAllAlgoResultFile()</li>
        <li>export()</li></ul></td>
    </tr>
    <tr>
      <td><a href="https://www.ultipa.com/doc/drivers/java-process-and-task-management"><b>Process and Task Management</a></b><ul>
        <li>top()</li>
        <li>kill()</li>
        <li>showTask()</li>
        <li>clearTask()</li>
        <li>stopTask()</li></ul></td>
      <td><a href="https://www.ultipa.com/doc/drivers/java-access-management"><b>Access Management</a></b><ul>
        <li>showPrivilege()</li>
        <li>showPolicy()</li>
        <li>getPolicy()</li>
        <li>createPolicy()</li>
        <li>alterPolicy()</li>
        <li>dropPolicy()</li>
        <li>showUser()</li>
        <li>getUser()</li>
        <li>createUser()</li>
        <li>alterUser()</li>
        <li>dropUser()</li>
        <li>grantPolicy()</li>
        <li>revokePolicy()</li></ul></td>
    </tr>
    <tr>
      <td><a href="https://www.ultipa.com/doc/drivers/java-others"><b>Others</a></b><ul>
        <li>stats()</li>
        <li>test()</li></ul></td>
      <td></td>
    </tr>
  </tbody>
</table>

The task specific methods eliminate the need to explicitly write UQL. The following two examples use the `uql()` and `getNodeSchema()` methods respectively to retrieve the `club-member` node schema and print its associated properties. Notice that the latter is easier to write and returns the result as a `Schema` directly. While with `uql()`, you need to extract the data from `Response` and cast it into `Schema`.

<p tit= "Java" ></p> 

```java
// Uses the uql() method
Response response = client.uql("show().node_schema(@`club-member`)");
List<Schema> schemas = response.get(0).asSchemas();
for (Schema schema : schemas) {
    System.out.println(schema.getProperties());
}

// Uses the getNodeSchema() method
Schema schema = client.getNodeSchema("club-member");
System.out.println(schema.getProperties());
```

However, the `uql()` method serves all querying purposes and can be utilized when the task specific methods are not privided, such as for node, edge or path queries.

Lastly, if you are retrieving a large amount of data from the database, it is recommended to use the <a href="https://www.ultipa.com/doc/drivers/java-uql-execution#uqlStream()">the `uqlStream()` method</a> to processes the result set incrementally.
