---
name: pre-flight
description: Pre-development briefing before building a feature or fixing a bug. Analyzes the repo (Lexa index if available, otherwise direct scan), maps the requested change against what already exists, and outputs a recap covering what the change is, the current state, what will change, assumptions, and the business flow impact. Use before starting a feature or bugfix, or when the user says "pre-flight".
---

# Pre-Flight

Produce a pre-development briefing for a feature or bugfix BEFORE any code is written. The goal: user reads the recap, confirms your understanding matches theirs, then development starts with shared context. This skill is read-only — never edit code while running it.

Input: the user's description of the feature or fix (from the skill arguments or the conversation). If no description was given, ask for one first.

## Step 1 — Restate the request

Rewrite the user's request in one short paragraph of plain words. If it is a bugfix, state the suspected broken behavior. Do not add scope the user did not mention.

## Step 2 — Recon the repo

Map the area of the codebase the change touches.

Prefer Lexa if available:

```bash
lexa status                # index missing/stale -> lexa index .
lexa brief "<the task, with symbols/paths/domain keywords>" --max 8
lexa symbol-search <RelevantSymbol> --max 10
lexa text-search "<domain keyword>" --scope --compact --max 20
lexa text-search "<keyword>" --compact --path-glob "apps/api/**"   # scope with --path-glob, not --path-prefix
lexa word-refs <ExactSymbol>
lexa outline <key-file>
lexa trace-deps <key-file>
```

Flag gotchas: use `--max`, not `--max-results`; `text-search` scopes with `--path-glob` only. If a flag errors, run `lexa <cmd> --help` and adapt instead of retrying.

If Lexa is unavailable, fall back to normal exploration: README, package manifest, route definitions, models/schema, the directories whose names match the feature's domain.

Collect: which existing features/modules relate to this change, which files implement them, and how data currently flows through that area.

## Step 3 — Reflect the change against the repo

Answer, from evidence found in Step 2:

- What does the app do **today** in this area?
- What will the change **add or alter**? New capability, changed behavior, or repaired behavior?
- Which existing features does it touch, extend, or risk breaking?
- What must be true for the plan to work (existing endpoints, schema fields, auth rules, third-party services)? Verify each in the code where possible; whatever you cannot verify becomes an assumption or open question.

## Step 4 — Output the briefing

Print the recap in chat using exactly this structure. Cite real file paths from recon. Keep each section tight — this is a briefing, not a design doc.

```markdown
## Pre-Flight: <feature/fix name>

**What**
One paragraph: the feature/fix in plain words.

**Current state**
What the app does today in this area. Reference the modules/files that implement it.

**What changes**
Bullet list: capability added, behavior altered, or defect repaired. Note which existing features are touched or at risk.

**Touched areas**
| Area | Files/Modules | Change type (new / modify / risk) |

**Assumptions**
Numbered list. Things that must hold true, each marked ✅ verified in code or ⚠️ unverified.

**Business flow impact**
Before: how the process/flow works now for the user/business.
After: how it works once this ships.

**Expected outcomes**
Bullet list: concrete results once done — what the user/business can do that they could not before, or what stops going wrong.

**Open questions**
Anything unresolved that could change the plan. Empty section is fine.
```

## Step 5 — Confirm gate

End with one question: does this match the user's intent? Wait for confirmation or corrections before any development starts. If the user corrects something, update the briefing and re-confirm. Only after confirmation does implementation begin — and implementation is outside this skill.

## Rules

- Read-only: no file edits, no commits, no scaffolding while this skill runs.
- Every claim about the current state must come from the repo, not from memory of similar apps. If you did not find it, mark it ⚠️ unverified.
- Do not inflate scope. If the recap reveals the feature is bigger than the user's description, say so in Open questions instead of silently expanding "What changes".
- Differs from grill-me: grill-me interrogates the user about their plan; pre-flight interrogates the repo and reflects the plan against it.
