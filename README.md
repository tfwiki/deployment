# TF2 Wiki Kubernetes Config

This repository contains the non-sensitive Kubernetes declarations powering the Team Fortress 2 Wiki.

Secrets and credentials are managed separately in a Blackbox repository: https://github.com/tfwiki/secrets

## Existing infrastructure

### Production

Cluster | &nbsp;
---- | ----
Name | `tfwiki-production`
Location | `us-west1-a`
Machine type | `n1-standard-8` (8 vCPU; 30GB memory)
Nodes | 6

Machine type closest, memory-wise, to pre-Cloud infrastructure (24 core, 24GB memory). We can review & 
optimise once we have production performance metrics.

Static IP | &nbsp;
---- | ----
TODO | 


Disks | &nbsp;
---- | ----
TODO | 


Database | &nbsp;
---- | ----
TODO | 


### Development

Note: Scrap and re-build this environment from Production, once Production config is finalised.

Cluster | &nbsp;
---- | ----
Name | `tfwiki-development`
Location | `us-central1-a`
Machine type | `n1-standard-4` (4 vCPU; 15GB memory)
Nodes | 2

Static IP | &nbsp;
---- | ----
TODO | 


Disks | &nbsp;
---- | ----
TODO | 


Database | &nbsp;
---- | ----
TODO | 

## Spin up new environment

### Setup Cluster

TODO

### Setup database

TODO
### Setup storage

TODO
### Setup static IP

TODO
### Kubernetes configuration

TODO
### Launch 

TODO

---

Rough notes:

### Prerequisites
* Kubernetes cluster running 1.8.x (to avoid hardcoding NFS Service IP in PersistantVolume declaration)
* Cloud SQL database `cloudsql-instance-credentials` https://cloud.google.com/sql/docs/mysql/connect-kubernetes-engine
* Persistant disk for mediawiki images (mounted via NFS)
* Global Static IP address

### Task list

1. Create cluster in Google Container Engine
2. Work on correct zone (`gcloud config set compute/zone [COMPUTE-ZONE]`)
3. Log into new cluster (`gcloud container clusters get-credentials [CLUSTER-NAME]`)
4. Set up [`config.yaml`](k8s/common/config.yaml.example)
5. Set up [`secret.yaml`](k8s/common/secret.yaml.example) (see tfwiki/secrets)
6. Update [`ingress.yaml`](k8s/prod/ingress.yaml)'s `metadata.annotations.kubernetes.io/ingress.global-static-ip-name` and `spec.tls.hosts` (TODO: Generalise?)
7. Update [`nfs.yaml`](k8s/prod/nfs.yaml)'s `spec.template.spec.volumes.gcePersistentDisk` (TODO: Generalise?)
8. Update Google Cloud proxy command in [`mediawiki.yaml`](k8s/prod/mediawiki.yaml) (TODO: Generalise?)
9. Spin up! `kubectl apply -f k8s/common;kubectl apply -f k8s/ENVIRONMENT`