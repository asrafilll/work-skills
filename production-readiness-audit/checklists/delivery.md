# Delivery & Deployment

How code becomes a running production system, and how you get back to the last good state when it goes wrong. AWS Well-Architected **Operational Excellence**. Cite evidence per item.

## Pipeline & gating

- Automated CI pipeline exists and **gates merges**: lint, typecheck, tests, build must pass before deploy. A green-but-empty pipeline (no tests actually run) is a finding.
- Deploy is triggered by a repeatable mechanism (merge to branch, tag, CD tool) — not a human running commands from their laptop.
- Build and deploy are separate concerns: build once, promote the **same artifact** through environments (don't rebuild per environment — that reintroduces drift).

## Reproducible artifacts

- Versioned, immutable artifacts/images tagged by commit SHA or release — not "SSH in and `git pull`", not `:latest`.
- Build metadata (commit, version, build time) baked in and exposed (endpoint/header/startup log) so you can tell exactly what's deployed.
- Lockfile committed and CI installs pinned (`npm ci`, `--frozen-lockfile`, hashed requirements) — reproducible builds, no silent version drift.

## Rollback & progressive delivery

- **Rollback path exists and is documented** — redeploy previous image/release, platform rollback button, or revert-and-redeploy. "Fix forward only" with slow builds is HIGH; a fast, tested rollback is the single most valuable safety net.
- Rollback is verified to actually work, not assumed — especially that it's compatible with the current DB schema (see migration safety below).
- Progressive delivery for higher-stakes systems: canary, blue-green, or health-gated rollout with auto-rollback on error-rate/latency breach. Absence is MEDIUM at scale, N/A for an MVP — calibrate.

## Migration sequencing

- Schema migrations versioned in repo and run via tooling (not manual SQL), with a rollback/down path or a stated forward-fix convention.
- Migrations ordered in the deploy sequence deliberately (run before/after app rollout on purpose, not by luck).
- **Expand/contract discipline**: no dropping or renaming a column/table in the same deploy that stops reading it, and no adding a NOT NULL column with no default while old code still runs. A migration that breaks the currently-serving version — or blocks rollback — is HIGH.
- Long-locking migrations (large table rewrites, index builds) flagged for a maintenance path or online-DDL tooling.

## IaC & GitOps

- Production infra is reproducible from code: IaC (Terraform/Pulumi/CDK/CloudFormation) or platform config files (`fly.toml`, `render.yaml`). Fully console-clicked infra with no record is HIGH — it can't be reviewed, rebuilt, or DR'd.
- IaC state managed safely (remote backend with locking, not a local `terraform.tfstate` in the repo).
- GitOps (Argo/Flux) if used: cluster state reconciled from git, drift detected. Credit it as strong delivery posture.
