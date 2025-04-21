# CHANGELOG


## v0.5.1 (2025-04-21)

### Bug Fixes

- Fedora: add missing python3-libdnf5
  ([`79d6ea8`](https://github.com/jomrr/ansible-molecule-images/commit/79d6ea8d93d38b1f1d672421528d14db15063aa0))


## v0.5.0 (2025-04-18)

### Bug Fixes

- Build_tags for fedora 42
  ([`279fb93`](https://github.com/jomrr/ansible-molecule-images/commit/279fb93595db8e98c623988a0e3f1eb27b83bd49))

### Build System

- Add tag adams to fedora 42
  ([`a3b66ef`](https://github.com/jomrr/ansible-molecule-images/commit/a3b66ef7bca873e89ea10d651e3cf538d739d210))

### Features

- Add fedora 42, retire fedora 40
  ([`71a9594`](https://github.com/jomrr/ansible-molecule-images/commit/71a959461056478acd51b48336ef63840479fb20))


## v0.4.0 (2024-11-16)

### Bug Fixes

- Image tagging and nolog
  ([`0dcc72e`](https://github.com/jomrr/ansible-molecule-images/commit/0dcc72eab75984518b1b0725d482efafcd65ae59))

- ensure correct tag for alpine 3.20 - correct tagging for current fedora versions - nolog true for
  push list

- Missing sudoers in leap 15.6
  ([`f4a7c7e`](https://github.com/jomrr/ansible-molecule-images/commit/f4a7c7e63e992dad1dbd425327459e4eefcdc5a9))

### Features

- Add fedora 41 as latest
  ([`c05df72`](https://github.com/jomrr/ansible-molecule-images/commit/c05df72febee4e86b8513453627fb5ae47793252))


## v0.3.0 (2024-06-19)

### Bug Fixes

- Almalinux 9 missing /etc/sudoers
  ([`446d562`](https://github.com/jomrr/ansible-molecule-images/commit/446d562eb66c1a8a1302edb534e9801de7966e1e))

- Almalinux 9 missing /etc/sudoers
  ([`76500fe`](https://github.com/jomrr/ansible-molecule-images/commit/76500fe10bad21e9879a8c698583b7b1e313fe2a))

- Fix ansible become with root
  ([`db84f56`](https://github.com/jomrr/ansible-molecule-images/commit/db84f56bbad0ad500f6bab8a370c3b57c73bc479))

### Build System

- Push after version
  ([`6eab1dd`](https://github.com/jomrr/ansible-molecule-images/commit/6eab1dd48603143a403f1c5aa7da42a2745fe811))

- Remove unnecessary config
  ([`8695fb2`](https://github.com/jomrr/ansible-molecule-images/commit/8695fb2948143adb57c5fb592602d28064251a72))

### Chores

- Update repository URL in pyproject.toml and README.md
  ([`493642a`](https://github.com/jomrr/ansible-molecule-images/commit/493642ab146f18151605bf180e6598b3a4855f62))

### Documentation

- **license**: Remove github reference
  ([`4a5afd3`](https://github.com/jomrr/ansible-molecule-images/commit/4a5afd39f7d45952f840870fa49986a272d0a31b))

### Features

- Add alpine 3.20
  ([`34ead09`](https://github.com/jomrr/ansible-molecule-images/commit/34ead09bb469b747f372f235e213c0b1b17aebbc))

- Add alpine 3.20
  ([`38160c7`](https://github.com/jomrr/ansible-molecule-images/commit/38160c7bb3a3a57e2a8c86347a88e6f995563df2))

- Drop amazonlinux-2
  ([`6f4749a`](https://github.com/jomrr/ansible-molecule-images/commit/6f4749a46f6f4fa7b71b290f77f3539c58a3df0c))

- Prepare docker repo management
  ([`0eb3af3`](https://github.com/jomrr/ansible-molecule-images/commit/0eb3af32ec488a13e8da6faeb795fc62af63f790))

- Tag f40 as latest
  ([`1d0e071`](https://github.com/jomrr/ansible-molecule-images/commit/1d0e071e388c76a145a1158e325466b99b42f849))


## v0.2.0 (2024-03-17)

### Bug Fixes

- Update package_clean command in archlinux.yml playbook
  ([`c1da1c7`](https://github.com/jomrr/ansible-molecule-images/commit/c1da1c7926814779fad1ac5a9ed289ca3447d069))

### Code Style

- More descriptive name
  ([`f495e60`](https://github.com/jomrr/ansible-molecule-images/commit/f495e60fe6040df990f4c47972f0bfb6eb4f46e5))

### Features

- Add build tags for Ubuntu 24.04 (24.04, noble)
  ([`cf4f69c`](https://github.com/jomrr/ansible-molecule-images/commit/cf4f69c5c69f79ba3a0f514e1244d7e15cf81113))

- Add debian 13, trixie and misc additonal tags
  ([`50e1616`](https://github.com/jomrr/ansible-molecule-images/commit/50e161653ce4a2d0eb0e59a4bf595bad707d5e7b))

- Add leap 15.6, drop opensuse for separate leap and tumbleweed repos
  ([`5175a7e`](https://github.com/jomrr/ansible-molecule-images/commit/5175a7ef1b3b7987f0622a02fcdc26c2c32db65f))


## v0.1.1 (2024-02-20)

### Bug Fixes

- Entrypoint for systemd
  ([`e4e72b5`](https://github.com/jomrr/ansible-molecule-images/commit/e4e72b51f7d02307793bae818fe905d250db9e19))

### Build System

- Merge main back to dev after version
  ([`bcb3d9c`](https://github.com/jomrr/ansible-molecule-images/commit/bcb3d9c1dc28465ce15f32558499186c77e4ef8e))

### Code Style

- Correct yaml spacing
  ([`ba6c6b0`](https://github.com/jomrr/ansible-molecule-images/commit/ba6c6b0758e90bb9f3b66f57dc6ca2d265b1bda3))

- Extend playbook name
  ([`e3ff71c`](https://github.com/jomrr/ansible-molecule-images/commit/e3ff71c09b4f213c58c9354f71fee412f614ad1d))

- Fix wrong indention
  ([`dbdbfa5`](https://github.com/jomrr/ansible-molecule-images/commit/dbdbfa5586646595e7c635fe5b8f90861b462c5c))

- Move strategy option from build.yml to ansible.cfg, use FQCNs
  ([`01a8b22`](https://github.com/jomrr/ansible-molecule-images/commit/01a8b22bd80f1ba5f306b1a48a013a802a59d132))


## v0.1.0 (2024-02-19)

### Build System

- Remove custom build command and publish src
  ([`94334a4`](https://github.com/jomrr/ansible-molecule-images/commit/94334a4f7cb6b707c0535ddff761bef76d8fcb4e))

- **release**: 0.1.0
  ([`69a2df8`](https://github.com/jomrr/ansible-molecule-images/commit/69a2df85169057d5833fd53b67af30341d1c0414))

### Features

- First commit
  ([`94eaa1e`](https://github.com/jomrr/ansible-molecule-images/commit/94eaa1e1d1c3466f06c3e1066c020178bcc655f0))
