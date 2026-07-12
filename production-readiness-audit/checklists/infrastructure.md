# Infrastructure & Delivery Checklist

Audit against these; cite evidence per item. 🔒 = security-critical.

## CI/CD

- Automated pipeline exists and gates merges: lint, typecheck, tests, build must pass before deploy — a green-but-empty pipeline (no tests run) is a finding.
- Deploys are reproducible: versioned artifacts/images, not "SSH in and git pull".
- **Rollback path exists and is documented** — redeploy previous image/release, platform rollback, or revert-and-redeploy. "Fix forward only" with slow builds is HIGH.
- 🔒 CI secrets in the CI provider's secret store, not echoed in logs or committed; deploy credentials scoped least-privilege (not an org-admin PAT).
- Migrations ordered correctly in the deploy sequence (run before/after app rollout deliberately, not by accident).

## Containers (if Dockerized)

- Multi-stage build; final image slim (no build toolchain, no dev deps in production image).
- 🔒 Runs as non-root user; base image pinned (digest or specific tag, not `latest`).
- `.dockerignore` excludes `.env`, `.git`, `node_modules` — 🔒 check `.env` isn't baked into an image layer.
- Resource requests/limits set (K8s) or instance sizing documented (PaaS).

## Environments

- At least: local, staging (or preview deploys), production — with config isolation; staging must not point at production DB or third-party production keys.
- Staging reasonably mirrors production topology (same DB engine, same platform) — SQLite-in-dev/Postgres-in-prod is a classic drift finding.
- Production infra is reproducible: IaC (Terraform/Pulumi/CDK), platform config files (`fly.toml`, `render.yaml`), or at minimum a written runbook. Fully console-clicked infra with no record is HIGH.

## Network & platform 🔒

- TLS everywhere, HTTP→HTTPS redirect, HSTS (usually platform-provided — verify).
- Only intended surfaces public: DB, cache, admin ports not internet-exposed; internal services on a private network.
- IAM/service credentials least-privilege: app talks to DB as a limited user, not superuser; cloud roles scoped, no long-lived root keys.
- DNS + domain config sane; certificate renewal automated.

## Data safety & DR

- 🔒 Automated backups with retention for every stateful store (DB, uploaded files, queues if durable) — and a **documented, ideally tested restore procedure**.
- Know the blast radius: what's lost if the primary DB dies now? If the answer is "everything since launch", that's BLOCKER.
- Single points of failure identified — one VM running everything is acceptable at MVP stage *if stated and monitored*, but it must be a conscious decision.

## Scaling & capacity

- App is stateless enough to run 2+ instances (sessions in DB/redis not memory, uploads to object storage not local disk) — even if currently running one.
- Autoscaling or documented manual scaling procedure; expected load estimated at least roughly.
- Cost visibility: someone gets a bill and would notice a 10x spike (billing alerts count).
