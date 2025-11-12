resource "scaleway_lb_ip" "main" {
  zone = var.zone
  tags = concat([var.project_name, var.environment], var.tags)
}

resource "scaleway_lb" "web_lb" {
  name        = "${var.project_name}-web-lb"
  type        = "LB-S"
  ip_ids      = [scaleway_lb_ip.main.id] # remplace l'attribut déprécié ip_id
  zone        = var.zone
  description = "LB HTTPS"
  tags        = concat([var.project_name, "lb", var.environment], var.tags)

  # Attache le LB au réseau privé applicatif
  private_network {
    private_network_id = scaleway_vpc_private_network.app_network.id
    # ipam_ids = [scaleway_ipam_ip.lb_pn_ip.id] # optionnel si vous réservez une IP privée précise
  }
}

# Certificat ACME uniquement si activé (et DNS déjà pointé vers l'IP du LB)
resource "scaleway_lb_certificate" "lets_encrypt" {
  count = var.enable_acme ? 1 : 0

  lb_id = scaleway_lb.web_lb.id
  name  = "le-${var.lb_domain}"

  letsencrypt {
    common_name = var.lb_domain
  }
}

resource "scaleway_lb_backend" "web_backend" {
  lb_id            = scaleway_lb.web_lb.id
  name             = "web-backend"
  forward_protocol = "http"
  forward_port     = 80

  # Pour sticky "cookie", un nom de cookie est requis
  sticky_sessions             = "cookie"
  sticky_sessions_cookie_name = "SRV"

  health_check_http {
    uri = "/healthz"
  }

  # IP privée de l’instance (string)
  server_ips = [
    scaleway_instance_server.web_server.private_ips[0].address
  ]
}

resource "scaleway_lb_frontend" "http" {
  lb_id        = scaleway_lb.web_lb.id
  name         = "http"
  inbound_port = 80
  backend_id   = scaleway_lb_backend.web_backend.id
}

# Frontend HTTPS créé uniquement si ACME est activé et le certificat existe
resource "scaleway_lb_frontend" "https" {
  count = var.enable_acme ? 1 : 0

  lb_id           = scaleway_lb.web_lb.id
  name            = "https"
  inbound_port    = 443
  backend_id      = scaleway_lb_backend.web_backend.id
  certificate_ids = [scaleway_lb_certificate.lets_encrypt[0].id]
  enable_http3    = true
}
