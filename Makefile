.PHONY: help init plan validate apply destroy fmt fmtcheck checkov checkov-json checkov-compact clean scan-all security install-checkov check-deps

TERRAFORM := terraform
CHECKOV := checkov

help: ## Aide
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

init: ## Initialiser Terraform
	$(TERRAFORM) init -upgrade

fmt: ## Formatter
	$(TERRAFORM) fmt -recursive

fmtcheck: ## Vérifier le formatage
	$(TERRAFORM) fmt -recursive -check

validate: fmt ## Valider
	$(TERRAFORM) validate

plan: ## Plan
	$(TERRAFORM) plan

apply: ## Appliquer
	$(TERRAFORM) apply -auto-approve

destroy: ## Détruire
	$(TERRAFORM) destroy -auto-approve

checkov: ## Scan Checkov
	$(CHECKOV) -d . --framework terraform --download-external-modules false

checkov-json: ## Rapport JSON
	$(CHECKOV) -d . --framework terraform --output json --output-file-path .

checkov-compact: ## Scan compact
	$(CHECKOV) -d . --framework terraform --compact --download-external-modules false

scan-all: validate checkov ## Valider + scanner
	@echo "✅ OK"

install-checkov: ## Installer Checkov
	pip install checkov

check-deps: ## Vérifier deps
	@command -v terraform >/dev/null 2>&1 || { echo "❌ Terraform non installé"; exit 1; }
	@command -v checkov >/dev/null 2>&1 || { echo "❌ Checkov non installé"; exit 1; }

clean: ## Nettoyer
	rm -rf .terraform *.tfstate* *.lock.hcl results_*.json results_*.xml results_*.sarif
