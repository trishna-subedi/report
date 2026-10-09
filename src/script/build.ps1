<#
.SYNOPSIS
    Build the internship report (XeLaTeX + latexmk).

.DESCRIPTION
    Robust build driver for the report.

        src/
          sections/     <- LaTeX root; main.tex lives here
          build/        <- every generated artefact lands here
          script/       <- this script

    What it does, and why:
      * Compiles with the working directory set to the LaTeX root
        (src/sections), because \input and \graphicspath are resolved
        relative to it. The script can be run from anywhere.
      * Writes the PDF and all auxiliary files into src/build via
        latexmk -outdir, so the source tree never collects junk.
      * Preflight checks before compiling: the entry file must exist, every
        \input target must exist, and every \includegraphics must resolve
        against the \graphicspath entries. A moved or renamed file therefore
        produces a clear message instead of a silently broken PDF.
      * Checks the toolchain and fails with an actionable message.
      * Captures the full console output in src/build/build.log.
      * Fails on: latexmk error, missing PDF, LaTeX errors in the log,
        undefined references/citations, or missing image files.

.PARAMETER File
    Entry file relative to the LaTeX root. Default: main.tex

.PARAMETER Clean
    Run latexmk -c before building (removes aux files, keeps the PDF).

.PARAMETER Rebuild
    Run latexmk -C before building (also removes the PDF and more).

.PARAMETER Watch
    Recompile on every save until Ctrl+C.

.PARAMETER Bib
    Run BibTeX between passes. Only needed if the reference list ever moves
    to a .bib file; with the hand-written thebibliography it is not required.

.PARAMETER Open
    Open the PDF when the build succeeds.

.PARAMETER SkipChecks
    Skip the preflight file checks (for debugging only).

.EXAMPLE
    .\build.ps1
    Builds src/sections/main.tex into src/build/main.pdf.

.EXAMPLE
    .\build.ps1 -Rebuild -Open

.EXAMPLE
    .\build.ps1 -File _errortest.tex
    Builds another entry file. Used to prove that failures are detected.
#>
[CmdletBinding()]
param(
    [string]$File = 'main.tex',
    [switch]$Clean,
    [switch]$Rebuild,
    [switch]$Watch,
    [switch]$Bib,
    [switch]$Open,
    [switch]$SkipChecks
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Layout
# ---------------------------------------------------------------------------
$scriptDir = Split-Path -Parent $PSScriptRoot   # .../src/script
$texRoot   = Join-Path $scriptDir 'sections'     # LaTeX root (main.tex here)
$buildDir  = Join-Path $scriptDir 'build'        # output directory
$logFile   = Join-Path $buildDir 'build.log'

function Write-Step { param([string]$m) Write-Host "==> $m" -ForegroundColor Cyan }
function Write-Ok   { param([string]$m) Write-Host "    $m" -ForegroundColor Green }
function Write-Bad  { param([string]$m) Write-Host "    $m" -ForegroundColor Red }
function Write-Info { param([string]$m) Write-Host "    $m" -ForegroundColor DarkGray }

# Extract the balanced brace group that follows the first occurrence of a
# marker, e.g. Get-BracedContent $text '\graphicspath' on
# "\graphicspath{{a/}{b/}}" returns "a/}{b/}".
# A plain regex cannot do this: \graphicspath{(.*)} swallows everything up to
# the last brace on the line, including unrelated \begin{document} groups.
function Get-BracedContent {
    param([string]$Text, [string]$Marker)
    $idx = $Text.IndexOf($Marker)
    if ($idx -lt 0) { return $null }
    $open = $Text.IndexOf('{', $idx)
    if ($open -lt 0) { return $null }
    $depth = 0
    $sb = New-Object System.Text.StringBuilder
    for ($i = $open; $i -lt $Text.Length; $i++) {
        $c = $Text[$i]
        if ($c -eq '{') {
            $depth++
            if ($depth -eq 1) { continue }
        }
        elseif ($c -eq '}') {
            $depth--
            if ($depth -eq 0) { break }
        }
        $null = $sb.Append($c)
    }
    return $sb.ToString()
}

<#
    Run a native executable and capture its output safely.

    PowerShell 5.1 turns any native stderr output into an ErrorRecord, and with
    $ErrorActionPreference = 'Stop' that becomes a terminating error even
    though the tool succeeded. MiKTeX always writes an update notice to
    stderr, so every call must go through here.
#>
function Invoke-Native {
    param(
        [Parameter(Mandatory)] [string]$Exe,
        [string[]]$Arguments = @()
    )
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $out = & $Exe @Arguments 2>&1
        $code = $LASTEXITCODE
        return [pscustomobject]@{
            Output   = @($out | ForEach-Object { $_.ToString() })
            ExitCode = $code
        }
    }
    finally {
        $ErrorActionPreference = $prev
    }
}

