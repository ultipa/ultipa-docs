# Graph Modeling

> This section introduces how to do graph modeling based on traditional table data in a simplified retailing scenario, in order to get graph data.

## Table Data

The three foundamental tables in retail business are Customer Information table, Merchant Information table, and Transaction Information table. Transaction Information table records customers' transaction behaviors to merchants when purchasing merchandises.

- Customer Information Table, CUSTOMER field：

| Field Name | Meaning | Example |
| -	| -	| -	|
| cust_no | Customer number（Main Key） | 100250090	|
| cust_name	| Customer name | Zhang San |
| risk_level | Evaluated risk level（1~10） | 4 |
| card_level | Card level（1~10） | 3 |
| balance | Card balance | 10000.11 |
| ... | ... | ... |

- Merchant Information table, MERCHANT field：

| Field Name | Meaning | Example |
| -	| -	| -	|
| merchant_no | Merchant number（Main Key）	| RS00JF1DF	|
| merchant_name	| Merchant name | Beijing Science and Technology Co. Ltd |
| type | Merchant type | IV |
| ... | ...	| ...|

- Transaction Informtion table, TRANSCTION field：

| Field Name | Meaning | Example |
| -	| -	| -	|
| cust_no | Customer number（External Key）	| 100250090	|
| merchant_no | Merchant number（External Key） | RS00JF1DF |
| tran_date	| Transaction date（timestamp） | 2022-03-21 22:12:56	|
| tran_amount | Transaction amount | 123.45 |
| tran_type	| Transaction type（1~20） | 13 |
| result | If successful（Y/N）	| Y	|
| ... | ...	| ... |

> If the scope of "external key" from TRANSCTION field exceeds "main key"s scope from CUSTOMER or MERCHANT，the transaction data can be regarded as invalid when inputting in a graph; or creating the customers and merchants the "external key" stands for before regarding the transaction data where the external key is located in as valid. Please note how Manager and Transporter handle this operation differently.

## Graph Data

<b>Graph modeling</b> is the process of transforminf table data to graph data.The easiest modeling approach is to divide table data into two cateogories: <font color=blue>Entity Table</font> and <font color=blue>Relation Table</font>，taking each Entity Table as a <font color=blue>node schema</font> in a graph，each Relation Table as an <font color=blue>edge schema</font> in a graph, and each field as a schema property.

It is often easy to identify an entity table, like CUSTOMER from customer information table and MERCHANT from merchant information table above. They stands for the two entities in a retailing scenario: customers and merchants.

The identification of a relation table depends on entities, for relation table stands for relations among multiple entity tables. Therefore a relation table needs to have at least two external keys that stand for entity tables. The two external keys from Transaction Information table are the main keys `cust_no` from Customer Information table and `merchant_no` from Merchant Information table, so it can be regarded as a relation table.

> To satisfy needs from real-world business scenarios, relation tables can be input as entity tables as well. The criteria include but not limited to the extensibility of the graph model, the complexity of UQL used for business expression, and operation efficiency, etc.

Customer Information table and Merchant Information Table are inputted as as node schema `customer` and `merchant`，and Transaction Information Table as edge schema `transfer`. Please note that edge schema does not reuse the name of the transaction information table but uses a verb; this is because Ultipa Graph's edges are directional edges, meaning that an edge always starts from a starting node to a terminal node, so the verb of the edge stands for an action from the starting node and the edge direction can be better understood semantically.

<div align=center drawio-diagram='2524' drawio-name='draw_1bdd638d0b694bc38effffcbee007417.jpg'><img src="https://img.ultipa.cn/draw/draw_1bdd638d0b694bc38effffcbee007417.jpg?v='1656426127118'"/></div>

Properties of schema `customer`, `merchant`, and `transfer`：

- Node schema `customer`

| Property Name | Data Type | Property Type	|
| -	| -	| -	|
| <font color=#aaaaaa>\_id</font> | <font color=#aaaaaa>string</font> | <font color=#aaaaaa>System property</font> |
| cust_name	| string | Custom property |
| risk_level | int32 | Custom property |
| card_level | int32 | Custom property |
| balance | float | Custom property |
| ... | ... | ... |

System property `_id` is the unique node identifier in a graphset (not belonging to any schema)，and it is the main key `cust_no` in the previous Customer Information table, its data type String's greatest length is 128: data type String's greatest length for other custom properties is 65535.  Ultipa supports both float and double, with different byte numbers and storage granularities; user can decide which one to use based on their needs.

- Node schema `merchant`

| Property Name | Data Type | Property Type	|
| -	| -	| -	|
| <font color=#aaaaaa>\_id</font> | <font color=#aaaaaa>string</font> | <font color=#aaaaaa>System property</font> |
| merchant_name	| string | Custom property |
| type | string | Custom property |
| ... | ... | ... |

System property here `_id` is the main key for previous Merchant Table `merchant_no`。

- Edge schema `transfer`

| Property Name | Data Type | Property Type	|
| -	| -	| -	|
| <font color=#aaaaaa>\_from</font>	| <font color=#aaaaaa>string</font>	| <font color=#aaaaaa>System property</font>	|
| <font color=#aaaaaa>\_to</font> | <font color=#aaaaaa>string</font> | <font color=#aaaaaa>System property</font>	|
| tran_date	| timestamp	| Custom property	|
| tran_amount	| float	| Custom property	|
| tran_type	| int32	| Custom property	|
| result	| string	| Custom property	|
| ...	| ...	| ...	|

System property `_from` is the edge's starting node's `_id`, which is one of the external keys here: `cust_no`；`_to` is the edge's terminal node's `_id`，which is another external key: `merchant_no`. The two properties' value are mandatory for inputting in graph.

> Naming convention for schema and property：2~64 characters, starting from a letter, composed of letters, numbers, and underlines.

> To satisfy needs from real-world business scenarios, some fields can be defined as schema as well, the judgement criteria includes but is not limited to the extensibility of the graph model, the complexity of UQL used for business expression, and operation efficiency, etc., similar to the handling of "Inputting Relational Table as Entity Table".
