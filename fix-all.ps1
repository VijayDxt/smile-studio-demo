
# ===== SMILE STUDIO FIX SCRIPT =====
# Fixes all remaining issues before GitHub Pages deploy
$ErrorActionPreference = "Continue"
$dir = "d:\smile-studio"

Write-Host "=== FIXING HTML FILES ===" -ForegroundColor Cyan

# --- Fix 1: Fix CSS link path (space in filename) ---
Write-Host "Fix 1: Correcting CSS link paths..." -ForegroundColor Yellow
$htmlFiles = Get-ChildItem -Path $dir -Filter "*.html" -Recurse
foreach ($f in $htmlFiles) {
    $content = Get-Content $f.FullName -Raw -Encoding UTF8
    $orig = $content
    # Fix CSS link with space
    $content = $content -replace 'assets/css/Smile Studio\.css', 'assets/css/smile-studio.css'
    # Fix logo paths with space
    $content = $content -replace 'assets/img/Smile Studio-logo-dark\.svg', 'assets/img/smile-studio-logo-dark.svg'
    $content = $content -replace 'assets/img/Smile Studio-logo\.svg', 'assets/img/smile-studio-logo.svg'
    if ($content -ne $orig) {
        [System.IO.File]::WriteAllText($f.FullName, $content, [System.Text.Encoding]::UTF8)
        Write-Host "  Fixed paths in: $($f.Name)"
    }
}

# --- Fix 2: Fix broken function name "Smile StudioLead" ---
Write-Host "Fix 2: Fixing broken JS function name..." -ForegroundColor Yellow
foreach ($f in $htmlFiles) {
    $content = Get-Content $f.FullName -Raw -Encoding UTF8
    $orig = $content
    $content = $content -replace 'return Smile StudioLead\(event\)', 'return leadSubmit(event)'
    $content = $content -replace 'function Smile StudioLead\(', 'function leadSubmit('
    if ($content -ne $orig) {
        [System.IO.File]::WriteAllText($f.FullName, $content, [System.Text.Encoding]::UTF8)
        Write-Host "  Fixed function name in: $($f.Name)"
    }
}

# --- Fix 3: Download webfont.js locally and replace CDN references ---
Write-Host "Fix 3: Localizing WebFont loader..." -ForegroundColor Yellow
$webfontPath = "$dir\assets\js\webfont.js"
if (-not (Test-Path $webfontPath)) {
    try {
        Invoke-WebRequest -Uri "https://ajax.googleapis.com/ajax/libs/webfont/1.6.26/webfont.js" -OutFile $webfontPath -UseBasicParsing
        Write-Host "  Downloaded webfont.js"
    } catch {
        Write-Host "  WARNING: Could not download webfont.js - will use @import fallback" -ForegroundColor Red
    }
}

foreach ($f in $htmlFiles) {
    $content = Get-Content $f.FullName -Raw -Encoding UTF8
    $orig = $content
    # Replace remote webfont script with local
    $content = $content -replace 'https://ajax\.googleapis\.com/ajax/libs/webfont/1\.6\.26/webfont\.js', 'assets/js/webfont.js'
    if ($content -ne $orig) {
        [System.IO.File]::WriteAllText($f.FullName, $content, [System.Text.Encoding]::UTF8)
        Write-Host "  Localized webfont.js in: $($f.Name)"
    }
}

# --- Fix 4: Download Google Fonts CSS locally ---
Write-Host "Fix 4: Downloading Google Fonts Sora locally..." -ForegroundColor Yellow
$fontCssPath = "$dir\assets\css\fonts.css"
if (-not (Test-Path $fontCssPath)) {
    try {
        $fontUrl = "https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700&display=swap"
        $fontCss = Invoke-WebRequest -Uri $fontUrl -UseBasicParsing -Headers @{"User-Agent"="Mozilla/5.0"} | Select-Object -ExpandProperty Content
        # Find all font URLs and download them
        $fontUrls = [regex]::Matches($fontCss, "url\(([^)]+)\)") | ForEach-Object { $_.Groups[1].Value }
        $fontsDir = "$dir\assets\fonts"
        if (-not (Test-Path $fontsDir)) { New-Item -ItemType Directory -Path $fontsDir | Out-Null }
        foreach ($fUrl in $fontUrls) {
            $fUrl = $fUrl.Trim("'""")
            $fName = ($fUrl -split "/")[-1] -split "\?" | Select-Object -First 1
            if ($fName -notmatch "\.woff") { $fName = "sora-font-" + ([guid]::NewGuid().ToString().Substring(0,8)) + ".woff2" }
            $fPath = "$fontsDir\$fName"
            if (-not (Test-Path $fPath)) {
                try { Invoke-WebRequest -Uri $fUrl -OutFile $fPath -UseBasicParsing } catch {}
            }
            $fontCss = $fontCss -replace [regex]::Escape($fUrl), "../fonts/$fName"
        }
        [System.IO.File]::WriteAllText($fontCssPath, $fontCss, [System.Text.Encoding]::UTF8)
        Write-Host "  Saved local fonts.css"
    } catch {
        Write-Host "  WARNING: Font download failed: $_" -ForegroundColor Red
    }
}

