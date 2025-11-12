variable "zone" {
  description = "Scaleway zone"
  type        = string
  default     = "fr-par-2"
}

variable "region" {
  description = "Scaleway region"
  type        = string
  default     = "fr-par"
}

variable "project_name" {
  description = "Nom du projet"
  type        = string
  default     = "checkov-test"
}

variable "environment" {
  description = "Environnement (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "ssh_public_key" {
  description = "Clé publique SSH (format authorized_keys)"
  type        = string
}

variable "allowed_ssh_cidrs" {
  description = "CIDR(s) autorisés pour SSH"
  type        = list(string)
  default     = ["192.0.2.0/24"]
}

variable "lb_domain" {
  description = "Nom de domaine pour le LB (Let's Encrypt)"
  type        = string
  default     = "example.com"
}

variable "lets_encrypt_email" {
  description = "Adresse email pour ACME/Let's Encrypt (facultatif côté API LB)"
  type        = string
  default     = "admin@example.com"
}

variable "db_name" {
  description = "Nom de la base (RDB)"
  type        = string
  default     = "app"
}

variable "db_username" {
  description = "Utilisateur admin RDB"
  type        = string
  default     = "app_admin"
}

variable "tags" {
  description = "Tags communs"
  type        = list(string)
  default     = []
}

variable "enable_acme" {
  description = "Provisionner le certificat Let's Encrypt (nécessite que le DNS pointe déjà sur l'IP publique du LB)"
  type        = bool
  default     = false
}
