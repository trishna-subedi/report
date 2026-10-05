# 08 — Testing, Quality Gates and Build Tooling

The repository has one of the better-documented quality processes of any student project, and it is
worth describing accurately in the report: the gates are real, they were run manually, and the
results were recorded in writing.

## 1. Test inventory

| Stack | Framework | Location | Count | How to run |
|---|---|---|---|---|
| `app/` | Vitest 4 + jsdom, `fast-check` for property tests | 140 `*.spec.ts(x)` files under `app/src`, plus 2 `.snap` files | 140 files | `npm test`, `npm run test:coverage` |
| `app/` end-to-end | Maestro | `app/.maestro/*.yaml` | 6 YAML files (5 flows + config) | `npm run e2e` |
| `backend-v2/` | Jest 30 + ts-jest | 19 `*.spec.ts` colocated in `src` | 194 `it(` blocks (213 executed with `it.each`) | `npm test`, `npm run test:cov` |
| `backend/` + `tests/` | TUnit 1.21.20 | `tests/LiftLog.Tests.Api` | 30 `.cs` files, 18 test-bearing, 22 test classes, 115 `[Test]`, 111 `[Arguments]` rows | `dotnet run` |
| `website/` | none configured | — | — | — |

## 2. App tests in detail

- `vitest.config.ts`: `globals: false`, `environment: 'jsdom'`,
  `include: ['**/*.spec.ts', '**/*.spec.tsx']`, `setupFiles: ['./test/setup.ts']`.
- Coverage (v8) is scoped to `src/{models,services,store,utils,hooks}`, excluding specs, `__test__`,
  `__tests__`, `test-assets`, `src/gen`, `src/drizzle`.
- Two custom plugins: a `.sql` inline-import shim, and a remap of `expo-sqlite` /
  `drizzle-orm/expo-sqlite` to `drizzle-orm/libsql` plus `test/shims/*`.
- `test/setup.ts` mocks `react-native`, `react-native-reanimated`, `react-native-gesture-handler`,
  `expo-localization`, `expo`, and provides an in-memory `expo-file-system`.
- Distribution by area: components 51, store 34, models 25, services 19, utils 7, db 2, hooks 2
  (140 total, none under `src/app`).
- Naming convention: `*-simulation.spec.ts` for screen-level simulations, `*-logic.spec.ts` for pure
  logic, `*-data.spec.ts` / `*-model.spec.ts` for view models.
- CSV import tests use the five real fixtures in `tests/csv-import-test-files` via
  `app/src/services/csv-import/__test__/fixtures.ts`.
- Snapshot files: `src/models/__snapshots__/built-in-programs.spec.ts.snap` and
  `src/store/settings/__snapshots__/export-plaintext-effects.spec.ts.snap`.

## 3. Maestro flows (`app/.maestro`)

`config.yaml` (appId `com.limajuice.liftlog`, `continueOnFailure: false`, order starts with
`fresh-install-onboarding`) plus `fresh-install-onboarding.yaml`, `completing-a-session.yaml`,
`cardio-session.yaml`, `creating-a-plan.yaml`, `exercise-manager.yaml`.

## 4. Static analysis, formatting, type checking

| Tool | Scope | Configuration |
|---|---|---|
| oxlint | primary linter (app and backend-v2) | `app/.oxlintrc.json`; `app` also runs `oxlint-tsgolint` for type-aware linting |
| ESLint 9 | app, flat config, effectively the React Compiler rule | `app/eslint.config.js` — `eslint-config-expo`, `eslint-plugin-react-compiler`, `unused-imports`, `check-file` |
| React Compiler | enabled in `app.json` `experiments` and via `babel-plugin-react-compiler` | `react-compiler-runtime` dependency |
| oxfmt | formatter, single quotes, trailing commas, semi, **printWidth 120** | `app/.oxfmtrc.json` (a stale `.prettierrc` also exists) |
| `tsgo` | `npm run typecheck` in the app | `@typescript/native-preview` |
| `tsc --noEmit` | `npm run typecheck` in backend-v2 | — |
| CSharpier 1.2.6 | C# formatting, pinned in `.config/dotnet-tools.json` with `rollForward: false` | `.csharpierignore` excludes `**/Migrations/**` and `app/**` |

