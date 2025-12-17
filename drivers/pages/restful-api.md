# RESTful API

> This article introduces the minimum procedure of using Ultipa RESTful API proxy.

## Change Log (V4.0 to V4.2)

- Use Go SDK v4.2 
- Abandon command line parameter `-bodytype`
- Add interfaces `/uql/stream`, `/update/nodes` and `/update/edges`

## Prerequisites

- a command line terminal that is compatible with your operating system: 
    - Linux or MacOS: [bash](https://www.gnu.org/software/bash), [zsh](https://www.zsh.org/), [tcsh](https://www.tcsh.org/)
    - Windows: [PowerShell](https://learn.microsoft.com/en-us/powershell/)
- a version of [Ultipa Importer](https://www.ultipa.com/download) compatible with your operating system


## Start API Service

1. Show help
<p run-tag="false" graph="" tit= "Command" ></p>

```bash
./ultipa_restful_api.exe --help
```

2. Show current version
<p run-tag="false" graph="" tit= "Command" ></p>

```bash
./ultipa_restful_api.exe --version
```

3. Start API service
<p tit="Command"></p>

```bash
./ultipa_restful_api.exe --hosts 192.168.1.85:61095,192.168.1.87:61095,192.168.1.88:61095 -u employee -p joaGsdf -w 3
```
Note: `-hosts`, `-u` and `-p` are equivalent to `--hosts`, `--username` and `--password`
<center><img src="https://img.ultipa.cn/img/2023-05-08-15-10-37-start-api.png"></center>

Other Parameters:

| <div table-width=20>Parameter</div> | Description | <div table-width=20>Default Value</div>	|
|-|-|-|
| -l --listen 	| The network and initial port to listen 			| 0.0.0.0:7001
| -w --workers	| The number of backend workers (threads), e.g.: 5 works will be the default 7001-7005	| 0
| -g --graph 	| The graphset name 								| 'default'
| -b --boost 	| Use SimpleCache									| (Do not use cache)
| -c --consistency	| Use leader to guarantee Consistency Read		| (Do not use leader)
| -batch --batch 	| The batch size (number of records) of `/insert/nodes` and `/insert/edges`			| 5000
| -d --duration		| The batch insert waiting time (milliseconds)	|  1000
| -hb --heartbeat	| The heartbeat seconds for all instances		|  5
| -sd --schema_cache_duration	| The heartbeat milliseconds when acquiring schema list during insert	| 5000

## API Basic Info

- Request type: POST
- Request URL:
  - Linux: the Ultipa server that the current API service connects, e.g. 'http://192.168.1.88'
  - Windows/MacOS: the local address of the current API service, 'http://127.0.0.1'
- Request port: the valid ports set via `-w` and `-l` when starting the API service
- Body parameter type: JSON, FORM

## Login Ultipa Service

- Request URL
<p run-tag="false" graph="" tit= "URL" ></p>

```bash
.../login
```

- Request Example
<p run-tag="false" graph="" tit= "JSON" ></p>

```json
{
    "username": "employee",
    "password": "joaGsdf"
}
```

- Response: the token value after login

> The rest of API interfaces should all have this token value carried in Cookie in the Headers, `ultipa=<token_value>`, with Content_Type `application/json`.

## Send UQL

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

## Send UQL and limit returns

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

## Insert Nodes

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

## Insert Edges

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

## Update Nodes

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

## Update Edges

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