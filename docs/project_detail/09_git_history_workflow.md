# 09 — Git History, Branches and Working Method

## 1. Branches

| Branch | HEAD | Commits | Meaning |
|---|---|---|---|
| `main` | `ff62544` | 46 | Integration trunk, identical to `origin/main`; final state is "all branches merged to main" |
| `ui-polish` (checked out) | `0ee0ebd` | 48 | 2 commits ahead of `main`: the responsive/locale polish pass and onboarding design |
| `backup/main-before-merge` | `8491720` | 4 | Safety snapshot of `main` before the merge |
| `backup/redesign-backup-and-restore` | `f989506` | 36 | Safety snapshot of the redesign tip, including a superseded commit |
| `backup/verification-final` | `ce8ef59` | 36 | Safety snapshot of the deleted verification branch |
| `origin/redesign/backup-and-restore` | `e60ca88` | 39 | Left on the remote deliberately |

Deleted refs: `origin/verification/final-2026-09-22`, the local `redesign/backup-and-restore`, the
temporary `integrate/all-to-main`, and four `refs/cline/checkpoints/session_*` AI-tool checkpoints.

49 unique commits across all refs. 3,674 file touches, +364,888 / −15,475 lines.
Files at HEAD by directory: `app` 1437, `backend` 1010, `backend-v2` 129, `docs` 96, `tests` 39,
`website` 35, `assets` 28, `examples` 25, `site` 16, `scripts` 9, `plugins` 8, `.agents` 3.

## 2. Commit timeline — 2026-09-21 to 2026-09-23

| Date | Commits |
|---|---|
| 2026-09-21 | 17 |
| 2026-09-22 | 26 |
| 2026-09-23 | 6 |

First commit `2eeca0d` at 2026-09-21 14:55 +0545; last `0ee0ebd` at 2026-09-23 16:17 +0545.
**The entire recorded history spans about 49 hours.** See `12_open_questions_and_discrepancies.md`
item 2 for what this means for the report.

## 3. Authors

| Author | Commits |
|---|---|
| `krishna subedi <krishnasubedi2366@gmail.com>` | 17 |
| `Muse <muse@hatch.local>` | 31 |
| `Muse <muse@local>` | 1 |

Author equals committer on all commits. Two identity families are present: one human committer
identity, and an agent identity `Muse` responsible for 32 commits. The `muse@local` vs
`muse@hatch.local` split plus the `+0000` vs `+0545` timezone difference indicates the agent ran on a
differently configured host. `AGENTS.md` and `.agents/skills/` are the agent-facing contract files
that came in with the initial import.

## 4. Commits by phase (48 on `ui-polish`)

### Phase A — import and foundation (4 commits, 2026-09-21)
| Hash | Subject |
|---|---|
| `2eeca0d` | chore: initial commit of Alcedo (by Power Gym) — 1916 files, +228,928 lines |
| `f0da774` | docs(agents): standardise on styled-components and the section file layout |
| `cac2e7c` | feat(): home page design |
| `8491720` | feat(): .agent design |

### Phase B — redesign series and data hardening (3 commits)
| Hash | Subject |
|---|---|
| `36e3f3d` | redesign: backup & restore hub, remote backup, export, import — 719 files, +68,877 |
| `b9c4f24` | Redesign: /workout-editor three-canvas rebuild |
| `8c98c89` | SQLite hardening + privacy-first backup modes (Off/Automatic/Manual) |

### Phase C — page-by-page sweep, pages 1–19 (20 commits)
One commit per screen: design-spec fidelity fixes + new state/simulation tests + an update to
`docs/new_design/page-verification.md`.

| Hash | Page |
|---|---|
| `6af7be6` | Home (1/20) |
| `a4abc1b` | Replace crashing js-joda text patterns with cached Intl formatters |
| `ea17ca6` | Workout flow (2/20) |
| `4fcf71f` | Workout editor (3/20) |
| `d72769f` | Exercise editor (4/20) |
| `661297d` | Diff-save (5/20) |
| `a3d5316` | History (6/20) |
| `fa32ca5` | Trends (7/20) |
| `05af681` | Feed timeline (8/20) |
| `a2263b2` | Feed post detail (9/20) |
| `975a2f1` | Feed share composer (10/20) |
| `39793ec` | Feed profile editor (11/20) |
| `3fde478` | Feed shared item (12/20) |
| `716b65b` | Settings home (13/20) |
| `9ddd0f5` | Preferences (14/20) |
| `24f0e6f` | Notifications (15/20) |
| `04bfb5c` | Settings AI planner (16/20) |
| `28334c3` | Settings programs and import (17/20) |
| `89a8975` | Backup hub and child routes (18/20) |
| `ed8c261` | What's New (19/20) |

