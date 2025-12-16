# Gradient Descent

Gradient descent stands as a foundational optimization algorithm extensively employed in graph embeddings. Its primary purpose is to iteratively adjust the parameters of a graph embedding model to minimize a predefined loss/cost function.

Several variations of gradient descent have emerged, each designed to address specific challenges associated with large-scale graph embedding tasks. Noteworthy variations include <b>Stochastic Gradient Descent (SGD)</b> and <b>Mini-Batch Gradient Descent (MBGD)</b>. These variations update model parameters by leveraging the gradient computed from either a single or a smaller subset of data during each iteration.

## Basic Form

Consider a real-life scenario: imagine standing atop a mountain and desiring to descend as swiftly as possible. Naturally, there exists an optimal path downwards, yet identifying this precise route is often an arduous undertaking. More frequently, a step-by-step approach is taken. In essence, with each stride to a new position, the next course of action is determined by calculating the direction (i.e., gradient descent) that allows the steepest descent, enabling movement towards the subsequent point in that direction. This iterative process persists until the foot of the mountain is reached.

Revolving around this concept, <b>gradient descent</b> serves as the technique to pinpoint the minimum value along the gradient's descent. Conversely, if the aim is to locate the maximum value while ascending along the gradient's direction, the approach becomes gradient ascent.

Given a function <math><mi>J</mi><mi>(</mi><mi>θ</mi><mi>)</mi></math>, the basic form of gradient descent is:

<center><img width="140" src="https://img.ultipa.cn/2022-09-26-14-29-54-Gardient-Descent.jpg"></center>

where <math><mi>∇</mi><mi>J</mi></math> is the <a href="#Gradient">gradient</a> of the function at the position of <math><mi>θ</mi></math>, <math><mi>η</mi></math> is the <b>learning rate</b>. Since gradient is the steepest ascent direction, a minus symbol is used before <math><mi>η</mi><mi>∇</mi><mi>J</mi></math> to get the steepest descent.

<b>Learning rate</b> determines the length of each step along the gradient descent direction towards the target. In the example above, the learning rate can be thought of as the distance covered in each step we take.

> The learning rate typically remains constant during the model's training process. However, variations and adaptations of the model might incorporate learning rate scheduling, where the learning rate could potentially be adjusted over the course of training, decreasing gradually or according to predefined schedules. These adjustments are designed to enhance convergence and optimization efficiency.

### Example: Single-Variable Function

For function <math><mi>J</mi><mo>=</mo><msup><mi>θ</mi><mn>2</mn></msup><mo>+</mo><mn>10</mn></math>, its gradient (in this case, same as the <a href="#Derivative">derivative</a>) is <math><mi>∇</mi><mi>J</mi><mo>=</mo><mi>J</mi><mo>&#x2032;</mo><mi>(</mi><mi>θ</mi><mi>)</mi><mo>=</mo><mn>2</mn><mi>θ</mi></math>.

If starts at position <math><msub><mi>θ</mi><mn>0</mn></msub><mo>=</mo><mn>1</mn></math>, and set <math><mi>η</mi><mo>=</mo><mn>0.2</mn></math>, the next movements following gradient descent would be:

- <math><msub><mi>θ</mi><mn>1</mn></msub><mo>=</mo><msub><mi>θ</mi><mn>0</mn></msub><mo>-</mo><mi>η</mi><mo>×</mo><mn>2</mn><msub><mi>θ</mi><mn>0</mn></msub><mo>=</mo><mn>1</mn><mo>-</mo><mn>0.2</mn><mo>×</mo><mn>2</mn><mo>×</mo><mn>1</mn><mo>=</mo><mn>0.6</mn></math>
- <math><msub><mi>θ</mi><mn>2</mn></msub><mo>=</mo><msub><mi>θ</mi><mn>1</mn></msub><mo>-</mo><mi>η</mi><mo>×</mo><mn>2</mn><msub><mi>θ</mi><mn>1</mn></msub><mo>=</mo><mn>0.6</mn><mo>-</mo><mn>0.2</mn><mo>×</mo><mn>2</mn><mo>×</mo><mn>0.6</mn><mo>=</mo><mn>0.36</mn></math>
- <math><msub><mi>θ</mi><mn>3</mn></msub><mo>=</mo><msub><mi>θ</mi><mn>2</mn></msub><mo>-</mo><mi>η</mi><mo>×</mo><mn>2</mn><msub><mi>θ</mi><mn>2</mn></msub><mo>=</mo><mn>0.36</mn><mo>-</mo><mn>0.2</mn><mo>×</mo><mn>2</mn><mo>×</mo><mn>0.36</mn><mo>=</mo><mn>0.216</mn></math>
- ...
- <math><msub><mi>θ</mi><mn>18</mn></msub><mo>=</mo><mn>0.00010156</mn></math>
- ...

