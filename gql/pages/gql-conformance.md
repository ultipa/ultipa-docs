# GQL Conformance

GQL is the standardized query language for graph databases, published by ISO/IEC in April 2024 as:

- <a target="_blank" href="https://www.iso.org/standard/76120.html">ISO/IEC 39075:2024 - Information technology — Database languages — GQL</a> 

Ultipa now supports nearly all GQL features. This page claims the GQL conformance and Ultipa extensions.

## Conformance to Required Features

Following the GQL standard subclause 24.2, Ultipa’s support of the data model and mandatory GQL features is declared as follows.

### Minimum Conformance

Per subclause 24.2, Ultipa claims:

1. **Graph Type Support:** Conformance to both Feature GG01 (open graph type) and Feature GG02 (closed graph type).
2. **Unicode Compliance:** Version 13 of The Unicode Standard.
3. **Property Value Type Support:** `STRING`/`VARCHAR`, `BOOLEAN`/`BOOL`, `INTEGER`/`INT`, `FLOAT`, and additional optional types.

### Mandatory Features

Mandatory features are not assigned Feature IDs and Feature Names, unlike the <a href="Conformance-to-Optional-Features">optional features</a>. Therefore, we reference them by their corresponding subclause numbers and titles as specified in the GQL standard:

| Subclause | Title | Support | Note |
| -- | -- | -- | -- |
| 7 | Session management | No | `SESSION SET`, `SESSION RESET`, `SESSION CLOSE` |
| 8 | Transaction management | Yes |	`START TRANSACTION`, `ROLLBACK`, `COMMIT` |
| 11 | Object expressions | Yes | `CURRENT_GRAPH` |
| 14.4 | \<match statement\> | Yes | `MATCH`, `OPTIONAL MATCH` |
| 14.9 | \<order by and page statement\> | Yes | `ORDER BY` |
| 14.10 | \<primitive result statement\> | Yes |
| 14.11 | \<return statement\> | Yes | `RETURN` |
| 14.12 | \<select statement\> | No | `SELECT` |
| 16.1 | \<at schema clause\> | No |
| 16.3 | \<graph pattern binding table\> | Yes |
| 16.4 | \<graph pattern\> | Yes |
| 16.5 | \<insert graph pattern\> | Yes |
| 16.7 | \<path pattern expression\> | Yes |
| 16.8 | \<label expression\> | Yes |
| 16.9 | \<path variable reference\> | Yes |
| 16.10 | \<element variable reference\> | Yes |
| 16.13 | \<where clause\> | Yes | `WHERE` |
| 16.14 | \<yield clause\> | Yes | `YIELD` |
| 16.16 | \<order by clause\> | Yes | `ORDER BY` |
| 16.17 | \<sort specification list\> | Yes | `ASC`, `DESC` |
| 19.3 | \<comparison predicate\> | Yes | `=`, `<>`, `<`, `>`, `<=`, `>=` |
| 19.4 | \<exists predicate\> | Yes | `EXISTS` |
| 19.5 | \<null predicate\> | Yes | `IS NULL`, `IS NOT NULL` |
| 19.7 | \<normalized predicate\> | No | `IS NORMALIZED`, `IS NOT NORMALIZED` |
| 20.2 | \<value expression primary\> | Yes |
| 20.3 | \<value specification\> | Yes | Ultipa does not support `SESSION_USER` |
| 20.7 | \<case expression\> | Yes | `CASE`, `NULLIF`, `COALESCE` |
| 20.9 | \<aggregate function\> | Yes | `avg()`, `count()`, `max()`, `min()`, `sum()` |
| 20.11 | \<property reference\> | Yes | Property reference of a graph element. |
| 20.20 | \<boolean value expression\> | Yes | `AND`, `OR`, `NOT` |
| 20.21 | \<numeric value expression\> | Yes | `+`, `-`, `*`, `/` |
| 20.22 | \<numeric value function\> | Yes | `char_length()`, `character_length()` |
| 20.23 | \<string value expression\> | Yes | String concatenation operator `\|\|` |
| 20.24 | \<character string function\> | Yes | `left()`, `right()`, `upper()`, `lower()`, `normalize()` |
| 20.25 | \<byte string function\> | No | `left()`, `right()` |
| 20.29 | \<duration value function\> | Yes | `duration()` |
| 21.1 | Names and variables | Yes |
| 21.2 | \<literal\> | Yes |

