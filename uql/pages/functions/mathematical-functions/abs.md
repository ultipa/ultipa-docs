# abs()

Function `abs()` calculates the absolute value of a number, the return is non-negative.

Arguments：
- Number \<number>

Returns：
- Absolute value \<number>, non-negative

## Common Usage

Example: Calculate the absolute value of each row of an alias
<p run-tag="true" graph="uql_manual_graph_1"></p> 

```js
uncollect [1, -2.5, 3.7] as a
return abs(a)
```
<p tit="Result"></p>

```bash
1
2.5
3.7
```