# Strip MiKTeX's update nag and console-codepage notices from captured output.
function Remove-Noise {
    param([string[]]$Lines)
    return @($Lines | Where-Object {
        $_ -notmatch 'not checked for MiKTeX updates' -and
        $_ -notmatch 'Reverting Windows console CPs'
    })
}

# ---------------------------------------------------------------------------
# 1. Toolchain
# ---------------------------------------------------------------------------
foreach ($tool in @('latexmk', 'xelatex')) {
    if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
        Write-Bad "'$tool' not found on PATH."
        Write-Bad 'Install MiKTeX (https://miktex.org) or add its bin\ directory to PATH,'
        Write-Bad 'then reopen the shell.'
        exit 127
    }
}
foreach ($tool in @('pdfinfo', 'pdffonts')) {
    if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
        Write-Info "'$tool' not found - that check will be skipped (MiKTeX ships both)."
    }
}

# ---------------------------------------------------------------------------
# 2. Entry file
# ---------------------------------------------------------------------------
$entry = Join-Path $texRoot $File
if (-not (Test-Path -LiteralPath $entry)) {
    Write-Bad "Entry file not found: $entry"
    Write-Bad "Expected it in the LaTeX root: $texRoot"
    exit 2
}
$baseName = [IO.Path]::GetFileNameWithoutExtension($File)

