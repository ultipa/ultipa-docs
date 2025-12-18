# distance()

Function `distance()` returns the direct distance of two geographical coordinates in meters.

Arguments：

- Geographical coordinates1 \<point>
- Geographical coordinates2 \<point>

Returns：

- Distance \<number>

Sample graph: (to be used for the following examples)

<div align=center drawio-diagram='6086' drawio-name='draw_64cc9f64e0b44cde94040b58a29d9d70.jpg'><img src="https://img.ultipa.cn/draw/draw_64cc9f64e0b44cde94040b58a29d9d70.jpg?v=''"/></div>
Run below UQLs one by one in an empty graphset to create graph data:

```uql
create().node_property(@default, "name").node_property(@default, "lat_long", point)
insert().into(@default).nodes([{_id:"L001", _uuid:1, name:"New York", lat_long:point({latitude:40.7, longitude:-74.0})}, {_id:"L002", _uuid:2, name:"Paris", lat_long:point({latitude:48.5, longitude:2.2})}, {_id:"L003", _uuid:3, name:"Sydney", lat_long:point({latitude:-33.9, longitude:150.9})}, {_id:"L004", _uuid:4, name:"Beijing", lat_long:point({latitude:39.9, longitude:116.3})}])
```

## Common Usage

Exalmple: Direct calculate, return in kilometers

 
```uql
find().nodes({name in ["New York", "Paris"]}) as a
find().nodes({name in ["Sydney", "Beijing"]}) as b
return table(a.name, b.name, distance(a.lat_long, b.lat_long)/1000)
```
<p tit="Result"></p>

```
|  a.name  | b.name  | distance(a.point, b.point)/1000 |
|----------|---------|---------------------------------|
| New York | Sydney  | 16017.5939640978                |
| Paris    | Beijing | 8247.41966611293                |
```

Exalmple: Multiply and calculate, return in kilometers

 
```uql
find().nodes({name in ["New York", "Paris"]}) as a
find().nodes({name in ["Sydney", "Beijing"]}) as b
with distance(a.lat_long, b.lat_long)/1000 as c
return table(a.name, b.name, c)
```
<p tit="Result"></p>

```
|  a.name  | b.name  |         c        |
|----------|---------|------------------|
| New York | Sydney  | 16017.5939640978 |
| New York | Beijing | 10992.9752060986 |
| Paris    | Sydney  | 16967.299225946  |
| Paris    | Beijing | 8247.41966611293 |
```
