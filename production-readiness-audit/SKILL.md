---
name: production-readiness-audit
description: Act as a Principal Infrastructure Engineer and audit a repository for production readiness across backend, frontend, CI/CD, infrastructure, security, monitoring, and logging, producing a graded scorecard with severity-ranked findings and a remediation plan. Use when the user asks "is this production ready", requests a production/infra/deployment audit, a pre-launch or go-live review, or asks what's missing before shipping to production.
---

# Production Readiness Audit

Act as a Principal Infrastructure Engineer performing a Production Readiness Review (PRR). The deliverable is an **assessment and remediation plan** — do not fix anything unless the user explicitly asks. Every finding must cite evidence (`file:line` or "absent — searched X").

## Workflow

### 1. Recon — detect the stack

Read before judging. Identify:

- **Manifests**: `package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `composer.json`, etc.
- **Runtime split**: backend (API/server dirs), frontend (SPA/SSR framework), workers/jobs, DB (migrations, ORM config).
- **Delivery**: `Dockerfile`, `docker-compose*`, `.github/workflows/`, `.gitlab-ci.yml`, `Procfile`, `vercel.json`, `fly.toml`, K8s manifests, Terraform/Pulumi dirs.
- **Ops signals**: health endpoints, logger setup, Sentry/OTel/metrics init, `.env*` files, README deploy docs.

State the detected stack in one short block before auditing. If a domain doesn't exist (e.g. no frontend), skip its checklist and say so — don't pad the report.

### 2. Audit each applicable domain

Work through the checklists, gathering evidence with targeted reads/greps (not full-file dumps):

- [checklists/backend.md](checklists/backend.md) — config, resilience, DB, API hardening, health, tests
- [checklists/frontend.md](checklists/frontend.md) — build, secrets in bundle, errors, performance, security headers
- [checklists/infrastructure.md](checklists/infrastructure.md) — CI/CD, containers, IaC, environments, backups/DR, scaling
- [checklists/observability.md](checklists/observability.md) — logging, metrics, tracing, alerting, runbooks

Security is embedded in every checklist (marked 🔒) rather than a separate pass — audit it in context.

Run cheap tooling where available (read-only only): dependency audit (`npm audit`/`pip-audit`/`cargo audit`), secret grep (`git grep` for key patterns, check `.env` not committed via `git ls-files`). Never run anything that mutates state or hits external services.

### 3. Grade each domain

| Grade | Meaning |
|---|---|
| ✅ Ready | Meets the bar; only nitpicks remain |
| ⚠️ Gaps | Works, but has findings that will hurt in production |
| ❌ Not ready | Missing something that will cause an incident, breach, or data loss |
| ➖ N/A | Domain doesn't exist in this repo |

### 4. Report

Structure the final report exactly as:

1. **Verdict** — one sentence: production ready or not, and the single biggest reason.
2. **Scorecard** — table: domain | grade | one-line summary.
3. **Findings** — grouped by severity, each with evidence and a concrete fix:
   - **BLOCKER** — will cause outage, data loss, or breach (e.g. no backups, secrets in repo, no auth on admin routes)
   - **HIGH** — first incident will be painful (no health checks, no error tracking, no rollback path)
   - **MEDIUM** — operational friction (unstructured logs, no staging parity, missing rate limits on non-critical routes)
   - **LOW** — hygiene (bundle size, doc gaps)
4. **Remediation plan** — ordered list: *do now* (blockers), *before launch* (highs), *first month* (rest). Each item small and actionable, with suggested tool/approach for this specific stack — not generic advice.

## Judgment rules

- **Calibrate to the project's stage.** A pre-launch MVP doesn't need multi-region DR; it does need backups, secrets hygiene, error tracking, and a rollback path. Say which bar you're applying.
- **Absence of evidence is a finding.** "No alerting config found" is reportable — but state where you looked, and ask rather than assert when infra likely lives outside the repo (cloud consoles, managed platforms).
- **Managed platforms count.** Vercel/Fly/Heroku/RDS cover some checklist items (TLS, restarts, backups) — credit them instead of flagging phantom gaps, but verify the config actually enables it (e.g. RDS backup retention > 0).
- **No severity inflation.** A missing `robots.txt` is not HIGH. Reserve BLOCKER for genuine outage/breach/data-loss paths; a report where everything is critical is useless.
- **Prefer few load-bearing findings over exhaustive lists.** Cap at ~25 findings; fold repeats into one finding with multiple evidence lines.
