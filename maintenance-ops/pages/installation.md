# Installation

Install GQLDB on a Linux or macOS host by downloading the distribution, placing the license file, and starting the database service. The distribution is delivered as a native executable for the target platform, there is no container runtime required and no separate service stack to install.

**Prefer a managed service?** Ultipa Cloud is available at <a href="https://dbaas.ultipa.com" target="_blank">dbaas.ultipa.com</a>. Provisioned instances, automated backups, and HA handled for you. If you go that route, the rest of this page is optional; pick up at the driver / GQL docs once your instance endpoint is live.

## System Requirements

| Resource | Minimum (single-node, evaluation) | Recommended (production, single-node) |
| -- | -- | -- |
| **OS** | Linux (kernel ≥ 4.x) or macOS (Darwin) | Linux x86_64 or arm64 |
| **CPU** | 2 cores | 8+ cores |
| **Memory** | 4 GB RAM | 32 GB+ RAM (sized to graph + compute cache) |
| **Disk** | 10 GB free, local SSD strongly preferred | NVMe SSD; size = 3× raw data for headroom (LSM compaction + WAL + backups) |
| **File descriptors** | `ulimit -n 4096` | `ulimit -n 65536` |
| **Network** | One open TCP port for the gRPC service (default 60061) | Same; additional ports if running HA, see <a href="/docs/maintenance-ops/deployment-topologies" target="_blank">Deployment Topologies</a> |

Witness nodes in HA mode have far smaller resource needs (~50 MB RSS, tens of MB to a few GB disk depending on write rate), see <a href="/docs/maintenance-ops/deployment-topologies" target="_blank">Deployment Topologies</a> for the full sizing matrix.

## Quick Install (Community Edition)

The install script downloads the latest GQLDB Community server for your platform and installs it as the `ultipa-gqldb` command:

```bash
curl -fsSL https://download.ultipa.com/gqldb/install.sh | sh
```

After the script completes, verify the command is on your PATH:

```bash
ultipa-gqldb -version
```

On macOS the executable is flagged by Gatekeeper on first download; if the command above fails with a quarantine error, clear the attribute:

```bash
xattr -d com.apple.quarantine "$(command -v ultipa-gqldb)" 2>/dev/null
```

This installs the **Community Edition** of GQLDB, intended for evaluation, learning, and non-commercial use. For commercial deployments, obtain the appropriate licensed distribution from your Ultipa account team. See <a href="#Commercial-Install">Commercial Install</a> below.

## Commercial Install

For production / commercial deployments, the licensed GQLDB distribution is delivered through your Ultipa account team rather than the public install script. Contact your account team to obtain:

- The signed GQLDB server distribution for your platform.
- The commercial license file matching your purchased capacity (database cap, HA membership, supported nodes).
- Any feature-specific entitlements your contract includes.

Once you have the distribution, the install steps are the same as Manual Install below.

## License

A license file is **optional**. The database starts and runs without one, it falls back to the **Free Tier** limits below. To unlock higher capacity or HA, place a license file alongside the server executable (or anywhere readable) and pass its path with `-license-file`.

| Limit | Free Tier (no license file) | Paid Tier (with valid license file) |
| -- | -- | -- |
| Max databases (graphs) | 3 | Unlimited (or as licensed) |
| Max nodes per graph | 10 billion | Unlimited (or as licensed) |
| Max edges per graph | 10 billion | Unlimited (or as licensed) |
| Max CPU cores used | 2 | Unlimited (or as licensed) |
| HA mode | Not available | Available with HA-entitled license |

When you start without `-license-file`, you'll see a warning in the startup log:

<p tit="Log"></p>

```
[license] WARN: no license file specified — running with free-tier limits (3 graphs, 2 cores). Use WithLicenseFile() to enable a paid license.
```

This is informational, not an error; the database is running. If you intend to stay on the Free Tier, you can ignore the warning.

> Edition vs Tier: the *edition* (Community vs Commercial) is the distribution you obtained; the *tier* (Free vs Paid) is the runtime mode, determined by whether `-license-file` points at a valid signed license. A Commercial distribution launched without a license still runs at Free Tier limits; a Community distribution given a valid license file runs at the licensed limits.

## First Boot

The minimal launch command. The executable name depends on how you installed.

**1. Community Edition:** the script installs `ultipa-gqldb` as a command, so invoke it directly:

```bash
ultipa-gqldb -db ./my.gdb -rbac -admin-pass <strong-password> -port 60123
```

**2. Direct Download / Commercial Distribution:** the executable arrives with a versioned name (`ultipa-gqldb-<version>-<platform>`); launch it from its directory:

```bash
./ultipa-gqldb-1.x.y-linux-amd64 \
  -db ./my.gdb \
  -rbac \
  -admin-pass <strong-password> \
  -port 60123 \
  -license-file ./your.license
```

Both examples include `-rbac` (along with `-admin-pass`) so the database boots with authentication enabled. Without `-rbac`, the database starts with no auth and `-admin-pass` is silently ignored — fine for a throwaway local sandbox, not for anything else.

The `-admin-pass` value only takes effect on the **first boot** of a `-db` directory — that's when the `admin` user is created. On every later restart of the same `-db`, the persisted password is what's checked at login, so you don't have to pass `-admin-pass` again (and if you do, the value is ignored). Change the password through `ALTER USER` while logged in, or use `-reset-admin-pass` for offline recovery if you've forgotten it.

So a **restart** of an already-initialized `-db` is typically simpler — drop `-admin-pass` entirely:

```bash
ultipa-gqldb -db ./my.gdb -rbac -port 60123
```

The remaining examples in this page use `ultipa-gqldb`; substitute the versioned form if your install delivers one.

