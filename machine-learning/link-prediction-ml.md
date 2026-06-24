# Link Prediction (ML)

A link-prediction pipeline learns to predict whether an edge *should* exist between two nodes, for recommendations, knowledge-graph completion, or forecasting future connections. 

> This is the **trained-model** approach. For the classic topology-based scores (Adamic–Adar, Common Neighbors, etc.) that need no training, see the <a href="/docs/graph-algorithms/adamic-adar" target="_blank">Link Prediction algorithms</a>.

> For the full parameters of every procedure on this page, see <a href="/docs/machine-learning/#Procedures" target="_blank">Procedures</a>.

## How It Differs from Node Classification

Link prediction classifies a **pair** of nodes (does an edge belong between them?), but the features you add are per-**node** — each endpoint has its own feature vector. A **combiner** is the rule that turns the two endpoint vectors `u` and `v` into the single vector that describes the pair. Combiners are set on the pipeline (`create_pipeline`).

If each node vector has `d` numbers, each combiner produces:

| Combiner | Pair vector from endpoint vectors `u`, `v` | Width |
| -- | -- | -- |
| `hadamard` (default) | element-wise product `u * v` | `d` |
| `l1` | element-wise `\|u - v\|` (absolute difference) | `d` |
| `l2` | element-wise `(u - v)^2` (squared difference) | `d` |
| `average` | element-wise `(u + v) / 2` | `d` |
| `concat` | `u` followed by `v` | `2d` |

`combiners` is a **list**, so you can pick more than one. When you do, each combiner's output vector is computed separately and the results are **concatenated end-to-end** into one longer pair vector — letting the model see the endpoints' relationship from several angles at once. With `d = 64`:

```text
combiners: ['hadamard']          -> pair vector = 64 numbers
combiners: ['hadamard', 'l1']    -> pair vector = 64 + 64 = 128 numbers
combiners: ['concat', 'l2']      -> pair vector = 128 + 64 = 192 numbers
```

The default is `['hadamard']` (a single combiner). Unknown names fall back to `hadamard`.

Training examples come from existing edges (positive examples); non-connected node pairs are sampled as negatives (`negativeSamplingRatio` per positive, default `1.0`).

## Quick Start

This uses the **same `social` graph** as <a href="/docs/machine-learning/node-classification" target="_blank">Node Classification</a> (`:User` nodes connected by `:FOLLOWS` edges). Here we train on the existing `:FOLLOWS` edges to predict the ones that are *missing*: "who should follow whom".

### 1. Build the graph

The same graph as <a href="/docs/machine-learning/node-classification#1--Build-the-graph" target="_blank">Node Classification</a>.

### 2. Define and train the pipeline

```gql
-- Pipeline: predict FOLLOWS edges. Combiners + edge type are set here.
CALL ml.create_pipeline('reco', {
  task: 'LINK_PREDICTION',
  targetEdgeType: 'FOLLOWS',     -- edge type to predict (optional; empty = any edge)
  combiners: ['hadamard']        -- how endpoint vectors are combined (default ['hadamard'])
})

-- Node features: combined per candidate pair at train time
CALL ml.add_feature('reco', {property: 'posts'})
CALL ml.add_feature('reco', {algo: 'fastrp', params: {dimensions: 64}, output: 'emb'})

-- Train/test split (small graph: hold out a quarter)
CALL ml.configure_split('reco', {testFraction: 0.25, randomSeed: 42})

-- Train and persist the model
CALL ml.train_lp('reco', {model: 'reco_model', metric: 'AUC'})
YIELD model, numFeatures, positives, trainSize, testSize, auc, accuracy
```

### 3. Predict

