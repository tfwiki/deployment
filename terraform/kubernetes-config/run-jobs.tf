resource "kubernetes_deployment" "run_jobs" {
  metadata {
    name = "run-jobs"

    labels = {
      app = "run-jobs"
    }
  }

  spec {
    replicas = 4

    selector {
      match_labels = {
        app = "run-jobs"
      }
    }

    template {
      metadata {
        labels = {
          app = "run-jobs"
        }
      }

      spec {
        volume {
          name = "mediawiki-images"

          persistent_volume_claim {
            # TODO: Pull from relevant resource?
            claim_name = "tfwiki-media-prod-claim"
          }
        }

        # Reuse env definitions across all mediawiki resources?
        container {
          name    = "run-jobs"
          image   = "tfwiki/mediawiki:1.31-tfwiki4"
          command = ["php", "/var/www/html/w/maintenance/runJobs.php", "--wait", "--procs 1", "--maxjobs 100"]

          env {
            name = "NODE_NAME"

            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }

          env {
            name  = "MEMCACHED_HOST"
            value = "$(NODE_NAME):5001"
          }

          env {
            name = "SERVER_URL"

            value_from {
              config_map_key_ref {
                name = "mediawiki-config"
                key  = "server_url"
              }
            }
          }

          env {
            name = "SITENAME"

            value_from {
              config_map_key_ref {
                name     = "mediawiki-config"
                key      = "sitename"
                optional = true
              }
            }
          }

          env {
            name = "VARNISH_HOST"

            value_from {
              config_map_key_ref {
                name     = "mediawiki-config"
                key      = "varnish_host"
                optional = true
              }
            }
          }

          env {
            name = "TRUSTED_PROXIES"

            value_from {
              config_map_key_ref {
                name     = "mediawiki-config"
                key      = "trusted_proxies"
                optional = true
              }
            }
          }

          env {
            name = "BLACKFIRE_SOCKET"

            value_from {
              config_map_key_ref {
                name     = "mediawiki-config"
                key      = "blackfire_socket"
                optional = true
              }
            }
          }

          env {
            name = "RECAPTCHA_KEY"

            value_from {
              secret_key_ref {
                name = "mediawiki-secret"
                key  = "recaptcha.key"
              }
            }
          }

          env {
            name = "RECAPTCHA_SECRET"

            value_from {
              secret_key_ref {
                name = "mediawiki-secret"
                key  = "recaptcha.secret"
              }
            }
          }

          env {
            name = "EMAIL_EMERGENCY_CONTACT"

            value_from {
              secret_key_ref {
                name     = "mediawiki-secret"
                key      = "email.emergency_contact"
                optional = true
              }
            }
          }

          env {
            name = "EMAIL_PASSWORD_SENDER"

            value_from {
              secret_key_ref {
                name     = "mediawiki-secret"
                key      = "email.password_sender"
                optional = true
              }
            }
          }

          env {
            name = "SENTRY_DSN"

            value_from {
              secret_key_ref {
                name     = "mediawiki-secret"
                key      = "sentry.dsn"
                optional = true
              }
            }
          }

          env {
            name = "SMTP_HOST"

            value_from {
              secret_key_ref {
                name     = "mediawiki-secret"
                key      = "smtp.host"
                optional = true
              }
            }
          }

          env {
            name = "SMTP_IDHOST"

            value_from {
              secret_key_ref {
                name     = "mediawiki-secret"
                key      = "smtp.idhost"
                optional = true
              }
            }
          }

          env {
            name = "SMTP_PORT"

            value_from {
              secret_key_ref {
                name     = "mediawiki-secret"
                key      = "smtp.port"
                optional = true
              }
            }
          }

          env {
            name = "SMTP_AUTH"

            value_from {
              secret_key_ref {
                name     = "mediawiki-secret"
                key      = "smtp.auth"
                optional = true
              }
            }
          }

          env {
            name = "SMTP_USERNAME"

            value_from {
              secret_key_ref {
                name     = "mediawiki-secret"
                key      = "smtp.username"
                optional = true
              }
            }
          }

          env {
            name = "SMTP_PASSWORD"

            value_from {
              secret_key_ref {
                name     = "mediawiki-secret"
                key      = "smtp.password"
                optional = true
              }
            }
          }

          env {
            name = "SECRET_KEY"

            value_from {
              secret_key_ref {
                name = "mediawiki-secret"
                key  = "secret_key"
              }
            }
          }

          env {
            name = "STEAM_API_KEY"

            value_from {
              secret_key_ref {
                name     = "mediawiki-secret"
                key      = "steam.api.key"
                optional = true
              }
            }
          }

          env {
            name = "DB_PASSWORD"

            value_from {
              secret_key_ref {
                name     = "mediawiki-secret"
                key      = "db.password"
                optional = true
              }
            }
          }

          env {
            name = "DB_DATABASE"

            value_from {
              secret_key_ref {
                name     = "mediawiki-secret"
                key      = "db.database"
                optional = true
              }
            }
          }

          env {
            name = "DB_HOST"

            value_from {
              secret_key_ref {
                name     = "mediawiki-secret"
                key      = "db.host"
                optional = true
              }
            }
          }

          env {
            name = "DB_TYPE"

            value_from {
              secret_key_ref {
                name     = "mediawiki-secret"
                key      = "db.type"
                optional = true
              }
            }
          }

          env {
            name = "DB_USER"

            value_from {
              secret_key_ref {
                name     = "mediawiki-secret"
                key      = "db.user"
                optional = true
              }
            }
          }

          resources {
            limits = {
              cpu = "2"

              memory = "1Gi"
            }

            requests = {
              cpu = "1"

              memory = "512Mi"
            }
          }

          volume_mount {
            name       = "mediawiki-images"
            mount_path = "/var/www/html/w/images"
            sub_path   = "prod"
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

    strategy {
      type = "RollingUpdate"

      rolling_update {
        max_unavailable = "1"
        max_surge       = "1"
      }
    }
  }
}

