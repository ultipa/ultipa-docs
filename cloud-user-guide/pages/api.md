# API

The Cloud API allows you to control your instances without the need to log in to the Ultipa Cloud dashboard.

## API Overview

### Base URL

The base URL for the Cloud API of both **Graph Powerhouse** and **Graph Blaze** instances is `https://cloud.ultipa.com/open/dbaas/v1/cluster`.

The base URL for the Cloud API of **Manager** instances is `https://cloud.ultipa.com/open/dbaas/v1/manager`.

### API Keys

API keys are required to authenticate API requests.

Go to **Accounts > API Keys** in Ultipa Cloud to create or manage your keys. When creating a key, be sure to download and store it securely for future use.

Each API request must include an API key in the request header, using the key name `api_key`.

## List Instances

### HTTP Request

To list **Graph Powerhouse** and **Graph Blaze** instances, submit a `GET` request to the following endpoint:

<p tit="http"></p>

```js
https://cloud.ultipa.com/open/dbaas/v1/cluster/list
```

To list **Manager** instances, submit a `GET` request to the following endpoint:

<p tit="http"></p>

```js
https://cloud.ultipa.com/open/dbaas/v1/manager/list
```

### Request Header

| <div table-width=15>Key</div> | <div table-width=7>Type</div> | <div table-width=7>Default</div> | <div table-width=9>Required</div> | Description |
| --- | --- | --- | --- | --- |
| `api_key` | String | / | Yes | Your Ultipa Cloud API key. |

### Request Parameters

| <div table-width=20>Parameter</div> | <div table-width=7>Type</div> | <div table-width=7>Default</div> | <div table-width=9>Required</div> | Description |
| --- | --- | --- | --- | --- |
| `page` | Integer | `1` | No | The page number in the response body. |
| `size` | Integer | `20` | No | The number of items displayed per page in the response body. |
| `instanceStateFilter` | Integer | `1` | No | Filter for cluster status:<br><ul><li>`1`: My Instances</li><li>`2`: Active Instances</li><li>`3`: Stopped Instances</li><li>`4`: Terminated Instances</li></ul> |
| `directions` | String | `desc` | No | Sorting order of elements in the response body: `desc` or `asc`. |
| `sorts` | String | `created_at` | No | Field for sorting elements in the response body. |

### Request Example

<p tit="HTTP Request"></p>

```js
GET https://cloud.ultipa.com/open/dbaas/v1/cluster/list??page=1&size=20&instanceStateFilter=1&directions=desc&sorts=created_at&componentType=GRAPH_V5`
Authorization: Bearer api_key:{Your Ultipa Cloud API key}
Accept: application/json
```

### Response Example

```js
{
    "code": 200,
    "message": "success",
    "data": {
        "page": 1,
        "size": 20,
        "totalPages": 1,
        "totalElements": 2,
        "list": [
            {
                "clusterId": "ultipa-abc123",
                "clusterState": "STOPPING",
                "name": "test2",
                "instanceList": [
                    {
                        "name": "xxxxxxxx_NAME_SERVER-1",
                        "instanceState": "STOPPING",
                        "type": "Name server"
                    },
                    {
                        "name": "xxxxxxxx_META_SERVER-1",
                        "instanceState": "STOPPING",
                        "type": "Meta server"
                    },
                    {
                        "name": "xxxxxxxx_SHARD_SERVER-1-1",
                        "instanceState": "STOPPING",
                        "type": "Shard server"
                    }
                ]
            },
            {
                "clusterId": "ultipa-abc456",
                "clusterState": "STOPPING",
                "name": "Graph Powerhouse 0",
                "instanceList": [
                    {
                        "name": "xxxxxxxxxxxx_NAME_SERVER-1",
                        "instanceState": "STOPPING",
                        "type": "Name server"
                    },
                    {
                        "name": "xxxxxxxxxxxx_META_SERVER-1",
                        "instanceState": "STOPPING",
                        "type": "Meta server"
                    },
                    {
                        "name": "xxxxxxxxxxxx_SHARD_SERVER-1-1",
                        "instanceState": "STOPPING",
                        "type": "Shard server"
                    }
                ]
            }
        ]
    }
}
```

## View Instance State

### HTTP Request

To view the state of **Graph Powerhouse** and **Graph Blaze** instances, submit a `POST` request to the following endpoint:

<p tit="http"></p>

```js
https://cloud.ultipa.com/open/dbaas/v1/cluster/state
```

To view the state of **Manager** instances, submit a `POST` request to the following endpoint:

<p tit="http"></p>

```js
https://cloud.ultipa.com/open/dbaas/v1/manager/state
```

### Request Header

| <div table-width=15>Key</div> | <div table-width=7>Type</div> | <div table-width=7>Default</div> | <div table-width=9>Required</div> | Description |
| --- | --- | --- | --- | --- |
| `api_key` | String | / | Yes | Your Ultipa Cloud API key. |

### Request Body

<p tit="JSON"></p>

```js
{
    "clusterIds": ["ultipa-abc123", "ultipa-abc456"]
}
```

| <div table-width=15>Key</div> | <div table-width=9>Type</div> | <div table-width=7>Default</div> | <div table-width=9>Required</div> | Description |
| --- | --- | --- | --- | --- |
| `clusterIds` or `managerIds` | Array | / | Yes | The IDs of the instances. |

### Request Example

<p tit="HTTP Request"></p>

```js
POST https://cloud.ultipa.com/open/dbaas/v1/cluster/state
Authorization: Bearer api_key:{Your Ultipa Cloud API key}
Content-Type: application/json

