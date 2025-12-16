# Insert Edges

- Request URL
<p run-tag="false" graph="" tit= "URL" ></p>

```bash
.../insert/edges
```

- Request Parameter

| Parameter	| Type	| Required	| <div table-width=50>Description</div>	|
|-|-|-|-|
| edges			| [{},{},...] (JSON), map (FORM)	| yes		| Edge properties, must carry `_from`&`_to` and all custom properties, do not support `_uuid`, `_from_uuid` or `_to_uuid`; in tools such as Postman, set multiple `edges` with type `{}` as FORM parameter 	|
| schema		| string		| yes		| Edge schema		|
| graph			| string		| no 		| The graphset name (default value: the graphset designated when starting the API service)	|
| sync			| bool			| no		| If return the status of request (default value: false). A 'true' value will induce batch waiting time	(`-d`, `--duration`) when the data volume is less than batch size (`-b`, `--batch`), which	will affect the insert performance	|

- Request Example
<p run-tag="false" graph="" tit= "JSON" ></p>

```json
{
    "edges": [{"year":"1998", "_from":"USER001", "_to":"USER002"}],
    "schema": "default",
    "graph": "test_text",
    "sync": true
}
```

- Success Response
<p run-tag="false" graph="" tit= "JSON" ></p>

```json
{
    "Msg": "Insert Edges Success: [{\"_from\":\"USER001\",\"_to\":\"USER002\",\"year\":\"1998\"}]"
}
```

