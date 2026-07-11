---
name: procurement-flow
description: Reverse-engineer the end-to-end procurement (or any domain) flow already implemented in a repo you are new to. Scans the API/service layer, routes, state constants, and approval logic, then produces a FLOW.md with mermaid diagrams: the source-to-pay pipeline, per-entity state machines, and approval chains. Use when onboarding to a procurement/vendor/e-proc codebase, or when the user asks "what is the procurement flow", "map the flow", "how does this app work end to end", "trace the business flow", "I'm new to this repo".
---

# Procurement Flow Mapper

Goal: hand a newcomer a correct map of the procurement flow that is ALREADY built in a
repo — derived from code, not guessed. Output is a `FLOW.md` at repo root.

Everything below is evidence-driven. Never invent a step you cannot point to in code.
Cite `file:line` for every claim in the final doc.

## 0. Scope

Ask for the target repo path if not given. Default output: `<repo>/FLOW.md`.
If a domain other than procurement (e.g. HR, logistics), the same steps apply — the
domain vocabulary in `references/procurement-domain.md` is procurement-specific, treat it
as a hint list, not a requirement.

## 1. Fingerprint the stack (2 min)

- `package.json` / `go.mod` / `pom.xml` etc → framework, HTTP client, state/query lib.
- Locate the **API surface**. In order of likelihood:
  - `src/services/*`, `src/api/*`, `src/lib/api/*` (frontend calling a backend)
  - route/controller dirs (backend)
  - `app/` / `pages/` router dirs (screens = user-facing steps)
- Note i18n/locale files (`locales/*`, `*.json`) — status/label keys there are a
  goldmine for lifecycle state names.

## 2. Enumerate domain modules

List every folder in the API/service layer. Cluster by domain noun, not alphabetically.
Typical procurement clusters (see reference for full taxonomy):

vendor / rekanan · pre-screening · activation (aktivasi) · blacklist & sanksi ·
RUR · procurement / sourcing · penetapan (award) · contract · PO · BAST (goods receipt) ·
invoice · guarantee / jaminan · evaluation (evaluasi rekanan) · HPS · approval-history.

For each cluster record: the CRUD verbs present (store/find/update/put), and whether it
has approval endpoints (`*-approval`, `*-approver-type`, `get-approval`, `put-approval`).

## 3. Extract lifecycle states

The flow lives in the **status values**, not the folder names. Find them:

- grep enums / constants: `grep -rniE "status|state|stage|tahap|phase" src/constants src/types`
- grep status string literals & i18n keys: search `locales/` for `status`, `draft`,
  `submitted`, `approved`, `rejected`, `pending`, `penetapan`, `aktif`, `blacklist`.
- Look at status→color/badge maps in components (often a switch/object literal) — these
  enumerate the full state set in one place.

Build a state set per entity. Note terminal states and who transitions them.

## 4. Trace the transitions & approval chains

- Approval pattern: `*-approval-action`, `approver-type`, `checker-signer`,
  `approval-history` → maker-checker-signer chains. Capture roles and order.
- Follow the calls: which screen/mutation moves an entity from state A → B. React Query
  `useMutation` + the service fn it calls is the transition edge.
- Cross-entity edges: e.g. vendor `aktif` unlocks RUR; award (penetapan) creates a
  contract; BAST unlocks invoice. Find these by shared IDs / navigation after success.

## 5. Assemble FLOW.md

Sections, in this order:

1. **TL;DR** — one paragraph + the source-to-pay pipeline as a mermaid `flowchart LR`.
2. **Domain modules** — table: module · purpose · key service files · has-approval?
3. **Per-entity state machines** — a mermaid `stateDiagram-v2` each, states from step 3,
   edges + trigger (screen/endpoint) from step 4.
4. **Approval chains** — maker→checker→signer per flow, with the endpoints.
5. **Open questions** — anything code was ambiguous about. Be honest; don't paper over gaps.

Use the mermaid templates in `references/mermaid-templates.md`.
Every non-obvious claim gets a `path:line` citation.

## 6. Verify before delivering

Pick 2–3 transitions you drew and re-open the code to confirm the edge is real.
Report coverage: "mapped N of M service modules; unmapped: …". Do not overclaim
completeness.

## Efficiency

For big repos, spawn the **Explore** agent (or `lexa`) to fan out step 2–3 in parallel
rather than reading every file yourself. Read `references/procurement-domain.md` for the
vocabulary that maps Indonesian/e-proc terms to standard source-to-pay stages.
