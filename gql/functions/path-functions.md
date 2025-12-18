# Path Functions

## Example Graph

The following examples run against this graph:

<div align=center drawio-diagram='17198' drawio-name="draw_e4339232f5454cf2ac26f62c1bc9a53a.jpg"><img src="https://img.ultipa.cn/draw/draw_e4339232f5454cf2ac26f62c1bc9a53a.jpg?v='1733306685458'"/></div>

## path_length()

Returns the number of edges in a path.

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
      <td colspan="3"><code>path_length(&lt;pathVar&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;pathVar&gt;</code></td>
      <td><code>PATH</code></td>
      <td>Path variable reference</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>UINT</code></td>
    </tr>
  </tbody>
</table>

```gql
MATCH p = ()->{1,3}()
RETURN p, PATH_LENGTH(p) AS length
```

Result:

| p | <div table-width="10">length</div> |
| -- | -- |
| <div align=center drawio-diagram='19668' drawio-name="draw_fefc93ef1d1245a39919bf2133d3cbd4.jpg"><img src="https://img.ultipa.cn/draw/draw_fefc93ef1d1245a39919bf2133d3cbd4.jpg?v='1733307011924'"/></div> | 2 |
| <div align=center drawio-diagram='19669' drawio-name="draw_24c0ac6993314eb99bac44e1e644c3e0.jpg"><img src="https://img.ultipa.cn/draw/draw_24c0ac6993314eb99bac44e1e644c3e0.jpg?v='1733306886856'"/></div> | 1 |
| <div align=center drawio-diagram='19670' drawio-name="draw_164ef437545f46259711092a3ec32443.jpg"><img src="https://img.ultipa.cn/draw/draw_164ef437545f46259711092a3ec32443.jpg?v='1733306931330'"/></div> | 1 |

## pedges()

Collects edges in a path into a list.

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
      <td colspan="3"><code>pedges(&lt;pathVar&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;pathVar&gt;</code></td>
      <td><code>PATH</code></td>
      <td>Path variable reference</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>LIST</code></td>
    </tr>
  </tbody>
</table>

```gql
MATCH p = ({_id: "P1"})-[]->{1,2}()
RETURN pedges(p)
```

Result:

| pedges(p) |
| -- |
| [{"from":"P1","to":"P2","uuid":"1","from_uuid":"8791028671650463745","to_uuid":"8718971077612535810","schema":"Cites","values":{"weight":2}}] |
| [{"from":"P1","to":"P2","uuid":"1","from_uuid":"8791028671650463745","to_uuid":"8718971077612535810","schema":"Cites","values":{"weight":2}},{"from":"P2","to":"P3","uuid":"2","from_uuid":"8718971077612535810","to_uuid":"12033620403357220867","schema":"Cites","values":{"weight":1}}] |

## pedgeUuids()

Collects the `_uuid` values of edges in a path into a list.

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
      <td colspan="3"><code>pedgeUuids(&lt;pathAlias&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;pathAlias&gt;</code></td>
      <td><code>PATH</code></td>
      <td>Path alias reference</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>LIST</code></td>
    </tr>
  </tbody>
</table>

```gql
MATCH p = ({_id: "P1"})-[]->{1,2}()
RETURN pedgeUuids(p)
```

Result:

| pedgeUuids(p) |
| -- |
| ["1"] |
| ["1","2"] |

## pnodes()

Collects nodes in a path into a list.

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
      <td colspan="3"><code>pnodes(&lt;pathVar&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;pathVar&gt;</code></td>
      <td><code>PATH</code></td>
      <td>Path variable reference</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>LIST</code></td>
    </tr>
  </tbody>
</table>

```gql
MATCH p = ({_id: "P1"})-[]->{1,2}()
RETURN pnodes(p)
```

Result:

| pnodes(p) |
| -- |
| [{"id":"P1","uuid":"8791028671650463745","schema":"Paper","values":{"author":"Alex","title":"Efficient Graph Search","score":6}},{"id":"P2","uuid":"8718971077612535810","schema":"Paper","values":{"author":"Alex","title":"Optimizing Queries","score":9}}] |
| [{"id":"P1","uuid":"8791028671650463745","schema":"Paper","values":{"author":"Alex","title":"Efficient Graph Search","score":6}},{"id":"P2","uuid":"8718971077612535810","schema":"Paper","values":{"author":"Alex","title":"Optimizing Queries","score":9}},{"id":"P3","uuid":"12033620403357220867","schema":"Paper","values":{"author":"Zack","title":"Path Patterns","score":7}}] |

## pnodeIds()

Collects the `_id` values of nodes in a path into a list.

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
      <td colspan="3"><code>pnodeIds(&lt;pathAlias&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;pathAlias&gt;</code></td>
      <td><code>PATH</code></td>
      <td>Path alias reference</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>LIST</code></td>
    </tr>
  </tbody>
</table>

```gql
MATCH p = ({_id: "P1"})-[]->{1,2}()
RETURN pnodeIds(p)
```

Result:

| pnodeIds(p) |
| -- |
| ["P1","P2"] |
| ["P1","P2","P3"] |
