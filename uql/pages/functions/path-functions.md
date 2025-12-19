# Path Functions

# Example Graph

The following examples run against this graph:

<div align=center drawio-diagram='19665' drawio-name="draw_78ad73aa8ee943cd9d74a9070e7b16bd.jpg"><img src="https://img.ultipa.cn/draw/draw_78ad73aa8ee943cd9d74a9070e7b16bd.jpg?v='1733307122627'"/></div>

# length()

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
      <td colspan="3"><code>length(&lt;pathAlias&gt;)</code></td>
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
      <td colspan="3"><code>UINT</code></td>
    </tr>
  </tbody>
</table>

```uql
n().re()[1:3].n() as p
return p{*}, length(p) as length
```

Result:

| p | <div table-width="10">length</div> |
| -- | -- |
| <div align=center drawio-diagram='19671' drawio-name='draw_7c7046e5c7fb472bad3ef37dfd70bbef.jpg'><img src="https://img.ultipa.cn/draw/draw_7c7046e5c7fb472bad3ef37dfd70bbef.jpg?v='1733307262204'"/></div> | 2 |
| <div align=center drawio-diagram='19672' drawio-name='draw_72bce7923bba4049a55495596df4f51a.jpg'><img src="https://img.ultipa.cn/draw/draw_72bce7923bba4049a55495596df4f51a.jpg?v='1733307291276'"/></div> | 1 |
| <div align=center drawio-diagram='19673' drawio-name='draw_7d9cd1dfc5d84fc4b951a7566d7edc7f.jpg'><img src="https://img.ultipa.cn/draw/draw_7d9cd1dfc5d84fc4b951a7566d7edc7f.jpg?v='1733307307475'"/></div> | 1 |

# pedges()

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
      <td colspan="3"><code>pedges(&lt;pathAlias&gt;)</code></td>
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

```uql
n({_id == "P1"}).re()[1:2].n() as p
return pedges(p)
```

Result:

| pedges(p) |
| -- |
| [{"from":"P1","to":"P2","uuid":"1","from_uuid":"10448353334522806273","to_uuid":"3098478742654156802","schema":"Cites","values":{}}] |
| [{"from":"P1","to":"P2","uuid":"1","from_uuid":"10448353334522806273","to_uuid":"3098478742654156802","schema":"Cites","values":{}},{"from":"P2","to":"P3","uuid":"2","from_uuid":"3098478742654156802","to_uuid":"13618887472191635459","schema":"Cites","values":{}}] |

# pedgeUuids()

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

```uql
n({_id == "P1"}).re()[1:2].n() as p
return pedgeUuids(p)
```

Result:

| pedgeUuids(p) |
| -- |
| ["1"] |
| ["1","2"] |

# pnodes()

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
      <td colspan="3"><code>pnodes(&lt;pathAlias&gt;)</code></td>
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

```uql
n({_id == "P1"}).re()[1:2].n() as p
return pnodes(p)
```

Result:

| pnodes(p) |
| -- |
| [{"id":"P1","uuid":"10448353334522806273","schema":"Paper","values":{}},{"id":"P2","uuid":"3098478742654156802","schema":"Paper","values":{}}] |
| [{"id":"P1","uuid":"10448353334522806273","schema":"Paper","values":{}},{"id":"P2","uuid":"3098478742654156802","schema":"Paper","values":{}},{"id":"P3","uuid":"13618887472191635459","schema":"Paper","values":{}}] |

# pnodeIds()

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

```uql
n({_id == "P1"}).re()[1:2].n() as p
return pnodeIds(p)
```

Result:

| pnodeIds(p) |
| -- |
| ["P1","P2"] |
| ["P1","P2","P3"] |
