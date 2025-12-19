## UQL Execution

This section introduces the `uql()` and `uqlStream()` methods to execute UQL in the database.

> UQL (Ultipa Query Language) is the native language designed by Ultipa to fully interact with Ultipa graph databases. For detailed information on UQL, refer to the <a target="_blank" href="/docs/uql">documentation</a>.

## uql()

Executes a UQL query in the database.

**Parameters**

- `uql: str`: The UQL query to be executed.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```python
# Retrieves 5 movie nodes from the graph 'miniCircle'

requestConfig = RequestConfig(graph="miniCircle")
response = Conn.uql("find().nodes({@movie}) as n return n{*} limit 5", requestConfig)
nodeList = response.alias("n").asNodes()
for node in nodeList:
    print(node.get("name"))
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

Executes a UQL query in the database and returns the results incrementally, allowing handling of large datasets without loading everything into memory at once.

**Parameters**

- `uql: str`: The UQL query to be executed.
- `cb: QueryResponseListener`: Listener for the streaming process.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `None`

```python
# Retrieves all 1-step paths from the graph 'miniCircle'

requestConfig = RequestConfig(graph="miniCircle")

# Define the event handler functions
def on_start(requestConfig):
    print("Stream started.")

def on_data(res, requestConfig):
    print("Data received:", res)

def on_end(requestConfig):
    print("Stream ended.")

stream = QueryResponseListener()
stream.on("start", on_start)
stream.on("data", on_data)
stream.on("end", on_end)
uql = 'n().e().n() as p return p{*}'
result = Conn.uqlStream(uql, stream, requestConfig)
print()
```

<p tit="Output"></p> 

```
Stream started.
Data received: {'status': <ultipa.types.types.Status object at 0x000001E01762FCA0>, 'items': {'paths': <ultipa.types.types.DataItem object at 0x000001E017635730>}, 'aliases': None, 'req': None, 'statistics': <ultipa.types.types.UltipaStatistics object at 0x000001E017635850>, 'explainPlan': None}
Data received: {'status': <ultipa.types.types.Status object at 0x000001E01762F2B0>, 'items': {'paths': <ultipa.types.types.DataItem object at 0x000001E0189C4DF0>}, 'aliases': None, 'req': None, 'statistics': <ultipa.types.types.UltipaStatistics object at 0x000001E0189C4D60>, 'explainPlan': None}
Stream ended.
```

## Full Example

<p tit="example.py" ></p> 

```python
from ultipa import UltipaConfig, Connection, RequestConfig

ultipaConfig = UltipaConfig()
# URI example: ultipaConfig.hosts = ["mqj4zouys.us-east-1.cloud.ultipa.com:60010"]
ultipaConfig.hosts = ["192.168.1.85:60061", "192.168.1.87:60061", "192.168.1.88:60061"]
ultipaConfig.username = "<username>"
ultipaConfig.password = "<password>"

Conn = Connection.NewConnection(defaultConfig=ultipaConfig)

# Retrieves 5 movie nodes from the graph 'miniCircle'

requestConfig = RequestConfig(graph="miniCircle")
response = Conn.uql("find().nodes({@movie}) as n return n{*} limit 5", requestConfig)
nodeList = response.alias("n").asNodes()
for node in nodeList:
    print(node.get("name"))
```
