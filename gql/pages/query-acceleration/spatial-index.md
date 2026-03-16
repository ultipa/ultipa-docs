# Spatial Index

## Overview

A spatial index enables efficient radius queries on `POINT` and `POINT3D` properties using geohash-based encoding. Instead of scanning all entities and computing distances, the spatial index narrows the search to a small set of candidates within the relevant geographic area.

Spatial indexes support:

- **POINT**: WGS84 geographic coordinates (latitude, longitude) for 2D spatial queries.
- **POINT3D**: 3D Cartesian coordinates (x, y, z) for 3D spatial queries.

## Showing Spatial Indexes

Spatial indexes appear in the standard index listing:

```gql
SHOW NODE INDEX
SHOW EDGE INDEX
```

Spatial indexes are displayed with type `SPATIAL` and the expression function `geohash`.

## Creating a Spatial Index

```gql
CREATE SPATIAL INDEX <indexName> ON NODE <schemaName> (<propertyName>)
CREATE SPATIAL INDEX <indexName> ON EDGE <schemaName> (<propertyName>)
```

The property must be of type `POINT` or `POINT3D`. Attempting to create a spatial index on other property types returns an error.

To create a spatial index on a `POINT` property:

```gql
CREATE SPATIAL INDEX idx_location ON NODE Station (location)
```

To create a spatial index on a `POINT3D` property:

```gql
CREATE SPATIAL INDEX idx_position ON NODE Sensor (position)
```

To create a spatial index on an edge property:

```gql
CREATE SPATIAL INDEX idx_route ON EDGE Route (waypoint)
```

### Using IF NOT EXISTS

```gql
CREATE SPATIAL INDEX idx_location ON NODE Station (location) IF NOT EXISTS
```

## Dropping a Spatial Index

```gql
DROP NODE SPATIAL INDEX idx_location
DROP EDGE SPATIAL INDEX idx_route
```

### Using IF EXISTS

```gql
DROP NODE SPATIAL INDEX idx_location IF EXISTS
DROP EDGE SPATIAL INDEX idx_route IF EXISTS
```

## Using Spatial Indexes

When a spatial index exists on a property, `distance()` queries with `<` or `<=` operators are automatically optimized to use spatial index range scans instead of full table scans.

### Optimized Query Patterns

Basic radius query:

```gql
MATCH (n:Station)
WHERE distance(n.location, point({latitude: 31.23, longitude: 121.47})) < 50000
RETURN n.name
```

Less-than-or-equal radius query:

```gql
MATCH (n:Station)
WHERE distance(n.location, point({latitude: 31.23, longitude: 121.47})) <= 50000
RETURN n.name
```

Reversed argument order (also optimized):

```gql
MATCH (n:Station)
WHERE distance(point({latitude: 31.23, longitude: 121.47}), n.location) < 50000
RETURN n.name
```

Combined with other conditions:

```gql
MATCH (n:Station)
WHERE distance(n.location, point({latitude: 31.23, longitude: 121.47})) < 50000
  AND n.name STARTS WITH 'S'
RETURN n.name
```

3D distance query:

```gql
MATCH (n:Sensor)
WHERE distance(n.position, point3d({x: 115.0, y: 215.0, z: 65.0})) < 20
RETURN n.name
```

Use `EXPLAIN` to verify that a spatial index is being used:

```gql
EXPLAIN MATCH (n:Station)
WHERE distance(n.location, point({latitude: 31.23, longitude: 121.47})) < 50000
RETURN n
```

The execution plan will show `SPATIAL INDEX SCAN` when the spatial index is used.

### Not Optimized

The following patterns do not use spatial indexes and result in a full scan:

- Greater-than comparisons: `distance(...) > 50000`
- Expressions that modify the distance: `distance(...) + 100 < 50000`

## DML Auto-Maintenance

Spatial indexes are automatically maintained when data changes:

| Operation | Behavior |
| -- | -- |
| `INSERT` | New geohash key added to the index. |
| `SET` | Old key removed, new key added. |
| `DELETE` | Key removed from the index. |
| `SET` to `NULL` | Old key removed from the index. |

Entities with `NULL` spatial properties are not indexed.
