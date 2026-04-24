# Schema Management

The GQLDB Java driver provides convenience methods for managing labels, properties, constraints, indexes, and fulltext indexes. These methods require a graph to be selected via `useGraph()` or a `QueryConfig` with `graphName`.

## Label Methods

| Method | Description |
|--------|-------------|
| `showLabels()` | List all labels (node and edge) |
| `showNodeLabels()` | List node labels |
| `showEdgeLabels()` | List edge labels |
| `showNodeTypes()` | List node types with properties (CLOSED graph) |
| `showEdgeTypes()` | List edge types with properties (CLOSED graph) |
| `getNodeLabel(name)` | Get a single node label |
| `getEdgeLabel(name)` | Get a single edge label |
| `createNodeLabel(name, props)` | Create a node label (CLOSED graph) |
| `createEdgeLabel(name, props)` | Create an edge label (CLOSED graph) |
| `dropNodeLabel(name)` | Drop a node label |
| `dropEdgeLabel(names...)` | Drop one or more edge labels |
| `createLabelIfNotExist(type, name, props)` | Create label if it doesn't exist |
| `alterNodeLabel(oldName, newName)` | Rename a node label |
| `alterEdgeLabel(oldName, newName)` | Rename an edge label |

## Listing Labels

```java
import com.gqldb.*;
import com.gqldb.types.*;
import java.util.List;

client.useGraph("myGraph");

// All labels
List<LabelInfo> labels = client.showLabels();
for (LabelInfo label : labels) {
    System.out.println(label.getLabels() + " (" + label.getType() + ")");
}

// Node labels only
List<LabelInfo> nodeLabels = client.showNodeLabels();

// Edge labels only
List<LabelInfo> edgeLabels = client.showEdgeLabels();
```

## Listing Types (CLOSED Graph)

Show labels with their property definitions:

```java
// Node types with properties
List<NodeTypeInfo> nodeTypes = client.showNodeTypes();
for (NodeTypeInfo nt : nodeTypes) {
    System.out.print(nt.getName() + ": ");
    for (PropertyDef p : nt.getProperties()) {
        System.out.print(p.getName() + "(" + p.getType() + ") ");
    }
    System.out.println();
}

// Edge types with properties
List<EdgeTypeInfo> edgeTypes = client.showEdgeTypes();
```

## Getting a Single Label

```java
// Returns null if not found
NodeTypeInfo personLabel = client.getNodeLabel("Person");
if (personLabel != null) {
    System.out.println("Found: " + personLabel.getName());
}

EdgeTypeInfo knowsLabel = client.getEdgeLabel("KNOWS");
```

## Creating Labels

Create labels with property definitions (required for CLOSED graphs):

```java
import com.gqldb.types.*;
import java.util.*;

// Create a node label with properties
client.createNodeLabel("Person", Arrays.asList(
    new PropertyDef("name", PropertyType.STRING),
    new PropertyDef("age", PropertyType.INT64)
));

// Create an edge label
client.createEdgeLabel("KNOWS", Arrays.asList(
    new PropertyDef("since", PropertyType.INT64)
));

// Idempotent create — returns true if created, false if already existed
boolean created = client.createLabelIfNotExist(
    DBType.NODE, "Person",
    Arrays.asList(new PropertyDef("name", PropertyType.STRING))
);
```

## Renaming Labels

```java
client.alterNodeLabel("OldName", "NewName");
client.alterEdgeLabel("OldEdge", "NewEdge");
```

## Dropping Labels

```java
client.dropNodeLabel("Person");
client.dropEdgeLabel("KNOWS", "LIKES");  // Multiple names
```

## Property Methods

| Method | Description |
|--------|-------------|
| `showNodeProperty(labelName)` | Show properties for a node label |
| `showEdgeProperty(labelName)` | Show properties for an edge label |
| `getNodeProperty(labelName, propName)` | Get a single property |
| `getEdgeProperty(labelName, propName)` | Get a single property |
| `createNodeProperty(labelName, props)` | Add properties to a node label |
| `createEdgeProperty(labelName, props)` | Add properties to an edge label |
| `dropNodeProperty(labelName, propNames...)` | Drop properties from a node label |
| `dropEdgeProperty(labelName, propNames...)` | Drop properties from an edge label |
| `createPropertyIfNotExist(type, labelName, props)` | Add properties if they don't exist |

