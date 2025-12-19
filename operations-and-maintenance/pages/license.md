# License

The use of Ultipa requires licenses. Ultipa Powerhouse v5 offers two licenses:

- Server License
- Algo License

They are both mounted into the Meta server container (`/opt/meta-server/resource/cert`).

## How to Apply for a License

You can apply for a license by logging in to the [Ultipa website](https://www.ultipa.com), clicking your email address in the top-right corner, and navigating to **User Center > License**. An Ultipa representative will get in touch with you shortly.

Alternatively, you may contact us directly at [support@ultipa.com](mailto:support@ultipa.com).

## Dumping License

To dump or print out information about the server license in your database:

```uql
license.dump()
```

It returns a table `license` with the following fields:

| <div table-width="20">Field</div> | Description |
| -- | -- |
| `license_uuid` | The unique identifier for the license. |
| `company` | The name of the company that owns the license. |
| `department` | The department within the company that owns the license. |
| `limited_user` | The maximum number of database users allowed. |
| `limited_graph` | The maximum number of graphsets allowed. |
| `limited_node` | The maximum number of nodes that each graphset can contain. |
| `limited_edge` | The maximum number of edges that each graphset can contain. |
| `limited_shard` | The maximum number of shard servers allowed. |
| `limited_hdc` | The maximum number of HDC servers allowed. |
| `expired_date` | The expiration date of the license. |

## Updating License

Licenses must be updated upon expiration to ensure continued access to Ultipa features and services.

### Using UQL

To update both server license and algo license:

```uql
license.update("<server_license_contxt>", "<algo_license_context>")
```

To update server license only:

```uql
license.update("<server_license_contxt>", "")
```

To update algo license only:

```uql
license.update("", "<algo_license_context>")
```

### Server-side Operation

You can also update the licenses by running the `./ultipa.sh` script provided during <a target="_blank" href="/docs/operations-and-maintenance/install-ultipa">deployment</a>:

```bash
./ultipa.sh lic upload --config example.sh
```

This command uploads the updated `ultipa.lic` and `ultipa_algo.lic` files—specified in the `example.sh` configuration file—to the Meta servers.
