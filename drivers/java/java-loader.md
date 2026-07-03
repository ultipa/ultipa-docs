# Loading Files

The GQLDB Java driver can trigger **server-side loading** of ontology schemas, RDF instance data, CSV files, and prefixes — the SDK wrappers around the GQL `LOAD ONTOLOGY` / `LOAD DATA` / `LOAD CSV` / `LOAD PREFIX` statements. See <a href="/docs/ontology/rdf-import-and-export" target="_blank">RDF Import & Export</a> for the underlying statements and RDF details.

Each loader comes in three forms:

- **`loadX(byte[] data, options)`** — load from an in-memory `byte[]` payload.
- **`loadXFile(String path, ...)`** — upload a **client-local file** to the server (chunked); the format is auto-detected from the extension.
- **`loadXFromSource(String source, options)`** — load a **server-reachable path or URL** (no upload) — the SDK equivalent of GQL `LOAD ... FROM '<server-path|url>'`.

This is distinct from [Bulk Import](/docs/drivers/java-bulk-import), which streams node/edge objects you build in code; here you point the server at a **file**.

Unlike the Python driver's keyword arguments, the Java methods take a mutable **options object** (`LoadOntologyOptions`, `LoadDataOptions`, `LoadCsvOptions`, `LoadPrefixOptions`) whose public fields you set before the call. The result POJOs and option/result types are nested under `com.gqldb.services.LoaderService` and expose camelCase getters (`getClasses()`, `getNodesCreated()`, …).

## Methods

| Method | Description |
|--------|-------------|
| `loadOntology` / `loadOntologyFile` / `loadOntologyFromSource` | Load an ontology **schema** (T-Box) |
| `loadData` / `loadDataFile` / `loadDataFromSource` | Load RDF **instance data** (A-Box) as nodes and edges |
| `loadCsv` / `loadCsvFile` | Load nodes or edges from a CSV file |
| `loadPrefix` | Register a single prefix, the standard set, or all prefixes from a source |
| `getLoaderCapabilities` | Query supported formats and limits |

> CSV has no `*FromSource` form — CSV is loaded from a `byte[]` payload (`loadCsv`) or a client-local file (`loadCsvFile`) only.

## Basic Usage

```java
import com.gqldb.*;
import com.gqldb.services.LoaderService;

public class LoaderQuickStart {
    public static void main(String[] args) {
        GqldbConfig config = GqldbConfig.builder()
            .hosts("localhost:9000")
            .build();

        try (GqldbClient client = new GqldbClient(config)) {
            client.login("admin", "password");
            client.useGraph("myGraph");

            // 1. Load an ontology schema (client-local file; format auto-detected from .ttl)
            LoaderService.LoadOntologyResult onto = client.loadOntologyFile("schema.ttl", "myGraph");
            System.out.println(onto.getClasses() + " classes, "
                + onto.getObjectProperties() + " object properties");

            // 2. Load RDF instance data
            LoaderService.LoadDataResult data = client.loadDataFile("instances.ttl", "myGraph");
            System.out.println(data.getNodesCreated() + " nodes, "
                + data.getEdgesCreated() + " edges");
        }
    }
}
```

## Loading Ontologies

```java
import com.gqldb.services.LoaderService;

// From a client-local file (format auto-detected from the extension)
LoaderService.LoadOntologyResult r1 = client.loadOntologyFile("schema.ttl", "myGraph");

// From a byte[] payload (set an explicit format)
LoaderService.LoadOntologyOptions opts = new LoaderService.LoadOntologyOptions();
opts.graphName = "myGraph";
opts.format = "TURTLE";
byte[] bytes = java.nio.file.Files.readAllBytes(java.nio.file.Paths.get("schema.ttl"));
LoaderService.LoadOntologyResult r2 = client.loadOntology(bytes, opts);

// From a server-reachable path or URL (no upload)
LoaderService.LoadOntologyOptions src = new LoaderService.LoadOntologyOptions();
LoaderService.LoadOntologyResult r3 =
    client.loadOntologyFromSource("https://xmlns.com/foaf/spec/index.rdf", src);
```

