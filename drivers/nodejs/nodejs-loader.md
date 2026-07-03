# Loading Files

The GQLDB Node.js driver can trigger **server-side loading** of ontology schemas, RDF instance data, CSV files, and prefixes — the SDK wrappers around the GQL `LOAD ONTOLOGY` / `LOAD DATA` / `LOAD CSV` / `LOAD PREFIX` statements. See <a href="/docs/ontology/rdf-import-and-export" target="_blank">RDF Import & Export</a> for the underlying statements and RDF details.

Each loader comes in three forms:

- **`loadOntology(payload, opts?)`** — load from an in-memory `Buffer`.
- **`loadOntologyFile(path, opts?)`** — upload a **client-local file** to the server (chunked); the format is auto-detected from the extension.
- **`loadOntologyFromSource(source, opts?)`** — load a **server-reachable path or URL** (no upload) — the SDK equivalent of GQL `LOAD ... FROM '<server-path|url>'`.

All methods are `async` and return a `Promise`. Options are passed as a trailing options object with `camelCase` keys.

This is distinct from [Bulk Import](/docs/drivers/nodejs-bulk-import), which streams node/edge objects you build in code; here you point the server at a **file**.

## Methods

| Method | Description |
|--------|-------------|
| `loadOntology` / `loadOntologyFile` / `loadOntologyFromSource` | Load an ontology **schema** (T-Box) |
| `loadData` / `loadDataFile` / `loadDataFromSource` | Load RDF **instance data** (A-Box) as nodes and edges |
| `loadCsv` / `loadCsvFile` | Load nodes or edges from a CSV file |
| `loadPrefix` | Register a single prefix, the standard set, or all prefixes from a source |
| `getLoaderCapabilities` | Query supported formats and limits |

> CSV has no `*FromSource` form — use `loadCsvFile` (client upload) or `loadCsv` (`Buffer`).

## Basic Usage

```typescript
import { GqldbClient, createConfig } from '@ultipa-graph/ultipa-driver';

async function main() {
  const client = new GqldbClient(createConfig({
    hosts: ['localhost:9000']
  }));

  try {
    await client.login('admin', 'password');
    await client.useGraph('myGraph');

    // 1. Load an ontology schema (client-local file; format auto-detected from .ttl)
    const onto = await client.loadOntologyFile('schema.ttl');
    console.log(`${onto.classes} classes, ${onto.objectProperties} object properties`);

    // 2. Load RDF instance data
    const data = await client.loadDataFile('instances.ttl');
    console.log(`${data.nodesCreated} nodes, ${data.edgesCreated} edges`);

  } finally {
    await client.close();
  }
}

main().catch(console.error);
```

## Loading Ontologies

```typescript
import { readFile } from 'fs/promises';

// From a client-local file (format auto-detected from the extension)
const result = await client.loadOntologyFile('schema.ttl', { graphName: 'myGraph' });

// From a Buffer (pass an explicit format)
const buf = await readFile('schema.ttl');
const result2 = await client.loadOntology(buf, { format: 'TURTLE' });

// From a server-reachable path or URL (no upload)
const result3 = await client.loadOntologyFromSource('https://xmlns.com/foaf/spec/index.rdf');
```

Common options: `graphName`, `format`, `baseIri`, plus the fault-tolerance options below.

### LoadOntologyOptions Interface

```typescript
interface LoadOntologyOptions {
  graphName?: string;        // Target graph; falls back to the session's current graph
  format?: string;           // OWL|RDFXML|TURTLE|NTRIPLES — required for Buffer; auto-detected by *File
  baseIri?: string;          // Base IRI for resolving relative IRIs
  validateOnly?: boolean;    // Dry run: parse + validate only, persist nothing
  continueOnError?: boolean; // Skip bad statements + record them in errors[], don't fail
  parserVersion?: string;    // Pin a parser version; "" = server default
}
```

### LoadOntologyResult Interface

```typescript
interface LoadOntologyResult {
  iri: string;
  classes: number;
  objectProperties: number;
  dataProperties: number;
  prefixesRegistered: number;
  prefixes: Record<string, string>;
  warnings: string[];
  // Fault-tolerance accounting (see below)
  parsed: number;
  failed: number;
  skipped: number;
  parserVersionUsed: string;
  errors: ParseError[];
  // Cost accounting
  timeCostNs: number;
  diskCostNs: number;
  computeCostNs: number;
}
```

## Loading Instance Data

```typescript
const result = await client.loadDataFile('instances.ttl');
console.log(`created ${result.nodesCreated} nodes, ${result.edgesCreated} edges`);
```

Same three forms and options as `loadOntology` (`LoadDataOptions` mirrors `LoadOntologyOptions`).

### LoadDataResult Interface

```typescript
interface LoadDataResult {
  nodesCreated: number;
  edgesCreated: number;
  prefixesRegistered: number;
  prefixes: Record<string, string>;
  warnings: string[];
  parsed: number;
  failed: number;
  skipped: number;
  parserVersionUsed: string;
  errors: ParseError[];
  timeCostNs: number;
  diskCostNs: number;
  computeCostNs: number;
}
```