# ---------------------------------------------------------------------------
# 3. Preflight — catch moved or missing files before spending time compiling
#
#    Only the files that are ACTUALLY part of this build are examined: the
#    entry file plus everything it \input's, resolved recursively. Scanning
#    the whole directory would report false failures when building an
#    alternative entry file (for example a test file).
# ---------------------------------------------------------------------------
$preflightErrors = @()
if (-not $SkipChecks) {
    $fileSet   = New-Object System.Collections.Generic.List[string]
    $visited   = @{}

    function Add-TexFile {
        param([string]$Path, [string]$From)
        $full = (Resolve-Path -LiteralPath $Path -ErrorAction SilentlyContinue)
        if (-not $full) {
            $script:preflightErrors += "missing file reached from ${From}: $Path"
            return
        }
        $full = $full.ProviderPath
        if ($visited.ContainsKey($full)) { return }   # cycle guard
        $visited[$full] = $true
        $fileSet.Add($full)

        $text = Get-Content -LiteralPath $full -Raw
        foreach ($m in [regex]::Matches($text, '\\input\{([^}]+)\}')) {
            $child = Join-Path $texRoot ($m.Groups[1].Value + '.tex')
            if (Test-Path -LiteralPath $child) {
                Add-TexFile -Path $child -From ([IO.Path]::GetFileName($full))
            }
            else {
                $script:preflightErrors += "\input{$($m.Groups[1].Value)} in $([IO.Path]::GetFileName($full)) -> not found: $child"
            }
        }
    }
    Add-TexFile -Path $entry -From $File

    # graphicspath may live in the entry file or any file it inputs (the
    # preamble is \input from ../config/), so search the whole graph. Parsed
    # with balanced braces so unrelated braces later on the line cannot
    # corrupt the result; only brace groups that look like directory entries
    # (they end with a slash) count, so a stray mention of the command in a
    # comment cannot clobber the real path list. The last definition wins,
    # as in LaTeX.
    $gpDirs = @()
    foreach ($f in $fileSet) {
        $inner = Get-BracedContent -Text (Get-Content -LiteralPath $f -Raw) -Marker '\graphicspath'
        if ($inner -and $inner -match '\{[^{}]*/\}') {
            $gpDirs = @([regex]::Matches($inner, '\{([^{}]+)\}') |
                        ForEach-Object { $_.Groups[1].Value.Trim().TrimEnd('/') } |
                        Where-Object { $_ -ne '' })
        }
    }

    # simple macros (\newcommand{\LogoFile}{tu_logo.png}) used in image paths
    $macros = @{}
    foreach ($f in $fileSet) {
        foreach ($m in [regex]::Matches((Get-Content -LiteralPath $f -Raw),
                 '\\newcommand\{?(\\[A-Za-z@]+)\}?\s*\{([^{}]*)\}')) {
            $macros[$m.Groups[1].Value] = $m.Groups[2].Value
        }
    }

    # images referenced by the files in this build only
    $images = @($fileSet | ForEach-Object {
        [regex]::Matches((Get-Content -LiteralPath $_ -Raw),
                         '\\includegraphics(?:\[[^\]]*\])?\{([^}]+)\}')
    } | ForEach-Object { $_.Groups[1].Value })

    foreach ($img in @($images | Sort-Object -Unique)) {
        $resolved = $img
        foreach ($k in $macros.Keys) {
            if ($resolved.Contains($k)) { $resolved = $resolved.Replace($k, $macros[$k]) }
        }
        $found = $false
        foreach ($d in @('.') + $gpDirs) {
            if (Test-Path -LiteralPath (Join-Path $texRoot (Join-Path $d $resolved))) { $found = $true; break }
        }
        if (-not $found) {
            $preflightErrors += "image not found: $resolved  (from $img)  (searched . and: $($gpDirs -join ', '))"
        }
    }
    if ($images.Count -gt 0) {
        Write-Info "$($fileSet.Count) source file(s), $($images.Count) image reference(s) checked against {$($gpDirs -join ',')}"
    }
    else {
        Write-Info "$($fileSet.Count) source file(s) checked, no image references"
    }

    if ($preflightErrors.Count -gt 0) {
        Write-Host ''
        Write-Bad "PREFLIGHT FAILED ($($preflightErrors.Count) problem(s)):"
        foreach ($e in ($preflightErrors | Select-Object -First 15)) { Write-Bad "  - $e" }
        Write-Bad 'Fix the paths, or run with -SkipChecks to compile anyway.'
        exit 4
    }
}

# ---------------------------------------------------------------------------
# 4. Output directory
# ---------------------------------------------------------------------------
if (-not (Test-Path -LiteralPath $buildDir)) {
    New-Item -ItemType Directory -Path $buildDir -Force | Out-Null
    Write-Ok "created $buildDir"
}
$outDirArg = '-outdir=../build'     # relative to the LaTeX root

