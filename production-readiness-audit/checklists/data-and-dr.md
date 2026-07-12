# Data Safety & Disaster Recovery

The findings here are the ones that end companies: lose the data, and there's no rollback. Weight this domain heavily. AWS Well-Architected **Reliability**. Cite evidence per item.

## Backups

- **Automated backups with retention for every stateful store** — primary DB, but also uploaded files/object storage, durable queues, and any secondary datastore (search index, cache-as-source-of-truth). A stateful store with no backup is BLOCKER.
- Backups stored separately from the primary (different account/region ideally) so one compromised or deleted resource doesn't take the backups with it.
- Point-in-time recovery or frequent-enough snapshots that the potential data loss window is acceptable for the business.

## Restore is tested, not hoped

- **A documented, ideally rehearsed restore procedure.** An untested backup is a hope, not a backup — restores fail in practice (wrong format, missing credentials, incomplete snapshot). "Backups are on" with no restore doc is still HIGH.
- Restore time is known and acceptable — a 12-hour restore for a service that promises hours of recovery is a mismatch.

## RPO / RTO & blast radius

- **RPO** (how much data can we lose) and **RTO** (how long to recover) are stated, even informally, and the backup cadence + restore time actually meet them.
- **Blast radius named**: what is lost, and for how long, if the primary DB dies right now? If the honest answer is "everything since launch" or "we don't know", that's BLOCKER.
- DR story matches the redundancy story (reliability.md): a single-instance stateful VM with no off-box backup is the most common fatal gap in an MVP.

## Migration & data-integrity safety

- Destructive migration safety (cross-referenced with delivery.md): no dropping data in the same deploy that stops reading it; destructive operations are reversible or explicitly accepted.
- Multi-step mutations that touch money/critical records are transactional or have compensating logic — a partial failure must not leave half-written state.
- Data retention/deletion honors any legal obligation (GDPR/CCPA erasure) if PII is stored — note it if relevant, defer detail to legal/compliance.
