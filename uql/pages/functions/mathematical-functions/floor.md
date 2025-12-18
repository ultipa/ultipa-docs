# floor()

Function `floor()` rounds down a given number to its floor, namely returns the largest integer that is no greater than the number.

Arguments：
- Number \<number>

Returns：
- Floor \<number>

## Common Usage

Example: Round down each row of an alias 
 

```uql
uncollect [1, -2.5, 3.7] as a
return floor(a)
```
<p tit="Result"></p>

```
1
-3
3
```

