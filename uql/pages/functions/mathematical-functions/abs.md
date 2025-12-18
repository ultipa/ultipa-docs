# abs()

Function `abs()` calculates the absolute value of a number, the return is non-negative.

Arguments：
- Number \<number>

Returns：
- Absolute value \<number>, non-negative

## Common Usage

Example: Calculate the absolute value of each row of an alias
 

```uql
uncollect [1, -2.5, 3.7] as a
return abs(a)
```
<p tit="Result"></p>

```
1
2.5
3.7
```

