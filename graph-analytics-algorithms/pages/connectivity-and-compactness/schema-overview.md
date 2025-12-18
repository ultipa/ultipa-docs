# Schema Overview

<div><span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ File Writeback</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Property Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Direct Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stream Return</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Stats</b></span></div>

## Overview

The Schema Overview algorithm summarizes the structure of a graph by presenting the statistics of the source node schema, edge schema, end node schema, and the count of edges.

## Syntax

- Command: `algo(schema_overview)`
- Parameters:

| <div table-width="13">Name</div> | <div table-width="7">Type</div> | <div table-width="12">Spec</div> | <div table-width="7">Default</div> | <div table-width="9">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| order | string | `asc`, `desc` | / | Yes | Sorts the results based on the edge count. |

## Examples

The example graph is as follows:

<div align=center drawio-diagram='17034' drawio-name="draw_21f3f3201d4b412ca26ec1229b35c256.jpg"><img src="https://img.ultipa.cn/draw/draw_21f3f3201d4b412ca26ec1229b35c256.jpg?v='1726279069119'"/></div>

### Direct Return 

| Alias Ordinal | <div table-width=12>Type</div> | <div table-width=35>Description</div> | <div table-width=30>Columns</div> |
| -- | -- | -- | -- |
| 0	| []perGroup | Statistics showing the number of edges of a specific schema between two node schemas	| `node schema(src)`, `edge schema`, `node schema(dest)`, `count` |

```uql
algo(schema_overview).params() as result 
return result
```

Results: *result*

| <div table-width="25">node schema(src)</div> | <div table-width="15">edge schema</div> | <div table-width="25">node schema(dest)</div>  | count |
| --- | --- | --- | --- |
| account  | follow   | account | 2 |
| account  | like	  | movie   | 1 |
| movie    | filmedIn | country | 1 |
| director | direct	  | movie   | 2 |

### Stream Return

| Alias Ordinal | <div table-width=12>Type</div> | <div table-width=35>Description</div> | <div table-width=30>Columns</div> |
| -- | -- | -- | -- |
| 0	| []perGroup | Statistics showing the number of edges of a specific schema between two node schemas	| `node schema(src)`, `edge schema`, `node schema(dest)`, `count` |

```uql
algo(schema_overview).params().stream() as result
where result.`node schema(src)` = "account" 
return result
```

Results: *result*

| <div table-width="25">node schema(src)</div> | <div table-width="15">edge schema</div> | <div table-width="25">node schema(dest)</div>  | count |
| --- | --- | --- | --- |
| account  | follow   | account | 2 |
| account  | like	  | movie   | 1 |