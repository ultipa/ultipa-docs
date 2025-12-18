# Syntactic Notation

The syntactic notation used in this document is an extended version of Backus Normal Form (BNF).

In the version of BNF used in this document, the following symbols have the meanings shown in the following table.

| <div table-width="10">Symbol</div> | Meaning |
| -- | -- |
| `< >` | A character string enclosed in angle brackets is the name of a **syntactic element** of the GQL language. |
| `::=` | The **definition operator**. The element being defined appears to the left of the operator and the formula that defines the element appears to the right. |
| `[ ]` | Square brackets indicate **optional elements** in a formula. The portion of the formula within the brackets may be explicitly specified or may be omitted. |
| `{ }` | Braces **group elements** in a formula. The portion of the formula within the braces shall be explicitly specified. |
| `\|` | The **alternative operator**. The vertical bar indicates that the portion of the formula following the bar is an alternative to the portion preceding the bar. If the vertical bar appears at a position where it is not enclosed in braces or square brackets, it specifies a complete alternative for the element defined by the production rule. If the vertical bar appears in a portion of a formula enclosed in braces or square brackets, it specifies alternatives for the content of the innermost pair of such braces or brackets. |
| `...` | The ellipsis indicates that the element to which it applies in a formula may be **repeated any number of times**. If the ellipsis appears immediately after a closing brace `}`, then it applies to the portion of the formula enclosed between that closing brace and the corresponding opening brace `{`. If an ellipsis appears after any other element, then it applies only to that element. |

Whitespace is used to separate syntactic elements. Apart from those symbols to which special functions were given above, other characters and character strings in a formula stand for themselves. Pairs of braces and square brackets may be nested to any depth.