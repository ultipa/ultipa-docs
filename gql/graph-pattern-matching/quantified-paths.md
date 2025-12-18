# Quantified Paths

## Overview

A quantified path is a variable-length path where the complete path or a part of it is repeated a specified number of times.

Quantified paths are useful when you:

- Don’t know the exact number of hops required between nodes.
- Need to capture relationships at varying depths. 
- Want to simplify queries by compressing repetitive pattens.

## Quantifiers

A quantifier is written as a postfix to either an edge pattern or a parenthesized path pattern to specify how many times the pattern should repeat.

| <div table-width="20">Quantifier</div> | Description |
| -- | -- |
| `{m,n}` | Between `m` and `n` repetitions. |
| `{m}` | Exactly `m` repetitions. |
| `{m,}` | `m` or more repetitions. |
| `{,n}` | Between `0` and `n` repetitions. |
| `*` | Between `0` and more repetitions. |
| `+` | Between `1` and more repetitions. |

## Example Graph

<div align=center drawio-diagram='16778' drawio-name="draw_a99f62df2adf48359cd1f95077fee319.jpg"><img src="https://img.ultipa.cn/draw/draw_a99f62df2adf48359cd1f95077fee319.jpg?v='1726735600890'"/></div>

<div tab="code">

<p tit="Create the graph"></p>

```gql
CREATE GRAPH myGraph { 
  NODE User ({name string}),
  NODE Device (),
  EDGE Owns ()-[{}]->(),
  EDGE Flows ()-[{packets int32}]->()
} SHARDS [1]
```

<p tit="Insert data to the graph"></p>

```gql
INSERT (jack:User {_id: "U01", name: "Jack"}),
       (mike:User {_id: "U02", name: "Mike"}),
       (c1:Device {_id: "Comp1"}),
       (c2:Device {_id: "Comp2"}),
       (c3:Device {_id: "Comp3"}),
       (c4:Device {_id: "Comp4"}),
       (jack)-[:Owns]->(c1),
       (mike)-[:Owns]->(c4),
       (c1)-[:Flows {packets: 20}]->(c2),
       (c1)-[:Flows {packets: 30}]->(c4),
       (c2)-[:Flows {packets: 34}]->(c3),
       (c2)-[:Flows {packets: 12}]->(c4),
       (c3)-[:Flows {packets: 74}]->(c4)
```

</div>

## Building Quantified Paths

When writing a quantified path to its full form:

- **Two consecutive node patterns** are merged into a single node pattern with their filtering conditions combined using logical `AND`.
- **Two consecutive edge patterns** are implicitly connected by an empty node pattern.

### Quantified Edge

Edge patterns can be directly followed by a quantifier, and both the full and abbreviated edge patterns are supported.

<div align=center drawio-diagram='16772' drawio-name="draw_d6da4e2292484b119ed451495473963b.jpg"><img src="https://www-test-data.oss-cn-hangzhou.aliyuncs.com/draw/draw_d6da4e2292484b119ed451495473963b.jpg?v='1751898702233'"/></div>

### Quantified Entire Path

You can enclose the entire path pattern in parentheses `()` and append a quantifier.

<div align=center drawio-diagram='16744' drawio-name="draw_552a43cbfded43459fd7af85fdd33f53.jpg"><img src="https://www-test-data.oss-cn-hangzhou.aliyuncs.com/draw/draw_552a43cbfded43459fd7af85fdd33f53.jpg?v='1751898825680'"/></div>

When a quantifier is applied to an entire path pattern, a step count of `0` produces no result.

### Quantified Partial Path

You can enclose part of a path pattern in parentheses `()` and append a quantifier for it.

<div align=center drawio-diagram='26367' drawio-name="draw_89c87bb02dab46c4b819ad5f220ec617.jpg"><img src="https://www-test-data.oss-cn-hangzhou.aliyuncs.com/draw/draw_89c87bb02dab46c4b819ad5f220ec617.jpg?v='1751898972887'"/></div>

Another example:

<div align=center drawio-diagram='26369' drawio-name="draw_0fa4186dcbb24cbbbee6a431e0a32dc0.jpg"><img src="https://www-test-data.oss-cn-hangzhou.aliyuncs.com/draw/draw_0fa4186dcbb24cbbbee6a431e0a32dc0.jpg?v='1751899060332'"/></div>

