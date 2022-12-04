# Terraform deployment stuffs

All the Kubernetes stuff, but in Terraform so its easier to deal with.

Resources to track/import:

- Cluster itself
  - [x] GKE cluster
  - [x] GKE node pool
- Supporting infrastructure
  - [ ] Blackfire
  - [x] Ingress
  - [ ] Cert manager ??
  - [ ] Filestore
  - [ ] CloudSQL database
  - [ ] (any other external resources?)
- Kubernetes deployments
  - [x] Cloudsql-proxy daemonset
  - [x] mcrouter daemonset
  - [x] Mediawiki deployment
  - [x] Mediawiki-update deployment
  - [x] Memcached stateful set
  - [x] Run-jobs deployment
  - [x] Update special pages cron job
  - [x] Varnish deployment
- Kubernetes services
  - [x] all-varnish
  - [x] cloudsql-proxy
  - [x] mcrouter
  - [x] mediawiki
  - [x] memcached
  - [x] nfs-server
  - [x] nfs-varnish

TODO

- Extract appropriate variables from kubernetes configs
- Replace hardcoded resource references with usage of resource attributes
- Set up remote Terraform state
