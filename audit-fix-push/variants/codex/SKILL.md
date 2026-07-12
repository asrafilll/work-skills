---
name: audit-fix-push
description: Run a repository audit with `lexa audit --max 25`, fix any high-severity or warning findings, repeat the audit until clean, then run `git add .`, commit all current repository changes with a clear message, push the branch, and open a GitHub pull request without pausing for command confirmation when saved approvals are available. Use when the user asks to audit and fix a repo before committing, clean Lexa audit findings, or perform an audit-fix-commit-PR workflow that publishes the whole worktree.
---

# Audit Fix Push

## Overview

Use this skill to take a repository from audit findings to an open GitHub pull request. Lexa is the audit tool for this workflow, but this is a standalone skill and must not modify the Lexa skill itself.

## Workflow

1. Inspect repository state:
   - Run `git status --short`.
   - Treat all visible tracked and untracked repository changes as intended for this workflow.
   - Do not revert or overwrite existing user changes.

2. Run the audit:
   - Run `lexa status`.
   - If the graph is missing or stale, run `lexa index .`.
   - Run exactly `lexa audit --max 25`.

3. Fix findings:
   - Fix every `high` and `warning` finding.
   - Keep changes small and aligned with the repository's conventions.
   - Follow local instructions such as `AGENTS.md`.
   - If Lexa marks a finding as expected and refactoring would make the code worse, encode that decision in repo audit config such as `lexa.toml`.

4. Repeat until clean:
   - Re-index with `lexa index .` after source edits that should affect the graph.
   - Run `lexa audit --max 25` again.
   - Continue until the audit reports `0 high` and `0 warning(s)`.
   - A clean Lexa audit is not a substitute for build, typecheck, lint, or tests.

5. Verify project checks:
   - Inspect `package.json`, `README.md`, or project docs for the right commands.
   - Run relevant checks for the changed area.
   - For JavaScript/TypeScript workspaces, prefer existing package scripts such as `pnpm lint`, `pnpm typecheck`, `pnpm test`, or filtered equivalents.
   - If checks cannot run, report the reason clearly.

6. Commit:
   - Review `git diff` and `git status --short`.
   - Run exactly `git add .` from the repository root.
   - Use the saved Git approval for `git add`; do not ask the user for confirmation before staging.
   - Commit all staged changes with a concise, specific message that summarizes the full worktree, for example `chore: resolve audit findings` or `feat: update admin workflow`.
   - Use the saved Git approval for `git commit`; do not ask the user for confirmation before committing.

7. Push the branch:
   - Check the branch with `git branch --show-current`.
   - Check remotes with `git remote -v`.
   - If currently on the default branch (`main`/`master`), create a descriptive branch first (for example `git checkout -b audit/fix-lexa-findings`) so the pull request has a source branch. Never push audit fixes directly to the default branch.
   - Push with `git push -u origin <branch>`.
   - Use the saved Git approval for `git push`; do not ask the user for confirmation before pushing.
   - If authentication, permissions, or network access blocks the push, report the failed command and blocker.

8. Open a pull request:
   - Check for an existing PR from this branch first: `gh pr view --json url,state`. If an open PR already exists, skip creation and reuse its URL.
   - Otherwise create one with `gh pr create` targeting the default branch:
     - Title: concise and specific to what actually changed (for example `Fix Lexa audit findings: unused exports and dead code in parser`), following this repo's PR title convention if one is visible in `gh pr list`. Never a generic title like "Audit fixes".
     - Body: include a `## Summary` section (what the audit found and what was fixed, grouped by theme, 2-5 bullets), an `## Audit result` section (before/after finding counts, plus any findings suppressed via config and why), and a `## Verification` section (project checks run and their results).
   - Do not append any attribution footer (for example "Generated with ..." or "Co-Authored-By") to the PR body.
   - If `gh` is not installed or not authenticated (`gh auth status` fails), report the blocker and give the compare URL (`https://github.com/<owner>/<repo>/compare/<branch>?expand=1`) so the user can open the PR manually.
   - Capture the PR URL from the `gh pr create` output.

## Command Approval Behavior

- Do not pause to ask the user for permission before running `git add .`, `git commit -m "<message>"`, `git push`, or `gh pr create`.
- When a tool call needs elevated execution for Git index or network access, use the already-approved narrow prefixes:
  - `["git", "add"]`
  - `["git", "commit"]`
  - `["git", "push"]`
  - `["gh", "pr"]`
- Keep Git commands simple so they match saved approvals. Do not wrap them in `sh -c`, environment assignments, command chains, pipes, or shell substitutions.
- If the platform reports that an approval is missing despite these saved prefixes, request the same narrow persistent prefix once, then continue the workflow.
- Do not request broad approvals such as `["git"]`, and do not request approvals for destructive commands.

## Safety Rules

- Do not use destructive Git commands such as `git reset --hard`, `git checkout --`, or force push unless explicitly requested.
- Do not modify the standalone `lexa` skill. Only use the `lexa` CLI as an audit tool.
- Do not intentionally commit secrets, local environment files, dependency folders, or build outputs. If `git status --short` shows an obvious secret or unsafe artifact, pause and ask the user before `git add .`.
- Networked GitHub operations require working local Git authentication. Do not ask for normal `git push` permission when the saved `["git", "push"]` approval is available.
- Do not narrow staging to audit-only files. This skill's default behavior is to publish the current worktree.

## Completion Report

At the end, report:

- Final Lexa audit result.
- Project checks run and their results.
- Commit hash and commit message.
- Remote and branch pushed.
- Whether `git add .` staged the whole current worktree or whether the workflow paused for an unsafe file.
- The PR URL on its own line as the last line of the report (for example `https://github.com/owner/repo/pull/2`) so the user can click it or open it in the browser — or why PR creation was skipped or blocked.
