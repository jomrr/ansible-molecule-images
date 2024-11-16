# CHANGELOG

## v0.4.0 (2024-11-16)

### Feature

* feat: add fedora 41 as latest ([`c05df72`](https://github.com/jomrr/ansible-molecule-images/commit/c05df72febee4e86b8513453627fb5ae47793252))

### Fix

* fix: image tagging and nolog

- ensure correct tag for alpine 3.20
- correct tagging for current fedora versions
- nolog true for push list ([`0dcc72e`](https://github.com/jomrr/ansible-molecule-images/commit/0dcc72eab75984518b1b0725d482efafcd65ae59))

* fix: missing sudoers in leap 15.6 ([`f4a7c7e`](https://github.com/jomrr/ansible-molecule-images/commit/f4a7c7e63e992dad1dbd425327459e4eefcdc5a9))

## v0.3.0 (2024-06-19)

### Build

* build(release): version 0.3.0 ([`3b558e2`](https://github.com/jomrr/ansible-molecule-images/commit/3b558e2ecbf439c41c9392044aeeb00f897b2c7c))

* build: remove unnecessary config ([`8695fb2`](https://github.com/jomrr/ansible-molecule-images/commit/8695fb2948143adb57c5fb592602d28064251a72))

* build: push after version ([`6eab1dd`](https://github.com/jomrr/ansible-molecule-images/commit/6eab1dd48603143a403f1c5aa7da42a2745fe811))

### Chore

* chore: Update repository URL in pyproject.toml and README.md ([`493642a`](https://github.com/jomrr/ansible-molecule-images/commit/493642ab146f18151605bf180e6598b3a4855f62))

### Documentation

* docs(license): remove github reference ([`4a5afd3`](https://github.com/jomrr/ansible-molecule-images/commit/4a5afd39f7d45952f840870fa49986a272d0a31b))

### Feature

* feat: add alpine 3.20 ([`34ead09`](https://github.com/jomrr/ansible-molecule-images/commit/34ead09bb469b747f372f235e213c0b1b17aebbc))

* feat: add alpine 3.20 ([`38160c7`](https://github.com/jomrr/ansible-molecule-images/commit/38160c7bb3a3a57e2a8c86347a88e6f995563df2))

* feat: prepare docker repo management ([`0eb3af3`](https://github.com/jomrr/ansible-molecule-images/commit/0eb3af32ec488a13e8da6faeb795fc62af63f790))

* feat: drop amazonlinux-2 ([`6f4749a`](https://github.com/jomrr/ansible-molecule-images/commit/6f4749a46f6f4fa7b71b290f77f3539c58a3df0c))

* feat: tag f40 as latest ([`1d0e071`](https://github.com/jomrr/ansible-molecule-images/commit/1d0e071e388c76a145a1158e325466b99b42f849))

### Fix

* fix: almalinux 9 missing /etc/sudoers ([`446d562`](https://github.com/jomrr/ansible-molecule-images/commit/446d562eb66c1a8a1302edb534e9801de7966e1e))

* fix: almalinux 9 missing /etc/sudoers ([`76500fe`](https://github.com/jomrr/ansible-molecule-images/commit/76500fe10bad21e9879a8c698583b7b1e313fe2a))

* fix: fix ansible become with root ([`db84f56`](https://github.com/jomrr/ansible-molecule-images/commit/db84f56bbad0ad500f6bab8a370c3b57c73bc479))

### Unknown

* Merge branch &#39;dev&#39; ([`e9ea3f3`](https://github.com/jomrr/ansible-molecule-images/commit/e9ea3f31e6e79bc95c6d3f5713c1e1dac29843e7))

* Merge branch &#39;dev&#39; ([`f02bb56`](https://github.com/jomrr/ansible-molecule-images/commit/f02bb56c319224b837f1d399b44fee45ea8282cd))

* Merge branch &#39;dev&#39; ([`5c4bcc6`](https://github.com/jomrr/ansible-molecule-images/commit/5c4bcc61a0eef6ed4467effd36d627360e03f95f))

* Merge branch &#39;dev&#39; ([`9f4fba9`](https://github.com/jomrr/ansible-molecule-images/commit/9f4fba9bb63987ad15b8c6f4c5cc297b318bba15))

* merge remote-tracking branch &#39;refs/remotes/origin/dev&#39; into dev ([`129f73e`](https://github.com/jomrr/ansible-molecule-images/commit/129f73e6be1577aae341367dcc3d2ecb35a2a05b))

## v0.2.0 (2024-03-17)

### Build

* build(release): version 0.2.0 ([`f602fb0`](https://github.com/jomrr/ansible-molecule-images/commit/f602fb0aa1bad221bfa109315162879bdb723566))

### Feature

* feat: add leap 15.6, drop opensuse for separate leap and tumbleweed repos ([`5175a7e`](https://github.com/jomrr/ansible-molecule-images/commit/5175a7ef1b3b7987f0622a02fcdc26c2c32db65f))

* feat: add debian 13, trixie and misc additonal tags ([`50e1616`](https://github.com/jomrr/ansible-molecule-images/commit/50e161653ce4a2d0eb0e59a4bf595bad707d5e7b))

* feat: Add build tags for Ubuntu 24.04 (24.04, noble) ([`cf4f69c`](https://github.com/jomrr/ansible-molecule-images/commit/cf4f69c5c69f79ba3a0f514e1244d7e15cf81113))

### Fix

* fix: Update package_clean command in archlinux.yml playbook ([`c1da1c7`](https://github.com/jomrr/ansible-molecule-images/commit/c1da1c7926814779fad1ac5a9ed289ca3447d069))

### Style

* style: more descriptive name ([`f495e60`](https://github.com/jomrr/ansible-molecule-images/commit/f495e60fe6040df990f4c47972f0bfb6eb4f46e5))

### Unknown

* Merge branch &#39;dev&#39; ([`ea70fc2`](https://github.com/jomrr/ansible-molecule-images/commit/ea70fc2fa65593b7c8bd85b17639dd726c615d3f))

* Merge branch &#39;dev&#39; ([`6b68a77`](https://github.com/jomrr/ansible-molecule-images/commit/6b68a77059c779f86519b06b44b60b8947b9f2b0))

* Merge branch &#39;dev&#39; ([`b723ec6`](https://github.com/jomrr/ansible-molecule-images/commit/b723ec6902eb78bc87dd2e41071b6cfd278b313a))

## v0.1.1 (2024-02-20)

### Build

* build(release): version 0.1.1 ([`c73118c`](https://github.com/jomrr/ansible-molecule-images/commit/c73118cc74c067bbb8a1ebda02269f375ef6a967))

* build: merge main back to dev after version ([`bcb3d9c`](https://github.com/jomrr/ansible-molecule-images/commit/bcb3d9c1dc28465ce15f32558499186c77e4ef8e))

### Fix

* fix: entrypoint for systemd ([`e4e72b5`](https://github.com/jomrr/ansible-molecule-images/commit/e4e72b51f7d02307793bae818fe905d250db9e19))

### Style

* style: Correct yaml spacing ([`ba6c6b0`](https://github.com/jomrr/ansible-molecule-images/commit/ba6c6b0758e90bb9f3b66f57dc6ca2d265b1bda3))

* style: Fix wrong indention ([`dbdbfa5`](https://github.com/jomrr/ansible-molecule-images/commit/dbdbfa5586646595e7c635fe5b8f90861b462c5c))

* style: Extend playbook name ([`e3ff71c`](https://github.com/jomrr/ansible-molecule-images/commit/e3ff71c09b4f213c58c9354f71fee412f614ad1d))

* style: Move strategy option from build.yml to ansible.cfg, use FQCNs ([`01a8b22`](https://github.com/jomrr/ansible-molecule-images/commit/01a8b22bd80f1ba5f306b1a48a013a802a59d132))

### Unknown

* Merge branch &#39;main&#39; into dev ([`ea693d8`](https://github.com/jomrr/ansible-molecule-images/commit/ea693d86dac664165625fc271c7a5b48771dafdc))

## v0.1.0 (2024-02-19)

### Build

* build(release): 0.1.0 ([`69a2df8`](https://github.com/jomrr/ansible-molecule-images/commit/69a2df85169057d5833fd53b67af30341d1c0414))

* build: remove custom build command and publish src ([`94334a4`](https://github.com/jomrr/ansible-molecule-images/commit/94334a4f7cb6b707c0535ddff761bef76d8fcb4e))

### Feature

* feat: first commit ([`94eaa1e`](https://github.com/jomrr/ansible-molecule-images/commit/94eaa1e1d1c3466f06c3e1066c020178bcc655f0))

### Unknown

* doc: add license file ([`1db1b13`](https://github.com/jomrr/ansible-molecule-images/commit/1db1b133c7a70a32c020f83dd469ad655b09bd4b))
