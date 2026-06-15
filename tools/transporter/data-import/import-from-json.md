# Import from JSON / JSONL

This page walks through a JSON or JSONL import end to end. The two formats share the same configuration shape and the same property semantics — the only difference is how the input file is laid out.

| `mode` value | File layout |
|---|---|
| `json` | A single top-level **array of objects** in one file. |
| `jsonl` | One **object per line** (newline-delimited). |

## Usage Guides

### Prepare the Source Files

Each object becomes one node or one edge. Object keys are the column / property names; values carry the data.

<p tit="people.json — JSON array"></p>

```json
[
  {"_id": "P001", "name": "Alice", "age": 30},
  {"_id": "P002", "name": "Bob",   "age": 25}
]
```

<p tit="people.jsonl — one object per line"></p>

```json
{"_id": "P001", "name": "Alice", "age": 30}
{"_id": "P002", "name": "Bob",   "age": 25}
```

Edge files follow the same shape (use whichever format you prefer for the source file):

<p tit="knows.json"></p>

```json
[
  {"from_id": "P001", "to_id": "P002", "since": 2024},
  {"from_id": "P002", "to_id": "P001", "since": 2025}
]
```

Place the files next to the importer, typically in a `./data` subdirectory:

<p tit="Directory layout"></p>

```
.
├── gqldb-importer
└── data/
    ├── people.json    # or people.jsonl
    └── knows.json     # or knows.jsonl
```

### Generate Configuration File

Use `-sample json` or `-sample jsonl` to match your source format:

```bash
./gqldb-importer -sample json    # or: -sample jsonl
```

A file named `import.sample.json.yml` (or `import.sample.jsonl.yml`) will be created in the current directory. If the file already exists, it will be overwritten — rename it before editing so a re-run doesn't clobber your changes:

```bash
mv import.sample.json.yml import.json.yml
```

### Modify Configuration File

Edit the renamed file to point at your data and target server. See the <a target="_blank" href="/docs/tools/import-configurations">Import Configurations</a> for every field; the only format-specific knob is `mode` itself (`json` or `jsonl`). JSON value-type behavior is covered below.

### Execute Import

```bash
./gqldb-importer -c import.json.yml
```

## JSON Value Types

Unlike CSV, JSON values already carry a type — strings are strings, numbers are numbers, booleans are booleans — so type declarations under `properties` are needed only when you want a more specific GQLDB type than JSON can express natively. The common cases:

| You want | Declare under `properties` |
|---|---|
| Distinguish `int32` from `int64` for an integer column | `age: int32` |
| Force a float to `double` (or vice-versa) | `score: double` |
| Parse a string as a `timestamp` | `created_at: timestamp` |
| Rename or prefix the value | Use the **list form** (see Configuration Reference) |

If the JSON already has the right type and the column name matches, you can omit `properties` entirely.
