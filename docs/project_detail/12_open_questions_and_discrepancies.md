# 12 â€” Open Questions and Discrepancies

Everything here must be resolved by the author before it can be written into the report. Nothing in
this file should be guessed or filled in by me.

## Blocking â€” the report cannot be written correctly until these are answered

### 1. Roll number

`data/information/front_matter.md` marks it `[CONFIRM: 79011927 ]`. `data/documents/front.pdf` prints
`79011927` on the cover but `79011` in the acknowledgement. **Confirm the correct roll number.**

### 2. Internship dates versus the repository history

| Claim | Source |
|---|---|
| "Start Date: July â€“ September", "Total Duration: 12 weeks" | `data/information/internship_information.md` |
| "October 2026" on the cover | `data/documents/front.pdf`, `front_matter.md` |
| Every commit in the repository is dated **2026-09-21 to 2026-09-23** (49 hours) | `09_git_history_workflow.md` Â§2 |

The repository cannot corroborate a 12-week timeline: the whole recorded history is three days, and
the first commit is a 1916-file import. The 12-week structure exists as *documented process* â€”
design phases 1â€“6, a 24-page tracker, 22 polish ledgers, a 5-phase merge programme â€” not as elapsed
time in git.

Decide one of these and tell me which:
- (a) the weekly log stands as written in `weekly_logs.md` and no dates are claimed anywhere else;
- (b) add real start/end dates so the log has a spine;
- (c) the log is a reconstruction and the report should say the work was summarised per week.

