# Element Functions

## Example Graph

<center><img src="images/paper-example.jpg"/></center>

```gql
INSERT (p1:Paper {_id:'P1', title:'Efficient Graph Search', score:6, author:'Alex'}),
       (p2:Paper {_id:'P2', title:'Optimizing Queries', score:9, author:'Alex'}),
       (p3:Paper {_id:'P3', title:'Path Patterns', score:7, author:'Zack'}),
       (p1)-[:Cites {weight:2}]->(p2),
       (p2)-[:Cites {weight:1}]->(p3)
```

## id()

Gets the unique identifier `_id` of a graph element. `element_id()` is a synonym.

> On an `EDGE_ID DISABLED` graph (see <a href="/docs/gql/node-and-edge-ids" target="_blank">Node and Edge IDs</a>) edges have no user-visible `_id`, so `id(e)` raises an error.

<table style="width: 100%;">
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>id(&lt;elemVar&gt;)</code> or <code>id(&lt;elemVar&gt;)</code></td>
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
RETURN id(n), id(e)
```

Result:

| id(n) | id(e) |
| -- | -- |
|	P2 | 52ade0a7-0247-4e68-bafb-32d2b2fbaa8b |
|	P1 | 22b49ab0-95ab-4591-bfd9-ff5cc5f9c633 |

## internal_id()

Returns the system-internal numeric identifier (the `_uuid`) of a node or edge as a decimal string. 

> Unlike `id()` which can error on edges in an `EDGE_ID DISABLED` graph, `internal_id()` **always resolves**. It's the function form of the built-in `_uuid` property and works on both `EDGE_ID`-enabled and disabled graphs.

<table style="width: 100%;">
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>internal_id(&lt;elemVar&gt;)</code></td>
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
      <td>Element variable reference.</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>STRING</code> — the `_uuid` formatted as a decimal string. Returned as a string because the underlying value is a 64-bit unsigned integer that can exceed the signed-int range.</td>
    </tr>
  </tbody>
</table>

```gql
MATCH (n)-[e]->()
RETURN internal_id(n), internal_id(e)
```

Result:

| internal_id(n) | internal_id(e) |
| -- | -- |
|	667260654663678695 | 2 |
|	667261754175306906 | 1 |

Equivalent property-form access:

```gql
MATCH (n)-[e]->()
RETURN n._uuid, e._uuid
```

## labels()

Gets the labels of a graph element.

<table style="width: 100%;">
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
      <td colspan="3"><code>LIST&lt;STRING&gt;</code></td>
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
| ["Paper"] | ["Cites"] |
| ["Paper"] | ["Cites"] |

## type()

Gets the label of an edge. Equivalent to `labels()` for edges.

<table style="width: 100%;">
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>type(&lt;edgeVar&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;edgeVar&gt;</code></td>
      <td><code>EDGE</code></td>
      <td>Edge variable reference</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>STRING</code></td>
    </tr>
  </tbody>
</table>

```gql
MATCH ()-[e]->()
RETURN type(e)
```

Result: 

| type(e) |
| -- |
| "Cites" |
| "Cites" |

## keys()

Returns the property names of a node, edge, or key names of a record.

<table style="width: 100%;">
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>keys(&lt;expr&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;expr&gt;</code></td>
      <td><code>NODE</code>, <code>EDGE</code>, <code>RECORD</code></td>
      <td>The input expression</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>LIST&lt;STRING&gt;</code></td>
    </tr>
  </tbody>
</table>

```gql
MATCH (n:Paper)
RETURN keys(n)
```

Result:

| keys(n) |
| -- |
| ["score", "author", "title"] |
| ["score", "author", "title"] |
| ["score", "author", "title"] |

```gql
LET myRecord = {x: 1, y: 3, z: 34}
RETURN keys(myRecord)
```

Result:

| keys(myRecord) |
| -- |
| ["x", "y", "z"] |

## values()

Returns the property values of a node, edge, or values of a record.

<table style="width: 100%;">
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>values(&lt;expr&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;expr&gt;</code></td>
      <td><code>NODE</code>, <code>EDGE</code>, <code>RECORD</code></td>
      <td>The input expression</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>LIST</code></td>
    </tr>
  </tbody>
</table>

```gql
LET myRecord = {x: 1, y: 3, z: 34}
RETURN values(myRecord)
```

Result:

| values(myRecord) |
| -- |
| [1, 3, 34] |

## properties()

Returns the properties of a node or edge as a record.

<table style="width: 100%;">
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>properties(&lt;elemVar&gt;)</code></td>
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
      <td colspan="3"><code>RECORD</code></td>
    </tr>
  </tbody>
</table>

```gql
MATCH (n:Paper)
RETURN properties(n)
```

Result:

| properties(n) |
| -- |
| {"score": 7, "author": "Zack", "title": "Path Patterns"} |
| {"score": 9, "author": "Alex", "title": "Optimizing Queries"} |
| {"score": 6, "author": "Alex", "title": "Efficient Graph Search"} |

## property_exists()

Checks whether a property exists on a node or edge.

<table style="width: 100%;">
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>property_exists(&lt;elemVar&gt;, &lt;propertyName&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
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
      <td><code>&lt;propertyName&gt;</code></td>
      <td><code>STRING</code></td>
      <td>The property name to check</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>BOOL</code></td>
    </tr>
  </tbody>
</table>

```gql
MATCH (n:Paper)
RETURN n._id, property_exists(n, "score"), property_exists(n, "rating")
```

Result:

| n.\_id | property_exists(n, "score") | property_exists(n, "rating") |
| -- | -- | -- |
| P1 | true | false |
| P2 | true | false |
| P3 | true | false |