### Important Flags

| Flag | Default | Purpose |
| -- | -- | -- |
| `-db` | — | **Required**. Database directory. Created on first boot. Holds all graphs, indexes, WAL, backups. |
| `-port` | `60061` | gRPC listen port. |
| `-license-file` | — | Path to license file. |
| `-rbac` | off | **Boolean toggle (no argument).** Enables role-based access control. Without it, the database runs with no auth and any client can connect. Turn it on for anything beyond a local sandbox. Must be paired with `-admin-pass` on first boot. |
| `-admin-user` | `admin` | Used with `-rbac` to set the username of the admin account **on the very first boot** of a `-db` directory. On every subsequent restart, this flag is silently ignored. |
| `-admin-pass` | — | Used with `-rbac` to seed the admin user's password **on the very first boot** of a `-db` directory. On every subsequent restart of the same `-db`, this flag is silently ignored. If you've forgotten the password, use `-reset-admin-pass` (below) for offline recovery. |
| `-log-level` | `info` | `debug` / `info` / `warn` / `error`. |
| `-log-file` | (stderr) | Log directory path. Empty means stderr only. |
| `-log-max-size` | `100` | Max log file size in MB before rotation. |
| `-log-max-files` | `10` | Max number of rotated log files to keep. |
| `-tls-cert`, `-tls-key` | — | TLS certificate and private key. Both required for TLS. |
| `-max-msg-size` | (gRPC default, 4 MB) | Max size in bytes for a single gRPC message, applies to **both** the incoming request and the outgoing response. Raise it if large `INSERT` payloads or `RETURN` result sets are being rejected with `ResourceExhausted`. The matching client-side limit must be raised too. |
| `-config` | — | YAML or JSON config file. Command-line flags override file values. Recommended for production. |
| `-cache-size` | `10000` (≈40 MB) | In-memory read cache, sized in 4 KB pages (so `10000` ≈ 40 MB). The cache holds recently read storage pages so repeat lookups skip disk. Raise it for read-heavy workloads on graphs that don't fit in OS page cache; lower it to save RAM on small instances. |
| `-mem-limit-bytes` | `0` (auto) | Soft memory limit. `0` = auto from cgroup, `-1` = disabled. |
| `-readonly` | off | Open the database in read-only mode (analysis / migration). |
| `-reset-admin-pass` | — | Offline emergency recovery — resets the admin password and exits. Stop any running server on the same `-db` path first. |
| `-version` / `-v` | — | Show version and exit. |

### See All Flags

The list above covers the flags most operators need to know. For the complete set — including timeouts, log rotation, RBAC TTLs, compaction tuning, gRPC reflection, plugin loading, MCP mode, and any build-specific options — run:

```bash
ultipa-gqldb -help
```

For production, foreground it under your service manager (systemd, launchd, supervisord). For ad-hoc local testing, run it under `nohup`:

```bash
nohup ultipa-gqldb \
  -db ./my.gdb -admin-pass admin11 -port 60123 \
  -license-file ./your.license -rbac \
  > gqldb.log 2>&1 &
```

The `> gqldb.log 2>&1` is shell redirection (not `-log-file`). It captures **everything** the process writes — stderr logs, stdout banners, panic traces — into a single flat file. Convenient for `tail -f` on a local sandbox. For production, prefer `-log-file <dir>` so the server's structured logs land in rotated files (governed by `-log-max-size` / `-log-max-files`), and let the service manager handle stderr/stdout separately.

## Verifying the Install

Connect with the CLI or any driver and run:

```gql
RETURN db.version()
```

If the call returns a version string, the install is functional. To confirm the license:

```gql
RETURN db.license()
```

If `db.license()` returns "not configured" or similar, the `-license-file` flag wasn't picked up.

## Stopping the Database

Send SIGTERM to the process. Under `nohup` / shell-launched setups, the simplest approach is:

```bash
pkill -f ultipa-gqldb
```

Under a service manager, use the service-manager's stop command (e.g., `systemctl stop gqldb`). The database flushes outstanding writes and exits cleanly on SIGTERM. SIGKILL is only safe in HA mode where another replica holds the durable state — on a single-node install, SIGKILL can lose the last `SyncAsync` window (typically ~100 ms of writes; see <a href="/docs/maintenance-ops/backup-restore" target="_blank">Backup & Restore</a> for durability options).

## Updating

The update procedure differs between editions:

**1. Community Edition:** re-run the install script. It's idempotent and pulls the latest Community release:

```bash
curl -fsSL https://download.ultipa.com/gqldb/install.sh | sh
```

**2. Commercial Edition:** obtain the new distribution from your account team and replace the existing executable in place.

In both cases: stop the running database, replace the server executable, and restart with the same flags. Storage and on-disk format are backward-compatible across minor versions; major-version upgrades occasionally require a lazy migration.

For HA clusters, perform rolling upgrades. Update followers one at a time, then step down the leader. See <a href="/docs/maintenance-ops/deployment-topologies" target="_blank">Deployment Topologies</a>.

## Where Things Live on Disk

Inside `-db <path>`:

| Path | Contents |
| -- | -- |
| `graphs/<name>/` | Per-graph LSM storage, WAL, property indexes |
| `backups/` | Default location for `db.backup()` output (configurable per call) |
| `license/` | Cached license artifacts |
| `meta/` | Cluster metadata, RBAC store, ontology prefix table |

The `.gdb` directory is the entire authoritative state. Backing it up offline (with the process stopped or after a `FLUSH`) is a valid disaster-recovery strategy alongside `db.backup()` — see <a href="/docs/maintenance-ops/backup-restore" target="_blank">Backup & Restore</a>.
