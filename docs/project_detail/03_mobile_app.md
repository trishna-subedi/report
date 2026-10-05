# 03 â€” Mobile Application (`app/`)

## 1. Stack and versions (`app/package.json`, `app.json`)

| Item | Value |
|---|---|
| package name | `alcedo-react` 1.0.0, private, `main: expo-router/entry` |
| Expo | `~57.0.26` |
| expo-router | `~57.0.24`, `typedRoutes: true`, React Compiler enabled |
| React / React DOM | `19.2.3` |
| React Native | `0.86.3` |
| TypeScript | `~6.0.3`, typecheck via `@typescript/native-preview` (`tsgo --noEmit`) |
| Router entry | expo-router file-based routing under `app/src/app` |
| Native runtime | Hermes (styled shim needed because of `styled-components`) |

`tsconfig.json`: `strict: true`, `strictNullChecks: true`, `noUncheckedIndexedAccess: true`,
`exactOptionalPropertyTypes: false`, aliases `@/*` â†’ `src/*` and `~/modules/*` â†’ `modules/*`.

## 2. Scripts

| Script | Command |
|---|---|
| `start` / `dev` | `expo start` / `expo start --dev-client` |
| `android` / `ios` | `expo run:android --variant debugOptimized` / `expo run:ios` |
| `test` / `test:coverage` | `vitest` / `vitest run --coverage` |
| `e2e` / `e2e:ci` | `maestro test .maestro --exclude-tags ci-only` / without the tag filter |
| `typecheck` | `tsgo --noEmit` |
| `lint` | `oxlint && eslint .` |
| `format` / `format:check` | `oxfmt --write .` / `oxfmt --check .` |
| `json-schema` | generates JSON schemas + plan validator from `modules/workout-worker/schema` |
| `apply-patches` / `postinstall` | `patch-package` |

## 3. Routing â€” the screens of the application

Route files live in **`app/src/app`** (the `app/app` folder is an empty leftover).
49 `.tsx` route files + 1 `.ts` (`+native-intent.ts`).

### Root stack â€” `app/src/app/_layout.tsx`

Providers in order: `GestureHandlerRootView` â†’ `KeyboardProvider` â†’ `SafeAreaProvider` â†’
`ServicesProvider` â†’ `AppThemeProvider` â†’ `AppStateProvider` â†’ `SnackbarProvider`, then a
`StackWithHeader` root stack with screens `(tabs)`, `exercise-search` (modal), `exercise-editor`,
`exercise-history`, `workout-editor`, `diff-save`.

### Tab navigator â€” `app/src/app/(tabs)/_layout.tsx`

Five tabs, custom bar `AppTabBar` (hides Feed when `settings.showFeed` is false):

| Order | Route directory | Label | Screen |
|---|---|---|---|
| 1 | `(session)` | Workout | `index.tsx` = workout hub; `session/index.tsx` = live session; `session/post-workout.tsx`; `screenshot-collection.tsx` |
| 2 | `feed` | Feed | `index.tsx`, `profile-editor.tsx`, `share.tsx`, `item/[id].tsx`, `shared-item/[id].tsx` |
| 3 | `stats` | Stats | `index.tsx` trends, `exercise-list.tsx`, `expanded-weighted-exercise.tsx` |
| 4 | `history` | History | `index.tsx` calendar + week list, `edit.tsx`, `post-workout.tsx` |
| 5 | `settings` | Settings | 21 routes including `account`, `app-configuration`, `localization`, `notifications`, `whats-new`, `program-list`, `manage-exercises`, `import-plan(+-info)`, `ai/planner`, `ai/planner-chat`, `backends/index` + `backends/[id]`, `backup-and-restore/*` (5), `manage-workouts/[programId]/â€¦` (3) |

Dynamic parameters in use: `[id]` (feed, 2 files), `[programId]`, `[sessionIndex]`.
This 24-screen set is the same 24 pages tracked in `docs/new_design/page-verification.md`.

## 4. Source structure (`app/src`)

