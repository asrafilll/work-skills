# Reliability & Resilience

The spine of the review: does the system stay up, degrade gracefully, and recover on its own? AWS Well-Architected **Reliability** + Google SRE. Cite evidence per item.

## SLOs & error budgets

- Are there defined SLIs/SLOs at all — availability and latency targets tied to user experience (e.g. 99.9% availability, p95 < 300ms)? Their absence is MEDIUM for an MVP, HIGH for anything with users depending on it: without an SLO you can't tell "healthy" from "on fire".
- SLOs are measured from something a user feels (request success rate, latency) — not just "CPU is fine".
- Error-budget posture (even informal): is there a rule for when to stop shipping features and fix reliability? Formal error budgets are a scale concern; a stated "if we breach X we freeze" is enough early.

## Health signals & the runtime contract

- **Liveness** (process alive) and **readiness** (dependencies reachable, ready to serve) are **distinct** endpoints, and wired into the orchestrator/platform. Using one for both means either dead pods get traffic or healthy pods get killed. Missing readiness under an orchestrator is HIGH.
- **Startup** probe for slow-booting apps (K8s) so liveness doesn't kill them mid-boot.
- **Graceful shutdown**: handles SIGTERM — stops accepting new work, drains in-flight requests, closes DB pool/connections within the grace period. Critical under rolling deploys and autoscaling; abrupt exit drops live requests on every deploy.
- Runtime contract for orchestrated/serverless: config from environment (12-factor), no local disk state assumed durable, connections re-established on reconnect.

## Timeouts, retries, and blast-radius control

- **Timeouts on every outbound call** (HTTP clients, DB queries, cache). A default no-timeout client is a finding — one slow dependency exhausts the pool and cascades.
- Retries with **backoff + jitter**, on idempotent calls only. Naive immediate retries amplify an outage (retry storm).
- Circuit breaker or fallback for critical dependencies so one failing service doesn't take the whole app down.
- Bulkheading / connection-pool limits per dependency so one saturated downstream can't consume all workers.
- Background jobs/queues: retry policy, dead-letter handling, and **idempotent handlers** (at-least-once delivery must be assumed).

## Redundancy & single points of failure

- Runs (or can run) **2+ instances** behind a load balancer — statelessness permitting (see scaling checklist). One instance = one restart is an outage.
- Multi-AZ / multi-node for anything claiming HA; a single-AZ deployment is a conscious tradeoff, not HA.
- **Pod Disruption Budget** (K8s) so voluntary disruptions (node drain, upgrade) don't take all replicas at once.
- **Named single points of failure**: one VM running app + DB + cache is acceptable *at MVP stage if stated and monitored* — but it must be a conscious, documented decision, and the DR story (data-and-dr.md) must match. An unacknowledged SPOF holding production data is BLOCKER.
