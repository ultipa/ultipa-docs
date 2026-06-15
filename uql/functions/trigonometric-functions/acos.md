# acos()

Function `acos()` calculates the radian of a cosine value.

Arguments：
- Cosine \<number>, ∈ [-1, 1]

Returns：
- Radian \<number>, ∈ [-PI/2, PI/2]

## Common Usage

Example: Calculate the radian of cosine value 0.5
 

```uql
return acos(0.5) * 180 / pi()
```
<p tit="Result"></p>

```
60
```

Example: Calculate the radian of each row (cosine value) of an alias
 

```uql
uncollect [1, -0.5, 0] as a
return acos(a)
```
<p tit="Result"></p>

```
0
2.0943951023932
1.5707963267949
```
