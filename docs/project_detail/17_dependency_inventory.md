# 17 — Dependency Inventory

Exact versions from the manifests at `0ee0ebd`. Use for the "Tools and Technologies" table in
Chapter 3 and for the report's List of Abbreviations.

## 1. `app/` — 83 runtime dependencies, 25 dev dependencies

### Framework and language

| Package | Version |
|---|---|
| `expo` | `~57.0.26` |
| `expo-router` | `~57.0.24` |
| `react` / `react-dom` | `19.2.3` |
| `react-native` | `0.86.3` |
| `typescript` | `~6.0.3` (dev) |
| `@typescript/native-preview` | `^7.0.0-dev.20251121.1` (dev, provides `tsgo`) |
| `babel-plugin-react-compiler` | `^1.0.0` |
| `react-compiler-runtime` | `^1.0.0` |
| `@babel/plugin-proposal-export-namespace-from` | `^7.18.9` |

### Navigation, state, data

| Package | Version | Purpose |
|---|---|---|
| `react-native-screens` | `4.26.2` | native screen containers |
| `react-native-safe-area-context` | `~5.7.0` | safe areas |
| `react-native-gesture-handler` | `~2.32.0` | gestures |
| `react-native-reanimated` | `4.5.1` | animations |
| `react-native-worklets` | `0.10.1` | worklet runtime |
| `@reduxjs/toolkit` | `^2.11.2` | state |
| `react-redux` | `^9.2.0` | state bindings |
| `expo-sqlite` | `~57.0.3` | local database |
| `drizzle-orm` | `^0.45.2` | ORM / migrations |
| `drizzle-kit` | `^0.31.10` | dev: migration generation |
| `@libsql/client` | `^0.17.3` | dev: libSQL driver used by the test shim |
| `expo-file-system` | `~57.0.0` | file-backed key-value store |
| `expo-secure-store` | `~57.0.4` | secrets |
| `expo-document-picker` | `~57.0.3`, `expo-sharing` `~57.0.22`, `expo-clipboard` `~57.0.2` | import/export |
| `expo-constants` | `~57.0.2` | config access |
| `protobufjs` | `^7.6.5` | native module message schemas |

### Styling and UI

| Package | Version |
|---|---|
| `styled-components` | `^6.1.8` (patched) |
| `react-native-paper` | `^5.15.3` (patched) |
| `react-native-paper-dates` | `^0.23.9` |
| `react-native-paper-tabs` | `^0.11.4` |
| `@expo/ui` | `~57.0.21` |
| `@shopify/react-native-skia` | `2.6.2` |
| `react-native-svg` | `15.15.4` |
| `react-native-gifted-charts` | `^1.4.77` |
| `@legendapp/list` | `^2.0.19` |
| `react-native-super-grid` | `^6.0.2` |
| `react-native-swipe-list-view` | `^3.2.9` |
| `react-native-pager-view` | `8.0.2` |
| `react-native-keyboard-controller` | `1.21.9` |
| `expo-glass-effect` | `~57.0.4`, `expo-linear-gradient` `~57.0.2` |
| `expo-video` | `~57.0.5`, `expo-haptics` | `~57.0.3` |
| `react-native-nitro-modules` | `^0.35.9` |

### Icons

`@expo/material-symbols` `^0.1.1`, `@material-symbols-react-native/outlined-400` `^1.0.0`,
`material-symbols-react-native` `^1.0.3`, `@react-native-vector-icons/material-design-icons` `^13.1.2`.

### Platform services

| Package | Version | Purpose |
|---|---|---|
| `@react-native-google-signin/google-signin` | `^16.1.5` | Google authentication |
| `@microsoft/signalr` | `^10.0.0` | AI chat, feed realtime |
| `react-native-purchases` / `-ui` | `^10.4.2` | RevenueCat subscriptions |
| `@kingstinct/react-native-healthkit` | `^14.0.2` | iOS health export |
| `react-native-health-connect` / `expo-health-connect` | `^3.5.3` / `^0.1.1` | Android health export |
| `expo-notifications` | `~57.0.21` | notifications |
| `expo-keep-awake` | `~57.0.0` | keep screen awake |
| `react-native-permissions` | `^5.3.0` | runtime permissions |
| `expo-localization` | `~57.0.2` | locale, units |
| `expo-dev-client` | `~57.0.19`, `expo-updates` `~57.0.24` | development builds, OTA |
| `expo-splash-screen`, `expo-status-bar`, `expo-linking`, `expo-intent-launcher`, `@expo/ngrok`, `@expo/metro-runtime`, `expo-web`(via react-dom) | various | platform plumbing |

### Data, maths, utilities

`@js-joda/core` `^5.6.4`, `bignumber.js` `^9.1.2`, `ts-pattern` `^5.6.2`, `linq` `^4.0.3`,
`data-async-iterators` `^1.4.6`, `use-debounce` `^10.1.0`, `uuid` `^14.0.1`,
`react-native-csv` `^0.2.0`, `ajv` `^8.20.0`, `ajv-formats` `^3.0.1`, `@tolgee/core` `7.1.0`,
`@tolgee/react` `^7.1.0`, `@tolgee/web` `7.1.0`, `@tolgee/format-icu` `^7.2.1`,
`react-native-quick-crypto` `^1.1.5`, `compression-streams-polyfill` `^0.1.7`,
`@testing-library/react` `^16.3.2`.

### Dev-only

