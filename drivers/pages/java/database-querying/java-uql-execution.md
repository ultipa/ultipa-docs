# UQL Execution

This section introduces the `uql()` and `uqlStream()` methods on a `Connection` object for querying the database using UQL.

Each example focuses solely on the method's usage. For a complete code example, please refer to the <a href="#Full-Example">full example</a>.

> UQL (Ultipa Query Language) is the language designed for fully interacting with Ultipa graph databases. For detailed information on UQL, refer to the <a href="/docs/uql/">documentation</a>.

## uql()

Executes a UQL query on the current graphset or the database and returns the result.

**Parameters:**

- `String`: The UQL query to be executed.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit= "Java" ></p> 

```java
// Retrieves 5 @movie nodes in graphset 'miniCircle' and prints their names

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraphName("miniCircle");

Response response = client.uql("find().nodes({@movie}) as n return n{*} limit 5", requestConfig);
List<Node> nodeList = response.alias("n").asNodes();
for (Node node : nodeList) {
    System.out.println(node.get("name"));
}
```

<p tit= "Output" ></p> 

```java
The Shawshank Redemption
Farewell My Concubine
Léon: The Professional
Titanic
Life is Beautiful
```

For more examples, please refer to <a href="https://www.ultipa.com/doc/drivers/data-types-mapping-ultipa-and-java">Types Mapping Ultipa and Java</a>.

## uqlStream()

Executes a UQL query on the current graphset or the database and returns the result incrementally, allowing handling of large datasets without loading everything into memory at once.

**Parameters:**

- `String`: The UQL query to be executed.
- `UqlListener`: Listener for the streaming process.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `void`

<p tit= "Java" ></p> 

```java
// Retrieves all 1-step paths in graphset 'miniCircle'

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraphName("miniCircle");

client.uqlStream("n().e().n() as paths return paths{*}", new UqlListener() {
    int count = 0;

    public void onReady() {
        System.out.println("Start downloading");
    }

    public void next(Response response) {
        if (response.getStatus().getErrorCode() != Ultipa.ErrorCode.SUCCESS){
            System.out.println(response.getStatus().getMsg());
        }
        List<Path> paths = response.get(0).asPaths();
        count += paths.size();
        System.out.println("count = " + count);
    }

    public void onComplete() {
        System.out.println("Done");
        System.out.println("count = " + count);
    }

    public void onError(Throwable throwable) {
        System.out.println("Error");

    }
}, requestConfig);
```

<p tit= "Output" ></p> 

```java
count = 1250
count = 1392
Done
count = 1392
```

## Full Example

<p tit= "Main.java" ></p> 

```java
package com.ultipa.www.sdk.api;

import com.ultipa.sdk.connect.Connection;
import com.ultipa.sdk.connect.conf.RequestConfig;
import com.ultipa.sdk.connect.conf.UltipaConfiguration;
import com.ultipa.sdk.connect.driver.UltipaClientDriver;
import com.ultipa.sdk.operate.entity.*;
import com.ultipa.sdk.operate.response.Response;
import java.util.*;

public class Main {
    public static void main(String[] args) {
         // Connection configurations
        UltipaConfiguration myConfig = UltipaConfiguration.config()
            // URI example: .hosts("mqj4zouys.us-east-1.cloud.ultipa.com:60010")
            .hosts("192.168.1.85:60061,192.168.1.86:60061,192.168.1.87:60061")
            .username("<username>")
            .password("<password>");

        UltipaClientDriver driver = null;
        try {
            // Establishes connection to the database
            driver = new UltipaClientDriver(myConfig);
            Connection client = driver.getConnection();
          
            // Request configurations
            RequestConfig config = new RequestConfig();
            config.setGraphName("amz");
            
            // Retrieves 10 nodes and prints the _id and storeName property value of the first returned one
            Response response = client.uql("find().nodes() as n return n{*} limit 10", config);
            List<Node> nodeList = response.alias("n").asNodes();
            System.out.println("ID of the 1st node: " + nodeList.get(0).getID());
            System.out.println("Store name of the 1st node: " + nodeList.get(0).get("storeName"));
        } finally {
            if (driver != null) {
                driver.close();
            }
        }
    }
}
```
