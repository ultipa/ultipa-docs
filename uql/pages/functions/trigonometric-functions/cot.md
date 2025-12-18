# cot()

Function `cot()` calculates the cotangent value of a radian.

Arguments：
- Radian \<number>

Returns：
- Cotangent \<number>

## Common Usage

Example: Calculate the cotangent value of degree 45° 
 

```uql
return cot(45 * pi() / 180)
```
<p tit="Result"></p>

```
1
```

Example: Calculate the cotangent value of each row (radian) of an alias
 

```uql
uncollect [1, 2.5, 3] as a
return cot(a)
```
<p tit="Result"></p>

```
0.642092615934331
-1.33864812830415
-7.01525255143453
```
