# CLI

This manual covers the usage of Ultipa CLI, a cross-platform command line tool for running UQL and operating Ultipa Graph Database. 

## Prerequisites

- A command line terminal that is compatible with your operating system: 
    - Linux or MacOS: [bash](https://www.gnu.org/software/bash), [zsh](https://www.zsh.org/), [tcsh](https://www.tcsh.org/)
    - Windows: [PowerShell](https://learn.microsoft.com/en-us/powershell/)
- A version of [Ultipa CLI](https://www.ultipa.com/download) compatible with your operating system (Version 4.x.x is recommended for the best experience in Graph Blaze)

> Sign up for an Ultipa Account in order to access Ultipa Download Centre, remove download restrictions if popped by your browser in order to continue the download process.

## Operation Procedure

1. Get server connection (in PowerShell on Windows, the same below) 
<p tit="bash"></p> 

```bash
./ultipa_cli.exe -h 192.168.1.88:61095 -u user1 -p 12dfa36
```

2. Send UQL (refer to [Ultipa Query Language Guide](/docs/uql/introduction)) 
```bash
show().graph()
```

3. Switch graphset ('alimama' for example)
<p tit="bash"></p> 

```bash
use alimama
```

4. Switch server connection
<p tit="bash"></p> 

```bash
exit

./ultipa_cli.exe -h 192.168.1.85:64801,192.168.1.85:64802,192.168.1.85:64803 -u user1 -p 12dfa36
```


<center><img src="https://img.ultipa.cn/img/2023-04-14-16-25-28-show-graph.png"></center><center><small><i>Diagram: Get Server Connection and Send UQL</i></small></center> <br>


<center><img src="https://img.ultipa.cn/img/2023-04-14-16-25-30-switch-connection.png"></center><center><small><i>Diagram: Switch GraphSet and Switch Server Connection</i></small></center> <br>

