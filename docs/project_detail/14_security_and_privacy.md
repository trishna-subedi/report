# 14 — Security and Privacy

Inventory of what the project actually does, with file paths. Usable for Chapter 3.4 (technical
detail) and Chapter 4.2 (learning outcomes).

## 1. Authentication

| Layer | Mechanism | Where |
|---|---|---|
| Mobile account auth | Google Sign-In ID token → short-lived JWT + opaque rotating refresh token | `app/src/services/auth-service.ts`, `backend-v2/src/auth/` |
| Refresh token storage | **sha256 hash only** server-side; `{refreshToken, profile}` in `expo-secure-store` key `alcedo.auth.session` | `backend-v2/src/auth/schemas/refresh-token.schema.ts` |
| Refresh rotation | Read-then-atomic-claim; a lost race revokes the newly minted token; tokens linked by `tokenFamilyId` | `backend-v2/src/auth/token.service.ts` |
| Reuse detection | Replaying a rotated token within a 10 s grace window is rejected but the family survives; after the window the **whole family is revoked** (`AUTH_REFRESH_REUSED`) | same file, `REUSE_GRACE_MS = 10_000` |
| 401 handling in the app | One single-flight refresh, then one retry; no refresh loop | `app/src/services/authenticated-fetch.ts` |
| Legacy feed auth | Per-request plaintext password verified with **PBKDF2-SHA512, 350,000 iterations, 64-byte salt**, compared with `CryptographicOperations.FixedTimeEquals` | `backend/LiftLog.Api/Service/PasswordService.cs` |
| .NET API schemes | Purchase token (RevenueCat entitlement), `X-API-Key`, forward-auth from a reverse proxy with a **CIDR trust list** parsed at startup | `backend/LiftLog.Api/Authentication/` |
| Passwords | **None.** `backend-v2` has no password field, no hashing library and no local-auth path — identity is Google-only by design | `backend-v2/src/auth/` |

## 2. Authorisation

| Control | Detail |
|---|---|
| Deny by default | `JwtAuthGuard` is registered globally as an `APP_GUARD`; public routes are an explicit allowlist (`PUBLIC_EXACT_PATHS`, `PUBLIC_PATH_PREFIXES`) |
| Route allowlist | `/api/healthz`, `/api/auth/google`, `/api/auth/refresh`, `/api/features`, `/api/billing/plans`; prefix `/api/webhooks/` |
| Admin | `AdminGuard` on the whole `/api/admin` controller; last-admin removal is refused with `ADMIN_LAST_ADMIN`; admin bootstrap from `ADMIN_EMAILS` only when the Google email is verified |
| Ownership | Non-owner access returns **404, not 403** — `GET /api/workouts/:id`, `DELETE /api/social/posts/:id`, `PUT /api/admin/users/:googleSub/admin` |
| Feature gating (.NET) | `FeatureCheckAttribute` is an `IResourceFilter` so a disabled feature yields **423 Locked** rather than a model-binding error; hubs also 423 |
| Feature gating (NestJS) | `GET /api/features` advertises capability; the app probes it and only shows what a server supports |

## 3. Encryption

| Data | Algorithm | Where |
|---|---|---|
| Social feed and inbox content, end-to-end | **AES-CBC 128-bit** payload + **RSA-256-PSS** signature, via `react-native-quick-crypto` WebCrypto `subtle` | `app/src/services/encryption-service.ts`, `app/src/models/encryption-models.ts` |
| Encryption test vectors | checked-in AES and RSA fixtures | `app/src/services/test-assets/{aes,rsa}/` |
| Server-side secrets | **AES-256-GCM**, 12-byte IV, envelope `iv:authTag:ciphertext` in hex; key must be 64 hex chars | `backend-v2/src/site-config/secret-crypto.ts` |
| Secret masking on read | `sk-…4f2a` style, or `••••••••` when too short or undecryptable | same file |
| .NET encryption library | `OsEncryptionService` (AES-CBC + RSA-PSS-256) exists in `LiftLog.Lib` but has **zero call sites** — the server never decrypts user content | `backend/LiftLog.Lib/Services/` |

## 4. Secret and key management

