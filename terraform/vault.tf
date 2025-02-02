data "onepassword_item" "digitalocean_token" {
  vault = var.onepassword_vault_uuid
  title  = "digitalocean_token"
}

data "onepassword_item" "airbyte" {
  vault = var.onepassword_vault_uuid
  title  = "airbyte"
}

resource "onepassword_item" "postgres" {
  vault = var.onepassword_vault_uuid

  title    = "postgres"
  category = "login"

  username = var.project_name

  password_recipe {
    length  = 20
    symbols = false
  }
}