# 01 — Project Overview

## 1. What the project is

The project is **Alcedo**, a cross-platform mobile application for logging gym workouts, planning
training, tracking progress, and sharing sessions socially, together with the backend services
that support it. Internally and in older documents the same product is called **LiftLog**; the
app display name, website and bundle identifiers were changed to Alcedo while the code and file
names kept the LiftLog heritage (see `docs/working/logo_brand_name_ledger.md` in the repo).

The repository is a derivative of the open-source project **LiftLog by Liam Morrow**
(AGPL v3). The remote is `github.com/Luke23-45/alcedo` and the first commit is titled
"initial commit of Alcedo (by Power Gym)", so the Power Gym ownership is recorded in the
history itself. Upstream attribution lives in the README and LICENSE.

## 2. Why the gym needed it

`data/information/company_information.md` in the report repository records the business case: the
gym had a social media presence but no dedicated application, and members could not see
information or plans digitally. The internship project was to build that application.

## 3. The four codebases

| Directory | Stack | Role |
|---|---|---|
| `app/` | Expo SDK 57, React Native 0.86, React 19, TypeScript | The mobile application. The main deliverable. |
| `backend-v2/` | NestJS 11, TypeScript, MongoDB 8 (Mongoose) | Newer backend: Google sign-in, JWT auth, workout sync, Stripe billing, AI coach, admin config, social graph. |
| `backend/` | ASP.NET Core 10, EF Core, SignalR | Older backend: encrypted social feed, sharing, remote backup ingestion, Claude AI planner hub. Still the production server for those features. |
| `website/` | Next.js 16, React, Tailwind 4, TypeScript | Web front end and backend-for-frontend for `backend-v2`: pricing, account, admin console. |
| `site/` | Static HTML + nginx | Marketing page and App Store privacy policy for liftlog.online. |

`app/` calls **both** backends. `app/src/services/api-consts.ts` holds the two base URLs:

| Constant | Target | Development | Production |
|---|---|---|---|
| `apiBaseUrl` | `.NET` backend (`backend/`) | `http://10.0.2.2:5264` (Android), `http://127.0.0.1:5264` | `https://api.liftlog.online` |
| `alcedoApiBaseUrl` | NestJS backend (`backend-v2/`) | `http://10.0.2.2:3000/api`, `http://127.0.0.1:3000/api` | `https://api.alcedo.app/api` |

The comment in that file states the split plainly: authentication, sync and the AI coach talk only
to `backend-v2` and never depend on the .NET backend. `app/src/store/backends/index.ts` registers
the .NET service as the built-in, non-removable backend, and the whole multi-backend / self-hosting
feature is built on it.

## 4. Feature inventory of the mobile application

Grouped as implemented in `app/src`, not as marketing claims.

| Area | Implementation |
|---|---|
| Workout logging | Live session screen, set recording, cardio sets, rest timer, per-exercise history, auto-pause on screen lock, notifications |
| Program / plan | Blueprint model, progressive overload rules, plan import from files, plan diff-and-apply editor |
| History | Month calendar, week list, day summaries, edit session, post-workout detail |
| Statistics | Heatmap, metric tiles, personal records, muscle-group load, progress charts, gifted charts |
| Social feed | Follow graph, timeline, posts, comments, reactions, shared items, end-to-end encrypted inbox, per-item encryption via AES-CBC + RSA-256-PSS |
| AI coach | SignalR streaming chat, skill registry, plan generation, premium gating via RevenueCat |
| Backups | Local export/import, plaintext export, remote backup, backup server connection editor |
| Multi-backend | User-configurable servers, feature probe per backend, per-feature backend assignment, custom headers |
| Import / export | CSV import for StrongLifts and FitNotes, plaintext export, health platform export (HealthKit, Health Connect) |
| Localisation | 19 Tolgee locale bundles |
| Theming | Light/dark/system, accent seed selection, true-black dark theme |

## 5. Product identity — names in play

| Name | Where it appears |
|---|---|
| Power Gym Budibazar Pokhara | Host organisation (report only) |
| Alcedo | `app.json` display name, website, Android/iOS strings, marketing copy |
| LiftLog | Folder name, `app/package.json` name `alcedo-react`, slug `liftlog`, bundle id `com.limajuice.liftlog`, `.liftlogplan` file type, Docker images |
| Kinetic | Design-spec phase naming in `docs/new_design/*-dark.md` ("PHASE 3 · KINETIC TRENDS") |
| Alcedo backend v2 | `backend-v2` package name `@alcedo/backend-v2` |

**Uncertain:** `app.json` sets `expo.name: "Alcedo"` and `slug: "liftlog"`, and
`app/src/models/backend.ts` labels the built-in backend name "Alcedo", so the rename is display-level
for the app but complete in `backend-v2` and `website`.

## 6. Licence and contribution rules

- `LICENSE` — GNU AGPL v3 (35 KB, full text).
- `CONTRIBUTING.md` — oxfmt/oxlint for TypeScript, CSharpier for C#, branch-then-PR workflow,
  and an **AI usage policy**: PRs must have an accepted issue, and issue text must be the author's
  own original wording.
- `.agents/skills/*` — three skill documents that define how features are added
  (apple-ios-frontend, add-setting-or-preference, add-storage-migration).

## 7. Relationship to the internship record

| Report item | Repository evidence |
|---|---|
| Position: Mobile Application Developer Intern | Frontend of `app/` plus backend work in `backend-v2` |
| Unit: Digitalization | The whole repository is the gym's digitalization output |
| Project repository | `docs/project_repo.md` → this repo; `data/project/github_repository.md` → `github.com/Luke23-45/alcedo` |
| Technologies listed in the report data | React Native, Expo, TypeScript, Expo Router — all present and correct, but incomplete; see `11_report_mapping.md` |
| Weekly log topics (components, navigation, screens, user management, workout management, feature flags, integration, testing) | All have corresponding code: `components/presentation/foundation`, `src/app/(tabs)`, `backend-v2/src/users`, `backend-v2/src/workouts`, `backend-v2/src/features` + `src/site-config`, `authenticated-fetch.ts`, the 140 Vitest specs |

See `12_open_questions_and_discrepancies.md` for the three items that do **not** reconcile with the
repository: the internship date range, the provenance of the codebase, and the authorship split.