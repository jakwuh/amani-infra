variable "project_name" {
  description = "The name of the project. Used for resources naming"
  type        = string
}

variable "onepassword_token" {
  description = "The service account token of 1Password vault"
  type = string
}

variable "onepassword_vault_uuid" {
    description = "1password vault uuid with all password"
    type = string
}

variable cluster_version {
  description = "The version of the kubernetes cluster to create"
  type        = string
}

variable region {
  description = "The digital ocean region slug for where to create resources"
  type        = string
  default     = "tor1"
}

variable min_node_count {
  description = "The minimum number of nodes in the default pool"
  type        = number
}

variable max_node_count {
  description = "The maximum number of nodes in the default pool"
  type        = number
}

variable default_node_size {
  description = "The default digital ocean node slug for each node in the default pool"
  type        = string
  default     = "s-1vcpu-2gb"
}

# variable top_level_domains {
#   description = "Top level domains to create records and pods for"
#   type    = list(string)
# }

# variable letsencrypt_email {
#   type = string
# }