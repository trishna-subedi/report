# 16 — Glossary and Abbreviations

Draft material for the report's **List of Abbreviations** page and for glossing repository jargon.
Every expansion below is taken from the codebase.

## 1. List of Abbreviations (APA style, alphabetical)

Only include the ones the report actually uses.

| Abbreviation | Expansion |
|---|---|
| AES | Advanced Encryption Standard |
| AES-CBC | Advanced Encryption Standard in Cipher Block Chaining mode |
| AES-GCM | Advanced Encryption Standard in Galois/Counter Mode |
| AGPL | GNU Affero General Public License |
| API | Application Programming Interface |
| ASP.NET | Active Server Pages .NET |
| BFF | Backend for Frontend |
| CI | Continuous Integration |
| CLI | Command-Line Interface |
| CRUD | Create, Read, Update, Delete |
| CSS | Cascading Style Sheets |
| CSV | Comma-Separated Values |
| DTO | Data Transfer Object |
| EAS | Expo Application Services |
| EF | Entity Framework |
| Expo | A framework and toolchain for React Native |
| GCM | Galois/Counter Mode |
| Git | distributed version-control system |
| HMAC | Hash-based Message Authentication Code |
| HTTP | Hypertext Transfer Protocol |
| i18n | internationalization |
| JSON | JavaScript Object Notation |
| JWT | JSON Web Token |
| LLB | LiftLog Library (the .NET shared library, `LiftLog.Lib`) |
| MAUI | .NET Multi-platform App UI |
| MD3 | Material Design 3 |
| MFA | Multi-Factor Authentication (not used in this project) |
| Mongoose | ODM library for MongoDB |
| MSAL | Microsoft Authentication Library (not used in this project) |
| NestJS | a Node.js server framework |
| OAuth | Open Authorization |
| ORM | Object-Relational Mapping |
| PBKDF2 | Password-Based Key Derivation Function 2 |
| PR | Personal Record |
| RBAC | Role-Based Access Control |
| REST | Representational State Transfer |
| RN | React Native |
| RSA | Rivest–Shamir–Adleman (public-key cryptosystem) |
| SDK | Software Development Kit |
| SEO | Search Engine Optimization |
| SSE | Server-Sent Events |
| SSR | Server-Side Rendering |
| SQLite | embedded relational database |
| TLS | Transport Layer Security |
| UI | User Interface |
| UX | User Experience |
| Vite | build tool used by Vitest |
| W3C | World Wide Web Consortium |
| WAL | Write-Ahead Logging |
| Zumba | a fitness dance class format |

## 2. Technology glossary

| Term | Meaning in this project |
|---|---|
| Alcedo | the product's current display name: `app.json` `expo.name`, website copy, Android/iOS strings |
| LiftLog | the inherited internal name: folder name, package `alcedo-react`, slug `liftlog`, bundle id `com.limajuice.liftlog`, `.liftlogplan` files, Docker images |
| Kinetic | design-spec phase naming in `docs/new_design/*-dark.md` (PHASE 3–6) |
| backend-v2 | the NestJS 11 + MongoDB service: auth, sync, billing, AI coach, social graph, admin config |
| built-in backend | the .NET service at `api.liftlog.online`, registered as non-removable in `src/store/backends/index.ts` |
| self-hosting | pointing the app at a member's own server via `settings/backends` |
| section file | the `<name>.tsx` + `<name>.styles.ts` (+ optional `.android.tsx`, `-props.tsx`, `index.tsx`) folder convention mandated by `AGENTS.md` |
| transient props | `$`-prefixed styled-components props used for conditional styles, kept away from the native view |
| effect module | a Redux slice listener that performs side effects (persist, call a service) after a reduce |
| store effect | the custom `addEffect` helper built on `createListenerMiddleware` |
| simulation spec | a Vitest file that drives a screen through its states (`*-simulation.spec.ts`) |
| property test | a `fast-check` test that generates inputs and checks invariants |
| page (in design docs) | one of the 24 screens tracked in `docs/new_design/page-verification.md` |
| polish ledger | per-screen punch list with dates and a patch order, in `docs/polish_ui/` |
| merge ledger | `docs/merge_ledger.md`, the record of the branch-merge programme |
| plan / program | a training plan: `ProgramBlueprint`, `SessionBlueprint`, `ExerciseBlueprint` |
| session | a logged workout: `Session`, `RecordedExercise`, `RecordedSet` |
| blueprint | the declarative description of a planned session, including progression rules |
| diff-save | the `/diff-save` screen that reviews and applies changes to the active plan |
| feed | the social timeline: posts, follows, comments, reactions, shared items |
| shared item | a session or plan deliberately shared with another member |
| inbox | end-to-end encrypted messages queued for the member, decrypted on device |
| follow secret | the token proving a follow relationship without exposing identities |
| feature | a server capability the app routes to a chosen backend: `feed`, `aiPlanner`, `backup` |
| feature flag (server) | a value in `GET /api/features`, or an admin-editable key in `site-config` |
| entitlement | the premium state on the user record, granted by RevenueCat, web checkout or Stripe |
| coach / AI planner | the conversational plan assistant (SignalR hub on .NET, LiteLLM on backend-v2) |
| skill (AI) | one of six prompt-side specialisations: `form-check`, `program-design`, `progression`, `nutrition`, `recovery`, `conditioning` |
| guardrail | keyword topic classification and output checks around the AI coach |
| workout worker | the Kotlin/Swift native module running the foreground workout service and notifications |
| What’s New | the in-app release-notes surface, entries in `app/src/models/whats-new.ts` |
| Tab | one of the five bottom tabs: Workout, Feed, Stats, History, Settings |

## 3. Domain terms the gym member sees

| Term | Meaning |
|---|---|
| Set | one recorded attempt: reps, weight, unit, RPE |
| Cardio set | a timed or distance-based entry instead of a weighted set |
| Rest timer | countdown between sets with notification support |
| Progression rule | how a planned load increases (axis, strategy, set scope, success rule) |
| PR | personal record for an exercise |
| RPE | rate of perceived exertion |
| Heatmap | calendar-style grid of training frequency in Stats |
| Muscle-group load | per-muscle volume summary in Trends |
| Kinetic coach | the AI coaching card on the home screen |
| Remote backup | encrypted copy of app data stored on a server the member controls |

## 4. Writing guidance

- Use **Alcedo** as the application name; mention LiftLog once if the repository link requires it.
- Prefer the member-facing words (workout, plan, exercise) over the code words
  (session, blueprint, recorded set) in Chapters 1, 2 and 4; use the code words in 3.4 where they
  describe implementation.
- Do not invent abbreviations. Every row above is verified against the repository.