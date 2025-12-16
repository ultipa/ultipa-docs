# pointInPolygon()

Function `pointInPolygon()` judges whether a 2D coordinate locates in (not outside or on ) the boundary of a polygon, and returns 1 for true, 0 for false.

Arguments：

- 2D coordinates \<point|list>
- Polygon \<list>

Returns：

- Result \<number>

## Common Usage

<div align=center drawio-diagram='6883' drawio-name='draw_2b36827e19944f46b1cb1006f4116759.jpg'><img src="https://img.ultipa.cn/draw/draw_2b36827e19944f46b1cb1006f4116759.jpg?v='1697513453355'"/></div>


Exalmple: Direct calculate
<p run-tag="true" graph="uql_manual_graph_7"></p>
 
```js
uncollect [[1.5,0.5],[2,2]] as point
uncollect [[[1,0],[3,0],[3,1],[1,1]],[[1,0],[2,1],[1,2],[0,1]]] as polygon
return table(toString(point), toString(polygon), pointInPolygon(point, polygon))
```
<p tit="Result"></p>

```bash
| toString(point) |     toString(polygon)     | pointInPolygon(point, polygon) |
|-----------------|---------------------------|--------------------------------|
| [1.5,0.5]       | [[1,0],[3,0],[3,1],[1,1]] | 1                              |
| [2,2]           | [[1,0],[2,1],[1,2],[0,1]] | 0                              |
```

Exalmple: Multiply and calculate
<p run-tag="true" graph="uql_manual_graph_7"></p>
 
```js
uncollect [[1.5,0.5],[2,2]] as point
uncollect [[[1,0],[3,0],[3,1],[1,1]],[[1,0],[2,1],[1,2],[0,1]]] as polygon
with pointInPolygon(point, polygon) as result
return table(toString(point), toString(polygon), result)
```
<p tit="Result"></p>

```bash
| toString(point) |     toString(polygon)     | result |
|-----------------|---------------------------|--------|
| [1.5,0.5]       | [[1,0],[3,0],[3,1],[1,1]] | 1      |
| [1.5,0.5]       | [[1,0],[2,1],[1,2],[0,1]] | 0      |
| [2,2]           | [[1,0],[3,0],[3,1],[1,1]] | 0      |
| [2,2]           | [[1,0],[2,1],[1,2],[0,1]] | 0      |
```
null
