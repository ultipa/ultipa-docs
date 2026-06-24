# Node Classification

A node-classification pipeline predicts a class label for each node, for example, a user's `role` in a social network (an *influencer* vs. a *regular* user). Nodes that **have** the target property are training/evaluation examples; nodes that **lack** it are the ones you predict.

> For the full parameters of every procedure on this page, see <a href="/docs/machine-learning/#Procedures" target="_blank">Procedures</a>.

## Quick Start

This worked example builds a small social graph of `:User` nodes connected by `:FOLLOWS` edges, then trains a model to classify each user's `role`. The features mix plain properties (`age`, `posts`) with **graph-structure signals** (follower count and PageRank) — influencers are followed by many users, so the topology itself is predictive.

### 1. Build the graph

```gql
CREATE GRAPH social
USE social

-- Users: some carry a 'role' label (training examples)
-- grace and heidi carry no 'role', they are the ones we will predict
-- FOLLOWS edges (follower -> followed); influencers attract many followers
INSERT (alice:User {_id: 'alice', name: 'Alice', age: 29, posts: 480, role: 'influencer'}),
       (bob:User   {_id: 'bob',   name: 'Bob',   age: 34, posts: 350, role: 'influencer'}),
       (frank:User {_id: 'frank', name: 'Frank', age: 27, posts: 510, role: 'influencer'}),
       (carol:User {_id: 'carol', name: 'Carol', age: 41, posts: 25,  role: 'regular'}),
       (dave:User  {_id: 'dave',  name: 'Dave',  age: 23, posts: 12,  role: 'regular'}),
       (erin:User  {_id: 'erin',  name: 'Erin',  age: 38, posts: 40,  role: 'regular'}),
       (grace:User {_id: 'grace', name: 'Grace', age: 31, posts: 460}),
       (heidi:User {_id: 'heidi', name: 'Heidi', age: 45, posts: 18}),
       (carol)-[:FOLLOWS]->(alice), (dave)-[:FOLLOWS]->(alice), (erin)-[:FOLLOWS]->(alice),
       (carol)-[:FOLLOWS]->(bob),   (dave)-[:FOLLOWS]->(bob),
       (erin)-[:FOLLOWS]->(frank),  (carol)-[:FOLLOWS]->(frank), (dave)-[:FOLLOWS]->(frank),
       (heidi)-[:FOLLOWS]->(grace), (carol)-[:FOLLOWS]->(grace), (dave)-[:FOLLOWS]->(grace),
       (grace)-[:FOLLOWS]->(alice), (alice)-[:FOLLOWS]->(bob)
```

### 2. Define and train the pipeline

```gql
-- Pipeline: classify a User's 'role'
CALL ml.create_pipeline('roles', {
  task: 'NODE_CLASSIFICATION',
  targetLabel: 'User',
  targetProperty: 'role'
})

-- Features: two properties + two graph-structure signals

CALL ml.add_feature('roles', {property: 'age'})
CALL ml.add_feature('roles', {property: 'posts'})

-- Algorithm features run over the whole graph at train time and write their per-node result to the 'output' property
CALL ml.add_feature('roles', {algo: 'degree', params: {direction: 'in'}, output: 'follower_count'})
CALL ml.add_feature('roles', {algo: 'pagerank', output: 'influence'})

-- Train/test split (small graph: hold out a quarter)
CALL ml.configure_split('roles', {testFraction: 0.25, randomSeed: 42})

-- Train and persist the model
CALL ml.train_nc('roles', {model: 'role_model'})
YIELD model, numClasses, numFeatures, trainSize, testSize, accuracy, f1Weighted
```

### 3. Predict

