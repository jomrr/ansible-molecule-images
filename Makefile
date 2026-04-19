# Makefile for ansible-molecule-images
# name: ansible-molecule-images
# file: Makefile

MAKEFLAGS	+= --no-builtin-rules
MAKEFLAGS	+= --warn-undefined-variables

SHELL		:= /bin/bash
.SHELLFLAGS	:= -euo pipefail -c

.DEFAULT_GOAL	:= help

# --- Python virtual environment -----------------------------------------------
DEPS			:= requirements.yml
REQS			:= requirements.txt
VENV			:= .venv
PIP			:= $(VENV)/bin/pip
PRE_COMMIT		:= $(VENV)/bin/pre-commit
PSR			:= $(VENV)/bin/semantic-release
# --- Ansible ------------------------------------------------------------------
GALAXY			:= $(VENV)/bin/ansible-galaxy
INVENTORY 		:= $(VENV)/bin/ansible-inventory --list --limit
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
	@echo "Usage: make <target> [LIMIT=<hostname|group>] [FEATURE=<branch-name>]"
	@echo
	@echo "Environment:"
	@echo "  LIMIT=<hostname|group>   Limit Ansible build targets (default: $(LIMIT))"
	@echo "  FEATURE=<branch-name>    Feature branch name for start-feature / merge-feature-to-dev"
	@echo
	@echo "Targets:"
	@echo "  help                  Show this help"
	@echo "  install               Create the Python virtual environment and install dependencies"
	@echo "  upgrade               Upgrade Python and Ansible dependencies in the virtual environment"
	@echo "  clean                 Remove the virtual environment and generated dependency files"
	@echo "  dist-clean            Remove the virtual environment and build artifacts"
	@echo "  mrproper              Alias for dist-clean"
	@echo
	@echo "Build:"
	@echo "  all                   Build all supported distributions"
	@echo "  <distro>              Build a specific distribution"
	@echo "  docker                Update docker repository description"
	@echo "  limit                 Build artifacts limited to LIMIT=<hostname|group>"
	@echo
	@echo "Git workflow:"
	@echo "  checkout-dev          Switch to the dev branch"
	@echo "  commit                Stage all changes and create a commit"
	@echo "  start-feature         Create a new feature branch from dev (requires FEATURE=...)"
	@echo "  merge-feature-to-dev  Merge FEATURE into dev and delete the feature branch"
	@echo
	@echo "Release workflow:"
	@echo "  prepare-release       Push dev, fast-forward merge dev into main locally, then switch back to dev"
	@echo "  version               Run semantic-release on main, then merge main back into dev"
	@echo "  publish               Upload built distribution files to an existing release on main"
	@echo "  release               Merge dev into main, run semantic-release, then merge main back into dev"
	@echo
	@echo "Supported distributions:"
	@echo "  $(distributions)"

$(DEPS):
	@echo "---" > $@
	@echo "collections:" >> $@
	@echo "  - containers.podman" >> $@
	@echo "" >> $@

$(REQS):
	@echo "ansible" > $@
	@echo "commitizen" >> $@
	@echo "pre-commit" >> $@
	@echo "python-semantic-release" >> $@

$(VENV): $(REQS) $(DEPS)
	@python3 -m venv $(VENV)
	@$(PIP) install --upgrade pip
	@$(PIP) install -r requirements.txt
	@$(GALAXY) install -r $(DEPS)
	@$(PRE_COMMIT) install --hook-type commit-msg

# --- General make targets ----------------------------------------------------

.PHONY: install
install: $(VENV)

.PHONY: upgrade
upgrade: | $(VENV)
	@$(PIP) install --upgrade pip
	@$(PIP) install --upgrade -r $(REQS)
	@$(GALAXY) install --force -r $(DEPS)

.PHONY: clean
clean:
	@rm -rf $(VENV) $(REQS) $(DEPS)

.PHONY: dist-clean mrproper
dist-clean mrproper: clean
	@rm -rf build/ dist/

# --- Ansible/Build targets ---------------------------------------------------
.PHONY: $(distributions) all docker limit

$(distributions): | $(VENV)
	@$(PLAYBOOK) playbooks/build.yml --limit=$@

all: $(distributions)

docker: | $(VENV)
	@$(PLAYBOOK) playbooks/docker.yml

limit: | $(VENV)
	@$(PLAYBOOK) playbooks/build.yml --limit=$(LIMIT)

# --- git targets -------------------------------------------------------------

# checkout the dev branch
.PHONY: checkout-dev
checkout-dev:
	@git checkout dev

# commit changes to the current branch
.PHONY: commit
commit:
	@git add .
	@git commit

# start a new feature branch
.PHONY: start-feature
start-feature:
	@git checkout -b $(FEATURE) dev

# merge a feature branch to dev
.PHONY: merge-feature-to-dev
merge-feature-to-dev:
	@git checkout dev
	@git merge $(FEATURE)
	@git branch -d $(FEATURE)

# prepare a release and merge dev to main
.PHONY: prepare-release
prepare-release:
	@git push origin dev
	@git checkout main
	@git pull --ff-only origin main
	@git merge --ff-only dev
	@git checkout dev

# bump the version number and update the changelog
.PHONY: version
version:
	@git checkout main
	@git pull --ff-only origin main
	@$(PSR) version
	@git push origin main --follow-tags
	@git checkout dev
	@git pull --ff-only origin dev
	@git merge --ff-only main
	@git push origin dev

# upload built distribution files to an existing release
.PHONY: publish
publish:
	@git checkout main
	@git pull --ff-only origin main
	@$(PSR) publish
	@git push origin main --follow-tags
	@git checkout dev

# merge dev to main and create a new release, push changes to both branches
.PHONY: release
release:
	@git checkout main
	@git pull --ff-only origin main
	@git merge --ff-only dev
	@$(PSR) version
	@git push origin main --follow-tags
	@git checkout dev
	@git pull --ff-only origin dev
	@git merge --ff-only main
	@git push origin dev
