# 05 — Backend v2 (`backend-v2/`)

NestJS 11 modular monolith on MongoDB. Its own `package.json` describes it as the
"migration target for the .NET backend". This is where authentication, workout sync, payments, the
AI coach, the admin configuration and the feature list for the app live.

## 1. Setup

| Item | Value |
|---|---|
| Package | `@alcedo/backend-v2` 0.1.0, private, CommonJS |
| Framework | NestJS 11 on Express (`@nestjs/platform-express`) |
| Language | TypeScript ~5.9.2, `noImplicitAny` + `strictNullChecks` (not full `strict`) |
| Database | MongoDB 8 via Mongoose 8 (`docker-compose.yml`: `mongo:8.0`, db `alcedo`, volume `mongo-data`) |
| Auth | `@nestjs/jwt` 11, `google-auth-library` 10.3 |
| Billing | `stripe` 22.6.2, plus RevenueCat and HMAC web-checkout webhooks |
| AI | LiteLLM over HTTP, `@microsoft/signalr`-compatible streaming endpoint, Mem0 memory |
| Misc | `@nestjs/throttler` 6.4, `helmet` 8.1, `compression` 1.8.1, `class-validator`, `class-transformer`, `@nestjs/terminus` 11 |
| Source size | 120 files under `src` (100 implementation `.ts`, 19 `*.spec.ts`, 1 `.md`), 39 directories, 10,193 lines of TypeScript |

Scripts: `build` (nest build), `start` / `start:dev` / `start:prod`, `test` (jest), `test:cov`,
`test:watch`, `lint` (oxlint src), `typecheck` (tsc --noEmit). No `dev`, no `migrate`, no `seed`
script — schema comes from Mongoose indexes at boot.

## 2. Bootstrap (`src/main.ts`)

Factory options `{ bufferLogs: true, rawBody: true }` (`rawBody` is required for HMAC webhooks).
Order: `enableShutdownHooks()` → `requestIdMiddleware` (accepts an incoming `X-Request-Id` only if
it is a UUID, else generates one; echoes it on the response) → `helmet()` → `compression()` →
`setGlobalPrefix('api')` → global `ValidationPipe({ forbidNonWhitelisted, transform, whitelist })` →
`AllExceptionsFilter` → `enableCors({ origin: CORS_ORIGINS.split(',') ?? [], credentials: true })` →
`listen(config.get('PORT', 3000))`.

`src/app.module.ts` registers 13 modules plus the global throttler: AppConfig, Throttler, Database,
Common, Health, Features, Auth, Users, Workouts, Social, Payments, SiteConfig, Admin, AI.
`CommonModule` adds the global logging interceptor and the global JWT guard, and registers `JwtModule`.

Error envelope: `{ error: { code, message, details? } }`, code derived from the HTTP status.
Non-HTTP exceptions return a generic message; the stack is logged server-side only.
`LoggingInterceptor` emits JSON per request with `durationMs`, `requestId` and a redacted body —
any key matching `/token|secret|password/i` becomes `[REDACTED]`, buffers become `[binary]`, and the
`authorization` header is redacted.

## 3. Modules, controllers and endpoints

All paths include the `/api` prefix. 11 controllers.

### auth — `src/auth/auth.controller.ts`

| Method | Path | Purpose |
|---|---|---|
| POST | `/api/auth/google` | Exchange a Google ID token for an access/refresh pair (public, 5 req/min) |
| POST | `/api/auth/refresh` | Rotate the refresh token (public, 10 req/min) |
| POST | `/api/auth/logout` | Revoke the presented refresh token; always 200 so it is not a validity oracle |
| GET | `/api/auth/me` | Current identity, premium status/source/expiry, `isAdmin` |

### users — `src/users/users.controller.ts`

| Method | Path | Purpose |
|---|---|---|
| GET | `/api/users/me` | Own profile plus entitlement |
| PATCH | `/api/users/me` | Update `name`, `picture` (https only), `units` |

### workouts — `src/workouts/workouts.controller.ts`

