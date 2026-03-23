Add-Type -AssemblyName System.Drawing

$scriptPath = $PSScriptRoot
if (-not $scriptPath) { $scriptPath = "." }
$srcPath    = Join-Path $scriptPath "69733609ad67d4001f48292a.png"
$outPath    = Join-Path $scriptPath "profile_card.png"
$readmePath = Join-Path $scriptPath "README.md"
$W = 900
$H = 520

# ===== BIO SECTION DYNAMICALLY PARSED FROM README ================
$bioLines = @("Hi, I'm @Cedric - Cedric MUNEZERO") # Fallback
$cWhite  = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255,230,237,243))
$cBlue   = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 88,166,255))
$cGreen  = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 86,211,100))
$bioColors = @($cBlue, $cWhite, $cWhite, $cGreen, $cWhite)

if (Test-Path $readmePath) {
    $content = Get-Content -Path $readmePath -Encoding UTF8 -Raw
    if ($content -match "(?s)<!-- BIO_START -->(.*?)<!-- BIO_END -->") {
        $rawBio = $matches[1]
        $lines = $rawBio -split "`n" | Where-Object { $_.Trim() -ne "" -and $_ -notmatch "^---" }
        $parsedLines = @()
        foreach ($l in $lines) {
            $cl = $l -replace '\*\*', ''
            $cl = $cl -replace '&nbsp;', ''
            $parsedLines += $cl.Trim()
        }
        if ($parsedLines.Count -gt 0) {
            $bioLines = $parsedLines
        }
    }
}

# 1. CALCULATE BIO HEIGHT
$yBioCalc = 40
for ($i = 0; $i -lt $bioLines.Count; $i++) {
    $yBioCalc += if ($i -eq 0) { 26 } else { 19 }
}
# Default space ended at ~146. If more bio lines, add to bioOffset.
$bioOffset = [int][math]::Max(0, $yBioCalc - 146)

# 2. CALCULATE STATS & LANGS HEIGHT
$statLabels = @("Total Stars Earned:", "Total Commits (last year):", "Total PRs:", "Total Issues:", "Contributed to (last year):")
$statVals   = @("6.7k", "474", "29", "9", "5")

# ===== FETCH DYNAMIC LANGUAGES FROM GITHUB ========================
$langs = @()
$pcts  = @()

try {
    $githubToken = $env:GITHUB_TOKEN
    $headers = @{
        "Accept" = "application/vnd.github.v3+json"
        "User-Agent" = "Cedrick250-Profile-Card"
    }
    if ($githubToken) {
        $headers["Authorization"] = "token $githubToken"
    }

    # Fetch repos for the user
    $reposUrl = "https://api.github.com/users/Cedrick250/repos?per_page=100&type=owner"
    $repos = Invoke-RestMethod -Uri $reposUrl -Headers $headers -ErrorAction Stop

    $langStats = @{}
    foreach ($repo in $repos) {
        if (-not $repo.fork -and $repo.languages_url) {
            $repoLangs = Invoke-RestMethod -Uri $repo.languages_url -Headers $headers -ErrorAction SilentlyContinue
            if ($repoLangs) {
                foreach ($prop in $repoLangs.psobject.properties) {
                    $langName = $prop.Name
                    $bytes = $prop.Value
                    if ($langStats.ContainsKey($langName)) {
                        $langStats[$langName] += $bytes
                    } else {
                        $langStats[$langName] = $bytes
                    }
                }
            }
        }
    }

    # Calculate total bytes
    $totalBytes = 0
    foreach ($val in $langStats.Values) {
        $totalBytes += $val
    }

    if ($totalBytes -gt 0) {
        # Sort and pick top 5
        $topLangs = $langStats.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 5
        foreach ($item in $topLangs) {
            $langs += $item.Name
            $pct = [math]::Round((($item.Value / $totalBytes) * 100), 1)
            $pcts += $pct
        }
    }
}
catch {
    Write-Host "Failed to fetch language data: $_"
}

# Fallback if no data was fetched or API rate limit hit
if ($langs.Count -eq 0) {
    $langs = @("Python", "C", "HTML", "C++", "JavaScript")
    $pcts  = @(50.0, 21.4, 14.3, 7.1, 7.1)
}

# Default had 5 items in stats/langs. If more are added, we push the bottom down further.
$maxListItems = [math]::Max($statLabels.Count, $langs.Count)
$listOffset = [int][math]::Max(0, ($maxListItems - 5) * 26)

