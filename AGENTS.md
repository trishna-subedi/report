# AGENTS.md — working rules for this repository

This repository produces **one deliverable**: the LaTeX internship report for the Mobile
Application Developer internship at Power Gym Budibazar Pokhara (Tribhuvan University, Institute
of Science and Technology, Prithvi Narayan Campus).

Read this file before changing anything. It records the rules that are easy to break and expensive
to discover late.

---

## 1. Layout

```
report/
├── AGENTS.md                    this file — the working contract
├── data/                        INPUT, never edited except where stated
│   ├── documents/front.pdf      the existing Word draft (source of the front matter text)
│   ├── information/             company, internship, role, weekly log, front matter
│   └── project/                 repository description
├── docs/
│   ├── guidelines/guidelines.md INTERNAL UNIVERSITY GUIDELINE — the format specification
│   ├── project_detail/          20 verified files describing the project repository
│   │   └── README.md            index; start here before re-reading anything
│   └── imp/plan.md              LaTeX implementation plan, format decisions, build history
└── src/
    ├── .gitignore               ignores all generated LaTeX files
    ├── script/build.ps1         the only build entry point
    ├── build/                   ALL generated output, including main.pdf (git-ignored)
    ├── data/figures/            the four prepared images (logo, hierarchy, screen, TU logo)
    └── sections/                the LaTeX root — main.tex lives here
        ├── main.tex             preamble + document skeleton
        ├── figures/             images added later
        ├── front-matter/        8 files
        ├── chapter01-introduction/chapter01.tex
        ├── chapter02-organization-and-literature-review/chapter02.tex
        ├── chapter03-internship-activities/chapter03.tex
        ├── chapter04-conclusion-and-learning-outcomes/chapter04.tex
        └── back-matter/         references, bibliography, appendices
```

The project source code being described lives outside this repository, at
`C:\Users\Hellx\Documents\Programming\python\Project\personal\LiftLog` (branch `ui-polish`, HEAD
`0ee0ebd`). **Do not re-read it to answer a question** — `docs/project_detail/` already records
everything needed, including what is *not* in the project and what remains uncertain.

### What we are writing, and what already exists

**The front matter is already written.** It exists as the approved draft at
`data/documents/front.pdf` (5 pages: cover and title page, Supervisor's Recommendation, Letter of
Approval, Student's Declaration, Acknowledgement), and `data/information/front_matter.md` lists the
signatories. Together they are the source of truth for all front matter wording.

**The layout source of truth is `docs/zz/Internship_Report_Tirshana_Subedi.docx`** (the same
approved draft in Word form). The front matter was transcribed and tuned to be pixel-perfect to it
— every word within 2 pt. Do not re-tune front-matter spacing without re-running the measurement
(`docs/imp/plan.md` §13 records the method and the traps).

Therefore **the work in `src/sections/` is the main contents — Chapters 1 to 4 — plus the
Appendices.** The files in `src/sections/front-matter/` exist for one reason only: the guideline
requires those pages in the submitted PDF, so they are a *verbatim transcription* of `front.pdf`.
Do not rewrite them, extend them, improve them, or invent any new front matter content. The only
two exceptions are flagged as missing: the Mentor's Recommendation from the Company (required by
the guideline, absent from `front.pdf`) and the Abstract, which the source itself defers until the
chapters are finished.

In short: **front matter = already done, transcribe only. Chapters and appendices = the work.**

---

## 2. Golden rules

1. **Never invent a fact.** Every statement must trace to `data/information/`,
   `data/documents/front.pdf`, or a verified file in `docs/project_detail/`. If the value is unknown,
   leave a `TODO` comment naming the question. A plausible sentence is worse than a gap.
2. **Never silently change approved text.** The front matter wording comes from `front.pdf` /
   `docs/zz/Internship_Report_Tirshana_Subedi.docx` and `front_matter.md`, which say to use it
   exactly. Polish grammar elsewhere; do not rewrite names, titles, roll numbers or signatory
   roles.
3. **Ask before assuming.** The open questions in §9 are unresolved on purpose. Guessing any of them
   puts incorrect information into a submitted academic document.
4. **Build after every structural change** and read the page map (§4). Some LaTeX mistakes compile
   cleanly and are invisible until you look.
