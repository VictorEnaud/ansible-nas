SHELL := /bin/bash
.SHELLFLAGS = -ec
.SILENT:
MAKEFLAGS += --silent
.ONESHELL:
default: lint

help:
	echo -e "Please use \`make \033[36m<target>\033[0m\`"
	echo -e "👉\t where \033[36m<target>\033[0m is one of"
	grep -E '^\.PHONY: [a-zA-Z_-]+ .*?## .*$$' $(MAKEFILE_LIST) \
		| sort | awk 'BEGIN {FS = "(: |##)"}; {printf "• \033[36m%-30s\033[0m %s\n", $$2, $$3}'

.PHONY: lint ## Lint les fichiers ansible
lint:
	yamllint -c .yamllint --strict .
	ansible-lint *.yml
	conftest -p $$ANSIBLE_POLICIES_PATH test --ignore ".*.vault.yml" roles

.PHONY: ls-vault  ## Pour déchiffrer le contenu du vault
ls-vault:
	ansible-vault view ./inventories/perso/group_vars/all/all.vault.yml

.PHONY: edit-vault  ## Pour éditer le contenu du vault
edit-vault:
	ansible-vault edit ./inventories/perso/group_vars/all/all.vault.yml

.PHONY: bootstrap  ## Pour bootstrapper le raspberry
bootstrap:
	ansible-playbook -i inventories/perso/inventory playbooks/bootstrap.yml

.PHONY: deploy  ## Pour déployer le playbook avec ansible-playbook
deploy:
	if [ -z "$(TAG)" ]; then echo -e "Erreur la variable TAG n'est pas définie"; exit 1; fi
	ansible-playbook -i inventories/perso/inventory playbooks/nas.yml -t ${TAG}
