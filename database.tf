resource "random_password" "db_password" {
  length  = 24
  special = true
  upper   = true
  lower   = true
  numeric = true
}

resource "scaleway_rdb_instance" "postgres" {
  name          = "${var.project_name}-pg"
  engine        = "PostgreSQL-16"
  node_type     = "DB-PLAY2-PICO"
  is_ha_cluster = false

  user_name = var.db_username
  password  = random_password.db_password.result

  region = var.region
  tags   = concat([var.project_name, "db", var.environment], var.tags)

  volume_type       = "sbs_15k"
  volume_size_in_gb = 20

  disable_backup            = false
  backup_schedule_frequency = 24
  backup_schedule_retention = 7

  encryption_at_rest = true

  # PN avec IPAM auto
  private_network {
    pn_id       = scaleway_vpc_private_network.app_network.id
    enable_ipam = true
  }
}

resource "scaleway_rdb_database" "app" {
  instance_id = scaleway_rdb_instance.postgres.id
  name        = var.db_name
}

resource "scaleway_rdb_acl" "postgres_app_acl" {
  instance_id = scaleway_rdb_instance.postgres.id

  # Autorise le /22 du réseau applicatif
  acl_rules {
    ip          = "10.0.0.0/22"
    description = "app subnet"
  }
}
