.PHONY: apply
apply:	agent/json
	terraform init
	terraform apply

agent/json:
	make -C agent/ json
