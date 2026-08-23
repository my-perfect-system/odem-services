# AGENTS.md — mps-alloy/ansible

Ansible deployment of the **Grafana Alloy** monitoring agent to Debian hosts.
Alloy ships host metrics, logs, container metrics, and Proxmox Backup Server
(PBS) metrics to a central Mimir + Loki stack.

## Quick start

```bash
ansible-playbook playbooks/site.yml            # all hosts in [monitored_hosts]
ansible-playbook playbooks/site.yml -l host1   # single host
ansible-playbook playbooks/site.yml --check    # dry-run (best-effort; some
                                               # shell/detection tasks are not
                                               # check-mode safe)
ansible-lint                                    # lint (skips role-name, var-naming)
```

`ansible.cfg` already sets `inventory=inventory.ini`, `roles_path=roles`,
`host_key_checking=False`, `interpreter_python=auto_silent`,
`retry_files_enabled=False`. No `requirements.yml` — only stdlib collections
(`ansible.builtin.*`) are used.

### Role directory layout

Roles are grouped into subdirectories under `roles/`:

- `roles/host/` — roles that configure the monitored host itself (Alloy
  agent, host metrics/logs, additional endpoint metrics).
- `roles/container/` — roles that collect container metrics/logs
  (Docker discovery + cAdvisor).
- `roles/services/` — roles that integrate a specific external service
  (e.g. Proxmox Backup Server, custom-metrics daemon).

`include_role` calls reference roles by path relative to `roles_path`, e.g.
`name: host/alloy_installer`, `name: container/default_metrics`, or
`name: services/pbs_metrics`.
When adding a role, place its directory under the matching subfolder and
prefix the `include_role` `name:` accordingly.

## Architecture

Single entrypoint: **`playbooks/site.yml`**. It runs on the
`[monitored_hosts]` inventory group with `become: true` and
`any_errors_fatal: true`. Each role is included via `include_role` gated by a
per-host `monitoring_features` list (see `host_vars/<host>.yml`).

### Feature flags → roles

Feature flags are named after their role folder (`<subfolder>_<role>`).

| `monitoring_features` entry | Role                                 | What it does                                                                                       |
| --------------------------- | ------------------------------------ | -------------------------------------------------------------------------------------------------- |
| `host_alloy_installer`      | `host/alloy_installer`               | Installs Grafana Alloy apt pkg, writes `/etc/default/alloy`, wipes stale `*.alloy`, writes `logging.alloy` + `remotes.alloy`. |
| `host_default_metrics`      | `host/default_metrics`               | `prometheus.exporter.unix` node_exporter-style metrics (`metrics_system.alloy`).                    |
| `host_default_logs`         | `host/default_logs`                  | Journal + syslog file scraping (`logs_system.alloy`).                                              |
| `host_custom_metrics`       | `host/custom_metrics`                | Templates one `scrape_<name>.alloy` per entry in `alloy_metrics_scrape_endpoints`.                 |
| `services_custom_server`   | `services/custom_server`            | Installs bash daemon (`monitoring-custom-metrics.bash`) + systemd unit serving `custom-metrics.json` over `python3 -m http.server` on port 25000. |
| `services_custom_server_metrics` | `services/custom_server_metrics` | Alloy scrape config for the custom-metrics daemon (`custom_metrics_scrape.alloy`).                   |
| `container_default_metrics` | `container/default_metrics`          | Docker container discovery + metric scraping via `/var/run/docker.sock` (`docker_metrics.alloy`). |
| `container_default_logs`    | `container/default_logs`            | Docker container discovery + log scraping via `/var/run/docker.sock` (`docker_logs.alloy`).      |
| `container_cadvisor_metrics`| `container/cadvisor_metrics`         | Embedded cAdvisor exporter for container CPU/mem/fs metrics.                                      |
| `services_pbs_server`       | `services/pbs_server`                 | Downloads `natrontech/pbs-exporter` release, installs systemd unit for the PBS exporter.          |
| `services_pbs_server_metrics` | `services/pbs_server_metrics`       | Alloy scrape config for the PBS exporter (`pbs_exporter_scrape.alloy`).                           |
| `services_ollama_server_metrics` | `services/ollama_server_metrics` | Alloy scrape config for the Ollama exporter (`ollama_exporter_scrape.alloy`).                       |
| `services_blackbox_exporter` | `services/blackbox_exporter` | Installs `prometheus-blackbox-exporter` apt pkg, templates `/etc/default/prometheus-blackbox-exporter`, systemd override unit, and `/etc/prometheus/blackbox.yml` modules config (host-var driven). |
| `services_blackbox_exporter_metrics` | `services/blackbox_exporter_metrics` | Alloy scrape config templating one probe target per entry in `blackbox_probe_targets` (`blackbox_exporter_scrape.alloy`). |

### Config layout on target hosts

- `/etc/alloy/*.alloy` — River-config fragments, one per concern (`logging`,
  `remotes`, `metrics_system`, `logs_system`, `docker_metrics`, `docker_logs`,
  `cadvisor`, `pbs_exporter_scrape`, `scrape_<name>`). Alloy loads all
  `*.alloy` in the directory.
