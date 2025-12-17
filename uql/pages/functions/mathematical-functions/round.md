# round()

Function `round()` calculates the nearest value of a given number, corrected to a designated position of digit; when two nearest values are found, returns the one with larger absolute value. 

Arguments：
- Number \<number>
- Position of digit \<integer>，-1 for '10', 0 (default) for '1', 1 for '0.1', and so on

Returns：
- Round \<number> 

## Common Usage

Example: Direct calculate
<p run-tag="true" graph="uql_manual_graph_1"></p> 

```js
uncollect [-3.75, 7.55] as a
uncollect [0, 1] as b
return table(a, b, round(a, b))
```
<p tit="Result"></p>

```bash
|  a    | b | round(a, b) |
|-------|---|-------------|
| -3.75 | 0 | -4          |
| 7.55  | 1 | 7.6         |
```

Example: Multiply and calculate
<p run-tag="true" graph="uql_manual_graph_1"></p> 

```js
uncollect [-3.75, 7.55] as a
uncollect [0, 1] as b
with round(a, b) as c 
return table(a, b, c)
```
<p tit="Result"></p>

```bash
|  a    | b |   c  |
|-------|---|------|
| -3.75 | 0 | -4   |
| -3.75 | 1 | -3.8 |
| 7.55  | 0 | 8    |
| 7.55  | 1 | 7.6  |
```