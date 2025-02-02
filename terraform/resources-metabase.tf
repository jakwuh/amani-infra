locals {
  metabase_values = {
    "MB_DB_TYPE" = "postgres",
    "MB_DB_PORT" = "5432",
    "MB_DB_USER" = onepassword_item.postgres.username,
    "MB_DB_PASS" = onepassword_item.postgres.password,
    "MB_DB_HOST" = local.postgres_host,
    "MB_DB_DBNAME" = local.postgres_databases.metabase
  }
}

resource "kubernetes_namespace" "metabase" {
  metadata {
    name = "metabase-ns"
  }
}

resource "kubernetes_deployment" "metabase" {
  depends_on = [kubernetes_namespace.metabase, helm_release.postgresql]
  metadata {
    name      = "metabase-deployment"
    namespace = kubernetes_namespace.metabase.metadata.0.name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "metabase"
      }
    }

    template {
      metadata {
        labels = {
          app = "metabase"
        }
      }

      spec {
        container {
          image = "metabase/metabase:latest"
          name  = "metabase"

          port {
            container_port = 3000
          }

          dynamic "env" {
            for_each = local.metabase_values
            content {
              name  = env.key
              value = env.value
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "metabase" {
  metadata {
    name      = "metabase-service"
    namespace = kubernetes_namespace.metabase.metadata.0.name
  }

  spec {
    type = "NodePort"

    port {
      port        = 3000
      target_port = 3000
      protocol    = "TCP"
    }

    selector = {
      app = "metabase"
    }
  }
}