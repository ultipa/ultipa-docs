# sin()

Function `sin()` calculates the sine value of a radian.

Arguments：
- Radian \<number>

Returns：
- Sine \<number>, ∈ [-1, 1]

## Common Usage

Example: Calculate the sine value of degree 30°
<p run-tag="true" graph="uql_manual_graph_1"></p> 

```js
return sin(30 * pi() / 180)
```
<p tit="Result"></p>

```bash
0.5
```

Example: Calculate the sine value of each row (radian) of an alias
<p run-tag="true" graph="uql_manual_graph_1"></p> 

```js
uncollect [1, 2.5, 3] as a
return sin(a)
```
<p tit="Result"></p>

```bash
0.841470984807897
0.598472144103957
0.141120008059867
```
