# Update Edges

Update edges based on `_from`&`_to` or `_uuid`.

- Request URL
<p run-tag="false" graph="" tit= "URL" ></p>

```bash
.../update/edges
```

- Request Parameter

| Parameter	| Type	| Required	| <div table-width=50>Description</div>	|
|-|-|-|-|
| edges			| [{},{},...] (JSON), map (FORM)	| yes		| Edge properties, must carry `_from`&`_to` or `_uuid`, if both are included then ignore `_uuid`; in tools such as Postman, set multiple `edges` with type `{}` as FORM parameter 	|
| graph			| string		| no 		| The graphset name (default value: the graphset designated when starting the API service)	|

- Request Example
<p run-tag="false" graph="" tit= "JSON" ></p>

```json
{
    "edges": [{"_uuid":"1","_from_uuid":"2", "age":"55"}],
    "graph": "test_text"
}
```

- Success Response
<p run-tag="false" graph="" tit= "JSON" ></p>

```json
{
    "Msg": "Update edges on test_text",
    "SuccessCount": 1
}
```


