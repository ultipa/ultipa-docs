# Deployment with Kubernetes

## Overview

Ultipa supports native Kubernetes deployment via:

- **Helm Chart**: One-command cluster deployment with configurable topology.
- **K8s Operator**: Automated lifecycle management including scaling, upgrades, and failure recovery.

The deployment architecture consists of:

- **Meta Server**: Deployed as a StatefulSet with Raft consensus (typically 3 replicas).
- **Shard Server**: Deployed as StatefulSets (one per shard group), each with configurable Raft replicas.
- **Name Server**: Deployed as a Deployment (stateless), serving as the client entry point.
- **HDC Server** (optional): Deployed as a Deployment for high-density computing workloads.

## Using Helm Chart

### Installation

Install from a local chart with a minimal single-node setup:

```bash
helm install my-cluster ./ultipa-helm-chart \
  --set shards.count=1 \
  --set metaServer.replicas=1 \
  --set nameServer.replicas=1
```

Production deployment with high availability:

```bash
helm install prod-cluster ./ultipa-helm-chart \
  --set shards.count=3 \
  --set shards.replicasPerShard=3 \
  --set metaServer.replicas=3 \
  --set nameServer.replicas=2 \
  --set nameServer.service.type=LoadBalancer
```

### Helm Parameters

| <div table-width="40">Parameter</div> | Default | Description |
| -- | -- | -- |
| `metaServer.replicas` | `3` | Meta server replicas. Use an odd number for Raft consensus. |
| `nameServer.replicas` | `2` | Name server replicas. |
| `shards.count` | `1` | Number of shard groups. |
| `shards.replicasPerShard` | `1` | Raft replicas per shard group. |
| `shards.storage.dataSize` | `100Gi` | Persistent volume size for shard data. |
| `nameServer.service.type` | `ClusterIP` | Service type for the name server. Set to `LoadBalancer` for external access. |
| `hdcServer.enabled` | `false` | Enables HDC server deployment. |
| `monitoring.prometheus.serviceMonitor.enabled` | `false` | Creates a Prometheus ServiceMonitor resource. |

### Kubernetes Resources Created

| Resource | Type | Purpose |
| -- | -- | -- |
| Meta server | StatefulSet | Meta server Raft cluster with persistent storage. |
| Shard server | StatefulSet (per shard) | Shard server Raft groups with persistent storage. |
| Name server | Deployment | Stateless name server as the client endpoint. |
| Shard register job | Job (Helm hook) | Automatically registers shards after installation. |
| PodDisruptionBudget | PDB | Ensures high availability during node maintenance. |
| ServiceMonitor | ServiceMonitor | Prometheus metrics integration (optional). |

### Health Endpoints

Each server exposes HTTP health endpoints for Kubernetes probes:

| Server | Endpoint | Purpose |
| -- | -- | -- |
| All servers | `/health` | Liveness probe. Returns `{"status": "UP"}`. |
| Name server | `/ready` | Readiness probe. Returns cluster status including shard count, active sessions, and disk usage. |
| Shard server | `/ready` | Readiness probe. Returns shard ID and Raft readiness. |
| Meta server | `/ready` | Readiness probe. Returns leader status. |

## Using K8s Operator

The Ultipa Operator manages the full lifecycle of Ultipa clusters through a custom resource definition (CRD).

### Install the Operator

```bash
# Install CRD
kubectl apply -f config/crd/bases/

# Deploy Operator
kubectl apply -f config/rbac/
kubectl apply -f config/manager/
```

### Create a Cluster

Define a cluster using the `UltipaCluster` CRD:

```yaml
apiVersion: ultipa.com/v1alpha1
kind: UltipaCluster
metadata:
  name: my-cluster
spec:
  version: "5.3.0"
  image:
    graphdb: "<your-registry>/ultipa-server:5.3.0"
    meta: "<your-registry>/ultipa-meta:5.3.0"
  metaServer:
    replicas: 3
    storage: { size: "10Gi" }
  nameServer:
    replicas: 2
  shards:
  - shardId: 1
    replicas: 3
    storage: { dataSize: "100Gi", backupSize: "50Gi" }
  auth:
    rootPassword: "root"
```