### Phase D — tracker expansion to 24 pages and shared design work (9 commits)
| Hash | Subject |
|---|---|
| `43e9080` | Exercise search (page 21/24) |
| `cb2c61b` | Tracker: expand to 24 pages (route-tree sweep) |
| `fd30b12` | Exercise history (22/24) |
| `20a88e6` | Manage exercises (23/24) |
| `c9ad2c6` | AI planner chat (24/24) |
| `ed71521` | Custom bottom tab bar icon system (5 glyphs, outline + filled) |
| `4c5e476` | Redesign backend editor and AI planner chat to Apple-inspired designs |
| `af29a5e` | Feed fallback catalog and AI planner offline greeting |
| `ce8ef59` | Final verification: backend-v2, website, and mobile auth hardening — 183 files, +32,405 |

### Phase E — branch merge programme (10 commits)
| Hash | Subject |
|---|---|
| `f18b748` | render fix (post-amend of `f989506`, drops `error.md`) |
| `82bb2a2` | docs: add all-branches merge ledger (source of truth) |
| `e94107e` | wip: homepage polish + staged renames before all-branch merge |
| `e60ca88` | docs: record Phase 0-1 merge execution log |
| `2bedab1` | **merge(all)**: redesign + verification/final-2026-09-22 into main line — the only merge commit |
| `d6bd7d9` | fix: close Fragment correctly in WeeklyChallengeSection (TS1003) |
| `951b0c7` | fix: annotate video setup callback; drop unsupported role on gradient badge |
| `c9b428c` | chore: reconcile backend-v2 lockfile with fresh install (dedupe nested mongoose deps) |
| `83b1f55` | docs: record Phase 2-3 merge execution log and gate evidence |
| `ff62544` | docs: close merge ledger - all branches merged to main |

### Phase F — polish and onboarding (2 commits, `ui-polish` only)
| Hash | Subject |
|---|---|
| `4273851` | polish: apple-grade responsive + locale pass across all 24 pages — 328 files, +6,193 |
| `0ee0ebd` | feat(): onboarding design — HEAD |

### Only reachable through `backup/*`
`f989506` render fix (original, superseded by `f18b748`, contained `error.md`);
`9cf1a97` merge ledger (orphaned by a `git reset --soft`, visible only in the HEAD reflog).

## 5. Where the work went

| Directory | Commits touching it |
|---|---|
| `docs/` | 39 (34 of them `docs/new_design/`) |
| `app/src/` | 39 |
| `app/` outside `src` | 7 |
| `backend-v2/` | 2 (wholesale in `ce8ef59`, then a lockfile fix) |
| `website/` | 1 (wholesale in `ce8ef59`) |
| `backend/` (C#) | 1 — the initial import only, never modified |
| `tests/` (.NET) | 1 — the initial import only |

Largest commits: `2eeca0d` (1916 files, +228,928), `36e3f3d` (719 files, +68,877),
`4273851` (328 files, +6,193), `ce8ef59` (183 files, +32,405).

## 6. The merge programme

`2bedab1` is the only merge commit. It merged `redesign/backup-and-restore` (36 commits) and
`verification/final-2026-09-22` (1 commit, `ce8ef59`) into `main`, executed with `--no-ff` on a
temporary `integrate/all-to-main` branch and landed by fast-forward.

`docs/merge_ledger.md` is the record of that programme and is the single most useful document for
describing engineering process:

- branch inventory table with full SHAs, topology and merge-base proof;
- file-set overlap analysis between the branches;
- hazard register **H1–H6**;
- five phases (0 safety → 1 triage → 2 dry run → 3 real merge → 4 land and clean) in PowerShell;
- rejected alternatives (rebase, squash, direct merge) with reasons;
- a rollback procedure;
- a dated execution log with one documented **incident** (a staged-index amend trap) and its recovery;
- open decisions escalated to an "owner".

Offline safety artefacts live outside the repository in
`C:\Users\Hellx\Documents\Programming\python\Project\personal\LiftLog-merge-backup-2026-09-22\`:
`backup-2026-09-22.bundle` (26.6 MB), `worktree-unstaged.patch`, `worktree-staged.patch`, and 12
untracked files.

## 7. Tags and releases

No tags and no release branches. Release tooling exists (`scripts/create-release.ts`,
`scripts/get-release-notes.ts`, `scripts/release-plan-builder-skill.ts`,
`scripts/collect-screenshots.ts`) but nothing was cut in git.

## 8. Working tree state at review time

Branch `ui-polish` has 9 uncommitted modified files: `app/package.json`,
`app/package-lock.json`, four `*.styles.ts` files (planner-chat, backend-header-editor,
connection-card, header-sheet, type-switch-dialog), `app/src/services/auth-service.ts`,
`app/src/services/tolgee.ts`. None of this is committed.

## 9. Commit message conventions observed

Human commits use Conventional-Commits prefixes (`chore:`, `docs:`, `docs(agents):`, `feat():`,
`fix:`, `polish:`, `wip:`, `merge(all):`). Agent commits use free-form subjects (`redesign:`,
`Redesign:`, `SQLite hardening…`, `Final verification:…`, `render fix`). Substance lives in the body:
concrete fixes with paths, a `Tests:` line with a running full-suite tally, gate results, and explicit
statements of what is *not* claimed. The three post-merge `fix:`/`chore:`/`docs:` commits have no
bodies because that detail was moved into `docs/merge_ledger.md`.