# SET DYNAMIC CANVAS HEIGHT
$totalOffset = $bioOffset + $listOffset
$H = 520 + $totalOffset

# ===== CANVAS INIT ===============================================
$src = [System.Drawing.Image]::FromFile($srcPath)
$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g   = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode      = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint  = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$g.InterpolationMode  = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

# --- background ---
$g.DrawImage($src, 0, 0, $W, $H)
$overlay = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(200, 13, 17, 23))
$g.FillRectangle($overlay, 0, 0, $W, $H)

# --- colours ---
$cGold   = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255,255,166, 87))
$cPurple = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255,210,168,255))
$cGrey   = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255,139,148,158))
$pBorder = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(120, 48, 54, 61), 1)

$statColors = @($cGold, $cBlue, $cPurple, $cGold, $cGreen)

$lColRaw   = @(
    [System.Drawing.Color]::FromArgb(255, 53,114,165), # Python
    [System.Drawing.Color]::FromArgb(255, 85, 85, 85), # C
    [System.Drawing.Color]::FromArgb(255,227, 76, 38), # HTML
    [System.Drawing.Color]::FromArgb(255,243, 75,125), # C++
    [System.Drawing.Color]::FromArgb(255,241,224, 90)  # JS
)

# --- fonts ---
$fBig  = New-Object System.Drawing.Font("Segoe UI Emoji", 16, [System.Drawing.FontStyle]::Bold)
$fMedB = New-Object System.Drawing.Font("Segoe UI Emoji", 12, [System.Drawing.FontStyle]::Bold)
$fSm   = New-Object System.Drawing.Font("Segoe UI Emoji", 10)
$fSmB  = New-Object System.Drawing.Font("Segoe UI Emoji", 10, [System.Drawing.FontStyle]::Bold)
$fTiny = New-Object System.Drawing.Font("Segoe UI Emoji",  8)
$fGrd  = New-Object System.Drawing.Font("Segoe UI Emoji", 26, [System.Drawing.FontStyle]::Bold)
$fNum  = New-Object System.Drawing.Font("Segoe UI Emoji", 22, [System.Drawing.FontStyle]::Bold)

$sfC = New-Object System.Drawing.StringFormat
$sfC.Alignment     = [System.Drawing.StringAlignment]::Center
$sfC.LineAlignment = [System.Drawing.StringAlignment]::Center

# ===== HEADER ====================================================
$g.DrawString("Cedrick250 / README.md", $fSm, $cGrey, 24, 12)
$g.DrawLine($pBorder, 20, 34, $W-20, 34)

# ===== DRAW BIO ==================================================
# Note: we recalculate yBio for drawing
$yBio = 40
for ($i = 0; $i -lt $bioLines.Count; $i++) {
    $col = if ($i -lt $bioColors.Count) { $bioColors[$i] } else { $cWhite }
    $fnt = if ($i -eq 0) { $fBig } else { $fSm }
    $g.DrawString($bioLines[$i], $fnt, $col, 28, $yBio)
    $yBio += if ($i -eq 0) { 26 } else { 19 }
}

<<<<<<< HEAD
$div1Y = 162 + $bioOffset
$g.DrawLine($pBorder, 20, $div1Y, $W-20, $div1Y)
=======

$g.DrawLine($pBorder, 20, 162, $W-20, 162)
>>>>>>> 1e576ee957dda89f0f4ee40a98fef735dd845c2f

# ===== STATS SECTION HEADER ======================================
$statsY = 170 + $bioOffset
$g.DrawString("cedrick's GitHub Stats", $fMedB, $cWhite, 24, $statsY)

# ===== LEFT: STATS ===============================================
$startY = 194 + $bioOffset
for ($i = 0; $i -lt $statLabels.Count; $i++) {
    $yy = $startY + $i*24
    $g.DrawString($statLabels[$i], $fSm,  $cGrey,         24, $yy)
    if ($i -lt $statVals.Count) {
        $colorIndex = $i % $statColors.Count
        $g.DrawString($statVals[$i],   $fSmB, $statColors[$colorIndex], 238, $yy)
    }
}

# ===== CENTER: grade circle (A-) =================================
$cx = 430; $cy = 225 + $bioOffset; $r = 48
$penGrade = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 88,166,255), 5)
$g.DrawEllipse($penGrade, $cx-$r, $cy-$r, $r*2, $r*2)
$gradeRect = New-Object System.Drawing.RectangleF(($cx-$r), ($cy-$r), ($r*2), ($r*2))
$g.DrawString("A-", $fGrd, $cBlue, $gradeRect, $sfC)

