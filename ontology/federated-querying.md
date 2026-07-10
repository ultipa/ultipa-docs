# Federated Querying

## Overview

Federation lets a query reach data held in a **remote SPARQL service** (e.g. DBpedia, Wikidata, or an internal triple store) and combine it with local graph data in a single GQL query. A service is registered once with `CREATE SERVICE`, then queried with `FROM SERVICE` placed in the query pipeline; alternatively, `FROM SERVICE` can name an endpoint IRI inline, with no prior registration. GQLDB translates the `FROM SERVICE` block to SPARQL, sends it to the endpoint, and maps the results back into the query.

## Service Management

### Creating a Service

Register a remote endpoint with `CREATE SERVICE`. Only a `URL` is required; the options may follow it in any order.

```syntax
<create service statement> ::=
  "CREATE SERVICE" <service name>
  "URL" < <iri> | <url string> >
  [ "TYPE SPARQL" ]
  [ "TIMEOUT" <integer> < "MILLISECOND" | "SECOND" | "MINUTE" | "HOUR" > ]
  [ "CACHE" <integer> < "MILLISECOND" | "SECOND" | "MINUTE" | "HOUR" > ]
  [ "CREDENTIALS" <auth header string> ]
```

**Details**

- `URL` points to the service endpoint. Prefer `https://`; a redirecting `http://` endpoint can drop the POSTed query.
- `TYPE` is the service kind, currently only `SPARQL` (the default).
- `TIMEOUT` sets the HTTP request timeout. Omit it to use the default of **30 seconds**.
- `CACHE` sets the cache TTL for responses. Responses are cached by default, so omitting `CACHE` uses the default TTL of **5 minutes** (not "no caching"). Use per-call `NO CACHE` to bypass it, see <a href="#Per-Call-Cache-Control">Per-Call Cache Control</a>.
- `CREDENTIALS` is sent as-is as the `Authorization` header. Use the full header form: `'Bearer <token>'` for OAuth/JWT, `'Basic <base64(user:password)>'` for HTTP Basic. There is no separate username/password form.

```gql
-- Minimal: just a URL (SPARQL is the default type)
CREATE SERVICE dbpedia URL <https://dbpedia.org/sparql>

-- With a request timeout
CREATE SERVICE wikidata
  URL <https://query.wikidata.org/sparql>
  TYPE SPARQL
  TIMEOUT 30 SECOND

-- With a cache TTL for responses
CREATE SERVICE cached
  URL <https://internal/sparql>
  CACHE 30 MINUTE

-- Combined options, any order
CREATE SERVICE primary
  URL 'https://internal/sparql'
  CREDENTIALS 'Bearer eyJhbGciOiJIUzI1...'
  TIMEOUT 90 SECOND
  CACHE 6 HOUR
  TYPE SPARQL
```

> Requests use SPARQL-protocol HTTP GET while the URL stays short, and switch automatically to a form-encoded POST for long queries (e.g. large correlated `VALUES` push-downs), so endpoint URL-length limits are never hit. A request that exceeds the timeout fails with an error naming the service and the effective limit.

### Dropping a Service

```gql
DROP SERVICE dbpedia

-- Use IF EXISTS to avoid an error when the service is not registered
DROP SERVICE IF EXISTS dbpedia
```

### Showing Services

List registered services with their configuration and runtime health:

```gql
SHOW SERVICES
```

Result columns:

| Column | Description |
| -- | -- |
| `name` | Service name (used in `FROM SERVICE <name> { … }`). |
| `url` | Endpoint URL. |
| `type` | Service kind (currently only `SPARQL`). |
| `timeout` | Configured request timeout; empty when not set (the 30-second default applies at runtime). |
| `cache_ttl` | Configured cache TTL; empty when not set (the 5-minute default applies at runtime). |
| `requests` | Cumulative requests sent to this service since startup. |
| `errors` | Cumulative errors (HTTP non-2xx or network failure). |
| `consecutive_failures` | Failures since the last success — non-zero means the service is currently flaky. |
| `last_ok` | RFC 3339 UTC timestamp of the most recent successful response; empty if never succeeded. |

This distinguishes "configured but unused" (zeros, empty `last_ok`) from "called but failing" (non-zero `consecutive_failures`, stale `last_ok`) from "healthy" (recent `last_ok`).

