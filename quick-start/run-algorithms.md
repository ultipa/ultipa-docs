# 4. Run Graph Algorithms

Beyond retrieving data, GQLDB ships a library of built-in graph algorithms for centrality, community detection, similarity, pathfinding, embeddings, and more. They answer structural questions that are hard to express as plain queries, like "who is most influential?" or "which users cluster together?".

For a full algorithm directory, see <a href="/docs/graph-algorithms" target="_blank">Graph Algorithms</a>.

## Rank by Degree

The simplest centrality measure is **degree**: how many edges a node has. Every algorithm is invoked with `CALL algo.<name>()`, and `YIELD` names the columns it produces. Since `Follows` edges point from follower to followee, each user's follower count is their in-degree:

```gql
CALL algo.degree({direction: "in", order: "desc"}) YIELD nodeId, degree
RETURN nodeId, degree
ORDER BY degree DESC
```

User with the `_id` as `u1` comes out on top with a degree of `6` (six followers). Use `direction: "out"` for how many people each user follows, or `both` to ignore direction.

To get the name of the users and their follower count:

```gql
CALL algo.degree({direction: "in", order: "desc"}) YIELD nodeId, degree
MATCH (n) WHERE n._id = nodeId
RETURN n.name, degree
ORDER BY degree DESC
```

## Rank by Influence with PageRank

Degree counts every follower equally. **PageRank** goes further, weighting a follow more heavily when it comes from an already-influential user, so it propagates influence along incoming edges. Get the top users by influence, with their names:

```gql
CALL algo.pagerank() YIELD nodeId, score
MATCH (n) WHERE n._id = nodeId
RETURN n.name, score
ORDER BY score DESC
```

Because `Follows` edges point from follower to followee, a high PageRank marks a user that many well-connected users follow.

---

You can now install, load, query, and analyze. Last stop: hand the whole thing to an AI agent. <a href="/docs/quick-start/work-with-ai" target="_blank">Work with an AI Agent</a>.
