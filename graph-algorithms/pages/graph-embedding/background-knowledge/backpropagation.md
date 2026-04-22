# Backpropagation

Backpropagation (BP), short for Error Backward Propagation, is a fundamental algorithm used to train neural network models for graph embeddings.

The BP algorithm encompasses two main stages:

- <b>Forward Propagation:</b> Input data is fed into the input layer of the neural network or model. It then moves forward through one or more hidden layers before generating an output at the output layer.
- <b>Backpropagation:</b> The generated output is compared with the actual or expected value. Subsequently, the error is conveyed from the output layer through the hidden layers and back to the input layer. During this process, the weights of the model are adjusted using the <a target="_blank" href="/docs/graph-algorithms/gradient-descent">gradient descent</a> technique.

The iterative adjustment of weights forms the core of the training process of a neural network. We will illustrate this with a concrete example.

## Preparations

### Neural Network

A neural network typically consists of several key components: an <i>input layer</i>, one or more <i>hidden layers</i>, and an <i>output layer</i>. Below is a simple example of a neural network architecture:

<div align="center" drawio-diagram='3220' drawio-name="draw_81e08511959547378d931afff6a9a767.jpg"><img src="https://img.ultipa.cn/draw/draw_81e08511959547378d931afff6a9a767.jpg?v='1664260462545'"/></div>

In this example, <math><mi>x</mi></math> is the input vector with 3 features, and <math><mi>y</mi></math> is the output. The hidden layer contains two <i>neurons</i> <math><msub><mi>h</mi><mn>1</mn></msub></math> and <math><msub><mi>h</mi><mn>2</mn></msub></math>, and the <i>sigmoid</i> activation function is applied at the output layer. 

Furthermore, the connections between layers are characterized by weights: <math><msub><mi>v</mi><mn>11</mn></msub></math> ~ <math><msub><mi>v</mi><mn>32</mn></msub></math> connect the input layer to the hidden layer, while <math><msub><mi>w</mi><mn>1</mn></msub></math> and <math><msub><mi>w</mi><mn>2</mn></msub></math> connect the hidden layer to the output layer. These weights are pivotal in the computations performed within the neural network.

### Activation Function

Activation functions enable neural networks to model non-linear relationships. Without them, the network can only represent linear mappings, which greatly limits its expressiveness. There are various activation functions available, each with its specific role. In this context, the <i>sigmoid</i> function is used, defined by the following formula and illustrated in the graph below:

<center><img width="190" src="https://img.ultipa.cn/img/2023-08-21-13-54-58-sigmoid.jpg"></center>

<center><img width="300" src="https://img.ultipa.cn/2022-09-21-13-43-36-Sigmoid.jpg"></center>

### Initial Weights

The weights are initialized with random values. For illustration, let's assume the following initial weights:

<div align="center" drawio-diagram='3221' drawio-name="draw_72b30356a2d74577ba9bfa6a81947b83.jpg"><img src="https://img.ultipa.cn/draw/draw_72b30356a2d74577ba9bfa6a81947b83.jpg?v='1664247624446'"/></div>

### Training Samples

Let's consider three sets of training samples, as shown below. The superscript indicates the order of the sample in the sequence:

- Inputs: <math><msup><mi>x</mi><mrow><mi>(</mi><mn>1</mn><mi>)</mi></mrow></msup><mo>=</mo><mi>(</mi><mn>2</mn><mi>,&nbsp;</mi><mn>3</mn><mi>,&nbsp;</mi><mn>1</mn><mi>)</mi></math>, <math><msup><mi>x</mi><mrow><mi>(</mi><mn>2</mn><mi>)</mi></mrow></msup><mo>=</mo><mi>(</mi><mn>1</mn><mi>,&nbsp;</mi><mn>0</mn><mi>,&nbsp;</mi><mn>2</mn><mi>)</mi></math>, <math><msup><mi>x</mi><mrow><mi>(</mi><mn>3</mn><mi>)</mi></mrow></msup><mo>=</mo><mi>(</mi><mn>3</mn><mi>,&nbsp;</mi><mn>1</mn><mi>,&nbsp;</mi><mn>1</mn><mi>)</mi></math>
- Outputs: <math><msup><mi>t</mi><mrow><mi>(</mi><mn>1</mn><mi>)</mi></mrow></msup><mo>=</mo><mn>0.64</mn></math>, <math><msup><mi>t</mi><mrow><mi>(</mi><mn>2</mn><mi>)</mi></mrow></msup><mo>=</mo><mn>0.52</mn></math>, <math><msup><mi>t</mi><mrow><mi>(</mi><mn>3</mn><mi>)</mi></mrow></msup><mo>=</mo><mn>0.36</mn></math>

The primary goal of the training process is to adjust the model's parameters (weights) so that the predicted/computed output (<math><mi>y</mi></math>) closely matches the actual output (<math><mi>t</mi></math>) when the input (<math><mi>x</mi></math>) is provided.

## Forward Propagation

### Input Layer → Hidden Layer

Neurons <math><msub><mi>h</mi><mn>1</mn></msub></math> and <math><msub><mi>h</mi><mn>2</mn></msub></math> are calculated by:

<center><img width="250" src="https://img.ultipa.cn/2022-09-28-09-33-32-h1-h2.jpg"></center>

### Hidden Layer → Output Layer

The output <math><mi>y</mi></math> is calculated by:

<center><img width="250" src="https://img.ultipa.cn/2022-09-28-09-33-41-s-y.jpg"></center>

Below is the calculation of the 3 samples:

| <div table-width="25"><math><mi>x</mi></math></div> | <math><msub><mi>h</mi><mn>1</mn></msub></math> | <math><msub><mi>h</mi><mn>2</mn></msub></math> | <math><mi>s</mi></math> | <math><mi>y</mi></math> | <math><mi>t</mi></math> |
| --- | --- | --- | --- | --- | --- | 
| <math><msup><mi>x</mi><mrow><mi>(</mi><mn>1</mn><mi>)</mi></mrow></msup><mo>=</mo><mi>(</mi><mn>2</mn><mi>,&nbsp;</mi><mn>3</mn><mi>,&nbsp;</mi><mn>1</mn><mi>)</mi></math> | 2.4 | 1.8 | 2.28 | 0.907 | 0.64 |
| <math><msup><mi>x</mi><mrow><mi>(</mi><mn>2</mn><mi>)</mi></mrow></msup><mo>=</mo><mi>(</mi><mn>1</mn><mi>,&nbsp;</mi><mn>0</mn><mi>,&nbsp;</mi><mn>2</mn><mi>)</mi></math> | 0.75 | 1.2 | 0.84 | 0.698 | 0.52 |
| <math><msup><mi>x</mi><mrow><mi>(</mi><mn>3</mn><mi>)</mi></mrow></msup><mo>=</mo><mi>(</mi><mn>3</mn><mi>,&nbsp;</mi><mn>1</mn><mi>,&nbsp;</mi><mn>1</mn><mi>)</mi></math> | 1.35 | 1.4 | 1.36 | 0.796 | 0.36 |

Apparently, the three computed outputs (<math><mi>y</mi></math>) are very different from the expected (<math><mi>t</mi></math>).

## Backpropagation

### Loss Function

A loss function is used to quantify the error or discrepancy between the model's predicted outputs and the expected outputs. It is also commonly referred to as the objective function or cost function. In this case, we'll use the mean squared error (MSE) as the loss function <math><mi>E</mi></math>:

<center><img width="200" src="https://img.ultipa.cn/2022-09-27-14-51-29-MSE.jpg"></center>

where <math><mi>m</mi></math> is the number of samples. Calculate the error of this round of forward propagation as:

<math style="font-size: 20px;">
  <mfrac>
    <mrow>
      <msup><mrow><mi>(</mi><mn>0.64</mn><mo>-</mo><mn>0.907</mn><mi>)</mi></mrow><mn>2</mn></msup>
      <mo>+</mo>
      <msup><mrow><mi>(</mi><mn>0.52</mn><mo>-</mo><mn>0.698</mn><mi>)</mi></mrow><mn>2</mn></msup>
      <mo>+</mo>
      <msup><mrow><mi>(</mi><mn>0.36</mn><mo>-</mo><mn>0.796</mn><mi>)</mi></mrow><mn>2</mn></msup>
  	</mrow>
    <mrow>
      <mn>2</mn><mo>×</mo><mn>3</mn>
  	</mrow>
  </mfrac>
  <mo>=</mo><mn>0.234</mn>
</math><br><br>

A smaller value of the loss function corresponds to higher model accuracy. The fundamental goal of model training is to minimize the value as much as possible.

By treating the inputs and outputs as constants and the weights as variables within the loss function, the goal becomes finding the weights that minimize the loss. This is precisely where the <a target="_blank" href="/docs/graph-algorithms/gradient-descent">gradient descent</a> technique comes into play.

In this example, batch gradient descent (BGD) is used, meaning all training samples are involved in the gradient calculation. The learning rate is set to <math><mi>η</mi><mo>=</mo><mn>0.5</mn></math>.

### Output Layer → Hidden Layer

Adjust the weights <math><msub><mi>w</mi><mn>1</mn></msub></math> and <math><msub><mi>w</mi><mn>2</mn></msub></math> respectively.

Calculate the partial derivative of <math><mi>E</mi></math> with respect to <math><msub><mi>w</mi><mn>1</mn></msub></math> with the <a target="_blank" href="/docs/graph-algorithms/gradient-descent#Chain-Rule">chain rule</a>:

<center><img width="180" src="https://img.ultipa.cn/2022-09-27-15-21-41-back1.jpg"></center>

where,

<center><img width="480" src="https://img.ultipa.cn/img/2023-08-21-15-46-09-w1.jpg"></center>

Calculate with values: <br><br>

<math>
  <mfrac>
    <mrow><mi>∂</mi><mi>E</mi></mrow>
    <mrow><mi>∂</mi><mi>y</mi></mrow>
  </mfrac>
  <mo>=</mo>
  <mfrac>
    <mrow>
      <mi>(</mi><mn>0.907</mn><mo>-</mo><mn>0.64</mn><mi>)</mi>
      <mo>+</mo>
      <mi>(</mi><mn>0.698</mn><mo>-</mo><mn>0.52</mn><mi>)</mi>
      <mo>+</mo>
      <mi>(</mi><mn>0.796</mn><mo>-</mo><mn>0.36</mn><mi>)</mi>
    </mrow>
    <mn>3</mn>
  </mfrac>
  <mo>=</mo>
  <mn>0.294</mn>
</math><br><br>

<math>
  <mfrac>
    <mrow><mi>∂</mi><mi>y</mi></mrow>
    <mrow><mi>∂</mi><mi>s</mi></mrow>
  </mfrac>
  <mo>=</mo>
  <mfrac>
    <mrow>
      <mn>0.907</mn><mi>×</mi><mi>(</mi><mn>1</mn><mo>-</mo><mn>0.907</mn><mi>)</mi>
      <mo>+</mo>
      <mn>0.698</mn><mi>×</mi><mi>(</mi><mn>1</mn><mo>-</mo><mn>0.698</mn><mi>)</mi>
      <mo>+</mo>
      <mn>0.796</mn><mi>×</mi><mi>(</mi><mn>1</mn><mo>-</mo><mn>0.796</mn><mi>)</mi>
    </mrow>
    <mn>3</mn>
  </mfrac>
  <mo>=</mo>
  <mn>0.152</mn>
</math><br><br>

