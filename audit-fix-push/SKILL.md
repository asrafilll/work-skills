---
name: audit-fix-push
description: Run a repository audit with `lexa audit --max 25`, fix any high-severity or warning findings, repeat until clean, then commit all current repository changes with a clear message and push to GitHub without pausing for confirmation. Use when the user asks to audit and fix a repo before committing, clean Lexa audit findings, or perform an audit-fix-commit-push workflow.
---

# Audit Fix Push

## Overview

Take a repository from Lexa audit findings to a pushed commit. Lexa is the audit tool for this workflow; do not modify the Lexa skill/CLI itself, only use it.

## Workflow

1. Inspect repository state:
   - Run `git status --short`.
   - Treat all visible tracked and untracked changes as intended for this workflow.
   - Do not revert or overwrite existing user changes.

2. Run the audit:
   - Run `lexa status`.
   - If the graph is missing or stale, run `lexa index .`.
   - Run exactly `lexa audit --max 25`.

3. Fix findings:
   - Fix every `high` and `warning` finding.
   - Keep changes small and aligned with the repository's conventions.
   - Follow local instructions such as `AGENTS.md` / `CLAUDE.md`.
   - If a finding is expected and refactoring would make the code worse, encode that decision in repo audit config (e.g. `lexa.toml`) instead of forcing a fix.

4. Repeat until clean:
   - Re-index with `lexa index .` after source edits that should affect the graph.
   - Run `lexa audit --max 25` again.
   - Continue until the audit reports `0 high` and `0 warning(s)`.
   - A clean Lexa audit is not a substitute for build, typecheck, lint, or tests.

5. Verify project checks:
   - Inspect `package.json`, `README.md`, or project docs for the right commands.
   - Run relevant checks for the changed area (e.g. `pnpm lint`, `pnpm typecheck`, `pnpm test`, or filtered equivalents).
   - If checks cannot run, report the reason clearly.

6. Commit:
   - Review `git diff` and `git status --short`.
   - Stage with `git add` (specific paths preferred over `git add .` when it's easy to be precise; use `git add .` if the whole worktree is genuinely intended).
   - If `git status --short` shows an obvious secret, credentials file, or build artifact, pause and ask the user before staging it.
   - Commit with a concise, specific message summarizing the change (follow this repo's existing commit style / Conventional Commits if that's the convention).

7. Push:
   - Check the branch with `git branch --show-current` and remotes with `git remote -v`.
   - Push immediately, no confirmation pause: `git push` (or `git push -u origin <branch>` if no upstream exists).
   - If authentication, permissions, or network access blocks the push, report the failed command and blocker.

## Command Approval Behavior

- This skill is a standing user instruction to auto-commit and auto-push: do not ask "should I push?" or "should I commit?" before running `git add`, `git commit`, or `git push` as part of this workflow — proceed directly.

## Safety Rules

- Do not use destructive Git commands (`git reset --hard`, `git checkout --`, force push) unless explicitly requested.
- Do not modify the `lexa` skill/tool itself — only invoke the CLI.
- Do not commit secrets, local env files, dependency folders, or build outputs without explicit user confirmation — pause and ask only in that case.

## Completion Report

At the end, report:

- Final Lexa audit result.
- Project checks run and their results.
- Commit hash and commit message.
- Remote and branch pushed (or why push was skipped/blocked).
