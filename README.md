# TF2 Wiki Kubernetes Config

This repository contains the non-sensitive Kubernetes declarations powering the Team Fortress 2 Wiki.

Secrets and credentials are managed separately in a Blackbox repository: [tfwiki/secrets](https://github.com/tfwiki/secrets)

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

Syncing files from the Valve-hosted wiki is managed via the [`media-sync`](k8s/common/media-sync.yaml) job, but needs authorised SSH keys stored within a Kubernetes secret:

```
kubectl create secret generic media-sync-secret --from-file=ssh-privatekey=/path/to/.ssh/id_rsa --from-file=ssh-publickey=/path/to/.ssh/id_rsa.pub
```