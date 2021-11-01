resource "kubernetes_service" "mcrouter" {
  metadata {
    name = "mcrouter"

    labels = {
      app = "mcrouter"
    }
  }

  spec {
    port {
      name        = "mcrouter-port"
      port        = 5000
      target_port = "mcrouter-port"
    }

    selector = {
      app = "mcrouter"
    }

    cluster_ip = "None"
  }
}

resource "kubernetes_config_map" "mcrouter" {
  metadata {
    name = "mcrouter"

    labels = {
      app = "mcrouter"
    }
  }

  data = {
    // TODO: Pull any of these from service definitions ???
    "config.json" = "{\n  \"pools\": {\n    \"A\": {\n      \"servers\": [\n        \"memcached-0.memcached.default.svc.cluster.local:11211\",\n        \"memcached-1.memcached.default.svc.cluster.local:11211\",\n        \"memcached-2.memcached.default.svc.cluster.local:11211\",\n        \"memcached-3.memcached.default.svc.cluster.local:11211\",\n        \"memcached-4.memcached.default.svc.cluster.local:11211\",\n        \"memcached-5.memcached.default.svc.cluster.local:11211\",\n        \"memcached-6.memcached.default.svc.cluster.local:11211\",\n        \"memcached-7.memcached.default.svc.cluster.local:11211\",\n        \"memcached-8.memcached.default.svc.cluster.local:11211\",\n        \"memcached-9.memcached.default.svc.cluster.local:11211\",\n      ]\n    }\n  },\n  \"route\": \"PoolRoute|A\"\n}"
  }
}

resource "kubernetes_daemonset" "mcrouter" {
  metadata {
    name = "mcrouter"

    labels = {
      app = "mcrouter"
    }
  }

  spec {
    selector {
      match_labels = {
        app = "mcrouter"
      }
    }

    template {
      metadata {
        labels = {
          app = "mcrouter"
        }
      }

      spec {
        volume {
          name = "config"

          config_map {
            name = "mcrouter"
          }
        }

        container {
          name    = "mcrouter"
          image   = "jphalip/mcrouter:0.36.0"
          command = ["mcrouter"]
          args    = ["-p 5000", "--config-file=/etc/mcrouter/config.json"]

          port {
            name           = "mcrouter-port"
            host_port      = 5000
            container_port = 5000
          }

          resources {
            limits = {
              cpu = "2"

              memory = "512Mi"
            }

            requests = {
              cpu = "1"

              memory = "128Mi"
            }
          }

          volume_mount {
            name       = "config"
            mount_path = "/etc/mcrouter"
          }

          liveness_probe {
            tcp_socket {
              port = "mcrouter-port"
            }

            initial_delay_seconds = 30
            timeout_seconds       = 5
          }

          readiness_probe {
            tcp_socket {
              port = "mcrouter-port"
            }

            initial_delay_seconds = 5
            timeout_seconds       = 1
          }

          image_pull_policy = "Always"
        }
      }
    }

    strategy {
      type = "RollingUpdate"
    }
  }
}

