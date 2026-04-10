# AI & Vector Functions

## Example Graph

<div align=center drawio-diagram='17191' drawio-name="draw_5fb3914b116b4a06ac12fbf6c9d30f68.jpg"><img src="https://img.ultipa.cn/draw/draw_5fb3914b116b4a06ac12fbf6c9d30f68.jpg?v='1733369467835'"/></div>

```gql
INSERT (p1:Paper {_id:'P1', title:'Efficient Graph Search', score:6, author:'Alex'}),
       (p2:Paper {_id:'P2', title:'Optimizing Queries', score:9, author:'Alex'}),
       (p3:Paper {_id:'P3', title:'Path Patterns', score:7, author:'Zack'}),
       (p1)-[:Cites {weight:2}]->(p2),
       (p2)-[:Cites {weight:1}]->(p3)
```

## AI Completion Functions

AI completion functions use a large language model to generate or execute GQL queries from natural language. Using `ai.setapikey()` to configure both the embedding and completion provider at once, no extra setup is needed. To use a different provider for completion (e.g., Anthropic for completion, OpenAI for embeddings), use `ai.setapikey()` with `false` to set the key without activating, then `ai.setCompletionProvider()` to switch.

### ai.gql()

Converts a natural language question into a GQL query using the configured completion provider. The function automatically includes the current graph's schema (labels, properties, edge patterns) as context for the LLM.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>ai.gql(&lt;question&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;question&gt;</code></td>
      <td><code>STRING</code></td>
      <td>A natural language question about the graph data</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>STRING</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN ai.gql("Find all papers written by Alex")
```

Result:

| ai.gql |
| -- |
| MATCH (p:Paper) WHERE p.author = 'Alex' RETURN p |

### ai.read()

Converts a natural language question into a read-only GQL query, executes it, and returns the results. Only read operations are allowed, any generated query containing write operations (`INSERT`, `DELETE`, `SET`, etc.) is rejected.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>ai.read(&lt;question&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;question&gt;</code></td>
      <td><code>STRING</code></td>
      <td>A natural language question about the graph data</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>RECORD</code></td>
    </tr>
  </tbody>
</table>

The returned record contains:

| Field | Type | Description |
| -- | -- | -- |
| `query` | `STRING` | The generated GQL query |
| `results` | `LIST` | The query results |
| `count` | `INT` | Number of result rows |

```gql
RETURN ai.read("How many papers did Alex write?")
```

Result:

```json
{
  "query": "MATCH (p:Paper) WHERE p.author = 'Alex' RETURN COUNT(p) AS count",
  "results": [
    {
      "count": 2
    }
  ],
  "count": 1
}
```

### ai.setCompletionProvider()

Sets the active completion provider. The provider's API key must have been set first via `ai.setapikey()`.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>ai.setCompletionProvider(&lt;provider&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;provider&gt;</code></td>
      <td><code>STRING</code></td>
      <td>Provider name: <code>"openai"</code>, <code>"gemini"</code>, <code>"xai"</code>, or <code>"anthropic"</code></td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>BOOL</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN ai.setCompletionProvider("openai")
```

### ai.completionProvider()

Returns the name of the current completion provider.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>ai.completionProvider()</code></td>
    </tr>
    <tr>
      <td><b>Arguments</b></td>
      <td colspan="3">None</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>STRING</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN ai.completionProvider()
```

## Vector Creation

### ai.vector()

Converts a list of numbers to a `VECTOR` type. Values are stored as 32-bit floats, so minor precision differences may occur (e.g., `0.1` becomes `0.10000000149011612`). This is useful when you need to explicitly create a `VECTOR` value for storing in a `VECTOR` property or passing to similarity functions.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>ai.vector(&lt;list&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;list&gt;</code></td>
      <td><code>LIST</code></td>
      <td>A list of numeric values</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>VECTOR</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN ai.vector([0.1, 0.2, 0.3])
```

Result:

```json
{
  "values": [
    0.10000000149011612,
    0.20000000298023224,
    0.30000001192092896
  ]
}
```

### ai.embed()