| Method | Path | Purpose |
|---|---|---|
| GET | `/api/workouts` | Cursor list, newest first, `limit` 50 (max 200), optional `includeDeleted` |
| GET | `/api/workouts/:id` | By `clientId`; a non-owner gets 404, not 403 |
| POST | `/api/workouts` | Create at version 0 → 201 |
| PATCH | `/api/workouts/:id` | Partial update, version + 1 |
| DELETE | `/api/workouts/:id` | Soft delete → tombstone |

### sync — `src/workouts/sync.controller.ts`

| Method | Path | Purpose |
|---|---|---|
| POST | `/api/sync/push` | Batch of 1–200 mutations, always 200, per-item `applied`/`conflict`/`duplicate`/`unsupported`/`error` |
| GET | `/api/sync/pull` | Live docs plus tombstones since a cursor, `limit` up to 500 |

### social — `src/social/social.controller.ts`

| Method | Path | Purpose |
|---|---|---|
| POST | `/api/social/follow` | Follow by Google sub; idempotent; self-follow 400 |
| DELETE | `/api/social/follow/:userId` | Idempotent unfollow |
| GET | `/api/social/followers` | Cursor page, 50 (max 200) |
| GET | `/api/social/following` | Cursor page, 50 (max 200) |
| POST | `/api/social/posts` | Create post, 1–2000 chars, ≤ 4 https media URLs |
| GET | `/api/social/feed` | Followees' posts newest first, 20 (max 50), includes `serverTime` |
| DELETE | `/api/social/posts/:id` | Author-only soft delete; others 404 |

### payments — `src/payments/billing.controller.ts` and `webhooks.controller.ts`

| Method | Path | Purpose |
|---|---|---|
| GET | `/api/billing/status` | `{ premium, status, source, expiresAt }` |
| GET | `/api/billing/plans` | **Public** Stripe price catalogue for the pricing page; `[]` when Stripe is off |
| POST | `/api/billing/checkout` | Create a Checkout Session, returns `{ url }`; 409 when already premium; in-flight dedupe; 10/min |
| POST | `/api/billing/portal` | Customer Portal session; `{ url: null }` without a Stripe customer; 10/min |
| POST | `/api/webhooks/revenuecat` | `Authorization: Bearer <secret>` timing-safe compare |
| POST | `/api/webhooks/web-checkout` | `X-Signature` = lowercase hex HMAC-SHA256 of the raw body |
| POST | `/api/webhooks/stripe` | `stripe-signature` verified against the raw body; 503 when unconfigured |

All webhooks: claim-before-process, release the claim and rethrow on transient failure so the
provider retries, acknowledge duplicates with `{ status: 'duplicate' }`. Contracts documented in
`src/payments/WEBHOOK_CONTRACTS.md`.

### ai — `src/ai/conversations.controller.ts`

| Method | Path | Purpose |
|---|---|---|
| POST | `/api/ai/conversations` | Create, optional title ≤ 120 → 201 |
| GET | `/api/ai/conversations` | Cursor list, 20 (max 100) |
| GET | `/api/ai/conversations/:id/messages` | History, 50 (max 100) |
| DELETE | `/api/ai/conversations/:id` | Delete conversation and messages → 204 |
| POST | `/api/ai/conversations/:id/messages` | Coach turn, 30/min |
| POST | `/api/ai/conversations/:id/messages/stream` | SSE `start`/`token`/`done`/`error`, `X-Accel-Buffering: no`, 20/min, aborts upstream on client disconnect |

### admin — `src/admin/admin.controller.ts` (whole controller behind `AdminGuard`)

| Method | Path | Purpose |
|---|---|---|
| GET | `/api/admin/config` | All editable keys, secrets masked |
| PUT | `/api/admin/config` | Set one allowlisted key; audit-logged |
| GET | `/api/admin/users` | Paged user list with premium status |
| PUT | `/api/admin/users/:googleSub/admin` | Grant/revoke admin; 404 missing; 409 `ADMIN_LAST_ADMIN` |

### features and health

| Method | Path | Purpose |
|---|---|---|
| GET | `/api/features` | **Public** capability map |
| GET | `/api/healthz` | Terminus: Mongoose ping + heap check |

## 4. Authentication design

- **Stateless access JWT** (default TTL 900 s from `JWT_ACCESS_TTL_SECONDS`, secret
  `JWT_ACCESS_SECRET`, min length 32) with claims `{ googleSub, sub, type: 'access' }`.
