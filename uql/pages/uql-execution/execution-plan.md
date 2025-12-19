# Execution Plan

## Overview

When a UQL query is submitted to Ultipa, it first undergoes parsing to validate its syntax. Once parsed, the query is passed through an optimization phase where Ultipa evaluates potential execution strategies based on the current state of the database.

Ultipa's query optimizer selects the most efficient execution plan by considering factors like data distribution, indexing, and potential bottlenecks. This execution plan outlines the optimal sequence of operations, minimizing resource consumption and improving query performance.

<center><img src="https://img.ultipa.cn/img/2024-10-30-17-52-50-UQL-life-cycle.jpg" /><br><span style="color:#999;">Lifecycle of a UQL query</span></center><br>

To examine the execution plan of a query, prefix it with either `EXPLAIN` or `PROFILE`.

## EXPLAIN

The `EXPLAIN` generates the execution plan for a query without actually running it. It provides a detailed tree of execution operators that outlines the steps the query engine will take to retrieve the desired results.

```uql
explain
find().nodes({@account}) as n
return n.name limit 10
```

The output is a structured representation of the execution plan, often referred to as `_explain`.

<p tit="_explain"></p>

```
Exchange{1}{distribution:distribution_type:SINGLETON,partition_ids:[1],gap_type:ROOT}  ::  n.name:ANY
->    Return(ROOT){expr:[n.name]  row_type:n.name:ANY}
        ->    Return(ROOT){expr:[n.name]  row_type:n.name:ANY}
                ->    Limit{limit:10,phase:DEFAULT,row_type:n.name:ANY}
                        ->    NodeSearch{alias:n,access_method:{condition:@account,index_name:schema,query_type:SK_SCHEMA_SCAN},row_type:n:NODE{name:STRING}}
```

## PROFILE

`PROFILE` runs the query and returns both the query results and a `profile_info` table. This table includes details such as the execution operators used, the number of rows each operator produces, and the time cost of each step.

```uql
profile
find().nodes({@account}) as n
return n.name limit 10
```

Sample `profile_info` output:

| level | op_name | op_id | time_cost | rows |
| -- | -- | -- | -- | -- |
| --1 | RETURN | 1 | 17μs | 121 |
| ----2 | RETURN | 2 | 8μs | 121 |
| ------3 | LIMIT_SKIP | 3 | 1μs | 121 |
| --------4 | NODE_SCAN | 4 | 440μs | 121 |
