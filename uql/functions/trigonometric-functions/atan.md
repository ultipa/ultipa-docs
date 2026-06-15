# atan()

Function `atan()` calculates the radian of a tangent value.

Arguments：
- Tangent \<number>

Returns：
- Radian \<number>, ∈ [-PI/2, PI/2]

## Common Usage

Example: Calculate the radian of tangent value 1
 

```uql
return atan(1) * 180 / pi()
```
<p tit="Result"></p>

```
45
```

Example: Calculate the radian of each row (tangent value) of an alias
 

```uql
uncollect [1, -0.5, 0] as a
return atan(a)
```
<p tit="Result"></p>

```
0.785398163397448
-0.463647609000806
0
```