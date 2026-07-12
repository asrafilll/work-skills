# Access Control & Authentication

OWASP 2025 **A01 Broken Access Control** (now includes SSRF) and **A07 Authentication Failures**. Access control is the #1 category — spend the most time here. Cite evidence per item.

## Authorization — the highest-yield bugs

- **BOLA/IDOR**: every handler that fetches an object by an id from the request must check the caller owns or may access it. Grep for `findById`, `findUnique`, `get(id`, `WHERE id =` then read the surrounding lines — a fetch by id with no owner/role check right after is the finding. This is the most common exploitable web bug; treat a confirmed one as CRITICAL (unauth) or HIGH (needs an account).
- **Function-level authorization**: admin/privileged routes gated by role, not just "is logged in". Look for admin routers mounted without a role middleware.
- **Mass assignment / BOPLA**: request body spread straight into an ORM create/update (`update(req.body)`, `Model(**request.data)`) lets a caller set `role`, `isAdmin`, `ownerId`. Require an allowlist of writable fields.
- **Multi-tenancy**: in a multi-tenant app, every query must be scoped by tenant/org id. Sample queries across modules — one unscoped read is a cross-tenant data leak (CRITICAL).
- **Client-enforced access**: if the only thing hiding an admin action is the UI not showing a button, it's unprotected. Authorization lives server-side.

## SSRF (moved under A01 in 2025)

Any server-side fetch of a user-influenced URL — webhooks, "import from URL", image/link previews, PDF/screenshot renderers, OAuth/OIDC discovery.

- Flag `fetch`/`axios`/`requests.get`/`http.Get`/`curl` where the URL comes from user input with no allowlist.
- Correct control: allowlist scheme+host, resolve DNS and reject any private/reserved IP (loopback, `169.254.169.254` cloud metadata, RFC1918, link-local, IPv6 ULA), and forbid redirects. Note the DNS-rebinding TOCTOU gap if they resolve-then-fetch separately.
- Cloud metadata endpoint reachable from a fetch primitive → credential theft → CRITICAL.

## CSRF

- State-changing routes using cookie sessions need CSRF protection (token or `SameSite=Strict/Lax` cookies). Pure `Authorization: Bearer` APIs are not CSRF-prone; cookie-auth ones are.
- Check `SameSite` on the session cookie and whether the framework's CSRF middleware is actually enabled (many ship it off by default).

## Authentication (A07)

- **Password storage**: bcrypt/scrypt/argon2 with sane cost (bcrypt ≥ 12). Any MD5/SHA1/SHA256 or unsalted hash for passwords is CRITICAL. Grep `md5`, `sha1`, `createHash`, `hashlib`.
- **Credential-stuffing defenses**: rate limit + lockout/backoff on login, password reset, MFA, and OTP verification. No rate limit on login is HIGH.
- **Generic auth errors**: "invalid email or password" — not "no such user" (user enumeration).
- **Reset/verify tokens**: high-entropy, single-use, short TTL, invalidated after use. Predictable or non-expiring tokens are HIGH.
- **Session fixation**: session id rotates on login.

## Sessions, JWT & OAuth

- **Session cookies**: `httpOnly`, `Secure`, `SameSite`; sensible idle + absolute expiry; server-side invalidation on logout.
- **JWT**: algorithm pinned server-side (reject `alg: none` and RS↔HS confusion); signature verified before claims are trusted; `exp` enforced; secret from env not code. A JWT verified with a hardcoded/weak secret is CRITICAL.
- **Token storage**: auth tokens in `localStorage` are XSS-exfiltratable — flag it; prefer httpOnly cookies.
- **OAuth/OIDC**: `state` param checked (CSRF), `redirect_uri` allowlisted exactly (no open redirect), PKCE for public clients, tokens validated against the right issuer/audience.
