Yes. Replace your existing **Mentor’s Recommendation** page with a modern, full-page certificate design.

This version:

- keeps **only the Neryva emblem** at the top;
- keeps the page **unnumbered**;
- uses your existing macros, so the factual content stays controlled by your report data;
- places the **mentor signature block on the left**;
- adds a **PowerGym official stamp section** on the right;
- uses a modern double frame, gold accent rule, clean typography, and a professional stamp placeholder.

Compile **twice** so TikZ can resolve the page coordinates.

---

## 1. Add this to the preamble

Add these lines **once** in the preamble.

```latex
% =====================================================================
% Modern Mentor's Recommendation certificate design
% =====================================================================
\usepackage{tikz}
\usetikzlibrary{calc}
\usepackage{eso-pic}

% Certificate colours
\providecolor{certNavy}{RGB}{15,36,64}
\providecolor{certGold}{RGB}{176,138,58}
\providecolor{certInk}{RGB}{32,38,48}
\providecolor{certSlate}{RGB}{84,94,105}

% Exact wording used in the official stamp section.
% Currently set to PowerGym as requested.
% If the officially registered spelling is two words, change only this:
%   Power Gym
\providecommand*{\OfficialStampName}{PowerGym}
\renewcommand*{\OfficialStampName}{PowerGym}

% Official stamp placeholder
\providecommand*{\OfficialStampPlaceholder}{%
  \begin{tikzpicture}[baseline=-1.125cm]
    \node[
      draw=certSlate!80,
      line width=0.8pt,
      dash pattern=on 2.4pt off 2.0pt,
      rounded corners=4pt,
      minimum width=3.35cm,
      minimum height=2.25cm,
      inner sep=0pt
    ] (stampbox) {};
    \draw[
      certSlate!35,
      line width=0.4pt,
      rounded corners=2.8pt
    ]
      ($(stampbox.north west)+(0.15cm,-0.15cm)$)
      rectangle
      ($(stampbox.south east)+(-0.15cm,0.15cm)$);
  \end{tikzpicture}%
}
```

---

## 2. Replace your current Mentor’s Recommendation page with this

Place this where the page should appear.

