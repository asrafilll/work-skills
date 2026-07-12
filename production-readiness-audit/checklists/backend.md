# Backend Checklist

Audit against these; cite evidence per item. 🔒 = security-critical.

## Configuration & secrets

- 🔒 No secrets committed: grep for API keys, tokens, passwords, private keys; check `git ls-files | grep -i env` — `.env` files must be gitignored (`.env.example` with placeholders is fine).
- Config via environment variables (12-factor), not hardcoded per-environment constants or `if (env === 'prod')` branches scattered through code.
- 🔒 Secrets sourced from a secret manager or platform env config in production — README/deploy docs should show how, not "paste into .env on the server".
- Required config validated at boot (fail fast with a clear message, not `undefined` at request time).

## Resilience

- Graceful shutdown: handles SIGTERM — stops accepting connections, drains in-flight requests, closes DB pool. Critical under containers/autoscaling.
- Timeouts on every outbound call (HTTP clients, DB queries). Default no-timeout clients are a finding.
- Retries with backoff + jitter for transient failures on idempotent calls only; circuit breaker or fallback for critical dependencies.
- Background jobs/queues: retry policy, dead-letter handling, idempotent handlers (at-least-once delivery assumed).

## Database

- Migrations versioned in repo and run via tooling (not manual SQL); rollback/down path or forward-fix convention stated.
- Connection pooling configured with sane bounds (not per-request connections; pool size vs. DB max connections).
- Indexes exist for hot query paths; look for obvious N+1 patterns in ORM usage.
- 🔒 Backups: automated, retention set, and **restore tested/documented** — an untested backup is a hope, not a backup. (May live in platform config — verify, don't assume.)
- Destructive migration safety: no dropping columns/tables in the same deploy that stops reading them.

## API hardening

- 🔒 AuthN on every non-public route; authZ (ownership/role checks) on object access — look for IDOR patterns (fetch by id without owner check).
- 🔒 Input validation at the boundary (schema validation — zod/joi/pydantic/etc.), not ad-hoc deep in handlers.
- 🔒 Rate limiting on auth endpoints (login, signup, password reset) at minimum; ideally global.
- Pagination on list endpoints (unbounded `SELECT *` behind an API is a future outage).
- Consistent error responses; 🔒 no stack traces or internal details leaked in production error bodies.
- Idempotency keys or safe-retry semantics for payment/mutation endpoints that clients may retry.
- 🔒 CORS: explicit origin allowlist in production, not `*` with credentials.

## Health & lifecycle

- Liveness endpoint (process up) and readiness endpoint (dependencies reachable) — distinct, and wired into the orchestrator/platform.
- Version/build metadata exposed (endpoint, header, or startup log) so you can tell what's deployed.

## Tests & dependencies

- Tests exist for the money paths (auth, payments, core domain logic) and run in CI as a merge gate — coverage % matters less than *what* is covered.
- Lockfile committed; 🔒 dependency vulnerability scanning in CI or at least runnable (`npm audit`, `pip-audit`, `cargo audit`, dependabot/renovate config).
- No abandoned/deprecated critical dependencies (check for years-dead packages on the hot path).
