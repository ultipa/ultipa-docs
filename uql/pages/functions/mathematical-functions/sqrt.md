# sqrt()

Function `sqrt()` calculates the square root of a number, both the argument and the return are non-negative.

Arguments：
- Base \<number>, non-negative

Returns：
- Square root \<number>, non-negative

## Common Usage

Example: Calculate the square root of each row of an alias
 

```uql
uncollect [1,4,9] as a
return sqrt(a)
```
<p tit="Result"></p>

```
1
2
3
```

