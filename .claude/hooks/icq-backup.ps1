# ICQ Backup Hook (PreToolUse for Write|Edit)
# Creates a timestamped backup of ICQ portal files before any edit

$inputJson = [Console]::In.ReadToEnd()
$input = $inputJson | ConvertFrom-Json
$file = $input.tool_input.file_path

# Backup the main ICQ portal file or customer portal files
$isMainPortal = $file -and $file -match 'ICQ[/\\]index\d*\.html$' -and $file -notmatch 'index-v2|\.bak'
$isCustomerPortal = $file -and $file -match 'customers[/\\][^/\\]+[/\\]index\.html$'

if ($isMainPortal -or $isCustomerPortal) {
    $icqRoot = 'C:\Repo\ICQ'
    $backupDir = Join-Path $icqRoot 'backups'

    if (-not (Test-Path $backupDir)) {
        New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    }

    if (Test-Path $file) {
        $timestamp = Get-Date -Format 'yyyy-MM-dd_HHmmss'
        $fileName = Split-Path $file -Leaf
        # Include customer name in backup filename for customer portals
        if ($isCustomerPortal) {
            $customerName = Split-Path (Split-Path $file -Parent) -Leaf
            $backupFile = Join-Path $backupDir "${customerName}_${timestamp}.html"
        } else {
            $backupFile = Join-Path $backupDir "index_$timestamp.html"
        }

        try {
            Copy-Item $file $backupFile -ErrorAction Stop
            Write-Host "[Hook: icq-backup] Backup created: backups\$(Split-Path $backupFile -Leaf)"
        } catch {
            Write-Host "[Hook: icq-backup] Warning: Could not create backup - $($_.Exception.Message)"
        }
    }
}

exit 0
