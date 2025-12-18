# Others

This section introduces methods on a `Connection` object for checking the database server statistics and the driver connection.

Each example focuses solely on the method's usage. For a complete code example, please refer to the <a href="#Full-Example">full example</a>.

## stats()

Retrieves database server statistics.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Stats`: The retrieved server statistics.

<p tit="Java"></p>

```js
Stats stats = client.stats();
System.out.println("CPU usage: " + stats.getCpuUsage() + "%");
System.out.println("Memory usage: " + stats.getMemUsage() + "MB");
System.out.println("Expiration date: " + stats.getExpiredDate());
System.out.println("CPU cores: " + stats.getCpuCores());
System.out.println("Company: " + stats.getCompany());
System.out.println("Server type: " + stats.getServerType());
System.out.println("Version: " + stats.getVersion());
```

<p tit="Output"></p>

```js
CPU usage: 111.151108%
Memory usage: 10939.929688MB
Expiration date: Thu Dec 26 23:59:59 2024
CPU cores: 80
Company: ultipa
Server type: CT
Version: htap_beta.4.4.47-b4.4.0-tv-ui
```

## test()

Tests driver and database server connection.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit="Java"></p>

```js
Response response = client.test();
System.out.println(response.getStatus().getErrorCode());
```

<p tit="Output"></p>

```js
SUCCESS
```

## Full Example

<p tit="Main.java" ></p> 

```java
package com.ultipa.www.sdk.api;

import com.ultipa.sdk.connect.Connection;
import com.ultipa.sdk.connect.conf.RequestConfig;
import com.ultipa.sdk.connect.conf.UltipaConfiguration;
import com.ultipa.sdk.connect.driver.UltipaClientDriver;
import com.ultipa.sdk.operate.response.Response;

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
           config.setUseMaster(true);
           
           // Test connection
           Response response = client.test();
           System.out.println(response.getStatus().getErrorCode());
        } finally {
            if (driver != null) {
                driver.close();
            }
        }
    }
}
```