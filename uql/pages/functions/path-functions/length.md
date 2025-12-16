# length()

Function `length()` returns the length of the path, namely, the number of edges in the path.

Arguments：
- Path \<path>

Returns：
- Length \<number>

Sample graph: (to be used for the following examples)

<div align=center drawio-diagram='6094' drawio-name="draw_7d6a28dbf9f54170ac9537f312b2e3d8.jpg"><img src="https://img.ultipa.cn/draw/draw_7d6a28dbf9f54170ac9537f312b2e3d8.jpg?v=''"/></div>
Run below UQLs one by one in an empty graphset to create graph data:
<p tit="" fold="true"></p>

```js
create().node_schema("firm").node_schema("human").edge_schema("hold")
create().edge_property(@hold, "portion", double)
insert().into(@firm).nodes([{_id:"F001", _uuid:1}, {_id:"F002", _uuid:2}])
insert().into(@human).nodes([{_id:"H001", _uuid:3}, {_id:"H002", _uuid:4}])
insert().into(@hold).edges([{_uuid:1, _from_uuid:3, _to_uuid:1, portion:0.3}, {_uuid:2, _from_uuid:2, _to_uuid:1, portion:0.7}, {_uuid:3, _from_uuid:3, _to_uuid:2, portion:0.4}, {_uuid:4, _from_uuid:4, _to_uuid:2, portion:0.6}])
```

## Common Usage

Example: Calculate the share holding path of each UBO from F001, return their respective lengths
<p run-tag="true" graph="uql_manual_graph_3"></p>

```js
n({_id == "F001"}).le()[:5].n({@human} as UBO) as p
return table(UBO._id, length(p))
```
<p tit="Result"></p>

```bash
| UBO._id | length(p) |
|---------|-----------|
| H002    | 2         |
| H001    | 2         |
| H001    | 1         |
```

