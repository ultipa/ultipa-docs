## HDC Graph and Algorithm

This section introduces methods for managing HDC graph and HDC algorithms. Note that these methods require the deployment of HDC servers for the database.

## HDC Graph

### showHDCGraph()

Retrieves all HDC graphs created from the graph.

**Parameters**

- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `List[HDCGraph]`: The list of retrieved HDC graphs.

```python
# Retrieves all HDC graphs of the graph 'miniCircle'

requestConfig = RequestConfig(graph="miniCircle")
hdcGraphs = Conn.showHDCGraph(requestConfig)
for hdcGraph in hdcGraphs:
    print(hdcGraph.name, "on", hdcGraph.hdcServerName)
```

<p tit="Output"></p> 
 
```
miniCircle_hdc_graph on hdc-server-1
miniCircle_hdc_graph2 on hdc-server-2
```

### createHDCGraphBySchema()

Creates an HDC graph for the graph.

**Parameters**

- `builder: HDCBuilder`: The HDC graph to be created; the attributes `hdcGraphName` and `hdcServerName` are mandatory, `nodeSchema`, `edgeSchema`, `syncType`, `direction`, `loadId`, and `isDefault` are optional.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `JobResponse`: Response of the request.

```python
# Creates an HDC graph named 'test_hdc_graph' for the graph 'miniCircle'

requestConfig = RequestConfig(graph="miniCircle")
hdcBuilder = HDCBuilder(
    hdcGraphName="test_hdc_graph",
    hdcServerName="hdc-server-1",
    nodeSchema=[{"*": ["*"]}],
    edgeSchema=[
        {"direct": ["*"]},
        {"review": ["value", "content"]}
    ],
    syncType=HDCSyncType.STATIC
)

response = Conn.createHDCGraphBySchema(hdcBuilder, requestConfig)
jobID = response.jobId

time.sleep(3)
jobs = Conn.showJob(jobID, requestConfig)
for job in jobs:
    print(job.id, "-", job.status)
```

<p tit="Output"></p> 
 
```
61 - FINISHED
61_1 - FINISHED
```

### dropHDCGraph()

Deletes a specified HDC graph of the graph.

**Parameters**

- `hdcGraphName: str`: Name of the HDC graph.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```python
# Drops the HDC graph 'miniCircle_hdc_graph2' of the graph 'miniCircle'

requestConfig = RequestConfig(graph="miniCircle")
response = Conn.dropHDCGraph("miniCircle_hdc_graph2", requestConfig)
print(response.status.code.name)
```

<p tit="Output"></p> 
 
```
SUCCESS
```

## HDC Algorithms

### showHDCAlgo()

Retrieves all HDC algorithms installed on an HDC server.

**Parameters**

- `hdcServerName: str`: Name of the HDC server.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `List[Algo]`: The list of retrieved HDC algorithms.

```python
# Retrieves all HDC algorithms installed on the HDC server 'hdc-server-1'

algos = Conn.showHDCAlgo("hdc-server-1")
data = [[algo.name, algo.writeSupportType] for algo in algos if algo.type == "algo"]
headers = ["Name", "writeSupportType"]
print(tabulate.tabulate(data, headers=headers, tablefmt="grid"))
```

<p tit="Output"></p> 
 
```
+-----------+--------------------+
| Name      | writeSupportType   |
+===========+====================+
| fastRP    | DB,FILE            |
+-----------+--------------------+
| struc2vec | DB,FILE            |
+-----------+--------------------+
```

### installHDCAlgo()

Installs an HDC algorithm on an HDC server.

**Parameters**

- `files: List[str]`: List of the paths of the installation files, the package file (.so) is necessary while the configuration file (.yml) is optional.
- `hdcServerName: str`: Name of the HDC server.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```python
# Installs the HDC algorithm LPA on the HDC server 'hdc-server-1'
# The files 'libplugin_lpa.so' and 'lpa.yml' are located in the 'algo' folder that is placed in the same directory as the file you executed

response = Conn.installHDCAlgo(["algo/libplugin_lpa.so", "algo/lpa.yml"], "hdc-server-1")
print(response.status.code.name)
```

<p tit="Output"></p> 
 
```
SUCCESS
```

### uninstallHDCAlgo()

Uninstalls an HDC algorithm from an HDC server.

**Parameters**

- `algoName: str`: Name of the algorithm.
- `hdcServerName: str`: Name of the HDC server.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```python
# Uninstalls the HDC algorithm LPA from the HDC server 'hdc-server-1'

response = Conn.uninstallHDCAlgo("lpa", "hdc-server-1")
print(response.status.code.name)
```

<p tit="Output"></p> 
 
```
SUCCESS
```

### rollbackHDCAlgo()

Rolls back a specified HDC algorithm on an HDC server.

**Parameters**

- `algoName: str`: Name of the algorithm.
- `hdcServerName: str`: Name of the HDC server.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```python
# Rolls back the HDC algorithms LPA on the HDC server 'hdc-server-1'

response = Conn.rollbackHDCAlgo("lpa", "hdc-server-1")
print(response.status.code.name)
```

<p tit="Output"></p> 
 
```
SUCCESS
```

## Full Example

<p tit="example.py" ></p> 

```python
from ultipa import UltipaConfig, Connection

ultipaConfig = UltipaConfig()
# URI example: ultipaConfig.hosts = ["mqj4zouys.us-east-1.cloud.ultipa.com:60010"]
ultipaConfig.hosts = ["192.168.1.85:60061", "192.168.1.87:60061", "192.168.1.88:60061"]
ultipaConfig.username = "<username>"
ultipaConfig.password = "<password>"

Conn = Connection.NewConnection(defaultConfig=ultipaConfig)

# Installs the HDC algorithm LPA on the HDC server 'hdc-server-1'
# The files 'libplugin_lpa.so' and 'lpa.yml' are located in the 'algo' folder that is placed in the same directory as the file you executed

response = Conn.installHDCAlgo(["algo/libplugin_lpa.so", "algo/lpa.yml"], "hdc-server-1")
print(response.status.code.name) 
```