## Federated Queries

### FROM SERVICE

The `FROM SERVICE` statement allows you to run a query against a remote service inline in your query pipeline. `FROM SERVICE` sits in the pipeline like any other statement.

```syntax
<from service statement> ::=
  "FROM SERVICE" <service reference> 
  [ "GRAPH" <iri> ] [ "NO CACHE" | "REFRESH" ]
  "{" <remote query> "}"

<service reference> ::= <service name> | <endpoint iri>

<remote query> ::= <gql query> | <gql graph pattern>
```

**Details**

- The `<service reference>` is either a `<service name>` registered with `CREATE SERVICE`, or an `<endpoint iri>` given inline (see <a href="#Inline-Endpoint-IRI">Inline Endpoint IRI</a>).
- `GRAPH <iri>` targets a named graph on the remote endpoint, see <a href="#Targeting-a-Named-Graph">Targeting a Named Graph</a>.
- `NO CACHE` / `REFRESH` override the response cache (see <a href="#Per-Call-Cache-Control">Per-Call Cache Control</a>).
- The `<remote query>` is translated to SPARQL: its `MATCH`/`WHERE` become triples and `FILTER`s, `RETURN [DISTINCT]` becomes `SELECT [DISTINCT]`, `ORDER BY` becomes `ORDER BY`, and `LIMIT`/`SKIP` become `LIMIT`/`OFFSET`. All of it runs on the endpoint.
- Remote labels use ontology form: `@prefix:Name` (with the prefix loaded or standard) or a full IRI. A bare LPG label `(p:Person)` (or the equivalent default-prefix form `(p@:Person)`) works only when the graph has a default namespace; otherwise the query fails with an actionable error rather than sending invalid SPARQL.

### Prepare the Graph

Most of the examples below share this setup: a `fed_demo` ontology graph with a few local `@foaf:Person` nodes (two real, one fictional), plus the registered `dbpedia` service.

```gql
CREATE GRAPH fed_demo WITH ONTOLOGY
USE fed_demo

CREATE SERVICE dbpedia URL <https://dbpedia.org/sparql>

INSERT (@foaf:Person {name: 'Einstein', _iri: 'http://dbpedia.org/resource/Albert_Einstein'}),
       (@foaf:Person {name: 'Newton', _iri: 'http://dbpedia.org/resource/Isaac_Newton'}),
       (@foaf:Person {name: 'Nobody', _iri: 'http://dbpedia.org/resource/Nonexistent_Person_XYZ'})
```

> **Federation does not require an ontology graph.** It works just as well in a plain LPG: `CREATE GRAPH fed_demo` (no `WITH ONTOLOGY`). See <a href="#Do-I-Need-an-Ontology-Graph">Do I Need an Ontology Graph?</a>

### Pure Remote Query

With no preceding or following `MATCH` to join against, the remote query's rows are the whole result. Its `LIMIT` is pushed into the SPARQL, so only that many rows are fetched — important against a huge public class.

```gql
FROM SERVICE dbpedia { MATCH (p@foaf:Person) RETURN p LIMIT 5 }
RETURN p
```

Result:

| p |
| -- |
| http://dbpedia.org/resource/Esteban_Mujica |
| http://dbpedia.org/resource/Ethel_Marshall |
| http://dbpedia.org/resource/Jack_Keller_(poker_player) |
| http://dbpedia.org/resource/Jean_Bottéro |
| http://dbpedia.org/resource/Joan_Cererols |

Each returned `p` is the matched resource's **IRI**, not a node. A SPARQL result is always an IRI or a literal, so a remote variable projected by the block comes back as that text.

The block `MATCH (p@foaf:Person) RETURN p LIMIT 5` matches resources of RDF class `foaf:Person`, binding `p` to each matching resource IRI. It translates to:

```sparql
SELECT ?p WHERE {
  ?p a <http://xmlns.com/foaf/0.1/Person> .
}
LIMIT 5
```

The GQL label `@foaf:Person` is expanded to the full IRI `<http://xmlns.com/foaf/0.1/Person>`: GQLDB looks up the prefix `foaf` → `http://xmlns.com/foaf/0.1/` and splices it in. Note we never loaded `foaf`; it is a <a target="_blank" href="/docs/ontology/introduction#Standard-Prefixes">standard prefix</a>, recognized automatically. A non-standard prefix needs an explicit `LOAD PREFIX` first.

