# Update Nodes

Update nodes based on `_id` or `_uuid`.

- Request URL
<p run-tag="false" graph="" tit= "URL" ></p>

```bash
.../update/nodes
```

- Request Parameter

| Parameter	| Type	| Required	| <div table-width=50>Description</div>	|
|-|-|-|-|
| nodes			| [{},{},...] (JSON), map (FORM)	| yes		| Node properties, must include `_id` or `_uuid`, if both are included then ignore `_uuid`; in tools such as Postman, set multiple `nodes` with type `{}` as FORM parameter 	|
| graph			| string		| no 		| The graphset name (default value: the graphset designated when starting the API service)	|

- Request Example
<p run-tag="false" graph="" tit= "JSON" ></p>

```json
{
    "nodes": [{"age":"35", "_id":"USER001"}, {"name":"John", "_id": "USER002"}],
    "graph": "test_text"
}
```

- Success Response
<p run-tag="false" graph="" tit= "JSON" ></p>

```json
{
    "Msg": "Update nodes on test_text",
    "SuccessCount": 2
}
```