- **Opaque rotating refresh tokens**: `randomBytes(32)` hex, only `sha256(token)` stored, linked by a
  `tokenFamilyId` UUID. Rotation is read-then-atomic-claim; a lost race revokes the freshly minted
  token. Reuse of an already-rotated token within `REUSE_GRACE_MS = 10_000` is rejected but the
  family is preserved; beyond that window the whole family is revoked (`AUTH_REFRESH_REUSED`).
- **Global guard** `JwtAuthGuard` (`src/common/guards/jwt-auth.guard.ts`): everything is protected by
  default; public paths are enumerated inside the guard — `PUBLIC_EXACT_PATHS` =
  `/api/healthz`, `/api/auth/google`, `/api/auth/refresh`, `/api/features`, `/api/billing/plans`, and
  `PUBLIC_PATH_PREFIXES` = `/api/webhooks/`. It re-checks that the user still exists in Mongo after
  verifying the token. Error codes: `AUTH_TOKEN_MISSING`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`.
- **Google verification** (`google-auth-library.verifier.ts`): `verifyIdToken`, issuer allowlist
  `accounts.google.com` + `https://accounts.google.com`, `azp` must match `GOOGLE_CLIENT_ID` or
  `GOOGLE_EXTRA_AUDIENCES`, 10 s timeout. An unverified email is logged as a warning, not rejected.
- **No passwords anywhere** — no hashing library, no local-auth path; identity is Google-only.
- Admin bootstrap: `isAdmin` granted to `ADMIN_EMAILS` on login, only when `emailVerified === true`.

## 5. Feature management — two distinct mechanisms

### A. Client capability advertisement — `src/features/features.controller.ts`

Five hardcoded flags, exported as `FeatureMap`:

| Flag | Value | Reason given in the code |
|---|---|---|
| `feed` | `false` | the end-to-end encrypted feed event protocol is not implemented on this backend |
| `aiPlanner` | `true` | |
| `backup` | `false` | this backend does not accept blobs |
| `sharing` | `false` | |
| `sync` | `true` | a backend-v2 feature the mobile app is gaining |

Stored nowhere; consumed by `app/src/services/backend-probe.ts` on the client, which fetches
`{url}/features` and keeps only entries where `enabled === true`. Covered by
`features.controller.spec.ts` (asserts the exact five keys and boolean values).

**Client-side caveat:** the app's type for this is
`ReportedBackendFeature = BackendFeature | 'sharing'` where
`BackendFeature = 'feed' | 'aiPlanner' | 'backup'` (`app/src/models/backend.ts`). The app's own
`backendFeatures` list is `['feed', 'aiPlanner', 'backup']`, so the `sync` flag has **no consumer in
the app yet**.

### B. Runtime admin-editable configuration — `src/site-config/` + `src/ai/ai-config.service.ts`

The real "feature management": Mongo collection `siteconfigs`, one document per dot-namespaced key.

- `EDITABLE_KEYS` allowlist in `admin.controller.ts`: 16 keys — `ai.systemInstructions`,
  `ai.guardrails`, `ai.model`, `ai.skills.{program-design,progression,form-check,nutrition,recovery,conditioning}`,
  `providers.litellm.baseUrl`, `providers.litellm.apiKey`, `providers.mem0.apiKey`,
  `providers.mem0.baseUrl`, `billing.stripe.priceMonthly`, `billing.stripe.priceYearly`,
  `billing.stripe.webhookSecret`.
- `SECRET_KEYS`: 3 keys stored **encrypted at rest** with AES-256-GCM, 12-byte IV, envelope
  `iv:authTag:ciphertext` in hex (`src/site-config/secret-crypto.ts`); masked on read as
  `sk-…4f2a`. Requires `CONFIG_ENCRYPTION_KEY` to be exactly 64 hex characters.
- Validators: `IsGuardrailsJsonConstraint` for `ai.guardrails`, `IsBaseUrlWhenKeyConstraint` so any
  `*baseUrl` key must be http/https.
- Consumers, each behind a 60 s cache: LiteLLM base URL / api key / model alias, Mem0 key and URL,
  system instructions, per-skill instruction overrides, extra guardrail terms (≤ 200 terms,
  ≤ 64 chars each), Stripe price ids.