`predict_nc` scores every `:User` (the model's target label). Alice/Bob/… already had a known role; the interesting rows are **Grace** (high posts, followed by several users → likely `influencer`) and **Heidi** (low activity, no followers → likely `regular`).

```gql
CALL ml.predict_nc({model: 'role_model', mode: 'stream'})
YIELD nodeId, predictedClass, probability
```

Example output. The two previously unlabeled users **Grace** and **Heidi** are classified as expected:

| nodeId | predictedClass | probability |
| -- | -- | -- |
| alice | influencer | 0.9994818472272478 |
| bob | influencer | 0.9979447822190353 |
| frank | influencer | 0.975714660758967 |
| **grace** | **influencer** | **0.9780775559356233** |
| carol | regular | 0.9987372822407649 |
| dave | regular | 0.9989451106844224 |
| erin | regular | 0.998521538117348 |
| **heidi** | **regular** | **0.9988205072437105** |

`probability` is the model's confidence in the predicted class. Note that `predict_nc` scores **every** `:User`, including the ones that were already labeled, so you can also use it to sanity-check the model against the known labels.

> **Don't read too much into these numbers.** This demo graph is tiny and cleanly separable, so the probabilities sit very close to 0/1 and the held-out `accuracy`/`f1` from training are computed on just one or two rows — not statistically meaningful. On real, larger datasets expect more spread in the probabilities and treat the reported metrics as genuinely informative.

## Creating the Pipeline

```gql
CALL ml.create_pipeline('<name>', {
  task: 'NODE_CLASSIFICATION',   -- optional, the default
  targetLabel: '<Label>',        -- optional: train/predict only on nodes with this label
  targetProperty: '<property>',  -- required: the property holding the class label
  orReplace: false               -- optional: replace an existing pipeline
}) YIELD name, status
```

## Adding Features

Add one feature step at a time. Reuse an existing property, or run an algorithm whose per-node output is materialized into a property at train time.

```gql
-- Property feature
CALL ml.add_feature('roles', {property: 'age'}) YIELD name, status

-- Algorithm feature (output written to the given property and used as the feature)
CALL ml.add_feature('roles', {algo: 'pagerank', output: 'influence'}) YIELD name, status
CALL ml.add_feature('roles', {algo: 'degree', params: {direction: 'in'}, output: 'follower_count'}) YIELD name, status
```

A scalar property becomes one feature column; a `LIST` property (e.g. an embedding) expands into one column per element.

## Configuring the Split

```gql
CALL ml.configure_split('roles', {
  testFraction: 0.2,   -- fraction of labeled nodes held out for evaluation (0..1)
  randomSeed: 42       -- reproducible split
}) YIELD name, status
```

The split is **stratified**; each class is represented in both the train and test sets.

## Training

`ml.train_nc` materializes algorithm features, builds the labeled feature matrix, splits it, standardizes on the train split, fits the classifier, evaluates on the test split, and persists the model.

```gql
CALL ml.train_nc('<pipeline>', {
  model: '<model name>',             -- required
  modelType: 'logistic_regression', -- 'logistic_regression' (default) | 'random_forest'
  metric: 'F1_WEIGHTED',            -- F1_WEIGHTED (default) | F1_MACRO | ACCURACY
  folds: 0                          -- >= 2 enables k-fold cross-validation (reports cvScore)
  -- logistic_regression params: learningRate, maxEpochs, penalty
  -- random_forest params:       numTrees, maxDepth, minSamplesLeaf, maxFeatures
}) 
YIELD model, modelType, numClasses, numFeatures, trainSize, testSize,
      accuracy, f1Weighted, f1Macro, cvScore, primaryMetric, primaryScore
```

Random forest with 5-fold cross-validation:

```gql
CALL ml.train_nc('roles', {model: 'role_rf', modelType: 'random_forest', numTrees: 100, folds: 5})
YIELD model, accuracy, cvScore
```

## Predicting

Apply a trained model to nodes of the model's (frozen) target label.

```gql
-- Stream results
CALL ml.predict_nc({model: 'role_model', mode: 'stream'})
YIELD nodeId, predictedClass, probability

-- Return materialized rows
CALL ml.predict_nc({model: 'role_model'}) YIELD nodeId, predictedClass, probability

-- Write back to node properties (async task; map result column -> property)
CALL ml.predict_nc.write({model: 'role_model'},
       {db: {property: {predictedClass: 'pred', probability: 'pred_prob'}}})
YIELD task_id, nodesWritten
```

The `.write` form runs as a <a target="_blank" href="/docs/gql/query-management">background task</a> like an algorithm `.write`. Poll it with `SHOW TASK '<task_id>'` until `status = completed`.

## Catalog

```gql
CALL ml.list_pipelines() YIELD name, task, targetLabel, targetProperty, numFeatures, testFraction
CALL ml.list_models() YIELD name, pipeline, modelType, numClasses, numFeatures, accuracy, f1Weighted, trainSize, testSize

CALL ml.drop_pipeline('roles') YIELD name, status
CALL ml.drop_model('role_model') YIELD name, status
```
