# Scaling & Capacity

Can it grow with load without a rewrite, and will someone notice before the bill or the latency does? AWS Well-Architected **Performance Efficiency** + **Cost Optimization**. Cite evidence per item.

## Statelessness (the precondition for scaling)

- App is **stateless enough to run N instances**: sessions in DB/Redis not process memory; uploads to object storage not local disk; no in-process caches assumed authoritative; no sticky-session dependency. Local state that breaks at 2 instances is HIGH — it blocks both scaling and rolling deploys.
- Sticky/affinity requirements, if any, are explicit and justified, not accidental.

## Horizontal scaling & autoscaling

- Horizontal scaling is possible and configured or documented: load balancer in front, replica count adjustable.
- Autoscaling with sane **min/max bounds** and a sensible signal (CPU, RPS, queue depth). Missing max is a cost/DoS-amplification risk; missing min risks cold-start on wake.
- **Resource requests and limits set on every container** (K8s/containers) — without requests the scheduler can't place pods well; without limits one pod can starve neighbors (noisy-neighbor OOM). This is a top production-readiness miss; absence is HIGH on K8s.
- Scaling the stateful tier considered too: DB read replicas / connection limits, not just the stateless app. A stateless app that scales into a DB connection ceiling just moves the bottleneck.

## Capacity & load

- Expected load estimated at least roughly (RPS, concurrent users, data growth) — you can't size or set autoscaler bounds without a number.
- Known throughput ceilings identified: DB max connections vs pool sizes across all instances, rate limits on third-party APIs, queue throughput.
- Connection pooling configured with bounds that account for **instance count × pool size ≤ DB max connections** — a classic outage when the app scales out.

## Cost visibility

- Someone gets the bill and would **notice a 10x spike** — billing/budget alerts configured (cloud budget alert, platform spend notification).
- No obvious cost footguns: unbounded autoscaling max, per-request expensive operations with no cap, egress-heavy patterns, always-on oversized instances for a low-traffic service.
- Cost visibility is LOW/MEDIUM for most launches — but an unbounded autoscaler with no budget alert is a real "surprise $50k bill" risk worth flagging.
