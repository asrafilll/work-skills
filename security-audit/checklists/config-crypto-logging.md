# Configuration, Crypto, Logging & Error Handling

OWASP 2025 **A02 Security Misconfiguration** (jumped to #2 in 2025), **A04 Cryptographic Failures**, **A09 Logging & Alerting Failures**, **A10 Mishandling of Exceptional Conditions** (new in 2025).

## Security misconfiguration (A02)

- **Debug/dev mode off in prod**: `DEBUG=True` (Django/Flask), `app.debug`, source maps served, framework dev error pages, GraphQL introspection/playground exposed. A debug page leaking stack traces + env is HIGH.
- **Security headers**: `Content-Security-Policy`, `Strict-Transport-Security`, `X-Content-Type-Options: nosniff`, `X-Frame-Options`/`frame-ancestors`, `Referrer-Policy`. Check for `helmet`/equivalent or reverse-proxy config. Missing on an app with a session is MEDIUM.
- **CORS**: explicit origin allowlist. `Access-Control-Allow-Origin: *` **with** `Allow-Credentials: true`, or reflecting the `Origin` header unchecked, is HIGH.
- **Default/verbose exposure**: default admin credentials, server version banners, directory listing, admin panels reachable from the internet, actuator/metrics/`.git`/`.env` served by the web server.
- **Container/runtime hardening**: container runs as non-root; read-only root FS where possible; no `--privileged`; secrets via runtime env/secret manager not image; least-privilege cloud IAM roles.
- **TLS**: HTTPS enforced end-to-end, HTTP→HTTPS redirect, no mixed content. Credit the platform if it terminates TLS, but confirm it's on.

## Cryptographic failures (A04)

- **Weak algorithms**: MD5/SHA1 for anything security-relevant, DES/3DES/RC4, ECB mode, custom/hand-rolled crypto. Use vetted libraries.
- **Weak randomness for secrets**: `Math.random()`, `random.random()`, `rand()` used to generate tokens/ids/OTPs → predictable. Require a CSPRNG (`crypto.randomBytes`, `secrets`, `crypto/rand`).
- **PII/secrets at rest**: sensitive fields encrypted where the threat model calls for it; encryption keys not alongside the data; column/disk encryption for regulated data.
- **Data in transit**: no plaintext HTTP for credentials/PII; internal service-to-service TLS for sensitive flows.
- **Hardcoded crypto keys/IVs/salts** in source → treat as a committed secret.

## Logging & alerting (A09)

- **Security events logged**: auth success/failure, access-control denials, privilege changes, input-validation failures — enough to reconstruct an incident.
- **No sensitive data in logs**: passwords, full tokens, full card numbers, session ids, raw PII. Grep logging calls near auth/payment code. Logging a secret is a finding.
- **Tamper-resistant, retained, monitored**: logs shipped off-box, retained, and wired to alerting — logging without alerting is the exact gap A09 was renamed to stress. "Logs exist but nobody is paged" is MEDIUM.

## Mishandling of exceptional conditions (A10 — new 2025)

- **Fail-open**: a `try/catch` (or auth/permission check) that swallows an error and continues as if it passed. An auth check that returns "allowed" in its catch block is CRITICAL. Grep empty `catch {}`, `except: pass`, `catch (e) { return true }`.
- **Error detail leakage**: raw stack traces, SQL errors, or internal paths in HTTP responses → info disclosure and a recon aid. Generic message to the user, detail to the log.
- **Unhandled rejection/panic crashing the process**: a single crafted request that can take the service down is a DoS (HIGH depending on exposure).
- **Inconsistent state on partial failure**: a multi-step mutation that fails midway must not leave money moved / half-created records — transactions or compensating logic.
