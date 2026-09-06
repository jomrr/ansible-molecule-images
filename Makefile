# Makefile for building ansible molecule container images
# repo: jomrr/ansible-molecule-images
# file: Makefile

MAKEFLAGS	+= --no-builtin-rules
MAKEFLAGS	+= --warn-undefined-variables

SHELL		:= /bin/bash
.SHELLFLAGS	:= -euo pipefail -c

.DEFAULT_GOAL	:= help

# --- Python environment -------------------------------------------------------
PYPROJECT		:= pyproject.toml
REQ_YML			:= requirements.yml
UV			:= uv
VENV			:= .venv
PYTHON			:= $(VENV)/bin/python
COMMITIZEN		:= $(VENV)/bin/cz
PRE_COMMIT		:= $(VENV)/bin/pre-commit
PSR			:= $(VENV)/bin/semantic-release
PRE_COMMIT_CONFIG	:= .pre-commit-config.yaml
COMMIT_MSG_HOOK		:= .git/hooks/commit-msg

# --- Ansible ------------------------------------------------------------------
ANSIBLE			:= .ansible
ANSIBLE_CFG		:= $(CURDIR)/ansible.cfg
ANSIBLE_COLLECTIONS	:= $(CURDIR)/$(ANSIBLE)/collections
GALAXY			:= $(VENV)/bin/ansible-galaxy
GALAXY_COLL_INSTALL	:= $(GALAXY) collection install --collections-path $(ANSIBLE_COLLECTIONS)
PLAYBOOK		:= $(VENV)/bin/ansible-playbook
PODMAN_COLLECTION_MANIFEST	:= $(ANSIBLE_COLLECTIONS)/ansible_collections/containers/podman/MANIFEST.json
export ANSIBLE_CONFIG	:= $(ANSIBLE_CFG)

# --- Makefile -----------------------------------------------------------------
inventory		:= $(CURDIR)/containers.yml
yq_groups		:= '.all.children | keys | .[]'
yq_variants		:= '.all.children[] | .hosts | keys | .[]'
groups			:= $(sort $(shell yq -r $(yq_groups) $(inventory)))
variants		:= $(sort $(shell yq -r $(yq_variants) $(inventory)))
PUBLISH			?= false
GROUP			?=
dockerhub_filter	= $(if $(strip $(GROUP)),--extra-vars=dockerhub_filter=$(GROUP))

# --- Help and Python environment targets -------------------------------------

# default target
.PHONY: help
help:
	@echo "Usage: make <target> [FEATURE=<branch-name>] [GROUP=<group>] [PUBLISH=true]"
	@echo
	@echo "Environment:"
	@echo "  FEATURE=<branch-name> Feature branch name for start-feature / merge-feature-to-dev"
	@echo "  GROUP=<group>         Limit Docker Hub metadata or cleanup to one inventory group"
	@echo "  PUBLISH=true          Publish built images; default is build-only"
	@echo
	@echo "Targets:"
	@echo "  help                  Show this help"
	@echo "  install               Create the uv-managed Python environment and install all dependencies,"
	@echo "                        must run once after fresh clone or after dist-clean/mrproper"
	@echo "  upgrade               Upgrade Python and Ansible dependencies in the local environment"
	@echo "  clean                 Remove Ansible and Python environments"
	@echo "  dist-clean            Remove local environments and build artifacts"
	@echo "  mrproper              Alias for dist-clean"
	@echo
	@echo "Build:"
	@echo "  all                   Build all supported groups/variants; use PUBLISH=true to publish"
	@echo "  <group>               Build a group; use PUBLISH=true to publish"
	@echo "  <variant>             Build a variant; use PUBLISH=true to publish"
	@echo "  docker-metadata       Update Docker Hub metadata; optionally limit with GROUP=..."
	@echo "  docker-cleanup        Delete untagged Docker Hub images; optionally limit with GROUP=..."
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

$(PYTHON):
	@$(UV) venv $(VENV)

# grouped target for Python dependencies: one recipe builds multiple targets
$(PLAYBOOK) $(GALAXY) $(COMMITIZEN) $(PRE_COMMIT) $(PSR) &: $(PYPROJECT) | $(PYTHON)
	@$(UV) pip install --python $(PYTHON) -r $(PYPROJECT)

$(COMMIT_MSG_HOOK): $(PRE_COMMIT_CONFIG) | $(PRE_COMMIT)
	@$(PRE_COMMIT) install --hook-type commit-msg

$(PODMAN_COLLECTION_MANIFEST): $(REQ_YML) | $(GALAXY)
	@$(GALAXY_COLL_INSTALL) -r $(REQ_YML)

.PHONY: ansible-deps
ansible-deps: $(PODMAN_COLLECTION_MANIFEST)

# --- General make targets ----------------------------------------------------

.PHONY: install
install: ansible-deps $(COMMIT_MSG_HOOK)

.PHONY: upgrade-python-deps
upgrade-python-deps: $(PYPROJECT) | $(PYTHON)
	@$(UV) pip install --python $(PYTHON) --upgrade -r $(PYPROJECT)

.PHONY: upgrade-ansible-deps
upgrade-ansible-deps: upgrade-python-deps $(REQ_YML)
	@$(GALAXY_COLL_INSTALL) --force -r $(REQ_YML)

.PHONY: upgrade-pre-commit-hook
upgrade-pre-commit-hook: upgrade-python-deps $(PRE_COMMIT_CONFIG)
	@$(PRE_COMMIT) install --hook-type commit-msg

.PHONY: upgrade
upgrade: upgrade-ansible-deps upgrade-pre-commit-hook

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
	@$(PLAYBOOK) playbooks/build.yml \
		--limit=$@ \
		--extra-vars=publish_images=$(PUBLISH) \
		--extra-vars=build_no_log=$(PUBLISH)

.PHONY: all
all: $(groups)

.PHONY: docker-metadata
docker-metadata: | $(PLAYBOOK)
	@$(PLAYBOOK) playbooks/docker-metadata.yml $(dockerhub_filter)

.PHONY: docker-cleanup
docker-cleanup: | $(PLAYBOOK)
	@$(PLAYBOOK) playbooks/docker-cleanup.yml $(dockerhub_filter)

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
	@$(PSR) version
	@git push origin main --follow-tags
	@git checkout dev
	@git pull --ff-only origin dev
	@git merge --ff-only main
	@git push origin dev
