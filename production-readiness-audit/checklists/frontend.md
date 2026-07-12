# Frontend Checklist

Audit against these; cite evidence per item. 🔒 = security-critical.

## Build & delivery

- Production build configured: minification, tree-shaking, hashed filenames for cache busting (framework defaults usually cover this — verify not disabled).
- Code splitting / lazy loading for routes or heavy components; single multi-MB bundle is a finding.
- Source maps: either not shipped to production or uploaded privately to the error tracker — public source maps for proprietary code is a judgment call, flag as LOW.
- Static assets served with long-lived cache headers + CDN (often platform-provided — credit it).

## Configuration & secrets

- 🔒 **Nothing secret in the bundle.** Every `NEXT_PUBLIC_*` / `VITE_*` / `REACT_APP_*` var ships to the client — grep them; API secret keys, service-role keys, or DB URLs there are BLOCKER.
- Environment-specific config injected at build/deploy, not hardcoded API URLs pointing at localhost or a dev server.

## Errors & resilience

- Error boundaries (or framework error pages) so one component crash doesn't white-screen the app.
- Client error tracking wired (Sentry/Bugsnag/etc.) with release/version tagging — without it, production frontend bugs are invisible.
- Failed API calls surface user-facing states (retry/error UI), not silent console errors or infinite spinners.

## Performance

- Core Web Vitals posture: image optimization (modern formats, sizing, lazy load), fonts with `font-display: swap` or preload, no obvious render-blocking bloat.
- Data fetching: caching/dedup layer (React Query/SWR/framework loader) rather than raw fetch-in-effect waterfalls on hot pages.
- RUM or at least basic analytics to know real-user performance (may be platform-provided).

## Security

- 🔒 Security headers: CSP (even report-only is a start), `X-Content-Type-Options`, `X-Frame-Options`/`frame-ancestors`, `Referrer-Policy` — set in framework config, platform config, or reverse proxy.
- 🔒 No `dangerouslySetInnerHTML`/`v-html`/`innerHTML` with unsanitized user content (XSS).
- 🔒 Auth tokens: prefer httpOnly cookies; long-lived JWTs in `localStorage` is a finding (severity depends on XSS surface).
- 🔒 Client-side route guards are UX only — verify the API enforces authZ server-side (cross-check with backend audit).
- Dependency audit clean of critical CVEs (shared tooling with backend).

## Baseline UX/meta

- Accessibility basics: semantic HTML, form labels, keyboard navigability on critical flows (audit the money path, not every page).
- If SEO matters for this product: meta tags, OG tags, sitemap, SSR/prerendering for crawlable pages. If it's an internal tool/dashboard, mark N/A.
