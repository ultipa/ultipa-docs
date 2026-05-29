# Spatial Functions

## Example Graph

<center><img src="images/spatial-example.jpg"/></center>

```gql
INSERT (paris:City {name: "Paris", location: point(2.4, 48.9), landmark: point3d(100, 25.3, 652.1)}),
       (newYork:City {name: "New York", location: point(-74.0, 40.7), landmark: point3d(95, 23, 54)}),
       (london:City {name: "London", location: point(-0.13, 51.5), landmark: point3d(5.2, 66, 3.2)}),
       (newYork)-[:Connects]->(paris),
       (newYork)-[:Connects]->(london),
       (paris)-[:Connects]->(london)
```

## point()

Creates a two-dimensional geographical coordinate.
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
      <td colspan="3"><code>point(&lt;longitude&gt;, &lt;latitude&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;longitude&gt;</code></td>
      <td>Numeric</td>
      <td>The longitude value, ranging from <code>-180</code> to <code>180</code></td>
    </tr>
    <tr>
      <td><code>&lt;latitude&gt;</code></td>
      <td>Numeric</td>
      <td>The latitude value, ranging from <code>-90</code> to <code>90</code></td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>POINT</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN point(116.3, 39.9) AS point
```

Result:

```json
{
  "longitude": 116.3, "latitude": 39.9
}
```

## point3d()

Creates a three-dimensional Cartesian coordinate.

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
      <td colspan="3"><code>point3d(&lt;x&gt;, &lt;y&gt;, &lt;z&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="4"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;x&gt;</code></td>
      <td>Numeric</td>
      <td>The x coordinate</td>
    </tr>
    <tr>
      <td><code>&lt;y&gt;</code></td>
      <td>Numeric</td>
      <td>The y coordinate</td>
    </tr>
    <tr>
      <td><code>&lt;z&gt;</code></td>
      <td>Numeric</td>
      <td>The z coordinate</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>POINT3D</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN point3d(10, 15, 5) AS point3d
```

Result:

```json
{
  "x": 10, "y": 15, "z": 5
}
```

## distance()

Computes the distance between two points. For `POINT` values, it uses the Haversine formula to calculate the great-circle distance on Earth in kilometers. For `POINT3D` values, it computes the Euclidean distance.

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
      <td>The second point; must be the same type as <code>&lt;point1&gt;</code></td>
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

Result: 5570.833653336143

## point_get()

Extracts a coordinate value from a `POINT` or `POINT3D` value by index.

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
      <td colspan="3"><code>point_get(&lt;point&gt;, &lt;index&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;point&gt;</code></td>
      <td><code>POINT</code> or <code>POINT3D</code></td>
      <td>A point value</td>
    </tr>
    <tr>
      <td><code>&lt;index&gt;</code></td>
      <td><code>INT</code></td>
      <td>Coordinate index. For <code>POINT</code>: <code>0</code> = longitude, <code>1</code> = latitude. For <code>POINT3D</code>: <code>0</code> = x, <code>1</code> = y, <code>2</code> = z.</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>DOUBLE</code></td>
    </tr>
  </tbody>
</table>

```gql
MATCH (n {name: "New York"})
RETURN point_get(n.location, 0) AS longitude, point_get(n.location, 1) AS latitude
```

Result:

| longitude | latitude |
| -- | -- |
| -74.0 | 40.7 |
