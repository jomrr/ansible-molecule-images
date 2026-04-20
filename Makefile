# Makefile for building ansible molecule container images
# repo: jomrr/ansible-molecule-images
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
ANSIBLE			:= .ansible
ANSIBLE_CFG		:= $(CURDIR)/ansible.cfg
ANSIBLE_COLLECTIONS	:= $(CURDIR)/$(ANSIBLE)/collections
GALAXY			:= $(VENV)/bin/ansible-galaxy
GALAXY_COLL_INSTALL	:= $(GALAXY) collection install --collections-path $(ANSIBLE_COLLECTIONS)
PLAYBOOK		:= $(VENV)/bin/ansible-playbook
export ANSIBLE_CONFIG	:= $(ANSIBLE_CFG)

# --- Makefile -----------------------------------------------------------------
inventory		:= $(CURDIR)/containers.yml
yq_groups		:= '.all.children | keys | .[]'
yq_variants		:= '.all.children[] | .hosts | keys | .[]'
groups			:= $(sort $(shell yq -r $(yq_groups) $(inventory)))
variants		:= $(sort $(shell yq -r $(yq_variants) $(inventory)))

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
	@echo "  install               Create python virtual environment and install all dependencies,"
	@echo "                        must run once after fresh clone or after dist-clean/mrproper"
	@echo "  upgrade               Upgrade python and ansible dependencies in the virtual environment"
	@echo "  clean                 Remove ansible environment and virtual environment"
	@echo "  dist-clean            Remove the virtual environment and build artifacts"
	@echo "  mrproper              Alias for dist-clean"
	@echo
	@echo "Build:"
	@echo "  all                   Build all supported groups/variants"
	@echo "  <group>               Build a specific group of variants (e.g. 'fedora' or 'debian')"
	@echo "  <variant>             Build a specific variant (e.g. 'fedora-44' or 'debian-13')"
	@echo "  dockerhub             Update docker repository description"
	@echo "  prune                 Prune local podman images"
	@echo "  prune-all             Prune all local podman images"
	@echo
	@echo "Git workflow:"
	@echo "  checkout-dev          Switch to the dev branch and pull the latest changes"
	@echo "  checkout-main         Switch to the main branch and pull the latest changes"
	@echo "  start-feature         Create a new feature branch from dev (requires FEATURE=...)"
	@echo "  merge-feature-to-dev  Merge FEATURE into dev and delete the feature branch"
	@echo
	@echo "Release workflow:"
	@echo "  prepare-release       Push dev, fast-forward merge dev into main and push to origin, then switch back to dev"
	@echo "  release               Merge dev into main, run semantic-release, then merge main back into dev"
	@echo
	@echo "Supported groups:"
	@echo "  $(groups)"

$(PIP):
	@python3 -m venv $(VENV)

# grouped target for python dependencies ~= one recipe builds multiple targets
$(PLAYBOOK) $(GALAXY) $(PRE_COMMIT) $(PSR) &: $(REQ_TXT) | $(PIP)
	@$(PIP) install --upgrade pip
	@$(PIP) install -r $(REQ_TXT)

.PHONY: ansible-deps
ansible-deps: $(REQ_YML) | $(GALAXY)
	@$(GALAXY_COLL_INSTALL) -r $(REQ_YML)

# --- General make targets ----------------------------------------------------

.PHONY: install
install: ansible-deps | $(PRE_COMMIT)
	@$(PRE_COMMIT) install --hook-type commit-msg

.PHONY: upgrade
upgrade: $(REQ_TXT) $(REQ_YML) | $(PIP)
	@$(PIP) install --upgrade pip
	@$(PIP) install --upgrade -r $(REQ_TXT)
	@$(GALAXY_COLL_INSTALL) --force -r $(REQ_YML)
	@$(PRE_COMMIT) install --hook-type commit-msg

.PHONY: prune
prune:
	@podman image prune --force

.PHONY: prune-all
prune-all:
	@podman image prune --all --force

.PHONY: clean
clean:
	@rm -rf $(ANSIBLE) $(VENV)

.PHONY: dist-clean mrproper
dist-clean mrproper: clean
	@rm -rf build/

# --- Ansible/Build targets ---------------------------------------------------

.PHONY: $(groups) $(variants)
$(groups) $(variants): | $(PLAYBOOK)
	@$(PLAYBOOK) playbooks/build.yml --limit=$@

.PHONY: all
all: $(groups)

.PHONY: dockerhub
dockerhub: | $(PLAYBOOK)
	@$(PLAYBOOK) playbooks/dockerhub.yml

# --- git targets -------------------------------------------------------------

.PHONY: check-clean-worktree
check-clean-worktree:
	@test -z "$$(git status --porcelain)" || { \
		echo "Working tree is not clean"; \
		git status --short; \
		exit 1; \
	}

# checkout branch and pull the latest changes
.PHONY: checkout-dev checkout-main
checkout-dev checkout-main: checkout-%: check-clean-worktree
	@git checkout $*
	@git pull --ff-only origin $*

# check that FEATURE variable is set for feature branch targets
.PHONY: require-feature
require-feature:
	@test -n "$(FEATURE)" || { echo "FEATURE is required"; exit 1; }

# start a new feature branch
.PHONY: start-feature
start-feature: require-feature checkout-dev
	@git checkout -b $(FEATURE)

# merge a feature branch to dev
.PHONY: merge-feature-to-dev
merge-feature-to-dev: require-feature checkout-dev
	@git merge --ff-only $(FEATURE)
	@git branch -d $(FEATURE)

# prepare a release and merge dev to main
.PHONY: prepare-release
prepare-release: checkout-dev
	@git push origin dev
	@git checkout main
	@git pull --ff-only origin main
	@git merge --ff-only dev
	@git push origin main
	@git checkout dev

# merge dev to main and create a new release, push changes to both branches
.PHONY: release
release: checkout-main | $(PSR)
	@git fetch origin dev
	@git merge --ff-only origin/dev
	@$(PSR) version
	@git push origin main --follow-tags
	@git checkout dev
	@git pull --ff-only origin dev
	@git merge --ff-only main
	@git push origin dev
