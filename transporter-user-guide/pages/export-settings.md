# Export Config | Settings

## All Parameters

| Parameter        | Specification | Default Value	| <div table-width=55>Description</div>            |
| --------------- | --------------| --------------- | ----------------------------- |
| outPath		| string	| ./export	| The path of the exported files, such as '/data/import'              |
| writeHeader	| bool		| true	| Whether to write header into the file |
| maxPacketSize	| int		| 41943040 (40M)	| The maximum bytes of each packet the GO SDK processes       |
| Timeout		| int		| 1000	| The grpc timeout limit when exporting huge amount of data, unit in second; set to <0 for no limit, set to 0 for 1000s   |
| timezone		| string	| (local timezone)	| The timezone of timestamp values, e.g. +00:80, Asia/Shanghai etc.       |
| fileType		| string	| CSV	| Supported file types include CSV, JSON, JSONL, and GraphML       |

> Exporter automatically decides the batch size which cannot be set by users.
