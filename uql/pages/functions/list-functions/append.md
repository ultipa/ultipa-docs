# append()

Function `append()` adds an element to the end of a list and returns this list.

Arguments：
- List \<list>
- Element \<any>

Returns：
- List \<list>

## Common Usage

Exalmple: Direct calculate
<p run-tag="true" graph="uql_manual_graph_1"></p>

```js
uncollect [["a","b"],["c","d"]] as a
uncollect ["X","Y"] as b
return append(a, b)
```
<p tit="Result"></p>

```bash
| append(a, b)  |
|---------------|
| ["a","b","X"] |
| ["c","d","Y"] |
```

Exalmple: Multiply and calculate
<p run-tag="true" graph="uql_manual_graph_1"></p>

```js
uncollect [["a","b"],["c","d"]] as a
uncollect ["X","Y"] as b
with append(a, b) as c
return c
```
<p tit="Result"></p>

```bash
|       c       |
|---------------|
| ["a","b","X"] |
| ["a","b","Y"] |
| ["c","d","X"] |
| ["c","d","Y"] |
```

null
