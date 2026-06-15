# FAQ

This page contains frequently asked questions about **Ultipa Transporter**. If you can't find an answer to your question, you may contact us at <a href="mailto:support@ultipa.com">support@ultipa.com</a>.

### Transporter cannot connect to Ultipa Cloud

If you want to connect to Ultipa Cloud from Ultipa Transporter, you must add the IP of Ultipa Transporter to the **Allowed Inbound IPs** in Ultipa Cloud. For details see <a target="_blank" href="/docs/cloud-user-guide/powerhouse-manage-clusters/#(Optional)-Add-Allowed-Inbound-IPs">Graph Powerhouse</a> or <a target="_blank" href="/docs/cloud-user-guide/blaze-manage-instances/#(Optional)-Add-Allowed-Inbound-IPs">Graph Blaze</a>.

### How to fix "rpc error: code = ResourceExhausted"

This error occurs when the packet size exceeds the limit during data import/export. This issue may be caused by:

- Importing too many properties at once.
- Large property values (e.g., long text fields).
- An excessively large `batchSize`.

Try the following solutions:

- Reduce `batchSize` in the Transporter configuration file.
- Increase `MaxPacketSize` in the Transporter configuration file.
- Adjust `max_rpc_msgsize` in the server configuration (requires a server reboot).

### What is the required format for importing date and time values

Supported standard `datetime` formats include:

- `[YY]YY-MM-DD HH:MM:SS`
- `[YY]YY-MM-DD HH:MM:SSZ`
- `[YY]YY-MM-DDTHH:MM:SSZ`
- `[YY]YY-MM-DDTHH:MM:SS[+/-]0x00`
- `[YY]YYMMDDHH:MM:SS[+/-]0x00`

Note:

- Year can be represented as either a 4-digit or 2-digit number. A 2-digit year will be parsed as `19xx` if ≥ 70, or as `20xx` if < 70.
- Month and day can be represented as either a 2-digit or 1-digit number.
- Dash (`-`) separator can be replaced with a slash (`/`).
- `[+/-]0x00` indicates the time zone offset (e.g., `+0700` or `-0300`).
- Letter `Z` indicates the UTC 0 timezone.

### What timezone is applied to the exported time values

If the `datetime` value doesn't include the timezone information, the time will be exported based on the `timezone` set in the Transporter configuration file. If no `timezone` is specified, it will be exported in the local timezone.

### Understanding quotation mark warnings

Warnings like `bare " in non-quoted-field` and `extraneous or missing " in quoted-field` occur when double quotation marks (`"`) are not handled correctly in data fields.

Check the `settings` > `quotes` option in the Transporter configuration file:

- If sets to `false` (default): Double quotes are treated as field boundaries and must appear at both the beginning and end of the content. Consecutive double quotes (`""`) are interpreted as a single quote character. For example, the text `I like when Jack said "If you jump, I jump".` must be formatted as `"I like when Jack said ""If you jump, I jump""."` for successful import.
- If sets to `true`: Double quotes are treated as part of the content rather than delimiters. No special formatting is needed for fields containing double quotes. The above example can be imported as-is without errors.

### How to process CSV data that contains commas and line breaks

<b>Handling Commas</b>: If the `settings` > `separator` in the Transporter configuration file is set to comma, data fields containing commas must be enclosed in double quotation marks (`"`) to prevent misinterpretation as a separator. If `separator` is not a comma, no additional formatting is required.

<p tit="comma"></p>

```csv
"Alice, CEO", 35, "New York"
```

Here, `Alice, CEO` is treated as a single field rather than two separate values.

<b>Handling Line Breaks</b>: Data fields containing line breaks must be wrapped in double quotation marks (`"`).

<p tit="line break"></p>

```csv
"This is a multi-line
description of a product."
```

The entire text block inside double quotes will be treated as a single field.

In both cases, set `settings` > `quotes` to `false` in the Transporter configuration file.

### Why is "null" fields in a CSV file not imported as null values

In a CSV file, the string "null" is interpreted literally as a text value, not as a `null` value. To ensure a field is imported as `null`, leave it empty between two consecutive field separators (e.g., `,,`).
