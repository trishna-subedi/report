# 04 — .NET Backend (`backend/`, `tests/LiftLog.Tests.Api`)

The original server. Serves the encrypted social feed, sharing, remote backup ingestion and the
Claude AI planner hub. It is **not** dead code: `app/src/services/feed-api.ts` calls its 13 endpoints
and production points at `https://api.liftlog.online`.

## 1. Solution and projects

`LiftLog.sln` — 4 projects, all `net10.0`:

| Project | Type | References | Key packages |
|---|---|---|---|
| `backend/LiftLog.Lib` | class library | — | none (pure BCL) |
| `backend/LiftLog.Api` | ASP.NET Core Web API | LiftLog.Lib, RevenueCat | EF Core 10.0.5, Npgsql 10.0.1, SQLitePCLRaw 2.1.13 (pinned for a security advisory), Anthropic 12.9.0, Microsoft.Extensions.AI 10.4.1, AWSSDK.S3 4.0.102.4, FluentValidation 12.1.1, AutomaticInterface 5.2.6, cuid.net 7.0.0, EFCore.NamingConventions 10.0.1 |
| `backend/RevenueCat` | generated client | — | Microsoft.Kiota.Bundle 1.22.1 |
| `tests/LiftLog.Tests.Api` | test host | LiftLog.Api | TUnit 1.21.20, NSubstitute 5.3.0, Microsoft.AspNetCore.Mvc.Testing 10.0.5, SignalR.Client 10.0.5, Microsoft.NET.Test.Sdk 18.3.0 |

All four set `Nullable=enable`, `ImplicitUsings=enable`; the API and Lib set `TreatWarningsAsErrors=true`.
The API also sets `InvariantGlobalization=true` and `NoWarn=CS8524`.
No `global.json`, no `Directory.Build.props` — the SDK version is not pinned; Dockerfiles and CI use
`.NET 10.0` / `10.0.x`. `.config/dotnet-tools.json` pins **CSharpier 1.2.6** (`rollForward: false`).

## 2. Startup pipeline (`backend/LiftLog.Api/Program.cs`)

Registration order: FluentValidation validators → EF Core contexts → CORS (`WithOrigins("*")`,
any header/method) → `IFeatureGate` singleton → SignalR (`MaximumParallelInvocationsPerClient=2`,
client timeout 120 s, handshake 60 s) → authentication (three custom schemes, **no JWT**) →
authorization → `PasswordService`, `RateLimitService` → hosted services
(`CleanupExpiredDataHostedService`, `ConfigurationLogger`) → backup sink (file or S3) →
two Anthropic planner registrations (v1 via `Microsoft.Extensions.AI`, v2 via the Anthropic SDK with
tool use) → controllers with JSON options (trailing commas, case-insensitive, enum and TimeSpan
converters).

Request order: `UseCors` → `UseHttpsRedirection` (non-Development) → `UseAuthentication` →
`UseAuthorization` → `MapControllers` → hubs → `/health`. On startup both EF contexts run
`MigrateAsync()` unless `SkipDatabaseMigrations` is set. **Swagger/OpenAPI is not present.**

## 3. Endpoints — 15 controller actions

| Controller | Route base | Feature gate | Actions |
|---|---|---|---|
| `UserController` | `User` | Feed or Sharing | POST create, GET `{idOrLookup}`, POST delete, PUT update |
| `UsersController` | `Users` | Feed or Sharing | POST batch fetch |
| `EventController` | `Event` | Feed | PUT |
| `EventsController` | `Events` | Feed | POST |
| `InboxController` | `Inbox` | Feed | PUT, POST (read-and-delete) |
| `FollowSecretController` | `follow-secret`, `follow-secret/delete` | Feed | PUT, POST |
| `SharedItemController` | `SharedItem` | Sharing | POST, GET `{id}` |
| `BackupController` | `Backup` | Backup | POST (`[Authorize(AuthSchemes.Backup)]`) |
| `FeaturesController` | `Features` | none (deliberately open) | GET |

Plus `GET|HEAD /health` and two SignalR hubs:

| Hub | Methods |
|---|---|
| `/ai-chat` | `SendMessage`, `Introduce`, `RestartChat`, `StopInProgress` |
| `/ai-chat-v2` | same four, plus `clientAiPlanVersion` and `preferredWeightUnit` parameters |

Both hubs return **423 Locked** when the AI planner feature is disabled.

## 4. Feature gating

