# Loading Files

The GQLDB Go driver can trigger **server-side loading** of ontology schemas, RDF instance data, CSV files, and prefixes — the SDK wrappers around the GQL `LOAD ONTOLOGY` / `LOAD DATA` / `LOAD CSV` / `LOAD PREFIX` statements. See <a href="/docs/ontology/rdf-import-and-export" target="_blank">RDF Import & Export</a> for the underlying statements and RDF details.

Each loader comes in three forms:

- **`LoadX(ctx, r, opts)`** — load from an in-memory `io.Reader` or binary stream (bytes are chunked to the server).
- **`LoadXFile(ctx, path, opts)`** — upload a **client-local file** to the server (chunked); the format is auto-detected from the extension.
- **`LoadXFromSource(ctx, source, opts)`** — load a **server-reachable path or URL** (no upload) — the SDK equivalent of GQL `LOAD ... FROM '<server-path|url>'`.

This is distinct from [Bulk Import](/docs/drivers/go-bulk-import), which streams node/edge objects you build in code; here you point the server at a **file**.

Every loader method takes a `context.Context` first argument and a per-call options **struct** (passed by value, `{}` for defaults). Results are returned as `*LoadXResult` alongside an `error`.

## Methods

| Method | Description |
|--------|-------------|
| `LoadOntology` / `LoadOntologyFile` / `LoadOntologyFromSource` | Load an ontology **schema** (T-Box) |
| `LoadData` / `LoadDataFile` / `LoadDataFromSource` | Load RDF **instance data** (A-Box) as nodes and edges |
| `LoadCsv` / `LoadCsvFile` | Load nodes or edges from a CSV file |
| `LoadPrefix` | Register a single prefix, the standard set, or all prefixes from a source |
| `GetLoaderCapabilities` | Query supported formats and limits |

CSV and prefix loaders have no `FromSource` variant: CSV is client-upload or stream only, and `LoadPrefix` takes a `Source` URL directly in its options.

## Basic Usage

```go
import (
    "context"

    gqldb "github.com/ultipa/ultipa-go-driver/v6"
)

ctx := context.Background()
client.Login(ctx, "admin", "password")
client.UseGraph(ctx, "myGraph")

// 1. Load an ontology schema (client-local file; format auto-detected from .ttl)
onto, err := client.LoadOntologyFile(ctx, "schema.ttl", gqldb.LoadOntologyOptions{})
if err != nil {
    log.Fatal(err)
}
fmt.Printf("%d classes, %d object properties\n", onto.Classes, onto.ObjectProperties)

// 2. Load RDF instance data
data, err := client.LoadDataFile(ctx, "instances.ttl", gqldb.LoadDataOptions{})
if err != nil {
    log.Fatal(err)
}
fmt.Printf("%d nodes, %d edges\n", data.NodesCreated, data.EdgesCreated)
```

## Loading Ontologies

```go
// From a client-local file (format auto-detected from the extension)
result, err := client.LoadOntologyFile(ctx, "schema.ttl", gqldb.LoadOntologyOptions{
    GraphName: "myGraph",
})

// From an io.Reader / stream (pass an explicit format)
f, _ := os.Open("schema.ttl")
defer f.Close()
result, err = client.LoadOntology(ctx, f, gqldb.LoadOntologyOptions{Format: "TURTLE"})

// From a server-reachable path or URL (no upload)
result, err = client.LoadOntologyFromSource(ctx, "https://xmlns.com/foaf/spec/index.rdf", gqldb.LoadOntologyOptions{})
```

### LoadOntologyOptions

```go
type LoadOntologyOptions struct {
    GraphName string // optional; falls back to the session's current graph
    Format    string // OWL|RDFXML|TURTLE|NTRIPLES — required for stream loads (auto-detected by *File)
    BaseIRI   string // optional: base IRI for resolving relative IRIs
    // Fault tolerance (see below)
    ValidateOnly    bool
    ContinueOnError bool
    ParserVersion   string
}
```

### LoadOntologyResult

```go
type LoadOntologyResult struct {
    IRI                string
    Classes            int64
    ObjectProperties   int64
    DataProperties     int64
    PrefixesRegistered int64
    Prefixes           map[string]string
    Warnings           []string
    // Fault-tolerance accounting
    Parsed            int64
    Failed            int64
    Skipped           int64
    ParserVersionUsed string
    Errors            []ParseError
    // Cost
    TimeCostNs    int64
    DiskCostNs    int64
    ComputeCostNs int64
}
```

## Loading Instance Data

```go
result, err := client.LoadDataFile(ctx, "instances.ttl", gqldb.LoadDataOptions{})
if err != nil {
    log.Fatal(err)
}
fmt.Printf("created %d nodes, %d edges\n", result.NodesCreated, result.EdgesCreated)
```

