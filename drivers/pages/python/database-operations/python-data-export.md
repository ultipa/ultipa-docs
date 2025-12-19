# Data Export

This section introduces methods for exporting nodes and edges from graphs. 

# export()

Exports nodes or edges from the graph.

**Parameters**

- `exportRequest: ExportRequest`: Configurations for the export request, including attributes `dbType`, `schema`, `selectProperties` and `graph`.
- `cb: Callable[[List[Node], List[Edge]], None]`: The callback function that gets executed when data is exported.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- None.

```python
# Exports 'account' nodes in the graph 'miniCircle'

batch_counter = 0 # Global counter for batch tracking

exportRequest = ExportRequest(
    dbType=DBType.DBNODE,
    schema="account",
    selectProperties=["_id", "name", "year"],
    graph="miniCircle"
)

def handle_export(nodes: List[Node], edges: List[Edge]): # Defines the callback function
    global batch_counter
    batch_counter += 1

    try:
        schema = exportRequest.schema
        if nodes:
            df_nodes = pd.DataFrame([node.__dict__ for node in nodes]) # Converts to dictionary
            df_nodes.to_csv(f"{schema}_nodes.csv", mode="a", index=False)
            print(f"Batch {batch_counter} exported")
        if edges:
            df_edges = pd.DataFrame([edge.__dict__ for edge in edges]) # Converts to dictionary
            df_edges.to_csv(f"{schema}_edges.csv", mode="a", index=False)
            print(f"Batch {batch_counter} exported")
    except Exception as e:
        print(f"Batch {batch_counter} export failed: {e}")

Conn.export(exportRequest, handle_export)
```

<p tit="Output"></p>

```
Batch 1 exported
Batch 2 exported
Batch 3 exported
```

The file `account_nodes.csv` is exported to the same directory as the file you executed.

## Full Example

<p tit="example.py"></p>

```python
from typing import List
import pandas as pd
from ultipa import UltipaConfig, Connection, ExportRequest, DBType, Node, Edge

ultipaConfig = UltipaConfig()
# URI example: ultipaConfig.hosts = ["mqj4zouys.us-east-1.cloud.ultipa.com:60010"]
ultipaConfig.hosts = ["192.168.1.85:60061", "192.168.1.87:60061", "192.168.1.88:60061"]
ultipaConfig.username = "<username>"
ultipaConfig.password = "<password>"

Conn = Connection.NewConnection(defaultConfig=ultipaConfig)

# Exports 'account' nodes in the graph 'miniCircle'

batch_counter = 0 # Global counter for batch tracking

exportRequest = ExportRequest(
    dbType=DBType.DBNODE,
    schema="account",
    selectProperties=["_id", "name", "year"],
    graph="miniCircle"
)

def handle_export(nodes: List[Node], edges: List[Edge]): # Defines the callback function
    global batch_counter
    batch_counter += 1

    try:
        schema = exportRequest.schema
        if nodes:
            df_nodes = pd.DataFrame([node.__dict__ for node in nodes]) # Converts to dictionary
            df_nodes.to_csv(f"{schema}_nodes.csv", mode="a", index=False)
            print(f"Batch {batch_counter} exported")
        if edges:
            df_edges = pd.DataFrame([edge.__dict__ for edge in edges]) # Converts to dictionary
            df_edges.to_csv(f"{schema}_edges.csv", mode="a", index=False)
            print(f"Batch {batch_counter} exported")
    except Exception as e:
        print(f"Batch {batch_counter} export failed: {e}")

Conn.export(exportRequest, handle_export)
```
