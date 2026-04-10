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

Result: 2.32

## ceil()

Rounds a given number up to the nearest integer. `ceiling()` is a synonym to `ceil()`

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

Result: 3.142

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

Result: 1.2

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

Result: 4

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

Result: 7.38905609893065

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

Result: 16

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

Result: 4.605170185988092

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

Result: 3

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

Result: 2

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

Result: 3.141592653589793

## random()

Returns a random floating-point number between 0 (inclusive) and 1 (exclusive). `rand()` is an alias for `random()`.

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
      <td colspan="3"><code>random()</code> or <code>rand()</code></td>
    </tr>
    <tr>
      <td><b>Arguments</b></td>
      <td colspan="3">None</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>FLOAT</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN random()
```

Result: A random value such as 0.4094453725342517

## sign()

Returns the sign of a number: `-1` for negative, `0` for zero, `1` for positive.

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
      <td colspan="3"><code>sign(&lt;num&gt;)</code></td>
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
RETURN sign(-5), sign(0), sign(3.14)
```

Result:

| sign(-5) | sign(0) | sign(3.14) |
| -- | -- | -- |
| -1 | 0 | 1 |
