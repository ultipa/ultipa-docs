# Path Template

## Overview

A path template `n()...n()` defines a specific structure of paths, with node and edge templates chained in sequence. A path template retrieves paths from the graph that match the described pattern or structure.

### Node and Edge Templates

Node and edge templates serve as building blocks for constructing path templates. There are four node and edge templates:

| <div table-width=20>Template</div> | <div table-width=18>Name</div> | Description | <div table-width=8>Alias Type</div> |
| -- | -- | -- | -- |
| `n()` | **Single-node** | Represents a single node in a path: <div align=center drawio-diagram='15254' drawio-name="draw_a5e5d5bb20634cb79ccd87e1bb4461cb.jpg"><img src="https://img.ultipa.cn/draw/draw_a5e5d5bb20634cb79ccd87e1bb4461cb.jpg?v='1713160539270'"/></div> | `NODE` |
| `e()`, `le()`, `re()` | **Single-edge**<br>(Direction: both, left, right) | Represents a single edge in a path: <div align=center drawio-diagram='15255' drawio-name="draw_116eeaf138e647b5b3bd8713b0561e48.jpg"><img src="https://img.ultipa.cn/draw/draw_116eeaf138e647b5b3bd8713b0561e48.jpg?v='1732594397928'"/></div> | `EDGE` |
| `e()[<steps>]`,<br>`le()[<steps>]`,<br>`re()[<steps>]` | **Multi-edge**<br>(Direction: both, left, right) | Represents multiple consecutive edges in a path: <div align=center drawio-diagram='15256' drawio-name="draw_99b64bee6de9498ba1935ef18e25e91a.jpg"><img src="https://img.ultipa.cn/draw/draw_99b64bee6de9498ba1935ef18e25e91a.jpg?v='1732595120613'"/></div>Format of `[<steps>]` (N≥0):<br><ul><li>`[N]`: N edges</li><li>`[:N]`: 1 ~ N edges</li><li>`[N:M]`: N ~ M edges</li><li>`[*:N]`: the shortest paths within N edges</li></ul>When a depth of `0` is involved, it is valid only if the node preceding the edge template can be merged with the node following it. In such cases, the edge template is ignored, and the two nodes on either side are considered a single node. | N/A |
| `e().nf()[<steps>]`,<br>`le().nf()[<steps>]`,<br>`re().nf()[<steps>]` | **Multi-edge with intermediates**<br>(Direction: both, left, right) | Represents multiple consecutive edges and nodes between them in a path: <div align=center drawio-diagram='15257' drawio-name="draw_5916d03e953e4786bd97c19039f03184.jpg"><img src="https://img.ultipa.cn/draw/draw_5916d03e953e4786bd97c19039f03184.jpg?v='1732595280719'"/></div>Format of `[<steps>]` is the same as multi-edge template. | N/A |

**Filters** enclosed in `{}` can be used inside the parentheses of node and edge templates to specify their schema and properties. Additionally, the first single-node template `n()` in a path template allows direct referencing of an alias.

### Constructing Path Templates

A path begins and ends with a node, alternating between nodes and edges throughout. Notably, a path can also consist of a single node without any edges. By following this rule, you can construct the path template to suit the specific scenario. The following are some examples.

To find books recommended by users whom Kavi likes:

<div align=center drawio-diagram='19576' drawio-name="draw_223a298c1c534f679991f9e97c2a25df.jpg"><img src="https://img.ultipa.cn/draw/draw_223a298c1c534f679991f9e97c2a25df.jpg?v='1732610727466'"/></div>

```uql
n({@user.name == "Kavi"}).re({@likes}).n({@user}).re({@recommends}).n({@books} as b)
return b.name
```

To find 1 to 3 step outgoing transaction paths from accounts owned by `C34` to accounts owned by `C135`:

<div align=center drawio-diagram='19577' drawio-name="draw_a6541fe9d272436e87deaad7f22a9191.jpg"><img src="https://img.ultipa.cn/draw/draw_a6541fe9d272436e87deaad7f22a9191.jpg?v='1732602401025'"/></div>

```uql
n({_id == "C34"}).re({@owns}).n({@account}).re({@transfers})[3].n({@account}).le({@owns}).n({_id == "C135"}) as p
return p{*}
```