`Features/Feature.cs` — enum `Feed, Backup, Sharing, AiPlanner`, all opt-out
(`Enabled ?? true`). `Features/FeatureCheckAttribute.cs` is an `IResourceFilter` (deliberately a
resource filter, so a disabled feature yields 423 rather than a binding error). `FeatureGate`
resolves configuration. The app reads the same information from `GET /Features` and from the
NestJS `GET /api/features`.

## 5. Authentication — three hand-rolled schemes, no JWT

| Scheme | Mechanism |
|---|---|
| `PurchaseTokenAuthenticationSchemeOptions` (default) | `Authorization: Bearer <AppStore> <proToken>`; verifies the RevenueCat entitlement through `RevenueCatPurchaseVerificationService` (`Customers[userId].GetAsync()` → `ActiveEntitlements.Items`), then emits `NameIdentifier`, `AppStore`, `ProToken` claims |
| `ApiKeyAuthenticationHandler` | `X-API-Key` header compared to `Auth:ApiKey:Value`; unset → `NoResult()` (inert); issues `NameIdentifier = "default"` |
| `ForwardAuthAuthenticationHandler` | trusts an identity header set by a reverse proxy (Authelia/Authentik/oauth2-proxy/Caddy/Traefik); restricted by `Auth:ForwardAuth:TrustedProxies` CIDR list with IPv4-mapped IPv6 normalisation, parsed at startup so a bad range fails fast |

Accepted combinations (`AuthSchemes.cs`): `Backup = ApiKey,ForwardAuth`;
`AiPlanner = PurchaseToken,ApiKey,ForwardAuth`.

Only `BackupController` and the AI hubs are decorated with `[Authorize]`. The feed, sharing and
inbox endpoints authenticate **per request** with a plaintext `Password` in the body, verified
against a stored `HashedPassword` and `Salt` using **PBKDF2-SHA512, 350,000 iterations, 64-byte salt**
and `CryptographicOperations.FixedTimeEquals` (`PasswordService`). There is no login or
token-issuing endpoint.

## 6. Database

EF Core 10 with a **switchable provider** selected by `Database:Provider`
(`DatabaseConfiguration.cs`, default `Postgres`):

| Abstract context | Postgres impl | SQLite impl | Entities |
|---|---|---|---|
| `UserDataContext` | `PostgresUserDataContext` | `SqliteUserDataContext` | `User`, `UserEvent`, `UserFollowSecret`, `UserInboxItem`, `SharedItem`, keyless `UserEventFilter` mapped to `tmp_stub_table` (used to feed a client-supplied `(user_id, since)` filter into `FromSqlRaw`) |
| `RateLimitContext` | `PostgresRateLimitContext` | `SqliteRateLimitContext` | `RateLimitConsumption` |

Both use snake_case naming (`EFCore.NamingConventions`) and one shared connection string
`Database:ConnectionString`. Design-time factories use fake connection strings.
SQLite adds `SqliteModelExtensions.StoreDateTimeOffsetsAsUtcTicks()` and a `SqlitePragmaInterceptor`
setting `busy_timeout=5000` and `journal_mode=WAL` on every open.

Migrations (19 + 4 model snapshots):

| Target | Count | Range |
|---|---|---|
| Postgres UserData | 15 | `20231230020929_InitialCreate` → `20260608092703_IncreaseMaxSize` |
| Postgres RateLimit | 2 | initial + `SnakeCase` |
| SQLite UserData | 1 | `20260825234608_InitialCreate` |
| SQLite RateLimit | 1 | `20260825234608`/`20260825234626` initial |

The SQLite path (2026-08) is the newest code in the repository — roughly two months before this
review date of October 2026.

## 7. `backend/LiftLog.Lib`

Provider-agnostic shared contract and crypto layer, no dependencies: wire DTOs (`UserRequests.cs`,
`ShareRequests.cs`), blueprint models, AI plan models, `IEncryptionService` + `OsEncryptionService`
(AES-CBC + RSA-PSS-256 signature over BCL primitives), canonical JSON settings and converters,
LINQ helpers.

**Dead code:** `IEncryptionService`/`OsEncryptionService` have zero consumers — the API never decrypts,
because feed payloads arrive already encrypted from the client. Same for `RateLimitService.GetRateLimitAsync`.

## 8. `backend/RevenueCat`

Fully Kiota-generated client (870 `.cs` files, `revenuecat.yaml` 310 KB, kiota 1.28.0, namespace
`RevenueCat.Client`). Only `Customers[userId].GetAsync()` and `ActiveEntitlements` are used, to
validate premium entitlement for the purchase-token auth scheme. Registered as a singleton in
`RegistrationHelpers.cs`. Marked `linguist-generated` in `.gitattributes` and excluded from VS search.

