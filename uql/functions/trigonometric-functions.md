# Trigonometric Functions

## acos()

Computes the angle in radians whose cosine is a given number. The resulting radians will be in the range [0, 𝜋]. If the result is needed in degrees (range [0º, 180º]), you can convert it using the `degrees()` function.

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

```uql
return acos(0.5) * 180 / pi() as degree
```

Result:

| degree |
| -- |
| 60 |

## asin()

Computes the angle in radians whose sine is a given number. The resulting radians will be in the range [-𝜋/2, 𝜋/2]. If the result is needed in degrees (range [-90º, 90º]), you can convert it using the `degrees()` function.

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

```uql
return asin(0.5) * 180 / pi() as degree
```

Result:

| degree |
| -- |
| 30 |

## atan()

Computes the angle in radians whose tangent is a given number. The resulting radians will be in the range [-𝜋/2, 𝜋/2]. If the result is needed in degrees (range [-90º, 90º]), you can convert it using the `degrees()` function.

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

```uql
return atan(1) * 180 / pi() as degree
```

Result:

| degree |
| -- |
| 45 |

## cos()

Computes the cosine of an angle expressed in radians. The output will be in the range [-1, 1]. If the angle is in degrees, you can convert it to radians using the `radians()` function.

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

```uql
return cos(60 * pi() / 180)
```

Result:

| cos(60 * pi() / 180) |
| -- |
| 0.5 |

## cot()

Computes the cotangent of an angle expressed in radians. The output will be in the range (−∞, −1] ∪ [1, +∞). If the angle is in degrees, you can convert it to radians using the `radians()` function.

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
      <td>The angle expressed in radian; <code>cot(0)</code> is undefined</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>DOUBLE</code></td>
    </tr>
  </tbody>
</table>

```uql
return cot(45 * pi() / 180)
```

Result:

| cot(45 * pi() / 180) |
| -- |
| 1 |

## sin()

Computes the sine of an angle expressed in radians. The output will be in the range [-1, 1]. If the angle is in degrees, you can convert it to radians using the `radians()` function.

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

```uql
return sin(30 * pi() / 180)
```

Result:

| sin(30 * pi() / 180) |
| -- |
| 0.5 |

## tan()

Computes the tangent of an angle expressed in radians. The output will be in the range (−∞, +∞). If the angle is in degrees, you can convert it to radians using the `radians()` function.

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

```uql
return tan(45 * pi() / 180)
```

Result:

| tan(45 * pi() / 180) |
| -- |
| 1 |