To find 3-step transaction paths from accounts owned by `C34` to accounts owned by `C135`, where intermediate accounts have a `level` greater than 4:

<div align=center drawio-diagram='19578' drawio-name="draw_5fdfc8c9f0074e20a1f4ddc9229a3342.jpg"><img src="https://img.ultipa.cn/draw/draw_5fdfc8c9f0074e20a1f4ddc9229a3342.jpg?v='1732602984866'"/></div>

```uql
n({_id == "C34"}).re({@owns}).n({@account}).e({@transfers}).nf({@account.level > 4})[:3].n({@account}).le({@owns}).n({_id == "C135"}) as p
return p{*}
```

To find circular task dependency paths within 3 to 5 steps:

<div align=center drawio-diagram='19579' drawio-name="draw_0445930ecc8e4cc4b2aa4e8882b4de87.jpg"><img src="https://img.ultipa.cn/draw/draw_0445930ecc8e4cc4b2aa4e8882b4de87.jpg?v='1732610690759'"/></div>

```uql
n({@task} as t).re({@dependsOn})[3:5].n({_id == t._id}) as p
return p{*}
```

This query reuses the alias `t` in the path template to form a ring-like structure.

## Syntax

- **Statement alias**: Type `PATH`
- **Methods** that can be chained after the path template:

| <div table-width=13>Method</div> | <div table-width=8>Param</div> | Description | <div table-width=9>Optional</div> | <div table-width=8>Alias Type</div> |
| -- | -- | -- | -- | -- |
| `no_circle()` | / | Excludes paths that form circles. A path has circles when it has repeated nodes. | Yes | N/A |
| `limit()` | `<N>` | Limits the number of paths (`N`≥-1) returned for each start node; `-1` includes all paths. | Yes | N/A |

## Example Graph 1

<div align=center drawio-diagram='19580' drawio-name="draw_cdb019a197104e259dd653bf1585c437.jpg"><img src="https://img.ultipa.cn/draw/draw_cdb019a197104e259dd653bf1585c437.jpg?v='1733903454793'"/></div>

To create the graph, execute each of the following UQL queries sequentially in an empty graphset:

```uql
create().node_schema("country").node_schema("movie").node_schema("director").edge_schema("filmedIn").edge_schema("direct").edge_schema("bornIn")
create().node_property(@*, "name").edge_property(@direct, "year", int32).edge_property(@bornIn, "year", int32)
insert().into(@country).nodes([{_id:"C1", name:"France"}, {_id:"C2", name:"USA"}, {_id:"C3", name:"Canada"}])
insert().into(@movie).nodes([{_id:"M1", name:"Léon"}, {_id:"M2", name:"The Terminator"}, {_id:"M3", name:"Avatar"}])
insert().into(@director).nodes([{_id:"D1", name:"Luc Besson"}, {_id:"D2", name:"James Cameron"}])
insert().into(@filmedIn).edges([{_from:"M1", _to:"C1"}, {_from:"M1", _to:"C2"}, {_from:"M2", _to:"C2"}, {_from:"M3", _to:"C2"}])
insert().into(@direct).edges([{_from: "D1", _to: "M1", year: 1994}, {_from: "D2", _to: "M2", year: 1984}, {_from: "D2", _to: "M3", year: 2009}])
insert().into(@bornIn).edges([{_from: "D1", _to: "C1", year: 1959}, {_from: "D2", _to: "C3", year: 1954}])
```

## Finding Nodes

You can declare alias in the single-node template `n()`.

To find `@movie` nodes:

```uql
n({@movie} as m)
return m.name
```

Result:

| m.name |
| -- |
| The Terminator |
| Léon |
| Avatar |

To find countries where the movie `Léon` was filmed:

```uql
n({@movie.name == "Léon"}).e({@filmedIn}).n(as c)
return c.name
```

Result:

| c.name |
| -- |
| France |
| USA |

## Finding Edges

You can declare alias in the single-edge template `e()`.

To find when the movie `The Terminator` was directed:

```uql
n({@movie.name == "The Terminator"}).e({@direct} as d).n()
return d.year
```

Result:

| d.year |
| -- |
| 1984 |

## Finding Fixed Length Paths

To find paths describing all movies filmed in `USA` along with their directors:

```uql
n({@country.name == "USA"}).le().n({@movie}).e().n({@director}) as p
return p{*}
```

Result: `p`

<div align=center drawio-diagram='19754' drawio-name="draw_1327c92378094867bcb9005190990541.jpg"><img src="https://img.ultipa.cn/draw/draw_1327c92378094867bcb9005190990541.jpg?v='1733902733261'"/></div>

To find 2-step connections between movies `Léon` and `The Terminator`:

```uql
n({@movie.name == "Léon"}).e()[2].n({@movie.name == "The Terminator"}) as p
return p{*}
```

Result: `p`

<div align=center drawio-diagram='19755' drawio-name="draw_8224df563cbf43b2ae41aa82577b3778.jpg"><img src="https://img.ultipa.cn/draw/draw_8224df563cbf43b2ae41aa82577b3778.jpg?v='1733902351116'"/></div>

## Finding Variable Length Paths

To find paths within 4 steps between `Luc Besson` and `France`:

```uql
n({name == "Luc Besson"}).e()[:4].n({name == "France"}) as p
return p{*}
```

Result:`p`

<div align=center drawio-diagram='19756' drawio-name="draw_777f656ffb7f4bf89ddceb3d1f6d5dbf.jpg"><img src="https://img.ultipa.cn/draw/draw_777f656ffb7f4bf89ddceb3d1f6d5dbf.jpg?v='1733903042773'"/></div>

To find paths within 4 steps between `Luc Besson` and `France` that do not pass through the movie `Léon`:

```uql
n({name == "Luc Besson"}).e().nf({name != "Léon"})[:4].n({name == "France"}) as p
return p{*}
```

Result: `p`

<div align=center drawio-diagram='19757' drawio-name="draw_5156fbc18cb345538975d38b38be3987.jpg"><img src="https://img.ultipa.cn/draw/draw_5156fbc18cb345538975d38b38be3987.jpg?v='1733903141750'"/></div>

## Finding Shortest Paths

To find the shortest paths within 4 steps between `Luc Besson` and `France`:

```uql
n({name == "Luc Besson"}).e()[*:4].n({name == "France"}) as p
return p{*}
```

Result: `p`

<div align=center drawio-diagram='19757' drawio-name="draw_5156fbc18cb345538975d38b38be3987.jpg"><img src="https://img.ultipa.cn/draw/draw_5156fbc18cb345538975d38b38be3987.jpg?v='1733903141750'"/></div>

## Excluding Circles

To find paths within 4 steps between `Léon` and `USA`:

```uql
n({name == "Léon"}).e()[:4].n({name == "USA"}) as p
return p{*}
```

Result: `p`

<div align=center drawio-diagram='19762' drawio-name="draw_29149f4465c14c99be73befd3bfe4e98.jpg"><img src="https://img.ultipa.cn/draw/draw_29149f4465c14c99be73befd3bfe4e98.jpg?v='1733906601599'"/></div>

To find paths within 4 steps between `Léon` and `USA` without any circles:

```uql
n({name == "Léon"}).e()[:4].n({name == "USA"}).no_circle() as p
return p{*}
```

Result: `p`

<div align=center drawio-diagram='19765' drawio-name='draw_cc2fd2a3775a46bb816770e852d2a77b.jpg'><img src="https://img.ultipa.cn/draw/draw_cc2fd2a3775a46bb816770e852d2a77b.jpg?v='1733906789652'"/></div>

## Using limit()

To find one movie directed by each director:

```uql
n({@director} as d).e().n({@movie} as m).limit(1)
return table(d.name,m.name)
```

Result:

| d.name | m.name |
| -- | -- |
| James Cameron | The Terminator |
| Luc Besson | Léon |

## Using OPTIONAL

In this query, the path template statement executes three times, each time using one record from `c`. With the `OPTIONAL` prefix, the query returns `null` if no result is found during execution:

```uql
find().nodes({@country}) as c
optional n(c).e({@filmedIn}).n({@movie} as m)
return table(c.name, m.name)
```

Result:

| c.name | m.name |
| -- | -- |
| France | Léon |
| Canada | `null` |
| USA | Léon |
| USA | Avatar |
| USA | The Terminator |

Without the prefix `OPTIONAL`, no record is returned for `Canada`:

```uql
find().nodes({@country}) as c
n(c).e({@filmedIn}).n({@movie} as m)
return table(c.name, m.name)
```

Result:

| c.name | m.name |
| -- | -- |
| France | Léon |
| USA | Léon |
| USA | Avatar |
| USA | The Terminator |

## Example Graph 2

<div align=center drawio-diagram='19583' drawio-name="draw_448a0a7269f74b258c474405f6d535ee.jpg"><img src="https://img.ultipa.cn/draw/draw_448a0a7269f74b258c474405f6d535ee.jpg?v='1732676083782'"/></div>

To create the graph, execute each of the following UQL queries sequentially in an empty graphset:

```uql
create().node_schema("customer").node_schema("account").edge_schema("owns").edge_schema("transfers")
create().node_property(@account, "level", uint32).edge_property(@transfers, "time", datetime)
insert().into(@customer).nodes([{_id:"C01"}])
insert().into(@account).nodes([{_id:"A01", level: 2}, {_id:"A02", level: 3}, {_id:"A03", level: 4}, {_id:"A04", level: 2}])
insert().into(@owns).edges([{_from:"C01", _to:"A01"}, {_from:"C01", _to:"A02"}])
insert().into(@transfers).edges([{_from:"A01", _to:"A03", time:"2023-03-01"}, {_from:"A01", _to:"A04", time:"2023-04-25"}, {_from:"A03", _to:"A04", time:"2023-03-27"}, {_from:"A04", _to:"A02", time:"2023-02-15"}])
```

## Including 0 Step

To find 0 to 1 step outgoing transaction paths from accounts held by `C01` to other accounts with a `level` no less than 3:

```uql
n({_id == "C01"}).e().n({@account}).re({@transfers})[0:1].n({@account.level >= 3}) as p
return p
```

Result: `p`

<div align=center drawio-diagram='19766' drawio-name='draw_2e4050d8310644ba9d37d8a3c81b367e.jpg'><img src="https://img.ultipa.cn/draw/draw_2e4050d8310644ba9d37d8a3c81b367e.jpg?v='1733908024192'"/></div>

The `[0:1]` specifies that the traversal can include `0` or `1` step through the `re({@transfers})` relationship. When the step `0` is applied, the `re({@transfers})[0:1]` is effectively ignored, merging the nodes before and after, and the path template simplifies to `n({_id == "C01"}).e().n({@account.level >= 3})`.

In the following query, the merged node `n({@account.level < 3 && @account.level >= 3})` does not exist, thus the step `0` will not yield any result:

```uql
n({_id == "C01"}).e().n({@account.level < 3}).re({@transfers})[0:1].n({@account.level >= 3}) as p
return p
```

Result: `p`

<div align=center drawio-diagram='19767' drawio-name='draw_5af08d547d264525b5a933ff57f075ec.jpg'><img src="https://img.ultipa.cn/draw/draw_5af08d547d264525b5a933ff57f075ec.jpg?v='1733908101442'"/></div>

## Inter-Step Filtering

### prev_n, prev_e

The system aliases `prev_n` and `prev_e` facilitate inter-step filtering in path templates by allowing reference to the previous node or edge at each step.

To find 2-step outgoing transaction paths between accounts with the ascending `time`:

```uql
n().re({@transfers.time > prev_e.time})[2].n() as p
return p
```

Result: `p`

<div align=center drawio-diagram='19768' drawio-name="draw_57e82dc29f714ce19424a52f30bcac18.jpg"><img src="https://img.ultipa.cn/draw/draw_57e82dc29f714ce19424a52f30bcac18.jpg?v='1733908449665'"/></div>

For more details on using `prev_e` and `prev_n`, refer to <a target="_blank" href="/docs/uqlalias#System-Alias">System Alias</a>.

### Reusing Alias

This query achieves the same as <a href="#prev_n,-prev_e">above</a> by reusing the alias declared in the path template:

```uql
n().re({@transfers} as t1).n().re({@transfers.time > t1.time}).n() as p
return p
```

Result: `p`

<div align=center drawio-diagram='19768' drawio-name="draw_57e82dc29f714ce19424a52f30bcac18.jpg"><img src="https://img.ultipa.cn/draw/draw_57e82dc29f714ce19424a52f30bcac18.jpg?v='1733908449665'"/></div>
