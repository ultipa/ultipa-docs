# Import Config | Data Field

## General Format

Configure schemas and/or CSV folders under `nodeConfig` and `edgeConfig`:

<p tit= "YML" type="yaml"></p>

```yml
nodeConfig:

# Configure a node schema
  # Schema name
  - schema:
    # (mysql/postgresSQL/sqlserver/bigQuery, mandatory) Sql that extracts data fields
    sql:
    # (neo4j, mandatory) label name in Neo4J
    label:
    # (neo4j, optional) Use variable 'n' to filter the data of this label, e.g., n.released > 1999; no filter by default
    where:
    # (kafka, mandatory) Kafka topic
    topic:
    # (kafka, optional) Kafka offset, supported formats are 'newest', 'oldest', '5', '2006-01-02 15:04:05 -0700', '2006-01-02 15:04:05'
    offset:
    # (csv/json/jsonl, mandatory) Path of data file
    file:
    # (csv, optional) Whether the CSV file has header; 'true' by default
    head:
    # (All sources, optional) Manually configure the data fields
    properties:
    # (All sources, optional) The number of data rows to skip from the beginning
    skip: 
    # (All sources, optional) The maximum number of data rows to inject
    limit: 

# Configure more node schemas
  - schema:
    ...
  
# (csv folder, mandatory) Configure a node schema folder, in which the CSV files are named as <schema>.node.csv, with headers and types (modification not supported)
  # Path of folder
  - dir:
  
# Configure more node schema folders
  - dir:

edgeConfig:  

# Configure an edge schema
  - schema:
    ...

# Configure more edge schemas
  - schema:
    ...
  
# (csv folder, mandatory) Configure an edge schema folder, in which the CSV files are named as <schema>.edge.csv, with headers and types (modification not supported)
  - dir:
  
# Configure more edge schema folders
  - dir:
```

## Details of `properties`

<p tit= "YML" type="yaml"></p>

```yml
nodeConfig:
  - schema:
    ...
    properties:
    
    # Configure a data field
      # Name of data field
      - name:
        # (Optional) Configure or modify field name
        new_name:
        # (Optional) Modify field name
        type:
        # (Optional) Prefix to be appended before the data of _id, _from or _to
        prefix:
        
      # Configure more data fields
      - name:
        new_name:
        type:
        prefix:

    skip: 
    limit: 
  ...
```

Classify data sources by whether carrying field name and field type:
- No name: Headerless CSV 
- Carry name:
  - No type: CSV with header but no type, JSON, JSONL
  - Carry type: CSV with header and type, MySQL, PostgreSQL, SQLServer, BigQuery, Neo4j, Kafka
  
`properties` can <sup>1)</sup> configure the un-carried field name and type, <sup>2)</sup> modify the carried field name and type, and <sup>3)</sup> add prefix to field value.

Validity of field names:
- Refer to [Naming Convention](/docs/uql/property) of property

Validity of field type:
- System properties: `_id`, `_uuid`, `_from`, `_to`, `_from_uuid`, `_to_uuid`
- Custom properties please refer to [Data Types of Property](/docs/uql/data-type)
- Fields to be ignored: `_ignore`

Field types that support prefix: `_id`, `_from`, `_to`

### Example: Configure field name and type

When configuring field names and types for a headerless CSV, the order of `-name` should be consistent with data columns in the file. Such as:
<p tit= "CSV"></p>

```js
A2CMX45JPSCTUJ,5,The Best Cable
A3EIML9QZO5NZZ,5,awesome
A3C9F3SZWLWDZF,2,worse than previous one
A1C60KQ8VJZBS5,4,Makes changing strings a breeze
```

<p tit= "YML" type="yaml"></p>

```yml
properties:
  - name: any		# When the field is a system property, the field name '- name' could be any value as long as it is NOT identical with any other field names
    type: _id
  - name: rating
    type: _ignore	# A field set to _ingore type will not be imported
  - name: comment
    # A field whose 'type' is omitted will be set to 'string' type
```

