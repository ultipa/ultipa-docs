## Connection

Once you have <a target="_blank" href="/docs/drivers/java-installation">installed the driver</a> and set up an Ultipa instance, you can connect your application to the database.

You can establish a connection using the configurations from `UltipaConfig`. See <a href="#UltipaConfig-Attributes">UltipaConfig Attributes</a>.

## Creating a Connection

Creates a connection using `UltipaDriver()`:

<p tit="Main.java"></p> 

```java
package com.ultipa.www.sdk.api;

import com.ultipa.sdk.UltipaDriver;
import com.ultipa.sdk.connect.conf.UltipaConfig;
import org.assertj.core.util.Lists;

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
            Boolean isSuccess = driver.test();
            System.out.println("Connection succeeds: " + isSuccess);
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

<p tit="Output"></p> 

```
Connection succeeds: true
```

## UltipaConfig Attributes

The `UltipaConfig` class includes the following attributes:

| <div table-width="20">Attribute</div> | <div table-width="12">Type</div> | <div table-width="8">Default</div> | Description |
| ---- | ---- | ---- | ---- |
| `hosts` | List\<String\> | / | **Required.** A comma-separated list of database server IPs or URLs. The protocol is automatically identified, do not include `https://` or `http://` as a prefix in the URL. |
| `username` | String | / | **Required.** Username of the host authentication. |
| `password` | String | / | **Required.** Password of the host authentication. |
| `defaultGraph` | String | / | Name of the graph to use by default in the database. |
| `crt` | String | / | The file path of the SSL certificate used for secure connections. |
| `passwordEncrypt` | String | `MD5` | Password encryption method of the driver. Supports `MD5`, `LDAP` and `NOTHING`. |
| `connectTimeout` | Integer | 2000 | Connection timeout threshold (in milliseconds). By default, each host is attempted three times. |
| `timeout` | Integer | Maximum | Request timeout threshold (in second). |
| `heartbeat` | Integer | 0 | The heartbeat interval (in millisecond), used to keep the connection alive. Set to 0 to disable. |
| `maxRecvSize` | Integer | 32 | The maximum size (in MB) of the received data. |
| `poolConfig` | `PoolConfig` | / | Configures <a href="#Connection-Pooling">Connection Pooling</a>. |
| `keepAlive` | Integer | 120 | The maximum period (in seconds) of inactivity before sending a keep-alive probe to the host to maintain connection responsiveness (may increase service load). |
| `keepAliveWithoutCalls` | Boolean | false | Activates keep-alive mechanism even during connection inactivity. |
| `overrideAuthority` | String | / | Overrides `hostname` with `ultipa` to match server certificate authority. |

## Connection Pooling

`Ultipa.poolConfig` contains the configuration for using the Apache Commons Pool library. These settings are necessary when connecting to a database to efficiently handle and reuse connections.

The `PoolConfig` class includes the following attributes:

| <div table-width="22">Attribute</div> | <div table-width="10">Type</div> | <div table-width="15">Default</div> | Description |
| ---- | ---- | ---- | ---- |
| `maxTotal` | int | 8 | Maximum number of total connections (active + idle) allowed in the pool. |
| `maxIdle` | int | 8 | Maximum number of idle connections in the pool. |
| `minIdle` | int | 1 | Minimum number of idle connections to maintain. |
| `minEvictableIdleTimeMillis` | long | 1800000L (30 minutes) | Minimum time a connection may sit idle before being eligible for eviction. |
| `timeBetweenEvictionRunsMillis` | long | 600000L (10 minutes) | Time interval between eviction runs that check idle connections. |
| `numTestsPerEvictionRun` | int | 3 | Number of connections to test during each eviction run. |
| `testOnBorrow` | boolean| false | Whether to validate a connection before borrowing from the pool. |
| `testOnReturn` | boolean | true | Whether to validate a connection when returning it to the pool. |
| `testWhileIdle` | boolean	| true | Whether to validate idle connections during eviction runs. |
| `maxWaitMillis` | long | -1L | Maximum time to wait for a connection when the pool is exhausted (wait indefinitely by default). |
| `lifo` | boolean	| true | Whether to use LIFO (last-in-first-out) order for connection retrieval. |
| `blockWhenExhausted` | boolean | true	| Whether to block when the pool is exhausted or immediately throw an exception. |

<p tit="Main.java"></p> 

```java
package com.ultipa.www.sdk.api;

import com.ultipa.sdk.UltipaDriver;
import com.ultipa.sdk.connect.conf.PoolConfig;
import com.ultipa.sdk.connect.conf.UltipaConfig;
import org.assertj.core.util.Lists;

public class Main {
    public static void main(String[] args) {
        UltipaConfig ultipaConfig = UltipaConfig.config()
                // URI example: .hosts(Lists.newArrayList("d3026ac361964633986849ec43b84877s.eu-south-1.cloud.ultipa.com:8443"))
                .hosts(Lists.newArrayList("192.168.1.85:60061","192.168.1.88:60061","192.168.1.87:60061"))
                .username("<username>")
                .password("<password>");

        PoolConfig poolConfig = ultipaConfig.getPoolConfig();
        poolConfig.setMaxIdle(50);
        poolConfig.setMinIdle(2);
        poolConfig.setMaxTotal(200);

        UltipaDriver driver = null;

        try {
            driver = new UltipaDriver(ultipaConfig);
            Boolean isSuccess = driver.test();
            System.out.println("Connection succeeds: " + isSuccess);
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

<p tit="Output"></p> 

```
Connection succeeds: true
```
