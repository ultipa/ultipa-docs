# pow()

Function `pow()` performs power operation based on the given base and exponent.

Arguments：
- Base \<number>
- Exponent \<number>

Returns：
- Exponentiation \<number>

## Common Usage

Example: Direct calculate
<p run-tag="true" graph="uql_manual_graph_1"></p> 

```js
uncollect [3,4] as a
uncollect [1,2] as b
return table(a, b, pow(a,b))
```
<p tit="Result"></p>

```bash
| a | b | pow(a,b) |
|---|---|----------|
| 3 | 1 | 3        |
| 4 | 2 | 16       |
```

Example: Multiply and calculate
<p run-tag="true" graph="uql_manual_graph_1"></p> 

```js
uncollect [3,4] as a
uncollect [1,2] as b
with pow(a,b) as c
return table(a, b, c)
```
<p tit="Result"></p>

```bash
| a | b | c  |
|---|---|----|
| 3 | 1 | 3  |
| 3 | 2 | 9  |
| 4 | 1 | 4  |
| 4 | 2 | 16 |
```

