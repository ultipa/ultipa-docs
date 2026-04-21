# Gradient Descent

Gradient descent is a fundamental optimization algorithm widely used in graph embedding models. Its primary purpose is to iteratively update model parameters in order to minimize a predefined loss/cost function.

To handle the computational challenges of large-scale graph embedding, several variants of gradient descent have been developed. Two commonly used ones are <b>Stochastic Gradient Descent (SGD)</b> and <b>Mini-Batch Gradient Descent (MBGD)</b>. These variations update model parameters using gradients computed from either a single data point or a small subset of data during each iteration.

## Basic Form

Consider a real-life scenario: standing on a mountain and aiming to descend as quickly as possible. While there may be an optimal path, identifying if in advance is difficult. Instead, a step-by-step approach is used—at each position, you assess the steepest downward direction and take a step accordingly. At each iteration, the algorithm calculates the direction that minimizes the loss most rapidly (the gradient) and updates the parameters accordingly. The process continues until the minimum (the base of the mountain) is reached.

Building on this concept, <b>gradient descent</b> serves as the technique to find the minimum of a function by moving in the direction of the negative gradient. Conversely, if the goal is to find a maximum, the algorithm follows the positive gradient direction, a technique known as gradient ascent.

along the gradient's descent. Conversely, if the aim is to locate the maximum value while ascending along the gradient's direction, the approach becomes gradient ascent.

Given a function <math><mi>J</mi><mi>(</mi><mi>θ</mi><mi>)</mi></math>, the basic form of gradient descent is:

<center><img width="140" src="https://img.ultipa.cn/2022-09-26-14-29-54-Gardient-Descent.jpg"></center>

where <math><mi>∇</mi><mi>J</mi></math> is the <a href="#Gradient">gradient</a> of the function at the position of <math><mi>θ</mi></math>, <math><mi>η</mi></math> is the <b>learning rate</b>. Since gradient is the steepest ascent direction, a minus symbol is used before <math><mi>η</mi><mi>∇</mi><mi>J</mi></math> to get the steepest descent.

The <b>learning rate</b> determines the step size taken in the direction of the gradient during optimization. In the example above, the learning rate corresponds to the distance covered in each step during the descent.

> The learning rate is typically kept constant throughout the training process, where the rate is adjusted over time—often decreased gradually or according to a predefined schedule. Such adjustments are designed to improve convergence stability and optimization efficiency.

### Example: Single-Variable Function

For function <math><mi>J</mi><mo>=</mo><msup><mi>θ</mi><mn>2</mn></msup><mo>+</mo><mn>10</mn></math>, its gradient (in this case, same as the <a href="#Derivative">derivative</a>) is <math><mi>∇</mi><mi>J</mi><mo>=</mo><mi>J</mi><mo>&#x2032;</mo><mi>(</mi><mi>θ</mi><mi>)</mi><mo>=</mo><mn>2</mn><mi>θ</mi></math>.

If we start at position <math><msub><mi>θ</mi><mn>0</mn></msub><mo>=</mo><mn>1</mn></math>, and set <math><mi>η</mi><mo>=</mo><mn>0.2</mn></math>, the next movements following gradient descent would be:

- <math><msub><mi>θ</mi><mn>1</mn></msub><mo>=</mo><msub><mi>θ</mi><mn>0</mn></msub><mo>-</mo><mi>η</mi><mo>×</mo><mn>2</mn><msub><mi>θ</mi><mn>0</mn></msub><mo>=</mo><mn>1</mn><mo>-</mo><mn>0.2</mn><mo>×</mo><mn>2</mn><mo>×</mo><mn>1</mn><mo>=</mo><mn>0.6</mn></math>
- <math><msub><mi>θ</mi><mn>2</mn></msub><mo>=</mo><msub><mi>θ</mi><mn>1</mn></msub><mo>-</mo><mi>η</mi><mo>×</mo><mn>2</mn><msub><mi>θ</mi><mn>1</mn></msub><mo>=</mo><mn>0.6</mn><mo>-</mo><mn>0.2</mn><mo>×</mo><mn>2</mn><mo>×</mo><mn>0.6</mn><mo>=</mo><mn>0.36</mn></math>
- <math><msub><mi>θ</mi><mn>3</mn></msub><mo>=</mo><msub><mi>θ</mi><mn>2</mn></msub><mo>-</mo><mi>η</mi><mo>×</mo><mn>2</mn><msub><mi>θ</mi><mn>2</mn></msub><mo>=</mo><mn>0.36</mn><mo>-</mo><mn>0.2</mn><mo>×</mo><mn>2</mn><mo>×</mo><mn>0.36</mn><mo>=</mo><mn>0.216</mn></math>
- ...
- <math><msub><mi>θ</mi><mn>18</mn></msub><mo>=</mo><mn>0.00010156</mn></math>
- ...