686 `.ts` + 518 `.tsx` = 1,204 files. Verified counts per directory:

| Directory | Files | Contents |
|---|---|---|
| `src/app` | 50 | expo-router routes: 49 `.tsx` + 1 `.ts` (`+native-intent.ts`) |
| `src/components` | 844 | `presentation` 774, `smart` 67, `layout` 3 |
| `src/store` | 88 | Redux Toolkit slices and effect modules |
| `src/models` | 85 | sessions, blueprints, feed, encryption, ai, backend, backup, storage versions |
| `src/services` | 84 | auth, api clients, encryption, notifications, health export, csv import, data migrations, workout worker, Tolgee |
| `src/utils` | 39 | pure helpers (date, base64, color, stream, uuid, backup format, units, â€¦) |
| `src/i18n` | 26 | 19 Tolgee locale JSON files + 7 feed fragment files |
| `src/drizzle` | 20 | 9 generated `.sql` migrations + journal, snapshots, `migrations.js` |
| `src/hooks` | 19 | `useAppTheme`, `useStartWorkout`, `useFinishWorkout`, `usePreferredWeightUnit`, `useWindowLayout`, â€¦ |
| `src/db` | 4 | `schema.ts` (Drizzle), `helpers.ts`, and 2 spec files |
| `src/styles` | 4 | `theme.ts`, `accent-seeds.ts`, `theme.usage.tsx`, `styled.d.ts` |
| `src/gen` | 3 | protobufjs output â€” generated, do not hand-edit |

### 4.1 `src/components/presentation` â€” 774 files in 15 folders

`settings` 177, `feed` 143, `stats` 101, `foundation` 82, `history` 61, `workout` 50, `home` 39,
`exercise-editor` 26, `summary` 24, `ai-planner` 18, `backends` 15, `workout-editor` 13,
`plan-diff` 12, `calendar` 7, `navigation` 6.

`foundation` is the reusable UI kit: buttons, card/item lists, forms, dialogs, editors, loaders,
glass backgrounds, focus rings, plus platform-split folders (`menu`, `native-button`, `page-actions`,
`page-menu`, `segmented-picker`, `select-picker`, `switch`, `indeterminate-progress`) each holding
`name.tsx`, `name.android.tsx`, `name-props.tsx` and an `index.tsx` barrel.

### 4.2 `src/services` â€” 49 top-level files

| Group | Files |
|---|---|
| Auth and API | `auth-service.ts`, `auth-config.ts`, `authenticated-fetch.ts`, `api-consts.ts`, `api-error.ts` |
| Feed / social | `feed-api.ts`, `feed-identity-service.ts`, `feed-follow-service.ts`, `feed-inbox-decryption-service.ts` |
| AI | `ai-chat-service-v2.ts`, `ai-chat-offline-script.ts`, `hub-connection-factory.ts` |
| Platform | `notification-service.ts`, `notification-service.ios.ts`, `notification-schedule.ts`, `notification-scheduler.ts`, `health-export-service{,.android,.ios,-shared}.ts`, `workout-worker.ts` |
| Storage | `key-value-store.ts`, `database-import-service.ts`, `database-migration-service.ts`, `progress-repository.ts`, `session-service.ts` |
| Import / export | `file-export-service.ts`, `file-picker-service.ts`, `string-sharer.ts`, `plaintext-export-preview.ts`, `backup-format` helpers in `utils`, `csv-import/` folder (StrongLifts, FitNotes) |
| Misc | `encryption-service.ts`, `backend-probe.ts`, `exercise-catalog.ts`, `preference-service.ts`, `logger.ts`, `tolgee.ts`, `index.ts` (`createServices`) |

Each service that is non-trivial has a colocated `*.spec.ts` â€” 19 spec files live in `src/services`.

## 5. State management

Redux Toolkit + react-redux. No Zustand, no React Query, no redux-persist.