{
  "clusterIds": [
    "ultipa-abc123",
    "ultipa-abc456"
  ]
}
```

### Response Example

```js
{
    "code": 200,
    "message": "success",
    "data": [
        {
            "clusterId": "ultipa-abc123",
            "clusterState": "STOPPING",
            "name": "test2",
            "instanceList": [
                {
                    "name": "xxxxxxxxxxxxxxxxx_NAME_SERVER-1",
                    "instanceState": "STOPPING",
                    "type": "Name server"
                },
                {
                    "name": "xxxxxxxxxxxxxxxxx_META_SERVER-1",
                    "instanceState": "STOPPING",
                    "type": "Meta server"
                },
                {
                    "name": "xxxxxxxxxxxxxxxxxs_SHARD_SERVER-1-1",
                    "instanceState": "STOPPING",
                    "type": "Shard server"
                }
            ]
        },
        {
            "clusterId": "ultipa-abc456",
            "clusterState": "STOPPING",
            "name": "Graph Powerhouse 0",
            "instanceList": [
                {
                    "name": "xxxxxxxxxxxxxyyyyyy_NAME_SERVER-1",
                    "instanceState": "STOPPING",
                    "type": "Name server"
                },
                {
                    "name": "xxxxxxxxxxxxxyyyyyy_META_SERVER-1",
                    "instanceState": "STOPPING",
                    "type": "Meta server"
                },
                {
                    "name": "xxxxxxxxxxxxxyyyyyy_SHARD_SERVER-1-1",
                    "instanceState": "STOPPING",
                    "type": "Shard server"
                }
            ]
        }
    ]
}
```

## Start an Instance

### HTTP Request

To start a **Graph Powerhouse** or **Graph Blaze** instance, submit a `POST` request to the following endpoint:

<p tit="http"></p>

```js
https://cloud.ultipa.com/open/dbaas/v1/cluster/start
```

To start a **Manager** instance, submit a `POST` request to the following endpoint:

<p tit="http"></p>

```js
https://cloud.ultipa.com/open/dbaas/v1/manager/start
```

### Request Header

| <div table-width=15>Key</div> | <div table-width=7>Type</div> | <div table-width=7>Default</div> | <div table-width=9>Required</div> | Description |
| --- | --- | --- | --- | --- |
| `api_key` | String | / | Yes | Your Ultipa Cloud API key. |

### Request Body

<p tit="JSON"></p>

```js
{
    "clusterId": "ultipa-abc123"
}
```

| <div table-width=15>Key</div> | <div table-width=9>Type</div> | <div table-width=7>Default</div> | <div table-width=9>Required</div> | Description |
| --- | --- | --- | --- | --- |
| `clusterId` or `managerId` | String | / | Yes | The ID of the instance. |

### Request Example

<p tit="HTTP Request"></p>

```js
POST https://cloud.ultipa.com/open/dbaas/v1/cluster/start
Authorization: Bearer api_key:{Your Ultipa Cloud API key}
Content-Type: application/json

{
    "clusterId": "ultipa-abc123"
}
```

### Response Example

<p tit="JSON"></p>

```js
{
    "code": 200,
    "message": "success",
    "data": null
}
```

## Stop a Cluster

### HTTP Request

To stop a **Graph Powerhouse** or **Graph Blaze** instance, submit a `POST` request to the following endpoint:

<p tit="http"></p>

```js
https://cloud.ultipa.com/open/dbaas/v1/cluster/stop
```

To stop a **Manager** instance, submit a `POST` request to the following endpoint:

<p tit="http"></p>

```js
https://cloud.ultipa.com/open/dbaas/v1/manager/stop
```

### Request Header

| <div table-width=15>Key</div> | <div table-width=7>Type</div> | <div table-width=7>Default</div> | <div table-width=9>Required</div> | Description |
| --- | --- | --- | --- | --- |
| `api_key` | String | / | Yes | Your Ultipa Cloud API key. |

### Request Body

<p tit="JSON"></p>

```js
{
    "clusterId": "ultipa-abc123"
}
```

| <div table-width=15>Key</div> | <div table-width=9>Type</div> | <div table-width=7>Default</div> | <div table-width=9>Required</div> | Description |
| --- | --- | --- | --- | --- |
| `clusterId` or `managerId` | String | / | Yes | The ID of the instance. |

### Request Example

<p tit="HTTP Request"></p>

```js
POST https://cloud.ultipa.com/open/dbaas/v1/cluster/stop
Authorization: Bearer api_key:{Your Ultipa Cloud API key}
Content-Type: application/json

{
    "clusterId": "ultipa-abc123"
}
```

### Response Example

```js
{
    "code": 200,
    "message": "success",
    "data": null
}
```

## Response Error Codes

| <div table-width="10">Code</div> | <div table-width="40">Message</div> | Description |
| --- | --- | --- |
| 403 | Forbidden | The given API key does not have permission to perform the request. |
| 405 | Operation not allowed | The current state of the instance does not allow the request. |
| 408 | Login to this account is banned. If you have any questions, please email support@ultipa.com | Your account has been banned. |
| 409 | The account has been canceled | Your account has been canceled. |
| 1301 | Unable to verify identity | You did not provide an API key in the request, or the key is null. |
| 1302 | Key is invalid or has been revoked | The API key does not exist or is invalid. |
| 1303 | Key requests are frequent, please try again later. | The number of requests has exceeded the API request limit. |