## Examples

### Lowerbound and Upperbound

```gql
MATCH p = ({name: 'Jack'})->()-[f:Flows WHERE f.packets > 15]->{1,3}()<-({name: 'Mike'})
RETURN p
```

Result: `p`

<div align=center drawio-diagram='20497' drawio-name="draw_c7d7992001da41b8b03f7b5abcf7ce01.jpg"><img src="https://www-test-data.oss-cn-hangzhou.aliyuncs.com/draw/draw_c7d7992001da41b8b03f7b5abcf7ce01.jpg?v='1751899195646'"/></div>

### Fixed Length

```gql
MATCH p = ((:Device)->(:Device)){2}
RETURN p
```

Result: `p`

<div align=center drawio-diagram='20498' drawio-name="draw_5a4d0d9bf2cd458e9c1c5802b7a88239.jpg"><img src="https://www-test-data.oss-cn-hangzhou.aliyuncs.com/draw/draw_5a4d0d9bf2cd458e9c1c5802b7a88239.jpg?v='1751939286498'"/></div>

### Fixed Lowerbound

```gql
MATCH ({_id: 'Comp1'})->{2,}(n)
RETURN COLLECT_LIST(n._id)
```

Result:

| COLLECT_LIST(n.\_id) |
| -- |
| ["Comp4","Comp3","Comp4"] |

```gql
MATCH p = ({_id: 'Comp1'})-[f:Flows WHERE f.packets > 20]->*()
RETURN p
```

Result: `p`

<div align=center drawio-diagram='20500' drawio-name="draw_801e34f355084aa993e7eb095c107d28.jpg"><img src="https://www-test-data.oss-cn-hangzhou.aliyuncs.com/draw/draw_801e34f355084aa993e7eb095c107d28.jpg?v='1751884564863'"/></div>

```gql
MATCH p = ({_id: 'Comp1'})-[f:Flows WHERE f.packets > 20]->+()
RETURN p
```

Result: `p`

<div align=center drawio-diagram='20501' drawio-name="draw_dfd1117f41f3468b9b3b8dc4a2b9dfa7.jpg"><img src="https://www-test-data.oss-cn-hangzhou.aliyuncs.com/draw/draw_dfd1117f41f3468b9b3b8dc4a2b9dfa7.jpg?v='1751884599523'"/></div>

### Fixed Upperbound

```gql
MATCH p = ({name: 'Jack'})->(()-[f:Flows WHERE f.packets > 15]->()){,2}<-({name: 'Mike'})
RETURN p
```

Result: `p`

<div align=center drawio-diagram='20502' drawio-name="draw_fe3b7537923d49c8844aeb589f6a97fd.jpg"><img src="https://www-test-data.oss-cn-hangzhou.aliyuncs.com/draw/draw_fe3b7537923d49c8844aeb589f6a97fd.jpg?v='1751939621381'"/></div>

## Group Variables

Element variables declared within the repeatable part of a quantified path are bound to a list of nodes or edges, known as **group variables** or **group list**.

### Example Graph

<div align=center drawio-diagram='16773' drawio-name="draw_67664aeb31984c1488a3ddc177146d32.jpg"><img src="https://www-test-data.oss-cn-hangzhou.aliyuncs.com/draw/draw_67664aeb31984c1488a3ddc177146d32.jpg?v='1751941057585'"/></div>

<div tab="code">

<p tit="Create the graph"></p>

```gql
CREATE GRAPH myGraph { 
  NODE User ({name string, age uint32}),
  EDGE Follows ()-[{score uint32}]->()
} SHARDS [1]
```

<p tit="Insert data to the graph"></p>

```gql
INSERT (rowlock:User {_id: "U1", name: "rowlock", age: 24}),
       (quasar92:User {_id: "U2", name: "Quasar92", age: 29}),
       (claire:User {_id: "U3", name: "claire", age: 35}),
       (rowlock)-[:Follows {score: 2}]->(quasar92),
       (quasar92)-[:Follows {score: 3}]->(claire)
```

</div>

### Referencing Outside the Quantified Segment

Whenever a group variable is referenced outside the repeatable part of the quantified path where it is declared, it refers to a list of nodes or edges.

In this query, variables `a` and `b` represent lists of nodes encountered along the matched paths, rather than individual nodes:

```gql
MATCH p = ((a)-[]->(b)){1,2}
RETURN p, a, b
```

Result:

<table>
  <thead>
    <tr>
      <th style="width:45%">p</th>
      <th>a</th>
      <th>b</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>
<div align=center drawio-diagram='20505' drawio-name="draw_cd873c21fbb44cf381d01cd79b609bb1.jpg"><img src="https://www-test-data.oss-cn-hangzhou.aliyuncs.com/draw/draw_cd873c21fbb44cf381d01cd79b609bb1.jpg?v='1751941071564'"/></div>
      </td>
      <td>[(:User {_id:"U2", name:"Quasar92", age:29})]</td>
      <td>[(:User {_id:"U3", name:"claire", age:35})]</td>
    <tr>
    <tr>
      <td>
<div align=center drawio-diagram='20506' drawio-name="draw_0cb3bcc2da1840f08abb2d898b8376f3.jpg"><img src="https://www-test-data.oss-cn-hangzhou.aliyuncs.com/draw/draw_0cb3bcc2da1840f08abb2d898b8376f3.jpg?v='1751941080877'"/></div>
      </td>
      <td>[(:User {_id:"U1", name:"rowlock", age:24})]</td>
      <td>[(:User {_id:"U2", name:"Quasar92", age:29})]</td>
    </tr>
    <tr>
      <td>
<div align=center drawio-diagram='20507' drawio-name="draw_62a7d15f52424dca9a78c12a0ffc1fed.jpg"><img src="https://www-test-data.oss-cn-hangzhou.aliyuncs.com/draw/draw_62a7d15f52424dca9a78c12a0ffc1fed.jpg?v='1751941102387'"/></div>
      </td>
      <td>[(:User {_id:"U1", name:"rowlock", age:24}), (:User {_id:"U2", name:"Quasar92", age:29})]</td>
      <td>[(:User {_id:"U2", name:"Quasar92", age:29}), (:User {_id:"U3", name:"claire", age:35})]</td>
    </tr>
  </tbody>
</table>
        
To aggregate the group variables, use the `FOR` statement to expand it into individual records:

```gql
MATCH path = ()-[edges]->{1,2}()
CALL (path, edges) {
  FOR edge IN edges
  RETURN sum(edge.score) AS scores 
}
FILTER scores > 2
RETURN path, scores
```

Result:

<table>
  <thead>
    <tr>
      <th style="width:80%">p</th>
      <th>scores</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>
<div align=center drawio-diagram='20508' drawio-name="draw_186aef45ae2c41f098e73aa85c02e55b.jpg"><img src="https://www-test-data.oss-cn-hangzhou.aliyuncs.com/draw/draw_186aef45ae2c41f098e73aa85c02e55b.jpg?v='1751941504989'"/></div>
      </td>
      <td>3</td>
    <tr>
    <tr>
      <td>
<div align=center drawio-diagram='20509' drawio-name="draw_45b766f4b13b401ab829a260fa5dff5f.jpg"><img src="https://www-test-data.oss-cn-hangzhou.aliyuncs.com/draw/draw_45b766f4b13b401ab829a260fa5dff5f.jpg?v='1751941522201'"/></div>
      </td>
      <td>5</td>
    </tr>
  </tbody>
</table>

The following query throws syntax error since `a` and `b` are lists:

<p tit="GQL - Syntax Error"></p>

```gql
MATCH p = ((a)-[]->(b)){1,2}
WHERE a.age < b.age
RETURN p
```

### Referencing Inside the Quantified Segment

A group variable has a singleton reference only when it is referenced within the repeatable part of the quantified path where it is declared.

In this query, `a` and `b` are treated as singletons that represent individual nodes. The condition `a.age < b.age` is evaluated for each pair of nodes `a` and `b` as the path is matched:

```gql
MATCH p = ((a)-[]->(b) WHERE a.age < b.age){1,2}
RETURN p
```

Result: `p`

<div align=center drawio-diagram='20504' drawio-name="draw_27d322952c484bc69c8ae8bdc751ed08.jpg"><img src="https://www-test-data.oss-cn-hangzhou.aliyuncs.com/draw/draw_27d322952c484bc69c8ae8bdc751ed08.jpg?v='1751941715657'"/></div>
