# 02 — Repository Map

Counts are file counts at `0ee0ebd` (`git ls-files`), excluding `node_modules`, `dist`, `.expo`,
`bin`, `obj` and platform folders.

## 1. Top level

| Path | Files at HEAD | Purpose |
|---|---|---|
| `app/` | 1437 | React Native / Expo mobile application |
| `backend/` | 1010 | ASP.NET Core 10 API (`LiftLog.Api`, `LiftLog.Lib`, `RevenueCat` Kiota client), `Dockerfile`, `README.md` |
| `backend-v2/` | 129 | NestJS 11 + MongoDB backend |
| `docs/` | 96 | Design specs, page tracker, polish ledgers, merge ledger, JSON schemas, brand decisions |
| `tests/` | 39 | `LiftLog.Tests.Api` (TUnit) plus `csv-import-test-files` (5 CSV fixtures) |
| `website/` | 35 | Next.js 16 web app / BFF for `backend-v2` |
| `assets/` | 28 | Brand master art, store screenshots, store badges |
| `examples/` | 25 | `remote-backup` reference server + Terraform |
| `site/` | 16 | Static marketing + privacy site for nginx |
| `scripts/` | 9 | Release, screenshot and validation tooling; has its own `package.json`, `tsconfig.json`, `package-lock.json`, `README.md` |
| `plugins/` | 8 | `liftlog-plan-builder` Claude/Cline plugin |
| `.agents/` | 3 | Skill documents: `apple-ios-frontend`, `add-setting-or-preference`, `add-storage-migration` |
| `.config/` | 1 | `dotnet-tools.json` pinning CSharpier 1.2.6 |
| root | 10 | `AGENTS.md`, `CONTRIBUTING.md`, `README.md`, `LICENSE`, `LiftLog.sln`, `.editorconfig`, `.gitattributes`, `.gitignore`, `.csharpierignore`, `.dockerignore` |

## 2. Not tracked by git — `.github/`

`.github/` **exists on disk** with 17 workflow files and an issue template, but `.gitignore` line 21
contains `.github`, and `git ls-files .github` returns 0 files. Consequence: the CI definitions are
inherited from upstream and are not part of this project's committed history. Everything else in
this repository tracks quality gates manually, recorded in commit messages and `docs/merge_ledger.md`.

Workflows present on disk (untracked):

`android-build.yml`, `android-publish.yml`, `api-build.yml`, `api-publish.yml`, `api-test.yml`,
`backupserver-build.yml`, `backupserver-publish.yml`, `discussion-welcome-comment.yml`,
`format.yml`, `ios-build.yml`, `ios-publish.yml`, `plan-builder-skill-build.yml`,
`pr-template-comment.yml`, `static-site-build.yml`, `static-site.yml`, `ui-unit-test.yml`,
plus `.github/release.yml` and `.github/ISSUE_TEMPLATE/bug_report.yaml`.

## 3. Monorepo shape

There is **no** root `package.json`, no `pnpm-workspace`, no `turbo.json` and no root lockfile.
Each subproject installs and builds on its own:

| Subproject | Install | Build | Test | Lint |
|---|---|---|---|---|
| `app/` | `npm install` (792 KB lockfile) | `expo prebuild` / EAS | `npm test` (Vitest), `npm run e2e` (Maestro) | `npm run lint`, `npm run format` |
| `backend-v2/` | `npm ci` (365 KB lockfile) | `npm run build` (nest build) | `npm test` (Jest) | `npm run lint` (oxlint) |
| `website/` | `npm install` | `npm run build` (Next) | none configured | `npm run lint` |
| `backend/` | `dotnet restore` | `dotnet build` | `dotnet run` in `tests/LiftLog.Tests.Api` (TUnit host) | `dotnet csharpier check .` |

`docs/merge_ledger.md` records the cost of this shape: during the branch merge the four codebases
had to be gated manually and `app/package-lock.json` had to be regenerated rather than merged.

## 4. `app/` layout

| Path | Purpose |
|---|---|
| `app/app.json` | Expo config: name Alcedo, slug liftlog, bundle `com.limajuice.liftlog`, 17 config plugins, `typedRoutes: true`, `reactCompiler: true` |
| `app/eas.json` | EAS build profiles: development, preview, production |
| `app/metro.config.js` | `.sql` source extension, blockLists `*.spec.*` and `__test__/` from bundles, maps `crypto` → `react-native-quick-crypto`, forces the native `styled-components` entry, injects the styled shim polyfill |
| `app/babel.config.js` | `babel-preset-expo`, namespace plugin, inline-import for `.svg`/`.sql`, worklets plugin |
| `app/vitest.config.ts` | Vitest 4, jsdom, `test/setup.ts`, v8 coverage scoped to models/services/store/utils/hooks |
| `app/drizzle.config.ts` | schema `./src/db/schema.ts`, out `./src/drizzle`, sqlite/expo driver |
| `app/tsconfig.json` | `strict`, `strictNullChecks`, `noUncheckedIndexedAccess`, alias `@/*` → `src/*` |
| `app/.oxlintrc.json`, `app/eslint.config.js`, `app/.oxfmtrc.json` | Lint (oxlint primary) and format (oxfmt, printWidth 120) |
| `app/modules/` | `workout-worker` native module (Kotlin + Swift, protobuf messages), `native-lib` |
| `app/plugins/` | 5 local Expo config plugins (see `10_scripts_and_automation.md`) |
| `app/patches/` | 5 `patch-package` patches (styled-components, react-native-paper, others) |
| `app/polyfills/` | `styled-shim.js` Hermes `document` stub |
| `app/assets/` | Generated icon/splash/notification PNGs, exercise catalogue `exercises.json`, 19 locale files, 11 avatar JPEGs, 5 feed media files |
| `app/public/` | `index.html`, `404.html`, `.well-known/apple-app-site-association`, `.well-known/assetlinks.json` |
| `app/src/` | Application source — 686 `.ts`, 518 `.tsx` (see `03_mobile_app.md`) |
| `app/test/` | `setup.ts` and `shims/` for Vitest |
| `app/.maestro/` | 6 YAML files: `config.yaml`, `fresh-install-onboarding`, `completing-a-session`, `cardio-session`, `creating-a-plan`, `exercise-manager` |
| `app/scripts/` | `generate-branding.mjs`, `generate-json-schemas.js`, `build-plan-validator.mjs` |
| `app/README.md` | 253 bytes, near-empty, garbled heading |

