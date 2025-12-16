# pnodes()

Function `pnodes()` collects the all NODEs in a path in a list, and return this list.

Arguments：
- Path \<path>

Returns：
- NODE list \<list>

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

Example: Calculate the share holding path of each UBO from F001, return the NODE list of each path
<p run-tag="true" graph="uql_manual_graph_3"></p>

```js
n({_id == "F001"}).le()[:5].n({@human} as UBO) as p
return pnodes(p)
```
<p tit="Result"></p>

```bash
[{"id":"F001","uuid":"1","schema":"firm","values":{}},{"id":"H001","uuid":"3","schema":"human","values":{}}]
[{"id":"F001","uuid":"1","schema":"firm","values":{}},{"id":"F002","uuid":"2","schema":"firm","values":{}},{"id":"H001","uuid":"3","schema":"human","values":{}}]
[{"id":"F001","uuid":"1","schema":"firm","values":{}},{"id":"F002","uuid":"2","schema":"firm","values":{}},{"id":"H002","uuid":"4","schema":"human","values":{}}]
```
