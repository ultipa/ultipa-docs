# Data Types

The GQLDB Python driver supports a comprehensive set of data types for storing and querying graph data. This guide covers property types, enums, and type conversions.

## Property Types

The `PropertyType` enum defines all supported data types:

```python
from gqldb.types import PropertyType
```

### Numeric Types

| Type | Description | Python Type |
|------|-------------|-------------|
| `INT32` | 32-bit signed integer | `int` |
| `UINT32` | 32-bit unsigned integer | `int` |
| `INT64` | 64-bit signed integer | `int` |
| `UINT64` | 64-bit unsigned integer | `int` |
| `FLOAT` | 32-bit floating point | `float` |
| `DOUBLE` | 64-bit floating point | `float` |
| `DECIMAL` | Arbitrary precision decimal | `GqldbDecimal` |

### String Types

| Type | Description | Python Type |
|------|-------------|-------------|
| `STRING` | Variable-length string | `str` |
| `TEXT` | Long text | `str` |

### Boolean and Null

| Type | Description | Python Type |
|------|-------------|-------------|
| `BOOL` | Boolean value | `bool` |
| `NULL` | Null value | `None` |
| `UNSET` | Unset/unknown type | `None` |

### Binary

| Type | Description | Python Type |
|------|-------------|-------------|
| `BLOB` | Binary data | `bytes` |

### Date and Time Types

| Type | Description | Python Type |
|------|-------------|-------------|
| `TIMESTAMP` | Unix timestamp with nanoseconds | `datetime` |
| `DATETIME` | Date and time (deprecated) | `datetime` |
| `DATE` | Date only | `date` |
| `LOCAL_DATETIME` | Local date and time | `GqldbLocalDateTime` |
| `ZONED_DATETIME` | Date and time with timezone | `GqldbZonedDateTime` |
| `LOCAL_TIME` | Local time of day | `GqldbLocalTime` |
| `ZONED_TIME` | Time with timezone | `GqldbZonedTime` |

### Duration Types

| Type | Description | Python Type |
|------|-------------|-------------|
| `YEAR_TO_MONTH` | Year-month duration | `YearToMonth` |
| `DAY_TO_SECOND` | Day-second duration | `DayToSecond` |

### Geospatial Types

| Type | Description | Python Type |
|------|-------------|-------------|
| `POINT` | 2D geographic point | `Point` |
| `POINT3D` | 3D point | `Point3D` |

### Collection Types

| Type | Description | Python Type |
|------|-------------|-------------|
| `LIST` | Ordered list | `list` |
| `SET` | Unordered unique set | `set` |
| `MAP` | Key-value map | `dict` |
| `VECTOR` | Numeric vector | `Vector` |

### Graph Types

| Type | Description | Python Type |
|------|-------------|-------------|
| `NODE` | Graph node | `GqldbNode` |
| `EDGE` | Graph edge | `GqldbEdge` |
| `PATH` | Graph path | `GqldbPath` |

## PropertyType Enum

```python
from gqldb.types import PropertyType

class PropertyType(IntEnum):
    UNSET = 0
    INT32 = 1
    UINT32 = 2
    INT64 = 3
    UINT64 = 4
    FLOAT = 5
    DOUBLE = 6
    STRING = 7
    DATETIME = 8  # Deprecated, use TIMESTAMP
    TIMESTAMP = 9
    TEXT = 10
    BLOB = 11
    POINT = 12
    DECIMAL = 13
    LIST = 14
    SET = 15
    MAP = 16
    NULL = 17
    BOOL = 18
    LOCAL_DATETIME = 19
    ZONED_DATETIME = 20
    DATE = 21
    ZONED_TIME = 22
    LOCAL_TIME = 23
    YEAR_TO_MONTH = 24
    DAY_TO_SECOND = 25
    RECORD = 26
    POINT3D = 27
    VECTOR = 28
    TABLE = 29
    PATH = 30
    ERROR = 31
    NODE = 32
    EDGE = 33
```

## GraphType Enum

```python
from gqldb.types import GraphType

class GraphType(IntEnum):
    OPEN = 0      # Schema-less graph
    CLOSED = 1    # Schema-enforced graph
    ONTOLOGY = 2  # Ontology-enabled graph
```

## HealthStatus Enum

```python
from gqldb.types import HealthStatus

class HealthStatus(IntEnum):
    UNKNOWN = 0
    SERVING = 1
    NOT_SERVING = 2
    SERVICE_UNKNOWN = 3
```

## CacheType Enum

```python
from gqldb.types import CacheType

class CacheType(IntEnum):
    ALL = 0
    AST = 1
    PLAN = 2
```

## Type Classes

### Node Types

```python
from gqldb.types import NodeData, GqldbNode

# Data for inserting nodes
@dataclass
class NodeData:
    labels: List[str]
    properties: Dict[str, Any]

# Internal node representation
@dataclass
class GqldbNode:
    id: str
    labels: List[str]
    properties: Dict[str, Any]
```

### Edge Types

