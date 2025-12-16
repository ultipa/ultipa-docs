# Insert Nodes

- Request URL
<p run-tag="false" graph="" tit= "URL" ></p>

```bash
.../insert/nodes
```

- Request Parameter

| Parameter	| Type	| Required	| <div table-width=50>Description</div>	|
|-|-|-|-|
| nodes			| [{},{},...] (JSON), map (FORM)	| yes		| Node properties, must include all custom properties, do not support `_uuid`; in tools such as Postman, set multiple `nodes` with type `{}` as FORM parameter 	|
| schema		| string		| yes		| Node schema		|
| graph			| string		| no 		| The graphset name (default value: the graphset designated when starting the API service)	|
| sync			| bool			| no		| If return the status of request (default value: false). A 'true' value will induce batch waiting time	(`-d`, `--duration`) when the data volume is less than batch size (`-b`, `--batch`), which	will affect the insert performance	|

- Request Example
<p run-tag="false" graph="" tit= "JSON" ></p>

```json
{
    "nodes": [{"name":"Jason","_id":"USER001"},{"name":"Alice"}],
    "schema": "default",
    "graph": "test_text",
    "sync": true
}
```

- Success Response
<p run-tag="false" graph="" tit= "JSON" ></p>

```json
{
    "Msg": "Insert Nodes Success: [{\"_id\":\"USER001\",\"name\":\"Jason\"},{\"name\":\"Alice\"}]"
}
```

