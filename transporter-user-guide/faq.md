# FAQ

<b>Q</b>: <b>Why Ultipa Transporter won't connect with Ultipa server? The server is deployed on Ultipa Cloud</b>

<b>A</b>: If the Ultipa server is deployed on Ultipa Cloud, the IP of client end , from where the Ultipa Transporter runs, needs to be added to the InBound Allowed IPs under Network Settings of this server, on the page of Ultipa Cloud.

<b>Q</b>: <b>Got error message 'rpc error: code = ResourceExhausted desc = Received/Sent message larger than max (31324123 vs. 4194304)', what does it mean and how to solve it?</b>

<b>A</b>: This message means when importing/exporting a data batch, the packet size which is 31324123 bytes exceeds the limit of 4194304 bytes.The possible reasons are too many properties imported at a time, excessive property volume (long texts stored in text type), or too large batchSize that has been set, as a result of which the data volume of a data batch exceeds the default server config of max_rpc_msgsize (4M) and/or the MaxPacketSize of Go SDK (40M).

Solution A: reduce the `batchSize` in the config file<br>
Solution B: raise the setting of `MaxPacketSize` in the config file, and/or `max_rpc_msgsize` in the server config (the latter requires a server re-boot).



<b>Q</b>: <b>What format is required when importing time values?</b>

<b>A</b>: Please follow below format examples:
- [YY]YY-MM-DD HH:MM:SS
- [YY]YY-MM-DD HH:MM:SSZ
- [YY]YY-MM-DDTHH:MM:SSZ 
- [YY]YY-MM-DDTHH:MM:SS[+/-]0x00
- [YY]YYMMDDHH:MM:SS[+/-]0x00

Supports year of 4-digit or 2-digit (2-digit year will be parsed as 19xx if year≥70, or parsed as 20xx if year＜70; supports month and day of 2-digit or 1-digit; dash (-) can be replaced with slash (/); `[+/-]0x00` stands for `+0700` or `-0300` dependent, and Z stands for UTC 0 timezone.



<b>Q</b>: <b>What timezone is used for the exported time values? </b>

<b>A</b>: Value of <i>datetime</i> has no timezone information, value of <i>timestamp</i> will be exported according to the parameter `timezone` setting, or in local timezone if `timezone` is not set.



<b>Q</b>: <b>Can data fields with names `_id`, `_uuid`, `_from`, `_to`, `_from_uuid`, `_to_uuid` be declared as <i>string</i> or <i>uint64</i>?</b>

<b>A</b>: No. For any data field representing a system property, it should be configured as the name of the corresponding system property. If a data field has same name with a system property but not representing that system property, either should it be configured as <i>_ignore</i> hence will not be imported, or be renamed through parameter `new_name`.



<b>Q</b>: <b>Got warning message 'bare " in non-quoted-field' or 'extraneous or missing " in quoted-field', what do they mean and how to solve them?</b>

<b>A</b>: These two warnings are related to the double quotation in the data field.

With `quotes` set to <i>false</i>, a double quotation in a data field will be parsed as the boundary wrapping around the content of this data field (not being recognized as the content and must be located in the begining and end of the content), two consecutive double quotations will be parsed as the character of double quotation (part of the content). For instance, importing some content `I like when Jack said "If you jump I jump".` while `quotes` is <i>false</i> will definitely trigger warnings, and the content should be revised into`"I like when Jack said ""If you jump I jump""."` in order to be imported correctly.

With `quotes` set to <i>true</i>, a double quotation will be parsed as the character of double quotation itself (part of the content), hence the data field content in the above example can be imported correctly without any data preprocessing.
  
  

<b>Q</b>: <b>How to preprocess data when there are double quotations, commas and line breaks in the CSV?</b>

<b>A</b>: Below are the solutions for each symbol presenting separately in a data field. A conservative solution should be elected if more than one symbol presents.

For double quotations, please refer to the previous Q&A.

For commas, if `separator` is also using comma then the data field content should be warpped with double quotations to prevent the comma from being parsed as separator, in which case the `quotes` should be <i>false</i>; otherwise, no data preprocess is needed. 

For line breaks, must wrap the content with double quotations and guarantee that `quotes` is <i>false</i>.



<b>Q</b>: <b>Why a field in the CSV file with value 'null' won't be imported as <i>null</i> value?</b>

<b>A</b>: The field 'null' in a CSV file will be parsed as a string whose value is 'null'. Only an empty field will be parsed as <i>null</i>, i.e., two consecutive field separators.