5. **Do not commit generated files.** `src/build/` is ignored. Only sources are committed.

---

## 3. Report structure — fixed by the guideline

Do not reorder, rename or merge these. Source: `docs/guidelines/guidelines.md`.

Front matter: the cover and the four certificate pages are **unnumbered**; roman numerals start at
i on the Acknowledgement (deliberate decision confirmed by the author — do not "correct" this to
start at the certificate page):

| Order | Page | File |
|---|---|---|
| — | Cover and title page | `front-matter/cover.tex` |
| — | Mentor's recommendation from the company | `front-matter/certificate-company-mentor.tex` |
| — | Supervisor's recommendation | `front-matter/certificate-supervisor.tex` |
| — | Letter of approval | `front-matter/letter-of-approval.tex` |
| — | Student's declaration | `front-matter/declaration.tex` |
| i | Acknowledgement | `front-matter/acknowledgement.tex` |
| ii | Abstract | `front-matter/abstract.tex` |
| iii | Table of contents | auto |
| iv | List of figures | auto |
| v | List of tables | auto |
| vi | List of abbreviations | `front-matter/list-of-abbreviations.tex` |

Main matter, arabic restarting at 1:

| Chapter | Sections |
|---|---|
| 1 Introduction | 1.1 Introduction · 1.2 Problem Statement · 1.3 Objectives · 1.4 Scope and Limitation (1.4.1 Scope, 1.4.2 Limitations) · 1.5 Report Organization |
| 2 Organization Details and Literature Review | 2.1 Introduction to Organization · 2.2 Organizational Hierarchy · 2.3 Working Domains · 2.4 Description of Intern Department/Unit · 2.5 Literature Review |
| 3 Internship Activities | 3.1 Roles and Responsibilities · 3.2 Weekly Log · 3.3 Description of the Project(s) · 3.4 Tasks/Activities Performed |
| 4 Conclusion and Learning Outcomes | 4.1 Conclusion · 4.2 Learning Outcome |

Back matter continues the arabic numbering: References, Bibliography (optional), Appendices.

Note the Chapter 3 order: **the weekly log comes before the project description**, as the guideline
prescribes. Sample 1 in `docs/samples/` uses a different order — it is a sample, not the rule.

---

## 4. Build and verify

```powershell
cd src\script
.\build.ps1                 # -> src\build\main.pdf
.\build.ps1 -Rebuild -Open  # full clean, build, open
.\build.ps1 -Watch          # rebuild on save
```

The script refuses to produce a silently broken PDF. It checks the toolchain, resolves the entry
file and its whole `\input` graph, verifies every image path, and fails on LaTeX errors, undefined
references or citations, and missing graphics. Exit codes: `0` ok, `1` build failed, `2` entry file
missing, `3` BibTeX failed, `4` preflight failed, `127` toolchain missing.

After any structural change, confirm the page map is still correct:

```powershell
cd src\sections
1..N | ForEach-Object { (pdftotext -f $_ -l $_ -layout ..\build\main.pdf - |
  Where-Object { $_.Trim() } | Select-Object -First 1) }
```

Expected: cover and the four certificate pages unnumbered → roman i–vi starting at the
Acknowledgement (Acknowledgement = i … List of abbreviations = vi) → Chapters 1–4 numbered 1–4 →
References, Bibliography, Appendices continuing the arabic sequence.

---

## 5. Format specification — already enforced in `main.tex`

Do not re-implement any of this; change it only deliberately, and record why in
`docs/imp/plan.md`.

| Requirement | Implementation |
|---|---|
| Times New Roman 12 pt | `fontspec` + `\setmainfont{Times New Roman}`, XeLaTeX |
| A4, margins T1 B1 R1 L1.25 in | `geometry` |
| Justified, 1.5 spacing | LaTeX default + `\setstretch{1.43}` (Word-equivalent 1.5) |
| Chapter 16 pt, section 14 pt, sub-section 12 pt, all bold | `titlesec` |
| Figure caption below, table caption above, both bold 12 pt, centred | `caption` + `\DeclareCaptionFont{repcap}` |
| Page number bottom centre | `fancyhdr` |
| Cover unnumbered, roman then arabic | `titlepage` + manual `\pagenumbering` |

