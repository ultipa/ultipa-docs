# Node and Edge Templates

## Overview

Node and edge templates serve as buliding blocks for constructing paths and subgraphs. By incorporating filters that define the nodes and edges involved, these templates can accurately match patterns across various scenarios.

## Templates

There are four basic node and edge templates: 

| <div table-width=19>Template</div> | <div table-width=19>Name</div> | Description | <div table-width=13>Custom Alias</div> |
| ---- | ---- | ---- | ---- |
| `n()` | Single node | <div align=left drawio-diagram='15254' drawio-name="draw_a5e5d5bb20634cb79ccd87e1bb4461cb.jpg"><img src="https://img.ultipa.cn/draw/draw_a5e5d5bb20634cb79ccd87e1bb4461cb.jpg?v='1713160539270'"/></div> | Supported, type: NODE |
| `e()`,<br>`le()`,<br>`re()` | Single edge<br><br>(Direction: ignored, left, right) | <div align=left drawio-diagram='15255' drawio-name="draw_116eeaf138e647b5b3bd8713b0561e48.jpg"><img src="https://img.ultipa.cn/draw/draw_116eeaf138e647b5b3bd8713b0561e48.jpg?v='1713161635376'"/></div> | Supported, type: EDGE |
| `e()[<steps>]`,<br>`le()[<steps>]`,<br>`re()[<steps>]` | Multi-edge<br><br>(Direction: ignored, left, right) | <div align=left drawio-diagram='15256' drawio-name="draw_99b64bee6de9498ba1935ef18e25e91a.jpg"><img src="https://img.ultipa.cn/draw/draw_99b64bee6de9498ba1935ef18e25e91a.jpg?v='1713161665079'"/></div><br>Formats of `[<steps>]`: (N≥1)<br>`[N]`: N edges<br>`[:N]`: 1~N edges<br>`[M:N]`: M~N edges<sup>[1]</sup> (M≥0)<br>`[*:N]`: the shortest paths within N edges | Not supported |
| `e().nf()[<steps>]`,<br>`le().nf()[<steps>]`,<br>`re().nf()[<steps>]` | Multi-edge with intermediate nodes<br><br>(Direction: ignored, left, right) | <div align=left drawio-diagram='15257' drawio-name="draw_5916d03e953e4786bd97c19039f03184.jpg"><img src="https://img.ultipa.cn/draw/draw_5916d03e953e4786bd97c19039f03184.jpg?v='1713161691376'"/></div><br>Formats of `[<steps>]` is same as above | Not supported |

<sup>[1]</sup> When setting `[0:N]` for a multi-edge template, the step `0` is valid only when the `n()` before the multi-edge template meets the filtering condition of the `n()` after the multi-edge template. In this case, this multi-edge template along with the right side `n()` are considered dismissed.

## Path Composition Rules

**Rule 1:** A path starts and ends with a node, and consists of alternating nodes and edges in between.

Example: The paths below with a length of 3 can be expressed as `n().e().n().e().n().e().n()`, each individual node and edge template in the path can have its own filter and alias.

<div align=center drawio-diagram='15258' drawio-name="draw_3905814a5acd43b99b4ae4e9217bfa2b.jpg"><img src="https://img.ultipa.cn/draw/draw_3905814a5acd43b99b4ae4e9217bfa2b.jpg?v='1713162847728'"/></div>

```js
n({@mgr}).re({@manage}).n({@cst} as n1)
  .re({@has}).n({@acct} as n2)
  .re({@buy} as e1).n({@product}) as p
return n1, n2, e1, p
```

Particularly, it's supported to use `n()` independently. 

Example: Find all *@account* nodes.

```js
n({@account} as acc)
return acc
```

**Rule 2:** Consecutive edges and nodes with same filtering condition can be merged into a multi-edge template.

Example: The paths below have the same types of edges and nodes from step 2 to step 4. You can use the multi-edge template `e().nf()[3]` to represent those edges and intermediate nodes. However, custom alias is not applicable in multi-edge template.

<div align=center drawio-diagram='15259' drawio-name='draw_b7d7706938b240b6a68c4feee18058de.jpg'><img src="https://img.ultipa.cn/draw/draw_b7d7706938b240b6a68c4feee18058de.jpg?v='1713162969568'"/></div>

```js
n({@cst}).re({@has}).n({@acct} as n1)
  .re({@transfer}).nf({@acct})[3].n({@acct} as n2)
  .le({@has}).n({@cst}) as p
return n1, n2, p
```

**Rule 3:** Set the steps as a range instead of a fixed number when applicable to expand the query scope.

Example: You can use the multi-edge template `e().nf()[:3]` to limit the number of transactions in paths within 3, as shown below.

<div align=center drawio-diagram='15260' drawio-name="draw_81cdfd464952422390f0e676d83d71ca.jpg"><img src="https://img.ultipa.cn/draw/draw_81cdfd464952422390f0e676d83d71ca.jpg?v='1713163450134'"/></div>

```js
n({@cst} as n1).re({@has}).n({@acct} as c1)
  .re({@transfer})[:3].n({@acct} c1)
  .le({@has}).n({@cst}) as p
return c1, c2, p
```
