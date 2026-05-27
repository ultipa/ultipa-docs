# Current Values

Current values are bare-keyword expressions that return information about the current session or the current moment in time.

```gql
RETURN CURRENT_USER, CURRENT_GRAPH, CURRENT_TIMESTAMP
```

In the ISO GQL standard these are classified as *general value specifications* (ISO/IEC 39075 §22.20). The keywords are reserved, so they cannot be used as variable, label, or property names.

| <div table-width="22">Keyword</div> | Category | Returns |
| -- | -- | -- |
| <a href="#CURRENT_USER">`CURRENT_USER`</a> | Session | A record describing the authenticated user, or `NULL` |
| <a href="#CURRENT_GRAPH">`CURRENT_GRAPH`</a> | Session | The active graph name as `STRING`, or `NULL` |
| <a href="#CURRENT_DATE">`CURRENT_DATE`</a> | Temporal | Current date as `DATE` |
| <a href="#CURRENT_TIME">`CURRENT_TIME`</a> | Temporal | Current time with timezone as `ZONED TIME` |
| <a href="#CURRENT_TIMESTAMP">`CURRENT_TIMESTAMP`</a> | Temporal | Current datetime with timezone as `ZONED DATETIME` |
| <a href="#LOCAL_TIME">`LOCAL_TIME`</a> | Temporal | Current time without timezone as `LOCAL TIME` |
| <a href="#LOCAL_TIMESTAMP">`LOCAL_TIMESTAMP`</a> | Temporal | Current datetime without timezone as `LOCAL DATETIME` |

## Session Values

### CURRENT_USER

Returns a record describing the authenticated user for the current request. Returns `NULL` when no user is authenticated (for example, when the server is running with access control disabled).

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td><code>CURRENT_USER</code></td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td><code>RECORD</code> or <code>NULL</code></td>
    </tr>
    <tr>
      <td><b>Record Fields</b></td>
      <td>
        <code>username</code> (<code>STRING</code>): the user's login name<br>
        <code>roles</code> (<code>LIST&lt;STRING&gt;</code>): roles granted to the user<br>
        <code>is_admin</code> (<code>BOOLEAN</code>): whether the user has the admin role
      </td>
    </tr>
  </tbody>
</table>

```gql
RETURN CURRENT_USER
```

Access individual fields:

```gql
RETURN CURRENT_USER.username, CURRENT_USER.is_admin
```

Use in a query to filter or record the acting user:

```gql
MATCH (n:Post)
WHERE n.author = CURRENT_USER.username
RETURN n
```

```gql
INSERT (:AuditLog {action: "delete", user: CURRENT_USER.username, at: CURRENT_TIMESTAMP})
```

### CURRENT_GRAPH

Returns the name of the graph the query is running against. Returns `NULL` when no graph is selected for the session.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td><code>CURRENT_GRAPH</code></td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td><code>STRING</code> or <code>NULL</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN CURRENT_GRAPH
```

## Temporal Values

These values are evaluated once per query and are equivalent to the zero-argument forms of the corresponding <a target="_blank" href="/docs/gql/datetime-functions">datetime functions</a>.

### CURRENT_DATE

Returns the current local date. Equivalent to `date()`.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td><code>CURRENT_DATE</code></td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td><code>DATE</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN CURRENT_DATE, date()
```

### CURRENT_TIME

Returns the current time with timezone. Equivalent to `zoned_time()`.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td><code>CURRENT_TIME</code></td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td><code>ZONED TIME</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN CURRENT_TIME, zoned_time()
```

### CURRENT_TIMESTAMP

Returns the current datetime with timezone. Equivalent to `zoned_datetime()` and `now()`.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td><code>CURRENT_TIMESTAMP</code></td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td><code>ZONED DATETIME</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN CURRENT_TIMESTAMP, zoned_datetime(), now()
```

### LOCAL_TIME

Returns the current time without timezone. Equivalent to `local_time()`.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td><code>LOCAL_TIME</code></td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td><code>LOCAL TIME</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN LOCAL_TIME, local_time()
```

### LOCAL_TIMESTAMP

Returns the current datetime without timezone. Equivalent to `local_datetime()`.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td><code>LOCAL_TIMESTAMP</code></td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td><code>LOCAL DATETIME</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN LOCAL_TIMESTAMP, local_datetime()
```