- `/etc/default/alloy` — env file setting `CONFIG_FILE=/etc/alloy` and
  `--server.http.listen-addr=0.0.0.0:<alloy_web_ui_port>`.
- `/etc/default/custom-metrics`, `/etc/systemd/system/custom-metrics.service`
  — for the bash custom-metrics daemon.
- `/etc/default/pbs-exporter`, `/etc/systemd/system/pbs-exporter.service` —
  for the PBS exporter.

### Remotes

- `remote_prometheus_url` → Mimir remote_write (default
  `http://10.23.43.10:9090/api/v1/write`).
- `remote_loki_url` → Loki push (default
  `http://10.23.43.10:3100/loki/api/v1/push`).
- `alloy_custom_labels` — comma-separated `k=v` labels applied to both
  `prometheus.remote_write.mimir` and `loki.write.loki` external_labels.

## Conventions (follow these when editing)

1. **FQCN only**: always `ansible.builtin.<module>`, never bare module
   names. No third-party collections are used.
2. **Task splitting**: a role's `tasks/main.yml` is a thin dispatcher using
   `ansible.builtin.include_tasks: <sub>.yml`. Do not inline substantive
   work in `main.yml`.
3. **Templates**: Jinja2 files live in `templates/` and end in `.j2`. They
   render to `*.alloy` (Grafana Alloy River config), `*.default` (env files
   in `/etc/default/`), or `*.service` (systemd units). Use `notify:
   Restart <svc>` on every templating task that affects a service.
4. **Handlers live at the playbook level, NOT in roles.** All restart handlers
   (`Restart alloy`, `Restart custom-metrics`, `Restart pbs-exporter`,
   `Restart blackbox-exporter`) are declared in the `handlers:` block of
   `playbooks/site.yml`. Role `handlers/main.yml` files are intentionally
   empty (`---`). **If you add a role that needs a new restart handler, add it
   to `playbooks/site.yml`'s `handlers:` section**, not the role.
5. **Per-role `defaults/main.yml`** redeclares shared vars like
   `alloy_config_dir`. Override cross-role vars via `host_vars/<host>.yml`
   or `group_vars/`, not by editing one role's defaults (other roles won't
   see it).
6. **Feature gating**: every role assumes `monitoring_features` (a list of
   strings) is defined on the host. New features must (a) add a role, (b)
   add an `include_role` block in `playbooks/site.yml` with a `when:` guard
   on the feature string, and (c) document the string in
   `host_vars/host1.yml`'s comment header.
7. **Loop labels**: always set `loop_control.label` when looping over dicts
   to keep task output readable.
8. **Modes as strings**: quote file modes (`mode: "0644"`, `mode: "0755"`).
9. **Idempotency**: the `host/alloy_installer` role runs an `ansible.builtin.find`
   + `ansible.builtin.file` pass to delete stale `*.alloy` files at the
   start of every run, then re-templates only what current features require.
   **Role order in `playbooks/site.yml` matters**: `host/alloy_installer` must
   run before any role that writes `*.alloy`, otherwise those files will be
   wiped and not re-rendered. Keep `host_alloy_installer` first.
10. **Secrets**: the PBS API token (`pbs_api_token`) is a plain default
    var. Do not commit real values; override via `host_vars/`, an
    `--extra-vars` file in `.gitignore`, or a vault-encrypted vars file
    (none used yet).
11. **Lint**: `.ansible-lint` skips `role-name` (role dirs use dots like
    `monitoring.host.defaults`) and `var-naming`. Keep these skips in place;
    do not rename roles.

## Per-feature gotchas

- **`services_pbs_server`** asserts that `pbs_api_token_name` and `pbs_api_token`
  are non-empty before installing. Supply them via `host_vars/<host>.yml`
  or extra vars.
- **`services_custom_server`** daemon requires `jq` and `python3`
  (installed by the role). It evaluates shell commands from
  `custom-metrics.json` via `eval` — only run on trusted hosts.
- **`container_default_metrics` / `container_default_logs` / `container_cadvisor_metrics`**
  all need the `alloy` user in the `docker` group; `host/alloy_installer`
  adds it when any of these features is enabled. Do not enable them without
  `host_alloy_installer` also enabled.
- **`services_blackbox_exporter`** asserts that `blackbox_modules` (a dict
  of name → module config) is non-empty before installing. Supply it via
  `host_vars/<host>.yml` or extra vars.
- **`services_blackbox_exporter_metrics`** asserts that
  `blackbox_probe_targets` (a list of `{name, target, module}` dicts) is
  non-empty before templating the scrape config.
- **`host/alloy_installer`'s stale-file cleanup** removes *any* `*.alloy` not
  re-templated in the current run. If you temporarily disable a feature,
  its alloy fragment will be deleted on the next run — expected behaviour,
  not a bug.

## Dashboards

Grafana dashboard JSON exports live under each role's `dashboards/`
directory (`dashboard_nodeexporter.json`, `dashborad_docker.json`,
`dashboard_cadvisor.json`, `dashboard_pbsexporter.json`). They are **not**
imported by the playbook — import them manually into Grafana.