resource "digitalocean_kubernetes_cluster" "default_cluster" {
  name   = "k8s-${var.project_name}-tf"
  region = var.region
  version = var.cluster_version
  auto_upgrade = true
  node_pool {
    name       = "${var.project_name}-default-pool"
    size       = var.default_node_size
    auto_scale = true
    min_nodes  = var.min_node_count
    max_nodes  = var.max_node_count
  }
}