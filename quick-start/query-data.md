# 3. Query Your Data

GQL queries revolve around **pattern matching**: you describe a shape of nodes and edges, and the database finds every subgraph that fits.

## Find Nodes

`MATCH` describes a pattern; `RETURN` says what to output. Find all users and return two properties:

```gql
MATCH (u:User)
RETURN u.name, u.age
```

`(u:User)` is a node pattern: bind the variable `u` to every node labeled `User`. Return the whole node with `RETURN u`, or pick properties with dot access.

## Filter, Sort, and Limit

Add `WHERE` to filter, `ORDER BY` to sort, and `LIMIT` to cap the result:

```gql
MATCH (u:User)
WHERE u.age >= 30
RETURN u.name, u.age
ORDER BY u.age DESC
```

You can also inline a simple equality filter in the pattern itself:

```gql
MATCH (u:User {city: "London"}) RETURN u.name

-- The above is equivalent to
MATCH (u:User) WHERE u.city = "London" RETURN u.name
```

## Traverse Relationships

The essence of a graph database is following edges. Describe the edge between two node patterns. Who does Diana follow?

```gql
MATCH (a:User {name: "Diana"})-[:Follows]->(b:User)
RETURN b.name
```

`-[:Follows]->` is a directed edge pattern. Flip the arrow (`<-[:Follows]-`) to find Diana's followers instead:

```gql
MATCH (a:User {name: "Diana"})<-[:Follows]-(b:User)
RETURN b.name
```

Or drop the direction (`-[:Follows]-`) to match either way:

```gql
MATCH (a:User {name: "Diana"})-[:Follows]-(b:User)
RETURN b.name
```

## Aggregate

Aggregate functions like `count`, `avg`, `min`, and `max` collapse matched rows into summary values:

```gql
-- How many follow relationships exist?
MATCH ()-[r:Follows]->()
RETURN count(r) AS totalFollows
```

```gql
-- Count followers of each user
MATCH (u:User)<-[:Follows]-(follower:User)
RETURN u.name, count(follower) AS followers GROUP BY u.name
```

## Follow Multi-Hop Paths

To reach beyond direct neighbors, quantify the edge. This finds everyone within 1 to 2 follow-hops of Alice, binding the whole path to `p`:

```gql
MATCH p = (a:User {name: "Alice"})-[:Follows]->{1,2}(b:User)
RETURN p
```

`->{1,2}` repeats the edge between 1 and 2 times. The path variable `p` captures the full sequence of nodes and edges.

## Find Shortest Paths

Prefix a quantified path with a shortest-path selector to get the shortest connection between two nodes instead of every path. This returns one shortest follow chain from George to Charlie:

```gql
MATCH p = ALL SHORTEST (a:User {name: "George"})-[:Follows]->{1,5}(b:User {name: "Charlie"})
RETURN p
```

`ALL SHORTEST` picks all paths with the fewest edges.

---

Querying retrieves what is explicitly there. To surface structural insight like influence and communities, run an algorithm: <a href="/docs/quick-start/run-algorithms" target="_blank">Run Graph Algorithms</a>.
