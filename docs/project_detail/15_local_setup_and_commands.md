# 15 — Local Setup and Commands

Everything needed to reproduce the project locally, gathered from the repository's own README,
`AGENTS.md`, scripts and configuration. Useful for the appendix and for verifying any claim.

## 1. Prerequisites

| Requirement | Needed for |
|---|---|
| Node.js 18+ | `app/`, `backend-v2/`, `website/`, `scripts/` |
| npm | all four JS projects (each has its own lockfile; there is no workspace root) |
| Android Studio (SDK, emulator) | running the app on Android |
| Xcode, macOS only | running the app on iOS |
| .NET 10 SDK | `backend/` and `tests/LiftLog.Tests.Api` (version is **not** pinned — no `global.json`) |
| Docker / Docker Compose | MongoDB + LiteLLM for `backend-v2`; Postgres 17 + LocalStack for the .NET tests |
| `dotnet tool restore` | CSharpier 1.2.6, pinned in `.config/dotnet-tools.json` with `rollForward: false` |
| Expo CLI | only for `expo prebuild`-level tasks; the repo uses `expo run:*` scripts |
| Maestro | end-to-end flows on a device or emulator |

## 2. Mobile app (`app/`)

```bash
cd app
npm install                # postinstall runs patch-package (5 patches)
npm run android            # expo run:android --variant debugOptimized
npm run ios                # macOS only
npm run dev                # expo start --dev-client
npm start                  # expo start
```

| Script | Command |
|---|---|
| `typecheck` | `tsgo --noEmit` (native-preview compiler, not plain `tsc`) |
| `lint` | `oxlint && eslint .` (ESLint runs only the React Compiler rule) |
| `lint:oxlint` / `lint:compiler` / `lint:fix` | individual linters |
| `format` / `format:check` | `oxfmt --write .` / `oxfmt --check .` |
| `test` | `vitest` (watch) |
| `test:coverage` | `vitest run --coverage` |
| `e2e` | `maestro test .maestro --exclude-tags ci-only` |
| `e2e:ci` | `maestro test .maestro` |
| `json-schema` | regenerate `docs/schemas` + the plan validator |
| `apply-patches` | re-apply `patch-package` patches |
| `prebuild` | `expo prebuild` |
| `android:release` / `build:android:release` | release variants |

EAS profiles in `app/eas.json`: `development`, `preview` (both internal apk), `production`
(`autoIncrement: true`), with `cli.appVersionSource: remote`.

Maestro config: `appId: com.limajuice.liftlog`, `continueOnFailure: false`, with an explicit
`flowsOrder` starting at `fresh-install-onboarding`.

## 3. backend-v2 (NestJS + MongoDB)

```bash
cd backend-v2
cp .env.example .env        # then fill in the required values
docker compose up -d        # mongo:8.0 on 27017 + litellm on 4000
npm ci
npm run start:dev           # nest start --watch
npm test                    # jest
npm run test:cov
npm run lint                # oxlint src
npm run typecheck           # tsc --noEmit
npm run build               # nest build
npm run start:prod          # node dist/main
```

Environment variables (66 lines in `.env.example`). **Required by `env.validation.ts`** — startup
fails without them:

| Variable | Rule |
|---|---|
| `MONGODB_URI` | non-empty string |
| `GOOGLE_CLIENT_ID` | non-empty string |
| `JWT_ACCESS_SECRET` | min length 32 |
| `REVENUECAT_WEBHOOK_SECRET` | min length 16 |
| `WEB_CHECKOUT_SECRET` | min length 16 |

Optional but read by code and **absent from `.env.example`**: `STRIPE_SECRET_KEY`,
`STRIPE_WEBHOOK_SECRET`, `STRIPE_PRICE_MONTHLY`, `STRIPE_PRICE_YEARLY`, `ADMIN_EMAILS`,
`CONFIG_ENCRYPTION_KEY` (must be 64 hex chars), `FRONTEND_URL`.

Also read: `PORT` 3000, `JWT_ACCESS_TTL_SECONDS` 900, `JWT_REFRESH_TTL_DAYS` 30, `LITELLM_URL`
`http://litellm:4000`, `LITELLM_MODEL_ALIAS` `coach-primary`, `LITELLM_TIMEOUT_MS` 60000,
`AI_FREE_DAILY_QUOTA` 20, `AI_PREMIUM_DAILY_QUOTA` 200, `AI_STREAM_PREMIUM_ONLY` false,
`MODERATION_ENABLED` false, `AI_MAX_SKILLS` 3, `AI_MAX_SKILL_CHARS` 6000, `MEM0_URL`,
`MEM0_TIMEOUT_MS` 10000, `THROTTLE_LIMIT` 120, `THROTTLE_TTL_SECONDS` 60,
`TOMBSTONE_RETENTION_DAYS` 90, `CORS_ORIGINS`, `GOOGLE_EXTRA_AUDIENCES`.

No seed script and no migration tool exist — collections and indexes are created by Mongoose at boot.
`config/litellm.yaml` maps the alias `coach-primary` to `gpt-4o-mini` using `OPENAI_API_KEY`.

## 4. .NET backend and its tests

```bash
# tests first (they need both databases)
cd tests && docker compose up -d        # Postgres 17 on host port 5401, LocalStack on 4566
cd LiftLog.Tests.Api && dotnet run     # TUnit self-executing host, NOT dotnet test

cd ../../backend/LiftLog.Api
dotnet restore
dotnet build
dotnet run                              # SQLite by default
# or: docker compose up / docker-compose.postgres.yml
```

Optional: `LIFTLOG_LIVE_AI_TESTS=true` enables the live Anthropic tests (they are skipped otherwise).
`Database:Provider` selects `Postgres` (default) or `Sqlite`; `SkipDatabaseMigrations` disables the
startup `MigrateAsync()`.

Rate limiting can be bypassed in tests with `TEST_MODE=True`.

## 5. Website (`website/`)

```bash
cd website
npm install
BACKEND_URL=http://localhost:3000 npm run dev
npm run build && npm run start
npm run lint
```

Route handlers act as a BFF: they forward to `${BACKEND_URL}/api…` and keep tokens in httpOnly
cookies. There is no test script.

## 6. Port map

| Port | Service |
|---|---|
| 3000 | backend-v2 (NestJS) |
| 4000 | LiteLLM (backend-v2 compose) |
| 27017 | MongoDB |
| 5264 | .NET backend (the app's dev default for `apiBaseUrl`) |
| 5401 | Postgres 17 for the .NET tests |
| 4566 | LocalStack S3 for the .NET tests |

Android emulators reach the host through `10.0.2.2`; iOS simulators through `127.0.0.1`.

## 7. Screenshots and branding regeneration

```bash
cd scripts && npm install    # scripts/ is its own package
node collect-screenshots.ts  # drives the app via liftlog://screenshot-collection

cd ../../app
node scripts/generate-branding.mjs        # icons/splash/notification from assets/logo
npm run json-schema                        # regenerate docs/schemas + plan validator
```

## 8. Verification checklist

Run these before claiming anything in the report about the project working:

```bash
cd app            && npm run typecheck && npm run lint && npm test
cd backend-v2     && npm run typecheck && npm run lint && npm test
cd tests/LiftLog.Tests.Api && dotnet run
```

These are exactly the gates recorded in commit bodies and in `docs/merge_ledger.md` for the merge
programme.