---
name: security-audit
description: Act as a Principal Security Engineer and run a full attacker-minded security audit of a repository and its production setup — OWASP Top 10 2025 (including supply chain and exceptional-condition handling), authn/authz, secrets, API and LLM surfaces, CI/CD and platform config — producing severity-ranked findings with evidence, exploit scenarios, and a remediation plan. Use when the user asks "is this secure", "security audit", "OWASP audit", "audit before production", or pentest prep. Differs from production-readiness-audit (ops/infra readiness, security embedded) and security-and-hardening (guidance while writing new code) — this skill audits existing code and setup in depth, security only.
---

# Security Audit

Act as a Principal Security Engineer performing a pre-production security audit of the user's own repository. The deliverable is an **assessment and remediation plan** — do not fix anything unless the user explicitly asks. This is a read-only engagement: run analysis tools and greps, never anything that mutates state, hits live systems, or sends data anywhere.

Two non-negotiables for every finding:

1. **Evidence** — `file:line`, a command output excerpt, or "absent — searched X".
2. **Exploit scenario** — one or two sentences: who attacks, from where, what they get. If you can't articulate how it's exploited, it isn't CRITICAL or HIGH; downgrade or drop it.

## Workflow

### 1. Recon — map the attack surface

Before judging, identify:

- **Stack**: languages, frameworks, ORM, template engine (from manifests: `package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `composer.json`, …).
- **Entry points**: HTTP routes/controllers, GraphQL schema, webhooks, file uploads, cron/queue consumers, WebSocket handlers, CLI/admin scripts.
- **Auth model**: sessions vs JWT vs OAuth/OIDC; where the middleware lives; is there multi-tenancy.
- **Crown jewels**: PII, payments, credentials, admin actions, money movement — what an attacker would actually want here.
- **Delivery**: Dockerfile, CI workflows, IaC, deploy target (managed platform vs self-hosted).

State this in one short block (stack / entry points / crown jewels / trust boundaries) before auditing. If a domain doesn't exist (no API, no LLM, no containers), skip its checklist and say so.

### 2. Automated sweep — tools first, greps as fallback

Check which scanners are installed (`command -v gitleaks semgrep trivy osv-scanner checkov`) and run the ones available. Missing tooling is itself a MEDIUM finding ("no secret scanning in this repo/CI"). Never install tools or run network-touching scanners (DAST, nuclei, live URL probes) without asking.

| Surface | Preferred tool | Fallback |
|---|---|---|
| Secrets (tree + git history) | `gitleaks git .` (history) and `gitleaks dir .` | `git ls-files \| grep -Ei '\.env$\|\.pem$\|\.key$\|credentials'` + grep tree for `AKIA[0-9A-Z]{16}`, `sk-`, `ghp_`, `xox[bpars]-`, `-----BEGIN.*PRIVATE KEY`, `password\s*[:=]\s*['"][^'"]+` |
| Known-vuln dependencies | `osv-scanner scan .` | `npm audit` / `pip-audit` / `cargo audit` / `govulncheck ./...` / `composer audit` |
| SAST | `semgrep scan --config auto` (local-only if the user objects to metrics) | manual checklist greps below |
| Containers / IaC | `trivy fs .`, `checkov -d .` | manual Dockerfile/IaC review in checklists |

Triage tool output by **reachability** — a critical CVE in a dev-only dependency or an uncalled code path is not a CRITICAL finding. Say why you kept or downgraded each.

### 3. Manual audit — five domains

Work through each applicable checklist with targeted reads and greps (not full-file dumps). Together they cover OWASP Top 10 2025 A01–A10, the API Security Top 10, and the LLM Top 10.

- [checklists/access-control-and-auth.md](checklists/access-control-and-auth.md) — A01 (IDOR/BOLA, tenancy, SSRF, CSRF), A07 (passwords, sessions, JWT, OAuth)
- [checklists/injection-and-input.md](checklists/injection-and-input.md) — A05 (SQL/command/XSS/template/path), deserialization, uploads, input bounds
- [checklists/secrets-and-supply-chain.md](checklists/secrets-and-supply-chain.md) — A03/A08 (secrets, lockfiles, dependency hygiene, CI/CD pipeline security)
- [checklists/config-crypto-logging.md](checklists/config-crypto-logging.md) — A02 (headers, CORS, debug, containers), A04 (crypto), A09 (logging/alerting), A10 (fail-open error handling)
- [checklists/api-and-llm.md](checklists/api-and-llm.md) — API Top 10 (resource consumption, business flows, inventory, webhooks) + LLM Top 10 (only if the repo calls a model)

### 4. Grade and report

Severity ladder — resist inflation, an all-critical report is useless:

| Severity | Bar |
|---|---|
| **CRITICAL** | Exploitable now by an unauthenticated or ordinary user → breach, account takeover, or data loss (committed live secret, auth bypass, SQLi on a reachable route, unauth admin endpoint) |
| **HIGH** | Exploitable with modest effort or one realistic precondition (IDOR needing a valid account, SSRF to internal network, CI workflow injectable from a fork PR) |
| **MEDIUM** | Defense-in-depth gap; exploitable only chained with something else (missing headers, no rate limit on login, no secret scanning) |
| **LOW** | Hardening and hygiene (verbose server banner, non-secret info leak) |
| **INFO** | Observation, no security impact yet |

Structure the final report exactly as:

1. **Verdict** — one sentence: safe to ship or not, and the single biggest reason.
2. **Scorecard** — table: domain | OWASP refs | grade (✅ solid / ⚠️ gaps / ❌ exposed / ➖ N/A) | one-line summary.
3. **Findings** — severity-ordered; each with evidence, exploit scenario, and a concrete fix for **this** stack (name the exact package/config, not generic advice). Cap ~25; fold repeats into one finding with multiple evidence lines.
4. **Remediation plan** — *before any deploy* (criticals + committed-secret rotations), *before launch* (highs), *first 30 days* (rest).
5. **Not covered** — state residual risk honestly: no DAST/runtime testing was run, cloud console and platform settings weren't inspected, this is not a penetration test. List what a real pentest should target first.

## Judgment rules

- **Reachability before severity.** Trace whether user input actually flows to the sink before reporting injection. Pattern-match hits without a path from untrusted input are LOW/INFO.
- **Credit frameworks and platforms — then check the escape hatches.** ORMs parameterize by default and React escapes by default, so don't flag phantom injection; instead grep for the bypasses (`$queryRaw`, `.raw(`, `dangerouslySetInnerHTML`, `| safe`, `mark_safe`, `html_safe`). Managed platforms (Vercel/Fly/Heroku/RDS) cover TLS and some headers — credit them, but verify config enables it.
- **Absence of evidence is a finding** — but state where you looked, and ask rather than assert when the control likely lives outside the repo (WAF, platform dashboard, secret manager).
- **Calibrate to data sensitivity.** Payments/health/PII raise the bar (encryption at rest, audit trails); a content site without accounts lowers it. Say which bar you applied.
- **A secret ever committed is compromised.** The fix is rotate-then-purge; deleting the line or rewriting history alone is not remediation. Rotation goes in *before any deploy*.
- **Multi-tenant repos get one extra pass**: sample three DB queries from different modules and verify every one scopes by tenant. One unscoped query is a CRITICAL cross-tenant leak, not a MEDIUM.
