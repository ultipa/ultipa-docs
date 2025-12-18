# point()

Function `point()` assembles two numbers representing latitude and longitude into geographical coordinates of <i>point</i> type.

Arguments：

- object of latitude & longitude \<object>

Returns：

- geographical coordinates \<point>

## Common Usage

Example: Convert Beijing (39.9° N 116.3° E) to geographical coordinates

 
```uql
return point({latitude:39.9, longitude:116.3})
```
<p tit="Result"></p>

```
POINT(39.900000 116.300000)
```

Example: Convert each row of an alias into geographical coordinates

 
```uql
uncollect [{latitude:39.9, longitude:116.3},{latitude:31.2, longitude:121.5}] as a
return point(a)
```
<p tit="Result"></p>

```
POINT(39.900000 116.300000)
POINT(31.200000 121.500000)
```
Analysis: The input parameter of function point() is an object, not the latitude and longitude in decimal form.

Sample graph: (to be used for the following examples)

<div align=center drawio-diagram='6086' drawio-name='draw_64cc9f64e0b44cde94040b58a29d9d70.jpg'><img src="https://img.ultipa.cn/draw/draw_64cc9f64e0b44cde94040b58a29d9d70.jpg?v=''"/></div>
Run below UQLs one by one in an empty graphset to create graph data:

```uql
create().node_property(@default, "name").node_property(@default, "lat_long", point)
insert().into(@default).nodes([{_id:"L001", _uuid:1, name:"New York", lat_long:point({latitude:40.7, longitude:-74.0})}, {_id:"L002", _uuid:2, name:"Paris", lat_long:point({latitude:48.5, longitude:2.2})}, {_id:"L003", _uuid:3, name:"Sydney", lat_long:point({latitude:-33.9, longitude:150.9})}, {_id:"L004", _uuid:4, name:"Beijing", lat_long:point({latitude:39.9, longitude:116.3})}])
```


Example: Insert node Shanghai (31.2° N 121.5° E) into @location
<p graph="uql_manual_graph_7"></p>
 
```uql
insert().into(@default).nodes({name: "Shanghai", lat_long: point({latitude: 31.2, longitude: 121.5}), _id: "L005", _uuid: 5}) as n
return n{*}
```
<p tit="Result"></p>

```
|  _id  | _uuid |    name    |           lat_long          |
|-------|-------|------------|-----------------------------|
| L005  |   5   |  Shanghai  | POINT(31.200000 121.500000) |
```