> When a headerless CSV file has less `- name` configured than its actual columns, error will prompt by default, or set  [fitToHeader](/docs/transporter/import-settings) under `settings` to 'true' so as to ignore the last couple of columns not configured.


When configuring field types for a CSV file with header but no type, the order of`-name` is not necessary and normally impossible to be consistent with data columns in the file. Such as:
<p tit= "CSV"></p>

```js
_id,rating,comment
A2CMX45JPSCTUJ,5,The Best Cable
A3EIML9QZO5NZZ,5,awesome
A3C9F3SZWLWDZF,2,worse than previous one
A1C60KQ8VJZBS5,4,Makes changing strings a breeze
```

<p tit= "YML" type="yaml"></p>

```yml
properties:
  - name: rating
    type: int32
  - name: _id
    type: _id
    # (For column 'comment') A field whose 'type' or '- name' is omitted will be set to 'string' type
```

When configuring field types for JSON and JSONL file, omitting  `type` and omitting `- name` have different processing logic. Such as:
<p tit= "JSON"></p>

```json
[
  {"_id":"A2CMX45JPSCTUJ", "rating":5, "comment":"The Best Cable"},
  {"_id":"A3EIML9QZO5NZZ", "rating":5, "comment":"awesome"},
  {"_id":"A3C9F3SZWLWDZF", "rating":2, "comment":"worse than previous one"},
  {"_id":"A1C60KQ8VJZBS5", "rating":4, "comment":"Makes changing strings a breeze"}
]
```

<p tit= "YML" type="yaml"></p>

```yml
properties:
  - name: rating
    type: int32
  - name: _id
    type: _id
    # (For column 'comment') A field whose 'type' is omitted will be set to 'string' type, a field whose '- name' is omitted will not be imported
```

### Example: Modify field name and type

When the filed names and/or types of data source are invalid in Ultipa system, or are not consistent with the target property, use `new_name` and `type` to modify. `type` should not be omitted in this case even though the target property is <i>string</i> type. Such as: 
<p tit= "CSV"></p>

```js
_id:_id,rating:int32,comment:string
A2CMX45JPSCTUJ,5,The Best Cable
A3EIML9QZO5NZZ,5,awesome
A3C9F3SZWLWDZF,2,worse than previous one
A1C60KQ8VJZBS5,4,Makes changing strings a breeze
```

<p tit= "YML" type="yaml"></p>

```yml
properties:
  - name: rating
    type: string	# Should not omit 'type', otherwise Ultipa Transporter will keep using the 'int32' from the file header as type of 'rating'
  - name: comment
    new_name: content
```

> As different data sources may have different supported data types, Ultipa Transporter will match these data types to those supported by Ultipa; types that cannot be matched will be alarmed and automatically ignored.

### Example: Add prefix to field value

In case the node IDs from the data source are not unique graph wise, use `prefix` to condition these IDs and the related FROMs and TOs, namely, only process data fields that are `_id`, `_from` or `_to`. Such as:
<p tit= "person.csv"></p>

```js
id,name
1,Hubert Pirtle
2,John Fowler
3,Christopher Sanzot
```
<p tit= "company.csv"></p>

```js
id,name
1,VoxelCloud
2,Lifeforce Ventures
3,Dentsu Ventures
```

<p tit= "holding.csv"></p>

```js
personID,companyID,shareInt
1,3,59
2,1,10
3,1,23
3,2,47
```

<p tit= "YML" type="yaml"></p>

