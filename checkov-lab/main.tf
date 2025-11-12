terraform {
  required_version = ">= 1.5.0"
  required_providers {
    scaleway = { source = "scaleway/scaleway", version = "~> 2.62" }
  }
}
provider "scaleway" {}

# SG corrigé : SSH autorisé uniquement depuis un CIDR spécifique
resource "scaleway_instance_security_group" "bad_sg" {
  name                    = "good-sg"
  zone                    = "fr-par-2"
  inbound_default_policy  = "drop"
  outbound_default_policy = "accept"
  stateful                = true

  inbound_rule {
    action   = "accept"
    protocol = "TCP"
    port     = 22
    ip_range = "2.4.19.133/32"
  }
}

# Bucket avec versioning
resource "scaleway_object_bucket" "public_assets" {
  name   = "demo-public-assets-ckv"
  region = "fr-par"

  versioning { enabled = true }
}

# ACL privée (plus de public-read)
resource "scaleway_object_bucket_acl" "public_assets_acl" {
  bucket = scaleway_object_bucket.public_assets.name
  region = "fr-par"
  acl    = "private"
}
