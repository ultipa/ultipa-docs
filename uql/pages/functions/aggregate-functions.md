# Aggregate Functions

## Overview

An aggregate function performs a calculation on a set of values and returns a single scalar value.

### DISTINCT

All aggregate functions support the use of the set quantifier `DISTINCT` to eliminate duplicates before aggregation.

### Null Values

Rows containing `null` values are ignored by all aggregate functions.

## Example Graph

The following examples run against this graph:

<div align=center drawio-diagram='19675' drawio-name='draw_66abc84313b74696bd8d0a14279e6664.jpg'><img src="https://img.ultipa.cn/draw/draw_66abc84313b74696bd8d0a14279e6664.jpg?v='1733308384809'"/></div>

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

```uql
find().nodes() as n
return avg(n.score)
```

Result:

| avg(n.score) |
| -- |
| 7.33333333333333 |

## collect()

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
      <td colspan="3"><code>collect(&lt;values&gt;)</code></td>
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

```uql
find().nodes() as n
return collect(n.title)
```

Result:

| collect(n.title) |
| -- |
| ["Optimizing Queries","Efficient Graph Search","Path Patterns"] |

## count()

Returns the number of records in the input.

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

```uql
find().nodes() as n
return count(n)
```

Result:

| count(n) |
| -- |
| 3 |

```uql
uncollect [1, "a", "2", "b3", null] as item
return count(item)
```

Result:

| count(item) |
| -- |
| 4 |

### count(DISTINCT)

You can include the set quantifier `DISTINCT` in `count()` to return the number of distinct records.

```uql
uncollect [1, 1, "a", "2", "b3", null] as item
return count(DISTINCT item)
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

```uql
find().nodes() as n
return max(n.score)
```

Result:

| max(n.score) |
| -- |
| 9 |

```uql
uncollect [1, "a", "2.1", "b3"] as item
return max(item)
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

```uql
find().nodes() as n
return min(n.score)
```

Result:

| min(n.score) |
| -- |
| 6 |

```uql
uncollect [1, "a", "2.1", "b3"] as item
return min(item)
```

Result:

| min(item) |
| -- |
| 0 |

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

```uql
find().nodes() as n
return stddev_pop(n.score)
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

```uql
find().nodes() as n
return stddev_samp(n.score)
```

Result:

| stddev_samp(n.score) |
| -- |
| 1.52752523165195 |

## sum()

Computes the sum of a set of values.

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

```uql
find().nodes() as n
return sum(n.score)
```

Result:

| sum(n.score) |
| -- |
| 22 |
