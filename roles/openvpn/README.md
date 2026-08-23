---
namespace: odem
collection: services
role: openvpn
---

# `odem.services.openvpn`

Deploy an OpenVPN server from the `mps-openvpn` config repo — clone the
repo, render its `.env`, generate the PKI and a single TAP network, and
start the server container via docker compose.

Docker and Docker Compose must already be present on the host (a
dedicated docker role runs in advance).

## Default variables

| Variable | Default | Description |
|---|---|---|
| `openvpn_enable_service` | `true` | Bring the compose services up at the end of the run |
| `openvpn_enable_regenerate` | `false` | Force a PKI rebuild (destroys the existing CA and all certs) |
| `openvpn_repo_url` | `https://github.com/my-perfect-system/mps-openvpn.git` | Git URL for the mps-openvpn repo |
| `openvpn_repo_version` | `main` | Git ref to check out |
| `openvpn_repo_dest` | `{{ common_default_repo_dir }}/mps-openvpn` | Clone destination (derived from the `common_default_repo_dir` global in `odem.base.common`) |
| `openvpn_server_address` | `server` | `SERVER_ADDRESS` in `.env` (remote address in `.ovpn` files) |
| `openvpn_network_name` | `example-tap` | Network name (also the server certificate CN) |
| `openvpn_network_mode` | `tap` | Network mode (`tap` or `tun`) |
| `openvpn_network_port` | `1195` | UDP listen port |
| `openvpn_network_subnet` | `10.9.0.0/24` | CIDR subnet |
| `openvpn_compose_file` | `docker-compose.ansible.yml` | Compose file path (relative to the repo dest) rendered from `docker-compose.yml.j2` |

The `openvpn_easyrsa_*` variables (country, province, city, org, email,
ou, key_size, algo, ca_expire, cert_expire) are rendered into `.env` and
consumed by `common/gen-certs.sh` for the CA subject — see
[`meta/argument_specs.yml`](meta/argument_specs.yml) for the full list.

## Dependencies

- `odem.base.common`

## Example usage

```yaml
- hosts: all
  become: true
  roles:
    - odem.services.openvpn
```

Client certificates are generated manually against the deployed server:

```bash
cd /usr/share/mps/openvpn
bash common/gen-client.sh <client> <network>
```

## Role metadata

- **Min Ansible version**: `2.16.0`
- **License**: GPL-3.0-or-later
- **Platforms**: Debian (trixie)

## Related files

- [`meta/main.yml`](meta/main.yml) — galaxy_info + role dependencies
- [`meta/argument_specs.yml`](meta/argument_specs.yml) — variable spec (the source of the variable table above)
- [`defaults/main.yml`](defaults/main.yml) — variable defaults (the source of the default values above)
