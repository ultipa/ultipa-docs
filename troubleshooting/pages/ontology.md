# Ontology

Issues around `CREATE GRAPH ... WITH ONTOLOGY`, class / property declarations, inference, and enforcement.

## MATCH (n@prefix:Class) returns nothing even though instances exist

**Symptom:** You inserted `(:@ex:Person {name: 'Alice'})`, the node clearly exists (`MATCH (n) WHERE n.name = 'Alice' RETURN labels(n)` shows the ontology label), but `MATCH (n@ex:Person)` returns nothing.

**Cause (most likely):** The graph wasn't created with ontology enabled, so the ontology hierarchy / label resolver isn't active.

**How to confirm:**

```gql
SHOW ONTOLOGY
```

If this errors or is empty, the graph has no ontology. The instance node may carry a plain LPG label that happens to look like `@ex:Person` rather than a registered ontology class.

**Fix:** Create the graph with the right option, then re-declare classes and properties before inserting instances:

```gql
CREATE GRAPH ontology_demo WITH ONTOLOGY
USE ontology_demo
LOAD ALL PREFIX
LOAD PREFIX ex FROM 'http://example.org/'
CREATE CLASS @ex:Person
-- now inserts can use @ex:Person and matches will work
```

## DISJOINT WITH doesn't error on the offending insert

**Symptom:** You declared `CREATE CLASS @ex:Dog DISJOINT WITH @ex:Cat`, then ran `INSERT (@ex:Cat&@ex:Dog {name: 'Mystery'})` — and the insert succeeded.

**Cause:** Ontology enforcement defaults to `WARNING` mode. Violations are logged but the operation proceeds. The same applies to `FUNCTIONAL` cardinality, `DOMAIN` / `RANGE` mismatches, and data-property type errors.

**Fix:** Switch enforcement to `STRICT` for the session:

```gql
SET ONTOLOGY ENFORCEMENT STRICT
INSERT (@ex:Cat&@ex:Dog {name: 'Mystery'})   -- now errors
```

The three modes are `WARNING` (default, log only), `STRICT` (reject), and `OFF` (no validation at all). The setting is per-session; for production graphs, set it as part of your connection bootstrap.

## Sub-property rollup returns empty

**Symptom:** You declared

```gql
CREATE OBJECT PROPERTY @ex:contributedTo
CREATE OBJECT PROPERTY @ex:directed SUBPROPERTY OF @ex:contributedTo
INSERT (lana)-[@ex:directed]->(film)
```

`MATCH (p)-[@ex:directed]->(f)` returns Lana, but `MATCH (p)-[@ex:contributedTo]->(f)` returns nothing.

**Cause (likely):** One of:

1. The graph wasn't created `WITH ONTOLOGY` — the `PropertyHierarchy` that powers sub-property MATCH inference is only built on ontology-enabled graphs.
2. `@ex:contributedTo` was declared **after** `@ex:directed`, but the hierarchy snapshot used by the matcher hasn't refreshed.
3. Your build pre-dates the SUBPROPERTY OF rollup (introduced in commit `443fae21`). The feature is a no-op in older builds.

**How to confirm:**

```gql
SHOW ONTOLOGY
```

The output should list both `@ex:directed` and `@ex:contributedTo` with the `superProperties` column populated on the former. If the `superProperties` field is missing entirely, your build doesn't have the feature.

**Fix:** Always declare the super-property first, then its sub-properties, then insert edges. If you altered the hierarchy mid-session, drop and re-create the property in the right order.

## PROPERTY CHAIN ... TRANSITIVE only finds the first hop

**Symptom:**

```gql
CREATE OBJECT PROPERTY @ex:hasAncestor
  PROPERTY CHAIN @ex:hasParent, @ex:hasParent TRANSITIVE

-- Family: Alice -> Bob -> Carol -> Dave -> Eve  (4 hasParent edges)
MATCH (a@ex:Person {name: 'Alice'})-[@ex:hasAncestor]->(x)
RETURN x.name
-- expected: Carol (2 hops) and Eve (4 hops)
-- actual:   Carol only
```

