## Connection

Once you have <a target="_blank" href="/docs/drivers/python-installation">installed the driver</a> and set up an Ultipa instance, you can connect your application to the database.

You can establish a connection using the configurations from `UltipaConfig`. See <a href="#UltipaConfig-Attributes">UltipaConfig Attributes</a>.

## Creating a Connection

Creates a connection using `Connection.NewConnection()`:

```python
from ultipa import Connection, UltipaConfig

ultipaConfig = UltipaConfig()
# URI example: ultipaConfig.hosts = ["mqj4zouys.us-east-1.cloud.ultipa.com:60010"]
ultipaConfig.hosts = ["192.168.1.85:60061", "192.168.1.87:60061", "192.168.1.88:60061"]
ultipaConfig.username = "<username>"
ultipaConfig.password = "<password>"

Conn = Connection.NewConnection(defaultConfig=ultipaConfig)

# Tests the connection
isSuccess = Conn.test()
print("Connection succeeds:", isSuccess)
```

<p tit="Output"></p> 

```
Connection succeeds: True
```

## Using Configuration File

This example demonstrates how to use the configuration file `.env` to establish a connection:

```python
import os
from pathlib import Path
from dotenv import dotenv_values, load_dotenv
from ultipa import Connection, UltipaConfig

# Loads the .env file and overrides system environment variables
env_path = Path('./.env')
env_dict = dotenv_values(dotenv_path=env_path)
load_dotenv(encoding='utf-8', override=True)

hosts = os.getenv("hosts").split(",")
username = os.getenv("username")
password = os.getenv("password")

ultipaConfig = UltipaConfig(hosts=hosts, username=username, password=password, heartbeat=10)
Conn = Connection.NewConnection(defaultConfig=ultipaConfig)

# Tests the connection
response = Conn.test()
print(response.status.code.name)
```

<p tit="Output"></p> 

```
SUCCESS
```

Example of the `.env` file:

<p tit=".env" ></p> 

```
#hosts=mqj4zouys.us-east-1.cloud.ultipa.com:60010
hosts=192.168.1.85:60061,192.168.1.86:60061,192.168.1.87:60061
username=<username>
password=<password>
passwordEncrypt=MD5
defaultGraph=miniCircle
#crt=F:\\ultipa.crt
#maxRecvSize=10240
```

## UltipaConfig Attributes

The `UltipaConfig` class includes the following attributes:

| <div table-width="22">Attribute</div> | <div table-width="10">Type</div> | <div table-width="8">Default</div> | Description |
| ---- | ---- | ---- | ---- |
| `hosts` | List[str] | / | **Required.** A comma-separated list of database server IPs or URLs. The protocol is automatically identified, do not include `https://` or `http://` as a prefix in the URL. |
| `username` | str | / | **Required.** Username of the host authentication. |
| `password` | str | / | **Required.** Password of the host authentication. |
| `defaultGraph` | str | / | Name of the graph to use by default in the database. |
| `crt` | str | / | The file path of the SSL certificate used for secure connections. |
| `passwordEncrypt` | str | `MD5` | Password encryption method of the driver. Supports `MD5`, `LDAP` and `NOTHING`. |
| `timeout` | int | Maximum | Request timeout threshold (in seconds). |
| `heartbeat` | int | 0 | The heartbeat interval (in milliseconds), used to keep the connection alive. Set to 0 to disable. |
| `maxRecvSize` | int | 32 | The maximum size (in MB) of the received data. |
