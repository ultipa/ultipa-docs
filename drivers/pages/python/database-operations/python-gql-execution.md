# GQL Execution

This section introduces the `gql()` and `gqlStream()` methods to execute GQL in the database.

> GQL (Graph Query Language) is the ISO-standard query language for graph databases. For detailed information on GQL, refer to the <a target="_blank" href="/docs/gql">documentation</a>.

# gql()

Executes a GQL query in the database.

**Parameters**

- `gql: str`: The GQL query to be executed.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```python
# Retrieves 5 movie nodes from the graph 'miniCircle'

requestConfig = RequestConfig(graph="miniCircle")
response = Conn.gql("MATCH (n:movie) RETURN n LIMIT 5", requestConfig)
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

## gqlStream()

Executes a GQL query in the database and returns the results incrementally, allowing handling of large datasets without loading everything into memory at once.

**Parameters**

- `gql: str`: The GQL query to be executed.
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
gql = 'MATCH p = ()-[]-() RETURN p'
result = Conn.gqlStream(gql, stream, requestConfig)
print()
```

<p tit="Output"></p> 

```
Stream started.
Data received: {'status': <ultipa.types.types.Status object at 0x00000239B87E9FD0>, 'items': {'p': <ultipa.types.types.DataItem object at 0x00000239B87F1790>}, 'aliases': None, 'req': None, 'statistics': <ultipa.types.types.UltipaStatistics object at 0x00000239B87F1760>, 'explainPlan': None}
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
response = Conn.gql("MATCH (n:movie) RETURN n LIMIT 5", requestConfig)
nodeList = response.alias("n").asNodes()
for node in nodeList:
    print(node.get("name"))
```
