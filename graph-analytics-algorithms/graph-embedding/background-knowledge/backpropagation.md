# Backpropagation

Backpropagation (or BP), stands for Error Backward Propagation, constitutes a core technique used in training models for graph embeddings.

The BP algorithm encompasses two main stages:

- <b>Forward Propagation:</b> Input data is fed into the input layer of a neural network or model. It then passes through one or multiple hidden layers before generating output from the output layer.
- <b>Backpropagation:</b> The generated output is compared with the actual or expected value. Subsequently, the error is conveyed from the output layer through the hidden layers and back to the input layer. During this process, the weights of the model are adjusted using the <a href="/docs/graph-analytics-algorithms/gradient-descent">gradient descent</a> technique.

The iterative weight adjustments constitute the training process of the neural network. We will further explain with a concrete example.

## Preparations

### Neural Network

Neural networks are typically composed of several essential components: an <i>input layer</i>, one or multiple <i>hidden layers</i>, and an <i>output layer</i>. Here, we present a simple example of a neural network architecture:

<div align="center" drawio-diagram='3220' drawio-name="draw_81e08511959547378d931afff6a9a767.jpg"><img src="https://img.ultipa.cn/draw/draw_81e08511959547378d931afff6a9a767.jpg?v='1664260462545'"/></div>

In this illustration, <math><mi>x</mi></math> is the input vector containing 3 features, <math><mi>y</mi></math> is the output. We have two <i>neurons</i> <math><msub><mi>h</mi><mn>1</mn></msub></math> and <math><msub><mi>h</mi><mn>2</mn></msub></math> in the hidden layer. The <i>sigmoid</i> activation function is applied in the output layer. 

Furthermore, the connections between layers are characterized by the weights: <math><msub><mi>v</mi><mn>11</mn></msub></math> ~ <math><msub><mi>v</mi><mn>32</mn></msub></math> are weights between the input layer and hidden layer, <math><msub><mi>w</mi><mn>1</mn></msub></math> and <math><msub><mi>w</mi><mn>2</mn></msub></math> are weights between the hidden layer and output layer. These weights are pivotal in the computations performed within the neural network.

### Activation Function

Activation functions empowers the neural network to conduct non-linear modeling. Without activation functions, the model can only express linear mappings, limiting their capability. A diverse range of activation functions exists, each serving a unique purpose. The <i>sigmoid</i> function used in this context is depicted by the following formula and graph:

<center><img width="190" src="https://img.ultipa.cn/img/2023-08-21-13-54-58-sigmoid.jpg"></center>

<center><img width="300" src="https://img.ultipa.cn/2022-09-21-13-43-36-Sigmoid.jpg"></center>

### Initial Weights

The weights are initialized with random values. Let's assume the initial weights are as follows:

<div align="center" drawio-diagram='3221' drawio-name="draw_72b30356a2d74577ba9bfa6a81947b83.jpg"><img src="https://img.ultipa.cn/draw/draw_72b30356a2d74577ba9bfa6a81947b83.jpg?v='1664247624446'"/></div>

### Training Samples

Let's consider three sets of training samples as outlined below, where the superscript indicates the order of the sample:

- Inputs: <math><msup><mi>x</mi><mrow><mi>(</mi><mn>1</mn><mi>)</mi></mrow></msup><mo>=</mo><mi>(</mi><mn>2</mn><mi>,&nbsp;</mi><mn>3</mn><mi>,&nbsp;</mi><mn>1</mn><mi>)</mi></math>, <math><msup><mi>x</mi><mrow><mi>(</mi><mn>2</mn><mi>)</mi></mrow></msup><mo>=</mo><mi>(</mi><mn>1</mn><mi>,&nbsp;</mi><mn>0</mn><mi>,&nbsp;</mi><mn>2</mn><mi>)</mi></math>, <math><msup><mi>x</mi><mrow><mi>(</mi><mn>3</mn><mi>)</mi></mrow></msup><mo>=</mo><mi>(</mi><mn>3</mn><mi>,&nbsp;</mi><mn>1</mn><mi>,&nbsp;</mi><mn>1</mn><mi>)</mi></math>
- Outputs: <math><msup><mi>t</mi><mrow><mi>(</mi><mn>1</mn><mi>)</mi></mrow></msup><mo>=</mo><mn>0.64</mn></math>, <math><msup><mi>t</mi><mrow><mi>(</mi><mn>2</mn><mi>)</mi></mrow></msup><mo>=</mo><mn>0.52</mn></math>, <math><msup><mi>t</mi><mrow><mi>(</mi><mn>3</mn><mi>)</mi></mrow></msup><mo>=</mo><mn>0.36</mn></math>