`loadOntologyFile` has two overloads: `loadOntologyFile(path, graphName)` (auto-detect format, target the given graph) and `loadOntologyFile(path, LoadOntologyOptions)` (auto-detect format only when `opts.format` is empty). The `loadOntology(byte[], ...)` and `loadOntologyFromSource(...)` forms take a `LoadOntologyOptions` and do **not** auto-detect — set `opts.format` yourself for `byte[]` payloads.

### LoadOntologyOptions Fields

```java
public static final class LoadOntologyOptions {
    public String graphName = "";       // empty => session's current graph
    public String format = "";          // OWL|RDFXML|TURTLE|NTRIPLES (empty => auto-detect by *File)
    public String baseIri = "";
    public boolean validateOnly = false;    // dry run: parse + validate, persist nothing
    public boolean continueOnError = false; // skip bad statements + record them
    public String parserVersion = "";        // pin a parser version; "" = server default
}
```

### LoadOntologyResult Getters

`getIri()`, `getClasses()`, `getObjectProperties()`, `getDataProperties()`, `getPrefixesRegistered()`, `getPrefixes()` (a `Map<String, String>`), `getWarnings()` (a `List<String>`), plus the fault-tolerance and cost getters described below.

## Loading Instance Data

```java
import com.gqldb.services.LoaderService;

LoaderService.LoadDataResult result = client.loadDataFile("instances.ttl", "myGraph");
System.out.println("created " + result.getNodesCreated() + " nodes, "
    + result.getEdgesCreated() + " edges");
```

Same three forms and options as ontology loading: `loadData(byte[], LoadDataOptions)`, `loadDataFile(path, graphName)` / `loadDataFile(path, LoadDataOptions)`, and `loadDataFromSource(source, LoadDataOptions)`.

### LoadDataOptions Fields

```java
public static final class LoadDataOptions {
    public String graphName = "";
    public String format = "";          // TURTLE|NTRIPLES|... (empty => auto-detect by *File)
    public String baseIri = "";
    public boolean validateOnly = false;
    public boolean continueOnError = false;
    public String parserVersion = "";
}
```

### LoadDataResult Getters

`getNodesCreated()`, `getEdgesCreated()`, `getPrefixesRegistered()`, `getPrefixes()`, `getWarnings()`, plus the fault-tolerance and cost getters below.

## Loading CSV

```java
import com.gqldb.services.LoaderService;
import java.util.Arrays;

// Nodes
LoaderService.LoadCsvOptions nodeOpts = new LoaderService.LoadCsvOptions();
nodeOpts.graphName = "myGraph";
nodeOpts.label = "Person";     // required
nodeOpts.withHeader = true;
nodeOpts.delimiter = ",";
LoaderService.LoadCsvResult nodes = client.loadCsvFile("people.csv", nodeOpts);

// Edges
LoaderService.LoadCsvOptions edgeOpts = new LoaderService.LoadCsvOptions();
edgeOpts.graphName = "myGraph";
edgeOpts.label = "knows";      // edge type
edgeOpts.edge = true;
edgeOpts.edgeFromCol = "from_id";
edgeOpts.edgeToCol = "to_id";
LoaderService.LoadCsvResult edges = client.loadCsvFile("knows.csv", edgeOpts);
System.out.println("imported " + edges.getImported() + ", skipped " + edges.getSkipped());
```

### LoadCsvOptions Fields

```java
public static final class LoadCsvOptions {
    public String graphName = "";
    public String label = "";                          // node label or edge type (required)
    public boolean edge = false;
    public String edgeFromCol = "";
    public String edgeToCol = "";
    public boolean withHeader = true;
    public String delimiter = ",";
    public String quote = "";
    public long skip = 0;
    public List<CsvColumnMapping> mapping = new ArrayList<>();
}
```

Supply per-column mappings by adding `CsvColumnMapping` entries to `opts.mapping`:

```java
LoaderService.LoadCsvOptions opts = new LoaderService.LoadCsvOptions();
opts.label = "Person";
opts.mapping.add(new LoaderService.CsvColumnMapping("name", "full_name", "STRING"));
opts.mapping.add(new LoaderService.CsvColumnMapping("age", "years", "INT"));
```