## 5. `docs/` layout

| Subfolder | Contents |
|---|---|
| `docs/new_design/` | 24-page verification tracker `page-verification.md`, phase design briefs (`workout-flow-*`, `trends-dark`, `history-dark`, `social-dark`, `settings-dark`, `backup-redesign`, `diff-save-redesign`, `exercise-editor-redesign`, `workout-editor-redesign`, `offline-first-plan`), SVG references, `onboading/` onboarding SVGs |
| `docs/polish_ui/` | 22 per-area polish ledgers (one per screen group) |
| `docs/working/` | `styles_ledger.md`, `logo_brand_name_ledger.md` (rebrand decisions D1–D6, per-platform rename table) |
| `docs/schemas/` | 45 generated JSON schema files: AI plan, program blueprint, workout worker messages |
| `docs/img/` | `includedexcludedplaintext.png` and 12 SVGs |
| `docs/index.md` | Document index — the repository's own "read this first" entry point, one line per document |
| `docs/merge_ledger.md` | The branch-merge programme of record: branch inventory, topology proof, hazard register H1–H6, phases 0–4, execution log, one documented incident and its recovery |

**All seven documentation links in the root `README.md` are broken.** Verified absent on disk:
`docs/SelfHosting.md`, `docs/PlanFileFormat.md`, `docs/FeedProcess.md`, `docs/RemoteBackup.md`,
`docs/PlaintextExport.md`, `docs/WorkoutWorker.md`, `docs/Migrations.md`. Their subjects are still
implemented in code (e.g. `app/src/models/storage/versions/`, `app/src/services/backup-format`,
`examples/remote-backup/`), only the prose documents are missing.

**Two stale statements inside the repository's own docs:**
- `docs/index.md` says `page-verification.md` covers "all 20 pages"; the tracker and the commits
  cover 24.
- `AGENTS.md` says `app/src/styles/theme.ts` is 857 lines; it is 947 lines / 34,951 bytes.

## 6. `tests/` layout

| Path | Purpose |
|---|---|
| `tests/LiftLog.Tests.Api/` | TUnit test host for the .NET API: 30 `.cs` files (15 in `Integration/`, 6 in `Integration/Helpers/`, 1 `Integration/Providers/ApiFactory.cs`, 5 in `Unit/`, 2 in `Unit/Helpers/`, `GlobalUsings.cs`); 18 files contain `[Test]`, 22 test classes plus 4 support classes, 115 `[Test]` methods, 111 `[Arguments]` rows |
| `tests/docker-compose.yml` | Postgres 17 on port 5401, LocalStack S3 on 4566 |
| `tests/csv-import-test-files/` | 5 real CSV exports: FitNotes (kg, lb, lb edge cases), StrongLifts (kg, lb). Consumed by the **app's** Vitest suite via `app/src/services/csv-import/__test__/fixtures.ts` |

`tests/` is therefore a shared fixture directory across two stacks, not only a .NET test root.

## 7. Root policy files

| File | Content |
|---|---|
| `AGENTS.md` | Development contract: styled-components (not Tailwind) in `app/`, section-file layout, `backend/` is .NET and "usually does not need changing", CSharpier before committing |
| `CONTRIBUTING.md` | oxfmt/oxlint/CSharpier, branch-then-PR, PR checklist, AI usage policy, AGPL v3 |
| `.editorconfig` | 2 rules: silence CA1860 for C#, 2-space indent for TS/JS |
| `.gitattributes` | `* text=auto`, `linguist-generated` for `backend/RevenueCat/**`, `app/src/gen/proto.*` |
| `.gitignore` | ~250 patterns, mostly .NET/VS heritage, plus `node_modules/`, `.vscode`, `tmp-*.log` **not** ignored (a 2 MB `app/tmp-lint.log` is committed) |
| `.csharpierignore` | `**/Migrations/**/*`, `app/**/*` |
| `.dockerignore` | deny-all then re-include `backend`, `docs/schemas`, `.editorconfig` |