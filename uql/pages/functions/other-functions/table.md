# table()

Function `table()` combines multiple values into one row of a table.

Arguments：
- Any value \<any> (`_uuid` of NODE/EDGE, do not support PATH)
- ...

Returns：
- Table \<table>

## Common Usage

Exalmple: Direct calculate
 

```js
uncollect [1,2] as a
uncollect [3,4] as b
return table(a, b)
```
<p tit="Result"></p>

```bash
| a | b |
|---|---|
| 1 | 3 |
| 2 | 4 |
```


Exalmple: Multiply and calculate
 

```js
uncollect [1,2] as a
uncollect [3,4] as b
with table(a, b) as c
return c
```
<p tit="Result"></p>

```bash
| a | b |
|---|---|
| 1 | 3 |
| 1 | 4 |
| 2 | 3 |
| 2 | 4 |
```

