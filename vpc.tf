resource "scaleway_vpc" "main" {
  name           = "${var.project_name}-vpc"
  region         = var.region
  enable_routing = true
  tags           = concat([var.project_name, var.environment], var.tags)
}

resource "scaleway_vpc_private_network" "app_network" {
  name   = "${var.project_name}-app"
  vpc_id = scaleway_vpc.main.id
  region = var.region

  # /22 requis pour Kapsule (ex: 10.0.0.0/22)
  ipv4_subnet {
    subnet = "10.0.0.0/22"
  }

  tags = concat([var.project_name, "app", var.environment], var.tags)
}

resource "scaleway_vpc_private_network" "mgmt_network" {
  name   = "${var.project_name}-mgmt"
  vpc_id = scaleway_vpc.main.id
  region = var.region

  ipv4_subnet {
    subnet = "10.0.10.0/24"
  }

  tags = concat([var.project_name, "mgmt", var.environment], var.tags)
}
