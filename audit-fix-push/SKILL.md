---
name: audit-fix-push
description: "Prepare a reviewed pull request with one host agent by combining semantic code review, Lexa structural audit, focused fixes, and project verification. Use when the user asks for an audit-fix-push workflow, wants changes reviewed and fixed before publication, or wants review-this-like outcomes without multi-agent usage."
---

# Audit Fix Push

Take the intended candidate changes from review to an open pull request. One host agent owns the entire workflow.

## Hard Rules

- **Single agent only.** Never spawn subagents, delegate review or fixes, or invoke an external multi-agent workflow such as `review-this`.
- Local CLI tools are allowed; they do not count as agents.
- Never publish while an actionable review finding, Lexa high/warning finding, or required verification failure remains.
- Treat all visible tracked and untracked repository changes as intended for this workflow, but never revert or overwrite user changes.
- Follow repository instructions such as `AGENTS.md` and `CLAUDE.md`.
- Do not modify the Lexa skill or CLI; only invoke it against the target repository.
- Do not use destructive Git operations or force push.
- Do not stage secrets, credentials, local environment files, dependency folders, generated build output, or unrelated verification artifacts.
- Stop after creating or reusing the pull request. Do not start a post-PR monitoring or repair agent.

## 1. Inspect State and Build the Candidate Scope

Run:

```bash
git status --short
git branch --show-current
git remote -v
lexa status
```

If the Lexa graph is missing or stale, run `lexa index .`.

Review the complete candidate that would enter the pull request:

- On the default branch, include staged changes, unstaged changes, and intended untracked files relative to `HEAD`.
- On a feature branch, find the merge base with the default branch and include committed branch changes plus staged, unstaged, and intended untracked changes.
- Inspect untracked file contents explicitly because normal `git diff` output omits them.
- If there are no candidate changes, stop and report that nothing needs review or publication.

## 2. Review, Fix, and Re-review

Use one continuous agent context. Run an initial review, then allow at most **three fix attempts**. Every fix attempt must be followed by a fresh review of the current candidate; never reuse the previous diff or verdict.

For each review pass:

1. Refresh the candidate diff and `git status --short`.
2. Re-index with `lexa index .` after edits that affect the graph.
3. Run exactly `lexa audit --max 25` and record its high/warning counts for the final before/after report.
4. Review the candidate semantically for:
   - correctness, regressions, and explicit requirement violations;
   - edge cases, error paths, state transitions, async/concurrency behavior, and data integrity;
   - security, privacy, and performance risks;
   - API contracts, module boundaries, file responsibility, and architectural fit;
   - missing or inadequate tests and verification.
5. Use Lexa findings as structural evidence. Confirm findings in source before reporting or fixing them.
6. Ignore formatting taste, import ordering, vague preferences, unrelated pre-existing issues, and concerns already disproved by code or tests.

Write every pass in this shape:

```markdown
## Review Pass <n>

### Change Intention
<What the candidate change does and which files matter.>

### Findings
| # | Severity | Location | Finding | Risk | Required fix |
|---|---|---|---|---|---|
| 1 | major or minor | path:line | ... | ... | ... |

### Notes
<Non-blocking context, or "No notes.">

### Verdict
REVIEW_VERDICT: pass or needs-changes
```

Severity rules:

- **major**: concrete correctness, security, data-loss, broken-runtime, invalid-boundary, or required-verification risk.
- **minor**: actionable test, maintainability, edge-case, or lower-impact correctness issue.
- Any actionable major or minor finding means `needs-changes`. Notes do not block.
- Map actionable Lexa `high` findings to major and `warning` findings to major or minor based on confirmed impact. Do not duplicate the same issue.

When the verdict is `needs-changes`:

1. If three fix attempts have already been used, stop without committing, pushing, or opening a PR.
2. Fix every supported finding with the smallest root-cause change.
3. Keep every edit tied to a reported finding or failed check; do not broaden into opportunistic refactoring.
4. If a Lexa finding is expected and refactoring would make the code worse, encode the decision narrowly in repository audit config such as `lexa.toml`.
5. Run the smallest relevant check after the fix, then rebuild the candidate and begin the next review pass.
6. If the same issue repeats without progress, the fix is unsafe, or required context is unavailable, stop and report the blocker instead of looping blindly.

## 3. Final Verification Gate

After a review pass returns `pass`:

1. Re-run `lexa audit --max 25`.
2. Inspect project manifests and documentation for the correct verification commands.
3. Run every available required check relevant to the candidate, including typecheck, lint, tests, build, and existing UI/e2e checks when applicable.
4. Mark unavailable optional checks as skipped with a reason. An unavailable required check is a blocker.
5. Refresh the diff and status once more to catch tool-generated or unexpected changes.

If final verification fails, Lexa reports a new blocker, or a check modifies candidate source/configuration files, treat that evidence as a new `needs-changes` finding. Use another remaining fix attempt and perform a fresh semantic review afterward. If no fix attempts remain, stop without publishing.

Publication is allowed only when all are true:

- latest semantic review: `pass`;
- Lexa audit: `0 high` and `0 warning(s)`;
- every available required project check: passed;
- no unsafe or unrelated file is about to be staged.

## 4. Commit, Push, and Open the Pull Request

Review the final `git diff` and `git status --short`. Stage the intended candidate paths explicitly when practical; use `git add .` only when the entire worktree is confirmed in scope. Commit with a concise message that describes the full change.

Before publishing, confirm `gh` is installed and `gh auth status` succeeds. If authentication, permissions, or remote access is blocked, do not fake success; report the failed command and provide a GitHub compare URL when it can be derived.

If on the default branch, create a descriptive feature branch. Push immediately with upstream tracking:

```bash
git push -u origin <branch>
```

Check for an existing pull request from the branch with `gh pr view --json url,state`. Reuse an open PR; otherwise create one against the default branch with a specific title and a body file containing exactly these top-level sections:

```markdown
## Change Intention
<Concise description of the reviewed change.>

## Reviews
<Number of review passes, final clean verdict, and concise findings history.>

## What Fixed
<Grouped summary of fixes, or "No fixes were required.">

## Verification Status
- Lexa audit: <before → 0 high, 0 warnings>
- Typecheck: <passed or skipped with reason>
- Lint: <passed or skipped with reason>
- Tests: <passed or skipped with reason>
- Build: <passed or skipped with reason>
- UI/e2e: <passed or skipped with reason>
```

Do not append generated-by or co-author attribution.

Normal invocation of this skill authorizes the commit, push, and PR steps after the gates pass. Do not pause for routine publication confirmation. Pause only for unsafe files, missing authority, authentication/permission failure, or unresolved review/verification blockers.

## Completion Report

Report:

- review passes and final verdict;
- findings fixed and any remaining blockers;
- final Lexa counts;
- verification commands and results;
- commit hash and message;
- remote and branch pushed;
- PR URL on its own final line, or why no PR was created.
