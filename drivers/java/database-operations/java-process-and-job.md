# Process and Job

This section introduces methods for managing processes and jobs.

## Process

### top()

Retrieves all running processes in the database.
 
**Parameters**

- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `List<Process>`: The list of retrieved processes.

```java
// Retrieves all running processes in the database

List<Process> processes = driver.top();
for (Process process : processes) {
    System.out.println(process.getProcessId() + " - " + process.getProcessQuery());
}
```

<p tit="Output"></p> 

```
1049542 - MATCH p = ()->{1,3}() RETURN p LIMIT 5000
```

### kill()

Kills running processes in the database.

**Parameters**

- `processId: String`: ID of the process to kill.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```java
// Retrieves all running processes in the database and kills them all

List<Process> processes = driver.top();
for (Process process : processes) {
    Response response = driver.kill(process.getProcessId());
    System.out.println(process.getProcessId() + " - " + process.getProcessQuery() + " - Kill " + response.getStatus().getCode());
}
```

<p tit="Output"></p> 

```
1049607 - MATCH p = ()->{1,3}() RETURN p LIMIT 5000 - Kill SUCCESS
```

## Job

### showJob()

Retrieves jobs in the graph.
 
**Parameters**

- `id: String` (Optional): Job ID.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `List<Job>`: The list of retrieved jobs.

```java
// Retrieves all failed jobs in the graph 'miniCircle'

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("miniCircle");

List<Job> jobs = driver.showJob(requestConfig);
List<Job> failed_jobs = jobs.stream()
		.filter(job -> "FAILED".equals(job.getStatus()))
		.collect(Collectors.toList());

if (!failed_jobs.isEmpty()) {
  	for (Job job : failed_jobs) {
    	System.out.println(job.getId() + " - " + job.getType() + " - " + job.getErrMsg());
  }
} else {
  	System.out.println("No failed jobs");
}
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

- `id: String`: ID of the job to stop.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```java
// Retrieves all running jobs in the graph 'miniCircle' and stops them all

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("miniCircle");

List<Job> jobs = driver.showJob(requestConfig);
List<Job> running_jobs = jobs.stream()
		.filter(job -> "RUNNING".equals(job.getStatus()))
  	    .collect(Collectors.toList());

for (Job running_job : running_jobs) {
  	Response response = driver.stopJob(running_job.getId(), requestConfig);
  	System.out.println(running_job.getId() + " - " + running_job.getType() + " - Stop " + response.getStatus().getCode());
}
```

<p tit="Output"></p>

```
10 - CREATE_HDC_GRAPH - Stop SUCCESS
```

### clearJob()

Clears a job that is not running from the graph.
 
**Parameters**

- `id: String`: ID of the job to clear.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```java
// Retrieves all running jobs in the graph 'miniCircle' and stops them all

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("miniCircle");

List<Job> jobs = driver.showJob(requestConfig);
List<Job> failed_jobs = jobs.stream()
		.filter(job -> "FAILED".equals(job.getStatus()))
  		.collect(Collectors.toList());

if (!failed_jobs.isEmpty()) {
  	for (Job job : failed_jobs) {
    	Response response = driver.clearJob(job.getId(), requestConfig);
    	System.out.println("Clear " + job.getId() + " " + response.getStatus().getCode());
  	}
} else {
 	System.out.println("No failed jobs");
}
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

<p tit="Main.java"></p>

```java
package com.ultipa.www.sdk.api;

import com.google.common.collect.Lists;
import com.ultipa.sdk.UltipaDriver;
import com.ultipa.sdk.connect.conf.RequestConfig;
import com.ultipa.sdk.connect.conf.UltipaConfig;
import com.ultipa.sdk.operate.entity.*;

import java.util.*;
import java.util.stream.Collectors;

public class Main {
    public static void main(String[] args) {
        UltipaConfig ultipaConfig = UltipaConfig.config()
               // URI example: .hosts(Lists.newArrayList("d3026ac361964633986849ec43b84877s.eu-south-1.cloud.ultipa.com:8443"))
                .hosts(Lists.newArrayList("192.168.1.85:60061","192.168.1.88:60061","192.168.1.87:60061"))
                .username("<username>")
                .password("<password>");

        UltipaDriver driver = null;

        try {
            driver = new UltipaDriver(ultipaConfig);

            // Retrieves all failed jobs in the graph 'miniCircle'

            RequestConfig requestConfig = new RequestConfig();
            requestConfig.setGraph("miniCircle");

            List<Job> jobs = driver.showJob(requestConfig);
            List<Job> failed_jobs = jobs.stream()
                    .filter(job -> "FAILED".equals(job.getStatus()))
                    .collect(Collectors.toList());

            if (!failed_jobs.isEmpty()) {
                for (Job job : failed_jobs) {
                    System.out.println(job.getId() + " - " + job.getType() + " - " + job.getErrMsg());
                }
            } else {
                System.out.println("No failed jobs");
            }

        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        } finally {
            if (driver != null) {
                driver.close();
            }
        }
    }
}
```
