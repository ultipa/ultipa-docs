## Process and Job

This section introduces methods for managing processes and jobs.

## Process

### top()

Retrieves all running processes in the database.
 
**Parameters**

- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `List[Process]`: The list of retrieved processes.

```python
# Retrieves all running processes in the database

processes = Conn.top()
for process in processes:
    print(process.processId, "-", process.processQuery)
```

<p tit="Output"></p> 

```
1049542 - MATCH p = ()->{1,3}() RETURN p LIMIT 5000
```

### kill()

Kills running processes in the database.

**Parameters**

- `processId: str`: ID of the process to kill.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```python
# Retrieves all running processes in the database and kills them all

processes = Conn.top()
for process in processes:
    response = Conn.kill(process.processId)
    print(process.processId, "-", process.processQuery, "- Kill", response.status.code.name)
```

<p tit="Output"></p> 

```
1049607 - MATCH p = ()->{1,3}() RETURN p LIMIT 5000 - Kill SUCCESS
```

## Job

### showJob()

Retrieves jobs in the graph.
 
**Parameters**

- `id: str` (Optional): Job ID.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `List[Job]`: The list of retrieved jobs.

```python
# Retrieves all failed jobs in the graph 'miniCircle'

requestConfig = RequestConfig(graph="miniCircle")

jobs = Conn.showJob(config=requestConfig)
failed_jobs = [job for job in jobs if job.status == "FAILED"]

if failed_jobs:
    for job in failed_jobs:
        print(job.id, "-", job.type, "-", job.errMsg)
else:
    print("No failed jobs")
```

<p tit="Output"></p>

```
64 - CREATE_FULLTEXT - Fulltext name already exists.
56 - CREATE_INDEX - @account.year does not exist.
55 - CREATE_INDEX - @transfer.year does not exist.
53 - CREATE_INDEX - String type must set index length.
40 - CREATE_HDC_GRAPH - The projection aa already existed!
27 - CREATE_HDC_GRAPH - Hdc server sss not found.
```

### stopJob()

Stops a running job in the graph.
 
**Parameters**

- `id: str`: ID of the job to stop.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```python
# Retrieves all running jobs in the graph 'miniCircle' and stops them all

requestConfig = RequestConfig(graph="miniCircle")

jobs = Conn.showJob(config=requestConfig)
running_jobs = [job for job in jobs if job.status == "RUNNING"]

for running_job in running_jobs:
    response = Conn.stopJob(running_job.id, requestConfig)
    print(running_job.id, "-", running_job.type, "- Stop", response.status.code.name)
```

<p tit="Output"></p>

```
26 - CREATE_HDC_GRAPH - Stop SUCCESS
```

### clearJob()

Clears a job that is not running from the graph.
 
**Parameters**

- `id: str`: ID of the job to clear.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```python
# Retrieves all failed jobs in the graph 'miniCircle' and clears them all

requestConfig = RequestConfig(graph="miniCircle")

jobs = Conn.showJob(config=requestConfig)
failed_jobs = [job for job in jobs if job.status == "FAILED"]

if failed_jobs:
    for job in failed_jobs:
        response = Conn.clearJob(job.id, requestConfig)
        print("Clear", job.id, response.status.code.name)
else:
    print("No failed jobs")
```

<p tit="Output"></p>

```
Clear 51 SUCCESS
Clear 42 SUCCESS
Clear 26 SUCCESS
Clear 26_1 SUCCESS
Clear 17 SUCCESS
Clear 17_1 SUCCESS
```

## Full Example

<p tit="Example.py"></p>

```python
from ultipa import UltipaConfig, Connection, RequestConfig

ultipaConfig = UltipaConfig()
# URI example: ultipaConfig.hosts = ["mqj4zouys.us-east-1.cloud.ultipa.com:60010"]
ultipaConfig.hosts = ["192.168.1.85:60061", "192.168.1.87:60061", "192.168.1.88:60061"]
ultipaConfig.username = "<username>"
ultipaConfig.password = "<password>"

Conn = Connection.NewConnection(defaultConfig=ultipaConfig)

# Retrieves all failed jobs in the graph 'miniCircle'

requestConfig = RequestConfig(graph="miniCircle")

jobs = Conn.showJob(config=requestConfig)
failed_jobs = [job for job in jobs if job.status == "FAILED"]

if failed_jobs:
    for job in failed_jobs:
        print(job.id, "-", job.type, "-", job.errMsg)
else:
    print("No failed jobs")
```
