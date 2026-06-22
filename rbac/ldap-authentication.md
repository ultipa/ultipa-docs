# LDAP / Active Directory Authentication

## Overview

GQLDB can authenticate users against an external **LDAP / Active Directory** directory in addition to its built-in user accounts. The two are not mutually exclusive, they run together in **hybrid mode**, with native users always checked first and LDAP consulted only if the native check fails. This guarantees a local break-glass admin keeps working even if the directory is unreachable.

LDAP is configured on the GQLDB server (not via GQL DDL), so enabling it is a one-time admin task rather than a per-graph or per-user operation. Once enabled, directory users log in with the same client and credentials they'd use for any other LDAP-backed service.

## Highlights

- **Bind-based.** GQLDB verifies the password by binding to the directory; no LDAP passwords are ever stored in GQLDB.
- **Auto-provisioning.** The first time a directory user logs in, a matching GQLDB user record is created automatically.
- **Group → role mapping.** A user's directory groups are mapped to GQLDB roles on every login. Mapped roles stay in sync; roles you assigned manually with <a target="_blank" href="/docs/rbac/grant-revoke-permissions">`GRANT ROLE`</a> outside the map are left untouched.
- **No password management in GQLDB.** `ALTER USER … SET PASSWORD` against an LDAP-backed user is rejected; passwords must be managed in the directory.
- **Hybrid coexistence.** Native and LDAP users live in the same `SHOW USERS` table. LDAP users appear automatically after their first successful login.

## Server Configuration

LDAP is configured on the `ultipa-gqldb` server at startup. Two paths:

- **Config file** (`-config <path>`): required for the full feature set: group → role mapping, TLS cert paths, direct-bind mode, attribute names, timeouts, default roles.
- **CLI flags** (`-ldap`, `-ldap-url`, `-ldap-bind-dn`, `-ldap-user-base-dn`, `-ldap-user-filter`): convenient for a quick search+bind setup; the file is still needed for anything beyond the basics. CLI flags override config-file values when both are present.

The service-account bind password is taken **only** from the `GQLDB_LDAP_BIND_PASSWORD` environment variable, never from the config file or CLI flags.

### Config File

The fastest way to get a valid file is to ask the server to generate one:

```bash
ultipa-gqldb -generate-config
# => writes ./gqldb.example.yml and exits
```

The template lists every recognized key with its default, so you can delete what you don't need and fill in the rest. See <a target="_blank" href="/docs/operations/database-installation#Using-a-Config-File">Operations → Database Installation → Using a Config File</a> for the full config.

**Example**: `rbac.ldap` config block

```yaml
rbac:
  enabled: true
  ldap:
    enabled: true
    url: ldaps://ad.corp.example.com:636        # use TLS in production
    ca_cert_file: /etc/gqldb/ldap-ca.pem
    # search+bind mode: a service account looks up the user,
    # then the server re-binds as them to verify the password
    bind_dn: "cn=svc-gqldb,ou=service,dc=corp,dc=example,dc=com"
    user_base_dn: "ou=users,dc=corp,dc=example,dc=com"
    user_search_filter: "(sAMAccountName=%s)"   # %s = login name
    group_member_attr: memberOf                 # AD: read groups off the user entry
    default_roles: ["reader"]                   # so new users aren't dead-on-arrival
    group_role_map:
      "GQLDB-Admins": admin
      "GQLDB-Writers": writer
      "GQLDB-Readers": reader
```

```bash
export GQLDB_LDAP_BIND_PASSWORD='<service-account-password>'

ultipa-gqldb -db ./my.gdb -rbac -port 60123 -config ./gqldb.yaml
```

### CLI Flags

For a minimal search+bind setup with no group mapping, the basics fit on one command line:

```bash
export GQLDB_LDAP_BIND_PASSWORD='<service-account-password>'

ultipa-gqldb -db ./my.gdb -rbac -port 60123 \
  -ldap \
  -ldap-url ldaps://ad.corp.example.com:636 \
  -ldap-bind-dn "cn=svc-gqldb,ou=service,dc=corp,dc=example,dc=com" \
  -ldap-user-base-dn "ou=users,dc=corp,dc=example,dc=com" \
  -ldap-user-filter "(sAMAccountName=%s)"
```

