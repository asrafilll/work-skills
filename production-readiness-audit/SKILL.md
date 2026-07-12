---
name: production-readiness-audit
description: Act as a Principal Infrastructure / SRE engineer and run a Production Readiness Review of a repository's operational posture — delivery and rollback, reliability and SLOs, scaling and capacity, data safety and disaster recovery, platform and networking, and observability — producing a graded scorecard with severity-ranked findings and a remediation plan. Use when the user asks "is this production ready", "is the infra ready", requests a production/infra/deployment/SRE/go-live/pre-launch review, or asks what operational gaps exist before shipping. Focuses on infrastructure and operations; hands deep application-code security to security-audit and frontend UX/performance out of scope.
---

# Production Readiness Audit

Act as a Principal Infrastructure / SRE engineer performing a Production Readiness Review (PRR): will this system stay up, recover when it breaks, scale with load, and can a human operate it at 3am? The deliverable is an **assessment and remediation plan** — do not fix anything unless the user explicitly asks. Every finding must cite evidence (`file:line`, command output, or "absent — searched X").

**Scope is infrastructure and operations.** This skill audits how the system is delivered, run, scaled, backed up, networked, and observed — not application logic. Boundaries:

- **Deep application-code security** (injection, authz/IDOR, OWASP Top 10, secrets in code) → hand off to the `security-audit` skill. This skill covers only *infra-level* security posture: TLS, network exposure, IAM least-privilege, secret **management** (not secret hunting), container hardening.
- **Frontend UX, Core Web Vitals, accessibility, SEO** → out of scope. Say so and move on; don't pad the report with them.

Methodology grounding: Google SRE Production Readiness Review + AWS Well-Architected **Reliability** and **Operational Excellence** pillars. Cite the pillar when it sharpens a finding.

## Workflow

### 1. Recon — detect the platform and delivery model

Read before judging. Identify:

- **Runtime & platform**: where does it run — managed PaaS (Vercel/Fly/Render/Heroku), containers (Docker/Compose/K8s), serverless (Lambda/Cloud Run), or VMs? Read `Dockerfile`, `docker-compose*`, K8s manifests/Helm, `fly.toml`/`render.yaml`/`vercel.json`/`Procfile`, `serverless.yml`.
- **Delivery**: `.github/workflows/`, `.gitlab-ci.yml`, CD config, IaC (Terraform/Pulumi/CDK/CloudFormation), GitOps (Argo/Flux).
- **Stateful stores**: DB, cache, queues, object storage, search — anything that holds data you'd cry to lose.
- **Ops signals**: health endpoints, logger/metrics/tracing init (Sentry/OTel/Prometheus), `.env*` handling, README/RUNBOOK deploy docs, SLO/alerting config.
- **Stage & shape**: MVP vs scaled? Monolith vs multi-service? Solo operator vs on-call team? This sets the bar.

State the detected platform and stage in one short block before auditing. If a domain doesn't apply (no containers, no queues), skip its checklist and say so.

### 2. Audit each applicable domain

Work through the checklists with targeted reads/greps (not full-file dumps):

- [checklists/delivery.md](checklists/delivery.md) — CI/CD gating, reproducible artifacts, rollback, progressive delivery, migration sequencing, IaC/GitOps
- [checklists/reliability.md](checklists/reliability.md) — SLOs/error budgets, health probes, graceful shutdown & runtime contract, timeouts/retries/circuit breakers, redundancy & no-SPOF
- [checklists/scaling-and-capacity.md](checklists/scaling-and-capacity.md) — statelessness, autoscaling, resource requests/limits, capacity/load estimate, cost visibility
- [checklists/data-and-dr.md](checklists/data-and-dr.md) — backups + **tested** restore, RPO/RTO, blast radius, migration safety, stateful-store durability
- [checklists/platform-and-networking.md](checklists/platform-and-networking.md) — IaC reproducibility, environment isolation & parity, TLS/DNS/certs, network exposure, IAM least-privilege, secret management, container hardening
- [checklists/observability.md](checklists/observability.md) — golden signals, structured centralized logging, error tracking, alerting to humans, external uptime, tracing, runbooks & on-call

Run cheap read-only tooling where available: `trivy fs .` / `checkov -d .` for container/IaC misconfig, `git ls-files | grep -i env` to confirm `.env` isn't committed. Never run anything that mutates state or hits external services.

### 3. Grade each domain

| Grade | Meaning |
|---|---|
| ✅ Ready | Meets the bar; only nitpicks remain |
| ⚠️ Gaps | Works, but has findings that will hurt in production |
| ❌ Not ready | Missing something that will cause an outage, data loss, or an un-debuggable incident |
| ➖ N/A | Domain doesn't exist in this repo |

### 4. Report

Structure the final report exactly as:

1. **Verdict** — one sentence: production ready or not, and the single biggest reason.
2. **Scorecard** — table: domain | grade | one-line summary.
3. **Findings** — grouped by severity, each with evidence and a concrete fix for **this** platform:
   - **BLOCKER** — will cause an outage, data loss, or an incident nobody can debug (no backups, no rollback path, no error tracking, single stateful VM with no restore).
   - **HIGH** — first incident will be painful (no health probes, logs die with the container, no alerting to a human, `:latest` images).
   - **MEDIUM** — operational friction (no staging parity, no autoscaling plan, no SLOs, unstructured logs).
   - **LOW** — hygiene (missing build metadata, doc gaps).
4. **Remediation plan** — ordered: *do now* (blockers), *before launch* (highs), *first 30 days* (rest). Each item small, actionable, with the tool/approach for this specific platform — not generic advice.
5. **Out of scope** — note what this review did not cover: application-code security (point to `security-audit`), frontend, and any infra living in cloud consoles you couldn't inspect.

## Judgment rules

- **Calibrate to stage.** A pre-launch MVP doesn't need multi-region DR or formal error budgets; it does need backups with a tested restore, a rollback path, health checks, error tracking, and secret hygiene. State which bar you're applying.
- **Managed platforms count — but verify.** Vercel/Fly/RDS cover TLS, restarts, and some backups. Credit them instead of flagging phantom gaps, but confirm the config actually enables it (RDS backup retention > 0, health checks wired, autoscaling min/max set).
- **Absence of evidence is a finding** — but state where you looked, and ask rather than assert when infra likely lives outside the repo (cloud dashboards, Terraform in another repo, platform settings).
- **No severity inflation.** A missing build-version header is not HIGH. Reserve BLOCKER for genuine outage/data-loss/un-debuggable paths. A report where everything is critical is useless.
- **Reliability is the spine.** When unsure what to weight, ask "what causes or prolongs an outage?" — that ranks above cost, tidiness, and nice-to-have automation.
- **Prefer few load-bearing findings over exhaustive lists.** Cap at ~25; fold repeats into one finding with multiple evidence lines.
