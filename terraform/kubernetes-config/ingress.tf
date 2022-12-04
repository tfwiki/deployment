resource "kubernetes_ingress" "prod_ingress" {
  metadata {
    name = "prod-ingress"

    annotations = {
      "acme.cert-manager.io/http01-edit-in-place" = "true"
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
      "kubernetes.io/ingress.class" = "gce"

      // TODO: Extract variable(s)
      "kubernetes.io/ingress.global-static-ip-name" = "tfwiki-production-static-ip"
    }
  }

  spec {
    backend {
      // TODO: Pull from service resource
      service_name = "varnish"
      service_port = "varnish"
    }

    tls {
      // TODO: Extract variable(s)
      hosts       = ["wiki.teamfortress.com", "wiki.tf2.com", "prod.wiki.tf"]
      secret_name = "prod-tls"
    }
  }
}

