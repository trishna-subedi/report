# 11 â€” Report Mapping

How repository evidence maps onto the report structure prescribed in `docs/guidelines/guidelines.md`.
"Source" means the authoritative file for that section in this report repository.

## 1. Front matter

| Report item | Source | Repository involvement |
|---|---|---|
| Cover page | `data/information/front_matter.md`, existing `data/documents/front.pdf` | none |
| Mentor's recommendation from company | **missing** â€” required by the guidelines | none |
| Supervisor's recommendation | `front.pdf` page 2 | none |
| Letter of approval (4 signature blocks) | `front.pdf` page 3 | none |
| Student's declaration (APA) | `front.pdf` page 4 | none |
| Acknowledgement | `front.pdf` page 5 | none |
| Abstract + keywords | to be written last | summarise chapters 1â€“4 |
| Table of contents | to be generated | follow the guideline order exactly |
| List of figures / tables / abbreviations | to be generated | see Â§5 below |

## 2. Chapter 1 â€” Introduction

| Section | Content source | Repository support |
|---|---|---|
| 1.1 Introduction | general internship framing, the gym's context | light: `01_project_overview.md` Â§2 |
| 1.2 Problem Statement | members had no digital channel; gym had only social media | `data/information/company_information.md` |
| 1.3 Objectives | derived from the role | `role_and_responsibility.md`; supported by `03_mobile_app.md`, `05_backend_v2.md` |
| 1.4 Scope and Limitations | the role boundary, single-contributor work, no device testing | strong: `09_git_history_workflow.md` Â§6, `08_testing_quality_tooling.md` Â§7 |
| 1.5 Report Organization | four-chapter summary | â€” |

## 3. Chapter 2 â€” Organization Details and Literature Review

| Section | Content source | Repository support |
|---|---|---|
| 2.1 Introduction to Organization | `company_information.md` Â§1 | none needed |
| 2.2 Organizational Hierarchy | `company_information.md` Â§3 | figure already prepared: `src/data/figures/organization_hierarchy.png` (caption "Figure 2.2" is baked into the image) |
| 2.3 Working Domains | `company_information.md` Â§4 | â€” |
| 2.4 Intern Department / Unit | `internship_information.md` | â€” |
| 2.5 Literature Review | **must be written from external sources** | repository topics to review: React Native, Expo, Expo Router, Redux Toolkit, SQLite + Drizzle ORM, NestJS, MongoDB/Mongoose, JWT with refresh rotation, feature flags, mobile UI/UX patterns, encryption on mobile. APA 7th, see `https://apastyle.apa.org/` |

## 4. Chapter 3 â€” Internship Activities

| Section | Content source | Repository support |
|---|---|---|
| 3.1 Roles and Responsibilities | `role_and_responsibility.md` â€” **polish grammar only, add nothing** | verify each claim against `03_mobile_app.md`, `05_backend_v2.md` |
| 3.2 Weekly Log | `weekly_logs.md` table â€” **keep 4 columns and 12 rows** | every row has code evidence: components â†’ `foundation/`, screens â†’ `app/src/app`, user management â†’ `backend-v2/src/users`, workout management â†’ `backend-v2/src/workouts`, feature flags â†’ `backend-v2/src/features` + `site-config`, integration â†’ `authenticated-fetch.ts`, testing â†’ 140 Vitest specs + 6 Maestro flows |
| 3.3 Description of the Project(s) | `data/project/github_repository.md` + `01_project_overview.md` | strongest section: product purpose, feature inventory, two backends, `website/` |
| 3.4 Tasks / Activities Performed | the detailed technical narrative | richest evidence: `03_mobile_app.md` Â§3â€“Â§10, `05_backend_v2.md` Â§3â€“Â§8, `08_testing_quality_tooling.md` |

### Suggested subsections for 3.4, each with hard evidence

1. Development environment and tooling â€” `app/package.json`, `app.json`, `metro.config.js`, `babel.config.js`, `eas.json`.
2. Reusable interface components and the design system â€” `foundation/` 82 files, `styles/theme.ts` tokens, platform-split components.
3. Navigation and screen implementation â€” 5 tabs, 49 route files, 24 tracked pages, `stack-with-header`.
4. State management â€” Redux Toolkit, 11 slices, the custom `addEffect` listener middleware and manual persistence.
5. Local data storage â€” SQLite + Drizzle, 17 tables, 9 SQL migrations, the file-based key-value store, `expo-secure-store`, model storage versioning with six named migration steps.
6. Frontendâ€“backend integration â€” `authenticated-fetch.ts` with single-flight 401 refresh, `backend-probe.ts`, `feed-api.ts`, SignalR AI chat.
7. User management â€” `backend-v2/src/users`, `entitlement.service.ts`, PATCH `/api/users/me`.
8. Workout management and sync â€” `backend-v2/src/workouts`, CRUD, cursor pull, batch push with compare-and-set, idempotency records, tombstones.
9. Feature management â€” `features.controller.ts` (5 flags consumed by `backend-probe.ts`) and `site-config` + admin allowlist of 16 keys with 3 encrypted secrets (AES-256-GCM).
10. Testing and debugging â€” 140 Vitest specs, `fast-check` property tests, 6 Maestro flows, 19 Jest suites, 22 TUnit classes; gate evidence in commit bodies and `docs/merge_ledger.md`.
11. Version control and branch management â€” 49 commits, one merge programme with a hazard register, documented incident and recovery.