Same three forms (`LoadData` / `LoadDataFile` / `LoadDataFromSource`) and options as the ontology loader.

### LoadDataOptions

```go
type LoadDataOptions struct {
    GraphName string // optional; falls back to the session's current graph
    Format    string // TURTLE|NTRIPLES — required for stream loads (auto-detected by *File)
    BaseIRI   string
    // Fault tolerance
    ValidateOnly    bool
    ContinueOnError bool
    ParserVersion   string
}
```

### LoadDataResult

```go
type LoadDataResult struct {
    NodesCreated       int64
    EdgesCreated       int64
    PrefixesRegistered int64
    Prefixes           map[string]string
    Warnings           []string
    // Fault-tolerance accounting
    Parsed            int64
    Failed            int64
    Skipped           int64
    ParserVersionUsed string
    Errors            []ParseError
    // Cost
    TimeCostNs    int64
    DiskCostNs    int64
    ComputeCostNs int64
}
```

## Loading CSV

```go
// Nodes
result, err := client.LoadCsvFile(ctx, "people.csv", gqldb.LoadCsvOptions{
    Label:      "Person",
    WithHeader: true,
    Delimiter:  ",",
})

// Edges
result, err = client.LoadCsvFile(ctx, "knows.csv", gqldb.LoadCsvOptions{
    Label:       "knows",
    Edge:        true,
    EdgeFromCol: "from_id",
    EdgeToCol:   "to_id",
})
if err != nil {
    log.Fatal(err)
}
fmt.Printf("imported %d, skipped %d\n", result.Imported, result.Skipped)
```

### LoadCsvOptions

```go
type LoadCsvOptions struct {
    GraphName   string             // optional; falls back to the session's current graph
    Label       string             // required: node label or edge type
    Edge        bool               // import as edges (requires EDGE_ID enabled)
    EdgeFromCol string             // edge import: CSV column holding source node _id
    EdgeToCol   string             // edge import: CSV column holding target node _id
    WithHeader  bool               // first row holds column names
    Delimiter   string             // default ","
    Quote       string             // accepted for compatibility
    Skip        int64              // leading rows to discard
    Mapping     []CsvColumnMapping // explicit property↔column bindings; empty = auto by header
}

type CsvColumnMapping struct {
    Property string
    Column   string
    Type     string // "" | STRING | INT | FLOAT | BOOL | DATE | DATETIME | TIMESTAMP |
                     // ZONED_DATETIME | DURATION | DECIMAL | BYTES | POINT | POINT3D | TIME
}
```

`Mapping` overrides header auto-binding, e.g.:

```go
result, err := client.LoadCsvFile(ctx, "people.csv", gqldb.LoadCsvOptions{
    Label:      "Person",
    WithHeader: true,
    Mapping: []gqldb.CsvColumnMapping{
        {Property: "name", Column: "full_name", Type: "STRING"},
        {Property: "age", Column: "years", Type: "INT"},
    },
})
```

### LoadCsvResult

```go
type LoadCsvResult struct {
    Imported      int64
    Skipped       int64
    IsEdge        bool
    TimeCostNs    int64
    DiskCostNs    int64
    ComputeCostNs int64
}
```

## Loading Prefixes

`LoadPrefix` is a single unary call; select the mode via `LoadPrefixOptions` (a single `Name`+`IRI`, the built-in `AllStandard` set, or every prefix declared at a `Source` URL).

```go
// A single prefix
client.LoadPrefix(ctx, gqldb.LoadPrefixOptions{
    Name: "foaf",
    IRI:  "http://xmlns.com/foaf/0.1/",
})

// All standard prefixes (rdf, rdfs, owl, xsd, ...)
client.LoadPrefix(ctx, gqldb.LoadPrefixOptions{AllStandard: true})

// All prefixes declared in a server-reachable document
client.LoadPrefix(ctx, gqldb.LoadPrefixOptions{Source: "https://xmlns.com/foaf/spec/index.rdf"})
```

### LoadPrefixOptions / LoadPrefixResult

```go
type LoadPrefixOptions struct {
    GraphName   string
    Name        string
    IRI         string
    AllStandard bool
    Source      string
}

type LoadPrefixResult struct {
    Registered int64
    Updated    int64
    Prefixes   map[string]string
    TimeCostNs int64
}
```

## Fault Tolerance

`LoadOntology*` and `LoadData*` accept fault-tolerance fields on their options structs:

| Field | Meaning |
|--------|---------|
| `ValidateOnly: true` | Parse and report, but write nothing |
| `ContinueOnError: true` | Skip malformed statements instead of failing; collect them in `Errors` |
| `ParserVersion: "..."` | Pin a specific parser version (`""` = server default/stable) |

