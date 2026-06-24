# Machine Learning

GQLDB can train and apply supervised machine-learning models **inside the database**, reusing built-in graph algorithms and embeddings as features. Pipelines and trained models are stored in the graph catalog and survive a database reopen.

Two tasks are supported:

- <a href="/docs/machine-learning/node-classification" 
  target="_blank">Node Classification</a>: predict a class label for each node (e.g. churn, fraud, category).
- <a href="/docs/machine-learning/link-prediction-ml" 
  target="_blank">Link Prediction</a>: predict missing or future edges (recommendations, knowledge-graph completion).

## The Workflow

Both tasks follow the same four steps:

1. **Create a pipeline**: a named, persisted recipe (target + feature steps + split).
2. **Add feature steps**: existing node properties and/or graph algorithms (degree, PageRank, embeddings, etc.) whose per-node output becomes a feature.
3. **Train**: split the labeled data, fit a classifier, evaluate on a held-out test set, and persist the model.
4. **Predict**: score nodes (classification) or candidate node pairs (link prediction); stream or return the result (node classification can also write it back to a property).

The **split** (step 3) divides the labeled data into a *training set* (the rows the model learns from) and a held-out *test set* (rows kept aside to measure how well the model does on data it didn't train on). You can tune it with `ml.configure_split`, or rely on the default (20% held out for testing).

## Models

Pass `modelType` to the train procedure:

- **`logistic_regression`** (default) params: `learningRate`, `maxEpochs`, `penalty`. Training is deterministic.
- **`random_forest`** params: `numTrees`, `maxDepth`, `minSamplesLeaf`, `maxFeatures`.

Add `folds: <k>` (≥2) to either to report a mean k-fold cross-validation score (`cvScore`) alongside the held-out metrics.

## How Features and Prediction Work

- **Feature matrix.** Each feature step contributes columns built from a node property. A scalar property gives one column; a `LIST` property (e.g. an embedding) expands into one column per element. Missing values contribute `0`. The column layout (the *feature schema*) is frozen into the model at train time.
- **Standardization.** Per-column mean/standard-deviation are computed on the **train split only**, stored on the model, and re-applied identically at prediction time; no leakage from the test split.
- **Label encoding.** Distinct values of the target property are sorted into class indices stored on the model.
- **Frozen snapshot.** A model keeps its own copy of the pipeline as it was at train time, so editing or dropping the pipeline afterward never invalidates the model — `ml.drop_pipeline` does not cascade to models.

### Determinism and Stochastic Features

Logistic-regression training is deterministic. Some embedding algorithms (FastRP, Node2Vec) are **stochastic**, so they are materialized **once at train time**; prediction reuses the values written then rather than re-running them (which would change the embeddings and invalidate the model). To refresh embeddings, retrain.

### Computing Engine

Algorithm feature steps run the corresponding built-in algorithm; topology-based algorithms are far faster with the computing engine enabled:

```gql
ALTER GRAPH social SET COMPUTE ENABLED
```

Feature materialization and prediction write-back use the incremental property-write path and never trigger a topology rebuild.

## Procedures

Every operation is an `ml.*` procedure invoked with `CALL`. Two conventions apply throughout:

1. **The name can be positional.** The first parameter of every procedure is the pipeline (or model) name. You can pass it on its own before the options map, or as a key inside the map:

```gql
-- name positional
CALL ml.create_pipeline('roles', {
  targetLabel: 'User',
  targetProperty: 'role'
})

-- Equivalent: name as a map key
CALL ml.create_pipeline({
  name: 'roles',
  targetLabel: 'User',
  targetProperty: 'role'
})
```

2. **`mode` chooses what a procedure does with its output.** `run` (the default) returns the rows as a result table; `stream` emits them incrementally; `write` persists them back into the graph. Select a non-default mode either by suffixing the procedure name or by passing a `mode` option:

```gql
CALL ml.predict_nc.stream({model: 'role_model'})

-- Equivalent
CALL ml.predict_nc({model: 'role_model', mode: 'stream'})
```

Only the modes a procedure lists are valid (for example, `ml.predict_lp` supports `run` and `stream`, but not `write`).

### ml.create_pipeline

Creates a pipeline: a named, persisted recipe of task + target + feature steps + split. Set `task` to choose node classification or link prediction; the task determines which of the target options apply.

| Parameter | Type | Default | Description |
| -- | -- | -- | -- |
| `name` | `STRING` | — | **Required.** Pipeline name. |
| `task` | `STRING` | `NODE_CLASSIFICATION` | `NODE_CLASSIFICATION` or `LINK_PREDICTION`. |
| `targetLabel` | `STRING` | — | Node label to train/predict on. |
| `targetProperty` | `STRING` | — | **Required for node classification.** Node property holding the class label. |
| `targetEdgeType` | `STRING` | — | **Link prediction:** edge type to predict (empty = any edge). |
| `combiners` | `LIST` | `['hadamard']` | **Link prediction:** how the two endpoints' node vectors are combined into a pair feature, see <a href="/docs/machine-learning/link-prediction-ml#How-It-Differs-from-Node-Classification" target="_blank">Link Prediction</a>. |
| `negativeSamplingRatio` | `FLOAT` | `1.0` | **Link prediction:** non-edge (negative) samples per positive edge. |
| `orReplace` | `BOOLEAN` | `false` | Replace an existing pipeline of the same name. |

**Returns**

| Column | Type | Description |
| -- | -- | -- |
| `name` | `STRING` | Pipeline name. |
| `status` | `STRING` | Result status. |

### ml.add_feature

Appends one feature step to a pipeline, either an existing node property, or an algorithm whose per-node output is materialized to a property at train time and then used as the feature. Provide **either** `property` **or** `algo` (with `output`). Call it once per feature.

| Parameter | Type | Default | Description |
| -- | -- | -- | -- |
| `pipeline` | `STRING` | — | **Required.** Pipeline name. |
| `property` | `STRING` | — | Use this existing node property as a feature. |
| `algo` | `STRING` | — | Built-in <a href="/docs/graph-algorithms/" target="_blank">graph algorithm</a> to run as a feature (e.g. `degree`, `pagerank`, `fastrp`). |
| `params` | `MAP` | — | Parameters for the algorithm feature (e.g. `{direction: 'in'}`, `{dimensions: 64}`). |
| `output` | `STRING` | — | **Required with `algo`.** Property to materialize the algorithm result into. |

**Returns**

| Column | Type | Description |
| -- | -- | -- |
| `name` | `STRING` | Pipeline name. |
| `status` | `STRING` | Result status. |

### ml.configure_split

Sets the train/test split applied at training time. The `accuracy`/`f1` reported by `train_nc`/`train_lp` are computed on the held-out test set. Optional: a pipeline that is never configured uses the defaults below. The split is stratified (each class keeps its proportion in both the train and test sets).

| Parameter | Type | Default | Description |
| -- | -- | -- | -- |
| `pipeline` | `STRING` | — | **Required.** Pipeline name. |
| `testFraction` | `FLOAT` | `0.2` | Fraction of labeled data held out for evaluation (0–1). |
| `randomSeed` | `INTEGER` | `42` | Seed for a reproducible split. |

**Returns**

| Column | Type | Description |
| -- | -- | -- |
| `name` | `STRING` | Pipeline name. |
| `status` | `STRING` | Result status. |

### ml.train_nc / ml.train_lp

Trains and persists a model from a pipeline: `ml.train_nc` for node classification, `ml.train_lp` for link prediction. Both share the same parameters; the only differences are that `ml.train_lp` defaults `metric` to `AUC` (with mean-AUC cross-validation), while `ml.train_nc` defaults `metric` to `F1_WEIGHTED` (with mean-accuracy cross-validation).

| Parameter | Type | Default | Description |
| -- | -- | -- | -- |
| `pipeline` | `STRING` | — | **Required.** Pipeline name. |
| `model` | `STRING` | — | **Required.** Name to save the trained model under. |
| `modelType` | `STRING` | `logistic_regression` | `logistic_regression` or `random_forest`. |
| `metric` | `STRING` | `F1_WEIGHTED` (nc) / `AUC` (lp) | Primary metric. NC: `F1_WEIGHTED`, `F1_MACRO`, `ACCURACY`. LP: `AUC`, `F1_WEIGHTED`, `ACCURACY`. |
| `folds` | `INTEGER` | `0` | `≥ 2` enables k-fold cross-validation (reports `cvScore`). |
| `learningRate` | `FLOAT` | `0.5` | `logistic_regression`: gradient-descent learning rate. |
| `maxEpochs` | `INTEGER` | `300` | `logistic_regression`: training epochs. |
| `penalty` | `FLOAT` | `0` | `logistic_regression`: L2 regularization strength. |
| `numTrees` | `INTEGER` | `100` | `random_forest`: number of trees. |
| `maxDepth` | `INTEGER` | `12` | `random_forest`: maximum tree depth. |
| `minSamplesLeaf` | `INTEGER` | `1` | `random_forest`: minimum samples per leaf. |
| `maxFeatures` | `INTEGER` | `0` | `random_forest`: features considered per split (`0` = √(features)). |

**Returns**

| Column | Type | Description |
| -- | -- | -- |
| `model` | `STRING` | Trained model name. |
| `modelType` | `STRING` | Model type. |
| `numFeatures` | `INTEGER` | Number of feature columns. |
| `numClasses` | `INTEGER` | Number of classes (node classification). |
| `positives` | `INTEGER` | Positive edges used (link prediction). |
| `trainSize` | `INTEGER` | Training-set size. |
| `testSize` | `INTEGER` | Test-set size. |
| `accuracy` | `FLOAT` | Test-set accuracy. |
| `f1Weighted` | `FLOAT` | Test-set weighted F1. |
| `f1Macro` | `FLOAT` | Test-set macro F1 (node classification). |
| `auc` | `FLOAT` | Test-set ROC AUC (link prediction). |
| `cvScore` | `FLOAT` | Mean k-fold CV score (`0` if `folds < 2`). |
| `primaryMetric` | `STRING` | Primary metric name. |
| `primaryScore` | `FLOAT` | Primary metric score. |

> Combiners for link prediction are set on the **pipeline** (`create_pipeline`), not on `train_lp`.

### ml.predict_nc

Applies a trained node-classification model, scoring every node of the model's (frozen) target label.

| Parameter | Type | Default | Description |
| -- | -- | -- | -- |
| `model` | `STRING` | — | **Required.** Trained model name. |
| `mode` | `STRING` | `run` | `run` / `stream` (return predictions) or `write` (persist to properties). |

In `write` mode (`ml.predict_nc.write`), a second map maps result columns to node properties: `{db: {property: {predictedClass: 'pred', probability: 'pred_prob'}}}`.

**Returns** (`run` / `stream`)

| Column | Type | Description |
| -- | -- | -- |
| `nodeId` | `STRING` | Node identifier. |
| `predictedClass` | `STRING` | Predicted class label. |
| `probability` | `FLOAT` | Probability of the predicted class. |

In `write` mode, returns `task_id` and `nodesWritten` instead.

### ml.predict_lp

Applies a trained link-prediction model, scoring candidate **non-adjacent, 2-hop** node pairs and returning the most likely missing links. Unlike `predict_nc`, it has no write-back mode.

| Parameter | Type | Default | Description |
| -- | -- | -- | -- |
| `model` | `STRING` | — | **Required.** Trained model name. |
| `topK` | `INTEGER` | `10` | Number of top-scoring candidate links to return. |
| `maxCandidates` | `INTEGER` | `200000` | Safety cap on the number of candidate pairs scored. |
| `mode` | `STRING` | `run` | `run` or `stream`. |

**Returns**

| Column | Type | Description |
| -- | -- | -- |
| `node1` | `STRING` | First endpoint id. |
| `node2` | `STRING` | Second endpoint id. |
| `probability` | `FLOAT` | Predicted link probability. |

### ml.list_pipelines / ml.list_models

Lists the pipelines or trained models in the current graph's catalog. No parameters.

**Returns** — `ml.list_pipelines`

| Column | Type | Description |
| -- | -- | -- |
| `name` | `STRING` | Pipeline name. |
| `task` | `STRING` | ML task. |
| `targetLabel` | `STRING` | Target node label. |
| `targetProperty` | `STRING` | Target (class) property. |
| `numFeatures` | `INTEGER` | Number of feature steps. |
| `testFraction` | `FLOAT` | Test-split fraction. |

**Returns** — `ml.list_models`

| Column | Type | Description |
| -- | -- | -- |
| `name` | `STRING` | Model name. |
| `pipeline` | `STRING` | Source pipeline. |
| `modelType` | `STRING` | Model type. |
| `numClasses` | `INTEGER` | Number of classes. |
| `numFeatures` | `INTEGER` | Number of feature columns. |
| `accuracy` | `FLOAT` | Test accuracy. |
| `f1Weighted` | `FLOAT` | Test weighted F1. |
| `trainSize` | `INTEGER` | Training-set size. |
| `testSize` | `INTEGER` | Test-set size. |

### ml.drop_pipeline / ml.drop_model

Removes a pipeline or trained model from the catalog. Dropping a pipeline does **not** affect models already trained from it (each model holds a frozen snapshot).

| Parameter | Type | Default | Description |
| -- | -- | -- | -- |
| `name` | `STRING` | — | **Required.** Pipeline / model name to remove. |

**Returns**

| Column | Type | Description |
| -- | -- | -- |
| `name` | `STRING` | Pipeline or model name. |
| `status` | `STRING` | Result status. |

## Notes & Limitations

- Model weights are stored inline in the graph metadata. Logistic-regression blobs are tiny; random forests are larger (inline, with bounded defaults).
- Prediction reads features from the same properties written at train time — ensure those properties are present on the nodes you predict. For nodes added after training, re-run training (or materialize the feature) before predicting.
