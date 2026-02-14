# ICQ Session Reminder Hook (fires on Stop)
# Reminds to save session and check for unsaved changes

$inputJson = [Console]::In.ReadToEnd()

Write-Host ""
Write-Host "[ICQ Session Reminder] Before ending, remember to:"
Write-Host "  1. /icq-save-session  - Save conversation summary"
Write-Host "  2. /icq-validate      - Check for structural issues"
Write-Host "  3. Open portal        - Verify changes in browser"
Write-Host "  4. Check file lock    - Ensure index.html is the latest version"
Write-Host "  5. git status         - Check for uncommitted changes"
Write-Host "  6. git push           - Push to GitHub (updates Pages)"
Write-Host "  7. Jira links         - Verify remote links on any generated tickets"
Write-Host ""

# Check for uncommitted changes
try {
    $gitStatus = git -C 'C:\Repo\ICQ' status --porcelain 2>&1
    if ($gitStatus) {
        $changeCount = ($gitStatus | Measure-Object -Line).Lines
        Write-Host "[ICQ Session Reminder] WARNING: $changeCount uncommitted change(s) detected"
        Write-Host ""
    }
} catch { }

# Check for unpushed commits
try {
    $unpushed = git -C 'C:\Repo\ICQ' log --oneline '@{upstream}..HEAD' 2>&1
    if ($unpushed -and $unpushed -notmatch 'fatal') {
        $commitCount = ($unpushed | Measure-Object -Line).Lines
        Write-Host "[ICQ Session Reminder] WARNING: $commitCount unpushed commit(s) - run 'git push' to update GitHub Pages"
        Write-Host ""
    }
} catch { }