## Managing Properties

```java
// Show properties for a label
List<PropertyDef> props = client.showNodeProperty("Person");
for (PropertyDef p : props) {
    System.out.println("  " + p.getName() + ": " + p.getType());
}

// Get a single property (returns null if not found)
PropertyDef prop = client.getNodeProperty("Person", "name");

// Add properties
client.createNodeProperty("Person", Arrays.asList(
    new PropertyDef("email", PropertyType.STRING)
));

// Idempotent add — returns true if created
boolean created = client.createPropertyIfNotExist(
    DBType.NODE, "Person",
    Arrays.asList(new PropertyDef("email", PropertyType.STRING))
);

// Drop properties
client.dropNodeProperty("Person", "email");
client.dropEdgeProperty("KNOWS", "weight", "note");  // Multiple names
```

## Constraint Methods

| Method | Description |
|--------|-------------|
| `createNotNullConstraint(type, labelName, propName)` | Create a NOT NULL constraint |
| `dropNotNullConstraint(type, labelName, propName)` | Drop a NOT NULL constraint |
| `createUniqueConstraint(type, labelName, propNames...)` | Create a UNIQUE constraint |
| `dropUniqueConstraint(type, labelName, propNames...)` | Drop a UNIQUE constraint |

## Managing Constraints (CLOSED Graph)

```java
import com.gqldb.types.DBType;

// NOT NULL constraint
client.createNotNullConstraint(DBType.NODE, "Person", "name");
client.dropNotNullConstraint(DBType.NODE, "Person", "name");

// UNIQUE constraint
client.createUniqueConstraint(DBType.NODE, "Person", "email");
client.dropUniqueConstraint(DBType.NODE, "Person", "email");
```

## Index Methods

| Method | Description |
|--------|-------------|
| `showIndex()` | List all indexes |
| `showNodeIndex()` | List node indexes |
| `showEdgeIndex()` | List edge indexes |
| `createNodeIndex(indexName, labelName, props)` | Create a node index |
| `createEdgeIndex(indexName, labelName, props)` | Create an edge index |
| `dropNodeIndex(indexName)` | Drop a node index |
| `dropEdgeIndex(indexName)` | Drop an edge index |

## Managing Indexes

```java
import com.gqldb.types.*;
import java.util.*;

client.useGraph("myGraph");

// Show indexes
List<IndexInfo> indexes = client.showIndex();
for (IndexInfo idx : indexes) {
    System.out.println(idx.getIndexName() + " on " + idx.getLabel() + "." +
        idx.getProperty() + " (" + idx.getStatus() + ")");
}

// Create index
client.createNodeIndex("idx_name", "Person",
    Arrays.asList(new IndexProperty("name")));

// Create index with prefix length (for string properties)
client.createNodeIndex("idx_prefix", "Person",
    Arrays.asList(new IndexProperty("name", 10)));

client.createEdgeIndex("idx_since", "KNOWS",
    Arrays.asList(new IndexProperty("since")));

// Drop index
client.dropNodeIndex("idx_name");
client.dropEdgeIndex("idx_since");
```

## Fulltext Index Methods

| Method | Description |
|--------|-------------|
| `showFulltext()` | List all fulltext indexes |
| `showNodeFulltext()` | List node fulltext indexes |
| `showEdgeFulltext()` | List edge fulltext indexes |
| `createNodeFulltext(indexName, labelName, props)` | Create a node fulltext index |
| `createEdgeFulltext(indexName, labelName, props)` | Create an edge fulltext index |
| `dropNodeFulltext(indexName)` | Drop a node fulltext index |
| `dropEdgeFulltext(indexName)` | Drop an edge fulltext index |

## Managing Fulltext Indexes

```java
import com.gqldb.types.*;
import java.util.*;

client.useGraph("myGraph");

// Show fulltext indexes
List<FulltextInfo> ftIndexes = client.showFulltext();
for (FulltextInfo ft : ftIndexes) {
    System.out.println(ft.getIndexName() + " on " + ft.getSchemaName() +
        " (" + ft.getStatus() + ")");
}

// Create fulltext index
client.createNodeFulltext("ft_name", "Person", Arrays.asList("name"));
client.createEdgeFulltext("ft_note", "KNOWS", Arrays.asList("note"));

// Drop fulltext index
client.dropNodeFulltext("ft_name");
client.dropEdgeFulltext("ft_note");
```

