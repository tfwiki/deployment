terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.90.0"
    }
  }
}

data "google_container_engine_versions" "supported" {
  location       = var.google_zone
  version_prefix = var.kubernetes_version
}

resource "google_container_cluster" "default" {
  name               = var.cluster_name
  location           = var.google_zone
  min_master_version = data.google_container_engine_versions.supported.latest_master_version
  # node version must match master version
  # https://www.terraform.io/docs/providers/google/r/container_cluster.html#node_version
  node_version       = data.google_container_engine_versions.supported.latest_master_version
  initial_node_count = 0

  resource_labels = {
    "env" = var.env_label
  }
}
resource "google_container_node_pool" "highcpu" {
  name    = "high-cpu-pool"
  cluster = var.cluster_name

  node_locations = [
    var.google_zone
  ]

  node_config {
    machine_type = var.machine_type

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/service.management",
      "https://www.googleapis.com/auth/servicecontrol",
    ]
  }

  autoscaling {
    max_node_count = 9
    min_node_count = 3
  }

  depends_on = [
    # Can't directly reference this for cluster_name because it'll force a
    # replacement due to diff name formats
    google_container_cluster.default
  ]
}
