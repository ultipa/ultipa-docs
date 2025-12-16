# Send UQL

- Request URL
<p run-tag="false" graph="" tit= "URL" ></p>

```bash
.../uql
```

- Request Parameter

| Parameter	| Type	| Required	| <div table-width=50>Description</div>	|
|-|-|-|-|
| uql			| string		| yes		| UQL statement		|
| graph			| string		| no 		| The graphset name (default value: the graphset designated when starting the API service)	|

- Request Example
<p run-tag="false" graph="" tit= "JSON" ></p>

```json
{
    "uql": "find().nodes({name == \"abc\"}) return count(nodes)",
    "graph": "test_text"
}
```

- Success Response
<p run-tag="false" graph="" tit= "JSON" ></p>

```json
{
    "Data": [
        {
            "Name": "count(nodes)",
            "PropertyType": 4,
            "Rows": [
                2
            ]
        }
    ],
    "Graph": "test_text",
    "Statistic": {
        "NodeAffected": 0,
        "EdgeAffected": 0,
        "TotalCost": 0,
        "EngineCost": 0
    },
    "Status": {
        "Message": "",
        "Code": 0
    }
}
```

