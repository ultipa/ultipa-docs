# asin()

Function `asin()` calculates the radian of a sine value.

Arguments：
- Sine \<number>, ∈ [-1, 1]

Returns：
- Radian \<number>, ∈ [-PI/2, PI/2]

## Common Usage

Example: Calculate the radian of sine value 0.5
<p run-tag="true" graph="uql_manual_graph_1"></p> 

```js
return asin(0.5) * 180 / pi()
```
<p tit="Result"></p>

```bash
30
```

Example: Calculate the radian of each row (sine value) of an alias
<p run-tag="true" graph="uql_manual_graph_1"></p> 

```js
uncollect [1, -0.5, 0] as a
return asin(a)
```
<p tit="Result"></p>

```bash
1.5707963267949
-0.523598775598299
0
```
