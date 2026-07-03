# Graph ML Data Loaders

The `gqldb.ml` package streams graph features and subgraphs out of GQLDB into the Python machine-learning stack for **Graph Neural Network (GNN)** training. It is a **Python-only** feature of the GQLDB driver.

## How it fits

`gqldb.ml` is the *out-of-database* half of GQLDB's hybrid ML story:

- **In-database** (engine): `CALL ml.*` trains classic models and feature algorithms such as FastRP or PageRank, materializing embeddings onto node properties. See <a href="/docs/machine-learning/machine-learning" target="_blank">Machine Learning</a>, <a href="/docs/machine-learning/node-classification" target="_blank">Node Classification</a>, and <a href="/docs/machine-learning/link-prediction-ml" target="_blank">Link Prediction</a>.
- **Out-of-database** (here): the database does the graph work (scanning, k-hop neighborhood sampling); the loaders batch the results into <a href="https://pytorch-geometric.readthedocs.io/" target="_blank">PyTorch Geometric</a> / <a href="https://www.dgl.ai/" target="_blank">DGL</a> objects, where deep GNN training and GPU tooling live.

The typical flow: compute embeddings **in** the database (e.g. `CALL algo.fastrp.write(...)` or an `ml.*` pipeline) so they land on node properties, then stream those features **out** to PyG/DGL for training.

## Installation

The loaders ship with the `ml` extra, which adds `torch`:

```bash
pip install ultipa[ml]
```

PyTorch Geometric and DGL are **not** pulled in automatically — install whichever framework you convert to:

```bash
pip install torch_geometric   # required for GraphData.to_pyg()
pip install dgl               # required for GraphData.to_dgl()
```

> Importing `gqldb` itself stays torch-free. Only `GraphData.to_pyg()` / `GraphData.to_dgl()` require torch and the framework packages, so the base driver has no heavy ML dependencies.

## Loaders

Three loaders cover the common GNN training patterns. All are iterable and construct their subgraphs by issuing read-only GQL queries through the client.

| Loader | Yields | Use case |
|--------|--------|----------|
| `GraphLoader` | One `GraphData` for the whole (label-scoped) graph | Full-batch GNN on graphs that fit in memory |
| `NeighborLoader` | `GraphData` mini-batches with a sampled k-hop neighborhood | Scalable node-level training on large graphs |
| `EdgeLoader` | `GraphData` mini-batches carrying positive/negative supervision edges | Link prediction |

### Shared constructor arguments

Every loader accepts these arguments (via a common base):

| Argument | Type | Description |
|----------|------|-------------|
| `client` | positional | A `GqldbClient` (anything exposing `gql(query, config=None) -> Response`) |
| `feature_properties` | `Sequence[str]` | **Required.** Node property names used as features (scalar or list/embedding) |
| `node_label` | `Optional[str]` | Restrict to nodes of this label; otherwise all nodes |
| `target_property` | `Optional[str]` | Node property holding the class label (for supervised tasks) |
| `edge_label` | `Optional[str]` | Restrict to edges of this label; otherwise all edges |
| `graph_name` | `Optional[str]` | Target graph; defaults to the session's current graph |
| `add_reverse_edges` | `bool` | Symmetrize directed edges by also adding the reverse (default `False`) |

### GraphLoader

Loads the whole (optionally label-scoped) graph as a single `GraphData`. Calling `load()` returns the `GraphData`; iterating yields it once.

```python
from gqldb import GqldbClient, GqldbConfig
from gqldb.ml import GraphLoader

config = GqldbConfig(hosts=["localhost:9000"])

with GqldbClient(config) as client:
    client.login("admin", "password")

    loader = GraphLoader(
        client,
        feature_properties=["embedding", "age"],  # scalar OR list (embedding) props
        node_label="Paper",                        # optional label scope
        target_property="subject",                 # class label property (optional)
        graph_name="cora",                         # optional; else session graph
        add_reverse_edges=True,                    # symmetrize directed edges
    )

    data = loader.load()                           # -> GraphData
    print(data.num_nodes, data.num_edges, data.num_features)
```

### NeighborLoader

For graphs too large to load whole, `NeighborLoader` samples a k-hop neighborhood per batch of seed nodes and yields the induced subgraph. Each batch is a `GraphData` whose `seed_mask` marks the batch seeds (the nodes to compute loss on).

| Argument | Type | Default | Description |
|----------|------|---------|-------------|
| `batch_size` | `int` | `128` | Number of seed nodes per batch |
| `num_hops` | `int` | `2` | Neighborhood depth sampled around each seed |
| `shuffle` | `bool` | `True` | Shuffle seeds before batching |
| `seed` | `int` | `42` | RNG seed for deterministic shuffling |
| `seed_ids` | `Optional[Sequence[str]]` | `None` | Explicit seed `_id`s; otherwise all matching nodes are used |

```python
from gqldb.ml import NeighborLoader

loader = NeighborLoader(
    client,
    feature_properties=["embedding"],
    node_label="Paper",
    target_property="subject",
    graph_name="cora",
    batch_size=512,     # larger batches reduce round-trips
    num_hops=2,
)

for batch in loader:                  # each batch is a GraphData
    data = batch.to_pyg()
    # forward/backward on data.x, data.edge_index;
    # compute loss only on data.seed_mask nodes
```

### EdgeLoader

A mini-batch loader for **link prediction**. It loads the graph once, then yields `GraphData` batches that share the message-passing graph (`x` / `edge_index`) but carry a batch of positive supervision edges plus sampled negatives in `edge_label_index` / `edge_label` (`1` = real edge, `0` = sampled non-edge) — the shape PyTorch Geometric's link-prediction models expect.

| Argument | Type | Default | Description |
|----------|------|---------|-------------|
| `batch_size` | `int` | `1024` | Number of positive edges per batch |
| `negative_ratio` | `float` | `1.0` | Sampled negatives per positive edge |
| `shuffle` | `bool` | `True` | Shuffle positive edges before batching |
| `seed` | `int` | `42` | RNG seed for shuffling and negative sampling |

```python
from gqldb.ml import EdgeLoader

loader = EdgeLoader(
    client,
    feature_properties=["embedding"],
    node_label="Paper",
    edge_label="CITES",
    graph_name="cora",
    batch_size=2048,
    negative_ratio=1.0,
)

for batch in loader:
    data = batch.to_pyg()
    # message-pass over data.edge_index;
    # supervise on data.edge_label_index / data.edge_label
```

## GraphData

The framework-agnostic container the loaders produce. It holds contiguous integer node indices: `node_ids[i]` is the external `_id` of node index `i`, `x[i]` its feature vector, and `edge_index` holds `(src_idx, dst_idx)` pairs.

### Fields

| Field | Meaning |
|-------|---------|
| `node_ids` | External `_id` per node index |
| `x` | Feature matrix (list/embedding properties expand one column per element) |
| `feature_names` | Flattened column names (e.g. `embedding[0]`, `age`) |
| `edge_index` | `(src_idx, dst_idx)` message-passing pairs |
| `y` | Class index per node (`-1` = unlabeled) |
| `classes` | Index → label decoder |
| `train_mask` / `val_mask` / `test_mask` | Boolean split masks from `make_split_masks()` |
| `seed_mask` | Batch seeds (set by `NeighborLoader`) |
| `edge_label_index` / `edge_label` | Supervision pairs / 0–1 labels (set by `EdgeLoader`) |

### Properties

| Property | Description |
|----------|-------------|
| `num_nodes` | Number of nodes |
| `num_edges` | Number of edges |
| `num_features` | Feature matrix width |
| `num_classes` | Number of distinct classes (0 if unlabeled) |

### Methods

| Method | Description |
|--------|-------------|
| `make_split_masks(val_fraction=0.1, test_fraction=0.2, seed=42)` | Assign `train_mask` / `val_mask` / `test_mask` over the labeled nodes (`y >= 0`); unlabeled nodes are excluded. Deterministic; returns `self` |
| `to_pyg()` | Convert to a `torch_geometric.data.Data` object (requires `torch_geometric`) |
| `to_dgl()` | Convert to a `dgl.DGLGraph` with node features in `ndata['feat']` (requires `dgl`) |

## FeatureEncoder

`FeatureEncoder` flattens per-node property values into a fixed-width numeric matrix: a scalar property contributes one column, and a list property (e.g. an embedding) expands into one column per element. The loaders use it internally, but it is exported for reuse.

```python
from gqldb.ml import FeatureEncoder

encoder = FeatureEncoder(["embedding", "age"])
x = encoder.fit_transform(rows)     # fit width from the rows, then transform
print(encoder.num_features)         # total flattened column count
```

| Member | Description |
|--------|-------------|
| `fit(rows)` | Infer per-property width from the rows; returns `self` |
| `transform(rows)` | Transform rows to a `List[List[float]]` matrix |
| `fit_transform(rows)` | `fit` then `transform` in one call |
| `transform_row(values)` | Transform a single row to a `List[float]` |
| `num_features` | Total flattened column count (after `fit`) |

## Exported helpers

| Helper | Description |
|--------|-------------|
| `build_graph_data(...)` | Assemble a `GraphData` directly from query-result columns/rows |
| `sample_negative_pairs(num_nodes, count, edge_set, seed)` | Sample distinct non-edge node-index pairs (used by `EdgeLoader`) |

## End-to-End Example

### Node classification (full-batch)

```python
import torch
import torch.nn.functional as F
from torch_geometric.nn import GCNConv

from gqldb import GqldbClient, GqldbConfig
from gqldb.ml import GraphLoader

config = GqldbConfig(hosts=["localhost:9000"])

with GqldbClient(config) as client:
    client.login("admin", "password")

    # 1) Load the whole graph and assign train/val/test masks.
    #    'embedding' here is typically written in-database, e.g.
    #    CALL algo.fastrp.write(...) materializing an embedding property.
    data = (
        GraphLoader(
            client,
            feature_properties=["embedding"],
            node_label="Paper",
            target_property="subject",
            graph_name="cora",
            add_reverse_edges=True,
        )
        .load()
        .make_split_masks(val_fraction=0.1, test_fraction=0.2)
    )

    # 2) Convert to a PyTorch Geometric Data object.
    pyg = data.to_pyg()   # x, edge_index, y, train_mask/val_mask/test_mask

    # 3) Train a simple GCN.
    class GCN(torch.nn.Module):
        def __init__(self, in_dim, hidden, out_dim):
            super().__init__()
            self.conv1 = GCNConv(in_dim, hidden)
            self.conv2 = GCNConv(hidden, out_dim)

        def forward(self, x, edge_index):
            x = F.relu(self.conv1(x, edge_index))
            return self.conv2(x, edge_index)

    model = GCN(data.num_features, 64, data.num_classes)
    optimizer = torch.optim.Adam(model.parameters(), lr=0.01, weight_decay=5e-4)

    model.train()
    for epoch in range(100):
        optimizer.zero_grad()
        out = model(pyg.x, pyg.edge_index)
        loss = F.cross_entropy(out[pyg.train_mask], pyg.y[pyg.train_mask])
        loss.backward()
        optimizer.step()

    # 4) Evaluate on the test split.
    model.eval()
    pred = model(pyg.x, pyg.edge_index).argmax(dim=1)
    acc = (pred[pyg.test_mask] == pyg.y[pyg.test_mask]).float().mean()
    print(f"Test accuracy: {acc:.4f}")
```

### Mini-batch training loop (NeighborLoader)

For graphs too large to fit in memory, train over sampled k-hop neighborhoods and supervise on each batch's seed nodes:

```python
from gqldb.ml import NeighborLoader

loader = NeighborLoader(
    client,
    feature_properties=["embedding"],
    node_label="Paper",
    target_property="subject",
    graph_name="cora",
    batch_size=512,
    num_hops=2,
)

model.train()
for epoch in range(10):
    for batch in loader:
        data = batch.to_pyg()
        optimizer.zero_grad()
        out = model(data.x, data.edge_index)
        # loss only on the batch's seed nodes
        loss = F.cross_entropy(out[data.seed_mask], data.y[data.seed_mask])
        loss.backward()
        optimizer.step()
```

## Next Steps

- <a href="/docs/machine-learning/machine-learning" target="_blank">Machine Learning</a> - In-database ML pipelines and feature algorithms
- <a href="/docs/machine-learning/node-classification" target="_blank">Node Classification</a> - Training and applying node classifiers in the engine
- <a href="/docs/machine-learning/link-prediction-ml" target="_blank">Link Prediction</a> - In-database link-prediction pipelines
