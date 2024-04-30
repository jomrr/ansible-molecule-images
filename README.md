# ansible-molecule-images

![GitHub](https://img.shields.io/github/license/jomrr/ansible-molecule-images) ![GitHub last commit](https://img.shields.io/github/last-commit/jomrr/ansible-molecule-images) ![GitHub issues](https://img.shields.io/github/issues-raw/jomrr/ansible-molecule-images)

This repository contains a Makefile, Ansible inventory and playbook for building
Docker images running an init system for use in Ansible Molecule tests.

> This is the successor of the buildah scripts from [buildah-molecule-images](https://github.com/jomrr/buildah-molecule-images).

## TL;DR

```bash
sudo dnf -y install git make python3 python3-pip python3-virtualenv

mkdir -p ~/src/ansible && cd ~/src/ansible

git clone https://github.com/jomrr/ansible-molecule-images

cd ansible-molecule-images

pip install --user --upgrade pip
pip install --user keyring

# set docker registry user and secret, add to ~/.bashrc or ~/.bashrc.d/env
keyring set docker user
keyring set docker secret

# nvim ~/.bashrc.d/env
export DOCKER_USER=$(keyring get docker user)
export DOCKER_SECRET=$(keyring get docker secret)

# optionally edit containers.yml and add more registries and credentials under key push_registries.
# nvim containers.yml
make install

make <all|almalinux|alpine|amazonlinux|archlinux|debian|fedora|opensuse|oralcelinux|ubuntu>

# to upgrade the virtualenv packages and ansible-galaxy dependencies run:
make upgrade
```

## Description

The playbook [`playbooks/build.yml`](playbooks/build.yml) utilizes the `ansible.builtin.template` module to render Dockerfiles to the directory `build/{{ inventory_hostname }}/Dockerfile` and then uses the `containers.podman,podman_image` module to build and push the images to the configured registries from the inventory file [`containers.yml`](containers.yml). In this file the registries and its credentials are listed as `list of dictionaries` under the key `push_registries`. The name of the built image is configured in `build_image` as host_var, the tags in `build_tags`, also as host_vars.

## Inventory variables in [`containers.yml`](containers.yml)

Any of these variables can be set at all, group or host level, where host level has the highest precedence.

| variable | scope | type | default | description |
| -------- | ----- | ---- | ------- | ----------- |
| ansible_connection | all | str | local | defines ansible_connection=local for all inventory hosts |
| build_image | group | str | None | name/repo of the built image, the namespace is used from `push_registries.item.username` |
| build_maintainer | all | str | Jonas Mauer <<jam@kabelmail.net>> | build maintainer used in `MAINTAINER` and `ENV maintainer=` statement in generated Dockerfiles |
| build_tags | host | list=str | None | tags for the built images, the first listed tag will be used in FROM statement in Dockerfile, so e.g. `[39, latest]` will use tag `39` to build the image and push it tagged as `39` and `latest` |
| container_image | group | str | None | name of the image to use in FROM statement in generated Dockerfile |
| container_registry | all | str | docker.io | the container registry from where an image is pulled, used in FROM statement in generated Dockerfile |
| push_registries | all | list=dict | [ { name: docker.io, username: "{{ lookup('ansible.builtin.env', 'DOCKER_USER') }}", password: "{{ lookup('ansible.builtin.env', 'DOCKER_USER') }}" } ] | list of registriy definitions as dictionaries to where the built images are pushed |

## Getting Started

This provides an overview of the prerequisites and ansible dependencies, as well as some usage examples.

### Prerequisites

The following prerequisites must be installed before using this playbook.

#### System packages (Fedora)

> The following packages need to be installed manually, adopt to your distribution as package names may vary:

- `git`
- `make`
- `python3` >= 3.6
- `python3-pip`
- `python3-virtualenv`

#### Python (requirements.txt)

The python prerquisites are installed in a virtualenv `.venv` via the Makefile with `make install`.

- ansible >= 2.15

To install it manually for your user without virtualenv run:

```bash
pip install --user --upgrade pip
pip install --user --upgrade ansible >= 2.15
```

For development the following are also installed by `make install`:

- commitizen
- pre-commit
- python-semantic-release

### Dependencies (requirements.yml)

The `containers.podman` collection will be installed in the virtualenv during `make install`.

To install it manually for your regular user without virtualenv run:

```bash
ansible-galaxy collection install containers.podman
```

As a requirements.yml file

```yaml
---
# name: ansible-molecule-images
# file: requirements.yml

collections:
  - containers.podman

roles: []

```

it can be installed with:

```bash
ansible-galaxy install -r requiremens.yml
```

### Usage / Examples

#### Build and push images for `Fedora` and `Debian`

All Fedora images are created in parallel, after completion the Debian images are created.

```bash
make fedora debian
```

#### Build and push images for `Fedora` and `Debian` in parallel

This will make `make` run 2 jobs simultaniously, but mind the resource consumption:

```bash
make -j 2 fedora debian
```

This basically translates to the two commands:

```bash
ansible-playbook playbooks/build.yml --limit=fedora &
ansible-playbook playbooks/build.yml --limit=debian &
```

The inventory `containers.yml` is configured as static yaml inventory in `ansible.cfg` and therefore implicitly used by `ansible-playbook`.

## License

This content is published under the [MIT License](LICENSE).

## Author(s)

This content was created in 2024 by Jonas Mauer (@jomrr).

Thanks to [@fgoebel](https://github.com/fgoebel) for his contributions to [buildah-molecule-images](https://github.com/jomrr/buildah-molecule-images). They are included here. Looking forward to collaborating again.

## References

- [Ansible Docs - containers.podman.podman_image module](https://docs.ansible.com/ansible/latest/collections/containers/podman/podman_image_module.html)