## 5. Chapter 4, references, appendices

| Item | Note |
|---|---|
| 4.1 Conclusion / 4.2 Learning Outcome | `role_and_responsibility.md` closing paragraph plus `01_project_overview.md` Â§4 feature inventory |
| References (APA) | Every source cited in text; the literature review needs ~10â€“15 real sources |
| Bibliography | Optional; scanned during the internship but not cited |
| Appendices | Screenshots (`assets/AppScreens-â€¦/iPhones 6.9/01â€“03.png`, `src/data/figures/screen.png`), repository link (`github.com/Luke23-45/alcedo`), key source listings, weekly log if required |

### Figures and tables to number for the List of Figures / List of Tables

Pixel sizes, aspect ratios and the full numbering plan are in `18_figures_and_assets.md`. Summary:

| Kind | Item | Source |
|---|---|---|
| Figure 2.1 | Logo of Power Gym Budibazar Pokhara | `src/data/figures/company_logo.png` (215 Ã— 274) |
| Figure 2.2 | Organizational Hierarchy | `src/data/figures/organization_hierarchy.png` (586 Ã— 430, caption baked into the image) |
| Figure 3.1 | Application home, workout and statistics screens | `src/data/figures/screen.png` (893 Ã— 645) |
| Figure 3.2â€“3.4 | Home reference, brand mark, onboarding screens | `docs/new_design/home_page_screen1.svg`, `assets/logo/`, `docs/new_design/onboading/` |
| Table 2.1 | Organizational contact details | `company_information.md` Â§2 |
| Table 2.2 | Internship details | `internship_information.md` |
| Table 3.1 | Roles and responsibilities | `role_and_responsibility.md` |
| Table 3.2 | Weekly logs | `weekly_logs.md` (12 rows) |
| Table 3.3â€“3.6 | Tools and technologies, architecture summary, backend-v2 endpoints, tests by layer | `17`, `13`, `05`, `08` |

### Abbreviations

`16_glossary_and_abbreviations.md` contains a ready-made List of Abbreviations (only verified
expansions) plus a glossary of repository terms. Include only the abbreviations the report actually
uses.

### 3.4 evidence that must be phrased carefully

Three claims are tempting and would be inaccurate:

| Do not claim | Why | Say instead |
|---|---|---|
| "the app syncs workouts with the NestJS backend" | no app code calls `/api/sync/*`; only `authenticated-fetch.spec.ts` references those paths | "the backend exposes a batch push/pull sync API with idempotency and conflict handling; the mobile app has an authenticated-fetch wrapper ready for it" |
| "the app uses the AI coach, billing and social features from the new backend" | those routes have no callers in `app/src`; the app's AI chat uses the **.NET** hub `/ai-chat-v2` | "the newer backend implements the AI coach, billing and social APIs; the app's chat currently targets the .NET SignalR hub" |
| "the internship covered the .NET backend" | `backend/` (1010 files) and `tests/` (39 files) were only ever touched by the initial import commit `2eeca0d` | omit the .NET backend from the tasks section, or mention it only as the pre-existing service the app connects to |

## 6. Terminology mapping â€” report wording vs repository wording

| Report wording | Repository term | Where |
|---|---|---|
| the gym's mobile application | Alcedo (internally LiftLog) | `01_project_overview.md` Â§1, Â§5 |
| workout / workout record | `Session`, `RecordedExercise`, `RecordedSet` | `app/src/models` |
| training plan | `ProgramBlueprint`, `SessionBlueprint`, `ExerciseBlueprint` | `app/src/models` |
| exercise library | `ExerciseDescriptor`, `app/assets/exercises.json` | `app/src/services/exercise-catalog.ts` |
| screens / pages | expo-router routes; 24 tracked pages | `03_mobile_app.md` Â§3 |
| feature flag | `BackendFeature`, `GET /api/features`, `site-config` keys | `05_backend_v2.md` Â§5 |
| user profile | `FeedUser`, `PATCH /api/users/me` | `backend-v2/src/users` |
| social sharing | feed, posts, shared items, reactions, comments | `app/src/components/presentation/feed` |
| AI coach | AI planner / SignalR chat / LiteLLM | `app/src/services/ai-chat-service-v2.ts`, `backend-v2/src/ai` |

## 7. Report format rules that affect the build (`docs/guidelines/guidelines.md`)

- A4; margins Top 1", Bottom 1", Right 1", Left 1.25" (presumably inches â€” confirm).
- Roman page numbers from the certificate page through the lists; Arabic restarting at 1 from
  Chapter 1; page number centred at the bottom.
- Times New Roman; body 12 pt; headings 16 pt (chapter), 14 pt (section), 12 pt (sub-section), all bold.
- Paragraphs justified, 1.5 line spacing.
- Figures centred with the caption **below**; tables centred with the caption **above**; captions bold,
  12 pt.
- APA referencing.

## 8. Existing draft status

`data/documents/front.pdf` already contains, correctly formatted: cover page, supervisor's
recommendation, letter of approval, student's declaration, acknowledgement. Still to build: abstract,
table of contents, list of figures, list of tables, list of abbreviations, Chapters 1â€“4, references,
appendices. One defect to fix: the acknowledgement page prints `Roll No: 79011` while the cover prints
`Roll No: 79011927`.