# Configure kubernetes provider with Oauth2 access token.
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config
# This fetches a new token, which will expire in 1 hour.
data "google_client_config" "default" {
  depends_on = [module.gke-cluster]
}

# Defer reading the cluster data until the GKE cluster exists.
data "google_container_cluster" "default" {
  name       = var.cluster_name
  depends_on = [module.gke-cluster]
}

module "gke-cluster" {
  source       = "./gke-cluster"
  cluster_name = var.cluster_name
  google_zone  = var.google_zone
  env_label    = var.env_label
}

module "kubernetes-config" {
  depends_on       = [module.gke-cluster]
  source           = "./kubernetes-config"
  cluster_name     = var.cluster_name
}
