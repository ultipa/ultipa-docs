# CONTAINS | Full-Text

Judges whether the fulltext index of a property contains another (or more) string.

- Expression: ~`<fulltext>` CONTAINS "`<value1>`* `<value2>`* ..."
- Left operand: full-text index
- Right operand: string constant
- Pattern: fuzzy match (with star \*) or precise match (w/o star \*), refer to <i>Full-text Index</i> for details

> This operator exists only in Ultipa filter and cannot appear as an expression in a UQL clause.

## Common Usage

Example: Find products that contain keywords 'graph' and 'database' by the full-text index named 'prodDesc'
```js
find().nodes({~prodDesc contains "graph database"}) 
return nodes
```

Please refer to <i>Index | Full-text | LTE</i> - <i>Full-text Index</i> for more examples.


