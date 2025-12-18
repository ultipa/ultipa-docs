# Skip-gram Optimization

## Overview

The <a target="_blank" href="/docs/graph-analytics-algorithms/skip-gram">basic Skip-gram model</a> is nearly impractical for real-world use due to its high computational demands. 

The sizes of the matrices <math><mi>W</mi></math> and <math><mi>W</mi><mo>&#x2032;</mo></math> depend on the vocabulary size (e.g., <math><mi>V</mi><mo>=</mo><mn>10000</mn></math>) and the embedding dimension (e.g., <math><mi>N</mi><mo>=</mo><mn>300</mn></math>). As a result, each matrix can contain millions of weights (e.g., <math><mi>V</mi><mo>⋅</mo><mi>N</mi><mo>=</mo><mn>3</mn></math> million), making the Skip-gram neural network substantially large. Training such a model effectively requires a massive number of samples to tune all the weights.

Additionaly, during each backpropagation step, updates are applied to all output vectors (<math><msubsup><mi>v</mi><mi>w</mi><mo>&#x2032;</mo></msubsup></math>) in matrix <math><mi>W</mi><mo>&#x2032;</mo></math>, even though most of these vectors are unrelated to the current target or context words. Given the large size of <math><mi>W</mi><mo>&#x2032;</mo></math>, this makes gradient descent highly inefficient and computationally slow.

Another significant computational cost comes from the <i>Softmax</i> function, which involves all words in the vocabulary to compute the normalization denominator.

<center><img width="190" src="https://img.ultipa.cn/img/2023-08-22-15-12-04-softmax.jpg"></center>

T. Mikoliv and colleagues introduced optimization techniques for the Skip-gram model, including <b>subsampling</b> and <b>negative sampling</b>. These approaches help accelerate training and improve the quality of the resulting embedding vectors. 

- T. Mikolov, I. Sutskever, K. Chen, G. Corrado, J. Dean, <a target="_blank" href="https://arxiv.org/pdf/1310.4546.pdf">Distributed Representations of Words and Phrases
and their Compositionality</a> (2013)
- X. Rong, <a target="_blank" href="https://arxiv.org/pdf/1411.2738.pdf">word2vec Parameter Learning Explained</a> (2016)

## Subsampling

Common words in the corpus, such as "the", "and", and "is", raise certain concerns:

- They have limited semantic value. For example, the model benefits more from the co-occurrence of "France" and "Paris" than from the frequent pairing of "France" and "the".
- These words show up in more training samples than needed, making it inefficient to train their vectors.

Subsampling is used to address this issue by randomly discarding words during training. Frequent words are more likely to be discarded, while rare words are kept more often.

First, calculate the probability of keeping a word by:

<center><img width="240" src="https://img.ultipa.cn/img/2023-08-29-14-10-47-sub-sample.jpg"></center>

where <math><mi>f</mi><mi>(</mi><msub><mi>w</mi><mi>i</mi></msub><mi>)</mi></math> is the frequency of the <math><mi>i</mi></math>-th word, <math><mi>α</mi></math> is a factor that influences the distribution and is default to <math><mn>0.001</mn></math>.

Then, a random number between <math><mn>0</mn></math> and <math><mn>1</mn></math> is generated. If <math><mi>P</mi><mi>(</mi><msub><mi>w</mi><mi>i</mi></msub><mi>)</mi></math> is smaller than this number, the word is discarded.

For instance, when <math><mi>α</mi><mo>=</mo><mn>0.001</mn></math>, then for <math><mi>f</mi><mi>(</mi><msub><mi>w</mi><mi>i</mi></msub><mi>)</mi><mo>≤</mo><mn>0.0026</mn></math>, <math><mi>P</mi><mi>(</mi><msub><mi>w</mi><mi>i</mi></msub><mi>)</mi><mo>≥</mo><mn>1</mn></math>, so words with frequency <math><mn>0.0026</mn></math> or less will 100% be kept. For a high word frequency like <math><mi>f</mi><mi>(</mi><msub><mi>w</mi><mi>i</mi></msub><mi>)</mi><mo>=</mo><mn>0.03</mn></math>, <math><mi>P</mi><mi>(</mi><msub><mi>w</mi><mi>i</mi></msub><mi>)</mi><mo>=</mo><mn>0.22</mn></math>.
  
In the case when <math><mi>α</mi><mo>=</mo><mn>0.002</mn></math>, then words with frequency <math><mn>0.0052</mn></math> or less will 100% be kept. For the same high word frequency <math><mi>f</mi><mi>(</mi><msub><mi>w</mi><mi>i</mi></msub><mi>)</mi><mo>=</mo><mn>0.03</mn></math>, <math><mi>P</mi><mi>(</mi><msub><mi>w</mi><mi>i</mi></msub><mi>)</mi><mo>=</mo><mn>0.32</mn></math>.

Thus, a higher value of <math><mi>α</mi></math> increases the probability that frequent nodes are down-sampled.

For example, if the word 'a' is discarded from the sentence 'Graph is a good way to visualize data,' then no training samples will include 'a' as either the target or a context word.

## Negative Sampling

In the negative sampling approach, when a <i>positive</i> context word is sampled for a target word, a total of <math><mi>k</mi></math> words are simultaneously chosen as <i>negative</i> samples. 

For instance, let's consider the simple corpus when discussing the basic Skip-gram model. This corpus comprises a vocabulary of 10 words: <i>graph</i>, <i>is</i>, <i>a</i>, <i>good</i>, <i>way</i>, <i>to</i>, <i>visualize</i>, <i>data</i>, <i>very</i>, <i>at</i>. When the positive sample <i>(target, content): (is, a)</i> is generated using a sliding window, we select <math><mi>k</mi><mo>=</mo><mn>3</mn></math> negative words <i>graph</i>, <i>data</i> and <i>at</i> to accompany it:

<table>
  <thead>
    <th>Target Word</th>
  	<th></th>
  	<th>Context Word</th>
  	<th>Expected Output</th>
  </thead>
  <tbody>
    <tr>
      <td rowspan="4"><i>is</i></td>
      <td>Positive Sample</td>
      <td><i>a</i></td>
      <td>1</td>
    </tr>
    <tr>
      <td rowspan="3">Negative Samples</td>
      <td><i>graph</i></td>
      <td>0</td>
    </tr>
    <tr>
      <td><i>data</i></td>
      <td>0</td>
    </tr>
    <tr>
      <td><i>at</i></td>
      <td>0</td>
    </tr>
  </tbody>
</table>

With negative sampling, the training objective of the model shifts from predicting context words for the target word to a binary classification task. In this setup, the output for the positive word is expected as <math><mn>1</mn></math>, while the outputs for the negative words are expected as <math><mn>0</mn></math>; other words that do not fall into either category are disregarded.

Consequently, during the backpropagation process, the model only updates the output vectors <math><msubsup><mi>v</mi><mi>w</mi><mo>′</mo></msubsup></math> associated with the positive and negative words to improve the model's classification performance.

Consider the scenario where <math><mi>V</mi><mo>=</mo><mn>10000</mn></math> and <math><mi>N</mi><mo>=</mo><mn>300</mn></math>. When applying negative sampling with the parameter <math><mi>k</mi><mo>=</mo><mn>9</mn></math>, only <math><mn>300</mn><mo>×</mo><mn>10</mn><mo>=</mo><mn>3000</mn></math> individual weights in <math><mi>W</mi><mo>&#x2032;</mo></math> will require updates, which is <math><mn>0.1%</mn></math> of the <math><mn>3</mn></math> million weights to be updated without negative sampling!

> Our experiments indicate that values of <math><mi>k</mi></math> in the range <math><mn>5</mn><mi>~</mi><mn>20</mn></math> are useful for small training datasets, while for large datasets the <math><mi>k</mi></math> can be as small as <math><mn>2</mn><mi>~</mi><mn>5</mn></math>. (<a target="_blank" href="https://arxiv.org/pdf/1310.4546.pdf">Mikolov et al.</a>)

To select negative samples, a probability distribution <math><msub><mi>P</mi><mi>n</mi></msub></math> is required. The fundamental principle is to prioritize frequent words in the corpus. However, using raw frequency can result in an overrepresentation of very common words, while underrepresenting less frequent ones. To address this, an empirical distribution is often used that involves raising the word frequency  to the power of <math><mfrac><mn>3</mn><mn>4</mn></mfrac></math>:

<center><img width="230" src="https://img.ultipa.cn/2022-10-11-14-15-14-Pn.jpg"></center>

where <math><mi>f</mi><mi>(</mi><msub><mi>w</mi><mi>i</mi></msub><mi>)</mi></math> is the frequency of the <math><mi>i</mi></math>-th word, the subscript <math><mi>n</mi></math> of <math><mi>P</mi></math> indicates the concept of <i>noise</i>, the distribution <math><msub><mi>P</mi><mi>n</mi></msub></math> is also called the <i>noise distribution</i>.

In extreme cases, consider a corpus containing only two words, with frequencies of <math><mn>0.9</mn></math> and <math><mn>0.1</mn></math> respectively. Applying the above formula results in adjusted probabilities of <math><mn>0.84</mn></math> and <math><mn>0.16</mn></math>. This adjustment helps reduce the bias caused by large frequency disparities.

However, when working with large corpora, negative sampling can still be computationally intensive. To address this, a `resolution` is introduced to rescale the noise distribution. A higher `resolution` value enables the resampled distribution to better approximate the original noise distribution, striking a balance between efficiency and accuracy.

## Optimized Model Training

### Forward Propagation 

We will demonstrate with target word <i>is</i>, positive word <i>a</i>, and negative words <i>graph</i>, <i>data</i> and <i>at</i>:

<center><img width="1000" src="https://img.ultipa.cn/img/2023-08-23-17-36-49-train.jpg"></center>

With negative sampling, the Skip-gram model uses the following variation of the <i>Softmax</i> function, which is actually the <i>Sigmoid</i> function (<math><mi>σ</mi></math>) of <math><msub><mi>u</mi><mi>j</mi></msub></math>. This function maps all components of <math><mi>u</mi></math> within the range of <math><mn>0</mn></math> and <math><mn>1</mn></math>:

<center><img width="200" src="https://img.ultipa.cn/img/2023-08-23-16-25-07-softmax.jpg"></center>

### Backpropagation

As explained, the output for the positive word, denoted as <math><msub><mi>y</mi><mn>0</mn></msub></math>, is expected to be <math><mn>1</mn></math>; while the <math><mi>k</mi></math> outputs corresponding to the negative words, denoted as <math><msub><mi>y</mi><mi>i</mi></msub></math>, are expected to be <math><mn>0</mn></math>. Therefore, the objective of the model's training is to maximize both <math><msub><mi>y</mi><mn>0</mn></msub></math> and <math><mn>1</mn><mo>-</mo><msub><mi>y</mi><mi>i</mi></msub></math>, which can be equivalently interpreted as maximizing their product:

<center><img width="500" src="https://img.ultipa.cn/img/2023-08-23-16-53-57-max.jpg"></center>

The loss funtion <math><mi>E</mi></math> is then obtained by transforming the above as a minimization problem:

<center><img width="420" src="https://img.ultipa.cn/img/2023-08-23-16-56-31-E.jpg"></center>

Take the partial derivative of <math><mi>E</mi></math> with respect to <math><msub><mi>u</mi><mn>0</mn></msub></math> and <math><msub><mi>u</mi><mi>i</mi></msub></math>:

<center><img width="580" src="https://img.ultipa.cn/img/2023-08-23-17-25-52-pd.jpg"></center>

<math><mfrac><mrow><mi>∂</mi><mi>E</mi></mrow><mrow><mi>∂</mi><msub><mi>u</mi><mn>0</mn></msub></mrow></mfrac></math> and <math><mfrac><mrow><mi>∂</mi><mi>E</mi></mrow><mrow><mi>∂</mi><msub><mi>u</mi><mi>i</mi></msub></mrow></mfrac></math> hold a similar meaning to <math><mfrac><mrow><mi>∂</mi><mi>E</mi></mrow><mrow><mi>∂</mi><msub><mi>u</mi><mi>j</mi></msub></mrow></mfrac></math> in the original Skip-gram model, which can be understood as subtracting the expected vector from the output vector:

<center><img width="250" src="https://img.ultipa.cn/img/2023-08-23-17-43-12-e.jpg"></center>

The process of updating weights in matrices <math><mi>W</mi><mo>&#x2032;</mo></math> and <math><mi>W</mi></math> is straightforward. You may refer to the <a target="_blank" href="/doc/graph-analytics-algorithms/skip-gram">original form</a> of Skip-gram. However, only weights <math><msubsup><mi>w</mi><mn>11</mn><mo>&#x2032;</mo></msubsup></math>, <math><msubsup><mi>w</mi><mn>21</mn><mo>&#x2032;</mo></msubsup></math>, <math><msubsup><mi>w</mi><mn>13</mn><mo>&#x2032;</mo></msubsup></math>, <math><msubsup><mi>w</mi><mn>23</mn><mo>&#x2032;</mo></msubsup></math>, <math><msubsup><mi>w</mi><mn>18</mn><mo>&#x2032;</mo></msubsup></math>, <math><msubsup><mi>w</mi><mn>28</mn><mo>&#x2032;</mo></msubsup></math>, <math><msubsup><mi>w</mi><mrow><mn>1</mn><mi>,</mi><mn>10</mn></mrow><mo>&#x2032;</mo></msubsup></math> and <math><msubsup><mi>w</mi><mrow><mn>2</mn><mi>,</mi><mn>10</mn></mrow><mo>&#x2032;</mo></msubsup></math> in <math><mi>W</mi><mo>&#x2032;</mo></math> and weights <math><msub><mi>w</mi><mn>21</mn></msub></math> and <math><msub><mi>w</mi><mn>21</mn></msub></math> in <math><mi>W</mi></math> are updated.