# Server Statistics

To view essential information about the Ultipa server environment, including license details and version data for each server node in the deployment.

<div tab="code">

```gql
STATS
```

```uql
stats()
```

</div>

It returns two tables:

- `license`: Displays server license information.
- `version`: Shows the version of each server node in the deployment. Each record includes the node's `type`, `identifier`, and `version`.