- `src/store/store.ts`: `configureStore` with `combineReducers`; slices `aiPlanner, auth, settings,
  program, feed, feedComments, composerPosts, app, storedSessions, stats, backends`.
  Serialisable and immutability checks are **disabled on purpose** ("We manually do persistence").
- Custom `addEffect(actionPredicate, effect)` built on `createListenerMiddleware`, giving each slice
  an effect module that receives `onFail`, `stateBeforeReduce`, `stateAfterReduce`, `extra: Services`.
- `src/store/index.ts` wires all 13 effect modules, dispatches `initializeAppStateSlice()` and
  `initializeFeedComments()`, and exports `useAppSelector`, `useAppSelectorWithArg`,
  `useAppSelectorWhenFocused`, `useAppSelectorWhenFocusedWithArg`, `useAppStore`.
- Services are injected through `ServicesProvider` (`createServices(store, db, expoDb)`),
  consumed with `useServices()`.

## 6. Data layer

| Concern | Implementation |
|---|---|
| HTTP | native `fetch` only (no axios); `authenticated-fetch.ts` adds the bearer token, rotates once on 401, throws `AuthError('session-expired' | 'network')` |
| Base URLs | `src/services/api-consts.ts` â€” see `01_project_overview.md` Â§3 |
| Auth | Google Sign-In via `@react-native-google-signin/google-signin`, lazy-loaded so a missing native module degrades to `not-configured`; access token in memory, refresh token + profile in `expo-secure-store` key `alcedo.auth.session`; `REFRESH_SKEW_SECONDS = 60`; error codes `not-configured, cancelled, in-progress, play-services-unavailable, no-id-token, network, rejected, session-expired` |
| Backend probe | `src/services/backend-probe.ts` fetches `{url}/features` and keeps only `enabled: true` entries |
| Local database | SQLite via `expo-sqlite` + `drizzle-orm` (`openDatabaseAsync('db.db')`), **17 tables**: `session`, `exercise`, `program`, `feed_identity`, `feed_followed_user`, `feed_pending_user`, `feed_items`, `feed_follower_user`, `feed_follow_request`, `feed_reaction`, `feed_sent_reaction`, `feed_revoked_follow_secrets`, `feed_unpublished_sessions`, `data_migration`, `backend`, `backend_header`, `backend_assignment` |
| Key-value store | `src/services/key-value-store.ts` over `expo-file-system` files with atomic temp-file writes. No AsyncStorage, no MMKV |
| Secrets | `expo-secure-store` |
| Encryption | `react-native-quick-crypto` WebCrypto `subtle`; **AES-CBC 128-bit + RSA-256-PSS** signature for feed content (`src/services/encryption-service.ts`, models in `src/models/encryption-models.ts`, test vectors in `src/services/test-assets/`) |
| Model versioning | `src/models/storage/versions/` with `any`, `initial` and `latest` schema sets (ai-plan, blueprint, exercise-descriptor, feed, session), a `libs/` helper, a `migrator.ts`, and **six named migration steps** in `versions/migrations/steps/`: `add-progressive-overload`, `add-set-targets`, `add-uses-bodyweight`, `progressive-overload-to-rules`, `reps-config-to-planned-sets`, `reps-per-set-to-reps-config` (most with colocated specs). Also `versions/initial/protobuf-migrator.ts` and a checked-in `export.liftlogbackup.gz` fixture |
| AI | `src/services/ai-chat-service-v2.ts` over `@microsoft/signalr` to hub `/ai-chat-v2` (`Introduce`, `SendMessage`, `StopInProgress`, inbound `ReceiveMessage`) |
| Notifications | `expo-notifications` + `expo-keep-awake`, scheduling services, per-OS variants |
| Purchases | `react-native-purchases` + `react-native-purchases-ui` (RevenueCat) for premium gating |
| Health export | `@kingstinct/react-native-healthkit` (iOS), `react-native-health-connect` + `expo-health-connect` (Android) |
| CSV import | `react-native-csv` with StrongLifts and FitNotes importers in `src/services/csv-import/` |
| Real-time | `hub-connection-factory.ts` builds SignalR connections with custom headers |