As the number of steps increases, the process gradually converges toward <math><mi>θ</mi><mo>=</mo><mn>0</mn></math>, ultimately reaching the minimum of the function.

<center><img width="700" src="https://img.ultipa.cn/2022-09-22-16-51-03-example.jpg"></center>

### Example: Multi-Variable Function

For function <math><mi>J</mi><mi>(</mi><mi>Θ</mi><mi>)</mi><mo>=</mo><msubsup><mi>θ</mi><mn>1</mn><mn>2</mn></msubsup><mo>+</mo><msubsup><mi>θ</mi><mn>2</mn><mn>2</mn></msubsup></math>, its gradient is <math><mi>∇</mi><mi>J</mi><mo>=</mo><mi>(</mi><mn>2</mn><msub><mi>θ</mi><mn>1</mn></msub><mi>,&nbsp;</mi><mn>2</mn><msub><mi>θ</mi><mn>2</mn></msub><mi>)</mi></math>.

If starts at position <math><msub><mi>Θ</mi><mn>0</mn></msub><mo>=</mo><mi>(</mi><mn>-1</mn><mi>,&nbsp;</mi><mn>-2</mn><mi>)</mi></math>, and set <math><mi>η</mi><mo>=</mo><mn>0.1</mn></math>, the next movements following gradient descent would be:

- <math><msub><mi>Θ</mi><mn>1</mn></msub><mo>=</mo><mi>(</mi><mn>-1</mn><mo>-</mo><mn>0.1</mn><mo>×</mo><mn>2</mn><mo>×</mo><mn>-1</mn><mi>,&nbsp;</mi><mn>-2</mn><mo>-</mo><mn>0.1</mn><mo>×</mo><mn>2</mn><mo>×</mo><mn>-2</mn><mi>)</mi><mo>=</mo><mi>(</mi><mn>-0.8</mn><mi>,&nbsp;</mi><mn>-1.6</mn><mi>)</mi></math>
- <math><msub><mi>Θ</mi><mn>2</mn></msub><mo>=</mo><mi>(</mi><mn>-0.64</mn><mi>,&nbsp;</mi><mn>-1.28</mn><mi>)</mi></math>
- <math><msub><mi>Θ</mi><mn>3</mn></msub><mo>=</mo><mi>(</mi><mn>-0.512</mn><mi>,&nbsp;</mi><mn>-1.024</mn><mi>)</mi></math>
- ...
- <math><msub><mi>Θ</mi><mn>20</mn></msub><mo>=</mo><mi>(</mi><mn>-0.011529215</mn><mi>,&nbsp;</mi><mn>-0.002305843</mn><mi>)</mi></math>
- ...

As the number of steps increases, the process gradually converges toward <math><mi>Θ</mi><mo>=</mo><mi>(</mi><mn>0</mn><mi>,&nbsp;</mi><mn>0</mn><mi>)</mi></math>, ultimately reaching the minimum of the function.

## Application in Graph Embeddings

In the process of training a neural network model for graph embeddings, a <b>loss or cost function</b>, typically denoted as <math><mi>J</mi><mi>(</mi><mi>Θ</mi><mi>)</mi></math>, is used to assess the discrepancy between the model's output and the expected outcomes. To minimize this loss, gradient descent is used. This iterative optimization technique updates the model's parameters in the opposite direction of the gradient <math><mi>∇</mi><mi>J</mi></math>. This process continues until the model converges to a minimum, thereby optimizing performance. 

To balance computational efficiency and model accuracy, several variants of gradient descent are commonly used in practice, including:

1. Stochastic Gradient Descent (SGD)
2. Mini-Batch Gradient Descent (MBGD)

### Example

