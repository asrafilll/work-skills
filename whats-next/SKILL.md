---
name: whats-next
description: Product ideation from repo and market analysis — the AI proposes what to build next, backed by an evidence-based SWOT. Use when the user asks "what's next", "what should we build next", wants feature ideas, or a product roadmap suggestion for an existing repo. Differs from pre-flight — pre-flight briefs a feature the user already chose; whats-next proposes the features.
---

# What's Next

Reverse of pre-flight: instead of the user bringing a feature idea, the AI studies the app and proposes the ideas. Read-only — no code changes, no scaffolding.

## Step 1 — Recon the product

Map what the app IS, not just its code. Prefer Lexa (`lexa status` → `lexa index .` if stale), fall back to direct scan.

```bash
lexa list apps        # or src/ — find the module map
lexa files <app-dir>
lexa brief "<domain keyword>" --max 8
```

Priority reading order (these say what the business does):
1. Product docs: `PRODUCT.md`, `README.md`, `docs/features/**`, `DESIGN.md`, ADRs
2. Module/route map: what features exist today
3. DB schema: what entities the business tracks
4. i18n/copy files: reveal user-facing language, target market, gaps

Output of this step (keep internal): feature inventory, target user, business model, domain, maturity of each feature.

If recon shows the repo is not an end-user product (a library, CLI, or infra tool), say so and reframe: "users" become developers, "market" becomes the ecosystem of comparable tools — or ask whether to proceed at all.

## Step 2 — Market context (internet, if available)

Before ideating, ground in the real market. Use WebSearch/WebFetch when the tools are available; skip silently if not.

- Search: "<domain> app features <current year>", competitors in the same niche, standard feature checklists for the domain.
- Identify: table-stakes features the app lacks, differentiators competitors ship, trends in the target market (note the app's language/locale — e.g. Indonesian copy → Indonesian market norms like WhatsApp-first commerce).
- Cite sources in the final output. Never present a guessed market claim as researched.

## Step 3 — SWOT the current product

From Steps 1–2, build the SWOT of the app as it exists today:

- **Strengths** — what it already does well (evidence: implemented, polished modules)
- **Weaknesses** — gaps, half-built areas, missing table-stakes (evidence: code/docs)
- **Opportunities** — market openings, user needs adjacent to current features
- **Threats** — what competitors/market shifts make dangerous to ignore

Every cell cites evidence: a file/module for internal claims, a source for market claims.

## Step 4 — Propose features

3–7 ideas, ranked by impact-for-effort. Each idea:

```markdown
### <n>. <Feature name>  — [SWOT: <quadrant it serves>]
**What**: one paragraph.
**Why now**: reasoning grounded in the SWOT + repo evidence (existing infra that makes it cheap, gap it closes).
**Business outcome**: what the user/business gains once shipped.
**Effort signal**: S / M / L, with one line on what makes it that size (existing modules to reuse vs new infra).
```

Rules for ideas:
- Anchor each to the SWOT: fix a Weakness, seize an Opportunity, extend a Strength, defend a Threat.
- Prefer ideas the codebase is already 60% ready for — name the modules that make it cheap.
- No generic filler ("add AI", "improve UX") unless tied to a concrete gap found in recon.

## Step 5 — Output

Print in chat: brief product summary (2–3 sentences), SWOT table, ranked ideas, then close with: which idea to take into `/pre-flight`? The two skills chain — whats-next picks the feature, pre-flight briefs its implementation.

## Rules

- Read-only. No edits, commits, or file creation.
- Internal claims come from the repo; market claims from cited research or marked ⚠️ assumption.
- Respect the app's actual market and locale — ideas must fit the user base the copy/docs reveal.
- Lexa flag gotchas: `--max` not `--max-results`; `text-search` scopes with `--path-glob` only; on flag error run `lexa <cmd> --help`.