**Cause (likely):** The `TRANSITIVE` keyword after `PROPERTY CHAIN` is parsed but the chain BFS in the matcher isn't picking up the flag — typically because the build pre-dates the combined production at `pkg/parser/goyacc/grammar/70_ontology.y.part:285`, or there's a regression in the `Characteristics.Transitive` propagation for chain properties.

**Fix:** For "every ancestor at every distance" — which is what most uses of transitive chains actually want — use a plain transitive single-hop property instead:

```gql
CREATE OBJECT PROPERTY @ex:isAncestorOf
  DOMAIN @ex:Person RANGE @ex:Person TRANSITIVE
```

Then insert edges with `@ex:isAncestorOf` directly (or alongside `hasParent`). This gives Bob, Carol, Dave, Eve — every ancestor at every hop — and is well-supported across all ontology-enabled builds.

`PROPERTY CHAIN x, y` **without** `TRANSITIVE` works fine and is the right tool for "exactly two hops" semantics (e.g., `hasGrandparent`).

## EQUIVALENT TO (... ONLY ...) classifies everything

**Symptom:** You declared `CREATE CLASS @ex:Director EQUIVALENT TO (@ex:directed ONLY @ex:Film)` expecting only Persons who directed Films, but `MATCH (d@ex:Director)` returns every node in the graph — including Films, restaurants, even unlabeled nodes.

**Cause:** `ONLY` is the OWL universal quantifier (`owl:allValuesFrom`). It's satisfied by every node whose `@ex:directed` edges are **all** Films — **including the vacuous case where the node has zero `@ex:directed` edges**. Any node that never directed anything trivially satisfies the restriction.

**Fix:** Use the standard OWL idiom `<named class> AND (SOME ...) AND (ONLY ...)`:

```gql
CREATE CLASS @ex:Director
  EQUIVALENT TO @ex:Person
    AND (@ex:directed SOME @ex:Film)      -- has at least one Film
    AND (@ex:directed ONLY @ex:Film)      -- and every directed thing is a Film
```

`SOME` knocks out the empty-edge vacuous case; `ONLY` enforces "all of them are Films"; the `@ex:Person` conjunct narrows candidates and avoids classifying non-Persons.

For the simpler "directed at least one Film" semantics, drop `ONLY` and use `SOME` alone.

## Ontology label on an edge in INSERT silently drops

**Symptom:**

```gql
INSERT (a)-[:KNOWS]->(b)        -- works
INSERT (a)-[:@ex:knows]->(b)    -- works  (legacy colon form)
INSERT (a)-[@ex:knows]->(b)     -- works  (canonical form)
```

All three parse, but only some store the ontology label.

**Cause:** Pre-`843bddd3`, the canonical no-leading-colon form for ontology edges (`[@ex:knows]`) worked only in some contexts. After that commit, all three forms parse equivalently and produce identical AST. Mixed-form inserts in older builds may silently fall back to plain LPG labels.

**Fix:** Use the canonical `@prefix:name` form everywhere (no leading colon) and ensure your build is current. To verify the stored label, run:

```gql
MATCH (a)-[r]->(b) WHERE a._id = '...' AND b._id = '...'
RETURN type(r)
```

If `type(r)` returns `'KNOWS'` (plain LPG) instead of the ontology label IRI, the insert dropped the ontology binding.

## "Prefix not loaded" error on a fresh graph

**Symptom:**

```
CREATE CLASS @ex:Person
-- error: prefix "ex" is not loaded
```

**Cause:** Only the 14 built-in prefixes (`foaf`, `rdfs`, `owl`, `xsd`, …) are pre-registered via `LOAD ALL PREFIX`. Custom prefixes like `ex` must be loaded explicitly.

**Fix:**

```gql
LOAD ALL PREFIX
LOAD PREFIX ex FROM 'http://example.org/'
```

Prefixes persist with the graph, so this only needs to run once per `CREATE GRAPH`. List currently loaded prefixes with `SHOW PREFIX`.