## 6. Workouts and sync

- `Workout` document: `clientId` (client-generated UUID, the stable identity, unique per user),
  `userId`, `name` ≤ 120, `date`, `exercises[]` (each with `exerciseId`, `sets[]` of
  `reps/weight/unit/rpe`, `notes`), `version` (monotonic, used for compare-and-set), `deletedAt`
  tombstone, `serverUpdatedAt` pull cursor. Indexes `{userId, serverUpdatedAt}`,
  unique `{userId, clientId}`, `{userId, deletedAt}`.
- `SyncService.push` claims an idempotency record per key, applies mutations whose
  `baseVersion` matches, and returns `serverVersion` + the full `serverDoc` for conflicts, without
  failing the whole batch. Non-finite set numbers are rejected.
- `SyncService.pull` returns live documents plus tombstones after a cursor; `purgeTombstones()` reads
  `TOMBSTONE_RETENTION_DAYS` (default 90) from `process.env` directly and **has no scheduler** — it
  must be triggered externally. TTL indexes reap refresh tokens, idempotency records (30 days) and
  daily AI usage (3 days); webhook events deliberately never expire.

## 7. Social

`Follow` (`followerId`, `followeeId`, unique pair), `Post` (`authorId`, `text` ≤ 2000,
`mediaUrls[]`, `deletedAt`, index `{authorId, createdAt:-1}`). Cursor pagination is
`encodeCursor(isoTimestamp, tiebreakerId)` / `decodeCursor` — base64url JSON `{t, id}` — and
`hasMore` is exact via a limit+1 probe. Repository interfaces (`UserRepository`,
`WorkoutRepository`, `SyncIdempotencyStore`, `PostRepository`, `FollowRepository`,
`ConversationRepository`, `MessageRepository`, `AiUsageRepository`) are abstract classes used as DI
tokens, with Mongoose implementations — this is the unit-test seam.

## 8. AI module

| Piece | Detail |
|---|---|
| Client | `litellm.client.ts` — 3 retries with exponential backoff (base 500 ms) on 429/5xx only, `max_tokens` 1024, `temperature` 0.7, moderation call to `/v1/moderations` |
| Quota | `quota.service.ts` — atomic `findOneAndUpdate` + `$inc` on `ai_daily_usage` keyed by UTC `YYYY-MM-DD`; 429 `AI_QUOTA_EXCEEDED` with `{ limit, resetsAt }`; free 20/day, premium 200/day |
| Guardrails | `guardrails/keyword-topic-guard.service.ts` — 7 in-scope groups (lifts, muscles, training, cardio, nutrition, recovery, programming) and 8 off-topic groups (politics, finance, coding, legal, relationships, academic, travel, entertainment), 16 self-harm terms checked first; admin-supplied extra in-scope terms from `ai.guardrails` |
| Output check | `guardrails/output-check.service.ts` — prompt-leakage detection with tail replacement, email/phone PII redaction, PED/steroid and self-harm detection |
| Skills | `skills/` — six skills with priority and match groups: `form-check` 85, `program-design` 80, `progression` 75, `nutrition` 70, `recovery` 70, `conditioning` 70. Budget `AI_MAX_SKILLS` (3) and `AI_MAX_SKILL_CHARS` (6000), lowest priority cut first |
| Memory | `memory/memory.service.ts` (Mem0), `memory-extraction.service.ts` |
| Conversations | `conversations.service.ts` — 9-step pipeline, `HISTORY_WINDOW = 20` |

## 9. Configuration and infrastructure

`config/litellm.yaml` maps alias `coach-primary` → `gpt-4o-mini` with the key from
`OPENAI_API_KEY`. `docker-compose.yml` runs `mongo:8.0` (healthchecked) and `litellm`
(`ghcr.io/berriai/litellm:main-stable`, port 4000). `.env.example` has 66 lines covering port,
Mongo URI, Google client id, JWT secrets and TTLs, webhook secrets, LiteLLM, AI quotas, moderation,
throttling, tombstone retention and CORS. `env.validation.ts` validates with class-validator and
throws `Environment validation failed: …`.

