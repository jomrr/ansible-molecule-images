# Makefile for ansible-molecule-images
# name: ansible-molecule-images
# file: Makefile

# --- Python virtual environment -----------------------------------------------
DEPS			:= requirements.yml
REQS			:= requirements.txt
VENV			:= .venv
PIP				:= $(VENV)/bin/pip
# --- Ansible ------------------------------------------------------------------
GALAXY			:= $(VENV)/bin/ansible-galaxy
INVENTORY 		:= $(VENV)/bin/ansible-inventory --list  --limit
PLAYBOOK		:= $(VENV)/bin/ansible-playbook
# --- Makefile -----------------------------------------------------------------
LIMIT			?= fedora
# no autocomplete for dynamic targets ... :(
#distributions		:= $(shell $(INVENTORY) | jq -r 'keys[] | \
#	select(. != "_meta" and . != "all") | @sh' | tr -d "'" | tr '\n' ' ')
# list of all supported distributions
distributions	:= \
	almalinux \
	alpine \
	amazonlinux \
	archlinux \
	debian \
	fedora \
	opensuse \
	oraclelinux \
	ubuntu

# --- Python virtual environment and general make targets ----------------------

# default target
.PHONY: help

help:
	@echo "Usage: make [target] [LIMIT=<hostname or group>]"
	@echo
	@echo "Targets:"
	@echo "  all        - build all distributions"
	@echo "  clean      - remove virtual environment"
	@echo "  dist-clean - remove virtual environment and build artifacts"
	@echo "  install    - create virtual environment"
	@echo "  limit      - build artifacts limited to LIMIT parameter"
	@echo "  upgrade    - update requirements in virtual environment"
	@echo "  <distro>   - build specific distribution"
	@echo
	@echo "Supported distributions:"
	@echo "  $(distributions)"

$(DEPS):
	@echo "---" > $@
	@echo "collections:" >> $@
	@echo "  - containers.podman" >> $@
	@echo "" >> $@

$(REQS):
	@echo "ansible >= 2.15" > $@
	@echo "commitizen" >> $@
	@echo "pre-commit" >> $@
	@echo "python-semantic-release" >> $@

$(VENV): $(REQS) $(DEPS)
	@python3 -m venv $(VENV)
	@$(PIP) install --upgrade pip
	@$(PIP) install -r requirements.txt
	@$(GALAXY) install -r $(DEPS)
	@pre-commit install --hook-type commit-msg

.PHONY: install upgrade clean dist-clean

install: $(VENV)

upgrade: $(REQS)
	@$(PIP) install --upgrade pip
	@$(PIP) install --upgrade -r $(REQS)
	@$(GALAXY) install --force -r $(DEPS)

clean:
	@rm -rf $(VENV) $(REQS)

dist-clean: clean
	@rm -rf build/ dist/

# --- Ansible/Build targets ----------------------------------------------------
.PHONY: $(distributions) all limit

$(distributions): $(VENV)
	@$(PLAYBOOK) playbooks/build.yml --limit=$@

all: $(distributions)

limit: $(VENV)
	@$(PLAYBOOK) playbooks/build.yml --limit=$(LIMIT)

# --- git targets --------------------------------------------------------------
.PHONY: checkout-dev commit start-feature merge-feature-to-dev prepare-release

# checkout the dev branch
checkout-dev:
	@git checkout dev

# commit changes to the current branch
commit:
	@git add .
	@git commit

# start a new feature branch
start-feature:
	@git checkout -b $(FEATURE) dev

# merge a feature branch to dev
merge-feature-to-dev:
	@git checkout dev
	@git merge $(FEATURE)
	@git branch -d $(FEATURE)

# prepare a release and merge dev to main
prepare-release:
	@git push origin dev
	@git checkout main
	@git merge dev
	@git push origin main
	@git checkout dev

# bump the version number and update the changelog
version:
	@git checkout main
	@semantic-release version
	@git checkout dev
	@git merge main

# create a new Git tag and build the distribution files
publish:
	@git checkout main
	@semantic-release publish
	@git push origin main --tags
	@git checkout dev
