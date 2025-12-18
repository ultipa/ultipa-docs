# tan()

Function `tan()` calculates the tangent value of a radian.

Arguments：
- Radian \<number>

Returns：
- Tangent \<number>, ∈ [-1, 1]

## Common Usage

Example: Calculate the tangent value of degree 45°
 

```js
return tan(45 * pi() / 180)
```
<p tit="Result"></p>

```bash
1
```

Example: Calculate the tangent value of each row (radian) of an alias
 

```js
uncollect [1, 2.5, 3] as a
return tan(a)
```
<p tit="Result"></p>

```bash
1.5574077246549
-0.74702229723866
-0.142546543074278
```
