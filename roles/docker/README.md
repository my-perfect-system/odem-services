---
namespace: odem
collection: services
role: docker
---

# `odem.services.docker`

Install the latest Docker Engine from the official Docker apt
repository (not the older packages in the Debian archive): adds the
Docker GPG key and `stable` repo, installs `docker-ce` +
`docker-compose-plugin` + the buildx plugin, and starts/enables the
`docker` service.

## Default variables

| Variable | Default | Description |
|---|---|---|
| `docker_enable_service` | `true` | Start and enable the docker systemd service |
| `docker_keyring_path` | `/etc/apt/keyrings/docker.asc` | Docker apt signing key location |
| `docker_gpg_key_url` | `https://download.docker.com/linux/debian/gpg` | GPG key URL |
| `docker_repo_url` | `https://download.docker.com/linux/debian` | Docker apt repository base URL |
| `docker_repo_release` | `{{ ansible_distribution_release }}` | Debian release codename for the repo |
| `docker_apt_filename` | `docker` | apt source-list filename |
| `docker_engine_packages` | `[docker-ce, docker-ce-cli, containerd.io, docker-buildx-plugin, docker-compose-plugin]` | Engine packages to install |
| `docker_service` | `docker` | systemd service name |

## Dependencies

- `odem.base.common`

## Example usage

```yaml
- hosts: all
  become: true
  roles:
    - odem.services.docker
```

## Role metadata

- **Min Ansible version**: `2.16.0`
- **License**: GPL-3.0-or-later
- **Platforms**: Debian (trixie)

## Related files

- [`meta/main.yml`](meta/main.yml) — galaxy_info + role dependencies
- [`meta/argument_specs.yml`](meta/argument_specs.yml) — variable spec (the source of the variable table above)
- [`defaults/main.yml`](defaults/main.yml) — variable defaults (the source of the default values above)
