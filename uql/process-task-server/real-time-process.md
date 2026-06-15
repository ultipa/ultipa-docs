# Real-time Process

Non-algorithm commands and algorithms that adopt `return` clause are run as process in real-time. The execution result of real-time process will be returned to user once it is done, and will NOT be stored in the Ultipa Server.

Valid operations on real-time process of different status：

| Status | `top()` | `kill()`	|
| ---- | :----: | :----: |
| running	| √		| √		|
| stopped 	| 		| 		|
| completed 	| 		| 		|

## Show Real-time Process

Returned table name: `_top`
<br>
Returned table header: `process_id` | `process_uql` | `duration` (the id, UQL statement and duration (second) of the task)

Syntax:
<p tit="Syntax"></p>

```uql
// To show all real-time processes in the current Ultipa instance
top()
```

## Stop Real-time Process

A stopped process cannot be restarted.

Syntax:
<p tit="Syntax"></p>

```uql
// To kill all real-time processes in the current Ultipa instance
kill("*")

// To kill a certain real-time process in the current Ultipa instance
kill("<process_id>")
```