```yml
...
nodeConfig:
  - schema: "person"
    file: /Data/person.csv
    head: true
    properties:
      - name: id
        type: _id
        prefix: person_		# Attach 'person_' to the front of 'id'

  - schema: "company"
    file: /Data/company.csv
    head: true
    properties:
      - name: id
        type: _id
        prefix: company_	# Attach 'company_' to the front of 'id'

edgeConfig:
  - schema: "holding"
    file: /Data/holding.csv
    head: true
    properties:
      - name: personID
        type: _from
        prefix: person_		# Attach 'person_' to the front of 'personID'  
      - name: companyID
        type: _to
        prefix: company_	# Attach 'person_' to the front of 'companyID'
      - name: shareInt
        type: int32
...
```

## Valid Field Value in CSV

### string, text

- When `quotes` under `settings` is set to `false` (default value), a double-quotation is recognized as the field boundary, two consecutive double-quotations are recognized as a double-quotation within the field value. Such as:
<p tit= "CSV"></p>

```js
field1:string,field2:text,field3:string
abc,"a,b,c",no double quotation in this field
def,"d,e,f","a double quotation "" in this field"
ghi,"g,h,i",quotes set to false
```

- When `quotes` under `settings` is set to `true`, double-quotations of any quantity at anywhere will be recognized as double-quotations within the field value, in which case double-quotations cannot be used as field boundaries. Such as:
<p tit= "CSV"></p>

```js
field1:string,field2:text,field3:string
abc,"a",no double quotation in this field
def,"d",a double quotation " in this field
ghi,"g",quotes set to true
```

### decimal

<p tit= "CSV"></p>

```js
"decimal:decimal(5,3)"
99.999
0.999
0.001
-99.000
-99.999
0.000
```

### datetime, timestamp

<p tit= "CSV"></p>

```js
time1:datetime,time2:datetime,time3:timestamp,time4:timestamp
1987-11-02,1987-11-02 01:25:52,1987-11-02T01:25:52+0400,562785952000
2001-08-14,2001-08-14 13:43:16,2001-08-14T13:43:16-1100,997767796000
1998-02-19,1998-02-19 16:15:03,1998-02-19T16:15:03+0200,887876103000
```

> More formats of time value are listed below, note that the time zone information will ignore if field type is <i>datetime</i>:
<br>[YY]YY-MM-DD HH:MM:SS 
<br>[YY]YY-MM-DD HH:MM:SSZ 
<br>[YY]YY-MM-DDTHH:MM:SSZ 
<br>[YY]YY-MM-DDTHH:MM:SS[+/-]0x00 
<br>[YY]YYMMDDHH:MM:SS[+/-]0x00 
<br>[YY]YY/MM/DD HH:MM:SS 
<br>[YY]YY/MM/DD HH:MM:SSZ 
<br>[YY]YY/MM/DDTHH:MM:SSZ 
<br>[YY]YY/MM/DDTHH:MM:SS[+/-]0x00 
<br>[YY]YYYY-MM-DD
<br>[YY]YYYY/MM/DD 
<br>[YY]YYYYMMDD

### list

<p tit= "CSV"></p>

```js
list1:int32[],list2:string[]
"[1,3,3]","[possitive,rebuy]"
"[2,1,4]","[negative]"
"[3,1,2]","[negative,rebuy]"
"[4,2,4]","[possitive]"
```

> Empty places held for elements indicate `null` value, i.e., the second element in [1,,3] is `null`

### set

<p tit= "CSV"></p>

```js
set1:set(int32),set2:set(string)
"[1,3]","[possitive,rebuy]"
"[2,1,4]","[negative]"
"[3,1,2]","[negative,rebuy]"
"[4,2]","[possitive]"
```

### point

<p tit= "CSV"></p>

```js
point1:point,point2:point,point3:point,point4:point
POINT(39.9 116.3),"{latitude:39.9,longitude:116.3}","[39.9,116.3]","39.9,116.3"
POINT(40.7 -74),"{latitude:40.7,longitude:-74}","[40.7,-74]","40.7,-74"
POINT(48.5 2.2),"{latitude:48.5,longitude:2.2}","[48.5,2.2]","48.5,2.2"
```
