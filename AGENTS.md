# AGENTS.md — odem-services

Service deployment and configuration — system-level service roles
(e.g. OpenVPN server configuration sourced from the `mps-openvpn`
config repo). The first role is not yet created.

## Galaxy

- **namespace**: `odem`
- **name**: `services`
- **version**: `0.3.2`
- **dependencies**: `odem.base >=0.1.0`, `ansible.posix >=1.0.0`

## Roles

None yet.

## Conventions

- Follows the cross-collection conventions documented in the root
  `AGENTS.md` / `manage/AGENTS.md` (task naming, toggle pattern,
  install/facts/configure sub-steps).
- Roles will be system-level unless noted; per-user roles opt in via
  `user_roles.services_<x>` keys.
- `changelogs/` intentionally absent — added at first release.
