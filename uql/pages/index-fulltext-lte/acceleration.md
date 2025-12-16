# Acceleration

## Overview

Creating an <b>index</b> for a property involves generating an index tree stored on disk, which enables quicker retrieval and filtering of nodes and edges.
 
Ultipa's exclusive <b>full-text index</b> performs word segmentation for a textual property, and establishes a reverse index based on the results of the segmentation. This index, stored on disk, enables efficient keyword searches and is ideal for text-based filters.

Additionally, Ultipa facilitates the loading of a property and its index into its high-performance computing engine, known as <b>LTE</b> (Load To Engine). This accelerates the filtering of nodes and edges by minimizing disk I/O time.

## Index vs. LTE

Both the index and LTE improve query performance by consuming disk space and persisting the created content. However, they differ in some respects.

|<div table-width=60>Acceleration Object</div>| Index | LTE |
| -- | :--: | :--: |
| Node and edge queries, i.e., `find().nodes()` and `find().edges()` | ✓ | ✕ |
| The filtering of the start nodes in other queries (path, khop, etc.) | ✓ (Precedence) | ✓ |
| The filtering of nodes and edges other than the start nodes in other queries (path, khop, etc.) | ✓ | ✓ (Precedence) |
| Properties used in algorithms | ✕ | ✓ |

|<div table-width=19></div>| Index | LTE |
| -- | -- | -- |
| **Implementation Rationale** | Creates index trees and uses data structures in persistent storage, accelerating queries without burdening memory | Loads property to Ultipa computing engine, allowing direct property filtering during queries and reducing dependency on disk based I/O |
| **Memory and Disk Usage** | Index tree is saved on disk | Consumes some memory depending on the type and size of the property; values are also kept on disk persistently for automatic reloading after instance reboot |

> A property can be both indexed and LTE-ed to suit different scenarios. Both index and LTE will be automatically updated.
