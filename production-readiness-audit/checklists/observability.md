# Observability Checklist

Audit against these; cite evidence per item. 🔒 = security-critical.
The bar: **when production breaks at 3am, can someone find out what, where, and why without SSHing in and guessing?**

## Logging

- Structured logging (JSON or key-value) via a real logger with levels — `console.log`/`print` scattered through handlers is a finding.
- Logs centralized off the box/container: platform log drain, CloudWatch, Loki, Datadog, etc. Logs that die with the container are HIGH.
- Request-scoped correlation: request ID (and user/tenant ID where lawful) attached to log lines so one request's story is greppable.
- 🔒 No secrets or sensitive PII in logs — check that auth headers, passwords, tokens, card data are redacted; logging full request bodies is a red flag.
- Retention defined; noisy debug logging not enabled in production.

## Error tracking

- Exception tracker wired on **both** backend and frontend (Sentry/Bugsnag/Rollbar/GlitchTip) with environment + release tagging.
- Unhandled rejections/panics captured, not just try/catch paths.
- Someone is notified of new error types — a tracker nobody looks at scores half credit.

## Metrics & dashboards

- The four golden signals available for the serving path: latency, traffic, errors, saturation — via APM, platform metrics, or self-hosted Prometheus/Grafana.
- Infra basics visible: CPU/memory/disk of runtime, DB connections/slow queries, queue depth for workers.
- A dashboard (even one) that answers "is the system healthy right now?" — platform-provided dashboards count.

## Alerting

- Alerts on user-facing symptoms first: error-rate spike, latency, uptime/health-check failure, queue backlog, disk/DB near capacity, cert expiry.
- Alerts reach a human (email/Slack/PagerDuty/phone) — a Grafana alert to nowhere doesn't count.
- External uptime check from outside the infrastructure (UptimeRobot/Pingdom/healthchecks.io class) — internal monitoring can't see "the whole box is down".
- Actionable, low-noise: if everything pages, nothing does. Symptom-based over cause-based.

## Tracing (calibrate to architecture)

- Multi-service/microservices: distributed tracing (OpenTelemetry or APM equivalent) is expected — its absence is MEDIUM+.
- Single monolith + DB: full tracing is optional; slow-query logging and APM-level timing suffice. Don't flag phantom gaps.

## Runbooks & on-call reality

- Deploy + rollback procedure written down where a stressed human can find it (README/RUNBOOK/wiki link).
- Known failure modes documented with responses ("DB connections exhausted → check X, restart Y").
- Clear answer to "who gets woken up and how" — even solo-founder "alerts go to my phone" counts if stated.
