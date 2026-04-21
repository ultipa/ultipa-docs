# Vector Similarity

## Overview

This is a utility algorithm that computes the similarity between two given numeric vectors. It supports multiple metrics: **cosine**, **pearson**, **euclidean**, and **jaccard**. Unlike other similarity algorithms that operate on graph structure, this algorithm works directly on user-provided vectors.

## Concepts

### Cosine Similarity

See <a href="/docs/graph-analytics-algorithms/cosine-similarity">Cosine Similarity</a> for details.

### Jaccard Similarity

See <a href="/docs/graph-analytics-algorithms/jaccard-similarity">Jaccard Similarity</a> for details.

> In this algorithm, Jaccard similarity treats vector elements as binary: non-zero values are considered "present" and zero values are "absent". The similarity is computed as the number of positions where both vectors are non-zero divided by the number of positions where at least one is non-zero.

### Euclidean Distance

See <a href="/docs/graph-analytics-algorithms/euclidean-distance">Euclidean Distance</a> for details.

### Pearson Correlation Coefficient

The Pearson correlation coefficient is the most common way of measuring the strength and direction of the linear relationship between two quantitative variables. In the graph, nodes are quantified by <i>N</i> numeric properties (features) of them.

For two variables <i>X= (x<sub>1</sub>, x<sub>2</sub>, ..., x<sub>n</sub>)</i> and <i>Y = (y<sub>1</sub>, y<sub>2</sub>, ..., y<sub>n</sub>)</i> , Pearson correlation coefficient (<i>r</i>) is defined as the ratio of the covariance of them to the product of their standard deviations:

<center><img width=400 src="https://img.ultipa.cn/img/2023-05-30-10-05-44-pearson.jpg"></center>

The Pearson correlation coefficient ranges from -1 to 1:

| <div table-width="23">Pearson correlation coefficient</div> | <div table-width="20">Correlation type</div> | Interpretation |
| -- | -- | -- |
| 0 < r ≤ 1 | Positive correlation | As one variable becomes larger, the other variable becomes larger |
| r = 0 | No linear correlation | (May exist some other types of correlation) |
| -1 ≤ r < 0 | Negative correlation | As one variable becomes larger, the other variable becomes smaller |

## Parameters

| Name | Type | Default | Description |
| -- | -- | -- | -- |
| `vector1` | `LIST` | / | **Required.** First numeric vector. |
| `vector2` | `LIST` | / | **Required.** Second numeric vector. |
| `metric` | `STRING` | `cosine` | Similarity metric: `cosine`, `pearson`, `euclidean`, or `jaccard`. |

## Run Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `similarity` | `FLOAT` | Computed similarity score |

Cosine similarity:

```gql
CALL algo.similarityvec({
  vector1: [1.0, 2.0, 3.0],
  vector2: [4.0, 5.0, 6.0]
}) YIELD similarity
```

Result:

| similarity |
| -- |
| 0.9746318461970762 |

Pearson correlation:

```gql
CALL algo.similarityvec({
  vector1: [1.0, 2.0, 3.0],
  vector2: [4.0, 5.0, 6.0],
  metric: "pearson"
}) YIELD similarity
```

Result:

| similarity |
| -- |
| 1 |

Euclidean distance:

```gql
CALL algo.similarityvec({
  vector1: [1.0, 2.0],
  vector2: [4.0, 6.0],
  metric: "euclidean"
}) YIELD similarity
```

Result:

| similarity |
| -- |
| 0.16666666666666666 |

Jaccard similarity:

```gql
CALL algo.similarityvec({
  vector1: [1.0, 2.0, 3.0],
  vector2: [2.0, 3.0, 4.0],
  metric: "jaccard"
}) YIELD similarity
```

Result:

| similarity |
| -- |
| 1 |

## Stream Mode

Returns the same columns as run mode, streamed for memory efficiency.

```gql
CALL algo.similarityvec.stream({
  vector1: [1.0, 2.0, 3.0],
  vector2: [4.0, 5.0, 6.0]
}) YIELD similarity
RETURN similarity
```

Result:

| similarity |
| -- |
| 0.9746318461970762 |

## Stats Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `similarity` | `FLOAT` | Computed similarity score |

```gql
CALL algo.similarityvec.stats({
  vector1: [1.0, 2.0, 3.0],
  vector2: [4.0, 5.0, 6.0]
}) YIELD similarity
```

Result:

| similarity |
| -- |
| 0.9746318461970762 |
