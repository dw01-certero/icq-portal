# Safety Check Hook
# Blocks potentially destructive Bash commands

$inputJson = [Console]::In.ReadToEnd()
$input = $inputJson | ConvertFrom-Json
$cmd = $input.tool_input.command

if ($cmd -match 'rm\s+-rf|del\s+/[sq]|format\s+|rmdir\s+/s|Remove-Item.*-Recurse.*-Force') {
    Write-Host '[Hook: safety] Blocked potentially destructive command'
    exit 2
}