As the number of steps increases, we progressively converge towards the position <math><mi>θ</mi><mo>=</mo><mn>0</mn></math>, ultimately reaching the minimum value of the function.

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

As the number of steps increases, we progressively converge towards the position <math><mi>Θ</mi><mo>=</mo><mi>(</mi><mn>0</mn><mi>,&nbsp;</mi><mn>0</mn><mi>)</mi></math>, ultimately reaching the minimum value of the function.

## Application in Graph Embeddings

In the process of training a neural network model in graph embeddings, a <b>loss or cost function</b>, denoted as <math><mi>J</mi><mi>(</mi><mi>Θ</mi><mi>)</mi></math>, is frequently employed to assess the disparity between the model's output and the expected outcome. The technique of gradient descent is then applied to minimize this loss function. This involves iteratively adjusting the model's parameters in the opposite direction of the gradient <math><mi>∇</mi><mi>J</mi></math> until convergence, thereby optimizing the model. 

To strike a balance between computational efficiency and accuracy, several variants of gradient descent have been employed in practice, including:

1. Stochastic Gradient Descent (SGD)
2. Mini-Batch Gradient Descent (MBGD)

### Example

Consider a scenario where we are utilizing a set of <math><mi>m</mi></math> samples to train a neural network model. Each sample consists of input values and their corresponding expected outputs. Let's use <math><msup><mi>x</mi><mrow><mi>(</mi><mi>i</mi><mi>)</mi></mrow></msup></math> and <math><msup><mi>y</mi><mrow><mi>(</mi><mi>i</mi><mi>)</mi></mrow></msup></math> (<math><mi>i</mi><mo>=</mo><mn>1</mn><mi>,&nbsp;</mi><mn>2</mn><mi>,&nbsp;</mi><mi>...</mi><mi>,&nbsp;</mi><mi>m</mi></math>) denote the <math><mi>i</mi></math>-th input value and the expected output.

The <b>hypothesis</b> <math><mi>h</mi><mi>(</mi><mi>Θ</mi><mi>)</mi></math> of the model is defined as:

<center><img width="380" src="https://img.ultipa.cn/2022-09-26-14-11-22-Hypothesis.jpg"></center>
  
Here, <math><mi>Θ</mi></math> represents the model's parameters <math><msub><mi>θ</mi><mn>0</mn></msub></math> ~ <math><msub><mi>θ</mi><mi>n</mi></msub></math>, and <math><msup><mi>x</mi><mrow><mi>(</mi><mi>i</mi><mi>)</mi></mrow></msup></math> is the <math><mi>i</mi></math>-th input vector, consisting of <math><mi>n</mi></math> features. The model uses function <math><mi>h</mi><mi>(</mi><mi>Θ</mi><mi>)</mi></math> to compute the output by performing a weighted combination of the input features.
  
The objective of model training is to identify the optimal values of <math><msub><mi>θ</mi><mn>j</mn></msub></math> that lead to the outputs being as close as possible to the expected values. During the start of training, <math><msub><mi>θ</mi><mn>j</mn></msub></math> is assigned random values.

During each iteration of model training, once the outputs for all samples have been computed, the mean square error (MSE) is used as the <b>loss/cost function</b> <math><mi>J</mi><mi>(</mi><mi>Θ</mi><mi>)</mi></math> to measure the average error between each computed output and its corresponding expected value:

<center><img width="280" src="https://img.ultipa.cn/2022-09-26-14-16-56-Loss.jpg"></center>

> In the standard MSE formula, the denominator is usually <math><mfrac><mi>1</mi><mi>m</mi></mfrac></math>. However, <math><mfrac><mi>1</mi><mrow><mn>2</mn><mi>m</mi></mrow></mfrac></math> is often used instead to offset the squared term when the loss function is derived, leading to the elimination of the constant coefficient for the sake of simplifying subsequent calculations. This modification does not affect the final results.

Subsequently, the gradient descent is employed to update the parameters <math><msub><mi>θ</mi><mi>j</mi></msub></math>. The partial derivative with respect to <math><msub><mi>θ</mi><mi>j</mi></msub></math> is calculated as follows:

<center><img width="480" src="https://img.ultipa.cn/2022-09-26-14-21-41-θj-1.jpg"></center>

Hence, update <math><msub><mi>θ</mi><mi>j</mi></msub></math> as:

<center><img width="320" src="https://img.ultipa.cn/2022-09-26-14-23-56-θj-2.jpg"></center>

The summation from <math><mi>i</mi><mo>=</mo><mn>1</mn></math> to <math><mi>m</mi></math> indicates that all <math><mi>m</mi></math> samples are utilized in each iteration to update the parameters. This approach is known as <b>Batch Gradient Descent</b> (BGD), which is the original and most straightforward form of the Gradient Descent optimization. In BGD, the entire sample dataset is used to compute the gradient of the cost function during each iteration.

