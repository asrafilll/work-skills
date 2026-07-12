# Platform & Networking

Infra-level security and environment posture — the operational surface, not application-code vulnerabilities. For injection, authz, secrets-in-code, and the OWASP Top 10, hand off to the `security-audit` skill and say so. Cite evidence per item.

## Environments & isolation

- At least local, staging (or preview deploys), and production, with **config isolation** — staging must not point at the production DB or production third-party keys. Shared prod credentials across envs is HIGH.
- **Staging mirrors production topology**: same DB engine, same platform, similar scaling. SQLite-in-dev / Postgres-in-prod is a classic drift finding — bugs hide in the gap.
- Environment config injected at deploy (12-factor), not hardcoded per-env branches (`if (env === 'prod')`) scattered through code.
- Required config validated at boot — fail fast with a clear message, not `undefined` at request time in production.

## Secret management (management, not hunting)

- Secrets sourced from a secret manager or platform env store in production (AWS Secrets Manager / SSM, Vault, platform env config) — not pasted into a `.env` on the server, not baked into images.
- `.env` is gitignored (`git ls-files | grep -i env` returns nothing but `.env.example`). *Deep scanning for committed secrets and rotation is `security-audit`'s job — here just confirm the management pattern exists.*
- A rotation story exists for high-value credentials (even "we rotate manually on incident" counts if stated).

## Network exposure

- **Only intended surfaces are public.** DB, cache, admin panels, metrics/actuator, internal services are on a private network or firewalled — not internet-exposed. A publicly reachable database port is BLOCKER.
- Security groups / firewall rules least-open; no `0.0.0.0/0` on management ports (SSH, DB) unless justified and compensated.
- Internal service-to-service traffic on a private network / VPC, not the public internet.

## TLS, DNS & certificates

- TLS everywhere, HTTP→HTTPS redirect, HSTS. Usually platform-provided — credit it but verify it's on.
- Certificate renewal automated (ACM, cert-manager, platform-managed). A manually-renewed cert is a scheduled outage.
- DNS config sane; no dangling records pointing at deprovisioned resources (subdomain-takeover risk — note it, defer depth to security-audit).

## IAM & least privilege

- App talks to the DB as a **limited user**, not superuser/root.
- Cloud roles/service accounts scoped to what the workload needs; no long-lived root/org-admin keys used by the app or CI. CI deploy credentials scoped least-privilege, not a personal org-admin PAT.
- Workload identity / short-lived credentials preferred over static long-lived keys where the platform supports it.

## Container & runtime hardening

- Multi-stage build; final image slim (no build toolchain or dev deps in the production image).
- Runs as **non-root**; base image pinned by digest or specific tag, not `:latest`.
- `.dockerignore` excludes `.env`, `.git`, `node_modules`; confirm `.env` isn't baked into an image layer.
- Read-only root filesystem and dropped capabilities where feasible; no `--privileged` containers.
- Run `trivy fs .` / `checkov -d .` (read-only) for image and IaC misconfiguration; triage by exposure.