`CsvColumnMapping.type` ∈ `STRING` / `INT` / `FLOAT` / `BOOL` / `DATE` / `DATETIME` / `TIMESTAMP` / `ZONED_DATETIME` / `DURATION` / `DECIMAL` / `BYTES` / `POINT` / `POINT3D` / `TIME`.

### LoadCsvResult Getters

`getImported()`, `getSkipped()`, `isEdge()`, plus the cost getters below.

## Loading Prefixes

`loadPrefix` takes a single `LoadPrefixOptions`; which fields you set select the mode:

```java
import com.gqldb.services.LoaderService;

// A single prefix
LoaderService.LoadPrefixOptions single = new LoaderService.LoadPrefixOptions();
single.name = "foaf";
single.iri = "http://xmlns.com/foaf/0.1/";
client.loadPrefix(single);

// All standard prefixes (rdf, rdfs, owl, xsd, ...)
LoaderService.LoadPrefixOptions standard = new LoaderService.LoadPrefixOptions();
standard.allStandard = true;
client.loadPrefix(standard);

// All prefixes declared in a server-reachable document
LoaderService.LoadPrefixOptions fromDoc = new LoaderService.LoadPrefixOptions();
fromDoc.source = "https://xmlns.com/foaf/spec/index.rdf";
client.loadPrefix(fromDoc);
```

### LoadPrefixOptions Fields

```java
public static final class LoadPrefixOptions {
    public String graphName = "";
    public String name = "";
    public String iri = "";
    public boolean allStandard = false;
    public String source = "";
}
```

### LoadPrefixResult Getters

`getRegistered()`, `getUpdated()`, `getPrefixes()` (a `Map<String, String>`), `getTimeCostNs()`.

## Fault Tolerance

`loadOntology*` and `loadData*` honor fault-tolerance fields on their options object:

| Field | Meaning |
|--------|---------|
| `validateOnly = true` | Parse and report, but write nothing |
| `continueOnError = true` | Skip malformed triples instead of failing; collect them in `getErrors()` |
| `parserVersion = "..."` | Pin a specific parser version |

The result then reports `getParsed()`, `getFailed()`, `getSkipped()`, `getParserVersionUsed()`, and `getErrors()` (a `List<ParseError>`, each with `getLine()`, `getSnippet()`, `getReason()`):

```java
LoaderService.LoadDataOptions opts = new LoaderService.LoadDataOptions();
opts.graphName = "myGraph";
opts.continueOnError = true;
LoaderService.LoadDataResult result = client.loadDataFile("messy.ttl", opts);

System.out.println("parsed " + result.getParsed()
    + ", failed " + result.getFailed()
    + ", skipped " + result.getSkipped());
for (LoaderService.ParseError e : result.getErrors()) {
    System.out.println("line " + e.getLine() + ": " + e.getReason() + " — " + e.getSnippet());
}
```

> `loadDataFile(path, graphName)` uses default (strict) fault-tolerance. To enable `continueOnError` / `validateOnly` / `parserVersion`, use the `loadDataFile(path, LoadDataOptions)` overload (and likewise for ontologies).

## Format Auto-Detection

The `*File` methods detect the format from the file extension (used when `opts.format` is empty):

| Extension | Format |
|-----------|--------|
| `.ttl` | TURTLE |
| `.nt` | NTRIPLES |
| `.owl` / `.rdf` / `.xml` | RDFXML |
| `.nq` | NQUADS |
| `.trig` | TRIG |
| `.jsonld` | JSONLD |

Set `opts.format` explicitly for other extensions or for `byte[]` payloads. `LOAD ONTOLOGY` accepts OWL / RDFXML / TURTLE / NTRIPLES; `LOAD DATA` additionally accepts NQUADS / TRIG / JSONLD.

## Capabilities

```java
LoaderService.LoaderCapabilities caps = client.getLoaderCapabilities();
System.out.println(caps.getOntologyFormats());   // List<String>
System.out.println(caps.getDataFormats());        // List<String>
System.out.println(caps.getMaxUploadBytes());     // long
System.out.println(caps.isRemoteSourceEnabled()); // boolean
```

All load results also carry `getTimeCostNs()`, `getDiskCostNs()`, and `getComputeCostNs()` (`LoadPrefixResult` carries `getTimeCostNs()` only).