```python
from gqldb.types import EdgeData, GqldbEdge

# Data for inserting edges
@dataclass
class EdgeData:
    label: str
    from_node_id: str
    to_node_id: str
    properties: Dict[str, Any]

# Internal edge representation
@dataclass
class GqldbEdge:
    id: str
    label: str
    from_node_id: str
    to_node_id: str
    properties: Dict[str, Any]
```

### Path Type

```python
from gqldb.types import GqldbPath

@dataclass
class GqldbPath:
    nodes: List[GqldbNode]
    edges: List[GqldbEdge]
```

### Geospatial Types

```python
from gqldb.types import Point, Point3D

@dataclass
class Point:
    latitude: float
    longitude: float

@dataclass
class Point3D:
    x: float
    y: float
    z: float
```

### Duration Types

```python
from gqldb.types import YearToMonth, DayToSecond

@dataclass
class YearToMonth:
    months: int

@dataclass
class DayToSecond:
    seconds: int
    nanoseconds: int
```

### Vector Type

```python
from gqldb.types import Vector

@dataclass
class Vector:
    values: List[float]
```

## TypedValue

The driver uses `TypedValue` internally for type-safe data transfer:

```python
from gqldb.types import TypedValue, PropertyType

# Get typed values from a row
row = response.first()
if row:
    for tv in row.values:
        print(f"Type: {tv.type}, Value: {tv.to_python()}")
```

## Type Wrapper Classes

For explicit type specification:

```python
from gqldb.types import Int32, UInt32, Float32, UInt64

# Wrap values with explicit types
node = NodeData(
    labels=["Test"],
    properties={
        "int32_val": Int32(42),
        "uint32_val": UInt32(100),
        "float32_val": Float32(3.14),
        "uint64_val": UInt64(9999999999)
    }
)
```

## Type Conversion Examples

### Working with Dates

```python
from datetime import date, datetime

# Insert with date
client.gql("""
    INSERT (e:Event {
        _id: 'e1',
        name: 'Conference',
        date: DATE('2024-06-15'),
        startTime: DATETIME('2024-06-15T09:00:00Z')
    })
""")

# Query and convert
response = client.gql("MATCH (e:Event) RETURN e.date, e.startTime")
row = response.first()
if row:
    event_date = row.get(0)
    start_time = row.get(1)
    print(f"Event date: {event_date}")
    print(f"Start time: {start_time}")
```

### Working with Points

```python
# Insert with location
client.gql("""
    INSERT (p:Place {
        _id: 'p1',
        name: 'Office',
        location: POINT(37.7749, -122.4194)
    })
""")

# Query and access point
response = client.gql("MATCH (p:Place) RETURN p.location")
row = response.first()
if row:
    location = row.get(0)
    if hasattr(location, 'latitude'):
        print(f"Lat: {location.latitude}, Lng: {location.longitude}")
```

### Working with Collections

```python
# Insert with list and map
client.gql("""
    INSERT (u:User {
        _id: 'u1',
        name: 'Alice',
        tags: ['developer', 'blogger'],
        metadata: {level: 5, premium: true}
    })
""")

# Query collections
response = client.gql("MATCH (u:User) RETURN u.tags, u.metadata")
row = response.first()
if row:
    tags = row.get(0)   # list
    metadata = row.get(1)  # dict
    print(f"Tags: {tags}")
    print(f"Metadata: {metadata}")
```

## Complete Example

```python
from gqldb import GqldbClient, GqldbConfig
from gqldb.types import PropertyType, NodeData
from gqldb.errors import GqldbError

def main():
    config = GqldbConfig(
        hosts=["localhost:60061"],
        timeout=30
    )

    with GqldbClient(config) as client:
        client.login("admin", "password")
        client.create_graph("typeDemo")
        client.use_graph("typeDemo")

        # Insert data with various types
        client.gql("""
            INSERT (u:User {
                _id: 'u1',
                name: 'Alice',
                age: 30,
                balance: 1234.56,
                active: true,
                joined: DATE('2023-01-15'),
                location: POINT(40.7128, -74.0060),
                tags: ['developer', 'mentor'],
                settings: {theme: 'dark', notifications: true}
            })
        """)

        # Query and check types
        response = client.gql("""
            MATCH (u:User {_id: 'u1'})
            RETURN u.name, u.age, u.balance, u.active, u.joined,
                   u.location, u.tags, u.settings
        """)

        row = response.first()
        if row:
            print(f"Name (str): {row.get_string(0)}")
            print(f"Age (int): {row.get_int(1)}")
            print(f"Balance (float): {row.get_float(2)}")
            print(f"Active (bool): {row.get_bool(3)}")
            print(f"Joined: {row.get(4)}")
            print(f"Location: {row.get(5)}")
            print(f"Tags: {row.get(6)}")
            print(f"Settings: {row.get(7)}")

            # Check property types
            print("\nProperty types:")
            for i, tv in enumerate(row.values):
                print(f"  Column {i}: {tv.type.name}")

        client.drop_graph("typeDemo")

if __name__ == "__main__":
    main()
```
