# Backend Task

The algorithms adopting `write()` parameter for write-disk operation will be run as tasks in background. The execution result of backend task will be stored in the GraphSet against which it runs, and can be retrieved by user whenever needed until the task is deleted from the Ultipa Server.

Valid operations on backend task of different status：

| Status | Description | `show()`	| `stop()`	| `clear()`	|
|------|-------|:------:|:------:|:------:|
| pending	| Queuing, not executed yet | √ |  | √ |
| computing	| Computing	| √ | √ |  |
| writing	| Writing	| √ | |  |
| stopped	| Stopped | √ |  | √ |
| failed	| Failed | √ |  | √ |
| done		| Done | √ |  | √ |

> Please refer to the algorithm handbook <i>Ultipa Graph Analytics & Algorithms</i> for the usage of parameter `write()`.

## Show Backend Task

Returned table name: `_task`
<br>
Returned table header: `id` | `name` | `params` | `start` | `egnineTime` | `totalTime` | `result` | `status` (the id, name, parameters, start time, engine duration (second), total duration (second), result and current status of the algorithm backend task)

Syntax:
<p tit="Syntax"></p>

```uql
// To show all algorithm backend tasks in the current graphset
show().task()
            
// To show a certain algorithm backend task in the current graphset
show().task(<id>)
            
// To show all tasks of a certain algorithm in the current graphset
show().task("<taskName>", "*")

// To show all algorithm backend tasks of a certain status in the current graphset
show().task("*", "<status>")

// To show all tasks of a certain algorithm and status in the current graphset
show().task("<taskName>", "<status>")
```

Example: Show all algorithm backend tasks of "khop_all"

```uql
show().task("khop_all", "*")
```

Example: Show all algorithm backend tasks that are computing

```uql
show().task("*", "computing")
```

## Stop Backend Task

A stopped task cannot be restarted.

Syntax:
<p tit="Syntax"></p>

```uql
// To stop all backend tasks that are computing in the current graphset
stop().task("*")
            
// To stop a certain backend task that is computing in the current graphset
stop().task(<id>)
```

## Clear Backend Task

Clearing a task will delete all the information of this task from the Ultipa server.

Syntax:
<p tit="Syntax"></p>

```uql
// To clear all algorithm backend tasks in the current graphset (excluding those whose status are computing and writing)
clear().task("*")
            
// To clear a certain algorithm backend task in the current graphset (excluding those whose status are computing and writing)
clear().task(<id>)
            
// To clear all tasks of a certain algorithm in the current graphset (excluding those whose status are computing and writing)
clear().task("<taskName>", "*")

// To clear all algorithm backend tasks of a certain status in the current graphset (excluding those whose status are computing and writing)
clear().task("*", "<status>")

// To clear all tasks of a certain algorithm and status in the current graphset (excluding those whose status are computing and writing)
clear().task("<taskName>", "<status>")
```

Example: Clear all algorithm backend tasks

```uql
clear().task("*")
```

Example: Clear algorithm backend task with id = 12

```uql
clear().task(12)
```

Example: Clear all "khop_all" backend tasks that are pending

```uql
clear().task("khop_all", "pending")
```