`vitest` `^4.1.8`, `@vitest/coverage-v8` `^4.1.9`, `jsdom` `^28.1.0`, `fast-check` `^4.5.3`,
`oxlint` `^1.71.0`, `oxlint-tsgolint` `^0.23.0`, `oxfmt` `^0.56.0`, `eslint` `^9.39.2`,
`eslint-config-expo` `~57.0.2`, `eslint-plugin-react-compiler`, `eslint-plugin-check-file` `^3.3.1`,
`eslint-plugin-unused-imports` `^4.1.4`, `patch-package` `^8.0.0`, `sharp` `^0.35.4`,
`esbuild` `^0.28.1`, `ts-json-schema-generator` `^2.9.0`, `@types/react` `~19.2.10`,
`@types/node` `^24.3.3`, `@react-native-community/cli` `^20.1.2`, `@babel/core` `^7.29.0`,
`babel-plugin-inline-import` `^3.0.0`.

### Pinned via `patch-package` (5)

`styled-components+6.1.8`, `react-native-paper+5.15.3`, `bignumber.js+9.3.1`,
`data-async-iterators+1.4.6`, `linq+4.0.3`.

## 2. `backend-v2/` — 18 runtime, 12 dev

| Runtime | Version |
|---|---|
| `@nestjs/common`, `@nestjs/core`, `@nestjs/platform-express` | `^11.1.6` |
| `@nestjs/config` | `^4.0.2` |
| `@nestjs/jwt` | `^11.0.0` |
| `@nestjs/mongoose` | `^11.0.3` |
| `@nestjs/terminus` | `^11.0.0` |
| `@nestjs/throttler` | `^6.4.0` |
| `mongoose` | `^8.18.0` |
| `google-auth-library` | `^10.3.0` |
| `stripe` | `^22.6.2` |
| `helmet` | `^8.1.0` |
| `compression` | `^1.8.1` |
| `class-validator` | `^0.15.1`, `class-transformer` `^0.5.1` |
| `rxjs` | `^7.8.2`, `reflect-metadata` `^0.2.2` |

| Dev | Version |
|---|---|
| `@nestjs/cli` | `^11.0.10`, `@nestjs/testing` `^11.1.6` |
| `typescript` | `~5.9.2` |
| `jest` | `^30.1.3`, `ts-jest` `^29.4.1`, `@types/jest` `^30.0.0` |
| `ts-node` | `^10.9.2`, `source-map-support` `^0.5.21` |
| `oxlint` | `^1.19.0` |
| types | `@types/node ^22.18.0`, `@types/express ^5.0.3`, `@types/compression ^1.7.5` |

MongoDB 8 via `docker-compose.yml`; LiteLLM image `ghcr.io/berriai/litellm:main-stable`.

## 3. `backend/` and `tests/` — NuGet

| Project | Package | Version |
|---|---|---|
| `LiftLog.Api` | `Microsoft.EntityFrameworkCore` (+ Abstractions, Design, Relational, Sqlite) | `10.0.5` |
| | `Npgsql.EntityFrameworkCore.PostgreSQL` | `10.0.1` |
| | `EFCore.NamingConventions` | `10.0.1` |
| | `SQLitePCLRaw.bundle_e_sqlite3` | `2.1.13` (pinned for a security advisory) |
| | `Anthropic` | `12.9.0` |
| | `Microsoft.Extensions.AI` | `10.4.1` |
| | `AWSSDK.S3` | `4.0.102.4` |
| | `FluentValidation` (+ DI extensions) | `12.1.1` |
| | `AutomaticInterface` | `5.2.6` |
| | `cuid.net` (`Visus.Cuid`) | `7.0.0` |
| `LiftLog.Lib` | *(no package references)* | — |
| `RevenueCat` | `Microsoft.Kiota.Bundle` | `1.22.1` |
| `LiftLog.Tests.Api` | `TUnit` | `1.21.20` |
| | `NSubstitute` | `5.3.0` |
| | `Microsoft.NET.Test.Sdk` | `18.3.0` |
| | `Microsoft.AspNetCore.Mvc.Testing` | `10.0.5` |
| | `Microsoft.AspNetCore.SignalR.Client` | `10.0.5` |
| | `Anthropic`, `AWSSDK.S3`, `Microsoft.Extensions.AI` | as above |

Tool: CSharpier `1.2.6`. Target framework `net10.0` for all four projects.

## 4. `website/` — Next.js 16 stack

Next.js 16 (App Router), React, TypeScript 5, Tailwind CSS 4 with `@tailwindcss/postcss`, ESLint 9.
`next.config.ts` is empty (no options). No test framework.

## 5. Recommended "Tools and Technologies" table for the report

| Layer | Tools |
|---|---|
| Mobile framework | Expo SDK 57, React Native 0.86.3, React 19.2.3 |
| Language | TypeScript 6.0.3 (strict), tsgo type checker |
| Navigation | expo-router 57 (file-based, typed routes) |
| State management | Redux Toolkit 2.11, react-redux 9.2 |
| Styling | styled-components 6.1.8, React Native Paper 5.15.3, Material Design 3, custom theme system |
| Local data | SQLite (expo-sqlite) with Drizzle ORM 0.45, 9 migrations |
| Animation and graphics | Reanimated 4.5, Skia 2.6.2, SVG 15.15, gifted-charts |
| Networking | native `fetch`, `@microsoft/signalr` 10 |
| Authentication | Google Sign-In, JWT with rotating refresh tokens |
| Backend | NestJS 11, Express, MongoDB 8 with Mongoose 8.18, Stripe 22.6 |
| Legacy backend | ASP.NET Core 10, EF Core 10, SignalR, PostgreSQL / SQLite |
| Testing | Vitest 4, Jest 30, TUnit 1.21, Maestro, fast-check |
| Code quality | oxlint, oxfmt, ESLint (React Compiler rule), CSharpier, patch-package |
| Build and release | EAS Build, Expo config plugins, Docker, GitHub Actions (untracked) |
| Internationalisation | Tolgee 7 (19 locales), Weblate upstream |