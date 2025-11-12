resource "scaleway_lb" "web" {
  name   = "lb-bad"
  type   = "LB-S"
  zone   = "fr-par-1"
}

resource "scaleway_lb_backend" "web_be" {
  lb_id            = scaleway_lb.web.id
  name             = "web-be"
  forward_protocol = "http"
  forward_port     = 80
  sticky_sessions  = "cookie"
}

resource "scaleway_lb_frontend" "https" {
  lb_id        = scaleway_lb.web.id
  name         = "https"
  inbound_port = 443
  backend_id   = scaleway_lb_backend.web_be.id
}
