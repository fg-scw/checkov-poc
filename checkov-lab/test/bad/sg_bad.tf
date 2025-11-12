resource "scaleway_instance_security_group" "bad_sg" {
  name                    = "bad-sg"
  zone                    = "fr-par-1"
  inbound_default_policy  = "accept"
  outbound_default_policy = "accept"
  stateful                = false

  inbound_rule {
    action   = "accept"
    protocol = "TCP"
    port     = 22
    ip_range = "0.0.0.0/0"
  }
}
