# ceil()

Function `ceil()` rounds up a given number to its ceil, namely returns the smallest integer that is no less than the number.

Arguments：
- Number \<number>

Returns：
- Ceil \<number>

## Common Usage

Example: Round up each row of an alias
 

```js
uncollect [1, -2.5, 3.7] as a
return ceil(a)
```
<p tit="Result"></p>

```bash
1
-2
4
```
