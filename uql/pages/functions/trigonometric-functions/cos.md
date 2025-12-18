# cos()

Function `cos()` calculates the cosine value of a radian.

Arguments：
- Radian \<number>

Returns：
- Cosine \<number>, ∈ [-1, 1]

## Common Usage

Example: Calculate the cosine value of degree 60°
 

```uql
return cos(60 * pi() / 180)
```
<p tit="Result"></p>

```
0.5
```

Example: Calculate the cosine value of each row (radian) of an alias
 

```uql
uncollect [1, 2.5, 3] as a
return cos(a)
```
<p tit="Result"></p>

```
0.54030230586814
-0.801143615546934
-0.989992496600445
```