`predict_lp` scores candidate **non-adjacent, 2-hop** pairs (users who share a followee but don't yet follow each other) and returns the highest-scoring ones — the follows most likely to be missing.

```gql
CALL ml.predict_lp({model: 'reco_model', mode: 'stream', topK: 20})
YIELD node1, node2, probability
```

Example output from one run. The model surfaces a single strong candidate — **bob–erin** — with every other pair scoring near zero:

| node1 | node2 | probability |
| -- | -- | -- |
| **bob** | **erin** | **0.9918289894490157** |
| grace | erin | 0.007025801623288817 |
| bob | frank | 0.003275945559245846 |
| grace | frank | 0.0018845099481372219 |
| alice | frank | 0.0007833275393326102 |
| dave | carol | 0.0007032104498193619 |
| alice | heidi | 0.00036563839891730316 |
| carol | erin | 0.0000334034796401832 |
| dave | erin | 0.00003340262468713315 |
| bob | grace | 0.0000002689436385535279 |
| carol | heidi | 0.00000013956603792936783 |
| dave | heidi | 0.00000013956443039479093 |

Only **non-adjacent, 2-hop** pairs appear — users who share a neighbor but don't yet follow each other. `probability` ranks them, so you'd act on the top few (here, just bob–erin).

> **Don't read too much into these numbers.** This demo graph is tiny with only a handful of positive edges, so the held-out metrics aren't statistically meaningful and the probabilities are extreme (one near 1, the rest near 0). FastRP is also **stochastic**, so the exact pairs and values vary from run to run. On real, larger datasets expect more spread in the probabilities and treat the reported metrics as genuinely informative.

## Creating the Pipeline

```gql
CALL ml.create_pipeline('<name>', {
  task: 'LINK_PREDICTION',          -- required for link prediction
  targetEdgeType: '<EdgeType>',     -- edge type that defines positive examples (optional; empty = any edge)
  targetLabel: '<Label>',           -- optional: restrict candidate nodes to this label
  combiners: ['hadamard'],          -- hadamard | l1 | l2 | average | concat (list, concatenated)
  negativeSamplingRatio: 1.0,       -- non-edge samples per positive edge
  orReplace: false
}) YIELD name, status
```

## Adding Features

Features are **node** properties / algorithm outputs; they are combined per candidate pair at train and predict time. Add them exactly as for node classification:

```gql
CALL ml.add_feature('reco', {algo: 'fastrp', params: {dimensions: 64}, output: 'emb'}) YIELD name, status
CALL ml.add_feature('reco', {property: 'age'}) YIELD name, status
```

## Training

```gql
CALL ml.train_lp('<pipeline>', {
  model: '<model name>',             -- required
  modelType: 'logistic_regression', -- logistic_regression (default) | random_forest
  metric: 'AUC',                    -- AUC (default) | F1_WEIGHTED | ACCURACY
  folds: 0                          -- >= 2 enables k-fold cross-validation (reports mean AUC)
  -- logistic_regression params: learningRate, maxEpochs, penalty
  -- random_forest params:       numTrees, maxDepth, minSamplesLeaf, maxFeatures
}) 
YIELD model, modelType, numFeatures, positives, trainSize, testSize,
      auc, accuracy, f1Weighted, cvScore, primaryMetric, primaryScore
```

Training collects positive edges, samples negative (non-edge) pairs, combines each pair's endpoint features with the pipeline's combiners, standardizes on the train split, fits the classifier, and reports ranking quality (`auc`) plus classification metrics on the held-out edges. `positives` is the number of positive edges used.

Random forest with 5-fold cross-validation:

```gql
CALL ml.train_lp('reco', {model: 'reco_rf', modelType: 'random_forest', numTrees: 100, folds: 5})
YIELD model, auc, cvScore
```

## Predicting

`ml.predict_lp` scores candidate **non-adjacent, 2-hop** node pairs (nodes that share a neighbor but aren't yet connected) and returns the highest-scoring ones — the most likely missing links across the graph.

```gql
-- Stream the top candidate links
CALL ml.predict_lp({model: 'reco_model', mode: 'stream', topK: 20})
YIELD node1, node2, probability

-- Return materialized rows
CALL ml.predict_lp({model: 'reco_model', topK: 20}) YIELD node1, node2, probability
```

| Param | Default | Description |
| -- | -- | -- |
| `model` | (required) | Trained link-prediction model name. |
| `topK` | `10` | Number of top-scoring candidate links to return. |
| `maxCandidates` | `200000` | Safety cap on the number of candidate pairs scored. |

`predict_lp` returns results only (`run`/`stream`); unlike `predict_nc` it has no write-back mode.

## Catalog

```gql
CALL ml.list_pipelines() YIELD name, task, targetLabel, numFeatures, testFraction
CALL ml.list_models() YIELD name, pipeline, modelType, numFeatures, auc, accuracy, trainSize, testSize

CALL ml.drop_pipeline('reco') YIELD name, status
CALL ml.drop_model('reco_model') YIELD name, status
```
