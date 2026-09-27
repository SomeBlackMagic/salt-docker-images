# salt-docker-images

Docker images for [SaltStack](https://saltproject.io/) development and testing via [kitchen-salt](https://github.com/saltstack/kitchen-salt).

Images are built on GitHub Actions and published to GitHub Container Registry (`ghcr.io`).

## Images

### salt-core

Full Salt environment based on `python:3.10-slim` with salt-common, salt-minion, salt-master, salt-ssh and salt-cloud.

```
ghcr.io/someblackmagic/salt-docker-images/salt-core:<salt_version>
```

Workspace layout inside the container:

| Variable           | Path                        |
|--------------------|-----------------------------|
| `SALT_CONFIG_DIR`  | `/workspace/etc/salt`       |
| `SALT_FILE_ROOT`   | `/workspace/srv/salt`       |
| `SALT_PILLAR_ROOT` | `/workspace/srv/pillar`     |
| `SALT_CACHEDIR`    | `/workspace/var/cache/salt` |
| `SALT_LOGDIR`      | `/workspace/var/log/salt`   |
| `SALT_PKI_DIR`     | `/workspace/pki/salt`       |

### salt-kitchen

Test containers for kitchen-salt with systemd support. Each platform is a separate image:

```
ghcr.io/someblackmagic/salt-docker-images/kitchen-<platform>:<salt_version>
```

Available platforms:

| Image                      | Base                            |
|----------------------------|---------------------------------|
| `kitchen-debian-12`        | `debian:12`                     |
| `kitchen-ubuntu-2204`      | `ubuntu:22.04`                  |
| `kitchen-ubuntu-2404`      | `ubuntu:24.04`                  |
| `kitchen-rockylinux-9`     | `rockylinux:9`                  |
| `kitchen-almalinux-9`      | `almalinux:9`                   |
| `kitchen-centos-stream-9`  | `quay.io/centos/centos:stream9` |
| `kitchen-amazonlinux-2023` | `amazonlinux:2023`              |
| `kitchen-opensuse-leap-15` | `opensuse/leap:15`              |

## Usage with kitchen-salt

Example `.kitchen.yml` using these images:

```yaml
driver:
  name: docker
  use_sudo: false
  binary: env DOCKER_BUILDKIT=0 docker
  build_context: false

provisioner:
  name: shell
  script: test/integration/default/provision.sh

verifier:
  name: shell
  remote_exec: true
  command: sudo bash /tmp/verify.sh

platforms:
  ## Debian / Ubuntu / openSUSE
  - name: debian-12
    driver:
      image: ghcr.io/someblackmagic/salt-docker-images/kitchen-debian-12:<salt_version>
      run_command: /lib/systemd/systemd
      env:
        - container=docker
      tmpfs:
        - /run
        - /run/lock

  ## RHEL-based (Rocky, Alma, CentOS Stream, Amazon Linux)
  - name: rockylinux-9
    driver:
      image: ghcr.io/someblackmagic/salt-docker-images/kitchen-rockylinux-9:<salt_version>
      run_command: /usr/lib/systemd/systemd
      username: root
      env:
        - container=docker
      tmpfs:
        - /run
        - /run/lock
    transport:
      name: docker
      username: root
      temp_dir: /var/tmp
    provisioner:
      root_path: /var/tmp/kitchen
      sudo: false
    verifier:
      root_path: /var/tmp/verifier
      sudo: false

suites:
  - name: default
```

> **Note:** Debian/Ubuntu/openSUSE platforms use `/lib/systemd/systemd` as `run_command`.
> RHEL-based platforms (Rocky, Alma, CentOS Stream, Amazon Linux) use `/usr/lib/systemd/systemd` and require additional `transport`, `provisioner`, and `verifier` overrides with `root_path: /var/tmp/...` and `sudo: false`.

## Building

### GitHub Actions (CI)

Both workflows support manual dispatch with a comma-separated list of Salt versions:

**Build Salt Core:**
```
salt_versions: "3006.9,3006.14,3007.1"
```

**Build Kitchen:**
```
salt_versions: "3006.9,3006.14"
```

Builds also trigger automatically on push to `main` when files in the corresponding directory change.

### Local build

```bash
# salt-core with specific version
docker build --build-arg SALT_VERSION=3006.14 -t salt-core:3006.14 salt-core/

# kitchen image with specific version
docker build --build-arg SALT_VERSION=3006.14 -t kitchen-ubuntu-2404:3006.14 salt-kitchen/kitchen-ubuntu-2404/
```
