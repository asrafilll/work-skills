# Secrets & Supply Chain

OWASP 2025 **A03 Software Supply Chain Failures** (new, highest incidence rate in 2025) and **A08 Software & Data Integrity Failures**. Scanners lag here — CVE coverage is low, so manual review matters.

## Committed secrets

- Prefer `gitleaks git .` to scan **history**, not just the working tree — a rotated-looking `.env` may still expose a live key in an old commit. Fallback greps for the tree only: `AKIA[0-9A-Z]{16}`, `sk-`, `ghp_`/`gho_`, `xox[bpars]-`, `AIza`, `-----BEGIN.*PRIVATE KEY-----`, `password\s*[:=]`.
- `git ls-files | grep -Ei '\.env$|\.pem$|\.key$|\.p12$|credentials|secrets'` — any real secret file tracked in git is CRITICAL.
- `.gitignore` covers `.env`, `.env.*`, `*.pem`, `*.key`; a committed `.env.example` with placeholders is the correct pattern.
- **Every hit that is or was a live credential → rotate first, then purge history.** Report rotation as *before any deploy*. History rewriting alone does not remediate.

## Dependency hygiene

- **Lockfile committed** (`package-lock.json`/`pnpm-lock.yaml`/`poetry.lock`/`Cargo.lock`/`go.sum`) and CI installs pinned (`npm ci`, `pip install -r` with hashes, `--frozen-lockfile`) — not `npm install`/unpinned, which allows silent version drift.
- **Known CVEs**: run `osv-scanner scan .` (or ecosystem tool). Triage by reachability and runtime-vs-dev. Unpatched critical CVE on a reachable runtime dependency → HIGH/CRITICAL.
- **Abandoned/typosquatted deps**: watch years-dead packages on the hot path and near-miss names (`crossenv`, `reactdom`). New deps should earn their place.
- **`postinstall`/lifecycle scripts** in unfamiliar packages run arbitrary code at install — flag suspicious ones.
- **Dependency confusion**: internal package names must be scoped/pinned to a private registry so a public package can't shadow them.
- Automated update tooling present (Dependabot/Renovate) — its absence is MEDIUM.

## CI/CD pipeline security (A08)

The pipeline is production infrastructure. Read `.github/workflows/*`, `.gitlab-ci.yml`, etc.

- **`pull_request_target` / fork-PR workflows** that check out and run untrusted PR code with secrets in scope → CRITICAL (secret exfiltration from a fork).
- **Script/expression injection**: `${{ github.event.* }}` (PR title, branch, body) interpolated into a `run:` shell step → arbitrary command execution. Require env-var indirection.
- **Unpinned third-party actions** (`uses: foo/bar@main` or a mutable tag) — pin to a full commit SHA.
- **Over-broad secrets/permissions**: `permissions: write-all` or all secrets exposed to every job; set least-privilege `permissions:` and scope secrets to the jobs that need them.
- **Self-hosted runner** on public-repo PRs — dangerous unless isolated.
- **Artifact/build integrity**: releases signed or checksummed; ideally SBOM generated (`syft`) and provenance attested. Absence is MEDIUM for most apps, higher for anything others install.

## Container & IaC integrity

- Base images pinned by digest, not `:latest`; minimal/distroless where practical.
- No secrets baked into image layers (`docker history`, `ARG`/`ENV` secrets) — flag build-time secret leakage.
- `trivy fs .` / `checkov -d .` for misconfigured Dockerfiles and IaC; triage by exposure. See config-crypto-logging for runtime container hardening.
