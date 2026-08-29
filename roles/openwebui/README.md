---
namespace: odem
collection: services
role: openwebui
---

# `odem.services.openwebui`

Deploy the `ailab-web` stack — Open WebUI (chat UI), SWAG (reverse proxy
with HTTPS), and Kokoro (TTS) — via its docker compose file: clone the
repo over SSH, render the root and per-service `.env` files, materialize
`common/ssh/authorized_keys` from its `_example` sibling, and start the
stack.

Docker and Docker Compose must already be present on the host
(see [`odem.services.docker`](../docker/README.md)).

The external Docker network `ailab-localai_ailab-local` (created by the
sibling `ailab-localai` project) must already exist for the openwebui
and kokoro services to attach to.

## Default variables

| Variable | Default | Description |
|---|---|---|
| `openwebui_enable_service` | `true` | Bring the compose stack up at the end of the run |
| `openwebui_repo_url` | `git@github.com:al-readytaken/ailab-web.git` | Git URL for the ailab-web repo (SSH form) |
| `openwebui_repo_version` | `main` | Git ref to check out |
| `openwebui_repo_dest` | `{{ common_default_repo_dir }}/github/al-readytaken/ailab-web` | Clone destination |
| `openwebui_ip_web` | `0.0.0.0` | Host IP the Open WebUI web port binds to |
| `openwebui_port_web` | `3001` | Host port for Open WebUI web |
| `openwebui_ip_ssh` | `0.0.0.0` | Host IP the Open WebUI SSH port binds to |
| `openwebui_port_ssh` | `22201` | Host port for Open WebUI SSH |
| `openwebui_swag_ip` | `0.0.0.0` | Host IP the SWAG ports bind to |
| `openwebui_swag_port_http` | `80` | Host port for SWAG HTTP |
| `openwebui_swag_port_https` | `443` | Host port for SWAG HTTPS |
| `openwebui_kokoro_port` | `8880` | Host port for the Kokoro TTS service |
| `openwebui_webui_url` | `https://openwebui-local` | WEBUI_URL for the Open WebUI service |
| `openwebui_webui_port` | `3001` | WEBUI_PORT for the Open WebUI service |
| `openwebui_cors_allow_origin` | `https://openwebui-local` | CORS_ALLOW_ORIGIN for the Open WebUI service |
| `openwebui_secret_key` | `your-secret-key-...` | WEBUI_SECRET_KEY for the Open WebUI service |
| `openwebui_ollama_base_url` | `http://ollama:11434` | OLLAMA_BASE_URL for the Open WebUI service |
| `openwebui_hf_token` | `""` | HuggingFace token for the Open WebUI service |
| `openwebui_root_password` | `set-your-password-here` | ROOT_PASSWORD for SSH access into the Open WebUI container |
| `openwebui_swag_url` | `openwebui-local` | URL for the SWAG reverse proxy |
| `openwebui_swag_subdomains` | `www` | SUBDOMAINS for the SWAG reverse proxy |
| `openwebui_swag_validation` | `http` | VALIDATION method for the SWAG reverse proxy |
| `openwebui_swag_email` | `admin@example.com` | EMAIL for the SWAG reverse proxy certbot |
| `openwebui_swag_staging` | `true` | SWAG STAGING mode (true = self-signed) |
| `openwebui_kokoro_device` | `cpu` | Device the Kokoro TTS runs on |
| `openwebui_kokoro_log_level` | `info` | Log level for the Kokoro TTS service |

The `openwebui_common_dir`, `openwebui_dir`, `openwebui_swag_dir`, and
`openwebui_kokoro_dir` variables hold the relative folder paths used in
the root `.env` — see [`meta/argument_specs.yml`](meta/argument_specs.yml)
for the full list.

## Dependencies

- `odem.base.common`

## Example usage

```yaml
- hosts: all
  become: true
  roles:
    - odem.services.docker
    - odem.services.openwebui
```

## Role metadata

- **Min Ansible version**: `2.16.0`
- **License**: GPL-3.0-or-later
- **Platforms**: Debian (trixie)

## Related files

- [`meta/main.yml`](meta/main.yml) — galaxy_info + role dependencies
- [`meta/argument_specs.yml`](meta/argument_specs.yml) — variable spec (the source of the variable table above)
- [`defaults/main.yml`](defaults/main.yml) — variable defaults (the source of the default values above)
