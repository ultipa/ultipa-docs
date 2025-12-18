## Scalar Functions

## Example Graph

The following examples run against this graph:

<div align=center drawio-diagram='17182' drawio-name="draw_4928406183014ae9a0cd90e4dd695714.jpg"><img src="https://www-test-data.oss-cn-hangzhou.aliyuncs.com/draw/draw_4928406183014ae9a0cd90e4dd695714.jpg?v='1751341566100'"/></div>

## cardinality()

Returns the cardinality of a path, a list, or a record.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:30%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>cardinality(&lt;expr&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;expr&gt;</code></td>
      <td><code>PATH</code>, <code>LIST</code>, <code>RECORD</code></td>
      <td>The input expression</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>UINT</code></td>
    </tr>
  </tbody>
</table>

```gql
MATCH p = ()->{1,3}()
RETURN p, cardinality(p)
```

Result:

<table>
  <thead>
    <tr>
      <th>p</th>
     <th style="width:18%;">cardinality(p)</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>
        <div align=center drawio-diagram='26004' drawio-name="draw_4d090610a19643a4b88e6cd01d5cdc90.jpg"><img src="https://www-test-data.oss-cn-hangzhou.aliyuncs.com/draw/draw_4d090610a19643a4b88e6cd01d5cdc90.jpg?v='1751341796105'"/></div>
      </td>
      <td>5</td>
    </tr>
    <tr>
      <td>
        <div align=center drawio-diagram='26005' drawio-name='draw_a15cd25983b244d299255411a74b7e3e.jpg'><img src="https://www-test-data.oss-cn-hangzhou.aliyuncs.com/draw/draw_a15cd25983b244d299255411a74b7e3e.jpg?v='1751341855081'"/></div>
      </td>
      <td>3</td>
    </tr>
    <tr>
      <td>
        <div align=center drawio-diagram='26006' drawio-name='draw_1cfb8e1482f24c9397bcaa3e3d1fecfc.jpg'><img src="https://www-test-data.oss-cn-hangzhou.aliyuncs.com/draw/draw_1cfb8e1482f24c9397bcaa3e3d1fecfc.jpg?v='1751341995968'"/></div>
      </td>
      <td>3</td>
    </tr>
  </tbody>
</table>

```gql
LET myList = [1, 2, null, 3]
RETURN cardinality(myList)
```

Result:

| cardinality(myList) |
| -- |
| 4 |

```gql
LET rec = RECORD{no: 1, value: "tennis"}
RETURN cardinality(rec)
```

Result:

| cardinality(rec) |
| -- |
| 2 |

## cast()

Specifies a data conversion.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
    <col>
    <col style="width:40%;">
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>cast(&lt;value&gt; AS &lt;type&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;value&gt;</code></td>
      <td>/</td>
      <td>Value expression</td>
    </tr>
    <tr>
      <td><code>&lt;type&gt;</code></td>
      <td>/</td>
      <td>A material value type</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3">As specified by <code>&lt;type&gt;</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN cast(1 AS String)
```

Result:

| cast(1 AS String) |
| -- |
| 1 |

## element_id()

Gets the unique identifier `_uuid` of a graph element.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:17%;">
    <col>
    <col style="width:40%;">
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>element_id(&lt;elemVar&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;elemVar&gt;</code></td>
      <td><code>NODE</code>, <code>EDGE</code></td>
      <td>Element variable reference</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>UINT64</code></td>
    </tr>
  </tbody>
</table>

```gql
MATCH (n)-[e]->()
RETURN element_id(n), element_id(e)
```

Result:

| element_id(n) | element_id(e) |
| -- | -- |
| 8718971077612535810 | 1 |
| 8791028671650463745 | 2 |

## labels()

Gets the label of a graph element.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:17%;">
    <col>
    <col style="width:40%;">
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>labels(&lt;elemVar&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;elemVar&gt;</code></td>
      <td><code>NODE</code>, <code>EDGE</code></td>
      <td>Element variable reference</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>STRING</code></td>
    </tr>
  </tbody>
</table>

```gql
MATCH (n)-[e]->()
RETURN labels(n), labels(e)
```

Result:

| labels(n) | labels(e) |
| -- | -- |
| Paper | Cites |
| Paper | Cites |