### Bare-Pattern Shorthand

A block with just a pattern (no `MATCH`/`RETURN` keyword) desugars to a single `MATCH`. Here the `LIMIT` is on the outer pipeline, so it runs locally rather than on the endpoint:

```gql
FROM SERVICE dbpedia { (p@foaf:Person) }
RETURN p LIMIT 5
```

Because this `LIMIT` is outside the braces, it is not pushed to SPARQL: the endpoint is asked for the whole `foaf:Person` class and the cap is applied locally only after the rows come back. Against a large public class that fetches far more data and takes much longer (and can hit the response cap). To cap on the endpoint, put the `LIMIT` inside a full block: `FROM SERVICE dbpedia { MATCH (p@foaf:Person) RETURN p LIMIT 5 }`, see the next section.

### Inside the Braces vs. Outside: Push-Down

The block is a self-contained remote query, so its `LIMIT` and `ORDER BY` translate directly to SPARQL and run on the endpoint; placed outside the braces they run locally instead, after the endpoint has already returned the whole class.

```gql
-- Endpoint sorts foaf:Person and applies LIMIT: SELECT ?p … ORDER BY ?p LIMIT 5
FROM SERVICE dbpedia { MATCH (p@foaf:Person) RETURN p ORDER BY p LIMIT 5 }
RETURN p
```

### Inline Endpoint IRI

Instead of a registered service name, `FROM SERVICE` can take the endpoint IRI directly. This is handy for a one-off query against a public endpoint, where registering a service first is unnecessary:

```gql
FROM SERVICE <https://dbpedia.org/sparql> { MATCH (p@foaf:Person) RETURN p LIMIT 5 }
RETURN p
```

The inline endpoint behaves like a service created with only a `URL`: `TYPE SPARQL`, the default 30-second timeout, and the default 5-minute cache TTL. Everything else works the same as a named service, `GRAPH <iri>`, `NO CACHE` / `REFRESH`, push-down, and correlation all apply.

Use a registered service (`CREATE SERVICE`) when you need non-default options (`TIMEOUT`, `CACHE`, `CREDENTIALS`), reusable health and cache metrics under a stable name (`SHOW SERVICES`, `SHOW SERVICE CACHE STATS`), or simply a short name repeated across many queries. An inline IRI cannot carry credentials, so it only fits open, unauthenticated endpoints.

### Constraining the Remote with Property Specs

Add an inline property spec inside the pattern to filter on the endpoint. The key must be an `@`-prefixed ontology label.

How you write the value decides how it becomes SPARQL. A **typed** value carries a datatype, written with `^^`, like `'1879-03-14'^^xsd:date`. It goes straight into the query as the triple's object and matches only a stored literal with the same text and the same datatype. DBpedia keeps dates and numbers as typed literals, so match Einstein by his typed `dbo:birthDate`:

```gql
-- dbo is non-standard, so load it first (xsd is standard, no load needed)
LOAD PREFIX dbo FROM <http://dbpedia.org/ontology/>

FROM SERVICE dbpedia { MATCH (p@foaf:Person {@dbo:birthDate: '1879-03-14'^^xsd:date}) RETURN p }
RETURN p
```

Translates to SPARQL (the typed value becomes an exact triple object):

```sparql
SELECT ?p WHERE {
  ?p a <http://xmlns.com/foaf/0.1/Person> .
  ?p <http://dbpedia.org/ontology/birthDate> "1879-03-14"^^<http://www.w3.org/2001/XMLSchema#date> .
}
```

Result (every person DBpedia records with that birth date, so Einstein appears among others; exact rows and order vary):

| p |
| -- |
| http://dbpedia.org/resource/Albert_Einstein |
| http://dbpedia.org/resource/James_DePree |
| http://dbpedia.org/resource/Tyko_Sallinen |
| … |

A **plain** (untagged) value instead becomes a triple to a scratch variable plus a `FILTER` equality, `{@foaf:name: 'Alice'}` → `FILTER(?prop1 = "Alice")`, matching plain or `xsd:string` literals; numbers and booleans are bare literals (`{@dbo:age: 42}` → `FILTER(?v = 42)`). DBpedia tags all its text, so a plain-string constraint returns nothing there; for tagged text use the tagged form, see <a href="#Language-Tagged-and-Typed-Literals">Language-Tagged and Typed Literals</a>.