## 7. Styling and theming

Three layers, no Tailwind/NativeWind in the app:

1. `styled-components/native` 6.1.8 â€” the mandated mechanism for all new UI. `metro.config.js` forces
   the native CJS entry and a `styled-shim.js` polyfill stubs `document` for Hermes.
2. `react-native-paper` 5.15.3 themed over the custom palette in `src/hooks/useAppTheme.tsx`
   (`MD3DarkTheme`/`MD3LightTheme` + custom icon renderer), plus `react-native-paper-dates`,
   `react-native-paper-tabs`. Paper is being **incrementally migrated to `@expo/ui`** (SwiftUI on iOS,
   Jetpack Compose on Android) using the platform-split file convention.
3. Local `StyleSheet` in `*.styles.ts` files (legacy, being migrated away).

`src/styles/theme.ts` â€” **947 lines, 34,951 bytes** (`AGENTS.md` still says 857 lines; the file is the
authority). It exports `palette` (raw ramps including `kingfisher`, `cobalt`, `turquoise`),
`systemColors`, `SemanticColors` (grouped `color.content.*`, `color.fill.*`, `color.border.*`,
`color.status.*`, `color.interactive.*`, `color.background.*`), `space`, `radius`, `borderWidth`,
`layout`, `elevation`, `zIndex`, `opacity`, `motion`, `Materials` (ultraThinâ€¦chrome), `gradients`,
`HomeGradientSpec`, `HomeTokens`, `ExerciseHistoryTokens`, `components`, `textStyles`
(**192 named text styles** such as `title1`, `body`, `caption1`), and the functions
`type(theme, name, options?)`, `createTheme(colorScheme, platform)`, `lightTheme`, `darkTheme`,
`scaleType`, `hitSlopFor`, `alpha`. `src/styles/accent-seeds.ts` holds user-selectable accent seeds;
`src/styles/theme.usage.tsx` holds the documented consumption examples (`Screen`, `Content`, `Text`).

Theme access is `useAppTheme()` from `@/hooks/useAppTheme`. Dark mode: `userInterfaceStyle: automatic`;
`settings.themeMode` (`system|light|dark`), a true-black dark theme override, and an accent-seed
gradient option. The theme is bridged into expo-router's `ThemeProvider` and Paper's `PaperProvider`.

The same hook still exports **deprecated shims** (`spacing`, `font`, `rounding`, `colors`,
`ColorChoice`, `AppThemeColors`) with roughly **83 remaining importers**; `AGENTS.md` forbids their
use in new code.

## 7.1 Coding conventions the repository mandates (`AGENTS.md`)

Directly reportable as the project's engineering standard.

| Rule | Detail |
|---|---|
| File organisation | one folder per section, folder name == file stem, kebab-case: `<name>.tsx` + `<name>.styles.ts`, optional `<name>.android.tsx`, `<name>-props.tsx`, `index.tsx` barrel. Styles never live in the component file |
| Styling | `styled-components/native` only; values come from `props.theme` (`theme.color.*`, `theme.space.*`, `theme.radius.*`, `theme.elevation.*`, `theme.components.*`, `type(theme, 'body')`). No raw hex or pixel values |
| Transient props | conditional styles ride `$`-prefixed props so they never reach the native view; use the `css` helper |
| Text styles | always `type(theme, name)`; `{ tabular: true }` for numbers that mutate in place (timers, counters) |
| React Compiler | enabled, so `useMemo`/`useCallback`/`React.memo` must **not** be added by default |
| Exports | named exports for new files; older files use defaults and are not bulk-converted |
| Reuse | reach for `foundation/` primitives before writing a new control; migrate a file to styled-components only when already editing it, never in bulk |
| Documentation | read `docs/index.md` first, and update it in the same change when a document changes |
| Generated code | `src/gen` and `docs/schemas` are generated; do not hand-edit |
| What's New | entries in `app/src/models/whats-new.ts`, append-only with a monotonic `id`; the highest `id` drives the unread state; opt-in features should also be surfaced in the welcome wizard |
| Before done | `npm run typecheck` and `npm run lint` must pass |
| C# | `dotnet csharpier .` before committing |

