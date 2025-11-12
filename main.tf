terraform {
  required_version = ">= 1.5.0"

  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = "~> 2.62"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

# Laisse le provider récupérer profil/identifiants depuis l'env ou ~/.config/scw/config.yaml
# pour éviter l’avertissement "Multiple variable sources".
provider "scaleway" {}
