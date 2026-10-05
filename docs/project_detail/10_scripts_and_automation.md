# 10 — Scripts, Automation, Skills and Examples

## 1. `scripts/` (9 files, Node with `zx`)

| File | Purpose |
|---|---|
| `create-release.ts` | Cuts a release |
| `get-release-notes.ts` | Builds release notes |
| `release-plan-builder-skill.ts` | Packaging for the plan-builder skill |
| `collect-screenshots.ts` | Drives the app via the `liftlog://screenshot-collection` deep link to capture store screenshots into `./screenshots/` (gitignored) |
| `.gitignore` | ignores `screenshots/` |

Untracked workflow `plan-builder-skill-build.yml` and `release.yml` cover publishing.

## 2. `app/scripts/` (3 files)

| File | Purpose |
|---|---|
| `generate-branding.mjs` | Generates icon, foreground, monochrome, splash and notification PNGs from `assets/logo/*` |
| `generate-json-schemas.js` | Emits JSON schemas from `modules/workout-worker/schema` (uses `ts-json-schema-generator`, `sharp`, `esbuild`) |
| `build-plan-validator.mjs` | Builds the Ajv validator used for plan files |

Run through `npm run json-schema`.

## 3. `app/patches/` — `patch-package`

Five patches applied on `postinstall`, including `styled-components+6.1.8.patch` and
`react-native-paper+5.15.3.patch`. `app/polyfills/styled-shim.js` stubs `document` for Hermes so
styled-components can initialise; it is imported first in `app/src/app/_layout.tsx` and injected as a
serializer polyfill by `metro.config.js`.

## 4. `app/plugins/` — five local Expo config plugins

| Plugin | Purpose |
|---|---|
| `override-health-connect-min-version.js` | Raises the Android Health Connect minimum version |
| `android-signing.js` | Android signing configuration |
| `android-gradle-properties.js` | Gradle property injection |
| `android-react-native-feature-flags.js` | React Native Android feature-flag toggles |
| `android-nav-bar-contrast.js` | Navigation bar contrast handling |

All five are registered in `app.json` alongside the twelve Expo/library plugins.

## 5. `AGENTS.md` and `.agents/skills/`

`AGENTS.md` is the development contract. Its load-bearing rules:

- TypeScript styling in `app/` uses **styled-components**, not Tailwind; theme tokens come from
  `app/src/styles/theme.ts`.
- Use the section-file layout for components (`*.tsx` + `*.styles.ts` + subfolder).
- `backend/` is a .NET / C# Web API that "usually does not need changing" to add app features — only
  touch it when the task is explicitly backend work.
- C# is formatted with CSharpier (`dotnet csharpier .`) before committing.
- Keep `docs/index.md` current when `docs/polish_ui/` or the merge ledger changes.

`.agents/skills/` holds three `SKILL.md` documents that define how a change is made:

| Skill | Scope |
|---|---|
| `apple-ios-frontend/SKILL.md` | iOS/Apple-grade frontend conventions |
| `add-setting-or-preference/SKILL.md` | How to add a setting or preference |
| `add-storage-migration/SKILL.md` | How to add a storage migration |

These are the repository's own recipes for the kind of work described in the weekly log
(components, screens, preferences, storage migrations) — strong evidence for the report's
"how work was done" narrative.

## 6. `plugins/liftlog-plan-builder/` (8 files)

A Claude/Cline plugin (`plugin.json` declares AGPL-3.0) that teaches an assistant to author
LiftLog/Alcedo workout plan files, with a script and reference material. It is built by the untracked
workflow `plan-builder-skill-build.yml`.

## 7. `examples/remote-backup/` (25 files)

A reference backup server implementation: `LiftLog.BackupServer` (`net10.0`,
`Microsoft.NET.Sdk.Web`, not in the solution) plus Terraform infrastructure. Built and published by
`backupserver-build.yml` / `backupserver-publish.yml`. It is what the app's
`/settings/backup-and-restore` remote backup feature talks to.

## 8. `assets/` (28 files)

| Subfolder | Contents |
|---|---|
| root | `developerpic-playstore.png`, `play_store_512.png`, `play_store_feature_graphic.png`, `google-play-badge.png`, `Icons.txt` |
| `AppScreens-LiftLog-1782275372989.render/` | Fastlane `supply` render: 4 shots × iPhone 6.9, iPad 13, Android Phone 169 |
| `logo/` | Alcedo "kingfisher" mark: 1024 px PNG composite, 4 SVG masters |
| `appstorebadges/` | `black.svg`, `white.svg`, `pre-order-on-black.svg`, `pre-order-on-white.svg` |

`app/assets/` holds the generated app icons, splash and notification images, the bundled exercise
catalogue `exercises.json` (251 KB) plus 19 localised catalogues (only `en`, `ru`, `it` populated;
15 are 0-byte Weblate placeholders), 11 mock feed avatars, and 5 feed media files.
`app/public/` holds `index.html`, `404.html` and the `.well-known` files for iOS universal links and
Android App Links.

## 9. Untracked-inherited automation worth knowing about

`.github/` is present on disk but gitignored. Among its 17 workflows:
`api-test.yml` (Postgres 17 on 5401 + LocalStack on 4566, `dotnet run` as the test command),
`api-build.yml` / `api-publish.yml`, `android-build.yml` / `android-publish.yml`,
`ios-build.yml` / `ios-publish.yml`, `static-site-build.yml` / `static-site.yml`, `format.yml`
(CSharpier check on every non-`main` push, auto-format on `renovate/*`),
`ui-unit-test.yml`, `backupserver-build.yml` / `backupserver-publish.yml`,
`plan-builder-skill-build.yml`, `pr-template-comment.yml`,
`discussion-welcome-comment.yml`. Treat these as inherited infrastructure, not as work done for the
gym.

## 10. Two stale artefacts

- `app/tmp-lint.log` (~2 MB) is committed because `tmp-*.log` is not in `.gitignore`.
- `.vscode/launch.json` still references `${workspaceFolder}/LiftLog.Web`, a folder from the
  pre-React-Native .NET MAUI app that no longer exists.
- LinguaSharp `.lscache` files (`LiftLog.Api.csproj.lscache` 20 KB, `RevenueCat.csproj.lscache`
  36 KB and siblings) are IDE caches committed to source control.