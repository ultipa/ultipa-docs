# listContains()

Function `listContains()` judges whether a <i>list</i> contains a particular element, returns 1 for 'yes' and 0 for 'no'. 

Arguments：
- List \<list>
- Element \<any>

Returns：
- 1 or 0

## Common Usage

Exalmple: Direct calculate


```uql
uncollect [[1,2,3],[2,4,5]] as a
uncollect [3,4] as b
return table(toString(a), b, listContains(a, b))
```
<p tit="Result"></p>

```
| toString(a) | b | listContains(a, b) |
|-------------|---|--------------------|
| [1,2,3]     | 3 | 1                  |
| [2,4,5]     | 4 | 1                  |
```

Exalmple: Multiply and calculate


```uql
uncollect [[1,2,3],[2,4,5]] as a
uncollect [3,4] as b
with listContains(a, b) as c
return table(toString(a), b, c)
```
<p tit="Result"></p>

```
| toString(a) | b | c |
|-------------|---|---|
| [1,2,3]     | 3 | 1 |
| [1,2,3]     | 4 | 0 |
| [2,4,5]     | 3 | 0 |
| [2,4,5]     | 4 | 1 |
```

