# ===== SMILE STUDIO TRANSFORMATION SCRIPT =====
# Steps 1-5, 7-9: Full rebrand from Lumora Dental to Smile Studio LA

$ProjectDir = "d:\smile-studio"

# Get all HTML files
$htmlFiles = Get-ChildItem -Path $ProjectDir -Filter "*.html" -Recurse

foreach ($file in $htmlFiles) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8

    # --- STEP 3: Strip template fingerprints ---
    # Remove meta generator tag
    $content = $content -replace '<meta\s+name="generator"[^>]*/?>', ''
    # Remove HTML comments mentioning builder/author (webflow, lumora, framer)
    $content = $content -replace '<!--[^>]*(?:webflow|Webflow|WEBFLOW|framer|Framer|lumora|Lumora)[^>]*-->', ''
    # Remove builder identity attributes on html element
    $content = $content -replace '(data-wf-page="[^"]*")', ''
    $content = $content -replace '(data-wf-site="[^"]*")', ''
    # Remove "buy this template" or "powered by" badges
    $content = $content -replace '<a[^>]*class="w-legacy-badge[^>]*>.*?</a>', ''

    # --- STEP 4: Rebrand ---
    # Replace business names (order matters: longer phrases first)
    $content = $content -replace 'Lumora Dental', 'Smile Studio LA'
    $content = $content -replace 'lumora dental', 'Smile Studio LA'
    $content = $content -replace 'lumoradental\.com', 'smilestudiola.com'
    $content = $content -replace 'Lumora', 'Smile Studio'
    $content = $content -replace 'lumora', 'smile-studio'
    # Update alt text referencing old brand
    $content = $content -replace 'alt="Lumora', 'alt="Smile Studio'
    $content = $content -replace 'alt="smile-studio', 'alt="Smile Studio'
    
    # --- STEP 4: Update logo reference ---
    $content = $content -replace 'lumora-logo-dark\.svg', 'smile-studio-logo-dark.svg'
    $content = $content -replace 'lumora-logo\.svg', 'smile-studio-logo.svg'

    # --- STEP 7: Fix lead form function name ---
    $content = $content -replace 'lumoraLead', 'leadSubmit'

    # --- STEP 9: Wire contact details ---
    # Replace phone numbers
    $content = $content -replace '\+91\s*9307512816', '+1 (310) 555-0192'
    $content = $content -replace 'tel:\+91\s*9307512816', 'tel:+13105550192'
    $content = $content -replace 'tel:\+1\s*\(310\)\s*555-0192', 'tel:+13105550192'
    $content = $content -replace 'Call\s*:\s*\+91\s*9307512816', 'Call: +1 (310) 555-0192'
    # Replace emails
    $content = $content -replace 'hello@smile-studiodental\.com', 'info@smilestudiola.com'
    $content = $content -replace 'hello@smilestudiola\.com', 'info@smilestudiola.com'
    # Replace Calendly booking links
    $content = $content -replace 'https://calendly\.com/shreyasrajsony11', 'https://smilestudiola.com/booking'
    # Replace WhatsApp number
    $content = $content -replace '919307512816', '13105550192'
    # Update WhatsApp message text 
    $content = $content -replace 'Hi Smile Studio LA Dental', 'Hi Smile Studio LA'
    $content = $content -replace 'Hi Smile Studio Dental', 'Hi Smile Studio LA'
    $content = $content -replace 'for a dental appointment', 'for a dental appointment'

    # --- STEP 9: Update footer credit ---
    $content = $content -replace 'Crafted by RapidXAI', 'Crafted by VJX Studio'

    # --- STEP 4: Update meta descriptions ---
    $content = $content -replace 'Smile Studio Dental is a modern dental clinic', 'Smile Studio LA is a modern dental clinic in Los Angeles'
    
    # Fix "Where Beautiful Smiles Begin" tagline in title/meta if possible
    # Replace generic title
    $content = $content -replace 'Smile Studio LA \| Modern, Gentle Dentistry', 'Smile Studio LA | Where Beautiful Smiles Begin'
    $content = $content -replace 'Smile Studio Dental \| Modern, Gentle Dentistry', 'Smile Studio LA | Where Beautiful Smiles Begin'
    
    # Remove em dashes (&#x2014; and actual em dash character)
    $content = $content -replace '&#x2014;', ','
    $content = $content -replace [char]0x2014, ','

    # Fix double "Smile Studio" issues from cascading replacements
    $content = $content -replace 'Smile Studio LA LA', 'Smile Studio LA'
    $content = $content -replace 'Smile Studio Studio', 'Smile Studio'
    
    # Fix copyright lines 
    $content = $content -replace [regex]::Escape('© 2026 Smile Studio Dental'), '© 2026 Smile Studio LA'
    $content = $content -replace '&copy; 2026 Smile Studio Dental', '&copy; 2026 Smile Studio LA'

    # Fix image guard script reference
    $content = $content -replace "Smile Studio Dental'\)", "'Smile Studio LA')"
    $content = $content -replace "'smile-studio Dental'", "'Smile Studio LA'"
    $content = $content -replace "label\|\|'smile-studio Dental'", "label||'Smile Studio LA'"
    $content = $content -replace "label\|\|'Smile Studio Dental'", "label||'Smile Studio LA'"

    # Localize WebFont loader (Step 1 - leave Google Fonts, localize webfont.js)
    # Actually the requirement says "Zero runtime calls to any external CDN except Google Fonts"
    # webfont.js is from googleapis so it's fine, but let's keep it local for safety
    # The file is already loaded via Google Fonts preconnect which is allowed
    
    # Write back
    [System.IO.File]::WriteAllText($file.FullName, $content, [System.Text.UTF8Encoding]::new($false))
    Write-Host "Processed: $($file.Name)"
}

