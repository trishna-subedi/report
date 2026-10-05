# Implementation Plan — LaTeX Report Build

Plan for producing the internship report as a LaTeX project under `src/`.
Status: scaffold created and compiling. Content writing not started.

## 1. Goal and constraints

Produce `main.pdf` that satisfies `docs/guidelines/guidelines.md`, from content already verified in
`docs/project_detail/` and `data/information/`.

Hard constraints:

- Times New Roman 12 pt body, justified, 1.5 line spacing
- A4; margins top 1, bottom 1, right 1, left 1.25
- Headings bold: chapter 16 pt, section 14 pt, sub-section 12 pt
- Figures centred with the caption **below**; tables centred with the caption **above**; captions bold 12 pt
- Page numbers bottom centre: roman from the certificate page, arabic restarting at 1 from Chapter 1
- APA referencing
- Section order exactly as the guidelines prescribe

## 2. Verified toolchain

Checked on this machine, not assumed:

| Item | Status |
|---|---|
| MiKTeX | 25.12 (User: MiKTeX Utility 1.11) |
| Engines | `pdflatex`, `xelatex`, `lualatex` all present |
| Build driver | `latexmk` present; `bibtex` and `biber` present |
| Packages | `report.cls`, `geometry`, `fontspec`, `titlesec`, `caption`, `setspace`, `fancyhdr`, `natbib`, `longtable`, `booktabs`, `tabularx`, `enumitem`, `listings`, `microtype`, `hyperref`, `float`, `array` — **all found by `kpsewhich`** |
| Times New Roman | `C:\Windows\Fonts\times.ttf`, `timesbd.ttf`, `timesi.ttf` all present |
| PDF inspection tools | `pdfinfo`, `pdffonts`, `pdftotext`, `pdfimages` (MiKTeX bin) |

### Decisions forced by what is actually installed

Four things were tested by compiling, not guessed:

1. **`report` class has no `\frontmatter`/`\mainmatter`.** Those exist only in `book.cls`. Numbering
   switches must be written manually: `\pagenumbering{roman}` and
   `\clearpage\pagenumbering{arabic}\setcounter{page}{1}`.
2. **XeLaTeX + `fontspec` + `\setmainfont{Times New Roman}` works** and embeds real
   TimesNewRomanPSMT / BoldMT / ItalicMT (confirmed with `pdffonts`).
3. **`apacite` is broken in this installation** — `\citet` and `\citep` are undefined, and loading
   `natbib` alongside it crashes. **`biblatex-apa` is not installed.** Decision: use `natbib` with a
   hand-written `thebibliography` and hand-written APA labels. See §6.
4. `xcolor`, `tikz`, `pgfplots`, `tocloft`, `ragged2e`, `needspace`, `lastpage` are also available if
   a diagram or a page-number check is needed later.

## 3. Format specification mapped to LaTeX

| Guideline requirement | Implementation |
|---|---|
| Times New Roman | `fontspec`, `\setmainfont{Times New Roman}` (XeLaTeX) |
| 12 pt body | `\documentclass[12pt,a4paper,oneside]{report}` |
| A4, margins T1 B1 R1 L1.25 | `geometry` with `left=1.25in,right=1in,top=1in,bottom=1in` |
| Justified | LaTeX default; `\emergencystretch=3em` to stop ugly overfull lines; `indentfirst` so the first paragraph after a heading is indented |
| 1.5 line spacing | `setspace` with `\setstretch{1.43}` — Word's "1.5 lines" for Times New Roman 12 pt equals a 20.7 pt baseline, which is 1.43 × the LaTeX single baseline. **Note:** `\onehalfspacing` is only 1.25 and would look visibly tighter than Word. See open decision D2 |
| Chapter heading 16 pt bold, new page, centred | `titlesec`, `\titleformat{\chapter}[display]` |
| Section 14 pt bold, sub-section 12 pt bold | `titlesec` for `\section` and `\subsection` |
| Figure caption below, table caption above, both bold 12 pt | `caption` with `\DeclareCaptionFont{repcap}` and `\captionsetup[table]{position=top}` |
| Figure/table numbering `Figure 2.1`, `Table 3.1` | inherited from `report` (chapter-prefixed) — matches the guideline samples |
| Page number bottom centre | `fancyhdr`: `\fancyfoot[C]{\thepage}`, empty header rule |
| Cover page unnumbered | `titlepage` environment (sets `\thispagestyle{empty}`) |
| Roman then arabic numbering | manual `\pagenumbering` (see §2 item 1) |
| TOC, List of Figures, List of Tables | `\tableofcontents`, `\listoffigures`, `\listoftables` (need 2–3 passes; `latexmk` handles it) |
| List of Abbreviations | hand-built list in `front-matter/list-of-abbreviations.tex`, added to the TOC with `\addcontentsline` |
| APA references | `natbib` + `back-matter/references.tex` |
| Source code in appendices | `listings` with `breaklines`, small font |
| Long weekly-log table | `longtable` with `\endfirsthead`/`\endhead` so the header repeats across pages |

