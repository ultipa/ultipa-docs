# Connection

After <a href="https://www.ultipa.com/doc/drivers/java-installation">installing the Ultipa Java SDK</a> and setting up a running Ultipa instance, you should be able to connect your application to the Ultipa graph database.

Connection to Ultipa can be established by creating a driver with configurations specified using either or both of the following methods:

- <a href="#Code-Configuration-Connection">Code Configuration Connection</a>: through the `UltipaConfiguration` class
- <a href="#File-Configuration-Connection">File Configuration Connection</a>: through the `ultipa.properties` file

The values of <a href="#Configuration-Items">configuration items</a> are preferentially determined by `UltipaConfiguration`, followed by `ultipa.properties`. If an item is not found in either configuration, the default value is used.

## Code Configuration Connection

<p tit="Main.java" ></p> 

```java
package com.ultipa.www.sdk.api;

import com.ultipa.sdk.connect.Connection;
import com.ultipa.sdk.connect.conf.UltipaConfiguration;
import com.ultipa.sdk.connect.driver.UltipaClientDriver;

public class Main {
    public static void main(String[] args) {
        UltipaConfiguration myConfig = UltipaConfiguration.config()
            // URI example: .hosts("mqj4zouys.us-east-1.cloud.ultipa.com:60010")
            .hosts("192.168.1.85:60061,192.168.1.86:60061,192.168.1.87:60061")
            .username("<username>")
            .password("<password>")
            .defaultGraph("default");

        UltipaClientDriver driver = null;
        try {
            driver = new UltipaClientDriver(myConfig);
            Connection client = driver.getConnection("amz");

            String reply = client.sayHello("Hi");
            System.out.println(reply);
        } finally {
            if (driver != null) {
                driver.close();
            }
        }
    }
}
```

<p tit="Output"></p> 

```java
Hi Welcome To Ultipa!
```

A driver is created with the configurations specified using `UltipaConfiguration`. Please refer to <a href="#Configuration-Items">Configuration Items</a> for all items available for configuring connection details with `UltipaConfiguration`.

The `getConnection()` method obtains a connection to Ultipa, allowing you to optionally specify a graphset as the current graphset (in this case, `amz`). If no graph is specified, the graphset identified by the configuration item `defaultGraph` will be used.

## File Configuration Connection

<p tit="Main.java" ></p> 

```java
package com.ultipa.www.sdk.api;

import com.ultipa.sdk.connect.Connection;
import com.ultipa.sdk.connect.conf.UltipaConfiguration;
import com.ultipa.sdk.connect.driver.UltipaClientDriver;

public class Main {
    public static void main(String[] args) {
        UltipaClientDriver driver = null;
        try {
            driver = new UltipaClientDriver();
            Connection client = driver.getConnection();

            String reply = client.sayHello("Hi");
            System.out.println(reply);
        } finally {
            if (driver != null) {
                driver.close();
            }
        }
    }
}
```

A driver is created with the configurations specified using the `ultipa.properties` file. The `ultipa.properties` file should be placed under the `classpath` of Java project, which is by default `./src/main/resources`.

Example of the `ultipa.properties` file:

<p tit="ultipa.properties" ></p> 

```properties
ultipa.hosts=192.168.1.85:60061,192.168.1.86:60061,192.168.1.87:60061
#ultipa.hosts=mqj4zouys.us-east-1.cloud.ultipa.com:60010
ultipa.username=<username>
ultipa.password=<password>
ultipa.passwordEncrypt=NOTHING
ultipa.defaultGraph=amz
# ultipa.crt=F:\\ultipa.crt
# ultipa.overrideAuthority=ultipa
# ultipa.crt=https
# ultipa.crt=
ultipa.keepAlive=180
ultipa.keepAliveWithoutCalls=true
ultipa.pool.maxIdle=50
ultipa.pool.minIdle=20
ultipa.pool.maxTotal=200
ultipa.pool.timeBetweenEvictionRunsMillis=3600000
ultipa.pool.testOnBorrow=true
```

Please refer to <a href="#Configuration-Items">Configuration Items</a> for all items available for configuring connection details with the `ultipa.properties` file.

## Configuration Items

Below are all the configuration items available for `UltipaConfiguration` and `ultipa.properties`:

| <div table-width="20">Items</div> | <div table-width="10">Type</div> | <div table-width="7">Default</div> | Description |
| ---- | ---- | ---- | ---- |
| `hosts` | String | | Database host addresses or URI (excluding `https://` or `http://`). For clusters, multiple addresses are separated by commas. Required. |
| `username` | String | | Username of the host authentication. Required. |
| `password` | String | | Password of the host authentication. Required. |
| `passwordEncrypt` | String | MD5 | Password encryption method of the driver. Supports `MD5`, `LDAP` and `NOTHING`. `NOTHING` is used when the content is blank. |
| `timeout` | Integer | 15 | Request timeout threshold in seconds. |
| `connectTimeout` | Integer | 2000 | Connection timeout threshold in milliseconds. By default, each host is attempted three times. |
| `consistency` | Boolean | false | Whether to use the leader node to ensure consistency read. |
| `crt` | String | | Sets the local certificate file path. SSL will be used for connection, `overrideAuthority` must be appropriately configured. Alternatively, set to `https` for HTTPS protocol host. Non-SSL connection is used when it is ignored. |
| `keepAlive` | Integer | 120 | Maximum period in seconds of inactivity before sending a keep-alive probe to the host to maintain connection responsiveness (may increase service load). |
| `keepAliveWithoutCalls` | Boolean | false | Activates keep-alive mechanism even during connection inactivity. |
| `overrideAuthority` | String | | Overrides `hostname` with `ultipa` to match server certificate authority. |
| `maxRecvSize` | Integer | 4 | Maximum size in megabytes when receiving data. |
| `defaultGraph` | String | default | Name of the graph in the database to use by default. |
| `heartBeat` | Integer | 10000 | Heartbeat interval in milliseconds for all instances, set 0 to disable heartbeat.  |
| `poolConfig` | `PoolConfig` | | Configures the <a href="#Connection-Pooling">connection pooling</a>. |

