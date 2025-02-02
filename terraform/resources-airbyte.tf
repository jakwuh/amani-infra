locals {
  airbyte_values = {
    "global.airbyteUrl" = data.onepassword_item.airbyte.url
    "global.auth.enabled" = "true"
    "global.auth.instanceAdmin.secretName" = "airbyte-auth-secrets"
    "global.database.type" = "postgres"
    "global.database.host" = local.postgres_host
    "global.database.port" = "5432"
    "global.database.user" = onepassword_item.postgres.username
    "global.database.password" = onepassword_item.postgres.password
    "global.database.dbname" = local.postgres_databases.airbyte

    "global.jobs.resources.requests.cpu" = "400m"
    "global.jobs.resources.requests.memory" = "600Mi"
    "global.jobs.resources.limits.cpu" = "1"
    "global.jobs.resources.limits.memory" = "2Gi"
  }
}

resource "kubernetes_namespace" "airbyte" {
  metadata {
    name = "airbyte-ns"
  }
}

resource "random_string" "airbyte_client_id" {
  length  = 32
  special = false
}

resource "random_string" "airbyte_client_secret" {
  length  = 32
  special = false
}

resource "random_string" "airbyte_jwt_signature_secret" {
  length  = 32
  special = false
}

resource "kubernetes_secret" "airbyte-auth-secrets" {
  metadata {
    name = "airbyte-auth-secrets"
    namespace = kubernetes_namespace.airbyte.metadata[0].name
  }

  data = {
    instance-admin-email = data.onepassword_item.airbyte.username
    instance-admin-password = data.onepassword_item.airbyte.password
    instance-admin-client-id = random_string.airbyte_client_id.result
    instance-admin-client-secret = random_string.airbyte_client_secret.result
    jwt-signature-secret = random_string.airbyte_jwt_signature_secret.result
  }

  type = "Opaque"
}

resource "helm_release" "airbyte" {
  depends_on = [kubernetes_namespace.airbyte, kubernetes_secret.airbyte-auth-secrets, helm_release.postgresql]

  name       = "airbyte"
  namespace  = kubernetes_namespace.airbyte.metadata[0].name
  repository = "https://airbytehq.github.io/helm-charts"
  chart      = "airbyte"

  dynamic "set" {
    for_each = local.airbyte_values
    content {
      name  = set.key
      value = set.value
    }
  }
}