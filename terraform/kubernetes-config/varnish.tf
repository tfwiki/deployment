resource "kubernetes_service" "varnish" {
  metadata {
    name = "varnish"
  }

  spec {
    port {
      name        = "varnish"
      protocol    = "TCP"
      port        = 80
      target_port = "varnish"
    }

    selector = {
      app = "varnish"
    }

    type                    = "NodePort"
    session_affinity        = "None"
    external_traffic_policy = "Cluster"
  }
}

resource "kubernetes_service" "all_varnish" {
  metadata {
    name = "all-varnish"
  }

  spec {
    port {
      name        = "varnish"
      protocol    = "TCP"
      port        = 80
      target_port = "varnish"
    }

    selector = {
      app = "varnish"
    }

    cluster_ip       = "None"
    type             = "ClusterIP"
    session_affinity = "None"
  }
}

resource "kubernetes_deployment" "varnish" {
  metadata {
    name = "varnish"

    labels = {
      app = "varnish"
    }
  }

  spec {
    replicas = 4

    selector {
      match_labels = {
        app = "varnish"
      }
    }

    template {
      metadata {
        name = "varnish"

        labels = {
          app = "varnish"
        }
      }

      spec {
        container {
          name  = "varnish"
          image = "tfwiki/varnish:1.0.3"

          port {
            name           = "varnish"
            container_port = 80
            protocol       = "TCP"
          }

          env {
            // TODO: Is this a another resource we can reference??
            name  = "BACKEND_HOST"
            value = "mediawiki"
          }

          resources {
            limits = {
              cpu = "1024m"

              memory = "3Gi"
            }

            requests = {
              cpu = "512m"

              memory = "2Gi"
            }
          }

          readiness_probe {
            http_get {
              path   = "/wiki/Main_Page"
              port   = "80"
              scheme = "HTTP"
            }

            timeout_seconds   = 1
            period_seconds    = 10
            success_threshold = 1
            failure_threshold = 3
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

      rolling_update {
        max_unavailable = "1"
        max_surge       = "1"
      }
    }
  }
}

