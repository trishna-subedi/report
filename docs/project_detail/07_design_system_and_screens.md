# 07 â€” Design System, Screens and Design Documentation

This is the evidence set for any report section about interface work, and the closest thing the
repository has to a design specification.

## 1. Screen inventory â€” 24 pages

`docs/new_design/page-verification.md` is the tracker, and the commit subjects track it exactly:
pages 1â€“19 were committed as "â€¦ simulation (page n/20)", then "Tracker: expand to 24 pages", then
pages 21â€“24. Mapping the tracker to the routes in `app/src/app`:

| # | Page | Route |
|---|---|---|
| 1 | Home / workout hub | `/(tabs)/(session)/index` |
| 2 | Workout flow (live session) | `/(tabs)/(session)/session/index` |
| 3 | Workout editor | `/workout-editor` |
| 4 | Exercise editor | `/exercise-editor` |
| 5 | Diff and save | `/diff-save` |
| 6 | History | `/(tabs)/history/index` |
| 7 | Trends / stats | `/(tabs)/stats/index` |
| 8 | Feed timeline | `/(tabs)/feed/index` |
| 9 | Feed post detail | `/(tabs)/feed/item/[id]` |
| 10 | Feed share composer | `/(tabs)/feed/share` |
| 11 | Feed profile editor | `/(tabs)/feed/profile-editor` |
| 12 | Feed shared item | `/(tabs)/feed/shared-item/[id]` |
| 13 | Settings home | `/(tabs)/settings/index` |
| 14 | Preferences (app configuration + localisation) | `/(tabs)/settings/app-configuration`, `/localization` |
| 15 | Notifications | `/(tabs)/settings/notifications` |
| 16 | AI planner | `/(tabs)/settings/ai/planner` |
| 17 | Programs and plan import | `/(tabs)/settings/program-list`, `/import-plan`, `/import-plan-info` |
| 18 | Backup hub and child routes | `/(tabs)/settings/backup-and-restore/*` |
| 19 | What's new | `/(tabs)/settings/whats-new` |
| 20 | Post-workout summary | `/(tabs)/(session)/session/post-workout`, `/(tabs)/history/post-workout` |
| 21 | Exercise search | `/exercise-search` |
| 22 | Exercise history | `/exercise-history` |
| 23 | Manage exercises | `/(tabs)/settings/manage-exercises` |
| 24 | AI planner chat | `/(tabs)/settings/ai/planner-chat` |

Not in the 24-page tracker but present in the route tree (49 route files in total, so several routes
back the same page or are sub-routes of a tracked page):
`/(tabs)/stats/exercise-list`, `/(tabs)/stats/expanded-weighted-exercise`, `/(tabs)/history/edit`,
`/(tabs)/settings/account`, `/(tabs)/settings/backends/index` and `backends/[id]`,
`manage-workouts/[programId]` plus its two `manage-session/[sessionIndex]` routes, and
`/(tabs)/(session)/screenshot-collection` (a development tool, not a user page).

**Onboarding is not implemented as a route.** Commit `0ee0ebd` ("feat(): onboarding design") added
only six design SVGs and one `docs/index.md` line â€” 7 files, 905 insertions, zero code. The existing
onboarding code is the single component `app/src/components/smart/welcome-wizard.tsx`.

## 2. Design token system â€” `app/src/styles/theme.ts` (35 KB)

Exported tokens: `palette`, `systemColors`, `fontWeight`, `TextStyle`/`textStyles`,
`tabularNumbers`, `space`, `radius`, `borderWidth`, `layout`, `zIndex`, `opacity`, `motion`,
`Tone`, `SemanticColors`, `Shadow`, `Material`/`Materials` (`ultraThin | thin | regular | thick | chrome`),
`Gradient`/`gradients`, `HomeGradientSpec`, `HomeTokens`, `ExerciseHistoryTokens`, `components`,
`ThemeMode`, `AppTheme`, `createTheme(mode, platform)`, `lightTheme`, `darkTheme`, `type()`,
`scaleType()`, `hitSlopFor()`, `alpha()`.

Supporting files: `accent-seeds.ts` (user-selectable accent seeds),
`theme.usage.tsx` (documented consumption examples `Screen`, `Content`, `Text`),
`styled.d.ts`.

