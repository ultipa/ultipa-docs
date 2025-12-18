# DISTINCT

Deduplicates rows united by multiple aliases.

- Expression: DISTINCT `alias1`, `alias2`, ...


## Comman Usage

Example: Direct deduplicate
 

```uql
uncollect [1,2,1,2] as a
uncollect [3,4,5,4] as b
return distinct a, b
```
<p tit="Result-a"></p>

```bash
1
2
1
```
<p tit="Result-b"></p>

```bash
3
4
5
```

Example: Multiply and deduplicate
 

```uql
uncollect [1,2,1,2] as a
uncollect [3,4,5,4] as b
with distinct a, b
return a, b
```
<p tit="Result-a"></p>

```bash
1
1
1
2
2
2
```
<p tit="Result-b"></p>

```bash
3
4
5
3
4
5
```