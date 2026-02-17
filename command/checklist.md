---
description: Create or update website-checklist.md as an actionable website launch checklist.
---

<objective>
You are working in an existing codebase. Create or update `website-checklist.md` as an actionable website launch checklist.

Rules:
1) Do not edit any file except `website-checklist.md` unless you first ask for permission and the user explicitly says yes.
2) If `website-checklist.md` already exists:
   - Preserve any existing checked boxes (`- [x]`) and do not reset progress.
   - Preserve any extra project-specific items already present.
   - Only add missing items, dedupe duplicates, and reorganize into the section order below.
3) Auto-check items when you can verify them from the repo/config (mark as `- [x]` only if you find clear evidence). If not verifiable, leave `- [ ]`.
4) Before including items that might be irrelevant, ask the user first with a short question list (max 8 questions). Based on answers, omit irrelevant checklist items instead of including everything.
5) Do not redo work: if an item is already implemented (detected in repo) or already checked in the checklist, keep it checked and do not create duplicate tasks.

Output rules:
- If you need the user's answers, output ONLY the question list (no checklist content yet).
- After the user answers, output ONLY the updated `website-checklist.md` content.
</objective>

<process>
A) Quick repo scan to detect what's already implemented (favicons, manifest, robots/sitemap, meta tags, headers, analytics, error tracking, tests, CI, etc).

B) Ask the short question list for anything you can't infer reliably. Keep it to 8 questions max.

C) Write/update `website-checklist.md` with these sections in this exact order, using Markdown checkboxes:
   - Basics
   - Performance
   - SEO
   - Accessibility
   - Security
   - UI/UX
   - Legal & Privacy
   - Development & Deployment

If `website-checklist.md` exists:
- Preserve any `- [x]` items.
- Preserve any extra project-specific items.
- Dedupe duplicates (case/whitespace/punctuation-insensitive) without losing checked state.
- Reorganize into the section order above.
</process>

<questions_max_8>
Ask these (or an equivalent set) if not reliably inferable from the repo:
1) Is this a PWA or does it need offline support?
2) Is the site multilingual (hreflang needed)?
3) Does it have user accounts/authentication?
4) Does it accept payments?
5) Does it include user-generated content or file uploads?
6) Do you run a backend/API (beyond static hosting)?
7) Do you need cookie consent (analytics/ads/third-party cookies)?
8) Do you need analytics and/or error tracking?

Omit irrelevant items based on answers.
</questions_max_8>

<base_item_pool>
Include only what's relevant after A+B; auto-check what you can verify.

## Basics
- [ ] Favicon (favicon.ico, apple-touch-icon, mask-icon)
- [ ] Web app manifest (manifest.json)
- [ ] Theme color meta tag
- [ ] robots.txt
- [ ] sitemap.xml
- [ ] humans.txt (optional)
- [ ] .well-known/security.txt

## Performance
- [ ] Loading skeletons or spinners
- [ ] Lazy loading for images/iframes
- [ ] Code splitting
- [ ] Minified CSS/JS
- [ ] Gzip/Brotli compression
- [ ] CDN for static assets
- [ ] Cache headers (Cache-Control, ETag)
- [ ] Preload critical resources
- [ ] DNS prefetch/preconnect
- [ ] Image optimization (WebP, srcset)
- [ ] Font loading strategy
- [ ] Critical CSS inlined

## SEO
- [ ] Unique title tags per page
- [ ] Meta description
- [ ] Canonical URLs
- [ ] Open Graph tags
- [ ] Twitter Card tags
- [ ] Structured data (JSON-LD)
- [ ] Semantic HTML (header, nav, main, footer)
- [ ] Alt text for images
- [ ] Hreflang for multilingual

## Accessibility
- [ ] ARIA labels and roles (only where needed)
- [ ] Keyboard navigation support
- [ ] Visible focus indicators
- [ ] Color contrast (WCAG AA+)
- [ ] Screen reader testing
- [ ] Skip links
- [ ] Associated form labels
- [ ] ARIA-live for dynamic errors

## Security
- [ ] HTTPS enforced
- [ ] HSTS header
- [ ] Content Security Policy
- [ ] X-Frame-Options / frame-ancestors
- [ ] X-Content-Type-Options
- [ ] Referrer-Policy
- [ ] Permissions-Policy
- [ ] Secure cookies (HttpOnly, SameSite) (only if cookies used)
- [ ] CSRF tokens (only if state-changing requests)
- [ ] Rate limiting (only if you run an API)
- [ ] Input validation/sanitization

## UI/UX
- [ ] Responsive design
- [ ] Touch targets >= 44x44 px
- [ ] Loading states
- [ ] Custom 404/500 pages
- [ ] Offline page (if PWA)
- [ ] Print styles (if needed)
- [ ] Dark mode support (if required)
- [ ] Consistent navigation
- [ ] Breadcrumbs (if site structure needs it)
- [ ] Back-to-top button (optional)

## Legal & Privacy
- [ ] Privacy policy
- [ ] Terms of service (if applicable)
- [ ] Cookie consent banner (if applicable)
- [ ] GDPR/CCPA compliance (if applicable)
- [ ] Data deletion process (if accounts/data stored)
- [ ] Contact information
- [ ] Copyright notice

## Development & Deployment
- [ ] Environment variables documented
- [ ] CI/CD pipeline
- [ ] Automated tests (unit, e2e)
- [ ] Linting (ESLint, Prettier)
- [ ] Build pipeline
- [ ] Source maps (development)
- [ ] Error tracking (e.g., Sentry) (if used)
- [ ] Analytics (privacy-friendly if required)
- [ ] Uptime monitoring
- [ ] Backup strategy (if backend/data)
- [ ] Rollback plan
</base_item_pool>

<repo_scan_hints>
Auto-check only with clear evidence. Examples of evidence (non-exhaustive):
- Favicons: `favicon.ico`, `apple-touch-icon*.png`, `mask-icon.svg`, `site.webmanifest`, `manifest.json`.
- robots/sitemap/security: `robots.txt`, `sitemap.xml`, `.well-known/security.txt`.
- Meta tags: presence in HTML templates/layouts (title/description/canonical/og/twitter/theme-color).
- Structured data: `application/ld+json` or JSON-LD generation.
- Compression / cache headers / security headers: `nginx.conf`, `Caddyfile`, `vercel.json`, `netlify.toml`, `firebase.json`, `cloudflare` config, `next.config.*`, custom server code.
- Analytics: Plausible/Umami/GA snippets, GTM IDs, vendor SDKs.
- Error tracking: Sentry initialization, DSN env vars, SDK deps.
- CI/CD: `.github/workflows/*`, `gitlab-ci.yml`, etc.

If you cannot verify, do NOT check the box.
</repo_scan_hints>