The weekly-log source rule in `weekly_logs.md` ("Do not add any activity, tool, or date that is not
written here") currently blocks (b).

### 3. Provenance of the codebase

The repository is a derivative of the open-source project **LiftLog by Liam Morrow** (AGPL v3).
Evidence: upstream README credits and store links, `LICENSE` is AGPL v3, `CONTRIBUTING.md` mentions
"contributions licensed AGPL v3", the GitHub remote is a personal fork (`Luke23-45/alcedo`), the app
slug and bundle id are still `liftlog` / `com.limajuice.liftlog`, and the .NET code in `backend/` and
`tests/` has only ever been touched by the initial import commit.

The first commit is titled "initial commit of Alcedo (by Power Gym)", so the repository itself records
the gym as the owner.

This has to be stated honestly somewhere in the report, because a reader can open the repository. The
question is where and how:
- as an existing codebase taken over and developed during the internship (the manager's decision),
- or as work started from the base and substantially extended.

**Which framing is true?** I will not choose this for you.

### 4. Who did the work

| Author identity | Commits |
|---|---|
| `krishna subedi <krishnasubedi2366@gmail.com>` | 17 |
| `Muse <muse@hatch.local>` / `Muse <muse@local>` | 32 |

The human identity is **Krishna Subedi** â€” the same name as the internship mentor in
`front_matter.md`, `company_information.md` and `internship_information.md`. The student is Tirshana
Subedi. Separately, `backend-v2/` (129 files) and `website/` (35 files) arrived in a **single commit**
(`ce8ef59`, "Final verification: backend-v2, website, and mobile auth hardening", +32,405 lines)
authored by the agent identity.

`role_and_responsibility.md` describes the intern's own work as frontend plus "basic backend
development and frontend-backend integration" covering User Management, Workout Management and
Feature Management. Those three map exactly onto `backend-v2/src/users`, `backend-v2/src/workouts` and
`backend-v2/src/features` + `site-config` â€” so the role description is technically consistent with
`backend-v2`.

But three things need your decision:
- Should the report claim backend work? If yes, at what granularity (modules contributed, endpoints,
  or the module as a whole)?
- `backend/` (the .NET API, 1010 files) and `tests/` (39 files) were never modified after import. Do
  not claim work on them.
- How should AI-assisted development be represented? 32 of 49 commits were authored by an agent
  identity, and `AGENTS.md`, `AGENTS.md`-driven rules and `.agents/skills/` are agent-facing contracts.
  `CONTRIBUTING.md` even has an AI usage policy. **Decide whether to disclose this**, and if so where.

I will write whatever you decide. I will not describe agent-assisted commits as hand-written work.

### 4b. How far does the backend claim go?

Verified: at `0ee0ebd` the app calls `backend-v2` for **authentication only**
(`auth-service.ts` â†’ `/api/auth/google|refresh|logout|me`), plus the generic
`authenticated-fetch.ts` wrapper and the account screen. No app code references `/api/sync/*`,
`/api/workouts`, `/api/users/me`, `/api/social/*`, `/api/billing/*` or `/api/ai/conversations*` â€”
the only occurrence of those paths is inside `authenticated-fetch.spec.ts`. Also,
`app/src/services/api-consts.ts` states the production value `https://api.alcedo.app/api`
"must be set to the deployed backend-v2 URL before release builds", so backend-v2 is not recorded as
deployed.

Decide the wording for section 3.4 and 3.3. Candidate framings:
- "designed and implemented backend modules, with the client integration completed for
  authentication and prepared for the remaining features";
- or describe only what is wired, and treat the rest as the organization's own work.

I will not write that sync, billing, social or the NestJS AI coach were integrated into the app.

## Needed for the front matter

### 5. Missing certificate page

The guidelines require three certificate pages:
(i) **Mentor's recommendation from the company**, (ii) supervisor's recommendation, (iii) examiners'
approval letter. `front.pdf` contains only (ii) and (iii). Need the text for the company mentor's
recommendation, and confirmation of who signs it.

### 6. Examiner names

The letter of approval has four signature blocks. Known: Mr. Chudamani Subedi (Program Director),
Mr. Gyaneshwor Dhungana (Internship Supervisor). **Internal Examiner and External Examiner names are
unknown.** The samples show `Bal Krishna Subedi` as external examiner, but that is another student's
report â€” do not copy it.

### 7. Page size / margin units

`docs/guidelines/guidelines.md` says "Top = 1; Bottom = 1; Right = 1; Left 1.25" with no unit.
Confirm inches (A4 is 210 Ã— 297 mm, so 1 inch = 2.54 cm; the left margin 1.25" = 3.175 cm matches
typical TU report templates).

### 8. `website/` and `site/` scope

Both exist and both are real deployments. `website/` is the Next.js app that talks to `backend-v2`;
`site/` is static marketing. Were either part of the internship? If only the mobile app was, they
should not appear in Chapter 3.

## Needed for accuracy, not blocking

### 9. Technology list in `data/project/github_repository.md`

The file lists React Native, Expo, TypeScript, Expo Router, and a literal placeholder
"[Other technologies used in the project]". Everything listed is correct. The list is incomplete â€” the
repository also contains NestJS, MongoDB/Mongoose, ASP.NET Core, EF Core, Redux Toolkit, SQLite with
Drizzle, styled-components, React Native Paper, Tolgee, SignalR, Stripe, Vitest, Jest, TUnit, Maestro,
oxlint/oxfmt, CSharpier and EAS.

**Confirm I may replace the placeholder** with a complete, accurate list. Also note the repo's own
`backend-v2/README.md` is out of date on three points (Stripe support, test-suite count, endpoint
table) â€” do not quote it.

### 10. Company details to verify

From `company_information.md`: Budibazar, Pokhara-26, Kaski; 5:00 AM â€“ 9:00 PM; phone 9846904440;
mentor Mr. Krishna Subedi; Facebook page "Power Gym Budibazar Pokhara" with about 1.7K followers. The
company logo and hierarchy diagram are already in `src/data/figures/`. Confirm the phone number and the
follower count are current, and confirm whether the gym has a website or email address worth adding.

### 11. Organization hierarchy figure

`src/data/figures/organization_hierarchy.png` already contains the caption "Figure 2.2: Organization
Hierarchy" inside the image. If the report adds the caption as text as well, the figure will show it
twice. Decide: keep the baked-in caption, or regenerate the image without it. My recommendation is to
regenerate it without the caption so the DOCX caption is consistent with every other figure.

### 12. Logo figure

`company_information.md` labels the logo "Figure 2.1" and the hierarchy "Figure 2.2", but the
guidelines' own sample numbers figures as "Figure 1", "Figure 2". Pick one scheme and apply it to
captions, the List of Figures and the text references.

### 13. Abstract and keywords

`front_matter.md` says to write the abstract after all chapters are done. Keywords should reflect the
real stack and the role: something like Mobile Application Development, React Native, Expo,
Expo Router, TypeScript, Redux Toolkit, SQLite, REST API Integration, Feature Flags, User Management,
Workout Management.

### 14. Typo in the weekly-log source file

`data/information/weekly_logs.md` line 22 ends with a stray `Qs` after the final observation
("...requires testing, cleanup, and feedback.``Qs``"). It must be deleted when the table is typeset.
This is the only defect in that file; the 12 rows and 4 columns are otherwise intact.

### 15. Stale prose inside the project repository

Do not quote these figures without re-checking; `19_verification_log.md` Â§3 lists each one.

| Claim in the repo | Reality |
|---|---|
| `AGENTS.md`: `theme.ts` is 857 lines | 947 lines |
| `AGENTS.md`: ~83 importers of the deprecated theme shims | an in-code comment said 147; neither is machine-checked â€” omit or say "about a hundred" |
| `docs/index.md`: tracker covers 20 pages | 24 pages |
| `README.md`: seven `docs/*.md` documents | all seven files are absent |
| `backend-v2/README.md`: "no Stripe by design", "12 suites" | Stripe implemented; 19 suites |
| `.github/` CI workflows | present on disk but **gitignored and untracked** (`.gitignore` line 21). Do not claim CI as a deliverable; the honest statement is that gates were run manually and recorded in commit messages and `docs/merge_ledger.md` |

### 16. Working tree is dirty

Branch `ui-polish` has 9 uncommitted modified files, including `app/package.json`,
`app/package-lock.json` and `app/src/services/auth-service.ts`. Anything written from the working
tree differs slightly from commit `0ee0ebd`. **Recommend committing or stashing before the report
quotes dependency versions**, so the appendix matches the repository a reader would clone.

## Verified and safe to use without asking

- Roll number format `79011927` appears on the cover page of the draft.
- Names: Tirshana Subedi (student), Mr. Gyaneshwor Dhungana (internship supervisor), Mr. Chudamani
  Subedi (program director), Mr. Krishna Subedi (internship mentor), Neeraj Tiwari (gym management).
- Campus: Prithvi Narayan Campus, Institute of Science and Technology, Tribhuvan University,
  Bhimkalipatan-1, Pokhara; B.Sc. CSIT; internship 12 weeks, Monday to Friday, 6 hours per day.
- Chapter structure and section numbering from `docs/guidelines/guidelines.md`.
- All technical facts in files 01â€“11 of this folder; each one cites the file path it came from.