# --- Fix 5: Replace Google Fonts preconnect + WebFont script with local font link ---
Write-Host "Fix 5: Replacing remote font references in HTML..." -ForegroundColor Yellow
if (Test-Path $fontCssPath) {
    foreach ($f in $htmlFiles) {
        $content = Get-Content $f.FullName -Raw -Encoding UTF8
        $orig = $content
        # Remove Google Fonts preconnect links
        $content = $content -replace '(?s)<link href="https://fonts\.googleapis\.com"[^>]*/>\s*', ''
        $content = $content -replace '(?s)<link href="https://fonts\.gstatic\.com"[^>]*/>\s*', ''
        # Add local fonts.css link after main CSS link if not present
        if ($content -notmatch 'fonts\.css') {
            $content = $content -replace '(<link href="assets/css/smile-studio\.css[^"]*"[^>]*/>\s*)', "`$1<link href=`"assets/css/fonts.css`" rel=`"stylesheet`" type=`"text/css`"/>`n        "
        }
        if ($content -ne $orig) {
            [System.IO.File]::WriteAllText($f.FullName, $content, [System.Text.Encoding]::UTF8)
            Write-Host "  Updated font references in: $($f.Name)"
        }
    }
}

# --- Fix 6: Strip any remaining filter:blur from inline styles ---
Write-Host "Fix 6: Stripping filter:blur from inline styles..." -ForegroundColor Yellow
foreach ($f in $htmlFiles) {
    $content = Get-Content $f.FullName -Raw -Encoding UTF8
    $orig = $content
    $content = $content -replace 'filter\s*:\s*blur\([^)]*\)\s*;?\s*', ''
    if ($content -ne $orig) {
        [System.IO.File]::WriteAllText($f.FullName, $content, [System.Text.Encoding]::UTF8)
        Write-Host "  Stripped blur in: $($f.Name)"
    }
}

# --- Fix 7: Remove any meta generator tags ---
Write-Host "Fix 7: Removing meta generator tags..." -ForegroundColor Yellow
foreach ($f in $htmlFiles) {
    $content = Get-Content $f.FullName -Raw -Encoding UTF8
    $orig = $content
    $content = $content -replace '(?i)<meta\s+name="generator"[^>]*/>\s*', ''
    if ($content -ne $orig) {
        [System.IO.File]::WriteAllText($f.FullName, $content, [System.Text.Encoding]::UTF8)
        Write-Host "  Removed generator meta in: $($f.Name)"
    }
}

# --- Fix 8: Verify safety net exists in all main pages ---
Write-Host "Fix 8: Checking safety net in all HTML files..." -ForegroundColor Yellow
foreach ($f in $htmlFiles) {
    $content = Get-Content $f.FullName -Raw -Encoding UTF8
    if ($content -notmatch "Safety net|safetyNet|force-shows") {
        Write-Host "  WARNING: $($f.Name) may be missing safety net" -ForegroundColor Red
    } else {
        Write-Host "  OK: $($f.Name) has safety net"
    }
}

# --- Final verification ---
Write-Host "`n=== VERIFICATION ===" -ForegroundColor Cyan
Write-Host "Checking for remaining issues..." -ForegroundColor Yellow

$issues = @()
foreach ($f in $htmlFiles) {
    $content = Get-Content $f.FullName -Raw -Encoding UTF8
    if ($content -match "Smile Studio\.css") { $issues += "$($f.Name): still has 'Smile Studio.css'" }
    if ($content -match "Smile StudioLead") { $issues += "$($f.Name): still has 'Smile StudioLead'" }
    if ($content -match "Smile Studio-logo") { $issues += "$($f.Name): still has 'Smile Studio-logo' with space" }
    if ($content -match "ajax\.googleapis\.com.*webfont") { $issues += "$($f.Name): still has remote webfont" }
    if ($content -match "lumora") { $issues += "$($f.Name): still has 'lumora'" }
    if ($content -match "smilifye") { $issues += "$($f.Name): still has 'smilifye'" }
}

if ($issues.Count -eq 0) {
    Write-Host "  ALL CLEAR - No remaining issues found!" -ForegroundColor Green
} else {
    Write-Host "  REMAINING ISSUES:" -ForegroundColor Red
    $issues | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
}

Write-Host "`n=== FIX SCRIPT COMPLETE ===" -ForegroundColor Green
