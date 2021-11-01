variable "kubernetes_version" {
  default = "1.18"
}

variable "cluster_name" {
  type = string
}

variable "google_zone" {
  type = string
}

variable "machine_type" {
  type    = string
  default = "n1-highcpu-32"
}

variable "env_label" {
  type = string
}
