# atan()

Function `atan()` calculates the radian of a tangent value.

Arguments：
- Tangent \<number>

Returns：
- Radian \<number>, ∈ [-PI/2, PI/2]

## Common Usage

Example: Calculate the radian of tangent value 1
<p run-tag="true" graph="uql_manual_graph_1"></p> 

```js
return atan(1) * 180 / pi()
```
<p tit="Result"></p>

```bash
45
```

Example: Calculate the radian of each row (tangent value) of an alias
<p run-tag="true" graph="uql_manual_graph_1"></p> 

```js
uncollect [1, -0.5, 0] as a
return atan(a)
```
<p tit="Result"></p>

```bash
0.785398163397448
-0.463647609000806
0
```