### Language-Tagged and Typed Literals

Real knowledge graphs store text as **language-tagged** literals: DBpedia's `rdfs:label` for Einstein is `"Albert Einstein"@en`, not a plain string. In RDF a plain literal and a tagged literal are different terms, so a plain constraint does not match tagged data. Write the tag explicitly with `'value'@tag`:

```gql
FROM SERVICE dbpedia { MATCH (p@foaf:Person {@rdfs:label: 'Albert Einstein'@en}) RETURN p }
RETURN p
```

Translates to SPARQL:

```sparql
SELECT ?p WHERE {
  ?p a <http://xmlns.com/foaf/0.1/Person> .
  ?p <http://www.w3.org/2000/01/rdf-schema#label> "Albert Einstein"@en .
}
```

Result:

| p |
| -- |
| http://dbpedia.org/resource/Albert_Einstein |

The rules:

- **Tagged / typed value → direct triple object.** `'x'@en` emits `… "x"@en .` and `'x'^^<iri>` emits `… "x"^^<iri> .`, matching the exact RDF term. Plain strings keep the scratch-var + `FILTER` form above.
- **Plain never matches tagged (by design).** `{@rdfs:label: 'Albert Einstein'}` (no tag) will not match DBpedia's `"Albert Einstein"@en`. The same rule the local engine enforces (`'x' ≠ 'x'@en`). Add the tag when the endpoint's data is tagged.
- **Returned literals keep their metadata.** A remote `"Berlin"@en` comes back as a language-tagged value, and a preserved custom datatype keeps its `^^<iri>`. Use `LANG(value)` to read the tag, e.g. `WHERE LANG(p) = 'en'`.
- **Direction limitation.** RDF 1.2 base direction (`'x'@ar--rtl`) has no SPARQL 1.1 syntax; only the language tag is sent (`"x"@ar`).

### Joining Local and Remote Data

Precede `FROM SERVICE` with a local `MATCH`, then put a `WHERE` inside the block that equates a remote variable with a local value. That equality is the join condition: the local values are pushed into the remote query as a SPARQL `VALUES` block (so the endpoint returns only the rows the join needs), and the equality is also enforced on the joined result.

```gql
-- All local Person IRIs push down as VALUES ?p { … }, so DBpedia returns birthplaces only for the ones that exist there
MATCH (s@foaf:Person)
FROM SERVICE dbpedia {
  MATCH (p@foaf:Person)-[@dbo:birthPlace]->(place)
  WHERE p = s._iri
  RETURN p, place
}
RETURN s.name, place, REPLACE(LAST(SPLIT(place, '/')), '_', ' ') AS placeName
```

Result (real DBpedia data; a person can carry several `dbo:birthPlace` values):

| s.name | place | placeName |
| -- | -- | -- |
| Einstein | http://dbpedia.org/resource/Ulm | Ulm |
| Einstein | http://dbpedia.org/resource/German_Empire | German Empire |
| Einstein | http://dbpedia.org/resource/Kingdom_of_Württemberg | Kingdom of Württemberg |
| Newton | http://dbpedia.org/resource/Woolsthorpe-by-Colsterworth | Woolsthorpe by Colsterworth |

The block translates to:

```sparql
SELECT ?p ?place WHERE {
  VALUES ?p { <http://dbpedia.org/resource/Albert_Einstein> <http://dbpedia.org/resource/Isaac_Newton> <http://dbpedia.org/resource/Nonexistent_Person_XYZ> }
  ?p a <http://xmlns.com/foaf/0.1/Person> .
  ?p <http://dbpedia.org/ontology/birthPlace> ?place .
}
```

Note that `Nobody` is pushed down too, but its IRI does not exist on DBpedia, so it matches nothing and drops out of the result. The join returns only local nodes that have a real remote counterpart.

**A remote variable binds to a string, not a node.** A SPARQL result is an IRI or a literal, so `p` above holds the IRI text (e.g. `http://dbpedia.org/resource/Albert_Einstein`), and a returned literal holds its value (with any language tag or datatype). Join it against a local property that stores the same text (`p = s._iri`) not against a whole local node (`p = s` compares a string to a node and matches nothing).