Consider a scenario where we are training a neural network model using a set of <math><mi>m</mi></math> samples. Each sample consists of an input value and its corresponding expected output. Let's use <math><msup><mi>x</mi><mrow><mi>(</mi><mi>i</mi><mi>)</mi></mrow></msup></math> and <math><msup><mi>y</mi><mrow><mi>(</mi><mi>i</mi><mi>)</mi></mrow></msup></math> (<math><mi>i</mi><mo>=</mo><mn>1</mn><mi>,&nbsp;</mi><mn>2</mn><mi>,&nbsp;</mi><mi>...</mi><mi>,&nbsp;</mi><mi>m</mi></math>) denote the input and expected output of the <math><mi>i</mi></math>-th sample.

The <b>hypothesis</b> <math><mi>h</mi><mi>(</mi><mi>Θ</mi><mi>)</mi></math> of the model is defined as:

<center><img width="380" src="https://img.ultipa.cn/2022-09-26-14-11-22-Hypothesis.jpg"></center>
  
Here, <math><mi>Θ</mi></math> represents the model's parameters <math><msub><mi>θ</mi><mn>0</mn></msub></math> ~ <math><msub><mi>θ</mi><mi>n</mi></msub></math>, and <math><msup><mi>x</mi><mrow><mi>(</mi><mi>i</mi><mi>)</mi></mrow></msup></math> is the <math><mi>i</mi></math>-th input vector, consisting of <math><mi>n</mi></math> features. The model computes the output using a function <math><mi>h</mi><mi>(</mi><mi>Θ</mi><mi>)</mi></math>, which performs a weighted combination of the input features.
  
The objective of model training is to identify the optimal values of <math><msub><mi>θ</mi><mn>j</mn></msub></math> that produce outputs as close as possible to the expected values. At the beginning of training, <math><msub><mi>θ</mi><mn>j</mn></msub></math> is initialized with random values.

During each iteration of model training, after computing the outputs for all samples, the mean squared error (MSE) is used as the <b>loss/cost function</b> <math><mi>J</mi><mi>(</mi><mi>Θ</mi><mi>)</mi></math>. It measures the average squared difference between the predicted output and its corresponding expected value:

<center><img width="280" src="https://img.ultipa.cn/2022-09-26-14-16-56-Loss.jpg"></center>

> In the standard MSE formula, the denominator is usually <math><mfrac><mi>1</mi><mi>m</mi></mfrac></math>. However, <math><mfrac><mi>1</mi><mrow><mn>2</mn><mi>m</mi></mrow></mfrac></math> is often used instead to offset the squared term when taking the derivative. This leads to the elimination of the constant coefficient during gradient calculation, simplifying subsequent computations without affecting the final result.

Subsequently, gradient descent is used to update the parameters <math><msub><mi>θ</mi><mi>j</mi></msub></math>. The partial derivative of the loss function with respect to <math><msub><mi>θ</mi><mi>j</mi></msub></math> is calculated as follows:

<center><img width="480" src="https://img.ultipa.cn/2022-09-26-14-21-41-θj-1.jpg"></center>

Hence, update <math><msub><mi>θ</mi><mi>j</mi></msub></math> as:

<center><img width="320" src="https://img.ultipa.cn/2022-09-26-14-23-56-θj-2.jpg"></center>

The summation from <math><mi>i</mi><mo>=</mo><mn>1</mn></math> to <math><mi>m</mi></math> indicates that all <math><mi>m</mi></math> samples are used in each iteration to update the parameters. This approach is known as <b>Batch Gradient Descent</b> (BGD), the original and most straightforward form of the gradient descent algorithm. In BGD, the entire sample dataset is used to compute the gradient of the cost function during each iteration.

While BGD offers precise convergence to the minimum of the cost function, it can be computationally intensive for large datasets. To improve efficiency and convergence speed, SGD and MBGD were introduced. These variants use subsets of the data in each iteration, significantly accelerating the optimization process while still aiming to find the optimal parameters.

### Stochastic Gradient Descent

Stochastic gradient descent (SGD) only selects one sample in random to calculate the gradient for each iteration.

When employing SGD, the above loss function should be expressed as:

<center><img width="250" src="https://img.ultipa.cn/2022-09-26-14-26-08-θj-2=3.jpg"></center>

The partial derivative with respect to <math><msub><mi>θ</mi><mi>j</mi></msub></math> is:

<center><img width="450" src="https://img.ultipa.cn/2022-09-26-14-27-27-θj-4.jpg"></center>

Update <math><msub><mi>θ</mi><mi>j</mi></msub></math> as:

<center><img width="280" src="https://img.ultipa.cn/2022-09-26-14-27-36-θj-5.jpg"></center>