While BGD can ensure precise convergence to the minimum of the cost function, it can be computationally intensive for large datasets. As a solution, SGD and MBGD were developed to address efficiency and convergence speed. These variations use subsets of the data in each iteration, making the optimization process faster while still seeking to find the optimal parameters.

### Stochastic Gradient Descent

Stochastic gradient descent (SGD) only selects one sample in random to calculate the gradient for each iteration.

When employing SGD, the above loss function should be expressed as:

<center><img width="250" src="https://img.ultipa.cn/2022-09-26-14-26-08-θj-2=3.jpg"></center>

The partial derivative with respect to <math><msub><mi>θ</mi><mi>j</mi></msub></math> is:

<center><img width="450" src="https://img.ultipa.cn/2022-09-26-14-27-27-θj-4.jpg"></center>

Update <math><msub><mi>θ</mi><mi>j</mi></msub></math> as:

<center><img width="280" src="https://img.ultipa.cn/2022-09-26-14-27-36-θj-5.jpg"></center>

The computational complexity is reduced in SGD since it involves the use of only one sample, thereby bypassing the need for summation and averaging. While this enhances computation speed, it comes at the expense of some degree of accuracy.

### Mini-Batch Gradient Descent

BGD and SGD both represent extremes - one involving all samples and the other only a single sample. Mini-batch Gradient Descent (MBGD) strikes a balance by randomly selecting a subset of <math><mi>x</mi><mo>∈</mo><mi>(</mi><mn>1</mn><mi>,&nbsp;</mi><mi>m</mi><mi>)</mi></math> samples for computation.

## Mathematical Basics

### Derivative

The derivative of a single-variable function <math><mi>f</mi><mi>(</mi><mi>x</mi><mi>)</mi></math> is often denoted as <math><mi>f</mi><mo>&#x2032;</mo><mi>(</mi><mi>x</mi><mi>)</mi></math> or <math><mfrac><mrow><mi>d</mi><mi>f</mi></mrow><mrow><mi>d</mi><mi>x</mi></mrow></mfrac></math>, it represents how <math><mi>f</mi><mi>(</mi><mi>x</mi><mi>)</mi></math> changes with respect to a slight change in <math><mi>x</mi></math> at a given point.

Graphically, <math><mi>f</mi><mo>&#x2032;</mo><mi>(</mi><mi>x</mi><mi>)</mi></math> corresponds to the slope of the tangent line to the function's curve. The derivative at point <math><mi>x</mi></math> is:

<center><img width="320" src="https://img.ultipa.cn/img/2023-08-17-13-31-39-derivative.jpg"></center>

For example, <math><mi>f</mi><mi>(</mi><mi>x</mi><mi>)</mi><mo>=</mo><msup><mi>x</mi><mn>2</mn></msup><mo>+</mo><mn>10</mn></math>, at point <math><mi>x</mi><mo>=</mo><mn>-7</n></math>:

<center><img width="700" src="https://img.ultipa.cn/img/2023-08-17-13-34-49-eg1.jpg"></center>

<center><img width="500" src="https://img.ultipa.cn/img/2023-09-07-11-15-20-fx.jpg"></center>

> The tangent line is a straight line that just touches the function curve at a specific point and shares the same direction as the curve does at that point.

### Partial Derivative

The partial derivative of a multiple-variable function measures how the function changes when one specific variable is varied while keeping all other variables constant. For a function <math><mi>f</mi><mi>(</mi><mi>x</mi><mo>,</mo><mi>y</mi><mi>)</mi></math>, its partial derivative with respect to <math><mi>x</mi></math> at a particular point <math><mi>(</mi><mi>x</mi><mo>,</mo><mi>y</mi><mi>)</mi></math> is denoted as <math><mfrac><mrow><mi>∂</mi><mi>f</mi></mrow><mrow><mi>∂</mi><mi>x</mi></mrow></mfrac></math> or <math><msubsup><mi>f</mi><mi>x</mi><mo>&#x2032;</mo></msubsup></math>:  

<center><img width="400" src="https://img.ultipa.cn/img/2023-08-17-13-44-03-partial-deriative.jpg"></center>

For example, <math><mi>f</mi><mi>(</mi><mi>x</mi><mo>,</mo><mi>y</mi><mi>)</mi><mo>=</mo><msup><mi>x</mi><mn>2</mn></msup><mo>+</mo><msup><mi>y</mi><mn>2</mn></msup></math>, at point <math><mi>x</mi><mo>=</mo><mn>-4</mn></math>, <math><mi>y</mi><mo>=</mo><mn>-6</mn></math>:
  
<center><img width="750" src="https://img.ultipa.cn/img/2023-08-17-13-46-00-eg2.jpg"></center>