# ---------------------------------------------------------------------------
# 5. Build
# ---------------------------------------------------------------------------
Push-Location $texRoot
try {
    if ($Clean -or $Rebuild) {
        $mode = if ($Rebuild) { '-C' } else { '-c' }
        Write-Step "Cleaning (latexmk $mode)"
        $null = Invoke-Native -Exe 'latexmk' -Arguments @($mode, $outDirArg, $File)
        Remove-Item -LiteralPath (Join-Path $buildDir "$baseName.pdf") -Force -ErrorAction SilentlyContinue
    }

    $args = @('-xelatex', '-interaction=nonstopmode')
    if ($Watch) { $args += '-watch' }
    $args += $outDirArg
    $args += $File

    if ($Watch) {
        Write-Step 'Watching for changes (Ctrl+C to stop)'
        $prevWatch = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        try {
            & latexmk @args 2>&1 | Tee-Object -FilePath $logFile
        }
        finally { $ErrorActionPreference = $prevWatch }
        return
    }

    Write-Step "Building $File  (xelatex -> build\)"
    $started = Get-Date
    $res = Invoke-Native -Exe 'latexmk' -Arguments $args
    $code = $res.ExitCode
    $secs = [int]((Get-Date) - $started).TotalSeconds

    # keep MiKTeX's update nag out of the readable output, keep everything in the log
    $lines = Remove-Noise -Lines $res.Output

    if ($Bib -and $code -eq 0) {
        Write-Step 'Running BibTeX'
        $bibRes = Invoke-Native -Exe 'bibtex' -Arguments @('build', $baseName)
        $lines += (Remove-Noise -Lines $bibRes.Output)
        if ($bibRes.ExitCode -ne 0) {
            Set-Content -LiteralPath $logFile -Value ($lines -join "`r`n") -Encoding UTF8
            Write-Bad "BibTeX failed (exit $($bibRes.ExitCode)). Full output: $logFile"
            exit 3
        }
        $more = Invoke-Native -Exe 'latexmk' -Arguments @('-xelatex', '-interaction=nonstopmode', $outDirArg, $File)
        $lines += (Remove-Noise -Lines $more.Output)
        $code = $more.ExitCode
    }

    Set-Content -LiteralPath $logFile -Value ($lines -join "`r`n") -Encoding UTF8
    Write-Info "finished in ${secs}s; full output: $logFile"

    # -----------------------------------------------------------------------
    # 6. Verify the result
    # -----------------------------------------------------------------------
    $problems = @()
    if ($code -ne 0) { $problems += "latexmk exited with code $code" }

    $pdfPath = Join-Path $buildDir "$baseName.pdf"
    if (-not (Test-Path -LiteralPath $pdfPath)) { $problems += "no PDF at $pdfPath" }

    $texLog = Join-Path $buildDir "$baseName.log"
    if (Test-Path -LiteralPath $texLog) {
        $tl = Get-Content -LiteralPath $texLog

        for ($i = 0; $i -lt $tl.Count; $i++) {
            if ($tl[$i] -match '^\!\s') {
                $msg = if (($i + 1) -lt $tl.Count) { $tl[$i + 1].Trim() } else { $tl[$i].Trim() }
                if ($msg -and $msg -notmatch '^$') { $problems += "LaTeX: $msg" }
            }
        }
        $undef = @($tl | Where-Object { $_ -match 'LaTeX Warning: (Reference|Citation).*undefined' })
        if ($undef.Count -gt 0) {
            $problems += "$($undef.Count) undefined reference/citation(s) - add the \label or \bibitem, then rebuild"
        }
        $noimg = @($tl | Where-Object { $_ -match 'Cannot find image|Cannot determine size of graphic' })
        foreach ($n in $noimg) {
            $problems += "missing graphic: $($n.Trim())"
        }
        $boxes = @($tl | Where-Object { $_ -match '^(Overfull|Underfull) \\hbox' })
        if ($boxes.Count -gt 0) { Write-Info "$($boxes.Count) overfull/underfull box warning(s) in $texLog" }
    }

    if ($problems.Count -gt 0) {
        Write-Host ''
        Write-Bad "BUILD FAILED ($($problems.Count) problem(s)):"
        foreach ($p in ($problems | Select-Object -Unique -First 12)) { Write-Bad "  - $p" }
        Write-Bad "full output: $logFile"
        exit 1
    }

    Write-Host ''
    Write-Ok "BUILD OK  ->  $pdfPath"
    if (Get-Command pdfinfo -ErrorAction SilentlyContinue) {
        (Remove-Noise -Lines (Invoke-Native -Exe 'pdfinfo' -Arguments @($pdfPath)).Output) |
            Where-Object { $_ -match '^(Pages|Page size)' } |
            ForEach-Object { Write-Info $_.Trim() }
    }
    if (Get-Command pdffonts -ErrorAction SilentlyContinue) {
        # column 0 is "SUBSET+FONTNAME", column 1 is the font type
        $names = @((Invoke-Native -Exe 'pdffonts' -Arguments @($pdfPath)).Output |
                   Select-Object -Skip 2 |
                   ForEach-Object { ($_.Trim() -split '\s+')[0] } |
                   Where-Object { $_ } | Sort-Object -Unique)
        if ($names.Count -gt 0) { Write-Info ('fonts: ' + ($names -join ', ')) }
    }
    Write-Info "log: $logFile"

    if ($Open) { Start-Process -FilePath $pdfPath }
}
finally {
    Pop-Location
}