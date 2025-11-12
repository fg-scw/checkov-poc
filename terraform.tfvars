# Exemple - NE PAS COMMIT des secrets réels
zone         = "fr-par-2"
region       = "fr-par"
project_name = "checkov-test"
environment  = "dev"

ssh_public_key    = "ssh-rsa aAU= fg@MBP.local"
allowed_ssh_cidrs = ["2.42.32.13/32"]

lb_domain          = "fgz.sa-scw.fr"
lets_encrypt_email = "testn@example.com"

db_name     = "app"
db_username = "app_admin"
