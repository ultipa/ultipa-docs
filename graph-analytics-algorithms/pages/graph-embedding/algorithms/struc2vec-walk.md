# Struc2Vec Walk

<div><span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ File Writeback</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Property Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Direct Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stream Return</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Stats</b></span></div>

## Overview

The Struc2Vec Walk is a biased random walk. This is one of the crucial componments of the Struc2Vec framework, where the walk is performed in a constructed multilayer weighted graph rather than the original graph. Please refer to the <a href="https://www.ultipa.com/docs/graph-analytics-algorithms/struc2vec">Struc2Vec</a> algorithm for the details.

## Syntax

- Command：`algo(random_walk_struc2vec)`
- Parameters:

| <div table-width="16">Name</p> | <div table-width="8">Type</div> | <div table-width="8">Spec</div> | <div table-width="7">Default</div> | <div table-width="8">Optional</div> | Description |
| ----- | ---- | ---- | ---- | ---- | -- |
| ids / uuids | []`_id` / []`_uuid`	| / | /	| Yes | ID/UUID of nodes to start random walks; start from all nodes if not set |
| walk_length | int	| ≧1 | `1` | Yes | Depth of each walk, i.e., the number of nodes to visit | 
| walk_num | int | ≧1 | `1` | Yes | Number of walks to perform for each specified node |
| k | int | [1, 10] | / | No | Number of layers of the constructed multilayer weighted graph, which should not exceed the diameter of the original graph |
| stay_probability | float | (0,1] | / | No | The probability of walking in the current level |
| limit | int | ≧-1 | `-1` | Yes | Number of results to return, `-1` to return all results |

## Example

The example graph is as follows:

<div align=center drawio-diagram='6597' drawio-name="draw_8747efdee6d844e9b219cb7e31fa6da2.jpg"><img src="https://img.ultipa.cn/draw/draw_8747efdee6d844e9b219cb7e31fa6da2.jpg?v='1692006469224'"/></div>

### File Writeback

| <div table-width="20">Spec</div> | <div table-width="20">Content</div> | Description |
| --- | --- | --- |
| filename | `_id`,`_id`,... | IDs of visited nodes |

```js
algo(random_walk_struc2vec).params({
  walk_length: 5,
  walk_num: 1,
  k: 4,
  stay_probability: 0.8
}).write({
  file:{
    filename: 'walks'
}})
```

Results: File <i>walks</i>

<p run-tag="false" graph="" tit="File" ></p>

```js
J,G,I,G,
I,H,I,H,G,
H,G,H,I,H,
G,H,I,G,
F,G,H,I,H,
E,C,B,C,
D,C,E,F,G,
C,E,C,A,C,
B,A,D,E,
A,B,A,D,
```

### Direct Return

| Alias Ordinal	| Type | <div table-width="35">Description</div> | <div table-width="23">Columns</div> |
| --------- | --- | ----------- | -------- |
| 0 | []perWalk | Array of UUIDs of visited nodes | `[_uuid, _uuid, ...]` |

```js
algo(random_walk_struc2vec).params({
  ids: ['J'],
  walk_length: 6,
  walk_num: 3,
  k: 4,
  stay_probability: 0.8
}) as walks
return walks
```

Results: <i>walks</i>

<table>
<tr><td>[10, 6, 3, 6]</td></tr>
<tr><td>[10, 7, 6, 5, 6, 5]</td></tr>
<tr><td>[10, 7, 10, 7, 6, 7]</td></tr>
</table>

### Stream Return

| Alias Ordinal	| Type | <div table-width="35">Description</div> | <div table-width="23">Columns</div> |
| --------- | --- | ----------- | -------- |
| 0 | []perWalk | Array of UUIDs of visited nodes | `[_uuid, _uuid, ...]` |

```js
algo(random_walk_struc2vec).params({
  ids: ['J'],
  walk_length: 6,
  walk_num: 30,
  k: 5,
  stay_probability: 0.7
}).stream() as walks
where size(walks) == 6
return walks
```

Results: <i>walks</i>

<table>
<tr><td>[10, 7, 6, 5, 3, 4]</td></tr>
<tr><td>[10, 7, 8, 7, 6, 5]</td></tr>
<tr><td>[10, 7, 6, 4, 6, 7]</td></tr>
