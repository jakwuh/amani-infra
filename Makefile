init:
	@cd terraform && terraform init -upgrade && terraform get

plan:
	@cd terraform && terraform plan -var-file="production.tfvars"

apply:
	@cd terraform && terraform apply -auto-approve -var-file="production.tfvars"

destroy:
	@cd terraform && terraform destroy -var-file="production.tfvars"