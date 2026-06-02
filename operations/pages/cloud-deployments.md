# Cloud Deployments

GQLDB has two cloud-side delivery paths:

| Path | Where | How it bills |
| -- | -- | -- |
| **Ultipa Cloud (DBaaS)** | <a href="https://dbaas.ultipa.com" target="_blank">dbaas.ultipa.com</a> | Pay-as-you-go via Ultipa |
| **AWS Marketplace** | The GQLDB listing in <a href="https://aws.amazon.com/marketplace/pp/prodview-sdmrcp4vtew5m?applicationId=AWSMPContessa&ref_=beagle&sr=0-1" target="_blank">AWS Marketplace</a> | Through your AWS account (pay-as-you-go) | 

## What the Platform Handles

| Concern | Self-hosted | Ultipa Cloud |
| -- | -- | -- |
| Install & upgrade | You run the install script, replace executables for upgrades. | Ultipa pushes server updates; rolling upgrades on HA tiers. |
| Sizing & topology | You pick host size, single-node vs HA shape. | Pick a tier in the portal; HA is implicit at production tiers. |
| Backups | You schedule `BACKUP` jobs and rotate files. | Automated periodic backups; restore from the portal. |
| Monitoring | You wire up logs, metrics, alerts. | Built-in metrics dashboard; alerts configurable per project. |
| RBAC | You run `ALTER USER` and `GRANT`. | Initial admin user provisioned at instance creation; further RBAC is the same GQL you'd write self-hosted. |