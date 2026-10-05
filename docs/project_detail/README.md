# Project Detail Documentation — Alcedo / LiftLog

Single reference for the internship project repository. Written once so the repository does
not have to be re-read when writing the internship report.

## Source

| Item | Value |
|---|---|
| Local path | `C:\Users\Hellx\Documents\Programming\python\Project\personal\LiftLog` |
| Git remote | `git@github.com:Luke23-45/alcedo.git` |
| Public URL | https://github.com/Luke23-45/alcedo |
| Branch reviewed | `ui-polish` |
| HEAD reviewed | `0ee0ebd` — "feat(): onboarding design" |
| `main` | `ff62544` — "docs: close merge ledger - all branches merged to main" |
| Commit range | `2eeca0d` (2026-09-21 14:55 +0545) → `0ee0ebd` (2026-09-23 16:17 +0545) |
| Licence | GNU AGPL v3 (inherited from upstream) |
| Organisation | Power Gym Budibazar Pokhara |

## File index

| File | What it contains |
|---|---|
| `01_project_overview.md` | What the project is, the four codebases, product identity, feature inventory |
| `02_repository_map.md` | Top-level directory map, file counts, build and run entry points per project |
| `03_mobile_app.md` | `app/` — Expo / React Native app: versions, routes, components, state, storage, services |
| `04_backend_dotnet.md` | `backend/` — ASP.NET Core 10 API, three auth schemes, EF Core, TUnit tests |
| `05_backend_v2.md` | `backend-v2/` — NestJS 11 + MongoDB: modules, every endpoint, auth, payments, AI |
| `06_website_and_site.md` | `website/` Next.js web app / BFF, `site/` static marketing and privacy page |
| `07_design_system_and_screens.md` | Theme tokens, screen inventory, design specs, polish ledgers, brand ledger |
| `08_testing_quality_tooling.md` | Vitest, Jest, TUnit, Maestro, lint/format/typecheck, EAS builds, gate discipline |
| `09_git_history_workflow.md` | Branches, commits by phase, merge programme, authors, ledger documents |
| `10_scripts_and_automation.md` | `scripts/`, patches, local Expo config plugins, `.agents` skills, plugin, examples |
| `11_report_mapping.md` | Which repository evidence supports which report section, terminology mapping |
| `12_open_questions_and_discrepancies.md` | Open questions and factual conflicts that must be resolved before writing |
| `13_architecture_and_data_flow.md` | How the four codebases fit together: request flows, offline-first model, multi-backend routing |
| `14_security_and_privacy.md` | Authentication, encryption, secret storage, privacy modes, security controls |
| `15_local_setup_and_commands.md` | Reproducible local setup, commands, ports and environment variables per stack |
| `16_glossary_and_abbreviations.md` | Ready-made List of Abbreviations plus a glossary of repository terms |
| `17_dependency_inventory.md` | Every dependency and version per project |
| `18_figures_and_assets.md` | Image inventory with pixel sizes, aspect ratios and a figure numbering plan |
| `19_verification_log.md` | Audit trail: what was checked, how, corrections made, remaining uncertainty |

## Ground rules used while writing these files

1. Every claim is a path, a count, or a quoted identifier from the repository at `0ee0ebd`.
   Anything not verifiable is marked **uncertain** or **not found**.
2. Counts were taken from the working tree, not from prose in the repository's own READMEs.
   Where a repository README disagrees with the code, the code wins and the drift is recorded.
3. Generated and vendored code (RevenueCat Kiota client, Drizzle migrations, protobuf output,
   locale bundles, `.expo` build cache) is identified as such so it is never mistaken for
   hand-written work.
4. Anything that cannot be supported by the repository — real internship dates, the roll number,
   who signed which page — is a question, not a fact. Those are collected in
   `12_open_questions_and_discrepancies.md` and must not be invented.

## Quick facts

- Four codebases: React Native/Expo mobile app, ASP.NET Core 10 backend, NestJS 11 backend,
  Next.js 16 website, plus a static marketing site.
- Mobile app: Expo SDK ~57.0.26, expo-router ~57.0.24, React 19.2.3, React Native 0.86.3,
  TypeScript ~6.0.3 with `strict` and `noUncheckedIndexedAccess`.
- 49 route files (`app/src/app`), 686 `.ts` + 518 `.tsx` under `app/src`,
  844 component files (`presentation` 774, `smart` 67, `layout` 3) in 15 presentation folders.
- Local persistence: SQLite through `expo-sqlite` + `drizzle-orm`, 17 tables, 9 SQL migrations,
  plus six named model-storage migration steps.
- State: Redux Toolkit, 11 slices, hand-written persistence effect middleware.
- Design system: `app/src/styles/theme.ts`, 947 lines, 192 named text styles.
- Testing: 140 Vitest spec files in the app (51 components, 34 store, 25 models, 19 services,
  7 utils, 2 db, 2 hooks), 19 Jest suites / 194 `it()` blocks in `backend-v2`, and
  22 TUnit test classes (115 `[Test]`, 18 test-bearing files) in `tests/LiftLog.Tests.Api`,
  plus 6 Maestro flows.
- `backend-v2` exposes 11 controllers under the `/api` prefix; `backend` exposes 15 controller
  actions plus a health endpoint and two SignalR hubs.
- **Important:** at `0ee0ebd` the mobile app calls `backend-v2` for **authentication only**
  (`auth-service.ts`, `authenticated-fetch.ts`, `account-screen.tsx`). Its sync, social, billing and
  AI endpoints exist server-side but are not called from app code. See `13_architecture_and_data_flow.md`.
- Git history: 49 commits, 17 by `krishna subedi` and 32 by the agent identity `Muse`,
  all inside a 3-day window (2026-09-21 to 2026-09-23).