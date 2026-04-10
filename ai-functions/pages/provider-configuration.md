# Provider Configuration

## ai.setapikey()

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

## ai.setprovider()

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

## ai.provider()

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

## ai.embeddim()

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
