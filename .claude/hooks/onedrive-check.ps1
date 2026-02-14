# OneDrive Compatibility Check Hook
# Validates filenames for OneDrive/SharePoint compatibility

$inputJson = [Console]::In.ReadToEnd()
$input = $inputJson | ConvertFrom-Json
$file = $input.tool_input.file_path

if ($file) {
    $name = Split-Path $file -Leaf
    $issues = @()

    if ($name -match '[\"*:<>?|\\]') { $issues += "Invalid characters found: contains one of "" * : < > ? | \" }
    if ($name -match '^\s|\s$') { $issues += 'Starts or ends with space' }
    if ($name -match '\.$' -and $name -notmatch '\.\w+$') { $issues += 'Ends with period' }
    if ($name -match '^~\$') { $issues += 'Starts with ~$ (temp file indicator)' }
    if ($name -match '^(CON|PRN|AUX|NUL|COM[0-9]|LPT[0-9])(\..*)?$') { $issues += 'Uses reserved Windows name' }
    if ($name -match '_vti_') { $issues += 'Contains _vti_ (SharePoint reserved)' }
    if ($name.Length -gt 255) { $issues += 'Filename exceeds 255 characters' }
    if ($file.Length -gt 400) { $issues += 'Full path exceeds 400 characters (OneDrive limit)' }
    if ($name -match '#|%') { $issues += 'Contains # or % (may cause sync issues)' }

    if ($issues.Count -gt 0) {
        Write-Host "`n[Hook: onedrive-check] $(Split-Path $file -Leaf)"
        Write-Host 'OneDrive compatibility issues:'
        $issues | ForEach-Object { Write-Host "  - $_" }
        Write-Host ''
    }
}
