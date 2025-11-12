.PHONY: help scan scan-compact scan-json scan-sarif baseline precommit-install precommit-run update-checkov scan-bad

CHECKOV := checkov
EXT_DIR := custom_checks
TFVARS ?= terraform.tfvars
TFVARS_FLAG := $(shell [ -f $(TFVARS) ] && echo "--var-file=$(TFVARS)")
EVAL ?= true

help:
	@echo "Targets:"
	@echo "  scan              - Scan CLI avec règles custom et variables évaluées"
	@echo "  scan-compact      - Scan compact"
	@echo "  scan-json         - Génère results.json"
	@echo "  scan-sarif        - Génère results.sarif"
	@echo "  baseline          - Crée/maj .checkov.baseline"
	@echo "  precommit-install - Installe pre-commit"
	@echo "  precommit-run     - Lance pre-commit sur tout"
	@echo "  update-checkov    - pip install -U checkov"
	@echo "  scan-bad          - Scan sur tests/bad (génère volontairement des erreurs)"

scan:
	$(CHECKOV) -d . --framework terraform --external-checks-dir $(EXT_DIR) \
		--evaluate-variables $(EVAL) $(TFVARS_FLAG)

scan-compact:
	$(CHECKOV) -d . --framework terraform --external-checks-dir $(EXT_DIR) \
		--compact --evaluate-variables $(EVAL) $(TFVARS_FLAG)

scan-json:
	$(CHECKOV) -d . --framework terraform --external-checks-dir $(EXT_DIR) \
		--output json --output-file-path results.json \
		--evaluate-variables $(EVAL) $(TFVARS_FLAG)

scan-sarif:
	$(CHECKOV) -d . --framework terraform --external-checks-dir $(EXT_DIR) \
		--output sarif --output-file-path results.sarif \
		--evaluate-variables $(EVAL) $(TFVARS_FLAG)

baseline:
	$(CHECKOV) -d . --framework terraform --external-checks-dir $(EXT_DIR) \
		--baseline .checkov.baseline --evaluate-variables $(EVAL) $(TFVARS_FLAG)

precommit-install:
	pip install pre-commit
	pre-commit install

precommit-run:
	pre-commit run --all-files

update-checkov:
	pip install -U checkov

scan-bad:
	$(CHECKOV) -d tests/bad --framework terraform \
		--external-checks-dir $(EXT_DIR) \
		--evaluate-variables $(EVAL) $(TFVARS_FLAG)
