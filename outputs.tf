# IP publique du front
output "instance_public_ips" {
  description = "IP publique du front"
  value = {
    web_server = scaleway_instance_ip.web_public.address
  }
}

# Endpoint privé de la base (IP/port) via le bloc private_network
# endpoint_ip est déprécié : on utilise l’endpoint privé du RDB. :contentReference[oaicite:5]{index=5}
output "database_private_endpoint" {
  description = "Endpoint privé PostgreSQL"
  value = {
    host = scaleway_rdb_instance.postgres.private_network[0].ip
    port = scaleway_rdb_instance.postgres.private_network[0].port
  }
}

output "database_password" {
  description = "Mot de passe admin DB"
  value       = random_password.db_password.result
  sensitive   = true
}

output "lb_public_ip" {
  description = "IP publique du LB"
  value       = scaleway_lb_ip.main.ip_address
}
