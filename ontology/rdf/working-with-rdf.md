# Working with RDF

GQLDB's ontology layer maps RDF data-model features (including **RDF 1.2** additions) onto the LPG. This page covers how those features surface when you import and query RDF. For the `LOAD` / `EXPORT` statements themselves, see <a href="/docs/ontology/rdf-import-and-export" target="_blank">RDF Import & Export</a>.

## Literals

A literal is a concrete data value that appears as the object of a triple. In the graph, literals become node property values. `LOAD DATA` preserves each literal's full metadata, including its **language tag**, the RDF 1.2 **base direction** (`@lang--dir`), and its **datatype IRI**, instead of flattening everything to a plain string.

<p tit="example.ttl"></p>

```ttl
@prefix ex:  <http://example.org/> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .

ex:alice a ex:Person ;
    ex:bio      "Engineer" ;              # plain string
    ex:greeting "hello"@en ;              # rdf:langString
    ex:greeting "bonjour"@fr ;            # rdf:langString — a second language
    ex:greeting "مرحبا"@ar--rtl ;         # rdf:dirLangString (RDF 1.2) — same predicate, another language
    ex:age      "30"^^xsd:integer ;       # known XSD type -> native value
    ex:code     "AB12"^^ex:partNumber .   # custom datatype  -> IRI kept
```

```gql
LOAD DATA FROM 'file:///path/example.ttl'

MATCH (n@ex:Person) RETURN n
```

Result:

| _id | _iri | bio | greeting | age | code |
| -- | -- | -- | -- | -- | -- |
| ac9ba4af-f74a-4c07-8fd9-7a06d7b5174b | http://example.org/alice | "Engineer" | ["hello", "bonjour", "مرحبا"] | 30 | "AB12" |

| Property | Stored term | Notes |
| -- | -- | -- |
| `n.bio` | `"Engineer"` | plain string (no metadata) |
| `n.greeting` | `["hello"@en, "bonjour"@fr, "مرحبا"@ar--rtl]` | repeated predicate → **list**; a `RETURN` projection prints bare lexical strings, not the tagged forms |
| `n.age` | `30` (INTEGER)| known XSD type coerced to a native value |
| `n.code` | `"AB12"^^<http://example.org/partNumber>` | unknown datatype IRI preserved |

To verify:

```gql
-- Language tag preserved: a bare string is a different term from the tagged one
-- greeting is a list, so test membership with IN
MATCH (n@ex:Person WHERE "hello"    IN n.greeting) RETURN n  // No return
MATCH (n@ex:Person WHERE "hello"@en IN n.greeting) RETURN n  // Success return

-- Custom datatype preserved: a bare string is a different term from the typed one.
MATCH (n@ex:Person WHERE n.code = "AB12") RETURN n                                   // No return
MATCH (n@ex:Person WHERE n.code = "AB12"^^<http://example.org/partNumber>) RETURN n  // Success return
```

A known XSD numeric/boolean type is coerced to a native value (`age` → integer); an unknown or custom datatype keeps its IRI. Plain strings are unchanged and fully back-compatible, and all this metadata round-trips through storage, survives a database restart, and is re-serialized by `EXPORT`.

Because the language tag, direction, and datatype are part of a literal's identity (per RDF), two literals that differ only in metadata are not equal, so `DISTINCT` / `GROUP BY` keep them separate. Plain strings are unaffected.

> Language tags are compared case-insensitively, so `"hi"@EN` and `"hi"@en` are the same term.

You can also write these literals using GQL directly in `INSERT` and in `WHERE` comparisons, not only via RDF import. The syntax mirrors Turtle:

```gql
INSERT (n:Doc {
    greeting: ["hello"@en, "bonjour"@fr, "مرحبا"@ar--rtl],  // multilingual list
    age:      "30"^^xsd:integer,                            // typed literal (standard prefix)
    code:     "AB12"^^<http://example.org/partNumber>,      // typed literal (full IRI)
    bio:      "Engineer"                                    // plain string
})
```

**Details**

- To assign multiple languages to one property, write a single list. A tag must abut the closing quote (`"hello"@en`, no space). Written with a space, `"hello" @en` does not lex as a tagged literal.
- The base direction is appended with a double hyphen (`@ar--rtl`); a single hyphen stays in the language subtag (`@en-US`).
- `^^` takes a full `<IRI>` or a `prefix:local` name. The standard prefixes (`xsd`, `rdf`, `rdfs`, `owl`) expand to their fixed IRIs; for a graph-custom prefix, use the full `<IRI>` form.
- An authored typed literal is a typed string, not a coerced value. Unlike the RDF-import path, `"30"^^xsd:integer` written in GQL keeps its lexical form and datatype IRI exactly as written; it is not coerced to a native integer. So `"30"^^xsd:integer` does not equal the number `30`, and you cannot do arithmetic or numeric range comparisons on it. Write a bare `30` when you want a native integer.