Verified on the current build: A4 595.28 × 841.89 pt, only TimesNewRomanPSMT/BoldMT/ItalicMT
embedded, left margin 1.25 in, page number 0.61 in from the bottom edge.

Citation system: `natbib` with a **hand-written** `thebibliography` in
`back-matter/references.tex`. `apacite` is broken in this MiKTeX installation and `biblatex-apa` is
not installed — do not "fix" this by switching to them without re-testing.

---

## 6. Writing rules

- **Language**: US spelling, matching the approved draft (`fulfillment`, not `fulfilment`).
- **Prose**: paragraphs are justified with a 0.5 in first-line indent and no space between
  paragraphs. Do not add blank lines between paragraphs to fake spacing.
- **Abbreviations**: add to `front-matter/list-of-abbreviations.tex` only if actually used, strictly
  alphabetical. Candidates with verified expansions are in
  `docs/project_detail/16_glossary_and_abbreviations.md`.
- **Citations**: APA 7th. Every `\bibitem` needs an explicit in-text label written as `\bibitem[Surname,
  Year]{key}` — e.g. `\bibitem[Parveen, 2012]{parveen2012}`. Do **not** write the label as
  `Surname (Year)`: the natbib in this MiKTeX installation then keeps the space before the
  parenthesis and every citation prints as `(Parveen , 2012)` instead of `(Parveen, 2012)`
  (verified by compiling both forms). Three or more authors use `et al.` in the label. Full details
  in `docs/imp/plan.md` §6.
- **Figures**: caption below, centred, bold 12 pt, cited in the body text before it appears, and
  listed in the List of Figures with identical wording. Images resolve through
  `\graphicspath{{figures/}{../data/figures/}}`; put new screenshots in `src/sections/figures/`.
- **Tables**: caption above, centred, bold 12 pt. The weekly log needs `longtable` with a repeating
  header.
- **Appendices** use `\appendix`, so their sections letter as A, B, C while chapters stay 1–4.

---

## 7. Content sources — which file feeds which section

| Section | Authoritative source |
|---|---|
| 1.1, 1.2, 1.5 | `data/information/company_information.md`, `docs/project_detail/11_report_mapping.md` |
| 1.3 | `data/information/role_and_responsibility.md` |
| 1.4 | `docs/project_detail/08`, `09` (limitations and gaps) |
| 2.1–2.4 | `data/information/company_information.md`, `internship_information.md` |
| 2.5 | external literature only — real, checkable APA sources |
| 3.1 | `data/information/role_and_responsibility.md` |
| 3.2 | `data/information/weekly_logs.md` |
| 3.3 | `docs/project_detail/01_project_overview.md`, `13_architecture_and_data_flow.md` |
| 3.4 | `docs/project_detail/03`, `05`, `08`, `09`, `13`, `14` |
| 4.1, 4.2 | `role_and_responsibility.md` closing paragraph, `docs/project_detail/01` §4 |
| Abstract | written last, summarising Chapters 1–4 |
| References | the same sources cited in the text, nothing more |

`docs/project_detail/11_report_mapping.md` is the full mapping, including which claim belongs in
which subsection.

---

## 8. Traps — these were all discovered by checking, not by assumption

1. **`report` class has no `\frontmatter`/`\mainmatter`.** Numbering switches are manual in
   `main.tex`. Do not "simplify" by adding them; they will fail.
2. **`\begin{thebibliography}` emits its own heading** from `\bibname`. Never add a manual
   `\chapter*{References}` next to it — the heading silently disappears and the entries appear under
   "Bibliography". `references.tex` uses `\renewcommand{\bibname}{References}` instead.
3. **`\graphicspath` depends on the directory depth.** `main.tex` is in `src/sections/`, so the path
   to the report images is `../data/figures/`. The build script's preflight fails loudly if this
   drifts — it did exactly that when the images were moved.
4. **The cover must fit on one page.** If it spills, the second page receives a stray page number.
   After editing `cover.tex`, check that page 2 begins with the certificate page.
5. **`data/information/weekly_logs.md` ends with a stray `Qs`** on the last row. Delete it when
   typing the table.
6. **The roll number is inconsistent** in the existing draft: `79011927` on the cover, `79011` in
   the acknowledgement. See §9.
7. **`organization_hierarchy.png` already contains its caption** inside the image. Adding a LaTeX
   caption duplicates it. Regenerate the image without the caption, or omit the caption.