Every LDAP user lands with `default_roles` (or nothing, if you haven't set defaults) — there's no group → role mapping in this mode. Switch to the config file when you need that.

After updating the config or flags, restart `ultipa-gqldb` so the new block takes effect.

## Bind Modes

GQLDB supports two bind modes; pick one based on whether you need group-based role mapping.

### Search + Bind (Recommended)

A service account ("bind DN") connects to the directory, finds the user entry by login name, then GQLDB re-binds as the user to verify the password. **Required for group → role mapping**, because reading group membership usually needs more privileges than the user's own bind has.

Required fields: `bind_dn`, `user_base_dn`, `user_search_filter` (must contain `%s` for the username).

```yaml
ldap:
  bind_dn: "cn=svc-gqldb,ou=service,dc=corp,dc=example,dc=com"
  user_base_dn: "ou=users,dc=corp,dc=example,dc=com"
  user_search_filter: "(sAMAccountName=%s)"     # AD
  # or for OpenLDAP:
  # user_search_filter: "(uid=%s)"
```

### Direct Bind

Builds the user's DN from a template and binds directly — no service account needed. Simpler to set up, but group resolution is limited to attributes on the user's own entry (typically `memberOf`).

Required field: `user_dn_template` (must contain `%s` for the username). `bind_dn` **must be empty** to select this mode.

```yaml
ldap:
  user_dn_template: "uid=%s,ou=people,dc=corp,dc=example,dc=com"
  group_member_attr: memberOf                  # optional, for group-from-user lookup
```

## Configuration Reference

| Field | Required | Description |
| -- | -- | -- |
| `enabled` | yes | Turns LDAP authentication on. When `false`, only native users are accepted. |
| `url` | yes | Server URL, e.g. `ldap://host:389` or `ldaps://host:636`. |
| `start_tls` | no | Upgrades a plaintext `ldap://` connection to TLS before binding. Ignored for `ldaps://`. |
| `skip_verify` | no | Disables TLS certificate verification. **Insecure** — dev/test only; emits a warning. |
| `ca_cert_file` | no | PEM bundle used to verify the server certificate. |
| `connect_timeout` | no | Bounds the TCP dial. Defaults to `5s`. |
| `request_timeout` | no | Bounds each LDAP operation. Defaults to `10s`. |
| `bind_dn` | search+bind | Service-account DN used to find users. Leave empty to select direct-bind mode. |
| `user_base_dn` | search+bind | Search base for user entries. |
| `user_search_filter` | search+bind | Filter that matches a user by login name. Must contain `%s`. |
| `user_dn_template` | direct-bind | Builds the user DN from a template. Must contain `%s`. |
| `email_attr` | no | User attribute holding the email. Defaults to `mail`. |
| `display_name_attr` | no | User attribute holding the display name. Optional. |
| `group_member_attr` | no | Read group membership directly from this multi-valued attribute on the user entry (e.g. `memberOf` for AD), avoiding a separate group search. |
| `group_base_dn` | no | Search base for groups (used when `group_member_attr` is unset). |
| `group_search_filter` | no | Filter that matches the groups a user belongs to. Must contain `%s` for the user DN. |
| `group_name_attr` | no | Group attribute extracted as the group key. Defaults to `cn`. |
| `group_role_map` | no | Maps a directory group key to a GQLDB role name. Each group is matched both as its raw value and as its extracted CN. |
| `default_roles` | no | Roles granted to every LDAP user regardless of group, so users aren't dead-on-arrival with zero permissions. |

## How Login Resolves

1. The native verifier checks the local bcrypt password. If it matches, login succeeds immediately — this is the break-glass path.
2. Otherwise GQLDB binds to the directory to verify the credentials.
3. On success, the user is auto-provisioned (if new) and their roles are reconciled from their directory groups (mapped via `group_role_map`, augmented with `default_roles`).
4. A GQLDB-disabled account is always blocked, even with valid directory credentials.

If the directory is unreachable, local accounts still authenticate; directory users simply receive a generic "authentication failed" until the directory recovers.

## Limitations

- **No password changes through GQLDB.** Running `ALTER USER alice SET PASSWORD '…'` against an LDAP-backed user is rejected. Manage the password in the directory instead.
- **Empty passwords are always rejected**, even when LDAP would accept an anonymous bind. This guards against the "unauthenticated bind" footgun where a blank password silently succeeds.
- **Manual `GRANT ROLE` survives sync.** Roles you grant outside the `group_role_map` are preserved across login. Roles inside the map are reconciled on every login — removing a user from a directory group will revoke the corresponding GQLDB role at next login.

## Security Notes

- Prefer **`ldaps://`** (or `start_tls: true` on `ldap://`). Plaintext LDAP leaks credentials and bind responses in transit.
- Set `skip_verify: true` only for development. It disables certificate verification and is logged as a warning at startup.
- Keep the built-in `admin` account with a strong local password as a **break-glass login** for directory outages.
- Store the service-account password in `GQLDB_LDAP_BIND_PASSWORD` (env var only), never in the config file or version control.
- Use a **read-only** service account for `bind_dn` — it only needs to search users and (optionally) groups.
