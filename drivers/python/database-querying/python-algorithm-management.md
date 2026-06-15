# Algorithm Management

This section introduces methods on a `Connection` object for managing <a href="/docs/graph-analytics-algorithms">Ultipa graph algorithms</a> and custom algorithms (EXTA) in the instance.

Each example focuses solely on the method's usage. For a complete code example, please refer to the <a href="#Full-Example">full example</a>.

## Ultipa Graph Algorithms

### showAlgo()

Retrieves all Ultipa graph algorithms installed in the instance.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List[Algo]`: The list of all algorithms retrieved.

```python
# Retrieves all Ultipa graph algorithms installed and prints the information of the first returned one

algos = Conn.showAlgo()
print(algos[0].toJSON())
```

<p tit="Output"></p> 
 
```
{"name": "lpa", "description": "label propagation algorithm", "version": "1.0.10", "result_opt": "27", "parameters": {"loop_num": "size_t,required", "node_label_property": "optional", "node_weight_property": "optional", "edge_weight_property": "optional", "k": "no more than k labels will be kept for each node", "ids": "labeled nodes, optional, all nodes(with non-NULL value) as labeled nodes if empty"}, "write_to_db_parameters": {"property": "set property name in db, only label with `max probability` will be write to db"}, "write_to_file_parameters": {"filename": "set file name"}}
```

### installAlgo()

Installs an Ultipa graph algorithm in the instance.

**Parameters:**

- `str`: File path of the algo installation package (*.so*).
- `str`: File path of the configuration file (*.yml*).
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UltipaResponse`: Result of the request.

```python
# Installs the algorithm LPA and uses the leader node to guarantee consistency, and prints the error code
# The installation package libplugin_lpa.so and the config file lpa.yml are located in the 'algo' folder, which is placed in the same directory as the file you executed

requestConfig = RequestConfig(useMaster=True)

response = Conn.installAlgo("algo/libplugin_lpa.so", "algo/lpa.yml", requestConfig)
print(response.status.code)
```

<p tit="Output"></p> 
 
```
0
```

### uninstallAlgo()

Uninstalls an Ultipa graph algorithm in the instance.

**Parameters:**

- `str`: Name of the algorithm.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UltipaResponse`: Result of the request.

```python
# Uninstalls the algorithm LPA and prints the error code

requestConfig = RequestConfig()

response = Conn.uninstallAlgo("lpa")
print(response.status.code)
```

<p tit="Output"></p> 
 
```
0
```

## EXTA

### showExta()

Retrieves all extas installed in the instance.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List[Exta]`: The list of all extas retrieved.

```python
# Retrieves all extas installed and prints the information of the first returned one

extas = Conn.showExta()
print(extas[0].toJSON())
```

<p tit="Output"></p> 
 
```
{
  "author": "wuchuang",
  "detail": {
    "base": {
      "category": "ExtaExample",
      "cn": {
        "name": "page_rank",
        "desc": null
      },
      "en": {
        "name": "page_rank",
        "desc": null
      }
    },
    "other_param": {},
    "param_form": {},
    "write": {},
    "return": {},
    "media": {}
  },
  "name": "page_rank",
  "version": "beta.4.4.41-b4.4.0-tv-ui"
}
```

### installExta()

Installs an exta in the instance.

**Parameters:**

- `str`: File path of the exta installation package (*.so*).
- `str`: File path of the configuration file (*.yml*).
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UltipaResponse`: Result of the request.

```python
# Installs the exta page_rank and uses the leader node to guarantee consistency, and prints the error code
# The installation package libexta_page_rank.so and the config file page_rank.yml are located in the 'exta' folder, which is placed in the same directory as the file you executed

requestConfig = RequestConfig(useMaster=True)

response = Conn.installExta("exta/libexta_page_rank.so", "exta/page_rank.yml", requestConfig)
print(response.status.code)
```

<p tit="Output"></p> 
 
```
0
```

### uninstallExta()

Uninstalls an exta in the instance.

**Parameters:**

- `str`: Name of the exta.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UltipaResponse`: Result of the request.

```python
# Uninstalls the exta page_rank and prints the error code

response = Conn.uninstallExta("page_rank")
print(response.status.code)
```

<p tit="Output"></p> 
 
```
0
```

## Full Example

<p tit="example.py" ></p> 

```python
from ultipa import Connection, UltipaConfig
from ultipa.configuration.RequestConfig import RequestConfig

ultipaConfig = UltipaConfig()
# URI example: ultipaConfig.hosts = ["mqj4zouys.us-east-1.cloud.ultipa.com:60010"]
ultipaConfig.hosts = ["192.168.1.85:60061","192.168.1.87:60061","192.168.1.88:60061"]
ultipaConfig.username = "<username>"
ultipaConfig.password = "<password>"

Conn = Connection.NewConnection(defaultConfig=ultipaConfig)

# Request configurations
requestConfig = RequestConfig(useMaster=True)

# Installs the algorithm LPA: the installation package libplugin_lpa.so and the config file lpa.yml are placed under the 'algo' folder within the current project directory.
response = Conn.installAlgo("algo/libplugin_lpa.so", "algo/lpa.yml", requestConfig)
print(response.status.code)   
```