SGD reduces computational complexity by using only one sample per iteration, eliminating the need for summation and averaging. This leads to faster computation but may sacrifice some accuracy in the gradient estimation.

### Mini-Batch Gradient Descent

BGD and SGD both represent two extremes: BGD uses all samples, while SGD uses only one. Mini-batch Gradient Descent (MBGD) strikes a balance by randomly selecting a subset of <math><mi>x</mi><mo>∈</mo><mi>(</mi><mn>1</mn><mi>,&nbsp;</mi><mi>m</mi><mi>)</mi></math> samples for computation.

## Mathematical Basics

### Derivative

The derivative of a single-variable function <math><mi>f</mi><mi>(</mi><mi>x</mi><mi>)</mi></math> is often denoted as <math><mi>f</mi><mo>&#x2032;</mo><mi>(</mi><mi>x</mi><mi>)</mi></math> or <math><mfrac><mrow><mi>d</mi><mi>f</mi></mrow><mrow><mi>d</mi><mi>x</mi></mrow></mfrac></math>, it represents how <math><mi>f</mi><mi>(</mi><mi>x</mi><mi>)</mi></math> changes with respect to a slight change in <math><mi>x</mi></math> at a given point.

Graphically, <math><mi>f</mi><mo>&#x2032;</mo><mi>(</mi><mi>x</mi><mi>)</mi></math> corresponds to the slope of the tangent line to the function's curve. The derivative at point <math><mi>x</mi></math> is:

<center><img width="320" src="https://img.ultipa.cn/img/2023-08-17-13-31-39-derivative.jpg"></center>

For example, <math><mi>f</mi><mi>(</mi><mi>x</mi><mi>)</mi><mo>=</mo><msup><mi>x</mi><mn>2</mn></msup><mo>+</mo><mn>10</mn></math>, at point <math><mi>x</mi><mo>=</mo><mn>-7</n></math>:

<center><img width="700" src="https://img.ultipa.cn/img/2023-08-17-13-34-49-eg1.jpg"></center>

<center><img width="500" src="https://img.ultipa.cn/img/2023-09-07-11-15-20-fx.jpg"></center>

> A tangent line is a straight line that touches a function's curve at exactly one point and has the same slope (direction) as the curve at that point.

### Partial Derivative

The partial derivative of a multiple-variable function measures how the function changes as one specific variable changes, while all other variables are held constant. For a function <math><mi>f</mi><mi>(</mi><mi>x</mi><mo>,</mo><mi>y</mi><mi>)</mi></math>, its partial derivative with respect to <math><mi>x</mi></math> at a particular point <math><mi>(</mi><mi>x</mi><mo>,</mo><mi>y</mi><mi>)</mi></math> is denoted as <math><mfrac><mrow><mi>∂</mi><mi>f</mi></mrow><mrow><mi>∂</mi><mi>x</mi></mrow></mfrac></math> or <math><msubsup><mi>f</mi><mi>x</mi><mo>&#x2032;</mo></msubsup></math>:  

<center><img width="400" src="https://img.ultipa.cn/img/2023-08-17-13-44-03-partial-deriative.jpg"></center>

For example, <math><mi>f</mi><mi>(</mi><mi>x</mi><mo>,</mo><mi>y</mi><mi>)</mi><mo>=</mo><msup><mi>x</mi><mn>2</mn></msup><mo>+</mo><msup><mi>y</mi><mn>2</mn></msup></math>, at point <math><mi>x</mi><mo>=</mo><mn>-4</mn></math>, <math><mi>y</mi><mo>=</mo><mn>-6</mn></math>:
  
<center><img width="750" src="https://img.ultipa.cn/img/2023-08-17-13-46-00-eg2.jpg"></center>

<center><img width="700" src="https://img.ultipa.cn/img/2023-08-17-11-05-44-derivative-2.jpg"><span style="color:#999999;"><br><math><mi>L</mi><mn>1</mn></math> shows how the function changes as you move along the Y-axis, while keeping <math><mi>x</mi></math> constant; <math><mi>L</mi><mn>2</mn></math> shows how the function changes as you move along the X-axis, while keeping <math><mi>y</mi></math> constant.</span></center>

### Directional Derivative

The <a href="#Partial-Derivative">partial derivative</a> of a function describes how its output changes when moving slightly along one of the coordinate axes. However, when movement occurs in a direction that is not parallel to any axis, the concept of the directional derivative becomes crucial.