**Correlate, or the remote runs unconstrained.** The `VALUES` push-down only fires when the block's `WHERE` is a simple equality between a remote variable and a local value (`p = s._iri`), with the local value an IRI-looking string (`http(s)://…` or `urn:…`). Drop that `WHERE`, or use anything other than `=`, and no `VALUES` is sent: the remote pattern then runs against the whole endpoint and can match a huge class. So always correlate with a simple `=`, or cap the block with a `LIMIT`.

**Storing the results back.** The remote IRIs are bound in the query, so you can persist them with an `INSERT` in the same pipeline:

```gql
MATCH (s@foaf:Person)
FROM SERVICE dbpedia {
  MATCH (p@foaf:Person)-[@dbo:birthPlace]->(place)
  WHERE p = s._iri
  RETURN p, place
}
INSERT (s)-[:BORN_IN]->(:Place {
  name: REPLACE(LAST(SPLIT(place, '/')), '_', ' '),
  _iri: place
})
```

### Aggregating Remote Results

Remote-bound variables flow into the surrounding pipeline, so you can aggregate over them in the outer `RETURN` (`COUNT`, `COLLECT`, `GROUP BY`, …). Aggregation runs locally over the returned rows; it is not pushed into SPARQL.

```gql
-- Collect each local person's remote birthplaces into a list
MATCH (s@foaf:Person)
FROM SERVICE dbpedia {
  MATCH (p@foaf:Person)-[@dbo:birthPlace]->(place)
  WHERE p = s._iri
  RETURN p, place
}
RETURN s.name, COLLECT(place) AS birthplaces
GROUP BY s.name
```

Result (the remote `place` IRIs gathered into a list per local person):

| s.name | birthplaces |
| -- | -- |
| Newton | ["http://dbpedia.org/resource/Woolsthorpe-by-Colsterworth"] |
| Einstein | ["http://dbpedia.org/resource/German_Empire", "http://dbpedia.org/resource/Kingdom_of_Württemberg", "http://dbpedia.org/resource/Ulm"] |

### Cross-Service Queries

Chain several `FROM SERVICE` stages in one pipeline; a later stage can correlate on an earlier stage's output:

```gql
-- Stage 1 finds the person by label; stage 2 correlates on that IRI
-- Stage 2 uses a distinct variable q and WHERE q = p
FROM SERVICE dbpedia { MATCH (p@foaf:Person {@rdfs:label: 'Albert Einstein'@en}) RETURN p }
FROM SERVICE dbpedia {
  MATCH (q@foaf:Person)-[@dbo:birthPlace]->(place)
  WHERE q = p
  RETURN q, place
}
RETURN p, place
```

Result (Einstein's three birthplaces on DBpedia):

| p | place |
| -- | -- |
| http://dbpedia.org/resource/Albert_Einstein | http://dbpedia.org/resource/German_Empire |
| http://dbpedia.org/resource/Albert_Einstein | http://dbpedia.org/resource/Kingdom_of_Württemberg |
| http://dbpedia.org/resource/Albert_Einstein | http://dbpedia.org/resource/Ulm |

**Dropping the `WHERE` breaks the correlation.** Each `FROM SERVICE` block scopes its own pattern variables independently, so a name reused inside the braces is a **fresh, unbound remote variable**, not a reference to the earlier stage. Only a `WHERE` conjunct that references an outer variable is pushed down (as a SPARQL `VALUES` binding) to constrain the remote query. Without it, the second block matches every `birthPlace` triple on the endpoint:

```gql
-- WRONG: no WHERE, so the second block's variable is unbound
FROM SERVICE dbpedia { MATCH (p@foaf:Person {@rdfs:label: 'Albert Einstein'@en}) RETURN p }
FROM SERVICE dbpedia {
  MATCH (p)-[@dbo:birthPlace]->(place)   -- p here is a NEW remote variable, not Einstein
  RETURN p, place
}
RETURN p, place
```

This block translates to `SELECT ?place WHERE { ?p dbo:birthPlace ?place }` with no constraint, so it enumerates every person's birthplace on DBpedia (DBpedia's Virtuoso caps the response at its 10,000-row server default). The outer `RETURN p, place` still projects the outer pipeline's `p` (Einstein, bound by stage 1), so every row pairs Einstein's IRI with an unrelated place, making it look as if he were born in thousands of cities:

