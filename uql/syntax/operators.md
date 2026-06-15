# Operators

## All Operators

| <div table-width="30">Category</div>	| Operator |
| ------  | -------	|
| Information abstractor | `.`: Extract the schema or property of a NODE or EDGE data; extract the x or y coordinate value of a point data; extract the value of a key of an object data<br>`[ ]`: Extract one or multiple elements of a list data | 
| List builder | `[ ]`: Build a list data |
| Full-text index prefix | `~`: Indicate the full-text index for use in the full-text filter |
| Schema checker | `@` |
| String concatenation | `+`	|
| Numeric operation | `+`，`-`，`*`，`/`，`%` |
| Comparison | `==`，`!=`，`>`，`<`，`>=`，`<=`，`<>`，`<=>` |
| Check for membership | `IN`，`NIN` |
| Check string | `CONTAINS` |
| Regular matching | `=~` |
| Null judgement | `IS NULL`，`IS NOT NULL` |
| Logical operation | `&&`，`\|\|`，`!`，`XOR` |
| Deduplication | `DISTINCT` |

## Operator Precedence

The following table shows the precedence of various operators, where 1 indicates the highest precedence:

| <div table-width="12">Precedence</div> | Operator | <div table-width="10">Type</div> | <div table-width="25">Category</div> |
| --- | --- | --- | --- |
| 1 | `( )` | / | / |
| 2	| `@` | Unary | Conditional operator |
| 3 | `!` | Unary | Logical operator |
| 4	 | `*`, `/`, `%` | Binary | Numeric operator |
| 5	 | `+`, `-` | Binary | Numeric operator, string concatenator |
| 6	| `>`, `<`, `>=` , `<=` , `<>` , `<=>`, `IN`, `NIN`, `CONTAINS`, `=~` | Binary | Conditional operator |
| 7	| `==` , `!=` | Binary | Conditional operator |
| 8 | `&&` | Binary	| Logical operator |
| 9 | `XOR`, `\|\|` | Binary | Logical operator |