The directional derivative is mathematically expressed as the dot product of the vector <math><mi>∇</mi><mi>f</mi></math> composed of all partial derivatives of the function with the unit vector <math><mover><mi>w</mi><mi>→</mi></mover></math> which indicates the direction of the change:

<center><img width="420" src="https://img.ultipa.cn/img/2023-08-17-16-13-26-directional-derivative.jpg"></center>

where <math><mi>|</mi><mover><mi>w</mi><mi>→</mi></mover><mi>|</mi><mo>=</mo><mn>1</mn></math>, <math><mi>θ</mi></math> is the angle between the two vectors, and 

<center><img width="240" src="https://img.ultipa.cn/img/2023-08-17-16-08-28-gradient.jpg"></center>

### Gradient

The gradient shows the direction in which a function increases the fastest. This is the same as finding the maximum <a href="#Directional-Derivative">directional derivative</a>. This occurs when angle <math><mi>θ</mi></math> between the vectors <math><mi>∇</mi><mi>f</mi></math> and <math><mover><mi>w</mi><mi>→</mi></mover></math> is <math><mn>0</mn></math>, as <math><mi>cos</mi><mn>0</mn><mo>=</mo><mn>1</mn></math>, implying that <math><mover><mi>w</mi><mi>→</mi></mover></math> aligns with the direction of <math><mi>∇</mi><mi>f</mi></math>. <math><mi>∇</mi><mi>f</mi></math> is thus called the gradient of a function.

Naturally, the negative gradient points in the direction of the steepest descent.

### Chain Rule

The chain rule describes how to calculate the <a href="#Derivative">derivative</a> of a composite function. In the simpliest form, the derivative of a composite function <math><mi>f</mi><mi>(</mi><mi>g</mi><mi>(</mi><mi>x</mi><mi>)</mi><mi>)</mi></math> can be calculated by multiplying the derivative of <math><mi>f</mi></math> with respect to <math><mi>g</mi></math> by the derivative of <math><mi>g</mi></math> with respect to <math><mi>x</mi></math>:

<center><img width="120" src="https://img.ultipa.cn/img/2023-08-17-14-37-54-chain1.jpg"></center>

For example, <math><mi>s</mi><mi>(</mi><mi>x</mi><mi>)</mi><mo>=</mo><msup><mrow><mi>(</mi><mn>2</mn><mi>x</mi><mo>+</mo><mn>1</mn><mi>)</mi></mrow><mrow><mn>2</mn></mrow></msup></math> is composed of <math><mi>s</mi><mi>(</mi><mi>u</mi><mi>)</mi><mo>=</mo><msup><mi>u</mi><mrow><mn>2</mn></mrow></msup></math> and <math><mi>u</mi><mi>(</mi><mi>x</mi><mi>)</mi><mo>=</mo><mn>2</mn><mi>x</mi><mo>+</mo><mn>1</mn></math>:

<center><img width="320" src="https://img.ultipa.cn/img/2023-08-17-14-26-53-eg3.jpg"></center>

In a multi-variable composite function, the <a href="#Partial-Derivative">partial derivatives</a> are obtained by applying the chain rule to each variable.

For example, <math><mi>s</mi><mi>(</mi><mi>x</mi><mo>,</mo><mi>y</mi><mi>)</mi><mo>=</mo><mi>(</mi><mn>2</mn><mi>x</mi><mo>+</mo><mn>y</mn><mi>)</mi><mi>(</mi><mi>y</mi><mo>-</mo><mn>3</mn><mi>)</mi></math> is composed of <math><mi>s</mi><mi>(</mi><mi>f</mi><mo>,</mo><mi>g</mi><mi>)</mi><mo>=</mo><mi>f</mi><mi>g</mi></math> and <math><mi>f</mi><mi>(</mi><mi>x</mi><mo>,</mo><mi>y</mi><mi>)</mi><mo>=</mo><mn>2</mn><mi>x</mi><mo>+</mo><mn>y</mn></math> and <math><mi>g</mi><mi>(</mi><mi>x</mi><mo>,</mo><mi>y</mi><mi>)</mi><mo>=</mo><mi>y</mi><mo>-</mo><mn>3</mn></math>:

<center><img width="500" src="https://img.ultipa.cn/img/2023-08-17-14-26-58-eg4.jpg"></center>