<center><img width="700" src="https://img.ultipa.cn/img/2023-08-17-11-05-44-derivative-2.jpg"><span style="color:#999999;"><br><math><mi>L</mi><mn>1</mn></math> shows how the function changes as you move along the Y-axis, while keeping <math><mi>x</mi></math> constant; <math><mi>L</mi><mn>2</mn></math> shows how the function changes as you move along the X-axis, while keeping <math><mi>y</mi></math> constant.</span></center>

### Directional Derivative

<a href="#Partial-Derivative">Partial derivative</a> of a function tells about the output changes when moving slightly in the directions of axes. But when we move in a direction that is not parallel to either of the axes, the concept of directional derivative becomes crucial.

The directional derivative is mathematically expressed as the dot product of the vector <math><mi>∇</mi><mi>f</mi></math> composed of all partial derivatives of the function with the unit vector <math><mover><mi>w</mi><mi>→</mi></mover></math> which indicates the direction of the change:

<center><img width="420" src="https://img.ultipa.cn/img/2023-08-17-16-13-26-directional-derivative.jpg"></center>

where <math><mi>|</mi><mover><mi>w</mi><mi>→</mi></mover><mi>|</mi><mo>=</mo><mn>1</mn></math>, <math><mi>θ</mi></math> is the angle between the two vectors, and 

<center><img width="240" src="https://img.ultipa.cn/img/2023-08-17-16-08-28-gradient.jpg"></center>

### Gradient

The gradient is the direction where the output of a function has the steepest ascent. That is equivalent to finding the maximum <a href="#Directional-Derivative">directional derivative</a>. This occurs when angle <math><mi>θ</mi></math> between the vectors <math><mi>∇</mi><mi>f</mi></math> and <math><mover><mi>w</mi><mi>→</mi></mover></math> is <math><mn>0</mn></math>, as <math><mi>cos</mi><mn>0</mn><mo>=</mo><mn>1</mn></math>, implying that <math><mover><mi>w</mi><mi>→</mi></mover></math> aligns with the direction of <math><mi>∇</mi><mi>f</mi></math>. <math><mi>∇</mi><mi>f</mi></math> is thus called the gradient of a function.

Naturally, the negative gradient points in the direction of the steepest descent.

### Chain Rule

The chain rule describes how to calculate the <a href="#Derivative">derivative</a> of a composite function. In the simpliest form, the derivative of a composite function <math><mi>f</mi><mi>(</mi><mi>g</mi><mi>(</mi><mi>x</mi><mi>)</mi><mi>)</mi></math> can be calculated by multiplying the derivative of <math><mi>f</mi></math> with respect to <math><mi>g</mi></math> by the derivative of <math><mi>g</mi></math> with respect to <math><mi>x</mi></math>:

<center><img width="120" src="https://img.ultipa.cn/img/2023-08-17-14-37-54-chain1.jpg"></center>

For example, <math><mi>s</mi><mi>(</mi><mi>x</mi><mi>)</mi><mo>=</mo><msup><mrow><mi>(</mi><mn>2</mn><mi>x</mi><mo>+</mo><mn>1</mn><mi>)</mi></mrow><mrow><mn>2</mn></mrow></msup></math> is composed of <math><mi>s</mi><mi>(</mi><mi>u</mi><mi>)</mi><mo>=</mo><msup><mi>u</mi><mrow><mn>2</mn></mrow></msup></math> and <math><mi>u</mi><mi>(</mi><mi>x</mi><mi>)</mi><mo>=</mo><mn>2</mn><mi>x</mi><mo>+</mo><mn>1</mn></math>:

<center><img width="320" src="https://img.ultipa.cn/img/2023-08-17-14-26-53-eg3.jpg"></center>

In a multi-variable composite function, the <a href="#Partial-Derivative">partial derivatives</a> are obtained by applying the chain rule to each variable.

For example, <math><mi>s</mi><mi>(</mi><mi>x</mi><mo>,</mo><mi>y</mi><mi>)</mi><mo>=</mo><mi>(</mi><mn>2</mn><mi>x</mi><mo>+</mo><mn>y</mn><mi>)</mi><mi>(</mi><mi>y</mi><mo>-</mo><mn>3</mn><mi>)</mi></math> is composed of <math><mi>s</mi><mi>(</mi><mi>f</mi><mo>,</mo><mi>g</mi><mi>)</mi><mo>=</mo><mi>f</mi><mi>g</mi></math> and <math><mi>f</mi><mi>(</mi><mi>x</mi><mo>,</mo><mi>y</mi><mi>)</mi><mo>=</mo><mn>2</mn><mi>x</mi><mo>+</mo><mn>y</mn></math> and <math><mi>g</mi><mi>(</mi><mi>x</mi><mo>,</mo><mi>y</mi><mi>)</mi><mo>=</mo><mi>y</mi><mo>-</mo><mn>3</mn></math>:

