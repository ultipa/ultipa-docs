# LTE

LTE (Load to Engine) operation specifies a node or edge property to be cached. When a property is no longer needed for caching, you can execute the UFE (Unload from Engine) operation to remove it. Although UFE-ed properties may remain temporarily in memory until cleared or evicted, they are no longer accessible by queries.

You can perform LTE on a property using the `LTE()` statement. The LTE operation runs as a job, you may run `show().job(<id?>)` afterward to verify the success of the completion.

```uql
LTE().node_property(@member._id)
```

```uql
LTE().edge_property(@transfer.amount)
```

You can perform UFE on a property using the `UFE()` statement.

```uql
UFE().node_property(@member._id)
```

```uql
UFE().edge_property(@transfer.amount)
```