### 7.2 Onboarding

There is **no onboarding route**. The final commit `0ee0ebd` ("feat(): onboarding design") added only
design assets: six SVGs in `docs/new_design/onboading/` (welcome, localisation, notifications-and-feed,
each dark and light) plus a `docs/index.md` entry â€” 7 files, 905 insertions, no code. The existing
implementation is the single component `app/src/components/smart/welcome-wizard.tsx`.

## 8. Notable native modules

`app/modules/workout-worker` â€” Kotlin (Android) and Swift (iOS) module for the foreground workout
service and notification management, with protobuf message payloads; `app/modules/native-lib` â€”
second native module. The app talks to them through `src/store/workout-worker/` message types.

## 9. App configuration details (`app.json`)

Bundle id `com.limajuice.liftlog`, slug `liftlog`, version 1.0.0, background `#02040A`, primary
`#0B2CC8`, web output `single`. 17 config plugins: expo-router, expo-dev-client (launchMode
most-recent), expo-health-connect, react-native-healthkit, expo-localization, expo-sharing, the five
local plugins (`override-health-connect-min-version`, `android-signing`, `android-gradle-properties`,
`android-react-native-feature-flags`, `android-nav-bar-contrast`), expo-notifications, expo-sqlite,
expo-splash-screen, expo-status-bar, expo-video, expo-secure-store,
@react-native-google-signin/google-signin. `expo.doctor` excludes 5 packages from the RN check.

## 10. Testing in the app

- **Vitest 4**, jsdom, `test/setup.ts`, v8 coverage scoped to `src/{models,services,store,utils,hooks}`.
- **140 `*.spec.ts(x)` files**, all under `src`, none under `src/app`. By area: components 51,
  store 34, models 25, services 19, utils 7, db 2, hooks 2, plus 2 `.snap` files.
- Property-based testing with `fast-check`; `expo-sqlite` and Drizzle are remapped to
  `drizzle-orm/libsql` + `test/shims/*`; `.sql` files inline-imported by a custom plugin.
- Naming convention: `*-simulation.spec.ts` (screen-level), `*-logic.spec.ts`, `*-data.spec.ts`.
- **Maestro** end-to-end: 6 YAML files in `app/.maestro` (see `02_repository_map.md` Â§4).

## 11. Assets usable as report figures

| Source | Files |
|---|---|
| Store renders used in the repository README | `assets/AppScreens-LiftLog-1782275372989.render/apple/English (en-US)/iPhones 6.9/01â€“04.png` (1320 Ã— 2868) |
| Design references | `docs/new_design/home_page_screen1.svg`, `home_screen_light_mode.svg`, `tab-bar-icons.svg`, `diff-save-dark.svg`, `backend-editor-dark.svg`, `planner-chat-dark.svg` |
| Onboarding designs | `docs/new_design/onboading/onboarding-1-welcome{,-light}.svg`, `onboarding-2-localisation{,-light}.svg`, `onboarding-3-notifications-feed{,-light}.svg` |
| Marketing screenshots | `site/assets/img/home.png`, `stats.png`, `exercise-stats.png`, `ai-planner.png`, `workoutpage.png` |
| Report repository | `src/data/figures/screen.png` (893 Ã— 645) already shows home, workout and stats screens |

Pixel dimensions and a figure numbering plan are in `18_figures_and_assets.md`.

## 12. Screenshot automation

`scripts/collect-screenshots.ts` drives a built app through the deep link
`liftlog://screenshot-collection`, handled by `app/src/app/(tabs)/(session)/screenshot-collection.tsx`,
which generates demo data into local storage (`@js-joda/core` for dates, AI plan seeding) and captures
each screen to `./screenshots/` â€” a gitignored directory. The Fastlane render set in `assets/` was
produced by the equivalent Fastlane `supply` pipeline.