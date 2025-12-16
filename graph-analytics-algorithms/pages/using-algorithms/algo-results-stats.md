# Algorithm Results and Statistics

There are two kinds of execution result of Ultipa graph algorithms: <b>algorithm results</b> and <b>statistics</b>. Some algorithms have both, and some have no statistics. By specifying how the algorithm is executed, you may decide which kind of result is returned.

### Algorithm Results

The algorithm results generally include the unique identifiers (`_uuid` or `_id`) of the nodes (or edges) and the corresponding calculation results.

Here an example results of the Degree Centrality algorithm, which contains two columns, the first column is the UUID of the node, and the second column is the calculated node degree:

| \_uuid | degree |
| ------ | ------ |
| 1 | 3 |
| 2 | 3 |
| 3 | 5 |
| 4 | 2 |
| 5 | 2 |

And an example results of the Jaccard similarity algorithm, with three columns, the first two columns are the UUIDs of the two nodes comparing similarity, and the third column is the similarity between them:

| node1	| node2	| similarity |
| -- | -- | -- |
| 1	| 3	| 0.25 |
| 1	| 2	| 0.2 |
| 1	| 4	| 0.166666666666667 |

### Statistics

Algorithm statistics generally include one or multiple KVs (Key-Value). 

Here an example statistics of the Degree Centrality algorithm, which contains total degree (`total_degree`) and avgerage degree (`average_degree`) of all nodes calculated:

| total_degree | average_degree |
| -- | -- |
| 10 | 1.25 |

And an example statistics of the Lovain algorithm, which contains the number of communities divisions (`community_count`) and the modularity (`modularity`):

| community_count | modularity |
| --------------- | ---------- |
| 3 | 0.43 |
null
