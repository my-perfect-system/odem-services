# `odem.services` Ansible Collection

Service deployment and configuration for Debian 13 — e.g. OpenVPN
server configuration managed from the `mps-openvpn` config repo.

## Galaxy metadata

- **namespace**: `odem`
- **name**: `services`
- **version**: `0.4.2`
- **dependencies**: `odem.base`, `ansible.posix`

See [`galaxy.yml`](galaxy.yml) for the canonical values.

## Roles

| Role | Purpose |
|---|---|
| [`odem.services.docker`](roles/docker/README.md) | Install the latest Docker Engine from the official Docker apt repository. |
| [`odem.services.openvpn`](roles/openvpn/README.md) | Deploy an OpenVPN server from the `mps-openvpn` config repo (clone, `.env` render, PKI + TAP network generation, docker compose up). |
| [`odem.services.monitoring`](roles/monitoring/README.md) | Deploy the `mps-monitoring` stack (Prometheus, Loki, Grafana) via docker compose. |

## Installation

```bash
ansible-galaxy collection install odem.services
```

## Documentation

- [`AGENTS.md`](AGENTS.md) — developer conventions

## License

GPL-3.0-or-later
