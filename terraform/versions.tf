terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.6.1"
    }

    google = {
      source  = "hashicorp/google"
      version = "3.90.0"
    }
  }

  required_version = ">= 1.0.10"
}
