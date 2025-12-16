# API

## Overview

**Ultipa Cloud API** enables you to operate your Ultipa Cloud instances without the need to log in to Ultipa Cloud. 

## API

### Base URL

The base URL of Ultipa Cloud API is `https://cloud.ultipa.com/open/dbaas/v1/instance`.

### API Keys

On **Accounts**, scroll down to **API Keys** to create or manage your API keys.

One API key should be included in each request header, with the key name as `api_key`.

### Request Limit

The API request limit is set to 80 requests per minute.

## Requests

### List Instances

**HTTP Request**

To list instances, submit a `GET` request to the following endpoint:

<p tit="http"></p>

```js
https://cloud.ultipa.com/open/dbaas/v1/instance/list
```

**Request Header**

| <div table-width=15>Key</div> | <div table-width=7>Type</div> | <div table-width=7>Default</div> | <div table-width=9>Required</div> | Description |
| --- | --- | --- | --- | --- | 
| `api_key` | String | / | Yes | Your Ultipa Cloud API key |

**Request Params**

Example `GET` request with parameters: 

<p tit="http"></p>

```js
https://cloud.ultipa.com/open/dbaas/v1/instance/list?instanceStateFilter=2&search=ultipa-abc123&page=1&size=1
```

| <div table-width=20>Key</div> | <div table-width=7>Type</div> | <div table-width=7>Default</div> | <div table-width=9>Required</div> | Description |
| --- | --- | --- | --- | --- | 
| `instanceStateFilter` | Int32 | `1` | No | Filter instances by their states: `1` for My Instances, `2` for Active (Running) Instances, `3` for Stopped Instances, `4` for Terminated Instances |
| `search` | String | / | No | Specify instance ID or name |
| `page` | Int32 | `1` | No | Filter page number in the response body |
| `size` | Int32 | `999` | No | Set the size (items per page) in the returned page of the response body |

**Example Response Body**

<p tit="JSON"></p>

```js
{
    "code": 200,
    "message": "success",
    "data": {
        "page": 1,
        "size": 2,
        "totalPages": 1,
        "totalElements": 2,
        "list": [
            {
                "instanceId": "ultipa-abc123",
                "instanceState": "STOPPED",
                "name": "Community"
            },
            {
                "instanceId": "ultipa-abc456",
                "instanceState": "RUNNING",
                "name": "Course Lab"
            }
        ]
    }
}
```

### View Instance State

**HTTP Request**

To view instance states, submit a `POST` request to the following endpoint:

<p tit="http"></p>

```js
https://cloud.ultipa.com/open/dbaas/v1/instance/state
```

**Request Header**

| <div table-width=15>Key</div> | <div table-width=7>Type</div> | <div table-width=7>Default</div> | <div table-width=9>Required</div> | Description |
| --- | --- | --- | --- | --- | 
| `api_key` | String | / | Yes | Your Ultipa Cloud API key |

**Request Body**

<p tit="JSON"></p>

```js
{
    "instanceIds": ["ultipa-abc123", "ultipa-abc456"]
}
```

| <div table-width=15>Key</div> | <div table-width=9>Type</div> | <div table-width=7>Default</div> | <div table-width=9>Required</div> | Description |
| --- | --- | --- | --- | --- | 
| `instanceIds` | []String | / | Yes | Specify instances by their IDs |

**Example Response Body**

<p tit="JSON"></p>

```js
{
    "code": 200,
    "message": "success",
    "data": [
        {
            "instanceId": "ultipa-abc123",
            "instanceState": "RUNNING",
            "name": "Course Lab"
        },
        {
            "instanceId": "ultipa-abc456",
            "instanceState": "STOPPED",
            "name": "Community"
        }
    ]
}
```

### Start an Instance

**HTTP Request**

To start an instance, submit a `POST` request to the following endpoint:

<p tit="http"></p>

```js
https://cloud.ultipa.com/open/dbaas/v1/instance/start
```

**Request Header**

| <div table-width=15>Key</div> | <div table-width=7>Type</div> | <div table-width=7>Default</div> | <div table-width=9>Required</div> | Description |
| --- | --- | --- | --- | --- | 
| `api_key` | String | / | Yes | Your Ultipa Cloud API key |

**Request Body**

<p tit="JSON"></p>

```js
{
    "instanceId": "ultipa-abc123"
}
```

| <div table-width=15>Key</div> | <div table-width=9>Type</div> | <div table-width=7>Default</div> | <div table-width=9>Required</div> | Description |
| --- | --- | --- | --- | --- | 
| `instanceId` | String | / | Yes | Specify the instance by its ID |

**Response Body**

<p tit="JSON"></p>

```js
{
    "code": 200,
    "message": "success",
    "data": null
}
```

### Stop an Instance

**HTTP Request**

To stop an instance, submit a `POST` request to the following endpoint:

<p tit="http"></p>

```js
https://cloud.ultipa.com/open/dbaas/v1/instance/stop
```

**Request Header**

| <div table-width=15>Key</div> | <div table-width=7>Type</div> | <div table-width=7>Default</div> | <div table-width=9>Required</div> | Description |
| --- | --- | --- | --- | --- | 
| `api_key` | String | / | Yes | Your Ultipa Cloud API key |

**Request Body**

<p tit="JSON"></p>

```js
{
    "instanceId": "ultipa-abc123"
}
```

| <div table-width=15>Key</div> | <div table-width=9>Type</div> | <div table-width=7>Default</div> | <div table-width=9>Required</div> | Description |
| --- | --- | --- | --- | --- | 
| `instanceId` | String | / | Yes | Specify the instance by its ID |

**Response Body**

<p tit="JSON"></p>

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
| 403 | Forbidden | The given API key does not have permission to perform the request |
| 405 | Operation not allowed | The current state of the instance does not allow the request |
| 408 | Login to this account is banned. If you have any questions, please email support@ultipa.com | Your account has been banned |
| 409 | The account has been canceled | Your account has been canceled |
| 1217 | The instance does not exist | The specified instance does not exist |
| 1301 | Unable to verify identity | You did not provide an API key in the request, or the key is null |
| 1302 | Key is invalid or has been revoked | The API key does not exist or is invalid |
| 1303 | Key requests are frequent, please try again later. | The number of requests has exceeded the API request limit |