The result then reports `Parsed`, `Failed`, `Skipped`, `ParserVersionUsed`, and `Errors` (a slice of `ParseError`):

```go
type ParseError struct {
    Line    int64
    Snippet string
    Reason  string
}
```

```go
result, err := client.LoadDataFile(ctx, "messy.ttl", gqldb.LoadDataOptions{ContinueOnError: true})
if err != nil {
    log.Fatal(err)
}
fmt.Printf("parsed %d, failed %d, skipped %d\n", result.Parsed, result.Failed, result.Skipped)
for _, e := range result.Errors {
    fmt.Printf("line %d: %s — %s\n", e.Line, e.Reason, e.Snippet)
}
```

> These fields are honored by servers ≥ `b37ae12`; older servers ignore them and leave the accounting fields zero/empty.

## Format Auto-Detection

The `*File` methods detect the format from the file extension (when `Format` is empty):

| Extension | Format |
|-----------|--------|
| `.ttl` | TURTLE |
| `.nt` | NTRIPLES |
| `.owl` / `.rdf` / `.xml` | RDFXML |
| `.nq` | NQUADS |
| `.trig` | TRIG |
| `.jsonld` | JSONLD |

Set `Format` explicitly for other extensions or for stream (`io.Reader`) loads. `LOAD ONTOLOGY` accepts OWL / RDFXML / TURTLE / NTRIPLES; `LOAD DATA` additionally accepts NQUADS / TRIG / JSONLD.

## Capabilities

```go
caps, err := client.GetLoaderCapabilities(ctx)
if err != nil {
    log.Fatal(err)
}
fmt.Println(caps.OntologyFormats, caps.DataFormats, caps.MaxUploadBytes, caps.RemoteSourceEnabled)
```

### LoaderCapabilities

```go
type LoaderCapabilities struct {
    OntologyFormats     []string
    DataFormats         []string
    MaxUploadBytes      int64
    RemoteSourceEnabled bool
}
```

All load results also carry `TimeCostNs`, `DiskCostNs`, and `ComputeCostNs`.

## Complete Example

```go
package main

import (
    "context"
    "fmt"
    "log"
    "time"

    gqldb "github.com/ultipa/ultipa-go-driver/v6"
)

func main() {
    config := gqldb.NewConfigBuilder().
        Hosts("localhost:9000").
        Timeout(5 * time.Minute).
        Build()

    client, err := gqldb.NewClient(config)
    if err != nil {
        log.Fatal(err)
    }
    defer client.Close()

    ctx := context.Background()
    client.Login(ctx, "admin", "password")

    // Schema before data: create an ontology-enabled graph
    client.CreateGraph(ctx, "loaderDemo", gqldb.GraphTypeOntology, "")
    client.UseGraph(ctx, "loaderDemo")

    // 1. Load the ontology schema (T-Box)
    fmt.Println("=== Loading Ontology ===")
    onto, err := client.LoadOntologyFile(ctx, "schema.ttl", gqldb.LoadOntologyOptions{
        GraphName: "loaderDemo",
    })
    if err != nil {
        log.Fatal(err)
    }
    fmt.Printf("  %d classes, %d object props, %d data props\n",
        onto.Classes, onto.ObjectProperties, onto.DataProperties)

    // 2. Load RDF instance data (A-Box), tolerating malformed statements
    fmt.Println("\n=== Loading Instance Data ===")
    data, err := client.LoadDataFile(ctx, "instances.ttl", gqldb.LoadDataOptions{
        GraphName:       "loaderDemo",
        ContinueOnError: true,
    })
    if err != nil {
        log.Fatal(err)
    }
    fmt.Printf("  %d nodes, %d edges (parsed %d, failed %d)\n",
        data.NodesCreated, data.EdgesCreated, data.Parsed, data.Failed)
    for _, e := range data.Errors {
        fmt.Printf("  skipped line %d: %s\n", e.Line, e.Reason)
    }

    // 3. Import supplementary rows from CSV
    fmt.Println("\n=== Loading CSV ===")
    csv, err := client.LoadCsvFile(ctx, "people.csv", gqldb.LoadCsvOptions{
        GraphName:  "loaderDemo",
        Label:      "Person",
        WithHeader: true,
    })
    if err != nil {
        log.Fatal(err)
    }
    fmt.Printf("  imported %d, skipped %d\n", csv.Imported, csv.Skipped)

    // Verify
    response, _ := client.Gql(ctx, "MATCH (n) RETURN count(n)", nil)
    nodeCount, _ := response.SingleInt()
    fmt.Printf("\n  Total nodes: %d\n", nodeCount)

    // Cleanup
    client.DropGraph(ctx, "loaderDemo", true)
}
```
