## Trigonometric Functions

## acos()

Computes the angle in radians whose cosine is a given number, the output radians will be in the range [0, 𝜋]. If you need the result in degrees, which is in the range [0º, 180º], you can convert it using the `degrees()` function.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
    <col>
    <col style="width:50%;">
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>acos(&lt;num&gt;)</code></td>
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
      <td>The cosine value in the range of [-1,1]</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>DOUBLE</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN degrees(acos(0.5)) AS degree
```

Result: 

| degree |
| -- |
| 60 |

## asin()

Computes the angle in radians whose sine is a given number, the output radians will be in the range [-𝜋/2, 𝜋/2]. If you need the result in degrees, which is in the range [-90º, 90º], you can convert it using the `degrees()` function.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
    <col>
    <col style="width:50%;">
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>asin(&lt;num&gt;)</code></td>
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
      <td>The sine value in the range of [-1,1]</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>DOUBLE</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN degrees(asin(0.5)) AS degree
```

Result: 

| degree |
| -- |
| 30 |

## atan()

Computes the angle in radians whose tangent is a given number, the output radians will be in the range [-𝜋/2, 𝜋/2]. If you need the result in degrees, which is in the range [-90º, 90º], you can convert it using the `degrees()` function.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
    <col>
    <col style="width:50%;">
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>atan(&lt;num&gt;)</code></td>
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
      <td>The tangent value</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>DOUBLE</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN degrees(atan(1)) AS degree
```

Result: 

| degree |
| -- |
| 45 |

## cos()

Computes the cosine of an angle expressed in radian, the output will be in the range [-1, 1]. If you has an angle in degree, you can convert it to radians using the `radians()` function.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
    <col>
    <col style="width:45%;">
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>cos(&lt;radians&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;radians&gt;</code></td>
      <td>Numeric</td>
      <td>The angle expressed in radian</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>DOUBLE</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN cos(radians(60))
```

Result: 

| cos(radians(60)) |
| -- |
| 0.5 |

## cosh()

Computes the hyperbolic cosine of an angle expressed in radian, the output will be in the range [1, +∞).  If you has an angle in degree, you can convert it to radians using the `radians()` function.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
    <col>
    <col style="width:45%;">
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>cosh(&lt;radians&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;radians&gt;</code></td>
      <td>Numeric</td>
      <td>The angle expressed in radian</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>DOUBLE</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN cosh(radians(60))
```

Result: 

| cosh(radians(60)) |
| -- |
| 1.60028685770239 |

## cot()

Computes the cotangent of an angle expressed in radian, the output will be in the range (−∞, −1] ∪ [1, +∞). If you has an angle in degree, you can convert it to radians using the `radians()` function.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
    <col>
    <col style="width:45%;">
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>cot(&lt;radians&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;radians&gt;</code></td>
      <td>Numeric</td>
      <td>The angle expressed in radian; <code>cot(0)</code> is undefined</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>DOUBLE</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN cot(radians(45))
```

Result: 

| cot(radians(45)) |
| -- |
| 1 |

## degrees()

Converts an angle from radians to degrees:

<div style="text-align: center;">
  <math>
    <mrow>
      <mi>degrees</mi>
      <mo>=</mo>
      <mi>radians</mi>
      <mo>&times;</mo>
      <mfrac linethickness="1">
        <mn>180</mn>
        <mi>&pi;</mi>
      </mfrac>
    </mrow>
  </math>
</div>

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
    <col>
    <col style="width:45%;">
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>degrees(&lt;radians&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;radians&gt;</code></td>
      <td>Numeric</td>
      <td>The angle expressed in radian</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>DOUBLE</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN degrees(pi())
```

Result: 

| degrees(pi()) |
| -- |
| 180 |

## radians()

Converts an angle from degrees to radians:

<div style="text-align: center;">
  <math>
    <mrow>
      <mi>radians</mi>
      <mo>=</mo>
      <mi>degrees</mi>
      <mo>&times;</mo>
      <mfrac linethickness="1">
        <mi>&pi;</mi>
        <mn>180</mn>
      </mfrac>
    </mrow>
  </math>
</div>

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
    <col>
    <col style="width:45%;">
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>radians(&lt;degrees&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;degrees&gt;</code></td>
      <td>Numeric</td>
      <td>The angle expressed in degree</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>DOUBLE</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN radians(60)
```

Result: 

| radians(60) |
| -- |
| 1.0471975511966 |

## sin()

Computes the sine of an angle expressed in radian, the output will be in the range [-1, 1]. If you has an angle in degree, you can convert it to radians using the `radians()` function.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
    <col>
    <col style="width:45%;">
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>sin(&lt;radians&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;radians&gt;</code></td>
      <td>Numeric</td>
      <td>The angle expressed in radian</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>DOUBLE</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN sin(radians(30))
```

Result: 

| sin(radians(30)) |
| -- |
| 0.5 |

## sinh()

Computes the hyperbolic sine of an angle expressed in radian, the output will be in the range (−∞, +∞). If you has an angle in degree, you can convert it to radians using the `radians()` function.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
    <col>
    <col style="width:45%;">
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>sinh(&lt;radians&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;radians&gt;</code></td>
      <td>Numeric</td>
      <td>The angle expressed in radian</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>DOUBLE</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN sinh(radians(30))
```

Result: 

| sinh(radians(30)) |
| -- |
| 0.54785347388804 |

## tan()

Computes the tangent of an angle expressed in radian, the output will be in the range (−∞, +∞). If you has an angle in degree, you can convert it to radians using the `radians()` function.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
    <col>
    <col style="width:45%;">
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>tan(&lt;radians&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;radians&gt;</code></td>
      <td>Numeric</td>
      <td>The angle expressed in radian</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>DOUBLE</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN tan(radians(45))
```

Result: 

| tan(radians(45)) |
| -- |
| 1 |

## tanh()

Computes the hyperbolic tangent of an angle expressed in radian, the output will be in the range [−1, 1]. If you has an angle in degree, you can convert it to radians using the `radians()` function.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
    <col>
    <col style="width:45%;">
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>tanh(&lt;radians&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;radians&gt;</code></td>
      <td>Numeric</td>
      <td>The angle expressed in radian</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>DOUBLE</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN tanh(radians(45))
```

Result: 

| tanh(radians(45)) |
| -- |
| 0.655794202632672 |