## Loading CSV

```typescript
import { CsvColumnMapping } from '@ultipa-graph/ultipa-driver';

// Nodes
const nodesResult = await client.loadCsvFile('people.csv', {
  label: 'Person',
  withHeader: true,
  delimiter: ',',
});

// Edges
const edgesResult = await client.loadCsvFile('knows.csv', {
  label: 'knows',
  edge: true,
  edgeFromCol: 'from_id',
  edgeToCol: 'to_id',
});
console.log(`imported ${edgesResult.imported}, skipped ${edgesResult.skipped}`);
```

### LoadCsvOptions Interface

```typescript
interface LoadCsvOptions {
  label: string;               // Node label or edge type (required)
  graphName?: string;
  edge?: boolean;              // Import as edges (requires EDGE_ID enabled)
  edgeFromCol?: string;
  edgeToCol?: string;
  withHeader?: boolean;        // First row holds column names (default true)
  delimiter?: string;          // Default ','
  quote?: string;
  skip?: number;
  mapping?: CsvColumnMapping[];
}

interface CsvColumnMapping {
  property: string;
  column: string;
  type?: string;               // See type tokens below
}
```

`CsvColumnMapping.type` ∈ `STRING` / `INT` / `FLOAT` / `BOOL` / `DATE` / `DATETIME` / `TIMESTAMP` / `ZONED_DATETIME` / `DURATION` / `DECIMAL` / `BYTES` / `POINT` / `POINT3D` / `TIME` (or `""` to infer).

### LoadCsvResult Interface

```typescript
interface LoadCsvResult {
  imported: number;
  skipped: number;
  isEdge: boolean;
  timeCostNs: number;
  diskCostNs: number;
  computeCostNs: number;
}
```

## Loading Prefixes

`loadPrefix` is a single unary call; the options object selects the form.

```typescript
// A single prefix
await client.loadPrefix({ name: 'foaf', iri: 'http://xmlns.com/foaf/0.1/' });

// All standard prefixes (rdf, rdfs, owl, xsd, ...)
await client.loadPrefix({ allStandard: true });

// All prefixes declared in a server-reachable document
await client.loadPrefix({ source: 'https://xmlns.com/foaf/spec/index.rdf' });
```

### LoadPrefixOptions Interface

```typescript
interface LoadPrefixOptions {
  graphName?: string;
  name?: string;         // Single-prefix form: the prefix name
  iri?: string;          // Single-prefix form: the namespace IRI
  allStandard?: boolean; // Register the built-in standard prefix set
  source?: string;       // Bulk form: register every prefix declared in the RDF doc at this URL
}
```

### LoadPrefixResult Interface

```typescript
interface LoadPrefixResult {
  registered: number;
  updated: number;
  prefixes: Record<string, string>;
  timeCostNs: number;
}
```

## Fault Tolerance

`loadOntology*` and `loadData*` accept fault-tolerance options:

| Option | Meaning |
|--------|---------|
| `validateOnly: true` | Parse and report, but write nothing |
| `continueOnError: true` | Skip malformed triples instead of failing; collect them in `errors` |
| `parserVersion: "..."` | Pin a specific parser version |

The result then reports `parsed`, `failed`, `skipped`, `parserVersionUsed`, and `errors` (an array of `ParseError`):

```typescript
import { ParseError } from '@ultipa-graph/ultipa-driver';

const result = await client.loadDataFile('messy.ttl', { continueOnError: true });
console.log(`parsed ${result.parsed}, failed ${result.failed}, skipped ${result.skipped}`);
for (const e of result.errors) {
  console.log(`line ${e.line}: ${e.reason} — ${e.snippet}`);
}
```

### ParseError Interface

```typescript
interface ParseError {
  line: number;
  snippet: string;
  reason: string;
}
```

> These fields are populated by newer servers; on older servers the fault-tolerance counters are `0` and `errors` is empty.

## Format Auto-Detection

The `*File` methods detect the format from the file extension:

| Extension | Format |
|-----------|--------|
| `.ttl` | TURTLE |
| `.nt` | NTRIPLES |
| `.owl` / `.rdf` / `.xml` | RDFXML |
| `.nq` | NQUADS |
| `.trig` | TRIG |
| `.jsonld` | JSONLD |

Pass `format` explicitly for other extensions or for `Buffer` payloads. `LOAD ONTOLOGY` accepts OWL / RDFXML / TURTLE / NTRIPLES; `LOAD DATA` additionally accepts NQUADS / TRIG / JSONLD.

## Capabilities

```typescript
const caps = await client.getLoaderCapabilities();
console.log(caps.ontologyFormats, caps.dataFormats, caps.maxUploadBytes, caps.remoteSourceEnabled);
```

### LoaderCapabilities Interface

```typescript
interface LoaderCapabilities {
  ontologyFormats: string[];
  dataFormats: string[];
  maxUploadBytes: number;
  remoteSourceEnabled: boolean;
}
```

All load results also carry `timeCostNs`, `diskCostNs`, and `computeCostNs`.
