# Import Config | Settings

## All Parameters

| Parameter        | Specification 	| Default Value	| <div table-width=55>Description</div>            |
| ---------------- | -------------	| ------------ 	| -------------------------------- |
| separator		| string	| ,			| (When importing CSV) Delimiter of all files, supports `,`, `\t`, `\|`, `;`, `^A`, `^B`, `^C` and `^D`   |
| importMode	| string	| insert	| Mode of import operation, supports `insert`, `upsert`, and `overwrite`             |
| yes			| bool		| false		| Whether auto-create graphset, schema and properties that do not exist         |
| logPath			| string	| ./log	| The path of the log file, i.e., '/data/import/log'                      |
| threads		| int		| (the number of local CPUs)	| The maximum threads (≥2), 32 threads recommended |
| batchSize		| int		| 10000		| The number of rows in each batch, valid from 500 to 10000; an integer of 100000/number_of_properties is recommended              |
| maxPacketSize		| int		| 41943040 (40M)	| The maximum bytes of each packet the GO SDK processes      |
| timezone			| string	| (local timezone)	| The timezone of timestamp values, e.g. +0815, Asia/Shanghai etc.       |
| createNodeIfNotExist  | bool     	| false	| true: create nodes for the non-existing \_from, \_to, \_from_uuid or \_to_uuid of edges; false: leave them non-existing and their related edges un-imported |
| stopWhenError		| bool      | false	| (When error occurs) `true`: terminate the import operation immediately; `false`: skip the error data batch and continue with the next batch when not using this parameter                  |
| fitToHeader		| bool   	| false	| (When importing CSV with no header and the number of fields configured are different than the number of fields in the file) `true`: omit or auto-fill data fields based on the configuration; `false`: stop and throw an error |
| quotes			| bool		| false	| (When importing CSV) `true`: parse double quotation as the character of a double quotation itself; `false`: parse double quotation as the field boundary (must locate at the beginning and end of a data field), any double quotation as part of the data field content should be represented as two consecutive double quotations and this data datafiled must be wrapped by double quotations      |
