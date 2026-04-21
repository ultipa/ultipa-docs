# Vector Similarity

## Overview

Computes the similarity between two given numeric vectors. Unlike other similarity algorithms that operate on graph structure or node properties, this algorithm works directly on user-provided vectors.

Four metrics are supported:

- **Cosine**: Cosine of the angle between two vectors. See <a href="/docs/graph-analytics-algorithms/cosine-similarity">Cosine Similarity</a> for details.
- **Pearson**: Linear correlation between two vectors. See <a href="/docs/graph-analytics-algorithms/pearson-correlation-coefficient">Pearson Correlation Coefficient</a> for details.
- **Euclidean**: Normalized Euclidean distance between two vectors. See <a href="/docs/graph-analytics-algorithms/euclidean-distance">Euclidean Distance</a> for details.
- **Jaccard**: Ratio of positions where both vectors are non-zero to positions where at least one is non-zero. See <a href="/docs/graph-analytics-algorithms/jaccard-similarity">Jaccard Similarity</a> for details.

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
