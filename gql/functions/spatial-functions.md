# Spatial Functions

## Example Graph

The following examples run against this graph:

<div align=center drawio-diagram='19689' drawio-name="draw_8af35576d1df48828c54ed4dbc548f28.jpg"><img src="https://img.ultipa.cn/draw/draw_8af35576d1df48828c54ed4dbc548f28.jpg?v='1759984566294'"/></div>

## distance()

Computes the straight-line distance between two points.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:20%;">
    <col style="width:30%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>distance(&lt;point1&gt;, &lt;point2&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;point1&gt;</code></td>
      <td><code>POINT</code> or <code>POINT3D</code></td>
      <td>The first point</td>
    </tr>
    <tr>
      <td><code>&lt;point2&gt;</code></td>
      <td><code>POINT</code> or <code>POINT3D</code></td>
      <td>The second point</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>DOUBLE</code></td>
    </tr>
  </tbody>
</table>

```gql
MATCH (n1:City {name: 'New York'})
MATCH (n2:City {name: 'London'})
RETURN distance(n1.location, n2.location)
```

Result: 

| distance(n1.location, n2.location) |
| -- |
| 5571177.78487926 |

## point()

Constructs a two-dimensional geographical coordinate. The `point()` function can be used to specify the value of a `point`-type property.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:20%;">
    <col style="width:20%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>point({latitude: &lt;lati&gt;, longitude: &lt;longti&gt;})</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;lati&gt;</code></td>
      <td>Numeric</td>
      <td>The latitude value</td>
    </tr>
    <tr>
      <td><code>&lt;longti&gt;</code></td>
      <td>Numeric</td>
      <td>The longitude value</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>POINT</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN point({latitude:39.9, longitude:116.3}) AS point
```

Result: 

| point |
| -- |
| POINT(39.9 116.3) |

```gql
INSERT (n:City {name: "Tokyo", location: point({latitude: 35.7, longitude: 139.7})})
RETURN n.location
```

Result: 

| n.location |
| -- |
| POINT(35.7 139.7) |

## point3d()

Constructs a three-dimensional Cartesian coordinate. The `point3d()` function can be used to specify the value of a `point3d`-type property.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:20%;">
    <col style="width:20%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>point3d({x: &lt;value_x&gt;, y: &lt;value_y&gt;, z: &lt;value_z&gt;})</code></td>
    </tr>
    <tr>
      <td rowspan="4"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;value_x&gt;</code></td>
      <td>Numeric</td>
      <td>The x value</td>
    </tr>
    <tr>
      <td><code>&lt;value_y&gt;</code></td>
      <td>Numeric</td>
      <td>The y value</td>
    </tr>
    <tr>
      <td><code>&lt;value_z&gt;</code></td>
      <td>Numeric</td>
      <td>The z value</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>POINT3D</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN point3d({x:10, y:15, z:5}) AS point3d
```

Result: 

| point3d |
| -- |
| POINT3D(10 15 5) |

```gql
INSERT (n:City {name: "Tokyo", landmark: point3d({x:10, y:15, z:5})})
RETURN n.landmark
```

Result: 

| n.landmark |
| -- |
| POINT3D(10 15 5) |

## pointget()

Extracts the coordinate values in the `point` or `point3d` property.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:23%;">
    <col style="width:13%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>point3get(&lt;propRef&gt;, &lt;coordName&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;propRef&gt;</code></td>
      <td>/</td>
      <td>Reference to a <code>point</code> or <code>point3d</code> type property</td>
    </tr>
    <tr>
      <td><code>&lt;coordName&gt;</code></td>
      <td>Textual</td>
      <td>Coordinate name; the <code>point</code> type is <code>latitude</code> or <code>longitude</code>, the <code>point3d</code> type is <code>x</code>, <code>y</code> or <code>z</code></td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>DOUBLE</code></td>
    </tr>
  </tbody>
</table>

```gql
MATCH (n {name: "New York"})
RETURN pointget(n.location, "latitude") AS latitude, pointget(n.landmark, "y") AS y
```

Result:

| latitude | y |
| -- | -- |
| 40.7 | 23 |