Also: `patch-package` runs on `postinstall` with 5 patches — `styled-components+6.1.8.patch`,
`react-native-paper+5.15.3.patch`, `bignumber.js+9.3.1.patch`, `data-async-iterators+1.4.6.patch`,
`linq+4.0.3.patch`. `metro.config.js` blockLists `*.spec.*`, `__test__/`, `__tests__/` and `/test/`
so co-located tests never get bundled as routes, and maps bare `crypto` imports to
`react-native-quick-crypto`.

## 4.1 Repository documentation drift (do not quote these numbers)

| Claim | Reality |
|---|---|
| `AGENTS.md`: `app/src/styles/theme.ts` is 857 lines | 947 lines / 34,951 bytes |
| `AGENTS.md`: "roughly ~83 remaining importers" of the deprecated theme shims | earlier tooling comment claimed 147; neither is machine-checked — use "approximately 80–150" if the report needs a figure, or omit it |
| `docs/index.md`: `page-verification.md` covers "all 20 pages" | 24 pages |
| `README.md`: seven `docs/*.md` links | all seven files are absent from disk |
| `backend-v2/README.md`: "no Stripe by design", "12 suites" | Stripe is fully implemented; 19 suites |
| `.vscode/launch.json` references `LiftLog.Web` | folder does not exist (pre-React-Native MAUI leftover) |

## 5. Build and release

| Item | Detail |
|---|---|
| EAS profiles (`app/eas.json`) | `development` (dev-client, internal, apk, channel `development`), `preview` (internal, channel `preview`), `production` (channel `production`, `autoIncrement: true`), `cli.appVersionSource: remote` |
| Native build | `expo run:android` (debugOptimized / release variants), `expo run:ios`, `expo prebuild` |
| Images | untracked workflows publish `ghcr.io/liammorrow/liftlog:api` (linux/amd64, linux/arm64) and the static site |
| .NET | `backend/Dockerfile` (SDK 10.0 → ASP.NET 10.0, non-root), `backend/docker-compose.yml` (SQLite) and `docker-compose.postgres.yml` |
| backend-v2 | `docker-compose.yml` with `mongo:8.0` (healthchecked) and LiteLLM on port 4000 |
| Tests infrastructure | `tests/docker-compose.yml`: Postgres 17 on 5401, LocalStack on 4566 |

## 6. How the gates were actually run — and this is the report-worthy part

`.github/` is **gitignored** (`.gitignore` line 21) and `git ls-files .github` returns 0 files, so
none of the CI definitions in that folder are part of this project's history. Quality was gated
manually, and the evidence is written down:

- **Commit bodies.** 35 of 49 commits carry a structured body containing: a bullet list of concrete
  fixes with file paths, an explicit `Tests:` line, and a running full-suite tally. The tally
  progresses across commits: 1,472 → 1,499 → 1,538 → 1,637 → 1,718 → 1,737 → 1,760 → 1,786 → 1,948 →
  1,962 → 1,970 → 1,978 → 1,985 → 2,052 → 2,104 → 2,144. Commit bodies also state gate results
  ("typecheck 0 errors; oxlint/eslint/react-compiler/oxfmt clean") and explicit honesty notes
  ("Not claimed: pixel/animation feel, real-device performance, haptics — no device used").
- **`docs/merge_ledger.md`** records per-phase gate evidence for the branch merge, including
  `npm run typecheck`, `npm run lint`, `npm test` for the app, and `npm run typecheck`, `npm run lint`,
  `npm test` for backend-v2.
- **`docs/new_design/page-verification.md`** records per-page verification state.

This is a defensible description of quality assurance for a report: gates defined, executed, and
recorded per change, with known gaps stated rather than hidden.

## 7. Known quality gaps

- No tests under `app/src/app` (routes); screen behaviour is covered through
  `src/components/**/*-simulation.spec.ts` instead.
- backend-v2 has no integration/e2e suite and no Mongo-backed tests; repositories are mocked.
- `website/` has no tests.
- .NET live Anthropic tests are opt-in behind `LIFTLOG_LIVE_AI_TESTS=true`.
- No device was used, so animation feel and on-device performance were never verified (stated in the
  commit bodies).