## 9. Deployment

`backend/Dockerfile` (SDK 10.0 build → ASP.NET 10.0 runtime, non-root), `backend/docker-compose.yml`
(SQLite default) and `backend/docker-compose.postgres.yml`, `appsettings.json`, `launchSettings.json`,
`backend/README.md`. Untracked workflow `api-publish.yml` publishes
`ghcr.io/liammorrow/liftlog:api` for `linux/amd64` and `linux/arm64`.

## 10. Tests (`tests/LiftLog.Tests.Api`)

**Framework: TUnit 1.21.20** — `[Test]`, `[Arguments]`, `[ClassDataSource<T>]`, `[Before(Assembly)]`,
`Assert.That`. Executed as a self-running host: `dotnet run` (not `dotnet test`).

- 30 `.cs` files: 15 in `Integration/` (including `TestFactoryHelper.cs` and `DbMigrate.cs`),
  6 in `Integration/Helpers/`, 1 `Integration/Providers/ApiFactory.cs`, 5 in `Unit/`,
  2 in `Unit/Helpers/`, plus `GlobalUsings.cs`.
- **18 files contain `[Test]`**, defining **22 test classes** plus 4 support classes
  (`BackupTestFactory`, `LocalStackS3`, `NamelessApiKeyAuthenticationHandler`,
  `PeerAddressStartupFilter`); **115 `[Test]` methods** and 111 `[Arguments]` rows, so the executed
  case count is higher than 115.
- Layout: `Integration/` (15 files) covers every controller — UserController via `UsersControllerTests`,
  `EventControllerTests` and `SharedItemIntegrationTests`, plus `EventsController`,
  `InboxController`, `FollowSecretController`, `FeaturesController`, and **four** classes for
  `BackupController` (`BackupControllerAuthTests`, `BackupControllerUnconfiguredApiKeyTests`,
  `BackupControllerNoSinkTests`, `BackupControllerS3Tests` / `BackupControllerNamelessPrincipalTests`),
  `AuthenticationIntegrationTests` (9 SignalR connect/deny cases across all 3 auth schemes),
  `ForwardAuthTests` (CIDR trust matrix incl. IPv4-mapped IPv6 and malformed networks),
  `S3BackupSinkIntegrationTests`, `AiWorkoutPlannerIntegrationTests`,
  `AiWorkoutPlannerV2IntegrationTests`. `Unit/` (5 files): `AiPlanToolProviderTests`,
  `AnthropicChatPlannerV2Tests`, `BackupSinkRegistrationTests`, `FileStorageBackupSinkTests`,
  `S3BackupSinkTests`. Helpers: `FeedHelper`, `UserHelper`, `MockAiChatDirectory`,
  `NonSeekableStream`, `RecordingBackupSink`, `FakeAnthropicMessageStreamer`, `StreamEvents`.
- **Dual-provider design:** `Providers/ApiFactory.cs` with `PostgresApiFactory` and
  `SqliteApiFactory`; a test class declares one `[ClassDataSource]` per provider, so every
  controller test runs twice. Postgres migrations run once per assembly (`[Before(Assembly)]` in
  `DbMigrate.cs`); SQLite uses a throwaway `%TEMP%/liftlog-test-<guid>.db` with `-wal`/`-shm` cleanup.
- `TestFactoryHelper` uses `WebApplicationFactory<Program>` in environment `"Test"` deliberately, so
  a developer's `appsettings.Development.json` cannot change the database under the tests, and sets
  `TEST_MODE=True` to bypass rate limiting.
- Live Anthropic tests are opt-in through `RequiresAnthropicApiKeyAttribute` and only run when
  `LIFTLOG_LIVE_AI_TESTS=true`.
- Local run: `cd tests && docker compose up -d` (Postgres 17 on 5401, LocalStack on 4566), then
  `cd tests/LiftLog.Tests.Api && dotnet run`.

## 11. Status summary for the report

| Aspect | Status |
|---|---|
| Encrypted feed, sharing, inbox | Live, served by this backend, production URL in the app |
| Remote backup ingestion | Live (`BackupController`, file or S3 sink) |
| AI planner hubs | Live; the app connects to `/ai-chat-v2` with `Bearer RevenueCat <proToken>` |
| Auth for accounts | Superseded: `backend-v2` provides Google sign-in + JWT |
| Billing | Superseded: `backend-v2` provides Stripe/RevenueCat webhooks |
| Source history | Only ever touched by the initial import commit `2eeca0d` — never modified since |