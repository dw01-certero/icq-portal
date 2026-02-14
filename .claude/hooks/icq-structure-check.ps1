# ICQ Structure Check Hook (PostToolUse for Write|Edit)
# Validates ICQ_DATA structure after edits to index.html
# Checks for: duplicate IDs, missing required fields, broken tech selectors

$inputJson = [Console]::In.ReadToEnd()
$input = $inputJson | ConvertFrom-Json
$file = $input.tool_input.file_path

if ($file -and $file -match 'index\d*\.html$' -and (Test-Path $file)) {
    $content = Get-Content $file -Raw -ErrorAction SilentlyContinue
    if (-not $content) { exit 0 }

    # Only check if this is an ICQ portal file
    if ($content -notmatch 'ICQ_DATA') { exit 0 }

    $issues = @()

    # Check for common JavaScript syntax issues
    # Trailing comma before closing bracket (breaks IE)
    if ($content -match ',\s*\]') {
        $issues += '[Syntax] Trailing comma before ] found - may break older browsers'
    }

    # Unmatched brackets in ICQ_DATA (basic check)
    $openBrackets = ([regex]::Matches($content, '\[')).Count
    $closeBrackets = ([regex]::Matches($content, '\]')).Count
    if ($openBrackets -ne $closeBrackets) {
        $issues += "[Syntax] Mismatched brackets: $openBrackets [ vs $closeBrackets ]"
    }

    $openBraces = ([regex]::Matches($content, '\{')).Count
    $closeBraces = ([regex]::Matches($content, '\}')).Count
    if ($openBraces -ne $closeBraces) {
        $issues += "[Syntax] Mismatched braces: $openBraces { vs $closeBraces }"
    }

    # Check for duplicate section IDs
    $sectionIds = [regex]::Matches($content, 'id:\s*"(\d+\.\d+)"') | ForEach-Object { $_.Groups[1].Value }
    $duplicateIds = $sectionIds | Group-Object | Where-Object { $_.Count -gt 1 }
    foreach ($dup in $duplicateIds) {
        $issues += "[ID] Duplicate section ID: $($dup.Name) (appears $($dup.Count) times)"
    }

    # Check for duplicate question refs
    $questionRefs = [regex]::Matches($content, 'ref:\s*"(\d+\.\d+\.\d+)"') | ForEach-Object { $_.Groups[1].Value }
    $duplicateRefs = $questionRefs | Group-Object | Where-Object { $_.Count -gt 1 }
    foreach ($dup in $duplicateRefs) {
        $issues += "[ID] Duplicate question ref: $($dup.Name) (appears $($dup.Count) times)"
    }

    # Check that hasTechSelector sections have techOptions
    $techSelectorMatches = [regex]::Matches($content, 'hasTechSelector:\s*true')
    $techOptionsMatches = [regex]::Matches($content, 'techOptions:\s*\[')
    if ($techSelectorMatches.Count -ne $techOptionsMatches.Count) {
        $issues += "[Tech] Mismatch: $($techSelectorMatches.Count) sections have hasTechSelector but only $($techOptionsMatches.Count) have techOptions"
    }

    # Check for empty question arrays
    if ($content -match 'questions:\s*\[\s*\]') {
        $issues += '[Data] Empty questions array found - section has no questions'
    }

    # Check for missing inputType
    $questionCount = ([regex]::Matches($content, 'ref:\s*"')).Count
    $inputTypeCount = ([regex]::Matches($content, 'inputType:\s*"')).Count
    if ($questionCount -gt $inputTypeCount) {
        $missing = $questionCount - $inputTypeCount
        $issues += "[Data] $missing question(s) missing inputType field"
    }

    # Customer portal checks
    if ($content -match 'const CUSTOMER_CONFIG\s*=\s*\{') {
        # Verify CUSTOMER_CONFIG has required fields
        if ($content -notmatch 'customerName:\s*"[^"]+') {
            $issues += '[CustomerConfig] Missing or empty customerName'
        }
        if ($content -notmatch 'jiraTicket:\s*"[^"]+') {
            $issues += '[CustomerConfig] Missing or empty jiraTicket'
        }
        if ($content -notmatch 'templateMode:\s*"(onprem|saas)"') {
            $issues += '[CustomerConfig] Invalid or missing templateMode (must be "onprem" or "saas")'
        }
        # Verify locked section IDs exist in ICQ_DATA
        $lockedIds = [regex]::Matches($content, '"(\d+\.\d+)":\s*\{\s*locked:\s*true') | ForEach-Object { $_.Groups[1].Value }
        $sectionIds = [regex]::Matches($content, 'id:\s*"(\d+\.\d+)"') | ForEach-Object { $_.Groups[1].Value }
        foreach ($lockedId in $lockedIds) {
            if ($lockedId -notin $sectionIds) {
                $issues += "[CustomerConfig] Locked section '$lockedId' does not exist in ICQ_DATA"
            }
        }
        # Verify Reset button is hidden
        if ($content -match 'showResetModal\(\)">Reset</button>' -and $content -notmatch 'showResetModal\(\)"\s*style="display:none">Reset') {
            $issues += '[CustomerConfig] Reset button is not hidden (should have display:none)'
        }
    }

    if ($issues.Count -gt 0) {
        $fileName = Split-Path $file -Leaf
        Write-Host "`n[Hook: icq-structure-check] $fileName"
        Write-Host 'Structure issues found:'
        $issues | ForEach-Object { Write-Host "  - $_" }
        Write-Host ''
    }
}

exit 0