## Conformance to Optional Features

Standard-defined optional GQL features are referenced by a Feature ID that comprises a letter “G” and three digits, and a Feature Name. 

| | Feature ID | Feature Name | Support |
| -- | -- | -- | -- |
| 1 | G002 | Different-edges match mode | Yes |
| 2 | G003 | Explicit REPEATABLE ELEMENTS keyword | Yes |
| 3 | G004 | Path variables | Yes |
| 4 | G005 | Path search prefix in a path pattern | Yes |
| 5 | G006 | Graph pattern KEEP clause: path mode prefix | No |
| 6 | G007 | Graph pattern KEEP clause: path search prefix | No |
| 7 | G010 | Explicit WALK keyword | Yes |
| 8 | G011 | Advanced path modes: TRAIL | Yes |
| 9 | G012 | Advanced path modes: SIMPLE | Yes |
| 10 | G013 | Advanced path modes: ACYCLIC | Yes |
| 11 | G014 | Explicit PATH/PATHS keywords | Yes |
| 12 | G015 | All path search: explicit ALL keyword | Yes |
| 13 | G016 | Any path search | Yes |
| 14 | G017 | All shortest path search | Yes |
| 15 | G018 | Any shortest path search | Yes |
| 16 | G019 | Counted shortest path search | Yes |
| 17 | G020 | Counted shortest group search | Yes |
| 18 | G030 | Path multiset alternation | No |
| 19 | G031 | Path multiset alternation: variable length path operands | No |
| 20 | G032 | Path pattern union | No |
| 21 | G033 | Path pattern union: variable length path operands | No |
| 22 | G035 | Quantified paths | Yes |
| 23 | G036 | Quantified edges | Yes |
| 24 | G037 | Questioned paths | Yes |
| 25 | G038 | Parenthesized path pattern expression | Yes |
| 26 | G039 | Simplified path pattern expression: full defaulting | No |
| 27 | G041 | Non-local element pattern predicates | Yes |
| 28 | G043 | Complete full edge patterns | Yes |
| 29 | G044 | Basic abbreviated edge patterns | Yes |
| 30 | G045 | Complete abbreviated edge patterns | Yes |
| 31 | G046 | Relaxed topological consistency: adjacent vertex patterns | Yes |
| 32 | G047 | Relaxed topological consistency: concise edge patterns | Yes |
| 33 | G048 | Parenthesized path pattern: subpath variable declaration | Yes |
| 34 | G049 | Parenthesized path pattern: path mode prefix | Yes |
| 35 | G050 | Parenthesized path pattern: WHERE clause | Yes |
| 36 | G051 | Parenthesized path pattern: non-local predicates | Yes |
| 37 | G060 | Bounded graph pattern quantifiers | Yes |
| 38 | G061 | Unbounded graph pattern quantifiers | Yes |
| 39 | G074 | Label expression: wildcard label | Yes |
| 40 | G080 | Simplified path pattern expression: basic defaulting | No |
| 41 | G081 | Simplified path pattern expression: full overrides | No |
| 42 | G082 | Simplified path pattern expression: basic overrides | No |
| 43 | G100 | ELEMENT_ID function | Yes |
| 44 | G110 | IS DIRECTED predicate | Yes |
| 45 | G111 | IS LABELED predicate | Yes |
| 46 | G112 | IS SOURCE and IS DESTINATION predicate | Yes |
| 47 | G113 | ALL_DIFFERENT predicate | Yes |
| 48 | G114 | SAME predicate | Yes |
| 49 | G115 | PROPERTY_EXISTS predicate | Yes |
| 50 | GA01 | IEEE 754 floating point operations | Yes |
| 51 | GA03 | Explicit ordering of nulls | Yes |
| 52 | GA04 | Universal comparison | Yes |
| 53 | GA05 | Cast specification | Yes |
| 54 | GA06 | Value type predicate | Yes |
| 55 | GA07 | Ordering by discarded binding variables | Yes |
| 56 | GA08 | GQL-status objects with diagnostic records | No |
| 57 | GA09 | Comparison of paths | Yes |
| 58 | GB01 | Long identifiers | Yes |
| 59 | GB02 | Double minus sign comments | Yes |
| 60 | GB03 | Double solidus comments | Yes |
| 61 | GC01 | Graph schema management | No |
| 62 | GC02 | Graph schema management: IF [ NOT ] EXISTS | No |
| 63 | GC03 | Graph type: IF [ NOT ] EXISTS | Yes |
| 64 | GC04 | Graph management | Yes |
| 65 | GC05 | Graph management: IF [ NOT ] EXISTS | Yes |
| 66 | GD01 | Updatable graphs | Yes |
| 67 | GD02 | Graph label set changes | Yes |
| 68 | GD03 | DELETE statement: subquery support | No |
| 69 | GD04 | DELETE statement: simple expression support | No |
| 70 | GE01 | Graph reference value expressions | No |
| 71 | GE02 | Binding table reference value expressions | No |
| 72 | GE03 | Let-binding of variables in expressions | Yes |
| 73 | GE04 | Graph parameters | No |
| 74 | GE05 | Binding table parameters | No |
| 75 | GE06 | Path value construction | Yes |\|` |
| 76 | GE07 | Boolean XOR | Yes |
| 77 | GE08 | Reference parameters | No |
| 78 | GE09 | Horizontal aggregation | No |
| 79 | GF01 | Enhanced numeric functions | Yes |
| 80 | GF02 | Trigonometric functions | Yes |
| 81 | GF03 | Logarithmic functions | Yes |
| 82 | GF04 | Enhanced path functions | Yes |
| 83 | GF05 | Multi-character TRIM function | Yes |
| 84 | GF06 | Explicit TRIM function | Yes |
| 85 | GF07 | Byte string TRIM function | No |
| 86 | GF10 | Advanced aggregate functions: general set functions | Yes |
| 87 | GF11 | Advanced aggregate functions: binary set functions | Yes |
| 88 | GF12 | CARDINALITY function | Yes |
| 89 | GF13 | SIZE function | Yes |
| 90 | GF20 | Aggregate functions in sort keys | Yes |
| 91 | GG01 | Graph with an open graph type | Yes |
| 92 | GG02 | Graph with a closed graph type | Yes |
| 93 | GG03 | Graph type inline specification | Yes |
| 94 | GG04 | Graph type like a graph | Yes |
| 95 | GG05 | Graph from a graph source | No |
| 96 | GG20 | Explicit element type names | Yes |
| 97 | GG21 | Explicit element type key label sets | Yes |
| 98 | GG22 | Element type key label set inference | No |
| 99 | GG23 | Optional element type key label sets | Yes |
| 100 | GG24 | Relaxed structural consistency | Yes |
| 101 | GG25 | Relaxed key label set uniqueness for edge types | No |
| 102 | GG26 | Relaxed property value type consistency | Yes |
| 103 | GH01 | External object references | No |
| 104 | GH02 | Undirected edge patterns | No |
| 105 | GL01 | Hexadecimal literals | No |
| 106 | GL02 | Octal literals | No |
| 107 | GL03 | Binary literals | No |
| 108 | GL04 | Exact number in common notation without suffix | Yes |
| 109 | GL05 | Exact number in common notation or as decimal integer with suffix | Yes |
| 110 | GL06 | Exact number in scientific notation with suffix | Yes |
| 111 | GL07 | Approximate number in common notation or as decimal integer with suffix | No |
| 112 | GL08 | Approximate number in scientific notation with suffix | No |
| 113 | GL09 | Optional float number suffix | No |
| 114 | GL10 | Optional double number suffix | No |
| 115 | GL11 | Opt-out character escaping | No |
| 116 | GL12 | SQL datetime and interval formats | Yes |
| 117 | GP01 | Inline procedure | Yes |
| 118 | GP02 | Inline procedure with implicit nested variable scope | Yes |
| 119 | GP03 | Inline procedure with explicit nested variable scope | Yes |
| 120 | GP04 | Named procedure calls | Yes |
| 121 | GP05 | Procedure-local value variable definitions | No |
| 122 | GP06 | Procedure-local value variable definitions: value variables based on simple expressions | No |
| 123 | GP07 | Procedure-local value variable definitions: value variable based on subqueries | No |
| 124 | GP08 | Procedure-local binding table variable definitions | No |
| 125 | GP09 | Procedure-local binding table variable definitions: binding table variables based on simple expressions or references | No |
| 126 | GP10 | Procedure-local binding table variable definitions: binding table variables based on subqueries | No |
| 127 | GP11 | Procedure-local graph variable definitions | No |
| 128 | GP12 | Procedure-local graph variable definitions: graph variables based on simple expressions or references | No |
| 129 | GP13 | Procedure-local graph variable definitions: graph variables based on subqueries | No |
| 130 | GP14 | Binding tables as procedure arguments | No |
| 131 | GP15 | Graphs as procedure arguments | No |
| 132 | GP16 | AT schema clause | No |
| 133 | GP17 | Binding variable definition block | No |
| 134 | GP18 | Catalog and data statement mixing | Yes |
| 135 | GQ01 | USE graph clause | Yes |
| 136 | GQ02 | Composite query: OTHERWISE | Yes |
| 137 | GQ03 | Composite query: UNION | Yes |
| 138 | GQ04 | Composite query: EXCEPT DISTINCT | Yes |
| 139 | GQ05 | Composite query: EXCEPT ALL | Yes |
| 140 | GQ06 | Composite query: INTERSECT DISTINCT | Yes |
| 141 | GQ07 | Composite query: INTERSECT ALL | Yes |
| 142 | GQ08 | FILTER statement | Yes |
| 143 | GQ09 | LET statement | Yes |
| 144 | GQ10 | FOR statement: list value support | Yes |
| 145 | GQ11 | FOR statement: WITH ORDINALITY | Yes |
| 146 | GQ12 | ORDER BY and page statement: OFFSET clause | Yes |
| 147 | GQ13 | ORDER BY and page statement: LIMIT clause | Yes |
| 148 | GQ14 | Complex expressions in sort keys | Yes |
| 149 | GQ15 | GROUP BY clause | Yes |
| 150 | GQ16 | Pre-projection aliases in sort keys | Yes |
| 151 | GQ17 | Element-wise group variable operations | Yes |
| 152 | GQ18 | Scalar subqueries | Yes |
| 153 | GQ19 | Graph pattern YIELD clause | Yes |
| 154 | GQ20 | Advanced linear composition with NEXT | Yes |
| 155 | GQ21 | OPTIONAL: Multiple MATCH statements | Yes |
| 156 | GQ22 | EXISTS predicate: multiple MATCH statements | Yes |
| 157 | GQ23 | FOR statement: binding table support | Yes |
| 158 | GQ24 | FOR statement: WITH OFFSET | Yes |
| 159 | GS01 | SESSION SET command: session-local graph parameters | No |
| 160 | GS02 | SESSION SET command: session-local binding table parameters | No |
| 161 | GS03 | SESSION SET command: session-local value parameters | No |
| 162 | GS04 | SESSION RESET command: reset all characteristics | No |
| 163 | GS05 | SESSION RESET command: reset session schema | No |
| 164 | GS06 | SESSION RESET command: reset session graph | No |
| 165 | GS07 | SESSION RESET command: reset time zone displacement | No |
| 166 | GS08 | SESSION RESET command: reset all session parameters | No |
| 167 | GS10 | SESSION SET command: session-local binding table parameters based on subqueries | No |
| 168 | GS11 | SESSION SET command: session-local value parameters based on subqueries | No |
| 169 | GS12 | SESSION SET command: session-local graph parameters based on simple expressions or references | No |
| 170 | GS13 | SESSION SET command: session-local binding table parameters based on simple expressions or references | No |
| 171 | GS14 | SESSION SET command: session-local value parameters based on simple expressions | No |
| 172 | GS15 | SESSION SET command: set time zone displacement | No |
| 173 | GS16 | SESSION RESET command: reset individual session parameters | No |
| 174 | GT01 | Explicit transaction commands | Yes |
| 175 | GT02 | Specified transaction characteristics | Yes |
| 176 | GT03 | Use of multiple graphs in a transaction | No |
| 177 | GV01 | 8 bit unsigned integer numbers | Yes |
| 178 | GV02 | 8 bit signed integer numbers | Yes |
| 179 | GV03 | 16 bit unsigned integer numbers | Yes |
| 180 | GV04 | 16 bit signed integer numbers | Yes |
| 181 | GV05 | Small unsigned integer numbers | No |
| 182 | GV06 | 32 bit unsigned integer numbers | Yes |
| 183 | GV07 | 32 bit signed integer numbers | Yes |
| 184 | GV08 | Regular unsigned integer numbers | Yes |
| 185 | GV09 | Specified integer number precision | No |
| 186 | GV10 | Big unsigned integer numbers | No |
| 187 | GV11 | 64 bit unsigned integer numbers |  Yes |
| 188 | GV12 | 64 bit signed integer numbers |  Yes |
| 189 | GV13 | 128 bit unsigned integer numbers | No |
| 190 | GV14 | 128 bit signed integer numbers | No |
| 191 | GV15 | 256 bit unsigned integer numbers | No |
| 192 | GV16 | 256 bit signed integer numbers | No |
| 193 | GV17 | Decimal numbers | Yes |
| 194 | GV18 | Small signed integer numbers | Yes |
| 195 | GV19 | Big signed integer numbers | Yes |
| 196 | GV20 | 16 bit floating point numbers | No |
| 197 | GV21 | 32 bit floating point numbers | Yes |
| 198 | GV22 | Specified floating point number precision | No |
| 199 | GV23 | Floating point type name synonyms | Yes |
| 200 | GV24 | 64 bit floating point numbers | Yes |
| 201 | GV25 | 128 bit floating point numbers | No |
| 202 | GV26 | 256 bit floating point numbers | No |
| 203 | GV30 | Specified character string minimum length | No |
| 204 | GV31 | Specified character string maximum length | Yes |
| 205 | GV32 | Specified character string fixed length | No |
| 206 | GV35 | Byte string types | No |
| 207 | GV36 | Specified byte string minimum length | No |
| 208 | GV37 | Specified byte string maximum length | No |
| 209 | GV38 | Specified byte string fixed length | No |
| 210 | GV39 | Temporal types: date, local datetime and local time support | Yes |
| 211 | GV40 | Temporal types: zoned datetime and zoned time support | Yes |
| 212 | GV41 | Temporal types: duration support | Yes |
| 213 | GV45 | Record types | Yes |
| 214 | GV46 | Closed record types | Yes |
| 215 | GV47 | Open record types | No |
| 216 | GV48 | Nested record types | Yes |
| 217 | GV50 | List value types | Yes |
| 218 | GV55 | Path value types | Yes |
| 219 | GV60 | Graph reference value types | No |
| 220 | GV61 | Binding table reference value types | No |
| 221 | GV65 | Dynamic union types | Yes |
| 222 | GV66 | Open dynamic union types | Yes |
| 223 | GV67 | Closed dynamic union types | No |
| 224 | GV68 | Dynamic property value types | No |
| 225 | GV70 | Immaterial value types | Yes |
| 226 | GV71 | Immaterial value types: null type support | Yes |
| 227 | GV72 | Immaterial value types: empty type support | Yes |
| 228 | GV90 | Explicit value type nullability | Yes |

## Ultipa Extensions

Beyond the GQL standard, Ultipa provides additional features:

| Feature | Description |
| -- | -- |
| Constraints | `NOT NULL` and `UNIQUE` constraints on node and edge properties |
| Backup and restore | `BACKUP GRAPH`, `BACKUP DATABASE`, `RESTORE`, `VERIFY BACKUP`, incremental backups |
| Triggers | `BEFORE INSERT` and `BEFORE UPDATE` triggers with callable body expressions |
| Full-text index | Full-text indexing with BM25 scoring, CJK support, and query operators (AND, OR, NOT, phrase, proximity, wildcard) |
| Vector index | HNSW-based vector index with cosine, euclidean, and dot product metrics |
| AI functions | `ai.embed()`, `ai.cosine()`, `ai.distance()`, `ai.gql()`, `ai.read()`, provider configuration |
| Stored procedures | `CREATE PROCEDURE`, `CALL`, with algorithm and query types |
| Graph projections | Named in-memory subgraph projections |
| RBAC | Role-based access control with `GRANT`, `REVOKE`, users and roles |
| Query management | `SHOW QUERIES`, `KILL QUERY`, `EXPLAIN` / `EXPLAIN ANALYZE` / `EXPLAIN OPTIMIZER` |
| Transactions | `START TRANSACTION`, `COMMIT`, `ROLLBACK`, `SAVEPOINT`, `READ ONLY` mode |
| Ontology | OWL-based ontology support with class hierarchies, domain/range constraints |
| Federation | Cross-database query federation via `SERVICE` endpoints |