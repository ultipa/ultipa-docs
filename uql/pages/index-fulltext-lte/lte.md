# LTE

## LTE

LTE is short for Load to Engine, it loads disk-based properties into Ultipa's high-performance graph computing engine. Before executing LTE, make sure there is adequate memory space. System properties UID, FROM and TO do not support LTE operation. Previously LTE-ed properties will be auto LTE-ed again after a system reboot and a GraphSet re-mount.

> LTE is a prerequisite when executing inter-step comparison (by `path_ascend()`, `path_descend()`), weighted shortest path calculation (by `shortest(<property>)`) and inter-step filtering (by `prev_n`, `prev_e` and alias defined earlier in the same path template).

Syntax:
<p tit="Syntax"></p>

```js
// To load a certain node property under a certain node schema in the current graphset
LTE().node_property(@<schema>.<property>)

// To load a certain node property (if has) under all node schemas in the current graphset
LTE().node_property(@*.<property>)

// To load a certain edge property under a certain edge schema in the current graphset
LTE().edge_property(@<schema>.<property>)

// To load a certain edge property (if has) under all edge schemas in the current graphset
LTE().edge_property(@*.<property>)
```

## UFE

UFE is short for Unload from Engine, it unloads properties not needed for query acceleration from engine, hence saves server memory (the property continues to persist on disk unless it is deleted). Deleting a property will also remove the property from engine, unmounting a GraphSet also unloads its properties, if there is any, from engine.

> The `UFE()` will take some time depending on the size of the data, but will not affect other operations.

Syntax:
<p tit="Syntax"></p>

```js
// To unload a certain node property under a certain node schema in the current graphset
UFE().node_property(@<schema>.<property>)

// To unload a certain node property (if has) under all node schemas in the current graphset
UFE().node_property(@*.<property>)

// To unload a certain edge property under a certain edge schema in the current graphset
UFE().edge_property(@<schema>.<property>)

// To unload a certain edge property (if has) under all edge schemas in the current graphset
UFE().edge_property(@*.<property>)
```