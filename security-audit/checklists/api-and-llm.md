# API & LLM Surfaces

Covers the **OWASP API Security Top 10** gaps not caught by the web checklists, plus the **OWASP Top 10 for LLM Applications (2025)** — audit the LLM section only if the repo actually calls a model.

## API-specific (beyond access-control.md, which already covers BOLA/BOPLA/auth)

- **Unrestricted resource consumption**: endpoints with no pagination cap, no request body/size limit, no rate limit, or that trigger heavy work (large exports, fan-out, unbounded joins) → cost and DoS. Check for `limit` caps and query timeouts.
- **Unrestricted access to sensitive business flows**: flows an attacker can automate at scale — signup, promo-code redemption, ticket purchase, invite sends. Look for anti-automation (rate limit, CAPTCHA, per-user caps) on flows where volume is the abuse.
- **Improper inventory management**: old API versions (`/v1` still live and unpatched), debug/internal routes exposed, undocumented endpoints. Grep the router for anything that looks deprecated or internal but is still mounted.
- **Unsafe consumption of third-party APIs**: data from an upstream API trusted without validation (it's untrusted input too) — reflected into queries, the DOM, or storage unchecked.
- **Webhook receivers**: verify HMAC/signature before processing (Stripe/GitHub/etc. sign payloads); reject on bad signature; guard against replay (timestamp + idempotency key). An unauthenticated webhook that mutates state is HIGH/CRITICAL.
- **GraphQL specifics**: query depth/complexity limits (no limit = DoS), introspection disabled in prod, field-level authorization (not just root resolvers), batching abuse caps.

## LLM & AI features (OWASP LLM Top 10 2025 — skip if no model is called)

- **LLM01 Prompt Injection**: untrusted text in the context window (user messages, fetched pages, PDFs, RAG documents, tool outputs) can carry instructions. The system prompt is **not** a security boundary — permissions must be enforced in code. Flag any design that relies on the prompt to stop a user doing X.
- **LLM05 Improper Output Handling**: model output is untrusted input. Flag it flowing into `eval`, SQL, a shell, `innerHTML`, a file path, or an HTTP call without validation/encoding. This is where LLM features become RCE/XSS/SSRF. Parse to a schema, then allowlist the action.
- **LLM02 Sensitive Information Disclosure**: secrets, other tenants' data, or the full system prompt placed in a context window can be echoed back. Keep them out.
- **LLM06 Excessive Agency**: agent/tool permissions scoped to the minimum; destructive or irreversible tool actions require confirmation; every tool argument validated. An agent with a shell tool and no bounds is CRITICAL.
- **LLM08 Vector/Embedding Weaknesses (RAG)**: vector store partitioned per tenant (cross-tenant retrieval leak otherwise); ingested documents validated so poisoned content can't steer answers.
- **LLM10 Unbounded Consumption**: token, request-rate, and loop/recursion-depth caps so a crafted input can't run up cost or hang the system.
- **Indirect injection via tools**: if the agent browses or reads user-supplied files, treat that content as hostile instructions, not just data.
