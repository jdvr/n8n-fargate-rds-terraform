.PHONY: init plan apply verify_vars

verify_vars:
	@if [ ! -f "terraform.tfvars" ]; then \
		echo "Create terraform.tfvars, use sample.tfvars as an inspiration"; \
		exit 1; \
	fi

init: verify_vars
	terraform init

plan: verify_vars
	terraform plan 

apply: verify_vars
	terraform apply

