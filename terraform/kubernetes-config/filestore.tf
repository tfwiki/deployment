resource "kubernetes_persistent_volume" "tfwiki_media_prod" {
  metadata {
    name = "tfwiki-media-prod"
  }

  spec {
    capacity = {
      storage = "1T"
    }

    access_modes = ["ReadWriteMany"]

    persistent_volume_source {
      nfs {
        # TODO: extract variable(s)
        path   = "/tfwiki"
        server = "10.155.167.82"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "tfwiki_media_prod_claim" {
  metadata {
    name      = "tfwiki-media-prod-claim"
    namespace = "default"
  }

  spec {
    access_modes = ["ReadWriteMany"]

    resources {
      requests = {
        storage = "1T"
      }
    }

    volume_name = "tfwiki-media-prod"
  }
}

