# Induced Subgraph

<div><span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ File Writeback</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Property Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Direct Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stream Return</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Stats</b></span></div>

## Overview

The Induced Subgraph algorithm is used to compute the induced subgraph of a given set of nodes in a graph. It provides a way to focus on the immediate connections and gain insights into the local structure and interactions within the selected subset of nodes.

## Concepts

### Induced Subgraph

An induced subgraph includes only the nodes from the given set and the edges that connect those nodes. 

<div align='center' drawio-diagram='6063' drawio-name="draw_2044bf57a80e4696a943ed9e77ce416c.jpg"><img src="https://img.ultipa.cn/draw/draw_2044bf57a80e4696a943ed9e77ce416c.jpg?v='1685497373767'"/></div>

As this example shows, when specifying node set <i>S = {A, B, I, K, L, M, N}</i>, the induced subgraph is the graph whose node set is <i>S</i> and whose edge set contains all edges that have both endpoints in <i>S</i>.

Ultipa's Induced Subgraph algorithm returns all the 1-step paths in the induced subgraph.

## Considerations

- The Induced Subgraph algorithm ignores the direction of edges but calculates them as undirected edges.

## Syntax

- Command: `algo(subgraph)`
- Parameters:

| <div table-width="11">Name</div> | <div table-width="16">Type</div> | <div table-width="6">Spec</div> | <div table-width="7">Default</div> | <div table-width="8">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| ids / uuids | []`_id` / []`_uuid`	| / | / | No | ID/UUID of the nodes to calculate |
| limit | int | ≥-1 | `-1` | Yes | Number of results to return, `-1` to return all results |

## Examples

The example graph is as follows:

<div align='center' drawio-diagram='2573' drawio-name="draw_415c38e4a8224988bbaad1c45bb7c5fc.jpg"><img src="https://img.ultipa.cn/draw/draw_415c38e4a8224988bbaad1c45bb7c5fc.jpg?v='1685498592253'"/></div>

### File Writeback

| <div table-width="13">Spec</div> | <div table-width="18">Content</div> | Description |
| --- | --- | --- |
| filename | `_id--[_uuid]--_id` | One-step path in the induced subgraph:<br>(start node)--(edge)--(end node) |

```js
algo(subgraph).params({
  ids: ['A','C','D','G']
}).write({
  file:{
    filename: 'paths'
    }
})
```

Results: File <i>paths</i>

<p run-tag="false" graph="" tit="File" ></p>

```js
C--[102]--A
C--[105]--D
D--[107]--A
D--[106]--A
G--[109]--G
```

### Direct Return

| <div table-width="15">Alias Ordinal</div> | <div table-width="10">Type</div> | Description |
| --- | --- | --- |
| 0 | []path | One-step path in the induced subgraph: <br>`_uuid` (start node) -- [`_uuid`] (edge) -- `_uuid` (end node) |

```js
algo(subgraph).params({
  ids: ['A','C','D','G']
}) as subgraph
return subgraph
```

Results: <i>subgraph</i>

<table>
<tr><td>3--[102]--1</td></tr>
<tr><td>3--[105]--4</td></tr>
<tr><td>4--[107]--1</td></tr>
<tr><td>4--[106]--1</td></tr>
<tr><td>7--[109]--7</td></tr>
</table>

### Stream Return

| <div table-width="15">Alias Ordinal</div> | <div table-width="10">Type</div> | Description |
| --- | --- | --- |
| 0 | []path | One-step path in the induced subgraph: <br>`_uuid` (start node) -- [`_uuid`] (edge) -- `_uuid` (end node) |

```js
algo(subgraph).params({
  uuids: [6,7]
}).stream() as p
with pedges(p) as e
find().edges(e) as edges
return max(edges.score)
```