```latex
% =====================================================================
% Mentor's Recommendation from the Company
% Modern professional certificate layout.
% Mentor/signature on the left, PowerGym official stamp section on right.
% This page is unnumbered.
% =====================================================================
\clearpage
\thispagestyle{empty}

% Page frame drawn as background
\AddToShipoutPictureBG*{%
  \begin{tikzpicture}[remember picture,overlay]
    \coordinate (OuterNW) at ($(current page.north west)+(1.02cm,-1.02cm)$);
    \coordinate (OuterSE) at ($(current page.south east)+(-1.02cm,1.02cm)$);
    \coordinate (InnerNW) at ($(OuterNW)+(0.23cm,-0.23cm)$);
    \coordinate (InnerSE) at ($(OuterSE)+(-0.23cm,0.23cm)$);

    \draw[
      certNavy,
      line width=1.25pt,
      rounded corners=8pt
    ] (OuterNW) rectangle (OuterSE);

    \draw[
      certGold,
      line width=0.55pt,
      rounded corners=6pt
    ] (InnerNW) rectangle (InnerSE);
  \end{tikzpicture}%
}

\noindent
\begin{tikzpicture}[remember picture,overlay]
  \node[inner sep=0] at (current page.center) {%
    \begin{minipage}[t][{\dimexpr\paperheight-3.05cm\relax}][s]%
      {\dimexpr\paperwidth-3.55cm\relax}
      \centering
      \color{certInk}
      \renewcommand{\baselinestretch}{1}

      % ---------------------------------------------------------------
      % Header: only the Neryva emblem, no company/campus text
      % ---------------------------------------------------------------
      \vspace*{0.55cm}
      \includegraphics[width=1.28in]{neryva_logo.png}\par
      \vspace{16pt}

      {\sffamily\bfseries\fontsize{17.5}{20.5}\selectfont
        \color{certNavy}%
        \MakeUppercase{Mentor's Recommendation}\par}
      \vspace{9pt}

      {\color{certGold}\rule{3.8cm}{1.05pt}}\par
      \vspace{26pt}

      % ---------------------------------------------------------------
      % Certificate body
      % ---------------------------------------------------------------
      \begin{minipage}[t]{0.945\linewidth}
        \fontsize{10.85}{16.2}\selectfont
        \setlength{\parindent}{0pt}
        \setlength{\leftskip}{0pt}
        \setlength{\rightskip}{0pt}
        \setlength{\parfillskip}{0pt plus 1fil}
        \setlength{\emergencystretch}{1.5em}

        This is to certify that Ms.~\ReportAuthor{}, a student of the
        \ProgramName{} program at \CampusFullName{}, \UniversityName{},
        has successfully completed a twelve-week internship at
        \CompanyName{} as a \InternPosition{} in the Digitalization Unit.

        \par\vspace{12pt}

        During the internship, she worked under my guidance on Alcedo,
        the mobile application developed at \WorkLocation{} for
        \CompanyName{}. Her responsibilities included implementing the
        user interface and navigation of the application; connecting the
        implemented screens with the backend services for User Management,
        Workout Management, and Feature Management; integrating the
        application's feature flags; and testing and correcting the
        implemented screens and functionalities. She also coordinated with
        the gym management, trainers, and front-desk staff to collect the
        information required for the application.

        \par\vspace{12pt}

        She has completed the assigned duties to our satisfaction and has
        carried out her work with sincerity and professionalism. I recommend
        this report for final evaluation and wish her success in her future
        academic and professional career.
      \end{minipage}

      \vfill

      % Thin divider before signature/stamp area
      {\color{certGold!55}\rule{0.945\linewidth}{0.45pt}}\par
      \vspace{16pt}

      % ---------------------------------------------------------------
      % Mentor on the left, official stamp section on the right
      % ---------------------------------------------------------------
      \begin{minipage}[b]{0.945\linewidth}
        \noindent
        \begin{minipage}[b]{0.58\linewidth}
          \raggedright
          {\color{certSlate}\rule{0.82\linewidth}{0.9pt}}\\[7pt]
          {\sffamily\bfseries\fontsize{12}{14.5}\selectfont
            \CompanyMentorTitle{} \CompanyMentor{}}\\[3pt]
          {\fontsize{10.7}{13.2}\selectfont
            \color{certSlate}%
            \CompanyMentorRole{}, \CompanyMentorOrg{}}
        \end{minipage}%
        \hfill
        \begin{minipage}[b]{0.36\linewidth}
          \centering
          \OfficialStampPlaceholder{}\\[6pt]
          {\sffamily\bfseries\fontsize{9.4}{11.6}\selectfont
            \color{certSlate}%
            \OfficialStampName{} Official Stamp}
        \end{minipage}
      \end{minipage}

      \vspace*{0.55cm}
    \end{minipage}%
  };
\end{tikzpicture}
\null
\clearpage
```

---

## Important notes

1. **Compile twice**  
   Because the design uses absolute page positioning, compile with XeLaTeX twice.

2. **Stamp wording is controlled by one command**  
   In the preamble code, this line controls the stamp text:

   ```latex
   \renewcommand*{\OfficialStampName}{PowerGym}
   ```

   If the exact official spelling should be two words, change only that line to:

   ```latex
   \renewcommand*{\OfficialStampName}{Power Gym}
   ```

3. **No facts are changed**  
   The body text still uses your existing macros:
   `\ReportAuthor`, `\ProgramName`, `\CampusFullName`, `\UniversityName`,
   `\CompanyName`, `\InternPosition`, `\WorkLocation`,
   `\CompanyMentorTitle`, `\CompanyMentor`, `\CompanyMentorRole`,
   and `\CompanyMentorOrg`.

4. **Page numbering**  
   The page uses `\thispagestyle{empty}`, so it remains unnumbered.