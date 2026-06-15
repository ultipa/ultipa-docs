# Schema Management

The GQLDB Python driver provides convenience methods for managing labels, properties, constraints, indexes, and fulltext indexes. These methods require a graph to be selected via `use_graph()` or a `QueryConfig` with `graph_name`.

## Label Methods

| Method | Description |
|--------|-------------|
| `show_labels()` | List all labels (node and edge) |
| `show_node_labels()` | List node labels |
| `show_edge_labels()` | List edge labels |
| `show_node_types()` | List node types with properties (CLOSED graph) |
| `show_edge_types()` | List edge types with properties (CLOSED graph) |
| `get_node_label(name)` | Get a single node label |
| `get_edge_label(name)` | Get a single edge label |
| `create_node_label(name, props)` | Create a node label (CLOSED graph) |
| `create_edge_label(name, props)` | Create an edge label (CLOSED graph) |
| `drop_node_label(name)` | Drop a node label |
| `drop_edge_label(*names)` | Drop one or more edge labels |
| `create_label_if_not_exist(type, name, props)` | Create label if it doesn't exist |
| `alter_node_label(old_name, new_name)` | Rename a node label |
| `alter_edge_label(old_name, new_name)` | Rename an edge label |

## Listing Labels

```python
from gqldb import GqldbClient, GqldbConfig

client.use_graph("myGraph")

# All labels
labels = client.show_labels()
for label in labels:
    print(f"{label.labels} ({label.type})")

# Node labels only
node_labels = client.show_node_labels()

# Edge labels only
edge_labels = client.show_edge_labels()
```

## Listing Types (CLOSED Graph)

Show labels with their property definitions:

```python
# Node types with properties
node_types = client.show_node_types()
for nt in node_types:
    print(f"{nt.name}: {[p.name for p in nt.properties]}")

# Edge types with properties
edge_types = client.show_edge_types()
```

## Getting a Single Label

```python
# Returns None if not found
person_label = client.get_node_label("Person")
if person_label:
    print(f"Found: {person_label.name}")

knows_label = client.get_edge_label("KNOWS")
```

## Creating Labels

Create labels with property definitions (required for CLOSED graphs):

```python
from gqldb.types.convenience import ConvPropertyDef, DBType

# Create a node label with properties
client.create_node_label("Person", [
    ConvPropertyDef(name="name", type="STRING"),
    ConvPropertyDef(name="age", type="INT64"),
])

# Create an edge label
client.create_edge_label("KNOWS", [
    ConvPropertyDef(name="since", type="INT64"),
])

# Idempotent create — returns True if created, False if already existed
created = client.create_label_if_not_exist(DBType.NODE, "Person", [
    ConvPropertyDef(name="name", type="STRING"),
])
```

## Renaming Labels

```python
client.alter_node_label("OldName", "NewName")
client.alter_edge_label("OldEdge", "NewEdge")
```

## Dropping Labels

```python
client.drop_node_label("Person")
client.drop_edge_label("KNOWS", "LIKES")  # Multiple names
```

## Property Methods

| Method | Description |
|--------|-------------|
| `show_node_property(label_name)` | Show properties for a node label |
| `show_edge_property(label_name)` | Show properties for an edge label |
| `get_node_property(label_name, prop_name)` | Get a single property |
| `get_edge_property(label_name, prop_name)` | Get a single property |
| `create_node_property(label_name, props)` | Add properties to a node label |
| `create_edge_property(label_name, props)` | Add properties to an edge label |
| `drop_node_property(label_name, *prop_names)` | Drop properties from a node label |
| `drop_edge_property(label_name, *prop_names)` | Drop properties from an edge label |
| `create_property_if_not_exist(type, label_name, props)` | Add properties if they don't exist |

## Managing Properties

```python
# Show properties for a label
props = client.show_node_property("Person")
for p in props:
    print(f"  {p.name}: {p.type}")

# Get a single property (returns None if not found)
prop = client.get_node_property("Person", "name")

# Add properties
client.create_node_property("Person", [
    ConvPropertyDef(name="email", type="STRING"),
])

# Idempotent add — returns True if created
created = client.create_property_if_not_exist(DBType.NODE, "Person", [
    ConvPropertyDef(name="email", type="STRING"),
])

# Drop properties
client.drop_node_property("Person", "email")
client.drop_edge_property("KNOWS", "weight", "note")  # Multiple names
```

## Constraint Methods

| Method | Description |
|--------|-------------|
| `create_not_null_constraint(type, label_name, prop_name)` | Create a NOT NULL constraint |
| `drop_not_null_constraint(type, label_name, prop_name)` | Drop a NOT NULL constraint |
| `create_unique_constraint(type, label_name, *prop_names)` | Create a UNIQUE constraint |
| `drop_unique_constraint(type, label_name, *prop_names)` | Drop a UNIQUE constraint |

## Managing Constraints (CLOSED Graph)

```python
from gqldb.types.convenience import DBType

# NOT NULL
client.create_not_null_constraint(DBType.NODE, "Person", "name")
client.drop_not_null_constraint(DBType.NODE, "Person", "name")

# UNIQUE
client.create_unique_constraint(DBType.NODE, "Person", "email")
client.drop_unique_constraint(DBType.NODE, "Person", "email")
```

## Index Methods

