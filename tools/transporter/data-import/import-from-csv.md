# Import from CSV

This page walks through a CSV import end to end.

## Usage Guides

### Prepare CSV Files

Place your node and edge CSV files in a directory accessible from where you will run `gqldb-importer`. A common layout is to keep the data files in a `./data` subdirectory next to the importer binary.

For example:

<p tit="Directory layout"></p>

```
.
├── gqldb-importer
└── data/
    ├── people.csv
    └── knows.csv
```

### Generate Configuration File

Open a terminal, navigate to the folder containing `gqldb-importer`, and run the following command to generate a sample CSV configuration file:

```bash
./gqldb-importer -sample csv
```

A file named `import.sample.csv.yml` will be created in the current directory. If the file already exists, it will be overwritten — rename it before editing so a re-run of `-sample csv` doesn't clobber your changes:

```bash
mv import.sample.csv.yml import.csv.yml
```

### Modify Configuration File

Edit `import.csv.yml` to point at your data and target server. See the <a target="_blank" href="/docs/tools/import-configurations">Import Configurations</a> for every field; CSV-specific behavior is covered below in <a href="#Headed-vs-Headerless">Headed vs. Headerless</a>.

### Execute Import

```bash
./gqldb-importer -c import.csv.yml
```

## Headed vs. Headerless

A CSV file with a header row is the default. The header defines the column names that the importer uses when mapping columns to node or edge properties:

<p tit="people.csv"></p>

```csv
person_id,name,age
P001,Alice,30
P002,Bob,25
```

These column names are referenced by `nodes` / `edges` > `properties` (as map keys) for type overrides, and by `id_column`, `from_column`, and `to_column` for ID columns.

You can also embed the value type directly in the header using the form `<colName>:<type>`:

<p tit="people.csv"></p>

```csv
person_id:_id,name:string,age:int32
P001,Alice,30
P002,Bob,25
```

When the type is declared in the header, you do not need to repeat it under `properties` in the configuration file.

If the CSV file has **no header**, set `head: false` on the entry and declare each column under `properties` as a list, in column order:

<p tit="config snippet"></p>

```yml
nodes:
  - file: "./data/cities_no_header.csv"
    labels: ["City"]
    head: false
    properties:
      - name: city_id
        type: _id
        prefix: "CITY_"       # adds a prefix to ID values: "123" → "CITY_123"
      - name: name
        type: string
        new_name: city_name   # rename the property on import
      - name: population
        type: int64
```

If the number of declared properties does not match the number of columns in the file, set `settings.fit_to_header` to `true` to tolerate the mismatch.
