# Connection

After <a href="https://www.ultipa.com/doc/drivers/python-installation">installing the Ultipa Python SDK</a> and setting up a running Ultipa instance, you should be able to connect your application to the Ultipa graph database.

Connection to Ultipa can be established by creating a driver with configurations specified using the following methods:

- <a href="#Code-Configuration-Connection">Code Configuration Connection</a>: through the `UltipaConfig` class
- <a href="#File-Configuration-Connection">File Configuration Connection</a>: through the `.env` file and the `UltipaConfig` class

The values of <a href="#Configuration-Items">configuration items</a> are preferentially determined by `UltipaConfig`, followed by `.env`. If an item is not found in either configuration, the default value is used.

## Code Configuration Connection

```python
from ultipa import Connection, UltipaConfig

ultipaConfig = UltipaConfig()
# URI example: ultipaConfig.hosts = ["mqj4zouys.us-east-1.cloud.ultipa.com:60010"]
ultipaConfig.hosts = ["192.168.1.85:60061", "192.168.1.87:60061", "192.168.1.88:60061"]
ultipaConfig.username = "<username>"
ultipaConfig.password = "<password>"

Conn = Connection.NewConnection(defaultConfig=ultipaConfig)

response = Conn.test()
# The connection is successfully established if the code is 0
print("Code = ", response.status.code)
```

<p tit="Output"></p> 

```
Code =  0
```

A driver is created with the configurations specified using `UltipaConfig`. Please refer to <a href="#Configuration-Items">Configuration Items</a> for all items available for configuring connection details with `UltipaConfig`.

The `Connection.NewConnection()` method obtains a connection to Ultipa. The graphset identified by the configuration item `defaultGraph` will be used.

## File Configuration Connection

```python
import os
from dotenv import load_dotenv, dotenv_values
from pathlib import Path
from ultipa import Connection, UltipaConfig
from ultipa.utils.logger import LoggerConfig

# Loads the .env file into the environment, and overrides system environment variables
env_path = Path('./.env')
env_dict = dotenv_values(dotenv_path=env_path)
load_dotenv(encoding='utf-8', override=True)

# Fetches environment variables
env_config = {
    "hosts": os.getenv("hosts"),
    "username": os.getenv("username"),
    "password": os.getenv("password"),
    "defaultGraph": os.getenv("defaultGraph")
}

def getConn():
    hosts = env_config.get("hosts", "").split(",")
    username = env_config.get("username", "")
    password = env_config.get("password", "")
    defaultGraph = env_config.get("defaultGraph", "")

    uqlLoggerConfig = LoggerConfig(name="testLog", fileName="../intergration_tests/Logs/test.log", isWriteToFile=True, isStream=True)
    defaultConfig = UltipaConfig(hosts=hosts, username=username, password=password, heartBeat=10, uqlLoggerConfig=uqlLoggerConfig)
    Conn = Connection.NewConnection(defaultConfig)
    return Conn

response = getConn().test()
print("Code = ", response.status.code)
```

<p tit="Output"></p> 

```
2024-08-19 10:21:00,347 - INFO: Test Welcome To Ultipa!
2024-08-19 10:21:00,357 - INFO: Test Welcome To Ultipa!
2024-08-19 10:21:00,370 - INFO: Test Welcome To Ultipa!
2024-08-19 10:21:00,374 - INFO: Test Welcome To Ultipa!
Code =  1000
```

A driver is created with the configurations specified using the `.env` file. The `.env` file should be placed under root path of the project.

Example of the `.env` file:

<p tit=".env" ></p> 

```js
#hosts=mqj4zouys.us-east-1.cloud.ultipa.com:60010
hosts=192.168.1.85:60061,192.168.1.86:60061,192.168.1.87:60061
username=<username>
password=<password>
passwordEncrypt=PasswordEncrypt.MD5
timeoutWithSeconds=300
consistency=true
#crtFilePath=F:\\ultipa.crt
#maxRecvSize=10240
defaultGraph=miniCircle
#timeZone=Asia/Tokyo
#timeZoneOffset=+0700
#responseWithRequestInfo=false
#debug=false
```

Please refer to <a href="#Configuration-Items">Configuration Items</a> for all items available for configuring connection details with the `.env` file.

## Configuration Items

Below are all the configuration items available for `UltipaConfig` and `.env` file:

| <div table-width="20">Items</div> | <div table-width="10">Type</div> | <div table-width="8">Default</div> | Description |
| ---- | ---- | ---- | ---- |
| `hosts` | List[str] | | Database host addresses or URI (excluding `https://` or `http://`). For clusters, multiple addresses are separated by commas. Required. |
| `username` | str | | Username of the host authentication. Required. |
| `password` | str | | Password of the host authentication. Required. |
| `passwordEncrypt` | `PasswordEncrypt` | `PasswordEncrypt.MD5` | Password encryption method of the driver. Supports `MD5`, `LDAP` and `NOTHING`. |
| `timeoutWithSeconds` | int | 3600 | Request timeout threshold in seconds. |
| `consistency` | bool | False | Whether to use the leader node to ensure consistency read. |
| `crtFilePath` | str | | The file path of SSL certificate when both Ultipa server and client-end are in SSL mode. |
| `maxRecvSize` | int | -1 | Maximum size in bytes when receiving data. |
| `defaultGraph` | str | default | Name of the graph in the database to use by default. |
| `heartBeat` | int | 10 | Heartbeat interval in seconds for all instances, set 0 to disable heartbeat. |
| `heartBeat` | int | 10 | Heartbeat interval in seconds for all instances, set 0 to disable heartbeat. |
| `timeZone` | str | | Timezone, e.g., Europe/Paris. |
| `timeZoneOffset` | int/str | | Specifies how far the target timezone is from UTC, either in seconds (if an integer) or a 5-character string such as +0700 and -0430. |
| `responseWithRequestInfo` | bool | False | Whether to return request. |
| `debug` | bool | False | Whether to use debug mode. |
| `uqlLoggerConfig` | `LoggerConfig` | | Configures logging for the UQL operations, including `name`, `filename`, `isWriteToFile`, `level` and `isStream`. |
