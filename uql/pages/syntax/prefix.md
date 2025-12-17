# Prefix

## Overview

UQL support the following **prefix** keywords for a clause or the entire UQL statement:

| <div table-width=13>Prefix Keyword</div> | <div table-width=57>Description</div> | Scope |
|-|-|-|
| `TRY` | Used to create new graphsets, schemas and properties without returning an error message in case of failure. Successful creations are unaffected. If not using `TRY`, creation failure will return an error message, such as duplicated names. | Current `create()` clause |
| `OPTIONAL` | Used to verify if each subquery within a query has returns. If a subquery finds no results, null values are returned in place of nodes and/or edges. If not using `OPTIONAL`, subquery with no results will have no return. | Current query clause |
| `EXPLAIN` | Return the operation plan of the entire UQL statement without executing it. | Entire UQL statement |
| `PROFILE` | Return the operation plan of the entire UQL statement and the time cost for each step during its execution. | Entire UQL statement |
| `DEBUG` | Return the number of calls and time cost for each step in the operation plan of the entire UQL statement during its execution. | Entire UQL statement |
| `EXEC TASK` | Send the entire UQL statement to the <a href="/docs/uql/analytics-node">analytics node</a> (algo node) of the cluster for execution | Entire UQL statement |

> Prefix keywords are all case insensitive.

## Examples

### EXPLAIN

```js
explain n({@movie} as movies).e({@filmedIn}).n({@country.name == "US"}) as paths  
group by  movies.genre 
return movies.genre, count(movies)
```

<center><img width=400 src="https://img.ultipa.cn/img/2023-03-27-10-28-41-explain.png" /></center>

### PROFILE

```js
profile n({@movie} as movies).e({@filmedIn}).n({@country.name == "US"}) as paths  
group by  movies.genre 
return movies.genre, count(movies)
```

<center><img width=400 src="https://img.ultipa.cn/img/2023-03-27-10-28-49-profile.png" /></center>

### DEBUG

```js
debug n({@movie} as movies).e({@filmedIn}).n({@country.name == "US"}) as paths  
group by  movies.genre 
return movies.genre, count(movies)
```

<center><img width=400 src="https://img.ultipa.cn/img/2023-03-27-10-28-51-debug.png" /></center>