| Method | Description |
|--------|-------------|
| `show_index()` | List all indexes |
| `show_node_index()` | List node indexes |
| `show_edge_index()` | List edge indexes |
| `create_node_index(index_name, label_name, props)` | Create a node index |
| `create_edge_index(index_name, label_name, props)` | Create an edge index |
| `drop_node_index(index_name)` | Drop a node index |
| `drop_edge_index(index_name)` | Drop an edge index |

## Managing Indexes

```python
from gqldb.types.convenience import IndexProperty

client.use_graph("myGraph")

# Show indexes
indexes = client.show_index()
for idx in indexes:
    print(f"{idx.index_name} on {idx.label}.{idx.property} ({idx.status})")

# Create index
client.create_node_index("idx_name", "Person", [IndexProperty(name="name")])

# Create index with prefix length (for string properties)
client.create_node_index("idx_prefix", "Person", [IndexProperty(name="name", prefix_length=10)])

client.create_edge_index("idx_since", "KNOWS", [IndexProperty(name="since")])

# Drop index
client.drop_node_index("idx_name")
client.drop_edge_index("idx_since")
```

## Fulltext Index Methods

| Method | Description |
|--------|-------------|
| `show_fulltext()` | List all fulltext indexes |
| `show_node_fulltext()` | List node fulltext indexes |
| `show_edge_fulltext()` | List edge fulltext indexes |
| `create_node_fulltext(index_name, label_name, props)` | Create a node fulltext index |
| `create_edge_fulltext(index_name, label_name, props)` | Create an edge fulltext index |
| `drop_node_fulltext(index_name)` | Drop a node fulltext index |
| `drop_edge_fulltext(index_name)` | Drop an edge fulltext index |

## Managing Fulltext Indexes

```python
client.use_graph("myGraph")

# Show fulltext indexes
fts = client.show_fulltext()
for ft in fts:
    print(f"{ft.index_name} on {ft.schema_name} ({ft.status})")

# Create fulltext index
client.create_node_fulltext("ft_name", "Person", ["name"])
client.create_edge_fulltext("ft_note", "KNOWS", ["note"])

# Drop fulltext index
client.drop_node_fulltext("ft_name")
client.drop_edge_fulltext("ft_note")
```

## Per-call Configuration

All schema management methods accept an optional `QueryConfig` for per-call graph targeting:

```python
from gqldb.client import QueryConfig

config = QueryConfig(graph_name="graphA")

# Target a specific graph without use_graph()
labels = client.show_node_labels(config=config)
client.create_node_label("User", props, config=config)
client.create_node_index("idx_name", "User", index_props, config=config)
```

## Special Character Handling

Label and property names containing special characters (spaces, hyphens, dots) are automatically wrapped in backticks:

```python
# These work with special characters
client.create_node_label("My Label", [...])        # → `My Label`
client.create_node_property("my-label", [...])     # → `my-label`
client.alter_node_label("my.old", "my.new")        # → `my.old` → `my.new`
```

> **Note:** Graph names, index names, and fulltext index names do **not** support special characters — only letters, digits, and underscores are allowed.

## Complete Example

```python
from gqldb import GqldbClient, GqldbConfig
from gqldb.types.convenience import ConvPropertyDef, DBType, IndexProperty
from gqldb.errors import GqldbError

def main():
    config = GqldbConfig(hosts=["localhost:9000"], timeout=30)

    with GqldbClient(config) as client:
        client.login("admin", "password")

        # Create a closed graph for schema management
        client.create_closed_graph("schemaDemo")
        client.use_graph("schemaDemo")

        # Create node labels with properties
        print("=== Creating Labels ===")
        client.create_node_label("Person", [
            ConvPropertyDef(name="name", type="STRING"),
            ConvPropertyDef(name="age", type="INT64"),
            ConvPropertyDef(name="email", type="STRING"),
        ])
        client.create_edge_label("KNOWS", [
            ConvPropertyDef(name="since", type="INT64"),
        ])
        print("Labels created")

        # Add constraints
        print("\n=== Adding Constraints ===")
        client.create_not_null_constraint(DBType.NODE, "Person", "name")
        client.create_unique_constraint(DBType.NODE, "Person", "email")
        print("Constraints added")

        # Create indexes
        print("\n=== Creating Indexes ===")
        client.create_node_index("idx_person_name", "Person", [IndexProperty(name="name")])
        client.create_node_fulltext("ft_person_name", "Person", ["name"])
        print("Indexes created")

        # Show schema
        print("\n=== Node Types ===")
        for nt in client.show_node_types():
            prop_names = [p.name for p in nt.properties]
            print(f"  {nt.name}: {', '.join(prop_names)}")

        print("\n=== Indexes ===")
        for idx in client.show_index():
            print(f"  {idx.index_name} on {idx.label}.{idx.property}")

        print("\n=== Fulltext Indexes ===")
        for ft in client.show_fulltext():
            print(f"  {ft.index_name} on {ft.schema_name}")

        # Add a property later
        print("\n=== Adding Property ===")
        client.create_node_property("Person", [
            ConvPropertyDef(name="phone", type="STRING"),
        ])

        # Verify
        person_props = client.show_node_property("Person")
        print(f"Person properties: {[p.name for p in person_props]}")

        # Clean up
        client.drop_graph("schemaDemo")
        print("\nDone")

if __name__ == "__main__":
    main()
```
