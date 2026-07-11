# work-skills

Personal library of agent skills for [Claude Code](https://claude.com/claude-code) and [Codex](https://openai.com/codex). Each skill is a folder with a `SKILL.md` (instructions + YAML frontmatter) that the agent auto-discovers from its skills directory.

## Skills

| Skill | What it does |
|---|---|
| **audit-fix-push** | Runs `lexa audit`, fixes high-severity/warning findings until clean, then commits and pushes without pausing. Has a Codex-specific variant (`variants/codex/`). |
| **awwwards-design** | Builds award-winning websites: advanced animations, creative interactions, distinctive visuals. For portfolios, agency showcases, launches — anything needing wow factor. |
| **effective-agent-skills** | Complete guide to authoring agent skills: anatomy, progressive disclosure, design patterns, anti-patterns, testing, security. Third-party — from [davidondrej/skills](https://github.com/davidondrej/skills) @ `50f4b7666347`. |
| **caveman** | Ultra-compressed communication mode. Cuts token usage ~75% by dropping filler, articles, pleasantries while keeping full technical accuracy. |
| **grill-me** | Interviews you relentlessly about a plan or design, one question at a time, until shared understanding — exploring the codebase itself when it can. |
| **grill-with-docs** | Grilling session that challenges a plan against your project's domain model and updates docs (CONTEXT.md, ADRs) inline as decisions crystallise. |
| **handoff** | Compacts the current conversation into a handoff document another agent can pick up. |
| **lexa** | Teaches the agent to use the Lexa CLI/MCP for token-efficient codebase intelligence: symbol lookup, dependency tracing, context bundles, hash-aware edits. |
| **make-interfaces-feel-better** | Design engineering details that make UI feel polished: concentric border radius, optical alignment, layered shadows, staggered animations, tabular numbers, hit areas. Third-party — from [jakubkrehel/make-interfaces-feel-better](https://github.com/jakubkrehel/make-interfaces-feel-better) @ `366f0f86efcb`. |
| **ponytail** | Lazy senior dev mode: YAGNI, stdlib first, no unrequested abstractions. For any coding task. |
| **pre-flight** | Pre-development briefing before building a feature or fixing a bug. Recons the repo, then recaps: what changes, current state, assumptions (verified/unverified), business flow impact, expected outcomes — and gates on your confirmation before any code. |
| **procurement-flow** | Reverse-engineers the end-to-end business flow implemented in a repo you're new to. Produces FLOW.md with mermaid diagrams: pipeline, state machines, approval chains. |
| **taste-skill** | Anti-slop frontend skill for landing pages, portfolios, and redesigns: brief inference, design dials, real design-system mapping, AI-tell bans, strict pre-flight checklist. Third-party — from [Leonxlnx/taste-skill](https://github.com/Leonxlnx/taste-skill) @ `3c7017d636c3` (frontmatter name aligned to folder; body untouched). |
| **security-and-hardening** | Security-first development: threat modeling (STRIDE), OWASP Top 10 prevention patterns, input validation, secrets management, LLM-feature security, review checklists. Third-party — from [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) @ `d1983929db65` (dangling references/ pointers removed). |
| **to-issues** | Breaks a plan/spec/PRD into independently-grabbable tracker issues using tracer-bullet vertical slices. |
| **to-prd** | Turns the current conversation into a PRD and publishes it to the project issue tracker. |
| **whats-next** | Product ideation from repo analysis. Maps the app + business process, researches the market, builds an evidence-backed SWOT, and proposes ranked next features — each with a why, SWOT quadrant, and expected business outcome. Chains into pre-flight. |

Workflow pairing: `whats-next` decides *what* to build → `pre-flight` briefs *how it lands* → `grill-me`/`grill-with-docs` stress-test the plan → `to-prd`/`to-issues` turn it into tracked work.

## Install

```sh
git clone https://github.com/asrafilll/work-skills.git
cd work-skills
./install.sh
```

The interactive installer lists every skill, lets you pick (numbers, names, or `all`), and asks which agent to install into: **claude**, **codex**, or **both**.

Non-interactive:

```sh
./install.sh --all --target both           # everything, both agents
./install.sh pre-flight whats-next --target claude
./install.sh --list                        # see what's available
./install.sh --all --target codex --force  # overwrite without asking
```

### Where skills go

| Target | Directory | Override with |
|---|---|---|
| Claude Code | `~/.claude/skills/` | `CLAUDE_SKILLS_DIR` |
| Codex | `~/.codex/skills/` | `CODEX_SKILLS_DIR` |

Restart your agent session after installing — skills are discovered at session start.

### Codex variants

Some skills behave differently per agent. When a skill has a `variants/codex/` folder (currently `audit-fix-push`), the installer copies that variant into Codex and the top-level canonical version into Claude. Everything else installs identically to both.

## Layout

```
skill-name/
├── SKILL.md              # frontmatter (name, description) + instructions
├── *.md                  # optional reference files
└── variants/
    └── codex/            # optional Codex-specific version
        └── SKILL.md
```

## Adding a skill

Create a folder with a `SKILL.md`, frontmatter `name` + `description` (description is what the agent reads to decide when to trigger — include "Use when …"). The installer picks it up automatically; no registry to update.