# ===== RIGHT: language bars ======================================
$g.DrawString("Most Used Languages", $fMedB, $cWhite, 530, $statsY)

$barW = 270
$bgBar = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(80, 48, 54, 61))
for ($i = 0; $i -lt $langs.Count; $i++) {
    $yy = $startY + $i*26
    $g.DrawString($langs[$i], $fTiny, $cGrey, 530, $yy)
    $g.FillRectangle($bgBar, 530, ($yy+14), $barW, 7)
    $pct = if ($i -lt $pcts.Count) { $pcts[$i] } else { 0 }
    if ($pct -gt 0) {
        $filled = [int]([math]::Max(2, ($pct / 50.0 * $barW))) 
        $colIndex = $i % $lColRaw.Count
        $fgBar  = New-Object System.Drawing.SolidBrush($lColRaw[$colIndex])
        $g.FillRectangle($fgBar, 530, ($yy+14), $filled, 7)
    }
    $g.DrawString("$pct%", $fTiny, $cGrey, (530+$barW+4), ($yy+12))
}

$div2Y = 328 + $bioOffset + $listOffset
$g.DrawLine($pBorder, 20, $div2Y, $W-20, $div2Y)

# ===== CONTRIBUTION BOXES ========================================
$boxes = @(
    @{label="Total Contributions"; val="474"; sub="githubstats.com"; col=$cBlue},
    @{label="Current Streak";       val="1";   sub="day";            col=$cGold},
    @{label="Longest Streak";       val="11";  sub="days";           col=$cPurple}
)
$boxW = [int](($W - 60) / 3)
$boxH = 90
$boxY = 336 + $bioOffset + $listOffset

for ($i = 0; $i -lt 3; $i++) {
    $bx = 20 + $i * ($boxW + 10)
    # box background
    $boxBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(110, 22, 27, 34))
    $g.FillRectangle($boxBrush, $bx, $boxY, $boxW, $boxH)
    $penBox = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(80, 48, 54, 61), 1)
    $g.DrawRectangle($penBox, $bx, $boxY, $boxW, $boxH)
    # large number
    $numRect = New-Object System.Drawing.RectangleF($bx, $boxY, $boxW, 52)
    $g.DrawString($boxes[$i].val, $fNum, $boxes[$i].col, $numRect, $sfC)
    # label
    $lblRect = New-Object System.Drawing.RectangleF($bx, ($boxY+52), $boxW, 20)
    $g.DrawString($boxes[$i].label, $fTiny, $cGrey, $lblRect, $sfC)
    # sub text
    $subRect = New-Object System.Drawing.RectangleF($bx, ($boxY+68), $boxW, 18)
    $g.DrawString($boxes[$i].sub,   $fTiny, $cGrey, $subRect, $sfC)
}

# ===== DIVIDER + FOOTER ==========================================
$div3Y = 434 + $bioOffset + $listOffset
$g.DrawLine($pBorder, 20, $div3Y, $W-20, $div3Y)

# mini contribution dots (decorative heatmap)
$dotBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(80, 86,211,100))
$dotBrush2= New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(160, 86,211,100))
$rnd = New-Object System.Random(88) # Fixed seed to keep pattern consistent
for ($col2 = 0; $col2 -lt 52; $col2++) {
    for ($row2 = 0; $row2 -lt 5; $row2++) {
        $dx = 24 + $col2*16
        $dy = 444 + $bioOffset + $listOffset + $row2*12
        if ($dx -gt $W-30) { break }
        $v = $rnd.Next(0,5)
        if ($v -eq 0 -or $v -eq 1) { $g.FillRectangle($dotBrush, $dx, $dy, 11, 10) }
        elseif ($v -eq 2) { $g.FillRectangle($dotBrush2, $dx, $dy, 11, 10) }
        else {
            $lgtBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(30, 48, 54, 61))
            $g.FillRectangle($lgtBrush, $dx, $dy, 11, 10)
        }
    }
}

$footerY = 508 + $bioOffset + $listOffset
$g.DrawString("474 contributions in the last year  |  github.com/Cedrick250", $fTiny, $cGrey, 24, $footerY)

# ===== SAVE ======================================================
$g.Dispose()
$src.Dispose()
$bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Host "Card saved to: $outPath"
