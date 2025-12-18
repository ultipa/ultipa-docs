# Schema Overview

<div><span class="flag" style="background:#014d4e;color:#fff;"><b>HDC</b></span></div>

## Overview

The Schema Overview algorithm summarizes the structure of a graph by presenting statistics for source node schemas (labels), edge schemas, end node schemas, and the corresponding edge counts.

## Example Graph

<div align=center drawio-diagram='17034' drawio-name="draw_21f3f3201d4b412ca26ec1229b35c256.jpg"><img src="https://img.ultipa.cn/draw/draw_21f3f3201d4b412ca26ec1229b35c256.jpg?v='1726279069119'"/></div>

Run the following statements on an empty graph to define its structure and insert data:

<div tab="code">

```gql
ALTER GRAPH CURRENT_GRAPH ADD NODE {
  account (), 
  movie (),
  country (),
  director ()
};
ALTER GRAPH CURRENT_GRAPH ADD EDGE {
  follow ()-[]->(),
  like ()-[]->(),
  filmedIn ()-[]->(),
  direct ()-[]->()
};
INSERT (David:account {_id: "David"}),
       (Emily:account {_id: "Emily"}),
       (Alice:account {_id: "Alice"}),
       (Titanic:movie {_id: "Titanic"}),
       (Avatar:movie {_id: "Avatar"}),
       (Mexico:country {_id: "Mexico"}),
       (JC:director {_id: "James Cameron"}),
       (David)-[:follow]->(Alice),
       (Emily)-[:follow]->(Alice),
       (Alice)-[:like]->(Titanic),
       (Titanic)-[:filmedIn]->(Mexico),
       (JC)-[:direct]->(Titanic),
       (JC)-[:direct]->(Avatar);
```

```uql
create().node_schema("account").node_schema("movie").node_schema("country").node_schema("director").edge_schema("follow").edge_schema("like").edge_schema("filmedIn").edge_schema("direct");
insert().into(@account).nodes([{_id:"David"}, {_id:"Emily"}, {_id:"Alice"}]);
insert().into(@movie).nodes([{_id:"Titanic"}, {_id:"Avatar"}]);
insert().into(@country).nodes({_id:"Mexico"});
insert().into(@director).nodes({_id:"James Cameron"});
insert().into(@follow).edges([{_from:"David", _to:"Alice"}, {_from:"Emily", _to:"Alice"}]);
insert().into(@like).edges({_from:"Alice", _to:"Titanic"});
insert().into(@filmedIn).edges({_from:"Titanic", _to: "Mexico"});
insert().into(@direct).edges([{_from:"James Cameron", _to:"Titanic"}, {_from:"James Cameron", _to:"Avatar"}]);
```

</div>

## Creating HDC Graph

To load the entire graph to the HDC server `hdc-server-1` as `my_hdc_graph`:

<div tab="code">
  
```gql
CREATE HDC GRAPH my_hdc_graph ON "hdc-server-1" OPTIONS {
  nodes: {"*": ["*"]},
  edges: {"*": ["*"]},
  direction: "undirected",
  load_id: true,
  update: "static"
}
```

```uql
hdc.graph.create("my_hdc_graph", {
  nodes: {"*": ["*"]},
  edges: {"*": ["*"]},
  direction: "undirected",
  load_id: true,
  update: "static"
}).to("hdc-server-1")
```

</div>

## Parameters

Algorithm name: `schema_overview`

| <div table-width="10">Name</div> | <div table-width="9">Type</div> | <div table-width="12">Spec</div> | <div table-width="8">Default</div> | <div table-width="9">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| `order` | String | `asc`, `desc` | / | Yes | Sorts the results by `count`. |

## Full Return

<div tab="code">
  
```gql
CALL algo.schema_overview.run("my_hdc_graph", {}) YIELD r
RETURN r
```

```uql
exec{
  algo(schema_overview).params() as r
  return r
} on my_hdc_graph
```

</div>

Result:

| <div table-width="25">node schema(src)</div> | <div table-width="15">edge schema</div> | <div table-width="25">node schema(dest)</div>  | count |
| --- | --- | --- | --- |
| account  | follow   | account | 2 |
| account  | like	  | movie   | 1 |
| movie    | filmedIn | country | 1 |
| director | direct	  | movie   | 2 |

## Stream Return

<div tab="code">
  
```gql
CALL algo.schema_overview.stream("my_hdc_graph", {}) YIELD r
FILTER r.`node schema(src)` = "account" 
RETURN r
```

```uql
exec{
  algo(schema_overview).params().stream() as r
  where r.`node schema(src)` == "account" 
  return r
} on my_hdc_graph
```

</div>

Result: 

| <div table-width="25">node schema(src)</div> | <div table-width="15">edge schema</div> | <div table-width="25">node schema(dest)</div>  | count |
| --- | --- | --- | --- |
| account  | follow   | account | 2 |
| account  | like	  | movie   | 1 |