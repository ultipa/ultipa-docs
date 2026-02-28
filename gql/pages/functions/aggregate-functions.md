# Aggregate Functions

## Overview

An aggregate function performs a calculation on a set of values and returns a single scalar value.

> **Vertical aggregation** is supported which takes a set of values from *different rows* and aggregates into a single value. **Horizontal aggregation** which takes a set of values from *a group list value* and aggregates into a single value is not yet supported.

### DISTINCT

All aggregate functions support the use of the set quantifier `DISTINCT` to deduplicate values before aggregation.

### Null Values

Rows containing `null` values are ignored by all aggregate functions, except `count(*)`.

## Example Graph

The following examples run against this graph:

<div align=center drawio-diagram='17076' drawio-name="draw_d24ae12e56364da0b67f726a6b5e12d1.jpg"><img src="https://img.ultipa.cn/draw/draw_d24ae12e56364da0b67f726a6b5e12d1.jpg?v='1733308261481'"/></div>

## avg()

Computes the average of a set of numeric values.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
    <col>
    <col style="width:30%;">
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>avg(&lt;values&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;values&gt;</code></td>
      <td>Numeric</td>
      <td>The target values</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>DOUBLE</code></td>
    </tr>
  </tbody>
</table>

```gql
MATCH (n)
RETURN avg(n.score)
```

Result: 

| avg(n.score) |
| -- |
| 7.33333333333333 |

## collect_list()

Collects a set of values into a list.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
    <col>
    <col style="width:30%;">
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>collect_list(&lt;values&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;values&gt;</code></td>
      <td>Any</td>
      <td>The target values</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>LIST</code></td>
    </tr>
  </tbody>
</table>

```gql
MATCH (n)
RETURN collect_list(n.title)
```

Result: 

| collect_list(n.title) |
| -- |
| ["Optimizing Queries","Efficient Graph Search","Path Patterns"] |

## count()

Returns the number of rows in the input.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
    <col>
    <col style="width:30%;">
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>count(&lt;values&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;values&gt;</code></td>
      <td>Any</td>
      <td>The target values</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>UINT</code></td>
    </tr>
  </tbody>
</table>

```gql
MATCH (n)
RETURN count(n)
```

Result: 

| count(n) |
| -- |
| 3 |

### count(*)

`count(*)` returns the number of rows in the intermediate result table.

Comparing the following two queries, the `null` values are only considered when using `count(*)`:

```gql
FOR item IN [1, "a", "2", "b3", null]
RETURN count(item)
```

Result: 

| count(item) |
| -- |
| 4 |

```gql
FOR item IN [1, "a", "2", "b3", null]
RETURN count(*)
```

Result: 

| count(\*) |
| -- |
| 5 |

### count(DISTINCT)

You can include the set quantifier `DISTINCT` in `count()` to return the number of distinct rows in the input.

```gql
FOR item IN [1, 1, "a", "2", "b3"]
RETURN count(DISTINCT item)
```

Result: 

| count(DISTINCT item) |
| -- |
| 4 |

## max()

Returns the maximum value in a set of values.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
    <col>
    <col style="width:30%;">
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>max(&lt;values&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;values&gt;</code></td>
      <td>Any</td>
      <td>The target values</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3">Numeric</td>
    </tr>
  </tbody>
</table>

```gql
MATCH (n)
RETURN max(n.score)
```

Result: 

| max(n.score) |
| -- |
| 9 |

```gql
FOR item IN [1, "a", "2.1", "b3"]
RETURN max(item)
```

Result: 

| max(item) |
| -- |
| 2 |

## min()

Returns the minimum value in a set of values.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
    <col>
    <col style="width:30%;">
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>min(&lt;values&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;values&gt;</code></td>
      <td>Any</td>
      <td>The target values</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3">Numeric</td>
    </tr>
  </tbody>
</table>

```gql
MATCH (n)
RETURN min(n.score)
```

Result: 

| min(n.score) |
| -- |
| 6 |

```gql
FOR item IN [3, "a", "0.2", "b2"]
RETURN min(item)
```

Result: 

| min(item) |
| -- |
| 0 |

## percentile_cont()

Computes the continuous percentile value over a set of numeric values.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
    <col>
    <col style="width:40%;">
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>percentile_cont(&lt;values&gt;, &lt;percentile&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;values&gt;</code></td>
      <td>Numeric</td>
      <td>The target values</td>
    </tr>
    <tr>
      <td><code>&lt;percentile&gt;</code></td>
      <td>Numeric</td>
      <td>Number between 0.0 and 1.0</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>DOUBLE</code></td>
    </tr>
  </tbody>
</table>

`percentile_cont()` is computed using the following steps:

- Sort the values in ascending order.
- Compute the percentile position as `p = percentile × (n − 1) + 1`, where `n` is the number of non-null values.
- Determine the percentile value using linear interpolation:
  - If `p` is an integer, the corresponding value at that position is the percentile value.
  - If `p` is a decimal between two integers `p1` and `p2` (`p1` < `p` < `p2`), interpolate between the value `v1` at position `p1` and the value `v2` at position `p2` to compute the percentile value as `v1 + (p - p1) × (v2 - v1)`. 
  
```gql
FOR item IN [3, 9, 4, 7, 6]
RETURN percentile_cont(item, 0.4)
```

Result: 

| percentile_cont(item, 0.4) |
| -- |
| 5.2 |

```gql
FOR item IN [3, 9, 4, 7, 6]
RETURN percentile_cont(item, 0.5)
```

Result: 

| percentile_cont(item, 0.5) |
| -- |
| 6 |

## percentile_disc()

Computes the discrete percentile value over a set of numeric values.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
    <col>
    <col style="width:40%;">
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>percentile_disc(&lt;values&gt;, &lt;percentile&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;values&gt;</code></td>
      <td>Numeric</td>
      <td>The target values</td>
    </tr>
    <tr>
      <td><code>&lt;percentile&gt;</code></td>
      <td>Numeric</td>
      <td>Number between 0.0 and 1.0</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>DOUBLE</code></td>
    </tr>
  </tbody>
</table>

`percentile_disc()` is computed using the following steps:

- Sort the values in ascending order.
- Compute the percentile position as `p = ceil(percentile × n)`, where `n` is the number of non-null values.
- The value at the position `p` is selected as the percentile value.

```gql
FOR item IN [3, 9, 4, 7, 6]
RETURN percentile_disc(item, 0.4)
```

Result: 

| percentile_disc(item, 0.4) |
| -- |
| 4 |

```gql
FOR item IN [3, 9, 4, 7, 6]
RETURN percentile_disc(item, 0.5)
```

Result: 

| percentile_disc(item, 0.5) |
| -- |
| 6 |

## stddev_pop()

Computes the population standard deviation of a set of numeric values.

<div style="text-align: center;">
  <math>
    <mrow>
      <mi>stddev_pop(</mi>
      <msub>
        <mi>x</mi>
        <mi>1</mi>
      </msub>
      <mi>, ...,&nbsp;</mi>
      <msub>
        <mi>x</mi>
        <mi>n</mi>
      </msub>
      <mi>)</mi>
      <mo>=</mo>
      <msqrt>
        <mfrac>
          <mn>1</mn>
          <mrow>
            <mi>n</mi>
          </mrow>
        </mfrac>
        <msubsup>
          <mo>∑</mo>
          <msub>
            <mi>i</mi> 
            <mo>=</mo>
            <mn>1</mn> 
          </msub>
          <mn>n</mn>
        </msubsup>
        <mrow>
          <msup>
            <mrow>
              <mo>(</mo>
              <msub>
                <mi>x</mi>
                <mi>i</mi>
              </msub>
              <mo>&#x2212;</mo>
              <mover>
                <mi>x</mi>
                <mo>&#x2014;</mo>
              </mover>
              <mo>)</mo>  
            </mrow>
            <mn>2</mn>
          </msup>
        </mrow>
      </msqrt>
    </mrow>
  </math>
</div>

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
    <col>
    <col style="width:30%;">
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>stddev_pop(&lt;values&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;values&gt;</code></td>
      <td>Numeric</td>
      <td>The target values</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3">Numeric</td>
    </tr>
  </tbody>
</table>

```gql
MATCH (n)
RETURN stddev_pop(n.score)
```

Result: 

| stddev_pop(n.score) |
| -- |
| 1.24721912892465 |

## stddev_samp()

Computes the sample standard deviation of a set of numeric values.

<div style="text-align: center;">
  <math>
    <mrow>
      <mi>stddev_samp(</mi>
      <msub>
        <mi>x</mi>
        <mi>1</mi>
      </msub>
      <mi>, ...,&nbsp;</mi>
      <msub>
        <mi>x</mi>
        <mi>n</mi>
      </msub>
      <mi>)</mi>
      <mo>=</mo>
      <msqrt>
        <mfrac>
          <mn>1</mn>
          <mrow>
            <mi>n</mi>
            <mo>&#x2212;</mo>
            <mn>1</mn>
          </mrow>
        </mfrac>
        <msubsup>
          <mo>∑</mo>
          <msub>
            <mi>i</mi> 
            <mo>=</mo>
            <mn>1</mn> 
          </msub>
          <mn>n</mn>
        </msubsup>
        <mrow>
          <msup>
            <mrow>
              <mo>(</mo>
              <msub>
                <mi>x</mi>
                <mi>i</mi>
              </msub>
              <mo>&#x2212;</mo>
              <mover>
                <mi>x</mi>
                <mo>&#x2014;</mo>
              </mover>
              <mo>)</mo>  
            </mrow>
            <mn>2</mn>
          </msup>
        </mrow>
      </msqrt>
    </mrow>
  </math>
</div>

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
    <col>
    <col style="width:30%;">
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>stddev_samp(&lt;values&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;values&gt;</code></td>
      <td>Numeric</td>
      <td>The target values</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>DOUBLE</code></td>
    </tr>
  </tbody>
</table>

```gql
MATCH (n)
RETURN stddev_samp(n.score)
```

Result: 

| stddev_samp(n.score) |
| -- |
| 1.52752523165195 |

## sum()

Computes the sum of a set of numeric values.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
    <col>
    <col style="width:30%;">
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>sum(&lt;values&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;values&gt;</code></td>
      <td>Numeric</td>
      <td>The target values</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>DOUBLE</code></td>
    </tr>
  </tbody>
</table>

```gql
MATCH (n)
RETURN sum(n.score)
```

Result: 

| sum(n.score) |
| -- |
| 22 |
