# 19 — Verification Log

Audit trail for this documentation set. Records how each claim was checked, what was corrected, and
what remains unverified.

## 1. Method

| Technique | Used for |
|---|---|
| `read` on manifests and rule files | `app/package.json`, `backend-v2/package.json`, `AGENTS.md`, `README.md`, `docs/index.md`, `api-consts.ts` |
| PowerShell `Get-ChildItem` counts | every file and directory count in this set |
| PowerShell `Select-String` | test-attribute counts, pattern searches, route/path searches |
| `git log` / `git show --stat` / `git shortlog` / `git branch -a` / `git check-ignore` / `git ls-files` | history, authorship, merge structure, the `.github` finding |
| `pdftotext` | extracting `data/documents/front.pdf` and the sample reports |
| `System.Drawing` | pixel dimensions of every image listed in `18_figures_and_assets.md` |
| `Test-Path` | confirming the seven broken `README.md` doc links |

An earlier pass used five parallel exploration sub-agents. **Their output was treated as a lead, not
as fact.** Every number that mattered was then re-measured directly, and ten of their figures were
wrong (see §3).

## 2. Claims verified directly

| Claim | Evidence |
|---|---|
| Branch `ui-polish`, HEAD `0ee0ebd`, `main` = `ff62544` | `git log`, `git branch -a` |
| 49 commits total, all between 2026-09-21 14:55 and 2026-09-23 16:17 +0545 | `git log --all` |
| Authors: `krishna subedi` 17, `Muse <muse@hatch.local>` 31, `Muse <muse@local>` 1 | `git shortlog -sne --all` |
| Repo git identity is `krishna subedi <krishnasubedi2366@gmail.com>` | `git config user.name/user.email` |
| One merge commit `2bedab1` | `git log --merges` |
| `.github/` exists on disk with 17 workflows but is **gitignored and untracked** | `git check-ignore -v .github` → `.gitignore:21`; `git ls-files .github` → 0 |
| `app/src`: 686 `.ts` + 518 `.tsx` | direct count |
| `app/src/app`: 49 `.tsx` + 1 `.ts` | direct count |
| `src/components` 844 files = presentation 774 + smart 67 + layout 3 | direct count |
| Presentation folder distribution (settings 177 … navigation 6) | direct count |
| `src/services` 49 top-level files; `src/store` 88; `src/models` 85; `src/hooks` 19; `src/utils` 39; `src/i18n` 26 (19 locales, all non-empty) | direct count |
| `src/drizzle` has exactly 9 `.sql` migrations `0000`–`0008` | direct list |
| 140 `*.spec.ts(x)` under `app/src`, none under `src/app`; distribution components 51, store 34, models 25, services 19, utils 7, db 2, hooks 2 | direct count |
| 2 snapshot files | direct list |
| `theme.ts` is 947 lines | direct count (contradicts `AGENTS.md`'s 857) |
| `app/assets/exercises/`: only `en.json` 661,672 B, `ru.json` 1,143,289 B, `it.json` 6,380 B, `fi.json` 65 B populated; the other 15 are 4-byte placeholders | direct listing |
| `docs/schemas` = 45 files; `docs/polish_ui` = 22 ledgers; `docs/new_design` = 18 files + `onboading/` | direct count |
| All seven `README.md` `docs/*.md` links are absent | `Test-Path` × 7 |
| backend-v2: 19 spec files, 194 `it(` occurrences, 3 `it.each` | `Select-String` |
| backend-v2: 100 implementation `.ts` + 19 specs + 1 `.md`, 10,193 lines | direct count |
| backend-v2: `.env.example` is 66 lines; 11 controllers | direct count |
| backend-v2: `alcedoApiBaseUrl` is used by exactly 6 files; **no** `/sync`, `/workouts`, `/users/me`, `/social/`, `/billing/`, `ai/conversations` string exists in non-spec app source | `Select-String` across `app/src` |
| `app/src/models/backend.ts`: `BackendFeature = 'feed' \| 'aiPlanner' \| 'backup'`, `ReportedBackendFeature` adds `'sharing'`, `backendFeatures = ['feed','aiPlanner','backup']` | direct read |
| `.NET` tests: 30 `.cs` files, 18 test-bearing, 22 test classes + 4 support classes, 115 `[Test]`, 111 `[Arguments]` | `Select-String` + class listing |
| TUnit `1.21.20`, NSubstitute `5.3.0`, `Microsoft.NET.Test.Sdk` `18.3.0` | direct read of the csproj |
| 5 `patch-package` patches, named exactly | direct list |
| Maestro: 6 YAML files, `appId: com.limajuice.liftlog`, `continueOnFailure: false` | direct list and read |
| Commit `0ee0ebd` "feat(): onboarding design" changed 7 files, +905 insertions, **no code** — only 6 SVGs and `docs/index.md` | `git show --stat` |
| There is **no** onboarding route file; the only onboarding code is `components/smart/welcome-wizard.tsx` | direct file search |
| Image dimensions in `18_figures_and_assets.md` | `System.Drawing` |
| `front.pdf` acknowledgement prints `Roll No: 79011` while the cover prints `79011927` | `pdftotext` |

## 3. Corrections made to the first draft of this documentation set

Ten figures came from sub-agent summaries and were wrong. All are fixed in place.

| # | Wrong claim | Correct value |
|---|---|---|
| 1 | `presentation` 763 files | 774 |
| 2 | `smart` 48 components | 67 files |
| 3 | app spec distribution: components 57, store 30, models 21, services 17 | components 51, store 34, models 25, services 19 |
| 4 | `.NET` tests: 23 `.cs` files, Integration 13 files | 30 `.cs` files; Integration 15 + 6 Helpers + 1 Providers; Unit 5 + 2 Helpers |
| 5 | `docs/schemas` 46 files | 45 |
| 6 | onboarding present in the route tree | no onboarding route; design SVGs only |
| 7 | `theme.ts` "35 KB" and 857 lines (from `AGENTS.md`) | 947 lines, 34,951 bytes |
| 8 | five broken doc links in `README.md` | all seven are broken |
| 9 | app is integrated with backend-v2 for "auth, sync and the AI coach" (quoting the code comment) | at `0ee0ebd` only **auth** is integrated; sync/social/billing/AI endpoints are not called from app code |
| 10 | i18n locales partly empty | `src/i18n` locales are all populated; it is `app/assets/exercises` that has 15 four-byte placeholders |
| 11 | SQLite schema has "18 tables" | **17** `sqliteTable(...)` declarations; the 18th entry was a duplicated schema name in the earlier summary |
| 12 | named model-storage migrations "not found" in a first pass | they do exist, in `src/models/storage/versions/migrations/steps/` (6 steps); the first search did not recurse into that folder |

Further figures confirmed on the second pass and now stated as verified: 11 Redux slices in
`store.ts`; 16 `EDITABLE_KEYS` and 3 `SECRET_KEYS` in `admin.controller.ts`; the 5 feature flags and
their values in `features.controller.ts`; 6 `*.skill.ts` AI skills; **39** HTTP route decorators
across the 11 backend-v2 controllers; 15 `[Http*]` actions across 9 .NET controllers; 19 .NET
migrations plus 4 model snapshots; the 24-page tracker confirmed by the status table row
`| 24 | AI planner chat | - | done 2026-09-22 |` in `page-verification.md`.

## 4. Explicitly NOT verified

- **No build or test run was performed.** `npm test`, `dotnet run`, `npm run typecheck` were not
  executed. Therefore no claim in this documentation set asserts that the suite currently passes. The
  pass/fail evidence quoted comes from commit messages and `docs/merge_ledger.md`, which are
  historical statements, not present-day results.
- The working tree has 9 uncommitted modified files (see `09_git_history_workflow.md` §8), so a test
  run would not describe `0ee0ebd` exactly.
- Production deployments of `api.liftlog.online` and `api.alcedo.app` were not contacted. The code
  comment in `api-consts.ts` says the backend-v2 production URL still needs to be set before release
  builds, so treat `api.alcedo.app` as unconfirmed.
- No mobile device or emulator was used; on-device behaviour is unknown.
- Whether Google sign-in can actually run is unknown: `auth-config.ts` contains placeholders
  (`YOUR_WEB_CLIENT_ID…`) and `GOOGLE_CLIENT_ID` is empty in `.env.example`.
- `tests/LiftLog.Tests.Api` needs Postgres on 5401 and LocalStack on 4566; not started here, so
  per-file `[Test]` tallies are attribute counts, not executed-case counts.
- The exercise catalogue contents (`app/assets/exercises.json`, 251 KB) were not parsed.
- `plugins/liftlog-plan-builder` internals and `examples/remote-backup` Terraform were listed but not
  read line by line.

## 5. Claims that are second-hand but consistent

These come from the repository's own prose and were not independently re-derived. They are safe to
use as *attributed* statements, not as facts:

- Running full-suite tallies in commit bodies (1,472 → 2,144 tests across the sweep).
- `docs/merge_ledger.md`'s hazard register, phases and incident narrative.
- `docs/new_design/page-verification.md`'s per-page verification states.
- `AGENTS.md`'s claim of roughly 83 remaining importers of the deprecated theme shims.
- The .NET README's run instructions.

## 6. Maintenance rule for this folder

When the project repository changes, update the affected numbered file and add a line to §2 of this
log. Do not restate a claim here that is not re-verified. If a number cannot be re-measured, mark it
**uncertain** in the file it appears in rather than deleting the uncertainty.