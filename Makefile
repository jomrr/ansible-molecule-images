# Makefile for ansible-molecule-images
# name: ansible-molecule-images
# file: Makefile

MAKEFLAGS	+= --no-builtin-rules
MAKEFLAGS	+= --warn-undefined-variables

SHELL		:= /bin/bash
.SHELLFLAGS	:= -euo pipefail -c

.DEFAULT_GOAL	:= help

# --- Python virtual environment -----------------------------------------------
REQ_TXT			:= requirements.txt
REQ_YML			:= requirements.yml
VENV			:= .venv
PIP			:= $(VENV)/bin/pip
PRE_COMMIT		:= $(VENV)/bin/pre-commit
PSR			:= $(VENV)/bin/semantic-release
# --- Ansible ------------------------------------------------------------------
GALAXY			:= $(VENV)/bin/ansible-galaxy
PLAYBOOK		:= $(VENV)/bin/ansible-playbook
# --- Makefile -----------------------------------------------------------------
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

# --- Help and Python virtual environment targets -----------------------------

# default target
.PHONY: help
help:
	@echo "Usage: make <target> [FEATURE=<branch-name>]"
	@echo
	@echo "Environment:"
	@echo "  FEATURE=<branch-name>    Feature branch name for start-feature / merge-feature-to-dev"
	@echo
	@echo "Targets:"
	@echo "  help                  Show this help"
	@echo "  install               Create python virtual environment and install all dependencies"
	@echo "  upgrade               Upgrade python and ansible dependencies in the virtual environment"
	@echo "  clean                 Remove the virtual environment"
	@echo "  dist-clean            Remove the virtual environment and build artifacts"
	@echo "  mrproper              Alias for dist-clean"
	@echo
	@echo "Build:"
	@echo "  all                   Build all supported distributions"
	@echo "  <distro>              Build a specific distribution"
	@echo "  dockerhub             Update docker repository description"
	@echo "  prune                 Prune local podman images"
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

$(PIP):
	@python3 -m venv $(VENV)

$(PLAYBOOK) $(GALAXY) $(PRE_COMMIT) $(PSR): $(REQ_TXT) | $(PIP)
	@$(PIP) install --upgrade pip
	@$(PIP) install -r $(REQ_TXT)

.PHONY: ansible-deps
ansible-deps: $(REQ_YML) | $(GALAXY)
	@$(GALAXY) install -r $(REQ_YML)

# --- General make targets ----------------------------------------------------

.PHONY: install
install: ansible-deps
	@$(PRE_COMMIT) install --hook-type commit-msg

.PHONY: upgrade
upgrade: $(REQ_TXT) $(REQ_YML) | $(PIP)
	@$(PIP) install --upgrade pip
	@$(PIP) install --upgrade -r $(REQ_TXT)
	@$(GALAXY) install --force -r $(REQ_YML)
	@$(PRE_COMMIT) install --hook-type commit-msg

.PHONY: prune
prune:
	@podman image prune --force

.PHONY: prune-all
prune-all:
	@podman image prune --all --force

.PHONY: clean
clean:
	@rm -rf $(VENV)

.PHONY: dist-clean mrproper
dist-clean mrproper: clean
	@rm -rf build/

# --- Ansible/Build targets ---------------------------------------------------

.PHONY: $(distributions)
$(distributions): | $(PLAYBOOK)
	@$(PLAYBOOK) playbooks/build.yml --limit=$@

.PHONY: all
all: $(distributions)

.PHONY: dockerhub
dockerhub: | $(PLAYBOOK)
	@$(PLAYBOOK) playbooks/dockerhub.yml

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
	@test -n "$(FEATURE)" || { echo "FEATURE is required"; exit 1; }
	@git checkout -b $(FEATURE) dev

# merge a feature branch to dev
.PHONY: merge-feature-to-dev
merge-feature-to-dev:
	@test -n "$(FEATURE)" || { echo "FEATURE is required"; exit 1; }
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
version: | $(PSR)
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
publish: | $(PSR)
	@git checkout main
	@git pull --ff-only origin main
	@$(PSR) publish
	@git push origin main --follow-tags
	@git checkout dev

# merge dev to main and create a new release, push changes to both branches
.PHONY: release
release: | $(PSR)
	@git checkout main
	@git pull --ff-only origin main
	@git merge --ff-only dev
	@$(PSR) version
	@git push origin main --follow-tags
	@git checkout dev
	@git pull --ff-only origin dev
	@git merge --ff-only main
	@git push origin dev
