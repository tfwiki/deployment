resource "kubernetes_service" "memcached" {
  metadata {
    name = "memcached"

    labels = {
      app = "memcached"
    }
  }

  spec {
    port {
      name        = "memcached"
      protocol    = "TCP"
      port        = 11211
      target_port = "memcached"
    }

    selector = {
      app = "memcached"
    }

    cluster_ip       = "None"
    type             = "ClusterIP"
    session_affinity = "None"
  }
}

resource "kubernetes_stateful_set" "memcached" {
  metadata {
    name = "memcached"

    labels = {
      app = "memcached"
    }
  }

  spec {
    replicas = 10

    selector {
      match_labels = {
        app = "memcached"
      }
    }

    template {
      metadata {
        labels = {
          app = "memcached"
        }
      }

      spec {
        container {
          name    = "memcached"
          image   = "memcached:latest"
          command = ["memcached", "-m 1024", "-c 10000"]

          port {
            name           = "memcached"
            container_port = 11211
            protocol       = "TCP"
          }

          resources {
            requests = {
              cpu = "100m"

              memory = "1Gi"
            }
          }

          liveness_probe {
            tcp_socket {
              port = "memcached"
            }

            initial_delay_seconds = 30
            timeout_seconds       = 5
            period_seconds        = 10
            success_threshold     = 1
            failure_threshold     = 3
          }

          readiness_probe {
            tcp_socket {
              port = "memcached"
            }

            initial_delay_seconds = 5
            timeout_seconds       = 1
            period_seconds        = 10
            success_threshold     = 1
            failure_threshold     = 3
          }

          termination_message_path   = "/dev/termination-log"
          termination_message_policy = "File"
          image_pull_policy          = "Always"
        }

        restart_policy                   = "Always"
        termination_grace_period_seconds = 30
        dns_policy                       = "ClusterFirst"
      }
    }

    service_name          = "memcached"
    pod_management_policy = "OrderedReady"

    update_strategy {
      type = "OnDelete"
    }

    revision_history_limit = 10
  }
}

