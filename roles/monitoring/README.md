---
namespace: odem
collection: services
role: monitoring
---

# `odem.services.monitoring`

Deploy the `mps-monitoring` stack — Prometheus (metrics), Loki (logs),
and Grafana (dashboards) — via its docker compose file: clone the repo,
render `.env` from variables, materialize the gitignored service config
files from their `.example` siblings, prepare the bind-mounted data
directories, and start the stack.

Docker and Docker Compose must already be present on the host
(see [`odem.services.docker`](../docker/README.md)).

## Default variables

| Variable | Default | Description |
|---|---|---|
| `monitoring_enable_service` | `true` | Bring the compose stack up at the end of the run |
| `monitoring_enable_setup` | `true` | Run the repo's setup.sh to create and chown the data directories |
| `monitoring_repo_url` | `https://github.com/my-perfect-system/mps-monitoring.git` | Git URL for the mps-monitoring repo |
| `monitoring_repo_version` | `main` | Git ref to check out |
| `monitoring_repo_dest` | `{{ common_default_repo_dir }}/mps-monitoring` | Clone destination |
| `monitoring_bind_ip` | `127.0.0.1` | Host IP the service ports bind to |
| `monitoring_grafana_port` | `3000` | Host port for Grafana |
| `monitoring_prometheus_port` | `9090` | Host port for Prometheus |
| `monitoring_loki_port` | `3100` | Host port for Loki |
| `monitoring_grafana_admin_user` | `admin` | Grafana admin username |
| `monitoring_grafana_admin_password` | `admin` | Grafana admin password |
| `monitoring_prometheus_version` | `v3.12.0` | Prometheus image tag |
| `monitoring_loki_version` | `3.7.2` | Loki image tag |
| `monitoring_grafana_version` | `13.0.2` | Grafana image tag |

## Dependencies

- `odem.base.common`

## Example usage

```yaml
- hosts: all
  become: true
  roles:
    - odem.services.docker
    - odem.services.monitoring
```

## Role metadata

- **Min Ansible version**: `2.16.0`
- **License**: GPL-3.0-or-later
- **Platforms**: Debian (trixie)

## Related files

- [`meta/main.yml`](meta/main.yml) — galaxy_info + role dependencies
- [`meta/argument_specs.yml`](meta/argument_specs.yml) — variable spec (the source of the variable table above)
- [`defaults/main.yml`](defaults/main.yml) — variable defaults (the source of the default values above)