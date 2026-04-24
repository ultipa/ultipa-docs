# Schema Management

The GQLDB Go driver provides convenience methods for managing labels, properties, constraints, indexes, and fulltext indexes. These methods require a graph to be selected via `UseGraph()` or a `*QueryConfig` with `GraphName`.

## Label Methods

| Method | Description |
|--------|-------------|
| `ShowLabels(ctx, config)` | List all labels (node and edge) |
| `ShowNodeLabels(ctx, config)` | List node labels |
| `ShowEdgeLabels(ctx, config)` | List edge labels |
| `ShowNodeTypes(ctx, config)` | List node types with properties (CLOSED graph) |
| `ShowEdgeTypes(ctx, config)` | List edge types with properties (CLOSED graph) |
| `GetNodeLabel(ctx, name, config)` | Get a single node label |
| `GetEdgeLabel(ctx, name, config)` | Get a single edge label |
| `CreateNodeLabel(ctx, name, props, config)` | Create a node label |
| `CreateEdgeLabel(ctx, name, props, config)` | Create an edge label |
| `DropNodeLabel(ctx, name, config)` | Drop a node label |
| `DropEdgeLabel(ctx, config, names...)` | Drop one or more edge labels |
| `CreateLabelIfNotExist(ctx, dbType, name, props, config)` | Create label if it doesn't exist |
| `AlterNodeLabel(ctx, oldName, newName, config)` | Rename a node label |
| `AlterEdgeLabel(ctx, oldName, newName, config)` | Rename an edge label |

## Listing Labels

```go
client.UseGraph(ctx, "myGraph")

// All labels
labels, err := client.ShowLabels(ctx, nil)
for _, label := range labels {
    fmt.Printf("%v (%s)\n", label.Labels, label.Type)
}

// Node labels only
nodeLabels, err := client.ShowNodeLabels(ctx, nil)

// Edge labels only
edgeLabels, err := client.ShowEdgeLabels(ctx, nil)
```

## Listing Types (CLOSED Graph)

```go
nodeTypes, err := client.ShowNodeTypes(ctx, nil)
for _, nt := range nodeTypes {
    fmt.Printf("%s: ", nt.Name)
    for _, p := range nt.Properties {
        fmt.Printf("%s(%s) ", p.Name, p.Type)
    }
    fmt.Println()
}
```

## Creating Labels

```go
// Create a node label with properties
_, err := client.CreateNodeLabel(ctx, "Person", []gqldb.PropertyDef{
    {Name: "name", Type: gqldb.PropertyTypeString},
    {Name: "age", Type: gqldb.PropertyTypeInt64},
}, nil)

// Create an edge label
_, err = client.CreateEdgeLabel(ctx, "KNOWS", []gqldb.PropertyDef{
    {Name: "since", Type: gqldb.PropertyTypeInt64},
}, nil)

// Idempotent create
created, err := client.CreateLabelIfNotExist(ctx, gqldb.DBTypeNode, "Person", props, nil)
// true = created, false = already existed
```

## Renaming / Dropping Labels

```go
client.AlterNodeLabel(ctx, "OldName", "NewName", nil)
client.DropNodeLabel(ctx, "Person", nil)
client.DropEdgeLabel(ctx, nil, "KNOWS", "LIKES")
```

## Property Methods

| Method | Description |
|--------|-------------|
| `ShowNodeProperty(ctx, labelName, config)` | Show properties for a node label |
| `ShowEdgeProperty(ctx, labelName, config)` | Show properties for an edge label |
| `GetNodeProperty(ctx, labelName, propName, config)` | Get a single property |
| `CreateNodeProperty(ctx, labelName, props, config)` | Add properties to a node label |
| `DropNodeProperty(ctx, labelName, config, propNames...)` | Drop properties |
| `CreatePropertyIfNotExist(ctx, dbType, labelName, props, config)` | Add if not exist |

## Managing Properties

```go
// Show
props, err := client.ShowNodeProperty(ctx, "Person", nil)

// Add
_, err = client.CreateNodeProperty(ctx, "Person", []gqldb.PropertyDef{
    {Name: "email", Type: gqldb.PropertyTypeString},
}, nil)

// Drop
_, err = client.DropNodeProperty(ctx, "Person", nil, "email")
```

## Constraint Methods

| Method | Description |
|--------|-------------|
| `CreateNotNullConstraint(ctx, dbType, labelName, propName, config)` | Create NOT NULL |
| `DropNotNullConstraint(ctx, dbType, labelName, propName, config)` | Drop NOT NULL |
| `CreateUniqueConstraint(ctx, dbType, labelName, config, propNames...)` | Create UNIQUE |
| `DropUniqueConstraint(ctx, dbType, labelName, config, propNames...)` | Drop UNIQUE |

## Managing Constraints

```go
client.CreateNotNullConstraint(ctx, gqldb.DBTypeNode, "Person", "name", nil)
client.CreateUniqueConstraint(ctx, gqldb.DBTypeNode, "Person", nil, "email")
client.DropNotNullConstraint(ctx, gqldb.DBTypeNode, "Person", "name", nil)
client.DropUniqueConstraint(ctx, gqldb.DBTypeNode, "Person", nil, "email")
```

## Index Methods

| Method | Description |
|--------|-------------|
| `ShowIndex(ctx, config)` | List all indexes |
| `ShowNodeIndex(ctx, config)` | List node indexes |
| `ShowEdgeIndex(ctx, config)` | List edge indexes |
| `CreateNodeIndex(ctx, indexName, labelName, props, config)` | Create a node index |
| `CreateEdgeIndex(ctx, indexName, labelName, props, config)` | Create an edge index |
| `DropNodeIndex(ctx, indexName, config)` | Drop a node index |
| `DropEdgeIndex(ctx, indexName, config)` | Drop an edge index |

## Managing Indexes

```go
// Show
indexes, err := client.ShowIndex(ctx, nil)

// Create
_, err = client.CreateNodeIndex(ctx, "idx_name", "Person",
    []gqldb.IndexProperty{{Name: "name"}}, nil)

// With prefix length
_, err = client.CreateNodeIndex(ctx, "idx_prefix", "Person",
    []gqldb.IndexProperty{{Name: "name", PrefixLength: 10}}, nil)

// Drop
_, err = client.DropNodeIndex(ctx, "idx_name", nil)
```

## Fulltext Index Methods

| Method | Description |
|--------|-------------|
| `ShowFulltext(ctx, config)` | List all fulltext indexes |
| `CreateNodeFulltext(ctx, indexName, labelName, props, config)` | Create node fulltext |
| `CreateEdgeFulltext(ctx, indexName, labelName, props, config)` | Create edge fulltext |
| `DropNodeFulltext(ctx, indexName, config)` | Drop node fulltext |
| `DropEdgeFulltext(ctx, indexName, config)` | Drop edge fulltext |

## Managing Fulltext Indexes

```go
// Show
fts, err := client.ShowFulltext(ctx, nil)

// Create
_, err = client.CreateNodeFulltext(ctx, "ft_name", "Person", []string{"name"}, nil)

// Drop
_, err = client.DropNodeFulltext(ctx, "ft_name", nil)
```

## Per-call Configuration

All methods accept an optional `*QueryConfig` for per-call graph targeting:

```go
qc := &gqldb.QueryConfig{GraphName: "graphA"}
labels, err := client.ShowNodeLabels(ctx, qc)
```

## Special Character Handling

Label and property names with special characters (spaces, hyphens, dots) are automatically wrapped in backticks by the SDK.

> **Note:** Graph names, index names, and fulltext index names do **not** support special characters.