## Per-call Configuration

All schema management methods accept an optional `QueryConfig` for per-call graph targeting:

```java
QueryConfig config = new QueryConfig();
config.setGraphName("graphA");

// Target a specific graph without useGraph()
List<LabelInfo> labels = client.showNodeLabels(config);
client.createNodeLabel("User", props, config);
client.createNodeIndex("idx_name", "User", indexProps, config);
```

## Special Character Handling

Label and property names containing special characters (spaces, hyphens, dots) are automatically wrapped in backticks:

```java
// These work with special characters
client.createNodeLabel("My Label", props);        // → `My Label`
client.createNodeProperty("my-label", newProps);   // → `my-label`
client.alterNodeLabel("my.old", "my.new");         // → `my.old` → `my.new`
```

> **Note:** Graph names, index names, and fulltext index names do **not** support special characters — only letters, digits, and underscores are allowed.

## Complete Example

```java
import com.gqldb.*;
import com.gqldb.types.*;
import java.util.*;

public class SchemaManagementExample {
    public static void main(String[] args) {
        GqldbConfig config = GqldbConfig.builder()
            .hosts("localhost:9000")
            .build();

        try (GqldbClient client = new GqldbClient(config)) {
            client.login("admin", "password");

            // Create a closed graph for schema management
            client.createClosedGraph("schemaDemo");
            client.useGraph("schemaDemo");

            // Create node labels with properties
            System.out.println("=== Creating Labels ===");
            client.createNodeLabel("Person", Arrays.asList(
                new PropertyDef("name", PropertyType.STRING),
                new PropertyDef("age", PropertyType.INT64),
                new PropertyDef("email", PropertyType.STRING)
            ));
            client.createEdgeLabel("KNOWS", Arrays.asList(
                new PropertyDef("since", PropertyType.INT64)
            ));
            System.out.println("Labels created");

            // Add constraints
            System.out.println("\n=== Adding Constraints ===");
            client.createNotNullConstraint(DBType.NODE, "Person", "name");
            client.createUniqueConstraint(DBType.NODE, "Person", "email");
            System.out.println("Constraints added");

            // Create indexes
            System.out.println("\n=== Creating Indexes ===");
            client.createNodeIndex("idx_person_name", "Person",
                Arrays.asList(new IndexProperty("name")));
            client.createNodeFulltext("ft_person_name", "Person",
                Arrays.asList("name"));
            System.out.println("Indexes created");

            // Show schema
            System.out.println("\n=== Node Types ===");
            for (NodeTypeInfo nt : client.showNodeTypes()) {
                System.out.println("  " + nt.getName() + ": " +
                    nt.getProperties().stream()
                        .map(p -> p.getName() + ":" + p.getType())
                        .reduce((a, b) -> a + ", " + b).orElse(""));
            }

            System.out.println("\n=== Indexes ===");
            for (IndexInfo idx : client.showIndex()) {
                System.out.println("  " + idx.getIndexName() + " on " +
                    idx.getLabel() + "." + idx.getProperty());
            }

            System.out.println("\n=== Fulltext Indexes ===");
            for (FulltextInfo ft : client.showFulltext()) {
                System.out.println("  " + ft.getIndexName() + " on " +
                    ft.getSchemaName());
            }

            // Add a property later
            System.out.println("\n=== Adding Property ===");
            client.createNodeProperty("Person", Arrays.asList(
                new PropertyDef("phone", PropertyType.STRING)
            ));

            // Verify
            List<PropertyDef> personProps = client.showNodeProperty("Person");
            System.out.println("Person properties: " +
                personProps.stream().map(PropertyDef::getName)
                    .reduce((a, b) -> a + ", " + b).orElse(""));

            // Clean up
            client.dropGraph("schemaDemo");
            System.out.println("\nDone");

        } catch (GqldbException e) {
            System.err.println("Error: " + e.getMessage());
        }
    }
}
```
