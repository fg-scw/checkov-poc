resource "scaleway_instance_security_group" "web_public" {
  name                    = "${var.project_name}-web-public"
  description             = "SG front web"
  zone                    = var.zone
  inbound_default_policy  = "drop"
  outbound_default_policy = "accept"
  stateful                = true
  enable_default_security = false
  tags                    = concat([var.project_name, "web", var.environment], var.tags)

  dynamic "inbound_rule" {
    for_each = var.allowed_ssh_cidrs
    content {
      action   = "accept"
      protocol = "TCP"
      port     = 22
      ip_range = inbound_rule.value
    }
  }

  inbound_rule {
    action   = "accept"
    protocol = "TCP"
    port     = 80
    ip_range = "0.0.0.0/0"
  }

  inbound_rule {
    action   = "accept"
    protocol = "TCP"
    port     = 443
    ip_range = "0.0.0.0/0"
  }
}

resource "scaleway_instance_security_group" "database" {
  name                    = "${var.project_name}-db"
  description             = "SG base de données"
  zone                    = var.zone
  inbound_default_policy  = "drop"
  outbound_default_policy = "accept"
  stateful                = true
  tags                    = concat([var.project_name, "db", var.environment], var.tags)

  # Autorise le /22 du réseau applicatif
  inbound_rule {
    action   = "accept"
    protocol = "TCP"
    port     = 5432
    ip_range = "10.0.0.0/22"
  }
}