Generates an embedding vector from text using the configured AI provider.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>ai.embed(&lt;text&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;text&gt;</code></td>
      <td><code>STRING</code></td>
      <td>The text to generate an embedding for</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>VECTOR</code></td>
    </tr>
  </tbody>
</table>

An AI provider must be configured with `ai.setapikey()` before using this function.

```gql
LET embedding = ai.embed("Introduction to graph databases")
RETURN embedding, ai.dimension(embedding) AS dimensions
```

Result:

```json
{
  "embedding": {
    "values": [
      -0.0258026123046875,
      -0.0126800537109375,
      …
      0.0162200927734375,
      -0.017486572265625
    ]
  },
  "dimensions": 1536
}
```

## Similarity Functions

### ai.cosine()

Computes cosine similarity between two vectors. Returns a value between -1 and 1, where 1 means identical direction.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>ai.cosine(&lt;vector1&gt;, &lt;vector2&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;vector1&gt;</code></td>
      <td><code>VECTOR</code></td>
      <td>The first vector</td>
    </tr>
    <tr>
      <td><code>&lt;vector2&gt;</code></td>
      <td><code>VECTOR</code></td>
      <td>The second vector; must have the same dimension as <code>&lt;vector1&gt;</code></td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>FLOAT</code></td>
    </tr>
  </tbody>
</table>

```gql
LET v1 = ai.vector([1.0, 0.0, 0.0])
LET v2 = ai.vector([1.0, 1.0, 0.0])
RETURN ai.cosine(v1, v2)
```

Result: 0.7071067690849304

### ai.euclidean()

Computes Euclidean distance between two vectors. Lower values indicate more similarity.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>ai.euclidean(&lt;vector1&gt;, &lt;vector2&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;vector1&gt;</code></td>
      <td><code>VECTOR</code></td>
      <td>The first vector</td>
    </tr>
    <tr>
      <td><code>&lt;vector2&gt;</code></td>
      <td><code>VECTOR</code></td>
      <td>The second vector; must have the same dimension as <code>&lt;vector1&gt;</code></td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>FLOAT</code></td>
    </tr>
  </tbody>
</table>

```gql
LET v1 = ai.vector([1.0, 0.0])
LET v2 = ai.vector([0.0, 1.0])
RETURN ai.euclidean(v1, v2)
```

Result: 1.4142135381698608

### ai.dot()

Computes the dot product of two vectors.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>ai.dot(&lt;vector1&gt;, &lt;vector2&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;vector1&gt;</code></td>
      <td><code>VECTOR</code></td>
      <td>The first vector</td>
    </tr>
    <tr>
      <td><code>&lt;vector2&gt;</code></td>
      <td><code>VECTOR</code></td>
      <td>The second vector; must have the same dimension as <code>&lt;vector1&gt;</code></td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>FLOAT</code></td>
    </tr>
  </tbody>
</table>

```gql
LET v1 = ai.vector([1.0, 2.0, 3.0])
LET v2 = ai.vector([4.0, 5.0, 6.0])
RETURN ai.dot(v1, v2)
```

Result: 32

### ai.distance()

Computes the cosine distance between two vectors (1 - cosine similarity). Lower values indicate more similarity.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>ai.distance(&lt;vector1&gt;, &lt;vector2&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;vector1&gt;</code></td>
      <td><code>VECTOR</code></td>
      <td>The first vector</td>
    </tr>
    <tr>
      <td><code>&lt;vector2&gt;</code></td>
      <td><code>VECTOR</code></td>
      <td>The second vector; must have the same dimension as <code>&lt;vector1&gt;</code></td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>FLOAT</code></td>
    </tr>
  </tbody>
</table>

```gql
LET v1 = ai.vector([1.0, 0.0, 0.0])
LET v2 = ai.vector([1.0, 1.0, 0.0])
RETURN ai.distance(v1, v2)
```

Result: 0.2928932309150696

## Vector Utilities

### ai.dimension()

Returns the number of dimensions in a vector.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>ai.dimension(&lt;vector&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;vector&gt;</code></td>
      <td><code>VECTOR</code></td>
      <td>A vector value</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>INT</code></td>
    </tr>
  </tbody>
</table>

```gql
LET v = ai.vector([3.0, 4.0])
RETURN ai.dimension(v)
```

Result: 2

### ai.magnitude()

Returns the magnitude (L2 norm) of a vector.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>ai.magnitude(&lt;vector&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;vector&gt;</code></td>
      <td><code>VECTOR</code></td>
      <td>A vector value</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>FLOAT</code></td>
    </tr>
  </tbody>
</table>

```gql
LET v = ai.vector([3.0, 4.0])
RETURN ai.magnitude(v)
```

Result: 5

### ai.normalize()

Normalizes a vector to a unit vector (magnitude of 1).

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>ai.normalize(&lt;vector&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;vector&gt;</code></td>
      <td><code>VECTOR</code></td>
      <td>A vector value</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>VECTOR</code></td>
    </tr>
  </tbody>
</table>

```gql
LET v = ai.vector([3.0, 4.0])
RETURN ai.normalize(v)
```

Result:

```json
{
  "values": [
    0.6000000238418579,
    0.800000011920929
  ]
}
```

### ai.toList()

Converts a vector to a list of numbers.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>ai.toList(&lt;vector&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;vector&gt;</code></td>
      <td><code>VECTOR</code></td>
      <td>A vector value</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>LIST</code></td>
    </tr>
  </tbody>
</table>

```gql
LET embedding = ai.embed("Introduction to graph databases")
RETURN ai.toList(embedding)
```

Result: [-0.0258026123046875, -0.0126800537109375, …, 0.0162200927734375, -0.017486572265625]

## Vector Arithmetic

### ai.add()

Adds two vectors element-wise.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>ai.add(&lt;vector1&gt;, &lt;vector2&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;vector1&gt;</code></td>
      <td><code>VECTOR</code></td>
      <td>The first vector</td>
    </tr>
    <tr>
      <td><code>&lt;vector2&gt;</code></td>
      <td><code>VECTOR</code></td>
      <td>The second vector; must have the same dimension as <code>&lt;vector1&gt;</code></td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>VECTOR</code></td>
    </tr>
  </tbody>
</table>

```gql
LET v1 = ai.vector([1.0, 2.0])
LET v2 = ai.vector([3.0, 4.0])
RETURN ai.toList(ai.add(v1, v2))
```

Result: [4, 6]

### ai.subtract()

Subtracts the second vector from the first element-wise.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>ai.subtract(&lt;vector1&gt;, &lt;vector2&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;vector1&gt;</code></td>
      <td><code>VECTOR</code></td>
      <td>The first vector</td>
    </tr>
    <tr>
      <td><code>&lt;vector2&gt;</code></td>
      <td><code>VECTOR</code></td>
      <td>The second vector; must have the same dimension as <code>&lt;vector1&gt;</code></td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>VECTOR</code></td>
    </tr>
  </tbody>
</table>

```gql
LET v1 = ai.vector([5.0, 3.0])
LET v2 = ai.vector([1.0, 2.0])
RETURN ai.toList(ai.subtract(v1, v2))
```

Result: [4, 1]

### ai.scale()

Multiplies a vector by a scalar value.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>ai.scale(&lt;vector&gt;, &lt;scalar&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;vector&gt;</code></td>
      <td><code>VECTOR</code></td>
      <td>A vector value</td>
    </tr>
    <tr>
      <td><code>&lt;scalar&gt;</code></td>
      <td>Numeric</td>
      <td>The scalar multiplier</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>VECTOR</code></td>
    </tr>
  </tbody>
</table>

```gql
LET v = ai.vector([1.0, 2.0, 3.0])
RETURN ai.toList(ai.scale(v, 2))
```

Result: [2, 4, 6]

## Provider Configuration

### ai.setapikey()

Sets the API key for an AI provider. Optionally activates it as the current provider.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>ai.setapikey(&lt;provider&gt;, &lt;apiKey&gt; [, &lt;activate&gt;])</code></td>
    </tr>
    <tr>
      <td rowspan="4"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;provider&gt;</code></td>
      <td><code>STRING</code></td>
      <td>Provider name: <code>"openai"</code>, <code>"gemini"</code>, <code>"xai"</code>, or <code>"anthropic"</code> (completion only)</td>
    </tr>
    <tr>
      <td><code>&lt;apiKey&gt;</code></td>
      <td><code>STRING</code></td>
      <td>The API key</td>
    </tr>
    <tr>
      <td><code>&lt;activate&gt;</code></td>
      <td><code>BOOL</code></td>
      <td>Optional. Whether to set this as the active provider (default: <code>true</code>)</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>BOOL</code></td>
    </tr>
  </tbody>
</table>

By default, calling `ai.setapikey()` both sets the key and activates the provider:

```gql
RETURN ai.setapikey("openai", "sk-...")
```

Each provider stores one API key. Calling `ai.setapikey()` again for the same provider overwrites the previous key. To set keys for multiple providers without activating them, pass `false` as the third argument, then use `ai.setprovider()` to switch:

```gql
RETURN ai.setapikey("gemini", "AQ.za...", false)
```

> `"anthropic"` supports completion only (`ai.gql()`, `ai.read()`), it has no embedding model. Use `ai.setapikey("anthropic", "sk-ant-...", false)` followed by `ai.setCompletionProvider("anthropic")` to configure it for completion.

### ai.setprovider()

Switches the active embedding provider. The provider's API key must have been set first via `ai.setapikey()`.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>ai.setprovider(&lt;provider&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;provider&gt;</code></td>
      <td><code>STRING</code></td>
      <td>Provider name: <code>"openai"</code>, <code>"gemini"</code>, or <code>"xai"</code></td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>BOOL</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN ai.setprovider("openai")
```

### ai.provider()

Returns the name of the current AI provider.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>ai.provider()</code></td>
    </tr>
    <tr>
      <td><b>Arguments</b></td>
      <td colspan="3">None</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>STRING</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN ai.provider()
```

### ai.embeddim()

Returns the embedding dimension of the current provider.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>ai.embeddim()</code></td>
    </tr>
    <tr>
      <td><b>Arguments</b></td>
      <td colspan="3">None</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>INT</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN ai.embeddim()
```