Apply the resource:

```bash
kubectl apply -f my-cluster.yaml
```

### Operator Capabilities

- **Cluster Lifecycle**: Create, update, and delete entire Ultipa clusters from a single CRD.
- **Scaling**: Change shard count or replica count — the Operator automatically creates StatefulSets and registers shards.
- **Rolling Upgrade**: Change `spec.version` — the Operator updates images across all components.
- **Status Tracking**: Monitor cluster status via `kubectl get ultipacluster`.

### Cluster Status

```bash
kubectl get ultipacluster
```

```
NAME         PHASE     READY   TOTAL   VERSION      AGE
my-cluster   Running   8       8       5.3.0        2h
```

The `PHASE` field indicates the cluster state: `Pending`, `Forming`, `Running`, or `Degraded`.

## Local Testing

To test a deployment locally using minikube or kind:

```bash
minikube start --cpus=4 --memory=16g

# Load Ultipa images
minikube image load ultipa-server:5.3.0
minikube image load ultipa-meta:5.3.0

# Deploy
helm install test ./ultipa-helm-chart \
  --set shards.count=1 \
  --set metaServer.replicas=1 \
  --set nameServer.replicas=1

# Verify pods are running
kubectl get pods

# Access the cluster
kubectl port-forward svc/test-ultipa-name 60061:60061
```

## Auto-Scaling

Ultipa supports Kubernetes HPA (HorizontalPodAutoscaler) for the Name Server, which is stateless and suitable for horizontal scaling.

### Using Helm Chart

Enable auto-scaling in the Helm chart values:

```bash
helm install ultipa ./ultipa-helm-chart \
  --set nameServer.autoscaling.enabled=true \
  --set nameServer.autoscaling.minReplicas=2 \
  --set nameServer.autoscaling.maxReplicas=10
```

| <div table-width="50">Parameter</div> | Default | Description |
| -- | -- | -- |
| `nameServer.autoscaling.enabled` | `false` | Enables HPA for the Name Server. |
| `nameServer.autoscaling.minReplicas` | `2` | Minimum number of Name Server replicas. |
| `nameServer.autoscaling.maxReplicas` | `10` | Maximum number of Name Server replicas. |
| `nameServer.autoscaling.targetCPUUtilizationPercentage` | `70` | CPU utilization target for scaling. |
| `nameServer.autoscaling.targetMemoryUtilizationPercentage` | `80` | Memory utilization target for scaling. |

When auto-scaling is enabled, the Deployment's `replicas` field is omitted and managed by the HPA.

### Using the Operator CRD

Add the `autoScaling` field to the `nameServer` spec:

```yaml
apiVersion: ultipa.com/v1alpha1
kind: UltipaCluster
metadata:
  name: my-cluster
spec:
  nameServer:
    autoScaling:
      enabled: true
      minReplicas: 2
      maxReplicas: 10
      targetCPUPercent: 70
      targetMemoryPercent: 80
```

### KEDA Integration

For custom metric-based scaling, Ultipa supports KEDA (Kubernetes Event-Driven Autoscaling) using the `ultipa_query_queue_depth` Prometheus metric:

```yaml
# values.yaml
nameServer:
  autoscaling:
    customMetrics:
      enabled: true
      prometheusAddress: "http://prometheus:9090"
      activeQueriesPerReplica: 50
```

> HPA and KEDA are mutually exclusive. Enable only one at a time.

### Graceful Scale-Down

When a Name Server pod is terminated:

1. Kubernetes sends SIGTERM to the pod.
2. The Name Server stops accepting new connections.
3. In-flight queries complete (up to timeout).
4. The pod terminates cleanly.

## Limitations

- No automated backup CRD; use `CREATE BACKUP` via GQL manually.
- No certificate rotation automation.
- Rolling upgrades use the `RollingUpdate` strategy.
