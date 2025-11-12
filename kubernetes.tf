resource "scaleway_k8s_cluster" "main" {
  name                        = "${var.project_name}-k8s"
  version                     = "1.34"
  cni                         = "cilium"
  region                      = var.region
  tags                        = concat([var.project_name, "k8s", var.environment], var.tags)
  private_network_id          = scaleway_vpc_private_network.app_network.id
  delete_additional_resources = true

  auto_upgrade {
    enable                        = true
    maintenance_window_start_hour = 3
    maintenance_window_day        = "monday"
  }

  #admission_plugins = ["PodSecurityPolicy", "NodeRestriction"]
}

resource "scaleway_k8s_pool" "pool" {
  cluster_id  = scaleway_k8s_cluster.main.id
  name        = "play2-pico-pool"
  node_type   = "PLAY2-NANO"
  size        = 2
  min_size    = 1
  max_size    = 5
  autoscaling = true
  autohealing = true
  zone        = var.zone
  tags        = concat([var.project_name, "k8s", "pool", var.environment], var.tags)
}
