
Add-Type -AssemblyName System.Drawing

$srcPath  = "c:\Users\MUNEZERO\Downloads\readme git\69733609ad67d4001f48292a.png"
$outPath  = "c:\Users\MUNEZERO\Downloads\readme git\profile_card.png"
$W = 900; $H = 520

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
$cWhite  = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255,230,237,243))
$cBlue   = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 88,166,255))
$cGreen  = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 86,211,100))
$cGold   = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255,255,166, 87))
$cPurple = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255,210,168,255))
$cGrey   = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255,139,148,158))
$pBorder = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(120, 48, 54, 61), 1)

# --- fonts ---
$fBig  = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$fMedB = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$fSm   = New-Object System.Drawing.Font("Segoe UI", 10)
$fSmB  = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$fTiny = New-Object System.Drawing.Font("Segoe UI",  8)
$fGrd  = New-Object System.Drawing.Font("Segoe UI", 26, [System.Drawing.FontStyle]::Bold)
$fNum  = New-Object System.Drawing.Font("Segoe UI", 22, [System.Drawing.FontStyle]::Bold)

# centered StringFormat
$sfC = New-Object System.Drawing.StringFormat
$sfC.Alignment     = [System.Drawing.StringAlignment]::Center
$sfC.LineAlignment = [System.Drawing.StringAlignment]::Center

# ===== HEADER ====================================================
$g.DrawString("Cedrick250 / README.md", $fSm, $cGrey, 24, 12)
$g.DrawLine($pBorder, 20, 34, $W-20, 34)

# ===== BIO =======================================================
$g.DrawString("Hi, I'm @Cedrick250  -  Cedric MUNEZERO", $fBig, $cBlue, 24, 42)
$bio = @(
    "Passionate about cybersecurity, IT operations & digital transformation",
    "Hands-on: tech support, threat detection, system maintenance & cloud computing",
    "Exploring Docker & Kubernetes | Currently learning Golang",
    "Open to: ethical IT solutions, secure infrastructure & technical innovation"
)
$bioColors = @($cWhite, $cWhite, $cGreen, $cWhite)
for ($i = 0; $i -lt $bio.Count; $i++) {
    $g.DrawString($bio[$i], $fSm, $bioColors[$i], 28, 72 + $i*20)
}

$g.DrawLine($pBorder, 20, 162, $W-20, 162)

# ===== STATS SECTION HEADER ======================================
$g.DrawString("cedrick's GitHub Stats", $fMedB, $cWhite, 24, 170)

# ===== LEFT: stat list ===========================================
$statLabels = @("Total Stars Earned:", "Total Commits (last year):", "Total PRs:", "Total Issues:", "Contributed to (last year):")
$statVals   = @("1", "46", "1", "0", "0")
$statColors = @($cGold, $cBlue, $cPurple, $cGold, $cGreen)
for ($i = 0; $i -lt 5; $i++) {
    $yy = 194 + $i*24
    $g.DrawString($statLabels[$i], $fSm,  $cGrey,         24, $yy)
    $g.DrawString($statVals[$i],   $fSmB, $statColors[$i], 238, $yy)
}

# ===== CENTER: grade circle ======================================
$cx = 430; $cy = 225; $r = 48
$penGrade = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 88,166,255), 5)
$g.DrawEllipse($penGrade, $cx-$r, $cy-$r, $r*2, $r*2)
$gradeRect = New-Object System.Drawing.RectangleF(($cx-$r), ($cy-$r), ($r*2), ($r*2))
$g.DrawString("A-", $fGrd, $cBlue, $gradeRect, $sfC)

# ===== RIGHT: language bars ======================================
$g.DrawString("Most Used Languages", $fMedB, $cWhite, 530, 170)
$langs     = @("Jupyter Notebook", "Go", "HTML", "Shell", "Python")
$pcts      = @(39.63, 2.84, 0.12, 0.06, 0.01)
$lColRaw   = @(
    [System.Drawing.Color]::FromArgb(255,218,123, 26),
    [System.Drawing.Color]::FromArgb(255,  0,173,216),
    [System.Drawing.Color]::FromArgb(255,227, 76, 38),
    [System.Drawing.Color]::FromArgb(255,137,224,158),
    [System.Drawing.Color]::FromArgb(255, 53,114,165)
)
$barW = 270
$bgBar = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(80, 48, 54, 61))
for ($i = 0; $i -lt 5; $i++) {
    $yy = 194 + $i*26
    $g.DrawString($langs[$i], $fTiny, $cGrey, 530, $yy)
    $g.FillRectangle($bgBar, 530, ($yy+14), $barW, 7)
    $filled = [int]([math]::Max(2, ($pcts[$i] / 40.0 * $barW)))
    $fgBar  = New-Object System.Drawing.SolidBrush($lColRaw[$i])
    $g.FillRectangle($fgBar, 530, ($yy+14), $filled, 7)
    $g.DrawString("$($pcts[$i])%", $fTiny, $cGrey, (530+$barW+4), ($yy+12))
}

$g.DrawLine($pBorder, 20, 328, $W-20, 328)

# ===== CONTRIBUTION BOXES ========================================
$boxes = @(
    @{label="Total Contributions"; val="56";  sub="Aug 22, 2018 - Present"; col=$cBlue},
    @{label="Week Streak";          val="1";   sub="Mar 15";                 col=$cGold},
    @{label="Longest Week Streak";  val="1";   sub="Aug 19, 2018";          col=$cPurple}
)
$boxW = [int](($W - 60) / 3)
$boxH = 90
$boxY = 336
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
    # sub date
    $subRect = New-Object System.Drawing.RectangleF($bx, ($boxY+68), $boxW, 18)
    $g.DrawString($boxes[$i].sub,   $fTiny, $cGrey, $subRect, $sfC)
}

# ===== DIVIDER + FOOTER ==========================================
$g.DrawLine($pBorder, 20, 434, $W-20, 434)

# mini contribution dots (decorative)
$dotBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(80, 86,211,100))
$dotBrush2= New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(160, 86,211,100))
$rnd = New-Object System.Random(42)
for ($col2 = 0; $col2 -lt 52; $col2++) {
    for ($row2 = 0; $row2 -lt 5; $row2++) {
        $dx = 24 + $col2*16
        $dy = 444 + $row2*12
        if ($dx -gt $W-30) { break }
        $v = $rnd.Next(0,4)
        if ($v -eq 0) { $g.FillRectangle($dotBrush, $dx, $dy, 11, 10) }
        elseif ($v -ge 2) { $g.FillRectangle($dotBrush2, $dx, $dy, 11, 10) }
        else {
            $lgtBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(30, 48, 54, 61))
            $g.FillRectangle($lgtBrush, $dx, $dy, 11, 10)
        }
    }
}

$g.DrawString("56 contributions in the last year  |  github.com/Cedrick250", $fTiny, $cGrey, 24, 508)

# ===== SAVE ======================================================
$g.Dispose()
$src.Dispose()
$bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Host "Card saved: $outPath"