The primary objective of the training process is to adjust the model's parameters (weights) so that the predicted/computed output (<math><mi>y</mi></math>) closely aligns with the actual output (<math><mi>t</mi></math>) when the input (<math><mi>x</mi></math>) is provided.

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

A loss function is used to quantify the error or disparity between the model's outputs and the expected outputs. It is also referred to as the objective function or cost function. Let's use the mean square error (MSE) as the loss function <math><mi>E</mi></math> here:

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

A smaller value of the loss function corresponds to higher model accuracy. The fundamental goal of model training is to minimize the value of the loss function to the greatest extent possible.

Consider the input and output as constants, while regarding the weights as variables within the loss function. Then the objective is to adjust the weights that result in the lowest value of the loss function - this is where the <a href="/docs/graph-analytics-algorithms/gradient-descent">gradient descent</a> technique comes to play.

In this example, the batch gradient descent (BGD) is used, i.e., all samples are involved in the calculation of the gradient. Set the learning rate <math><mi>η</mi><mo>=</mo><mn>0.5</mn></math>.

### Output Layer → Hidden Layer

Adjust the weights <math><msub><mi>w</mi><mn>1</mn></msub></math> and <math><msub><mi>w</mi><mn>2</mn></msub></math> respectively.

Calculate the partial derivative of <math><mi>E</mi></math> with respect to <math><msub><mi>w</mi><mn>1</mn></msub></math> with the <a href="/docs/graph-analytics-algorithms/gradient-descent#Chain-Rule">chain rule</a>:

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

> Since all samples are involved in computing the partial derivative, when calculating <math><mfrac><mrow><mi>∂</mi><mi>y</mi></mrow><mrow><mi>∂</mi><mi>s</mi></mrow></mfrac></math> and <math><mfrac><mrow><mi>∂</mi><mi>s</mi></mrow><mrow><mi>∂</mi><msub><mi>w</mi><mn>1</mn></msub></mrow></mfrac></math>, we take the sum of these derivatives across all samples and then obtain the average.
  
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

The weight <math><msub><mi>w</mi><mn>2</mn></msub></math> can be adjusted in a similar way by calculating the partial derivative of <math><mi>E</mi></math> with respect to <math><msub><mi>w</mi><mn>2</mn></msub></math>. In this round, <math><msub><mi>w</mi><mn>2</mn></msub></math> is updated from <math><mn>0.2</mn></math> to <math><mn>0.167</mn></math>.

### Hidden Layer → Input Layer 

Adjust the weights <math><msub><mi>v</mi><mn>11</mn></msub></math> ~ <math><msub><mi>v</mi><mn>32</mn></msub></math> respectively.

Calculate the partial derivative of <math><mi>E</mi></math> with respect to <math><msub><mi>v</mi><mn>11</mn></msub></math> with the <a href="/docs/graph-analytics-algorithms/gradient-descent#Chain-Rule">chain rule</a>:

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

The remaining weights can be adjusted in a similar way by calculating the partial derivative of <math><mi>E</mi></math> with respect to each of them. In this round, they are updated as follows:

- <math><msub><mi>v</mi><mn>12</mn></msub></math> is updated from <math><mn>0.2</mn></math> to <math><mn>0.191</mn></math>
- <math><msub><mi>v</mi><mn>21</mn></msub></math> is updated from <math><mn>0.6</mn></math> to <math><mn>0.576</mn></math>
- <math><msub><mi>v</mi><mn>22</mn></msub></math> is updated from <math><mn>0.3</mn></math> to <math><mn>0.294</mn></math>
- <math><msub><mi>v</mi><mn>31</mn></msub></math> is updated from <math><mn>0.3</mn></math> to <math><mn>0.282</mn></math>
- <math><msub><mi>v</mi><mn>32</mn></msub></math> is updated from <math><mn>0.5</mn></math> to <math><mn>0.496</mn></math>

## Training Iterations

Apply the adjusted weights into the model and proceed with forward propagation using the same three samples. In this iteration, the resulting error <math><mi>E</mi></math> is reduced to <math><mn>0.192</mn></math>.

The Backpropagation algorithm iteratively performs the forward and back-propagation steps to train the model. This process continues until either the designated training count or time limit is reached, or when the error decreases to a predefined threshold.