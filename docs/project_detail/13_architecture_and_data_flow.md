# 13 — Architecture and Data Flow

The single most useful file for Chapter 3.4 and for a system-diagram figure.

## 1. System shape

```
┌──────────────────────────────────────────────────────────────────────┐
│  Device (iOS / Android)                                             │
│  ┌────────────────────────────────────────────────────────────────┐  │
│  │ Expo / React Native app  (app/)                                │  │
│  │  expo-router routes → presentation → smart → store → services  │  │
│  │  SQLite (Drizzle, 17 tables) · file key-value · SecureStore    │  │
│  │  native modules: workout-worker (Kotlin/Swift), native-lib     │  │
│  └───────────────┬──────────────────────────────┬─────────────────┘  │
└──────────────────┼──────────────────────────────┼────────────────────┘
                   │                              │
   apiBaseUrl      │                              │  alcedoApiBaseUrl
   https://api     │                              │  https://api.alcedo.app/api
   .liftlog.online │                              │
                   ▼                              ▼
┌────────────────────────────┐   ┌────────────────────────────────────┐
│ backend/  ASP.NET Core 10  │   │ backend-v2/  NestJS 11 + MongoDB   │
│ encrypted feed, sharing,   │   │ Google auth + JWT, workout sync,   │
│ inbox, remote backup,      │   │ Stripe/RevenueCat billing, AI      │
│ AI planner hubs            │   │ coach, social graph, admin config │
│ EF Core (Postgres/SQLite)  │   │ repository interfaces             │
└────────────────────────────┘   └────────────────────────────────────┘
              ▲                                  ▲
              │                                  │ cookie-based BFF
              │                     ┌────────────┴─────────────┐
              │                     │ website/  Next.js 16     │
              │                     │ /  /login  /pricing      │
              │                     │ /account  /admin        │
              │                     └──────────────────────────┘
              │
┌────────────────────────────┐        ┌──────────────────────────────┐
│ examples/remote-backup/    │◀──────▶│ app: remote backup settings  │
│ LiftLog.BackupServer + TF  │        │ (/settings/backup-and-restore)│
└────────────────────────────┘        └──────────────────────────────┘

site/  static marketing + privacy (nginx) — no runtime coupling
```

## 2. The two-base-URL rule (`app/src/services/api-consts.ts`)

| Constant | Points at | Used by |
|---|---|---|
| `apiBaseUrl` | .NET backend; dev `10.0.2.2:5264` / `127.0.0.1:5264`, prod `https://api.liftlog.online` | the feed, sharing and AI-planner services; registered as the non-removable built-in backend in `src/store/backends/index.ts` |
| `alcedoApiBaseUrl` | NestJS backend; dev `10.0.2.2:3000/api` / `127.0.0.1:3000/api`, prod `https://api.alcedo.app/api` | `auth-service.ts`, `authenticated-fetch.ts`, `account-screen.tsx` only |

The `/api` prefix is baked into the constant because the NestJS app calls
`app.setGlobalPrefix('api')`; callers append paths such as `/auth/google` and must never add `/api`.

## 3. Feature routing: the multi-backend system

The app does not hardcode one server. `app/src/models/backend.ts` defines:

| Type | Definition |
|---|---|
| `BackendKind` | `'liftlog'` (a full Alcedo server) or `'backupEndpoint'` (a bare URL that can only serve backups) |
| `BackendFeature` | `'feed' \| 'aiPlanner' \| 'backup'` |
| `ReportedBackendFeature` | `BackendFeature \| 'sharing'` — everything `/features` may report |
| `backendFeatures` | `['feed', 'aiPlanner', 'backup']` |
| `BackendAssignments` | `Partial<Record<BackendFeature, BackendId>>` — each feature can point at a different server |
| helpers | `backendSupportsFeature()`, `canBeSetToNoBackend()` (true only for `backup`, because the app deliberately holds nobody's backup), `featuresUrl()` = `${url}/features`, `backupUrl()` = `${url}/backup` |

Flow: `backend-probe.ts` fetches `{url}/features` → keeps entries where `enabled === true` → the UI
in `settings/backends/index.ts` and `backends/[id].tsx` shows which features that server can serve and
lets the user attach it to a feature. This is the concrete meaning of "feature management" in this
project, on both the client and the server.

## 4. Verified request flows

### 4.1 Authentication (the only backend-v2 flow the app uses)

1. `auth-service.ts` lazy-imports `@react-native-google-signin/google-signin`. If the native module
   is missing, the app reports `not-configured` instead of crashing at startup.
2. `POST /api/auth/google` with the Google ID token.
3. `backend-v2` `AuthService` verifies the token (`google-auth-library`: signature, expiry, issuer
   allowlist, `azp` audience), then `TokenService` returns an access JWT (900 s) plus an opaque
   refresh token whose sha256 is stored in Mongo.
4. The app keeps the access token **in memory only** and writes `{ refreshToken, profile }` to
   `expo-secure-store` under `alcedo.auth.session`.
5. On any `401`, `authenticated-fetch.ts` triggers **one single-flight** refresh and replays the
   request once; a second failure raises `AuthError('session-expired')`.
6. `POST /api/auth/logout` revokes the presented refresh token.

### 4.2 Social feed and sharing (.NET backend)

`feed-api.ts` speaks the .NET contract: `/user/create`, `/user/{idOrLookup}`, `PUT /user`,
`DELETE /user`, `POST /users`, `PUT /event`, `POST /events`, `PUT /inbox`, `POST /inbox`,
`PUT /follow-secret`, `POST /follow-secret/delete`, `POST /shareditem`, `GET /shareditem/{id}`.

Each request is authenticated **per request** with a plaintext password that the server verifies with
PBKDF2-SHA512 (350,000 iterations). The payloads themselves are encrypted end-to-end:
`encryption-service.ts` uses WebCrypto AES-CBC 128-bit plus an RSA-256-PSS signature, and
`feed-inbox-decryption-service.ts` decrypts inbox items. The server never holds the keys — its
`IEncryptionService` implementation in `LiftLog.Lib` has zero call sites.

### 4.3 AI planner (SignalR, .NET backend)

`hub-connection-factory.ts` builds the connection; production sends
`Authorization: Bearer RevenueCat <proToken>`, which the .NET `PurchaseTokenAuthenticationHandler`
validates against RevenueCat entitlements. Hub path `/ai-chat-v2`; client methods `Introduce`,
`SendMessage`, `StopInProgress`; the server pushes `ReceiveMessage`. If the AI planner feature is
disabled the server answers **423 Locked** instead of mapping the hub. Premium gating on the client is
RevenueCat (`react-native-purchases`) via `requiresPro()`.

### 4.4 Workout sync (backend-v2 — implemented, not yet called by the app)

Push: the client sends a batch of mutations with `baseVersion`; the server claims an idempotency key,
applies each mutation whose version matches, and returns per-item
`applied | conflict | duplicate | unsupported | error`. A conflict carries `serverVersion` and the
full `serverDoc`, so the client can resolve without a second round trip. Pull returns live documents
plus tombstones after a cursor (`serverUpdatedAt`). Deleted workouts become tombstones and are purged
after `TOMBSTONE_RETENTION_DAYS` (default 90) by an externally triggered job.

### 4.5 Remote backup

`settings/backup-and-restore/` → `remote-backup.tsx` → `choose-server.tsx`: the user supplies a backup
server URL; the app POSTs the backup payload to `{url}/backup` using the `ApiKey` auth scheme
(`X-API-Key`) defined in the .NET backend. The reference server implementation is
`examples/remote-backup/LiftLog.BackupServer`, and the app deliberately never keeps a user's backup
on its own servers (`canBeSetToNoBackend`).

## 5. Offline-first model

| Concern | Design |
|---|---|
| Local write path | Everything is written to SQLite first through Drizzle; nothing requires a network round trip. The upstream README states "Entirely device local workouts, no waiting for sign in or downloads" |
| Key-value state | `key-value-store.ts` over `expo-file-system` with atomic temp-file-then-move writes (Redux serialisability/immutability checks are disabled because persistence is hand-written) |
| Schema evolution | `src/models/storage/versions/` holds `any`, `initial` and `latest` schema sets, a `libs/` helper, a `migrator.ts` and six named migration steps in `versions/migrations/steps/` |
| SQL migrations | 9 Drizzle migrations `0000_purple_betty_ross.sql` … `0008_far_catseye.sql` |
| Data migrations | `src/services/data-migrations/` — import sessions, programs, exercises, feed, backends, dedupe built-in exercises, seed backend assignments, migrate nil weight units |
| Backup modes | Off / Automatic / Manual, introduced by commit `8c98c89` "SQLite hardening + privacy-first backup modes" |
| Design plan | `docs/new_design/offline-first-plan.md` defines the Phase 0–4 rollout with explicit data-safety reasoning |
| Export paths | Plaintext export, file export/sharing, clipboard share, CSV export, health platform export (HealthKit on iOS, Health Connect on Android) |

## 6. Where the report can draw a diagram

`13` above is directly redrawable as **Figure: system architecture**. Two smaller candidates:
the multi-backend feature-routing flow (§3) and the authentication sequence (§4.1).