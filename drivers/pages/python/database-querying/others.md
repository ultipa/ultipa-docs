# Others

This section introduces methods on a `Connection` object for checking the database server statistics and the driver connection.

Each example focuses solely on the method's usage. For a complete code example, please refer to the <a href="#Full-Example">full example</a>.

## stats()

Retrieves database server statistics.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Stats`: The retrieved server statistics.

<p tit="Python"></p>

```js
stats = Conn.stats()
print("CPU usage (%): " + stats.cpuUsage)
print("Memory usage (MB): " + stats.memUsage)
print("Expiration date: " + stats.expiredDate)
print("CPU cores: " + stats.cpuCores)
print("Company: " + stats.company)
print("Server type: " + stats.serverType)
print("Version: " + stats.version)
```

<p tit="Output"></p>

```js
CPU usage (%): 116.560783
Memory usage (MB): 11924.585938
Expiration date: Thu Dec 26 23:59:59 2024
CPU cores: 80
Company: ultipa
Server type: CT
Version: htap_beta.4.5.7-b4.5.0-tv-ui
```

## test()

Tests driver and database server connection.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit="Python"></p>

```js
response = Conn.test()
print(response.status.code)
```

<p tit="Output"></p>

```js
0
```

## Full Example

<p tit="example.py" ></p> 

```python
from ultipa import Connection, UltipaConfig

ultipaConfig = UltipaConfig()
# URI example: ultipaConfig.hosts = ["mqj4zouys.us-east-1.cloud.ultipa.com:60010"]
ultipaConfig.hosts = ["192.168.1.85:60061", "192.168.1.87:60061", "192.168.1.88:60061"]
ultipaConfig.username = "<username>"
ultipaConfig.password = "<password>"

Conn = Connection.NewConnection(defaultConfig=ultipaConfig)

# Test connection
response = Conn.test()
print(response.status.code)
```