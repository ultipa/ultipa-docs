## UQL Execution

This section introduces the `uql()` and `uqlStream()` methods to execute UQL in the database.

> UQL (Ultipa Query Language) is the native language designed by Ultipa to fully interact with Ultipa graph databases. For detailed information on UQL, refer to the <a target="_blank" href="/docs/uql">documentation</a>.

## uql()

Executes an UQL query in the database.

**Parameters**

- `uql: String`: The UQL query to be executed.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```java
// Retrieves 5 movie nodes from the graph 'miniCircle'

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("miniCircle");

Response response = driver.uql("find().nodes({@movie}) as n return n{*} limit 5", requestConfig);
List<Node> nodeList = response.alias("n").asNodes();
for (Node node : nodeList) {
    System.out.println(node.get("name"));
}
```

<p tit="Output"></p> 

```
The Shawshank Redemption
Farewell My Concubine
Léon: The Professional
Titanic
Life is Beautiful
```

## uqlStream()

Executes an UQL query in the database and returns the results incrementally, allowing handling of large datasets without loading everything into memory at once.

**Parameters**

- `uql: String`: The UQL query to be executed.
- `cb: QueryResponseListener`: Listener for the streaming process.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `None`

```java
// Retrieves all 1-step paths from the graph 'miniCircle'

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("miniCircle");

driver.uqlStream("n().e().n() as paths return paths{*}", new QueryResponseListener() {
    int count = 0;

    public void onReady() {
    	System.out.println("Start downloading");
    }

    public void next(Response response) {
    	if (response.getStatus().getCode() != Ultipa.ErrorCode.SUCCESS){
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

<p tit="Output"></p> 

```
count = 1024
count = 2048
count = 3072
count = 3220
count = 3621
count = 3849
Done
count = 3849
```

## Full Example

<p tit="Main.java"></p> 

```java
package com.ultipa.www.sdk.api;

import com.ultipa.sdk.UltipaDriver;
import com.ultipa.sdk.connect.conf.RequestConfig;
import com.ultipa.sdk.connect.conf.UltipaConfig;
import com.ultipa.sdk.operate.entity.Node;
import com.ultipa.sdk.operate.response.Response;
import org.assertj.core.util.Lists;

import java.util.List;

public class Main {
    public static void main(String[] args) {
        UltipaConfig ultipaConfig = UltipaConfig.config()
                // URI example: .hosts(Lists.newArrayList("d3026ac361964633986849ec43b84877s.eu-south-1.cloud.ultipa.com:8443"))
                .hosts(Lists.newArrayList("192.168.1.85:60061","192.168.1.88:60061","192.168.1.87:60061"))
                .username("<username>")
                .password("<password>");

        UltipaDriver driver = null;

        try {
            driver = new UltipaDriver(ultipaConfig);

            // Retrieves 5 movie nodes from the graph 'miniCircle'

            RequestConfig requestConfig = new RequestConfig();
            requestConfig.setGraph("miniCircle");

            Response response = driver.uql("find().nodes({@movie}) as n return n{*} limit 5", requestConfig);
            List<Node> nodeList = response.alias("n").asNodes();
            for (Node node : nodeList) {
                System.out.println(node.get("name"));
            }
        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        } finally {
            if (driver != null) {
                driver.close();
            }
        }
    }
}
```
