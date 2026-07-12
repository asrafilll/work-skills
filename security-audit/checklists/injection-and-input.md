# Injection & Input Handling

OWASP 2025 **A05 Injection** (includes XSS) and design-level input trust. Trace a path from untrusted input to the sink before you call it injection — a parameterized ORM call is not a finding just because it contains a variable.

## SQL / NoSQL injection

- **Raw query with interpolation** is the finding: template strings or concatenation inside `query(...)`, `execute(...)`, `$queryRaw`, `.raw(`, `sequelize.literal`, `db.Raw`. Parameterized/bound queries and default ORM methods are fine.
- **NoSQL**: user object passed straight into a Mongo filter enables operator injection (`{ $gt: '' }`, `$where`). Check that query values are cast to expected primitives.
- **ORM escape hatches** carrying user input → HIGH/CRITICAL by reachability.

## Command / path / SSTI

- **OS command**: `exec`, `execSync`, `spawn(..., {shell:true})`, `os.system`, `subprocess` with `shell=True`, `Runtime.exec`, backticks — with any user-derived argument. Require an argument array (no shell) plus an allowlist. Reachable command injection is CRITICAL.
- **Path traversal**: user input in file paths (`readFile`, `sendFile`, `open`, `path.join(base, req.param)`) without normalizing and confirming the result stays under the intended root — `../../etc/passwd`.
- **SSTI**: user input rendered as a template rather than passed as data (`render_template_string`, `Template(userInput)`, `eval`-like template engines).

## Cross-Site Scripting (XSS)

- Auto-escaping frameworks (React/Angular/Vue, Jinja/ERB/Blade with escaping on) are safe **until bypassed**. The findings are the bypasses: `dangerouslySetInnerHTML`, `v-html`, `[innerHTML]`, `| safe`, `{{{ }}}`, `mark_safe`, `html_safe`, `bypassSecurityTrustHtml`, direct `.innerHTML =`, `document.write`.
- User-controlled data reaching those without sanitization (DOMPurify or equivalent) → stored/reflected XSS.
- Check for XSS in non-HTML sinks too: `href`/`src` = `javascript:`, unescaped data in inline `<script>` JSON, and `Content-Type` that lets an uploaded file render as HTML.

## Deserialization & parsing

- Unsafe deserializers on untrusted data: `pickle`, Java native `readObject`, PHP `unserialize`, Ruby `Marshal.load`, `yaml.load` (vs `safe_load`), `eval`/`Function` on JSON-ish input. Reachable → CRITICAL.
- XML parsers with external entities enabled (XXE) — check DTD/entity resolution is disabled.

## Input validation at boundaries

- Schema validation (zod/joi/pydantic/valibot/DTO validators) at every entry point, not ad-hoc checks deep in handlers. Absence is a systemic MEDIUM, upgraded where it enables a concrete injection.
- **Size and count bounds**: max body size, array length caps, string length caps, pagination limits — their absence is a DoS vector (see A10 / API resource-consumption).
- **File uploads**: type checked by magic bytes not just extension/`Content-Type`; size capped; stored outside webroot with a generated name; never executed; images re-encoded if feasible.
- **Trust boundary reminder**: client-side validation is UX, never a security control — the server must re-validate everything.
