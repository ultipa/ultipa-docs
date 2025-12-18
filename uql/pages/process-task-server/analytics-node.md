# Analytics Node

When a UQL (whether it is a real-time process or a backend task) is expected to run for a considerable amount of time or take up substantial resources, it is suggested to be sent to the analytics node (algo node) of the cluster so as to retain sufficient resources in other instances to respond to other requests.

`Syntax`: use prefix `EXEC TASK`
<p tit="Syntax"></p>

```uql
exec task <uql>
```

Example:
```uql
exec task n().e().n() as p return p{*}
```

> Please note that prefix EXEC TASK does NOT mean to execute a UQL as backend task.