## 4. Project structure

```
src/
├── .gitignore                  ignores every generated LaTeX file
├── script/
│   └── build.ps1                the only build entry point
├── build/                       ALL generated output (git-ignored)
│   ├── main.pdf                 the report
│   └── main.aux .log .toc .lof .lot .out .xdv .fdb_latexmk .fls build.log
└── sections/                    the LaTeX root — main.tex lives here
    ├── main.tex                 master file: preamble + document skeleton
    ├── figures/                 images added later (app screenshots etc.)
    ├── front-matter/
    │   ├── cover.tex                        cover and title page
    │   ├── certificate-company-mentor.tex   Mentor's recommendation from the company  [TEXT MISSING]
    │   ├── certificate-supervisor.tex       Supervisor's Recommendation
    │   ├── letter-of-approval.tex           Letter of Approval, 4 signature blocks
    │   ├── declaration.tex                  Student's Declaration
    │   ├── acknowledgement.tex             Acknowledgement
    │   ├── abstract.tex                     Abstract + Keywords
    │   └── list-of-abbreviations.tex        List of Abbreviations
    ├── chapter01-introduction/chapter01.tex
    ├── chapter02-organization-and-literature-review/chapter02.tex
    ├── chapter03-internship-activities/chapter03.tex
    ├── chapter04-conclusion-and-learning-outcomes/chapter04.tex
    └── back-matter/
        ├── references.tex         APA reference list
        ├── bibliography.tex       Bibliography (optional)
        └── appendices.tex         Appendices
```

`main.tex` sits in `src/sections/`, so the build runs with the working directory set to `src/sections`.
`\input` and `\graphicspath` are resolved from there, which is why the image path is
`../data/figures/`:

```
\graphicspath{{figures/}{../data/figures/}}
```

`src/data/figures/` is therefore the single source of truth for the logo, hierarchy diagram, screen
image and university logo. High-resolution application screenshots are copied into
`src/sections/figures/`.

Each chapter directory holds exactly one file named after the chapter, containing `\chapter{...}`
followed by the mandated `\section`s, each pre-filled with a comment giving its content source and
any constraint that must not be violated.

## 5. Build

```powershell
cd src\script
.\build.ps1                 # build            -> src\build\main.pdf
.\build.ps1 -Clean          # clean aux files, then build
.\build.ps1 -Rebuild -Open  # full clean, build, open the PDF
.\build.ps1 -Watch          # rebuild on every save
.\build.ps1 -File x.tex     # build another entry file
.\build.ps1 -SkipChecks     # bypass the preflight checks
```

What the script does beyond calling latexmk:

- works from any working directory (it locates the project from its own path);
- writes every artefact into `src/build/`, so the source tree stays clean;
- **preflight**: resolves the entry file plus every `\input` transitively, and verifies every
  `\includegraphics` against the `\graphicspath` entries, so a moved or renamed file is reported
  before compiling;
- checks that `latexmk` and `xelatex` exist and explains what to install if not;
- captures the full console output in `src/build/build.log`;
- **fails the build** on a latexmk error, a missing PDF, any `!` error in the log, undefined
  references or citations, or a missing graphic — and prints the reason;
- prints the page count, page size and embedded fonts when the build succeeds.

Exit codes: `0` success · `1` build failed · `2` entry file missing · `3` BibTeX failed ·
`4` preflight failed · `127` toolchain missing.

Independent verification without the script:

```powershell
pdfinfo  src\build\main.pdf | Select-String 'Page size'   # expect A4 595 x 842 pt
pdffonts src\build\main.pdf                              # expect only TimesNewRomanPS* families
pdftotext src\build\main.pdf - | Select-String 'CHAPTER'
```

## 6. Citation convention (must be followed exactly)

`natbib` is loaded, but the reference list is written by hand. Every `\bibitem` carries an explicit
APA label, because that label is what appears in the text.

```latex
\bibitem[Frain (2022)]{frain2022}
Frain, B. (2022). \textit{Responsive web design with HTML5 and CSS} (4th ed.). New Riders.
```

Resulting in-text forms:

| Written as | Renders as |
|---|---|
| `\citep{frain2022}` | (Frain, 2022) |
| `\citet{frain2022}` | Frain (2022) |
| `\citep{abras2004}` | (Abras et al., 2004) |
| `\citet{abras2004}` | Abras et al. (2004) |

Rule: the optional label must be the **in-text** form — surname(s) plus year, `et al.` for three or
more authors. The full author list belongs in the entry text below it, never in the label. A test
compile confirmed this renders correctly.

## 7. Order of writing

Content must not be written before the blocking questions in
`docs/project_detail/12_open_questions_and_discrepancies.md` are answered (roll number, internship
dates, provenance, authorship, missing certificate page).

| Step | Target | Source of content |
|---|---|---|
| 1 | `back-matter/references.tex` (entries only, no prose yet) | real literature, APA verified |
| 2 | `front-matter/*` | existing text in `data/documents/front.pdf`, plus answers to open questions |
| 3 | `chapter01` | `data/information/*`, plus `project_detail/11_report_mapping.md` §2 |
| 4 | `chapter02` | `data/information/company_information.md`, `internship_information.md`; images already prepared |
| 5 | `chapter03` | `weekly_logs.md`, `role_and_responsibility.md`, `github_repository.md`, and `project_detail` files 03, 05, 08, 09, 13, 14 |
| 6 | `chapter04` | `role_and_responsibility.md` closing paragraph, `project_detail/01` §4 |
| 7 | `front-matter/abstract.tex` | written last, summarising Chapters 1–4 |
| 8 | Appendices | screenshots, repository link, listings |

## 8. Open format decisions

| # | Decision | Default applied | Needs |
|---|---|---|---|
| D1 | Margin units: the guideline gives "1" with no unit | inches | confirm; if centimetres, change the four values in `geometry` |
| D2 | Line spacing: `\setstretch{1.43}` (Word-equivalent 1.5) | 1.43 | confirm, or switch to `\onehalfspacing` |
| D3 | Paragraph indent | 0.5 in first line, no inter-paragraph space | confirm against the department template |
| D4 | Font size inside tables | 12 pt where it fits, `\small` (11 pt) for the long weekly log | confirm; guidelines only specify 12 pt for paragraphs and captions |
| D5 | Figure numbering | chapter-prefixed, `Figure 2.1` | `company_information.md` already uses this; the two samples use flat numbering |
| D6 | Hanging indent in the reference list | 0.5 in | standard APA, low risk |
| D7 | Whether `site/` and `website/` are mentioned | omitted from Chapter 3 | confirm they were in scope |

## 9. Guardrails

- No fact may enter the report that is not in `data/information/` or `docs/project_detail/`. If it is
  unknown, it stays a `TODO` comment, never a plausible sentence.
- The weekly log keeps its 12 rows and 4 columns; only grammar may be polished.
- `role_and_responsibility.md` states no role, tool or task may be added beyond what it lists.
- The report must not claim the mobile app integrates backend-v2 sync, billing, social or the NestJS
  AI coach: only authentication is wired. See `project_detail/05_backend_v2.md` §11.
- The .NET backend must not be presented as internship work; it was never modified after import.
- Every figure must be cited in the body text and listed in the List of Figures with identical wording.
- Delete the stray `Qs` typo at the end of `data/information/weekly_logs.md` when typing the table.

## 10. First build: verified output and the four defects that were found

