locals {
  postgres_host = "${helm_release.postgresql.name}.${kubernetes_namespace.postgres.metadata[0].name}.svc.cluster.local"

  postgres_databases = {
    metabase = "${var.project_name}-metabase"
    airtable = "${var.project_name}-airtable"
    airbyte = "${var.project_name}-airbyte"
  }

  postgres_values = {
    "auth.username"                 = onepassword_item.postgres.username
    "auth.password"                 = onepassword_item.postgres.password
    
    "persistence.enabled"           = "true"
    "persistence.size"              = "8Gi"
    "persistence.defaultStorageClass" = "standard"

    "primary.initdb.scripts" = yamlencode({
      "create-additional-dbs.sql" = join("\n", [
        for dbkey, dbname in local.postgres_databases : <<-EOT
          CREATE DATABASE "${dbname}";
          GRANT ALL PRIVILEGES ON DATABASE "${dbname}" TO "${onepassword_item.postgres.username}";
        EOT
      ])
    })
  }
}

resource "kubernetes_namespace" "postgres" {
  metadata {
    name = "postgres-ns"
  }
}

resource "helm_release" "postgresql" {
  depends_on = [kubernetes_namespace.postgres]
  name       = "postgresql"
  namespace  = kubernetes_namespace.postgres.metadata[0].name
  repository = "oci://registry-1.docker.io/bitnamicharts"
  chart      = "postgresql"
  version    = "16.4.5" 

  dynamic "set" {
    for_each = local.postgres_values
    content {
      name  = set.key
      value = set.value
    }
  }
}