<math>
  <mfrac>
    <mrow><mi>∂</mi><mi>s</mi></mrow>
    <mrow><mi>∂</mi><msub><mi>w</mi><mn>1</mn></msub></mrow>
  </mfrac>
  <mo>=</mo>
  <mfrac>
    <mrow>
      <mn>2.4</mn>
      <mo>+</mo>
      <mn>0.75</mn>
      <mo>+</mo>
      <mn>1.35</mn>
    </mrow>
    <mn>3</mn>
  </mfrac>
  <mo>=</mo>
  <mn>1.5</mn>
</math><br><br>

Then, 
<math>
  <mfrac>
    <mrow><mi>∂</mi><mi>E</mi></mrow>
    <mrow><mi>∂</mi><msub><mi>w</mi><mn>1</mn></msub></mrow>
  </mfrac>
  <mo>=</mo>
  <mn>0.294</mn>
  <mo>×</mo>
  <mn>0.152</mn>
  <mo>×</mo>
  <mn>1.5</mn>
  <mo>=</mo>
  <mn>0.067</mn>
</math><br><br>

> Since all samples are involved in computing the partial derivative, we calculate <math><mfrac><mrow><mi>∂</mi><mi>y</mi></mrow><mrow><mi>∂</mi><mi>s</mi></mrow></mfrac></math> and <math><mfrac><mrow><mi>∂</mi><mi>s</mi></mrow><mrow><mi>∂</mi><msub><mi>w</mi><mn>1</mn></msub></mrow></mfrac></math> by summing the derivatives across all samples and then taking the average.
  
Therefore, <math><msub><mi>w</mi><mn>1</mn></msub></math> is updated to 
<math>
  <msub><mi>w</mi><mn>1</mn></msub>
  <mo>=</mo>
  <msub><mi>w</mi><mn>1</mn></msub>
  <mo>-</mo>
  <mi>η</mi>
  <mfrac>
    <mrow><mi>∂</mi><mi>E</mi></mrow>
    <mrow><mi>∂</mi><msub><mi>w</mi><mn>1</mn></msub></mrow>
  </mfrac>
  <mo>=</mo>
  <mn>0.8</mn>
  <mo>-</mo>
  <mn>0.5</mn>
  <mo>×</mo>
  <mn>0.067</mn>
  <mo>=</mo>
  <mn>0.766</mn>
</math>.

The weight <math><msub><mi>w</mi><mn>2</mn></msub></math> can be updated in a similar way by calculating the partial derivative of <math><mi>E</mi></math> with respect to <math><msub><mi>w</mi><mn>2</mn></msub></math>. In this round, <math><msub><mi>w</mi><mn>2</mn></msub></math> is updated from <math><mn>0.2</mn></math> to <math><mn>0.167</mn></math>.

### Hidden Layer → Input Layer 

Adjust the weights <math><msub><mi>v</mi><mn>11</mn></msub></math> ~ <math><msub><mi>v</mi><mn>32</mn></msub></math> respectively.

Calculate the partial derivative of <math><mi>E</mi></math> with respect to <math><msub><mi>v</mi><mn>11</mn></msub></math> with the <a target="_blank" href="/docs/graph-algorithms/gradient-descent#Chain-Rule">chain rule</a>:

<center><img width="230" src="https://img.ultipa.cn/2022-09-27-15-55-13-back3.jpg"></center>

We already computed <math><mfrac><mrow><mi>∂</mi><mi>E</mi></mrow><mrow><mi>∂</mi><mi>y</mi></mrow></mfrac></math> and <math><mfrac><mrow><mi>∂</mi><mi>y</mi></mrow><mrow><mi>∂</mi><mi>s</mi></mrow></mfrac></math>, below are the latter two:

<center><img width="360" src="https://img.ultipa.cn/2022-09-27-15-58-11-back4.jpg"></center>

Calculate with values: <br></br>

<math>
  <mfrac>
    <mrow><mi>∂</mi><mi>E</mi></mrow>
    <mrow><mi>∂</mi><mi>y</mi></mrow>
  </mfrac>
  <mo>=</mo>
  <mn>0.294</mn>