The scaffold was compiled and inspected on this machine. Result: **19 pages, A4
(595.28 × 841.89 pt), only TimesNewRomanPSMT / BoldMT / ItalicMT embedded, zero errors, zero
overfull or underfull boxes, no undefined references.**

Page map produced by the build:

| Page | Content | Page label |
|---|---|---|
| 1 | Cover and title page | none (correct) |
| 2–5 | Company's mentor recommendation, supervisor's recommendation, letter of approval, student's declaration | i–iv |
| 6 | Acknowledgement | v |
| 7 | Abstract | vi |
| 8–9 | Table of contents | vii–viii |
| 10–12 | List of figures, list of tables, list of abbreviations | ix–xi |
| 13–16 | Chapters 1–4 | 1–4 |
| 17–19 | References, bibliography, appendices | 5–7 |

Margins measured from the generated PDF: left **1.25 in**, right **1.00 in**, top **1.05 in** on a
body page (the extra 0.05 in is the first-line baseline offset), page number **0.61 in** from the
bottom edge.

Four defects were found by building and were fixed:

1. **The cover overflowed onto a second page**, which then received a stray arabic page number.
   Fixed by setting `\setstretch{1.0}` inside the `titlepage` and tightening the vertical spacing.
   Re-check after every cover edit.
2. **`declaration.tex` had a stray `&` inside a one-column `tabular`**, producing five
   "Extra alignment tab" errors. Fixed by making it a two-column table.
3. **The References heading was silently lost.** `\begin{thebibliography}` issues its own chapter
   heading from `\bibname`, which collided with the manual `\chapter*{References}`, so the reference
   entries appeared under a "Bibliography" heading. Fixed by renaming:
   `\renewcommand{\bibname}{References}` and removing the manual chapter heading.
4. **`bibliography.tex` added a contents entry but never printed its heading**, so the section was
   in the table of contents but absent from the body. Fixed by adding `\chapter*{Bibliography}`.

Guard for the future: after any structural edit, rebuild and re-read the page map. The two heading
collisions in items 3 and 4 are the kind of mistake that compiles without error.

## 11. Build script hardening — bugs found by testing `src/script/build.ps1`

The script was written, then deliberately tested against failure cases. Six defects were found and
fixed; all of them produced wrong behaviour while still "looking" successful.

| # | Defect | Consequence | Fix |
|---|---|---|---|
| 1 | `$images.Count` on a scalar under `Set-StrictMode -Version Latest` | script crashed on the first run | every pipeline result that is counted is wrapped in `@()` |
| 2 | Non-greedy regex `\graphicspath\{(.+?)\}` | captured only `{figures/`, so image checks silently searched the wrong place | balanced-brace extraction via `Get-BracedContent` |
| 3 | Image preflight scanned **all** `.tex` files under `sections/` | building an alternative entry file produced false failures from unrelated files | resolve the entry file plus its `\input` graph recursively, with a cycle guard |
| 4 | `$ErrorActionPreference='Stop'` plus native tools writing to stderr | MiKTeX's update notice became a fake terminating `NativeCommandError` | `Invoke-Native` wrapper that relaxes the preference for the call and returns output plus exit code |
| 5 | `$undef.Count` on a single match | crash when exactly one undefined citation existed | wrapped in `@()` |
| 6 | `pdffonts` column 1 parsed instead of column 0 | reported `fonts: CID` instead of the font names | parse column 0 (`SUBSET+FONTNAME`) |

Tests run against the final script:

| Test | Expected | Result |
|---|---|---|
| Normal build | exit 0, 19 pages, A4, three Times New Roman faces | pass |
| LaTeX error in the entry file | build failed, error text reported, exit 1 | pass |
| Undefined `\ref` and `\citep` | reported, exit 1 | pass |
| Missing image | preflight failure, exit 4 | pass |
| Missing entry file | reported with the expected path, exit 2 | pass |
| Invoked from an unrelated directory (`C:\`) | identical successful build | pass |
| `-Clean` / `-Rebuild` | artefacts removed, PDF regenerated | pass |

Note for future edits: the `\graphicspath` in `main.tex` must stay
`{figures/}{../data/figures/}` while `main.tex` lives in `src/sections/`. The preflight check
fails loudly if the file is moved without updating it, which is the intended behaviour.