# Mathematical Functions

## abs()

Returns the absolute value of a given number.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
    <col>
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>abs(&lt;num&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;num&gt;</code></td>
      <td>Numeric</td>
      <td>The target number</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>UINT</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN abs(-2.32)
```

Result: 

| abs(-2.32) |
| -- |
| 2.32 |

## ceil()

Rounds a given number up to the nearest integer.

> `ceiling()` is a synonym to `ceil()`.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
    <col>
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>ceil(&lt;num&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;num&gt;</code></td>
      <td>Numeric</td>
      <td>The target number</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>INT</code></td>
    </tr>
  </tbody>
</table>

```gql
For item in [-2.92, 4.2]
RETURN ceil(item)
```

Result: 

| ceil(item) |
| -- |
| -2 |
| 5 |

## exp()

Computes the value of Euler's number 𝑒 raised to the power of a given number, where 𝑒 is approximately equal to 2.71828.

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
      <td colspan="3"><code>exp(&lt;num&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;num&gt;</code></td>
      <td>Numeric</td>
      <td>The power to which 𝑒 is raised</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>DOUBLE</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN exp(2)
```

Result: 

| exp(2) |
| -- |
| 7.38905609893065 |

## floor()

Rounds a given number down to the nearest integer.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
    <col>
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>floor(&lt;num&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;num&gt;</code></td>
      <td>Numeric</td>
      <td>The target number</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>INT</code></td>
    </tr>
  </tbody>
</table>

```gql
For item in [-2.92, 4.2]
RETURN floor(item)
```

Result: 

| floor(item) |
| -- |
| -3 |
| 4 |

## ln()

Computes the natural logarithm of a given number,  i.e., the logarithm to the base 𝑒 (Euler's number, approximately 2.71828).

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
    <col>
    <col style="width:50%">
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>ln(&lt;num&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;num&gt;</code></td>
      <td>Numeric</td>
      <td>A positive number to for which the logarithm is to be computed</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>DOUBLE</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN ln(100)
```

Result: 

| ln(100) |
| -- |
| 4.60517018598809 |

## log()

Computes the logarithm of a specified number with respect to a given base. 

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
    <col>
    <col style="width:50%">
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>log(&lt;base&gt;, &lt;num&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;base&gt;</code></td>
      <td>Numeric</td>
      <td>A postive number as the base of the logarithm</td>
    </tr>
    <tr>
      <td><code>&lt;num&gt;</code></td>
      <td>Numeric</td>
      <td>A positive number to for which the logarithm is to be computed</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>DOUBLE</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN log(2, 8)
```

Result: 

| log(2, 8) |
| -- |
| 3 |

## log10()

Computes the base 10 logarithm of a given number. 

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
    <col>
    <col style="width:50%">
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>log10(&lt;num&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;num&gt;</code></td>
      <td>Numeric</td>
      <td>A positive number to for which the logarithm is to be computed</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>DOUBLE</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN log10(100)
```

Result: 

| log10(100) |
| -- |
| 2 |

## mod()

Computes the modulus, or the remainder when one number is divided by another.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
    <col>
    <col style="width:45%">
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>mod(&lt;dividend&gt;, &lt;divisor&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;dividend&gt;</code></td>
      <td>Numeric</td>
      <td>The number to be divided</td>
    </tr>
    <tr>
      <td><code>&lt;divisor&gt;</code></td>
      <td>Numeric</td>
      <td>The number by which the dividend is divided</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>DOUBLE</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN mod(9.2, 2)
```

Result: 

| mod(9.2, 2) |
| -- |
| 1.2 |

## pi()

Returns the mathematical constant π (pi) approximately equal to 3.14159. Pi is the ratio of a circle's circumference to its diameter in Euclidean geometry.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td><code>pi()</code></td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td><code>DOUBLE</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN pi()
```

Result: 

| pi() |
| -- |
| 3.14159265358979 |

## power()

Raises a number to the power of another number.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:18%;">
    <col>
    <col style="width:48%">
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>power(&lt;base&gt;, &lt;exponent&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;base&gt;</code></td>
      <td>Numeric</td>
      <td>The number to be raised to a power</td>
    </tr>
    <tr>
      <td><code>&lt;exponent&gt;</code></td>
      <td>Numeric</td>
      <td>The power to which the base is raised</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>DOUBLE</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN power(2, 4)
```

Result: 

| power(2, 4) |
| -- |
| 16 |

## round()

Returns the nearest value of a given number, rounded to a specified position of digits. If two nearest values are equidistant, it returns the one with the larger absolute value.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
    <col>
    <col style="width:53%">
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>round(&lt;num&gt;, [&lt;digit&gt;])</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;num&gt;</code></td>
      <td>Numeric</td>
      <td>The target number to be rounded</td>
    </tr>
    <tr>
      <td><code>&lt;digit&gt;</code></td>
      <td><code>INT</code></td>
      <td>The position of digits to keep:<ul><li>...<br></li><li><code>-2</code> rounds to the hundreds place</li><li><code>-1</code> rounds to the tens place</li><li><code>0</code> rounds to the nearest integer (default)</li><li><code>1</code> rounds to one decimal place</li><li><code>2</code> rounds to two decimal places</li><li>...</li></ul></td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>DOUBLE</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN round(3.1415926, 3)
```

Result: 

| round(3.1415926, 3) |
| -- |
| 3.142 |

## sqrt()

Computes the square root of a given number.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
    <col>
    <col style="width:40%">
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>sqrt(&lt;num&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;num&gt;</code></td>
      <td>Numeric</td>
      <td>The target number</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>DOUBLE</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN sqrt(16)
```

Result: 

| sqrt(16) |
| -- |
| 4 |
