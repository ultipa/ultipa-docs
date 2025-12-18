# IS NULL

- Expression: `<value>` IS NULL
- Operand: Any

> The operators `==` and `!=` cannot be used to evaluate null values.

Sample graph: (to be used for the following examples)

<div align=center drawio-diagram='6103' drawio-name="draw_f8859ab69627473fa7374cb5d6806aea.jpg"><img src="https://img.ultipa.cn/draw/draw_f8859ab69627473fa7374cb5d6806aea.jpg?v=''"/></div>
Run below UQLs one by one in an empty graphset to create graph data:

```js
create().node_property(@default, "name").node_property(@default, "try1", int32).node_property(@default, "try2", int32).node_property(@default, "try3", int32)
insert().into(@default).nodes([{name:"Jason", try1:84}, {name:"Alice", try1:55, try2:79}, {name:"Lina"}, {name:"Eric", try1:39, try2:46, try3:61}, {name:"Pepe", try1:89}])
```

## Comman Usage

Example: Return the name of student who didn't take the 2nd test (the 1st re-test)
 

```js
find().nodes({try2 is null }) as n
return n.name
```
<p tit="Result"></p>

```bash
Jason
Lina
Pepe
```