8. **There is no CI.** `.github/` exists on disk in the project repository but is gitignored there.
   Never claim continuous integration as a deliverable; the honest statement is that gates were run
   manually and recorded in commit messages and the project's merge ledger.

---

## 9. Open questions — never guess these

Each is documented with context in `docs/project_detail/12_open_questions_and_discrepancies.md`.

1. **Roll number** — `front_matter.md` marks it `[CONFIRM: 79011927 ]`; the draft disagrees with
   itself. Use the confirmed value on the cover, the declaration and the acknowledgement, or
   nowhere.
2. **Internship dates** — the data says July–September, 12 weeks; the project repository's entire
   git history spans 49 hours (2026-09-21 to 2026-09-23). The weekly log cannot be dated from the
   repository.
3. **Provenance** — the project repository is a derivative of the open-source project LiftLog by
   Liam Morrow (AGPL v3). Its first commit reads "initial commit of Alcedo (by Power Gym)". The
   report must not imply the codebase was written from scratch. Decide how this is stated.
4. **Authorship** — 17 commits carry a human git identity, 32 an agent identity. The intern's
   backend work is real, but decide what is claimed about it and whether AI-assisted development is
   disclosed.
5. **Integration scope** — at the reviewed commit the mobile app calls the NestJS backend for
   **authentication only**. Sync, billing, social and AI endpoints exist server-side but have no
   caller in the app. Never claim otherwise.
6. **Neryva collaboration** — confirmed by the author (9 Oct 2026): Neryva (https://neryva.com) is
   a software company engaged by Power Gym Budibazar Pokhara, the client. The Alcedo application
   is developed at Neryva Lab. **Mr. Krishna Subedi is Neryva's Senior Software Engineer and the
   internship mentor. He is not Power Gym staff**, so never write "company mentor" of Power Gym
   and never call him a Power Gym employee. Tirshana Subedi is the intern *at Power Gym*, the host
   organization. Her project work is carried out at Neryva Lab. No Neryva address, logo or staff
   list is known, so do not invent one. Page 2 uses the Neryva emblem letterhead (author
   decision, Oct 2026; art in src/data/figures/neryva_logo.svg, rendered PNG alongside it).
   Do not replace it with the campus header or Power Gym branding.
7. **Company mentor's recommendation** — RESOLVED (Oct 2026): the page was absent from
   `front.pdf`, so the wording was written from `data/information/` facts only, and the author
   confirmed the signatory as **Mr. Krishna Subedi, Internship Mentor**. Source of every claim is
   recorded in the header comment of `certificate-company-mentor.tex`.
8. **Internal and external examiner names** — unknown. Do not copy them from
   `docs/samples/sample 1.docx` or `sample 2.pdf`; those are other students' reports.
9. **Margin units and line spacing** — the guideline states "1" without units and "1.5" spacing.
   Inches and Word-equivalent 1.5 are applied; confirm with the department.
10. **Whether `website/` and `site/` are in scope** — omitted from Chapter 3 until confirmed.

---

## 10. Definition of done

A change is complete when:

- `.\build.ps1` exits 0 and reports the expected page count, A4, and only Times New Roman faces;
- the page map is still correct (§4);
- `build.log` and `main.log` contain no `!` errors and no undefined reference or citation;
- every new fact is traceable to a source in §7, or is marked `TODO`;
- figures are cited in the text and appear in the List of Figures;
- no generated file is staged by git;
- anything decided or discovered along the way is written down in `docs/imp/plan.md` (format and
  build) or `docs/project_detail/` (project facts), never only in a chat message.

## 11. Documentation map

| Need | Read |
|---|---|
| What the project is, what it contains, what is uncertain | `docs/project_detail/README.md` then the numbered files |
| Which repository evidence supports which report section | `docs/project_detail/11_report_mapping.md` |
| How to cite, format, build; and what broke before | `docs/imp/plan.md` |
| What the university requires | `docs/guidelines/guidelines.md` |
| Front matter wording | `data/documents/front.pdf`, `data/information/front_matter.md` |
| Front matter layout (pixel-perfect target) | `docs/zz/Internship_Report_Tirshana_Subedi.docx`, `docs/imp/plan.md` §13 |