</math><br><br>

<math>
  <mfrac>
    <mrow><mi>∂</mi><mi>y</mi></mrow>
    <mrow><mi>∂</mi><mi>s</mi></mrow>
  </mfrac>
  <mo>=</mo>
  <mn>0.152</mn>
</math><br><br>

<math>
  <mfrac>
    <mrow><mi>∂</mi><mi>s</mi></mrow>
    <mrow><mi>∂</mi><msub><mi>h</mi><mn>1</mn></msub></mrow>
  </mfrac>
  <mo>=</mo>
  <mn>0.8</mn>
</math><br><br>

<math>
  <mfrac>
    <mrow><mi>∂</mi><msub><mi>h</mi><mn>1</mn></msub></mrow>
    <mrow><mi>∂</mi><msub><mi>v</mi><mn>11</mn></msub></mrow>
  </mfrac>
  <mo>=</mo>
  <mfrac>
    <mrow>
      <mn>2</mn>
      <mo>+</mo>
      <mn>1</mn>
      <mo>+</mo>
      <mn>3</mn>
    </mrow>
    <mn>3</mn>
  </mfrac>
  <mo>=</mo>
  <mn>2</mn>
</math><br><br>

Then, 
<math>
  <mfrac>
    <mrow><mi>∂</mi><mi>E</mi></mrow>
    <mrow><mi>∂</mi><msub><mi>v</mi><mn>11</mn></msub></mrow>
  </mfrac>
  <mo>=</mo>
  <mn>0.294</mn>
  <mo>×</mo>
  <mn>0.152</mn>
  <mo>×</mo>
  <mn>0.8</mn>
  <mo>×</mo>
  <mn>2</mn>
  <mo>=</mo>
  <mn>0.072</mn>
</math>.

Therefore, <math><msub><mi>v</mi><mn>11</mn></msub></math> is updated to 
<math>
  <msub><mi>v</mi><mn>11</mn></msub>
  <mo>=</mo>
  <msub><mi>v</mi><mn>11</mn></msub>
  <mo>-</mo>
  <mi>η</mi>
  <mfrac>
    <mrow><mi>∂</mi><mi>E</mi></mrow>
    <mrow><mi>∂</mi><msub><mi>v</mi><mn>11</mn></msub></mrow>
  </mfrac>
  <mo>=</mo>
  <mn>0.15</mn>
  <mo>-</mo>
  <mn>0.5</mn>
  <mo>×</mo>
  <mn>0.072</mn>
  <mo>=</mo>
  <mn>0.114</mn>
</math>.

The remaining weights can be updated in a similar way by calculating the partial derivative of <math><mi>E</mi></math> with respect to each weight. In this round, their values are updated as follows:

- <math><msub><mi>v</mi><mn>12</mn></msub></math> is updated from <math><mn>0.2</mn></math> to <math><mn>0.191</mn></math>
- <math><msub><mi>v</mi><mn>21</mn></msub></math> is updated from <math><mn>0.6</mn></math> to <math><mn>0.576</mn></math>
- <math><msub><mi>v</mi><mn>22</mn></msub></math> is updated from <math><mn>0.3</mn></math> to <math><mn>0.294</mn></math>
- <math><msub><mi>v</mi><mn>31</mn></msub></math> is updated from <math><mn>0.3</mn></math> to <math><mn>0.282</mn></math>
- <math><msub><mi>v</mi><mn>32</mn></msub></math> is updated from <math><mn>0.5</mn></math> to <math><mn>0.496</mn></math>

## Training Iterations

Apply the updated weights to the model and perform forward propagation again using the same three samples. In this iteration, the resulting error <math><mi>E</mi></math> decreases to <math><mn>0.192</mn></math>.

The backpropagation algorithm continues this cycle of forward and backward propagation iteratively to train the model. This process repeats until one of the following conditions is met: a predefined number of training iterations is completed, a time limit is reached, or the error falls below a specific threshold.