## Blank Nodes

A Turtle blank node (`[ ... ]`) becomes an anonymous node: it carries no ontology label, and its inner properties attach directly to it. Its document-local blank id (`_:b1`) is kept as the node's `_iri`; there is no separate `_blank` flag.

<p tit="example.ttl"></p>

```ttl
@prefix ex:  <http://example.org/> .

ex:alice a ex:Person ;
    ex:home [ ex:city "NYC" ; ex:zip "10001" ] ;
    ex:work [ ex:city "LA"; ex:zip "10002" ] .
```

```gql
LOAD DATA FROM 'file:///path/example.ttl'

MATCH (@ex:Person)-[@ex:work|@ex:home]->(b) RETURN b
```

Result:

| _id | city | zip | _iri |
| -- | -- | -- | -- |
| 9ca9c74f-2cf2-4ac5-85cd-e95004639bea | NYC | 10001 | _:b1 |
| aabba91c-0bde-415b-9c77-a4badf31eb03| LA | 10002 | _:b2 |

**A blank node's `_iri` is neither unique nor stable, don't use it as a key.** The blank-id counter **resets per document**, so the n-th blank node in each file is `_:b<n>`. Loading a file twice yields two distinct nodes both with `_iri = "_:b1"`, two with `"_:b2"`, and so on (blank nodes never merge). So never treat `_:b1` as a unique id, an `@=` match target, or a cross-load reference.

## RDF Collections

An RDF **collection** (an ordered list, written `( … )` in Turtle/TriG, an `rdf:first`/`rdf:rest` chain in N-Triples/N-Quads, or `@list` in JSON-LD) maps onto the graph by the type of its members.

<p tit="example.ttl"></p>

```ttl
@prefix ex: <http://example.org/> .

ex:alice a ex:Person ;
    ex:nicknames ( "Al" "Ally" ) ;         # literal collection → ordered list property
    ex:visited   ( ex:paris ex:tokyo ) .   # IRI collection → one edge per member
```

```gql
LOAD DATA FROM 'file:///path/example.ttl'

MATCH (a@ex:Person)-[@ex:visited]->(b) RETURN a.nicknames, b._iri
```

Result:

| a.nicknames | b._iri |
| -- | -- |
| ["Al", "Ally"] | http://example.org/paris |
| ["Al", "Ally"] | http://example.org/tokyo |

The mapping:

- **Literal members → an ordered list property.** `ex:nicknames ( "Al" "Ally" )` becomes `nicknames = ["Al", "Ally"]`, with member order preserved.
- **IRI members → one edge per member.** `ex:visited ( ex:paris ex:tokyo )` becomes two `@ex:visited` edges, and `ex:paris` / `ex:tokyo` are created as nodes even if they appear nowhere else in the data.

Unlike a repeated predicate, a collection always yields a list for literal members, whatever its length:

| Collection | Stored value |
| -- | -- |
| `( "a" "b" )` | `["a", "b"]` |
| `( "only" )` | `["only"]` (a one-element list, not a scalar) |
| `()` or a bare `rdf:nil` | `[]` (an empty list) |
| `( "a" ( "b1" "b2" ) "c" )` | `["a", ["b1", "b2"], "c"]` (nested lists) |

This is the key contrast with a **repeated predicate** (`ex:p "a" ; ex:p "b"`), which produces an unordered list and folds a single occurrence to a scalar. A collection preserves order and always produces a list. The three formats above (Turtle/TriG `( … )`, N-Triples/N-Quads first/rest chains, JSON-LD `@list`) load identically, the result survives a database restart, and `EXPORT` writes list properties back out as real RDF collections so ordering round-trips.

Three collection shapes are not imported. They are reported as load warnings (surfaced on the result set, see <a href="/docs/ontology/rdf-import-and-export" target="_blank">RDF Import & Export</a>), never dropped silently:

- a nested collection whose inner list contains **IRI** members,
- a collection in **subject** position (`( "a" "b" ) ex:p ex:o`),
- an **RDF-star** annotation attached to a collection.

## Named Graphs / Quads

An RDF **quad** adds a 4th term, i.e., the named graph a statement belongs to: `(subject, predicate, object, graph)`. GQLDB models the named graph as a logical tag over the single physical graph, not as a separate physical graph.

Import **N-Quads** (`.nq`) or **TriG** (`.trig`). In the TriG below, `ex:bob`'s statement sits outside any block (the default graph), while the `ex:g1` and `ex:g2` blocks name the graph their triples belong to:

<p tit="example.trig"></p>

```trig
@prefix ex: <http://example.org/> .

ex:bob ex:name "Bob" .
ex:g1 {
    ex:alice a ex:Person ;
        ex:name "Alice" .
}
ex:g2 { ex:alice ex:knows ex:bob . }
```

```gql
LOAD DATA FROM 'file:///tmp/example.trig'

MATCH (n1)->(n2) RETURN n1, n2
```

Result:

`n1`:

| _id | name | _graph | _iri |
| -- | -- | -- | -- |
| 5d58c1ac-5ed7-46a4-969e-2c8b25e6a377 | Alice | ["http://example.org/g1", "http://example.org/g2"] | http://example.org/alice |

`n2`:

| _id | name | _iri |
| -- | -- | -- |
| 3afcce75-1392-43c6-b429-af6cd2b783d3 | Bob | http://example.org/bob |


A node carries a `_graph` property when it heads statements in a named graph: a sorted list of the distinct named-graph IRIs its subject-statements belong to (a subject can appear in several). A node whose only statements are in the default graph, like `ex:bob`, has no `_graph`. Also note, `_graph` lives on **nodes only**, edges do not carry `_graph`. 

Export back to either format. `EXPORT FORMAT NQUADS` writes the 4th term (a 3-term line for the default graph); `EXPORT FORMAT TRIG` groups by graph. Because edges carry no `_graph`, relationship (object-property) triples are emitted into the default graph on export.

## JSON-LD Import

`LOAD DATA` expands JSON-LD to triples. The `@context` maps terms and prefixes to IRIs (with optional per-term `@type` / `@language` coercion); `@id` is the subject, `@type` becomes `rdf:type`, and `@graph` lands in a named graph.

<p tit="example.jsonld"></p>

```json
{
  "@context": {
    "ex": "http://example.org/",
    "name": "http://example.org/name",
    "knows": { "@id": "http://example.org/knows", "@type": "@id" },
    "age":   { "@id": "http://example.org/age", "@type": "http://www.w3.org/2001/XMLSchema#integer" }
  },
  "@id": "ex:alice",
  "@type": "ex:Person",
  "name": "Alice",
  "age": 30,
  "knows": "ex:bob",
  "ex:greeting": [
    { "@value": "hi",    "@language": "en" },
    { "@value": "salut", "@language": "fr" }
  ],
  "ex:address": { "ex:city": "NYC" }
}
```

```gql
LOAD DATA FROM 'file:///tmp/example.jsonld'
```

The JSON-LD file loads: 

- an `@ex:Person` node, `name: "Alice"`, `age: 30` (coerced to a native integer via the `xsd:integer` term type), `greeting: ["hi"@en, "salut"@fr]` (the two-element `ex:greeting` array becomes a langString list); 
- a `@ex:knows` edge from Alice to `http://example.org/bob` (the term's `@type: @id` coerces the bare IRI string into a node reference, so `bob` is created as a node); 
- an `@ex:address` edge from Alice to an anonymous node holding `city` "NYC" (that node leaks its blank id as `_iri = "_:jb1"`, like any [blank node](#Blank-Nodes)).

**Supported:** a local `@context` (term / prefix maps, **datatype** `@type` coercion, `@language` coercion, **`@type: @id` node references** → edges, `@vocab`, `@base`), `@id`, `@type`, `@graph`, value objects, nested objects (→ an edge to a blank node), blank nodes, and arrays (a repeated term → a list; an array of `@id` references → one edge per element). **Not supported:** remote or array `@context`, `@reverse`, `@container`, scoped contexts, framing.

> JSON-LD is accepted by `LOAD DATA` only. `LOAD ONTOLOGY` does not accept `JSONLD`.

## Canonicalization (RDFC-1.0)

Two RDF datasets that say the same thing but use different blank-node labels (or statement order) are equal, yet serialize differently. **RDF Dataset Canonicalization (RDFC-1.0)** assigns deterministic blank-node identifiers so they serialize identically, which is useful for comparing, deduplicating, signing, or hashing datasets. Two built-in functions operate on an N-Quads string:

| Function | Returns |
| -- | -- |
| `RDF.CANONICALIZE(nquads)` | Canonical N-Quads (blank nodes relabeled to `_:c14nN`, statements sorted). |
| `RDF.CANONICAL_HASH(nquads)` | The hex SHA-256 of the canonical form (a dataset fingerprint). |

```gql
-- The argument is an N-Quads STRING you supply: a literal (below), a bound variable,
-- or the output of EXPORT FORMAT NQUADS. A bare `nquads` is not a keyword — pass a string
RETURN RDF.CANONICALIZE('_:a <http://example.org/knows> _:b .')
RETURN RDF.CANONICAL_HASH('_:a <http://example.org/knows> _:b .')
```

Both take exactly one `STRING` argument (an N-Quads document) and return `NULL` on `NULL` input. To fingerprint the current graph, take its `EXPORT FORMAT NQUADS` output and feed it to `RDF.CANONICAL_HASH(…)` (two steps, e.g. from a driver). Two isomorphic datasets (blank nodes relabeled, statements reordered) produce **byte-identical** `RDF.CANONICALIZE` output and the **same** `RDF.CANONICAL_HASH`; any real difference changes the hash. Canonicalization is idempotent.

## Triple Terms (RDF-star)

RDF 1.2 lets you make **statements about statements**. A **triple term** `<<( s p o )>>` denotes a triple without asserting it, and may appear only in object position. Pairing it with `rdf:reifies` gives you a **reifier** — a resource you can hang metadata on (who said it, when, how confident):

<p tit="example.ttl"></p>

```ttl
@prefix ex: <http://example.org/> .

# A triple term as the object of :states — the inner triple is NOT asserted, only referred to
ex:report ex:states <<( ex:earth ex:orbits ex:sun )>> .

# rdf:reifies + metadata: :obs is a reifier for the inner triple, carrying its own provenance
ex:obs rdf:reifies <<( ex:alice ex:knows ex:bob )>> ;
       ex:certainty "0.9" ;
       ex:source    ex:dbpedia .
```

```gql
LOAD DATA FROM 'file:///tmp/example.ttl'
```

Loading it yields **11 nodes, 9 edges** — each `<<( … )>>` becomes a blank statement node (`_:b1`, `_:b2`):

<p tit="Result graph"></p>

```
ex:report -[@ex:states]->     _:b1
_:b1      -[@rdf:subject]->    ex:earth
_:b1      -[@rdf:predicate]->  ex:orbits
_:b1      -[@rdf:object]->     ex:sun

ex:obs    -[@rdf:reifies]->    _:b2          -- ex:obs also carries certainty = "0.9"
ex:obs    -[@ex:source]->      ex:dbpedia
_:b2      -[@rdf:subject]->    ex:alice
_:b2      -[@rdf:predicate]->  ex:knows
_:b2      -[@rdf:object]->     ex:bob
```

The inner triples are not asserted; there is no `ex:earth -[@ex:orbits]-> ex:sun` or `ex:alice -[@ex:knows]-> ex:bob` edge.

### How GQLDB Stores a Triple Term

GQLDB has no triple-valued cell, so on import a triple term is expanded into standard W3C reification on a fresh blank statement node:

<p tit="Triple term → reification"></p>

```
<<( ex:earth ex:orbits ex:sun )>>
   ⇩  becomes
_:stmt rdf:subject   ex:earth .
_:stmt rdf:predicate ex:orbits .
_:stmt rdf:object    ex:sun .
```

and the outer triple becomes the edge `ex:report --ex:states--> _:stmt`. The statement node is an ordinary anonymous node, it keeps its document-local blank id as `_iri` (e.g. `_:b1`), so you query it with normal `MATCH`: follow the asserting edge to the statement node, then read its components:

```gql
-- the statement node referred to by :report
MATCH (r)-[]->(stmt)-[]->(component)
WHERE r._iri = 'http://example.org/report'
RETURN component._iri        -- earth, orbits, sun
```

A triple term whose object is a literal stores that literal as the statement node's `object` data property (subject and predicate stay as edges): `<<( ex:mars ex:radius 3389 )>>` → `_:stmt.object = 3389`.

### Annotation Syntax

The annotation form is sugar for "assert this triple and reify it with metadata". The triple is asserted normally; a reifier carrying the annotation is created for it:

```ttl
ex:carol ex:age 30 {| ex:certainty "0.8" ; ex:source ex:survey |} .
```

is equivalent to asserting `ex:carol ex:age 30` (so `carol.age = 30`) plus a reifier `_:r rdf:reifies <<( ex:carol ex:age 30 )>> ; ex:certainty "0.8" ; ex:source ex:survey`.

### Export

`EXPORT` serializes a reified statement node as its standard W3C reification triples (`rdf:subject` / `rdf:predicate` / `rdf:object`), so the graph round-trips structurally (re-importing reproduces the same statement node):

```ttl
ex:report ex:states _:stmt .
_:stmt rdf:subject ex:earth ; rdf:predicate ex:orbits ; rdf:object ex:sun .
```

Triple-term import works in Turtle, N-Triples, and TriG (inside a named-graph block).