Theme modes: `system | light | dark`, plus a true-black dark theme and an accent-seed gradient
option. Bridged into expo-router's `ThemeProvider` and Paper's `PaperProvider`.

## 3. Component architecture

| Layer | Location | Rule |
|---|---|---|
| Foundation (UI kit) | `src/components/presentation/foundation` â€” 82 files | Platform-split components (`.android.tsx` + `.tsx` + `index.tsx` + props) for `menu`, `native-button`, `page-actions`, `page-menu`, `segmented-picker`, `select-picker`, `switch`, `indeterminate-progress`; `editors/` for weight, decimal, integer, duration, color dialogs and sliders |
| Feature presentation | `src/components/presentation/{settings,feed,stats,history,workout,home,exercise-editor,summary,ai-planner,backends,workout-editor,plan-diff,calendar,navigation}` | Pure display, styled with the theme tokens |
| Smart / container | `src/components/smart` â€” 67 files | Wired to the Redux store and services; holds the logic |
| Layout | `src/components/layout` â€” 3 files | `stack-with-header`, `settings-page`, `full-height-scroll-view` |

`src/components` totals **844 files**. Local `*.styles.ts` files sit next to `*.tsx` files â€” this is
the convention `AGENTS.md` mandates, and `docs/working/styles_ledger.md` tracks it.

## 4. Design documentation in the repository

| File | Content |
|---|---|
| `docs/new_design/page-verification.md` | The 24-page tracker with per-page verification state |
| `docs/new_design/workout-flow-brief.md`, `workout-flow-dark.md` | Workout flow design |
| `docs/new_design/*-dark.md` | Phase design briefs, titled "PHASE 3 Â· KINETIC TRENDS", "PHASE 4 Â· KINETIC HISTORY", "PHASE 5 Â· KINETIC FEED (SOCIAL)", "PHASE 6 Â· KINETIC SETTINGS" (phases 1â€“2 are `workout-flow-*`) |
| `docs/new_design/backup-redesign.md`, `diff-save-redesign.md`, `exercise-editor-redesign.md`, `workout-editor-redesign.md` | Feature redesign briefs |
| `docs/new_design/offline-first-plan.md` | Phase 0â€“4 offline-first delivery ladder with data-safety reasoning |
| `docs/new_design/*.svg` | `home_page`, `home_page_screen1`, `home_screen_light_mode`, `tab-bar-icons`, `diff-save-dark`, `backend-editor-dark`, `planner-chat-dark` |
| `docs/new_design/onboading/` | Onboarding SVGs: `onboarding-1-welcome`, `onboarding-2-localisation`, `onboarding-3-notifications-feed`, each with a light variant |
| `docs/polish_ui/**` | 22 polish ledgers, one per screen group, with dated rows and phases |
| `docs/working/logo_brand_name_ledger.md` | Rebrand decisions D1â€“D6 and a per-key, per-platform rename table |
| `docs/schemas/` | 45 generated JSON schema files (AI plan, program blueprint, workout worker messages) |

Each phase document ends with an explicit open question for the owner, which is direct evidence of a
supervised, review-driven process.

## 5. Screenshots available for report figures

| File | Use |
|---|---|
| `assets/AppScreens-LiftLog-1782275372989.render/apple/English (en-US)/iPhones 6.9/01â€“03.png` | Home, workouts, stats â€” the three README heroes; the same images are in the report repository as `src/data/figures/screen.png` |
| `assets/AppScreens-.../android/Android Phones 169/01â€“04.png` | Android variants, 904â€“1012 KB each |
| `assets/AppScreens-.../apple/iPad 13/01â€“04.png` | iPad variants |
| `site/assets/img/*.png` | Marketing screenshots |
| `docs/new_design/*.svg`, `docs/new_design/onboading/*.svg` | Design references, usable as interface figures |
| `src/data/figures/screen.png` (report repository) | Already prepared: home, workout, stats tab bar |

`scripts/collect-screenshots.ts` writes new screenshots to `./screenshots/`, which is gitignored, and
drives the app through the deep link `liftlog://screenshot-collection`
(`app/src/app/(tabs)/(session)/screenshot-collection.tsx`).