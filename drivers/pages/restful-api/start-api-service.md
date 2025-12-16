# Start API Service

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