| p | place |
| -- | -- |
| http://dbpedia.org/resource/Albert_Einstein | http://dbpedia.org/resource/Al-Zawaida |
| http://dbpedia.org/resource/Albert_Einstein | http://dbpedia.org/resource/Anzali |
| http://dbpedia.org/resource/Albert_Einstein | http://dbpedia.org/resource/Baladwayne |
| … (10,000 rows) | … |

To correlate across stages, always give the second block its own variable and join it back with `WHERE`, as in the first example (`WHERE q = p`).

```gql
-- Two independent services joined through a local pipeline
MATCH (u:LocalUser)
FROM SERVICE usersDB { MATCH (person@ex:Person) WHERE person = u.personUri RETURN person }
FROM SERVICE ordersDB { MATCH (order@ex:Order) WHERE order = u.orderUri RETURN order }
RETURN person, order LIMIT 50
```

### Remote Failure Handling

- When the remote variables are **required** — the query correlates on them, or any later clause (`RETURN`, `ORDER BY`, a following `MATCH`, …) consumes them — a remote failure (timeout, HTTP error, TLS failure) surfaces as a **query error naming the service**. The result is never silently reduced to local-only data missing the requested columns.
- When the remote block is **optional enrichment** (its variables are never referenced), a remote failure **degrades gracefully**: the incoming local rows are returned with a warning on the result (`ResultSet.Warnings()`, forwarded to drivers).
- An **empty** remote answer is a legitimate result (0 rows), not an error.
- **Public endpoints are slow and variable, retry on `DEADLINE_EXCEEDED`.** DBpedia is a shared service; the same query can return in a second or take tens of seconds under load. Keep the remote sub-query light and `LIMIT`ed to make an overrun less likely.

### Fallback with OTHERWISE

`OTHERWISE` falls back to a second branch when the first returns no rows. It is an empty-result fallback, not an error handler — a hard service failure on required remote variables still surfaces as an error.

```gql
-- Try the primary service; if it returns nothing, use the backup
FROM SERVICE primaryDB { MATCH (data@ex:Data {ex:code: 'important'}) RETURN data }
RETURN data
OTHERWISE
FROM SERVICE backupDB { MATCH (data@ex:Data {ex:code: 'important'}) RETURN data }
RETURN data
```

### Targeting a Named Graph

By default the block queries the endpoint's default graph. Add `GRAPH <iri>` after the service reference to target a named graph; the translator wraps the block in `GRAPH <iri> { … }` in the generated SPARQL:

```gql
FROM SERVICE internal GRAPH <http://example.org/graph/people> { 
  MATCH (p@foaf:Person) RETURN p LIMIT 5 }
RETURN p
```

The named graph must actually exist on the endpoint. `GRAPH <iri>` pointing at a non-existent or empty named graph is valid SPARQL that matches nothing, so the query returns no rows even when the default graph has the data. If a `GRAPH` query is empty, drop the `GRAPH` clause to confirm the data is present, then discover the endpoint's real named graphs with `SELECT DISTINCT ?g WHERE { GRAPH ?g { ?s ?p ?o } }`.

### Per-Call Cache Control

Federated responses are cached by default and reused within the service's TTL (the configured `CACHE <ttl>`, or the 5-minute default). Two keywords override the cache for a single query, placed after the service reference:

| Form | Effect |
| -- | -- |
| `NO CACHE` | Bypass the cache for this call; fetch fresh, and neither read nor write the cached entry. |
| `REFRESH` | Force a fresh fetch and replace the cached entry with the new result. |

```gql
-- Always hit the live endpoint, ignoring any cached response
FROM SERVICE dbpedia NO CACHE { MATCH (p@foaf:Person) RETURN p LIMIT 5 }
RETURN p

-- Refresh the cached entry with a fresh result
FROM SERVICE dbpedia REFRESH { MATCH (p@foaf:Person) RETURN p LIMIT 5 }
RETURN p
```

There is no service-level way to disable caching entirely; use per-call `NO CACHE` when you need a guaranteed fresh fetch.

## Service Caching

When you run `FROM SERVICE <svc> { … }`, the block is translated to SPARQL, sent to the endpoint, and the response is memoized in a per-service LRU cache keyed by the resulting SPARQL query string. Cache TTL is set per service with the `CACHE` option (default 5 minutes); per-service quotas default to 50 MB / 1000 entries unless overridden in startup config.