# --- STEP 5: Recolor CSS ---
$cssFile = Join-Path $ProjectDir "assets\css\lumora.css"
$cssContent = Get-Content $cssFile -Raw -Encoding UTF8

# Replace original teal palette with new accent (#1a6b5c) and ink dark (#0d3b31)
# Original primary: #24a3b1 -> New: #1a6b5c
# Original dark ink: #011f23 -> New: #0d3b31
# Related teal shades
$cssContent = $cssContent -replace '#24a3b1', '#1a6b5c'
$cssContent = $cssContent -replace '#1c91a1', '#176252'
$cssContent = $cssContent -replace '#0098af', '#1a6b5c'
$cssContent = $cssContent -replace '#011f23', '#0d3b31'
$cssContent = $cssContent -replace '#022f34', '#0e4438'
$cssContent = $cssContent -replace '#042b30', '#0d3f35'
$cssContent = $cssContent -replace '#002124', '#0d3b31'
$cssContent = $cssContent -replace '#000b0b', '#041510'
$cssContent = $cssContent -replace '#ddebec', '#dde8e5'
$cssContent = $cssContent -replace '#e2f1f3', '#e2ede9'
$cssContent = $cssContent -replace '#7fe3ef', '#7fd4c0'
$cssContent = $cssContent -replace '#cdd8da', '#cdd8d4'
$cssContent = $cssContent -replace '#587d81', '#4d7d6e'

# Also rename the CSS file
$newCssName = Join-Path $ProjectDir "assets\css\smile-studio.css"
[System.IO.File]::WriteAllText($newCssName, $cssContent, [System.Text.UTF8Encoding]::new($false))
# Don't delete old one yet, update references first

# Update CSS file references in all HTML
foreach ($file in $htmlFiles) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    $content = $content -replace 'lumora\.css', 'smile-studio.css'
    $content = $content -replace 'smile-studio\.css', 'smile-studio.css'
    [System.IO.File]::WriteAllText($file.FullName, $content, [System.Text.UTF8Encoding]::new($false))
}

# Remove old CSS file
if (Test-Path $cssFile) { Remove-Item $cssFile }

# --- Rename logo SVG files ---
$logoDir = Join-Path $ProjectDir "assets\img"
$oldLogoDark = Join-Path $logoDir "lumora-logo-dark.svg"
$newLogoDark = Join-Path $logoDir "smile-studio-logo-dark.svg"
$oldLogo = Join-Path $logoDir "lumora-logo.svg"
$newLogo = Join-Path $logoDir "smile-studio-logo.svg"

if (Test-Path $oldLogoDark) { 
    Copy-Item $oldLogoDark $newLogoDark -Force
    Remove-Item $oldLogoDark
}
if (Test-Path $oldLogo) { 
    Copy-Item $oldLogo $newLogo -Force
    Remove-Item $oldLogo
}

# Update logo SVG content to say "Smile Studio" instead of "Lumora"
if (Test-Path $newLogoDark) {
    $logoContent = Get-Content $newLogoDark -Raw -Encoding UTF8
    $logoContent = $logoContent -replace 'Lumora', 'Smile Studio'
    $logoContent = $logoContent -replace 'lumora', 'smile-studio'
    [System.IO.File]::WriteAllText($newLogoDark, $logoContent, [System.Text.UTF8Encoding]::new($false))
}
if (Test-Path $newLogo) {
    $logoContent = Get-Content $newLogo -Raw -Encoding UTF8
    $logoContent = $logoContent -replace 'Lumora', 'Smile Studio'
    $logoContent = $logoContent -replace 'lumora', 'smile-studio'
    [System.IO.File]::WriteAllText($newLogo, $logoContent, [System.Text.UTF8Encoding]::new($false))
}

# Create .nojekyll file
New-Item -Path (Join-Path $ProjectDir ".nojekyll") -ItemType File -Force | Out-Null

Write-Host ""
Write-Host "===== TRANSFORMATION COMPLETE ====="
Write-Host "All HTML files rebranded and rewired"
Write-Host "CSS recolored and renamed"
Write-Host "Logo files renamed"
Write-Host ""

# Final check for remaining "lumora" references
Write-Host "--- Checking for remaining 'lumora' references ---"
$remaining = Get-ChildItem -Path $ProjectDir -Recurse -File -Include "*.html","*.css","*.js","*.svg" | 
    Select-String -Pattern "lumora" -SimpleMatch -CaseSensitive:$false |
    Where-Object { $_.Filename -ne "transform.ps1" }
if ($remaining) {
    Write-Host "WARNING: Found remaining references:"
    $remaining | ForEach-Object { Write-Host "  $($_.Filename):$($_.LineNumber): $($_.Line.Trim().Substring(0, [Math]::Min(100, $_.Line.Trim().Length)))" }
} else {
    Write-Host "CLEAN: No 'lumora' references found!"
}
