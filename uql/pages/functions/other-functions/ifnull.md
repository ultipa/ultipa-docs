# ifnull()

Function `ifnull()` returns the left-most non <i>null</i> value from two values, or returns `null` if both values are `null`.

> When two values are of different data structures, data conversion might be triggered to guarantee a consistent data type in the final column.

> Occasions when `null` value is produced: properties not provided when inserting data, properties created after data is inserted, calling a property that is not existent.

Arguments：
- Value1 \<any>
- Value2 \<any>

Returns：
- Result \<any>


Sample graph: (to be used for the following examples)

<div align=center drawio-diagram='6103' drawio-name="draw_f8859ab69627473fa7374cb5d6806aea.jpg"><img src="https://img.ultipa.cn/draw/draw_f8859ab69627473fa7374cb5d6806aea.jpg?v=''"/></div>
Run below UQLs one by one in an empty graphset to create graph data:

```js
create().node_property(@default, "name").node_property(@default, "try1", int32).node_property(@default, "try2", int32).node_property(@default, "try3", int32)
insert().into(@default).nodes([{name:"Jason", try1:84}, {name:"Alice", try1:55, try2:79}, {name:"Lina"}, {name:"Eric", try1:39, try2:46, try3:61}, {name:"Pepe", try1:89}])
```

## Common Usage

Example: Return the score of the last re-test that each student takes, knowing that each student has three chances, and retesting is allowed only if the previous one failed. Return `null` if a student does not give any try.
 

```js
find().nodes() as n
return table(n.name, ifnull(n.try3, n.try2))
```
<p tit="Result"></p>

```bash
| n.name | ifnull(n.try3, n.try2) |
|--------|------------------------|
| Jason  | null                   |
| Alice  | 79                     |
| Lina   | null                   |
| Eric   | 61                     |
| Pepe   | null                   |
```