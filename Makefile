
ENV        ?= dev
TF_DIR     := environments/$(ENV)
TF         := terraform -chdir=$(TF_DIR)
BOLD       := \033[1m
RESET      := \033[0m
GREEN      := \033[32m
YELLOW     := \033[33m
RED        := \033[31m

.PHONY: help init validate fmt lint checkov plan apply destroy output \
        bootstrap docs clean all-validate

help: ## Afficher l'aide
	@echo ""
	@echo "$(BOLD)terraform-aws-infra — Commandes disponibles$(RESET)"
	@echo ""
	@echo "$(BOLD)Usage :$(RESET) make <cible> [ENV=dev|staging|prod]"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-18s$(RESET) %s\n", $$1, $$2}'
	@echo ""

## Bootstrap 

bootstrap: ## Créer le bucket S3 et la table DynamoDB 
	@echo "$(YELLOW)▶ Bootstrap backend — saisir le nom du bucket :$(RESET)"
	@read -p "Nom du bucket : " BUCKET; \
	bash scripts/bootstrap_backend.sh $$BUCKET eu-west-3

## Terraform ─

init: ## terraform init pour ENV 
	@echo "$(YELLOW)▶ terraform init [$(ENV)]$(RESET)"
	$(TF) init

init-no-backend: ## terraform init sans backend 
	@echo "$(YELLOW)▶ terraform init -backend=false [$(ENV)]$(RESET)"
	$(TF) init -backend=false

validate: ## terraform validate pour ENV
	@echo "$(YELLOW)▶ terraform validate [$(ENV)]$(RESET)"
	$(TF) init -backend=false -input=false -upgrade
	$(TF) validate
	@echo "$(GREEN)✓ Validation réussie [$(ENV)]$(RESET)"

all-validate: ## Valider tous les environnements 
	@mkdir -p /tmp/tf-plugin-cache
	@FAILED=0; \
	for env in dev staging prod; do \
		echo "$(YELLOW)▶ Validation : $$env$(RESET)"; \
		TF_PLUGIN_CACHE_DIR=/tmp/tf-plugin-cache \
		terraform -chdir=environments/$$env init -backend=false -input=false -upgrade 2>&1 \
			| grep -E "Warning|Error|provider" || true; \
		if terraform -chdir=environments/$$env validate; then \
			echo "$(GREEN)✓ $$env OK$(RESET)"; \
		else \
			echo "$(RED)✗ $$env FAILED$(RESET)"; \
			FAILED=1; \
		fi; \
		echo ""; \
	done; \
	exit $$FAILED

fmt: ## Formater tout le code Terraform
	@echo "$(YELLOW)▶ terraform fmt$(RESET)"
	terraform fmt -recursive .
	@echo "$(GREEN)✓ Formatage terminé$(RESET)"

fmt-check: ## Vérifier le formatage (sans modifier)
	@echo "$(YELLOW)▶ terraform fmt -check$(RESET)"
	terraform fmt -check -recursive .

plan: ## terraform plan pour ENV
	@echo "$(YELLOW)▶ terraform plan [$(ENV)]$(RESET)"
	$(TF) plan -out=$(TF_DIR)/tfplan

apply: ## terraform apply pour ENV
	@echo "$(RED)▶ terraform apply [$(ENV)] — DÉPLOIEMENT RÉEL$(RESET)"
	@read -p "Confirmer le déploiement sur $(ENV) ? (oui) : " OK; \
	[[ "$$OK" == "oui" ]] && $(TF) apply $(TF_DIR)/tfplan || echo "Annulé."

destroy: ## terraform destroy pour ENV
	@echo "$(RED)▶ terraform destroy [$(ENV)] — SUPPRESSION DE L'INFRA$(RESET)"
	@read -p "Confirmer la destruction sur $(ENV) ? (oui) : " OK; \
	[[ "$$OK" == "oui" ]] && $(TF) destroy || echo "Annulé."

output: ## Afficher les outputs Terraform pour ENV
	@echo "$(YELLOW)▶ terraform output [$(ENV)]$(RESET)"
	$(TF) output

##  Qualité & Sécurité 

lint: ## Lancer TFLint sur tous les modules et environnements
	@echo "$(YELLOW)▶ TFLint$(RESET)"
	@for dir in modules/vpc modules/ec2 modules/security \
	            environments/dev environments/staging environments/prod; do \
		echo "  → $$dir"; \
		tflint --chdir=$$dir || true; \
	done
	@echo "$(GREEN)✓ Lint terminé$(RESET)"

checkov: ## Scanner la sécurité IaC avec Checkov (sans AWS)
	@echo "$(YELLOW)▶ Checkov security scan$(RESET)"
	checkov -d . --framework terraform --quiet
	@echo "$(GREEN)✓ Checkov terminé$(RESET)"

## Documentation 

docs: ## Générer la documentation avec terraform-docs
	@echo "$(YELLOW)▶ terraform-docs$(RESET)"
	@for mod in modules/vpc modules/ec2 modules/security; do \
		echo "  → $$mod"; \
		terraform-docs markdown table --output-file README.md --output-mode inject $$mod; \
	done
	@echo "$(GREEN)✓ Documentation générée$(RESET)"

## Utilitaires 

clean: ## Nettoyer les fichiers temporaires Terraform
	@echo "$(YELLOW)▶ Nettoyage$(RESET)"
	find . -name ".terraform" -type d -exec rm -rf {} + 2>/dev/null || true
	find . -name "tfplan"     -type f -delete 2>/dev/null || true
	find . -name "*.tfstate"  -type f -delete 2>/dev/null || true
	find . -name "crash.log"  -type f -delete 2>/dev/null || true
	@echo "$(GREEN)✓ Nettoyage terminé$(RESET)"

install-tools: ## Installer les outils locaux 
	@echo "$(YELLOW)▶ Installation des outils$(RESET)"
	pip install checkov pre-commit detect-secrets --break-system-packages 2>/dev/null || \
	pip3 install checkov pre-commit detect-secrets
	curl -Lo /tmp/tflint.zip https://github.com/terraform-linters/tflint/releases/latest/download/tflint_linux_amd64.zip
	unzip -o /tmp/tflint.zip -d /usr/local/bin/
	curl -Lo /tmp/terraform-docs.tar.gz \
  		https://github.com/terraform-docs/terraform-docs/releases/latest/download/terraform-docs-v0.24.0-linux-amd64.tar.gz

	tar -xzf /tmp/terraform-docs.tar.gz -C /tmp

	mv /tmp/terraform-docs /usr/local/bin/

	chmod +x /usr/local/bin/terraform-docs
	chmod +x /usr/local/bin/tflint /usr/local/bin/terraform-docs
	pre-commit install
	@echo "$(GREEN)✓ Outils installés$(RESET)"