| Item | Handling |
|---|---|
| Mobile auth session | `expo-secure-store` (Keychain / Keystore), never `AsyncStorage` |
| Server config secrets | 3 keys encrypted at rest: `providers.litellm.apiKey`, `providers.mem0.apiKey`, `billing.stripe.webhookSecret` |
| JWT secret | `JWT_ACCESS_SECRET`, validated `minLength(32)` |
| Webhook secrets | RevenueCat bearer secret compared timing-safe; web checkout HMAC-SHA256 over the raw body; Stripe signature verified against the raw body |
| Raw body requirement | `NestFactory.create(..., { rawBody: true })` — HMAC verification needs the unparsed body |
| Logging redaction | `LoggingInterceptor` replaces any body key matching `/token|secret|password/i` with `[REDACTED]`, buffers with `[binary]`, and redacts the `authorization` header |
| Client config placeholders | `auth-config.ts` still contains `YOUR_WEB_CLIENT_ID…` placeholders and `isGoogleAuthConfigured()`; Google auth is **not configured in the repository** |
| Config files | `.env.example` only; real secrets are untracked (`appsettings.Development.json`, `SubscriptionKey_*.p8`, `my.secrets`, `purchaseToken.txt` are all gitignored) |
| Website session | httpOnly, SameSite=Lax cookies `alcedo_access` / `alcedo_refresh`; Secure in production; the browser never sees a backend token |

## 5. Transport and platform hardening

| Control | Detail |
|---|---|
| Helmet | enabled globally in `backend-v2/src/main.ts` |
| Compression | enabled globally |
| CORS | driven by `CORS_ORIGINS` (comma-separated). **Unset in `.env.example`, and the fallback is an empty allowlist** |
| Rate limiting | `@nestjs/throttler` global guard, `THROTTLE_LIMIT=120` / `THROTTLE_TTL_SECONDS=60`, plus per-route tighter limits: sign-in 5/min, refresh 10/min, checkout and portal 10/min, chat 30/min, chat stream 20/min; webhooks skip throttling |
| Request validation | global `ValidationPipe` with `whitelist` and **`forbidNonWhitelisted`**, so unknown fields are rejected, not ignored |
| Error handling | one `AllExceptionsFilter`; non-HTTP exceptions return a generic message and the stack is logged server-side only |
| Request correlation | `requestIdMiddleware` accepts an inbound `X-Request-Id` only if it is a UUID, otherwise generates one, and echoes it |
| Input limits | workout name ≤ 120 chars, post text 1–2000 chars with ≤ 4 https media URLs, conversation title ≤ 120, batch sizes capped (push 200, pull 500, feed 50, followers 200), non-finite set numbers rejected |
| URL scheme validation | admin `*baseUrl` config keys must be http/https; user profile `picture` must be https |
| Idempotency | webhook events claimed by unique `eventId` before processing; sync pushes claimed by `idempotencyKey` |
| Concurrency control | monotonic `version` with compare-and-set on workout updates |
| .NET SQL | `FromSqlRaw` used only with a strongly typed keyless filter entity mapped to a stub table |
| SQLite | `busy_timeout=5000`, `journal_mode=WAL` on every connection open (`.NET` side) |
| SQL injection surface | parameterised EF Core / Drizzle only; no string-built SQL found |

## 6. Privacy design decisions

| Decision | Evidence |
|---|---|
| Local-first by default | workouts live on the device; nothing requires sign-in |
| End-to-end encrypted social feed | opt-in; the server stores and relays ciphertext |
| The app never stores a user's backup | `canBeSetToNoBackend(feature)` returns true only for `backup`; `models/backend.ts` comments "We do not hold anyone's backup" |
| Backup modes Off / Automatic / Manual | commit `8c98c89`, `docs/new_design/offline-first-plan.md` |
| Account deletion | `DELETE /api/user/{id}` on the .NET side; `TOMBSTONE_RETENTION_DAYS` reaps sync tombstones |
| Feed privacy controls | feed settings, follow requests, blocked users, share-request branch (profile editor, page 12) |
| Plaintext export is explicit | `plain-text-export.tsx` + `plaintext-export-preview.ts`, with a reference image `docs/img/includedexcludedplaintext.png` |
| Self-hosting | `BackendKind: 'backupEndpoint'` and the remote-backup flow let a member keep data on infrastructure they control |

## 7. Known weaknesses worth stating honestly

- `backend/` CORS is fully open (`WithOrigins("*").AllowAnyHeader().AllowAnyMethod()`).
- `backend-v2` `CORS_ORIGINS` is unset by default, so an unset environment produces an empty
  allowlist; `main.ts` reads `process.env` directly instead of the validated `ConfigService`.
- Seven environment variables read by code are missing from `.env.example`
  (`STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`, `STRIPE_PRICE_MONTHLY`, `STRIPE_PRICE_YEARLY`,
  `ADMIN_EMAILS`, `CONFIG_ENCRYPTION_KEY`, `FRONTEND_URL`).
- Google sign-in is not configured in the repository, so authentication cannot run as committed.
- `backend-v2`'s production URL is documented in code as still needing to be set before release.
- `purgeTombstones()` has no scheduler; retention depends on an external trigger.
- `IEncryptionService` and `RateLimitService` in the .NET backend are dead code.