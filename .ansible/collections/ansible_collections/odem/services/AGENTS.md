# AGENTS.md — odem-services

Service deployment and configuration — system-level service roles
(e.g. OpenVPN server configuration sourced from the `mps-openvpn`
config repo).

## Galaxy

- **namespace**: `odem`
- **name**: `services`
- **version**: `0.4.3`
- **dependencies**: `odem.base >=0.1.0`, `ansible.posix >=1.0.0`

## Roles

| Role | Description | Complexity |
|---|---|---|
| `odem.services.docker` | Install latest Docker Engine from the official Docker apt repo (GPG key + `stable` repo + docker-ce + compose/buildx plugins), start/enable the service. | 1 |
| `odem.services.openvpn` | Clone `mps-openvpn`, render `.env`, generate PKI + a single TAP network (stat-gated), render an own `docker-compose.yml` (server-only, port-driven), `docker compose up`. Requires `odem.services.docker`. | 2 |
| `odem.services.monitoring` | Clone `mps-monitoring`, render `.env`, materialize gitignored config files from `.example` twins, run `setup.sh`, `docker compose up` the Prometheus/Loki/Grafana stack. Requires `odem.services.docker`. | 2 |
| `odem.services.openwebui` | Clone `ailab-web` over SSH, render root + per-service `.env` (openwebui/swag/kokoro), materialize `common/ssh/authorized_keys`, `docker compose up` the Open WebUI/SWAG/Kokoro stack. Requires `odem.services.docker` and the `ailab-localai_ailab-local` Docker network. | 2 |

## Conventions

- Follows the cross-collection conventions documented in the root
  `AGENTS.md` / `manage/AGENTS.md` (task naming, toggle pattern,
  install/facts/configure sub-steps).
- Roles will be system-level unless noted; per-user roles opt in via
  `user_roles.services_<x>` keys.
- `changelogs/` intentionally absent — added at first release.
