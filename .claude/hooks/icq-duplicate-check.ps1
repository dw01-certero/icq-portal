# ICQ Duplicate Check Hook (PostToolUse for Write|Edit)
# Checks for duplicate question text and overlapping content

$inputJson = [Console]::In.ReadToEnd()
$input = $inputJson | ConvertFrom-Json
$file = $input.tool_input.file_path

if ($file -and $file -match 'index\d*\.html$' -and (Test-Path $file)) {
    $content = Get-Content $file -Raw -ErrorAction SilentlyContinue
    if (-not $content) { exit 0 }
    if ($content -notmatch 'ICQ_DATA') { exit 0 }

    $issues = @()

    # Extract all question texts
    $questionTexts = [regex]::Matches($content, 'text:\s*"([^"]+)"') | ForEach-Object { $_.Groups[1].Value }

    # Check for exact duplicate question text
    $duplicateTexts = $questionTexts | Group-Object | Where-Object { $_.Count -gt 1 }
    foreach ($dup in $duplicateTexts) {
        $shortText = if ($dup.Name.Length -gt 60) { $dup.Name.Substring(0, 57) + '...' } else { $dup.Name }
        $issues += "[Duplicate] Question text appears $($dup.Count) times: `"$shortText`""
    }

    # Check for questions with very similar starts (potential duplicates)
    $prefixes = @{}
    foreach ($text in $questionTexts) {
        if ($text.Length -ge 40) {
            $prefix = $text.Substring(0, 40)
            if ($prefixes.ContainsKey($prefix)) {
                $prefixes[$prefix]++
            } else {
                $prefixes[$prefix] = 1
            }
        }
    }
    foreach ($kv in $prefixes.GetEnumerator()) {
        if ($kv.Value -gt 1) {
            $shortPrefix = if ($kv.Key.Length -gt 50) { $kv.Key.Substring(0, 47) + '...' } else { $kv.Key }
            $issues += "[Similar] $($kv.Value) questions start with: `"$shortPrefix`""
        }
    }

    if ($issues.Count -gt 0) {
        $fileName = Split-Path $file -Leaf
        Write-Host "`n[Hook: icq-duplicate-check] $fileName"
        Write-Host 'Duplicate content issues:'
        $issues | ForEach-Object { Write-Host "  - $_" }
        Write-Host ''
    }
}

exit 0