## Connection Pooling

`PoolConfig` contains the configuration settings for using the Apache Commons Pool library. These settings are necessary when connecting to a database to efficiently handle and reuse connections.

<p tit="Main.java" ></p> 

```java
package com.ultipa.www.sdk.api;

import com.ultipa.sdk.connect.Connection;
import com.ultipa.sdk.connect.conf.UltipaConfiguration;
import com.ultipa.sdk.connect.driver.UltipaClientDriver;

public class Main {
    public static void main(String[] args) {
        UltipaConfiguration myConfig = UltipaConfiguration.config()
            // URI example: .hosts("mqj4zouys.us-east-1.cloud.ultipa.com:60010")
            .hosts("192.168.1.85:60061,192.168.1.86:60061,192.168.1.87:60061")
            .username("<username>")
            .password("<password>");

        PoolConfig poolConfig = myConfig.getPoolConfig();
        poolConfig.setMaxIdle(50);
        poolConfig.setMinIdle(2);
        poolConfig.setMaxTotal(200);

        UltipaClientDriver driver = null;
        try {
            driver = new UltipaClientDriver(myConfig);
            Connection client = driver.getConnection();

            String reply = client.sayHello("Hi");
            System.out.println(reply);
        } finally {
            if (driver != null) {
                driver.close();
            }
        }
    }
}
```

`PoolConfig` has the following fields:

| <div table-width="20">Item</div> | <div table-width="10">Type</div> | <div table-width="7">Default</div> | Description |
| ---- | ---- | ---- | ---- |
| `maxIdle` | Integer | 8 | Maximum number of idle connections. |
| `minIdle` | Integer | 0 | Minimum number of idle connections. |
| `maxTotal` | Integer | 8 | Maximum number of total connections. |
| `minEvictableIdleTimeMillis` | Long | 1800000 | Minimum idle time in milliseconds before a connection is evictable. |
| `timeBetweenEvictionRunsMillis`  | Long | -1 | Interval in milliseconds between eviction tests for idle connections. Set to a negative value to disable scanning. |
| `maxWaitMillis` | Long | -1 | Maximum wait time in milliseconds for a connection. Set to a negative value to wait indefinitely. |
| `testOnBorrow` | Boolean | false | Whether to test connections when borrowing. |
| `testOnReturn` | Boolean | true | Whether to test connections when returning. |
| `testWhileIdle` | Boolean | true | Whether to test connections while idle. |
| `lifo` | Boolean | true | Whether to use last-in-first-out (LIFO) order. |
| `blockWhenExhausted` | Boolean | true | Whether to block new requests until a connection is available when connections are exhausted. If set to false, an error is thrown. |
| `numTestsPerEvictionRun` | Integer | 3 | Maximum number of connections to test per eviction run. |

## Data Source

By setting the configurations and the target graph in a `DataSource`, you can easily pass all necessary connection information to the `UltipaClientDriver` when creating a connection.

> When `UltipaClientDriver` is instantiated using `DataSource`, the `ultipa.properties` file is ignored.

<p tit="Main.java" ></p> 

```java
package com.ultipa.www.sdk.api;

import com.ultipa.sdk.connect.Connection;
import com.ultipa.sdk.connect.conf.UltipaConfiguration;
import com.ultipa.sdk.connect.driver.UltipaClientDriver;

public class Main {
    public static void main(String[] args) {
        UltipaConfiguration myConfig = UltipaConfiguration.config()
            // URI example: .hosts("mqj4zouys.us-east-1.cloud.ultipa.com:60010")
            .hosts("192.168.1.85:60061,192.168.1.86:60061,192.168.1.87:60061")
            .username("<username>")
            .password("<password>");

        PoolConfig poolConfig = myConfig.getPoolConfig();
        poolConfig.setMaxIdle(50);
        poolConfig.setMinIdle(2);
        poolConfig.setMaxTotal(200);

        DataSource dataSource = new DataSource();
        dataSource.setUltipaConfiguration(myConfig);
        dataSource.setDefaultGraph("amz");

        UltipaClientDriver driver = null;
        try {
            driver = new UltipaClientDriver(dataSource);
            Connection client = driver.getConnection();

            String reply = client.sayHello("Hi");
            System.out.println(reply);
        } finally {
            if (driver != null) {
                driver.close();
            }
        }
    }
}
```

## Close Connection

The driver object can be reused across multiple threads, and the connection can be properly closed by calling the `driver.close()` method.
