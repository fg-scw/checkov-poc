resource "scaleway_rdb_instance" "pg" {
  name                = "bad-pg"
  engine              = "PostgreSQL-15"
  node_type           = "DB-DEV-S"
  is_ha_cluster       = false
  user_name           = "app"
  password            = "Ch@ngeMe-123"

  encryption_at_rest  = false
  disable_backup      = true
}
