# Send UQL and limit returns

- Request URL
<p run-tag="false" graph="" tit= "URL" ></p>

```bash
.../uql/stream
```

- Request Parameter

| Parameter	| Type	| Required	| <div table-width=50>Description</div>	|
|-|-|-|-|
| uql			| string		| yes		| UQL statement		|
| graph			| string		| no 		| The graphset name (default value: the graphset designated when starting the API service)	|
| package_num	| int			| no		| The number of packages to return (default value: 0, query but do not return)		|

- Request Example
<p run-tag="false" graph="" tit= "JSON" ></p>

```json
{
    "uql": "find().nodes({name == \"abc\"}) return nodes",
    "graph": "test_text",
    "package_num": 1
}
```

- Success Response