**Not in `.env.example` although read by code:** `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`,
`STRIPE_PRICE_MONTHLY`, `STRIPE_PRICE_YEARLY`, `ADMIN_EMAILS`, `CONFIG_ENCRYPTION_KEY`,
`FRONTEND_URL`.

## 10. Tests

- **Jest 30 + ts-jest**, config inline in `package.json` (`rootDir: src`, `testRegex: .*\.spec\.ts$`,
  node environment).
- **19 spec files, 194 `it(` blocks** (three use `it.each`, so the runtime count is higher;
  `docs/merge_ledger.md` records a run of 213 tests in 19 suites).
- Style is hand-rolled in-memory model doubles and `makeService(seed)` factories rather than
  `mongodb-memory-server`. No `.e2e-spec.ts`.
- Coverage highlights: `webhooks.controller.spec.ts` 23, `payments.service.spec.ts` 23,
  `workouts.service.spec.ts` 16, `sync.service.spec.ts` 12, `social.service.spec.ts` 15,
  `output-check.service.spec.ts` 11, `skill-registry.service.spec.ts` 11,
  `token.service.spec.ts` 9, `entitlement.service.spec.ts` 9, `auth.service.spec.ts` 4.
- **Not covered:** `main.ts` bootstrap, the Mongo connection backoff, `env.validation.ts`, the
  request-id middleware, the exception filter, the logging interceptor, cursor pagination, the JWT
  guard, `health.controller.ts`, `conversations.service.ts`, `litellm.client.ts`, the moderation and
  memory services, and every Mongoose repository implementation (interfaces are mocked instead).

## 11. How much of this the mobile app actually uses — read this before writing Chapter 3

Verified by searching every `.ts`/`.tsx` file under `app/src` for `alcedoApiBaseUrl` and for the
route paths:

| backend-v2 surface | Called from app code? | Evidence |
|---|---|---|
| `/api/auth/google`, `/auth/refresh`, `/auth/logout`, `/auth/me` | **Yes** | `app/src/services/auth-service.ts` |
| Generic authenticated GET/POST with bearer token and 401 refresh | **Yes** | `app/src/services/authenticated-fetch.ts` |
| Account screen data | **Yes** | `app/src/components/presentation/settings/account/account-screen.tsx` |
| `/api/features` | **Yes** | `app/src/services/backend-probe.ts` (any backend URL, not only v2) |
| `/api/sync/push`, `/api/sync/pull` | **No** — referenced only in `authenticated-fetch.spec.ts` | no `/sync` string anywhere in non-spec app source |
| `/api/workouts*`, `/api/users/me`, `/api/social/*`, `/api/billing/*`, `/api/ai/conversations*` | **No** | no matching path strings in `app/src` outside that one spec |
| `/api/admin/*` | No — but `website/` calls it | `website/src/app/api/admin/*` |

`alcedoApiBaseUrl` appears in exactly six files: `api-consts.ts`, `auth-service.ts`,
`auth-service.spec.ts`, `authenticated-fetch.ts`, `authenticated-fetch.spec.ts`,
`account-screen.tsx`.

Also note the comment in `app/src/services/api-consts.ts`: the production value
`https://api.alcedo.app/api` "**must be set to the deployed backend-v2 URL before release builds**" —
so backend-v2 is not recorded as deployed at `0ee0ebd`.

Consequence for the report: the honest claim is that the mobile app is integrated with `backend-v2`
for **authentication and the account screen**, with a reusable authenticated-fetch wrapper ready for
the rest. Sync, billing, social and AI-coach endpoints are implemented and tested server-side but not
yet consumed by the app. The app's AI planner chat talks to the **.NET** hub `/ai-chat-v2`, not to this
module. See `12_open_questions_and_discrepancies.md` items 4 and 9.

## 12. README drift (recorded for accuracy)

`backend-v2/README.md` is behind the code: it says "no Stripe by design" although there is a
complete, tested Stripe integration; it lists 12 test suites when there are 19; its endpoint table
omits all four `/api/admin/*` routes and the three Stripe billing routes; and it claims idempotency
records never expire while the schema applies a 30-day TTL. Quote the code, not this README.

Also: `dist/` is present but empty (never built in place); `newSecret()` in `src/common/utils/ids.ts`
is unused; `revokeAllForUser()` has no in-tree caller.