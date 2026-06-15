# Expression

An **expression** is a combination of constants, alias calls, operators and functions that produces one or more values.

| <div table-width="20">Purpose</div>	| Example	|
| -	| -	|
| Use decimal constant | -10.25，1，1691636269	|
| Use textual constant | "graph"，'uql'，' both \' and " '，"2020-01-01 0:0:0"	|
| Build list with constant | [1, 2, 3]，["graph", "database"]，[ ] |
| Call an alias	| `nodes`，`edges`，`paths`，`mylist`，`groupName`，`count`，`` `ABC-123` ``	|
| Call a property | `nodes.age`，`` edges.`version-old` ``，`this.age`，`age`	|
| Call the values of coordinates of a point data | `location.x`，`location.y`	|
| Call the schema | `edges.@`，`this.@`	|
| Call the element(s) of a list	| `mylist[5]`，`mylist[3:6]`，`mylist[2:]`，`mylist[:4]`	|
| Build list with alias | [`nodes.level`, -1, "NaN"]，[`groupName`, `count`]	|
| Decuplication	| `DISTINCT nodes.name`，`DISTINCT nodes.name, nodes.age`	|
| Numeric operation	| `1 + 3 * 2`，`year("2022-04-12") % 4`	|
| Conditional operation	| `3 > 1`，`nodes.age == 20`，`@default`，`groupName IN ["graph", "database"]`	|
| Logical operation	| `@student && age > 10`	|
| General function operation | `now()`，`toString(nodes.age)`，`length(paths)`	|
| Aggregation function operation | `count(nodes)`，`collect(nodes.age)`	|
| CASE function operation | `CASE WHEN score >= 80 THEN "pass" ELSE "fail" END`	|
| Judgement on null	 | `nodes.age IS NULL`，`edges.time IS NOT NULL` |
