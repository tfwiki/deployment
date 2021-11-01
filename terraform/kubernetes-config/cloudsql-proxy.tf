resource "kubernetes_service" "cloudsql_proxy" {
  metadata {
    name = "cloudsql-proxy"

    labels = {
      app = "cloudsql-proxy"
    }
  }

  spec {
    port {
      name        = "cloudsql-proxy"
      protocol    = "TCP"
      port        = 3306
      target_port = "cloudsql-proxy"
    }

    selector = {
      app = "cloudsql-proxy"
    }

    type                    = "NodePort"
    session_affinity        = "None"
    external_traffic_policy = "Cluster"
  }
}

resource "kubernetes_daemonset" "cloudsql_proxy" {
  metadata {
    name = "cloudsql-proxy"

    labels = {
      app = "cloudsql-proxy"
    }

    annotations = {
      "deprecated.daemonset.template.generation" = "0"
    }
  }

  spec {
    selector {
      match_labels = {
        app = "cloudsql-proxy"
      }
    }

    template {
      metadata {
        labels = {
          app = "cloudsql-proxy"
        }
      }

      spec {
        volume {
          name = "cloudsql-instance-credentials"

          secret {
            secret_name  = "cloudsql-instance-credentials"
            default_mode = "0644"
          }
        }

        volume {
          name = "ssl-certs"

          host_path {
            path = "/etc/ssl/certs"
          }
        }

        volume {
          name      = "cloudsql"
        }

        container {
          name    = "cloudsql-proxy"
          image   = "gcr.io/cloudsql-docker/gce-proxy:1.11"

          # TODO: Extract variables
          command = ["/cloud_sql_proxy", "--dir=/cloudsql", "-instances=tfwiki-182108:us-west1:tfwiki-production=tcp:0.0.0.0:3306", "-credential_file=/secrets/cloudsql/credentials.json"]

          port {
            name           = "cloudsql-proxy"
            container_port = 3306
            protocol       = "TCP"
          }

          resources {
            limits = {
              cpu = "1024m"

              memory = "512Mi"
            }

            requests = {
              cpu = "512m"

              memory = "128Mi"
            }
          }

          volume_mount {
            name       = "cloudsql-instance-credentials"
            read_only  = true
            mount_path = "/secrets/cloudsql"
          }

          volume_mount {
            name       = "ssl-certs"
            mount_path = "/etc/ssl/certs"
          }

          volume_mount {
            name       = "cloudsql"
            mount_path = "/cloudsql"
          }

          termination_message_path   = "/dev/termination-log"
          termination_message_policy = "File"
          image_pull_policy          = "IfNotPresent"
        }

        restart_policy                   = "Always"
        termination_grace_period_seconds = 30
        dns_policy                       = "ClusterFirst"
      }
    }

    strategy {
      type = "RollingUpdate"
    }

    revision_history_limit = 10
  }
}

