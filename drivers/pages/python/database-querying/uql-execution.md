# UQL Execution

This section introduces the `uql()` and `uqlStream()` methods on a `Connection` object for querying the database using UQL.

Each example focuses solely on the method's usage. For a complete code example, please refer to the <a href="#Full-Example">full example</a>.

> UQL (Ultipa Query Language) is the language designed for fully interacting with Ultipa graph databases. For detailed information on UQL, refer to the <a href="https://www.ultipa.com/docs/uql/">documentation</a>.

## uql()

Executes a UQL query on the current graphset or the database and returns the result.

**Parameters:**

- `str`: The UQL query to be executed.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UltipaResponse`: Result of the request.

<p tit="Python" ></p> 

```python
# Retrieves 5 @movie nodes in graphset 'miniCircle' and prints their names

response = Conn.uql("find().nodes({@movie}) as n return n{*} limit 5", requestConfig)

nodeList = response.alias("n").asNodes()
for node in nodeList:
    print(node.get("name"))
```

<p tit= "Output" ></p> 

```Python
The Shawshank Redemption
Farewell My Concubine
Léon: The Professional
Titanic
Life is Beautiful
```

For more examples, please refer to <a href="https://www.ultipa.com/doc/drivers/data-types-mapping-ultipa-and-python">Types Mapping Ultipa and Python</a>.

## uqlStream()

Executes a UQL query on the current graphset or the database and returns the result incrementally, allowing handling of large datasets without loading everything into memory at once.

**Parameters:**

- `str`: The UQL query to be executed.
- `UQLResponseStream`: Listener for the streaming process.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `None`

<p tit="Python" ></p> 

```python
# Retrieves all 1-step paths in graphset 'miniCircle'

requestConfig = RequestConfig(graphName="miniCircle")

# Define the event handler functions
def on_start(requestConfig):
    print("Stream started.")

def on_data(res, requestConfig):
    print("Data received:", res)

def on_end(requestConfig):
    print("Stream ended.")

stream = UQLResponseStream()
stream.on("start", on_start)
stream.on("data", on_data)
stream.on("end", on_end)
uql = 'n().e().n() as paths return paths{*}'
result = Conn.uqlStream(uql, stream, requestConfig)
print()
```

<p tit= "Output" ></p> 

```python
Stream started.
Data received: {'status': <ultipa.types.types.Status object at 0x000001E01762FCA0>, 'items': {'paths': <ultipa.types.types.DataItem object at 0x000001E017635730>}, 'aliases': None, 'req': None, 'statistics': <ultipa.types.types.UltipaStatistics object at 0x000001E017635850>, 'explainPlan': None}
Data received: {'status': <ultipa.types.types.Status object at 0x000001E01762F2B0>, 'items': {'paths': <ultipa.types.types.DataItem object at 0x000001E0189C4DF0>}, 'aliases': None, 'req': None, 'statistics': <ultipa.types.types.UltipaStatistics object at 0x000001E0189C4D60>, 'explainPlan': None}
Stream ended.
```

## Full Example

<p tit="example.py" ></p> 

```python
from ultipa import Connection, UltipaConfig
from ultipa.configuration.RequestConfig import RequestConfig

ultipaConfig = UltipaConfig()
# URI example: ultipaConfig.hosts = ["mqj4zouys.us-east-1.cloud.ultipa.com:60010"]
ultipaConfig.hosts = ["192.168.1.85:60061", "192.168.1.87:60061", "192.168.1.88:60061"]
ultipaConfig.username = "<username>"
ultipaConfig.password = "<password>"

Conn = Connection.NewConnection(defaultConfig=ultipaConfig)

# Request configurations
requestConfig = RequestConfig(graphName="amz")
            
# Retrieves 10 nodes and prints the _id and storeName property value of the first returned one
response = Conn.uql("find().nodes() as n return n{*} limit 10", requestConfig)
nodeList = response.alias("n").asNodes()
print("ID of the 1st node:", nodeList[0].getID())
print("Store name of the 1st node:", nodeList[0].get("storeName"))
```