### SHOW SERVICE CACHE STATS

Inspect cache hit/miss counters per service.

```gql
SHOW SERVICE CACHE STATS
```

Result columns:

| Column | Description |
| -- | -- |
| `service` | Service name (matches `SHOW SERVICES` rows). |
| `hits` | Number of cache hits. |
| `misses` | Number of cache misses. |
| `evictions` | Entries dropped due to LRU / TTL. |
| `entries` | Live entries in the cache. |
| `size_bytes` | Approximate memory footprint. |

### CLEAR SERVICE CACHE

Drop cached SPARQL responses for one service or all of them.

```gql
-- Clear one service's cache
CLEAR SERVICE CACHE dbpedia

-- Clear every service's cache
CLEAR SERVICE CACHE ALL
```

## Feature Support and Limitations

The SPARQL translator covers most of the GQL surface that ontology workloads need: labeled patterns, edges with predicates, property constraints, `WHERE` filters (including functions and `NOT` / `IS NULL`), label disjunction/conjunction, optional patterns, named graphs, and ontology-label expansion. A few constructs have no portable SPARQL translation and are **explicitly rejected at translation time** with a typed error, rather than silently degraded.

| GQL Construct | Status |
| -- | -- |
| `OPTIONAL MATCH` | ✓ Implemented (SPARQL `OPTIONAL { … }`) |
| `REGEX` / `STR` / `LANG` / `DATATYPE` / `BOUND` in `WHERE` | ✓ Implemented |
| `NOT expr`, unary minus, `IS NULL` (→ `!BOUND`) | ✓ Implemented |
| Named graph `GRAPH <iri> { … }` | ✓ Implemented |
| Label disjunction `(:A\|B)` | ✓ Implemented (→ SPARQL `UNION`) |
| Label conjunction `(:A&B)` | ✓ Implemented (→ multiple `a` triples) |
| SPARQL `ASK` response (boolean) | ✓ Implemented |
| Aggregation (`COUNT` / `SUM` / `AVG` / `MIN` / `MAX`) inside `FROM SERVICE` | Evaluated locally over the returned rows (not pushed into SPARQL) |
| Quantified edge `-[]->{1,5}` / `-[*]->` / `-[+]->` | Partial — bounded shapes map to SPARQL property paths; complex quantifiers return the typed error |
| `KHOP` | Partial — fixed-distance maps to a property path; otherwise the typed error |
| `SHORTEST` / `ANY SHORTEST` / `ALL SHORTEST` | ✗ Rejected — no portable SPARQL form; run locally |
| `CHEAPEST` (weighted) | ✗ Rejected — not federated; run locally or in a stored procedure |

**Prefix registration.** Remote labels resolve through GQLDB's prefix table. The <a href="/docs/ontology/introduction#Standard-Prefixes" target="_blank">standard prefix set</a> (`foaf`, `rdfs`, `owl`, …) is recognized automatically for `FROM SERVICE`, so `@foaf:Person` needs no setup; a non-standard prefix such as `dbo` must be loaded first with `LOAD PREFIX dbo FROM <iri>`. An unrecognized prefix fails the query with a clear error before it reaches the endpoint.

## Do I Need an Ontology Graph?

**No.** The examples on this page use an ontology graph so the local nodes are genuine RDF resources identified by `_iri`, but federation itself works from any graph — LPG (open, closed) or ontology.

The ontology-prefixed labels in the block (`@foaf:Person`, `@dbo:birthPlace`) describe the remote endpoint's RDF vocabulary; they are translation hints for the generated SPARQL, not local schema, so the local graph never has to be in ontology mode to use them. Standard prefixes are recognized automatically, and `LOAD PREFIX` works regardless of graph mode.

In a plain LPG graph, store each local node's IRI in an ordinary string property (e.g. `uri`) and correlate on that value (`WHERE p = s.uri`); the push-down fires on the value being IRI-shaped, not on `_iri` or ontology membership. You need an ontology graph only when you also want to store RDF locally as first-class resources (`INSERT (@foaf:Person {_iri: '…'})`) and mix it with remote results; that requirement comes from local RDF storage, not from federation itself.
