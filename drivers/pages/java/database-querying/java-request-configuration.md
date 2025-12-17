# Database Querying

## Request Configuration

All querying methods support an optional request configuration parameter (`RequestConfig` or `InsertRequestConfig`) to customize the behavior of requests made to the database. This parameter allows you to specify various settings, such as graphset name, timeout, and host, to tailor your requests according to your needs.

## RequestConfig

`RequestConfig` defines the settings needed when sending non-insert requests to the database.

<p tit= "Main.java" ></p> 

```java
public class Main {
    public static void main(String[] args) {
        UltipaConfiguration myConfig = UltipaConfiguration.config()
            // URI example: .hosts("mqj4zouys.us-east-1.cloud.ultipa.com:60010")
            .hosts("192.168.1.85:60061,192.168.1.86:60061,192.168.1.87:60061")
            .username("<username>")
            .password("<password>");

        UltipaClientDriver driver = null;
        try {
            driver = new UltipaClientDriver(myConfig);
            Connection client = driver.getConnection();

            // Specifies 'amz' as the target graphset and sets to use the leader node of the cluster 
            RequestConfig requestConfig = new RequestConfig();
            requestConfig.setGraphName("amz");
            requestConfig.setUseMaster(true);
        
            Response response = client.uql("find().nodes() as nodes return nodes{*} limit 10", requestConfig);
            List<Node> nodeList = response.alias("nodes").asNodes();
            for(int i = 0; i < nodeList.size(); i ++){
                System.out.println("node " + i + " is: " + nodeList.get(i).toJson());
            }
        } finally {
            if (driver != null) {
                driver.close();
            }
        }
    }
}
```

`RequestConfig` has the following fields:

| <div table-width="20">Field</div> | <div table-width="10">Type</div> | <div table-width="7">Default</div> | Description |
|  ----  | ----  | ----  | ---- |
| `graphName` | String | | Name of the graph to use, or the `defaultGraph` configured when establishing the connection if not set. |
| `timeout` | Integer | 15 | Timeout in seconds for the request, or the `timeout` configured when establishing the connection if not set. |
| `host` | String |  | Sends the request to a designated host node, or to a random host node if not set. |
| `useMaster` | Boolean | false | Sends the request to the leader node to guarantee consistency read if set to true. |
| `threadNum` | Integer |  | Number of threads. |

## InsertRequestConfig

`InsertRequestConfig` defines the settings needed when sending data insertion or deletion requests to the database.

<p tit= "Main.java" ></p> 
 
```java
public class Main {
    public static void main(String[] args) {
        UltipaConfiguration myConfig = UltipaConfiguration.config()
            // URI example: .hosts("mqj4zouys.us-east-1.cloud.ultipa.com:60010")
            .hosts("192.168.1.85:60061,192.168.1.86:60061,192.168.1.87:60061")
            .username("<username>")
            .password("<password>");

        UltipaClientDriver driver = null;
        Connection client;
        try {
            driver = new UltipaClientDriver(myConfig);
            client = driver.getConnection();

            // Specifies 'test' as the target graphset and sets the insert mode to OVERWRITE
            InsertRequestConfig insertRequestConfig = new InsertRequestConfig();
            insertRequestConfig.setGraphName("test");
            insertRequestConfig.setInsertType(Ultipa.InsertType.OVERWRITE);
        
            List<Node> nodeList = new ArrayList<>();
            Node node1 = new Node();
            node1.setSchema("client");
            node1.setID("CLIENT00001");
            nodeList.add(node1);
            Node node2 = new Node();
            node2.setSchema("card");
            node2.setID("CARD00004");
            nodeList.add(node2);
          
            client.insertNodesBatchAuto(nodeList, insertRequestConfig);
        } finally {
            if (driver != null) {
                driver.close();
            }
        }
    }
}
```

`InsertRequestConfig` has the following fields:

| <div table-width="20">Field</div> | <div table-width="10">Type</div> | <div table-width="7">Default</div> | Description |
|  ----  | ----  | ----  | ---- |
| `graphName` | String | | Name of the graph to use, or the `defaultGraph` configured when establishing the connection if not set. |
| `timeout` | Integer | 15 | Timeout in seconds for the request, or the `timeout` configured when establishing the connection if not set. |
| `host` | String |  | Sends the request to a designated host node, or to a random host node if not set. |
| `useMaster` | Boolean | false | Sends the request to the leader node to guarantee consistency read if set to true. |
| `insertType` | Ultipa.InsertType | `NORMAL` | Insert mode (`NORMAL`, `UPSERT`, `OVERWRITE`) |
| `silent` | Boolean | true | Whether to keep silent after success insertion, i.e., whether to return the inserted nodes or edges. |
| `createNodeIfNotExist` | Boolean | false | Whether to create start/end nodes of an edge if the end nodes do not exist in the graph. |
