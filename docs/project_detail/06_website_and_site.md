# 06 — Website and Static Site

Two small deployments that sit beside the app. Neither is part of the mobile build.

## 1. `website/` — Next.js web app and backend-for-frontend

| Item | Value |
|---|---|
| Framework | Next.js 16 (App Router), React, TypeScript 5, Tailwind CSS 4 (`@tailwindcss/postcss`) |
| Scripts | `dev`, `build`, `start`, `lint` |
| Files | 40 (excluding `node_modules`, `.next`) |
| Branding | "Alcedo — Train with intent"; fonts Geist / Geist Mono |
| Purpose | Public marketing + pricing, Google sign-in, account page, admin console — all by proxying `backend-v2` |

Pages: `/`, `/login`, `/pricing`, `/privacy`, `/account`, `/admin`.

Route handlers (the BFF):

| Route | Purpose |
|---|---|
| `api/_lib/bff.ts` | Shared proxy: `BACKEND_URL` (default `http://localhost:3000`), `backendApi(path)` = `${BACKEND_URL}/api${path}`, httpOnly cookies `alcedo_access` / `alcedo_refresh` (SameSite=Lax, Secure in production), single-flight `refreshTokenPair()` keyed on the sha256 of the refresh token so the refresh path does not trip the backend's `AUTH_REFRESH_REUSED` protection |
| `api/auth/google`, `api/auth/me` | Sign-in and identity |
| `api/billing/plans`, `api/billing/status`, `api/billing/checkout` | Pricing page and checkout |
| `api/admin/config`, `api/admin/users`, `api/admin/users/[googleSub]` | Admin console |

The design intent is that the browser never sees a backend URL or token.

**One mismatch worth knowing:** the cookie `ACCESS_MAX_AGE` is 1200 s while the backend's
`JWT_ACCESS_TTL_SECONDS` default is 900 s, so the refresh path runs routinely.

Housekeeping: `website/README.md` is still unmodified `create-next-app` boilerplate, and a `.next`
build cache is committed.

## 2. `site/` — static marketing and privacy

16 files, no framework, all CSS and JS inlined.

- `index.html` 37 KB — marketing page ("LiftLog: Simple Gym Tracking, Free for Everyone") using the
  **older LiftLog palette** (DM Serif Display + DM Sans, `--base: #f0efe8`, `--accent: #005500`), i.e.
  pre-rebrand compared with `app/` and `website/`.
- `privacy.html` 10 KB — the App Store privacy policy.
- `Dockerfile` — five `COPY` lines onto `nginx:alpine`.
- `assets/img/` — 10 files: 6 store/social screenshots (`home.png`, `stats.png`, `exercise-stats.png`,
  `ai-planner.png`, `workoutpage.png`, `portrait_black.png`), 3 store badges, `tnw-logo.svg`
  (The New New Stack press mention), `icon.png`.
- Purpose per the root README: source for liftlog.online and the privacy policy. Untracked workflow
  `static-site.yml` publishes it as a Docker image.

## 3. What this means for the report

Both are legitimate deliverables if the internship included a web presence, and both are easy to
overstate. `website/` is the one that connects to `backend-v2` and is therefore the most defensible
thing to describe as backend integration work. `site/` is static marketing content and should only
be mentioned if it was actually part of the internship.

See `12_open_questions_and_discrepancies.md` item 8.