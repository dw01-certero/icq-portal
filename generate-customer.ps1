[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$CustomerName,

    [Parameter(Mandatory=$true, Position=1)]
    [string]$UserName,

    [Parameter(Mandatory=$true, Position=2)]
    [ValidateSet("onprem", "saas")]
    [string]$TemplateMode,

    [Parameter(Mandatory=$true, Position=3)]
    [string]$JiraTicket,

    [Parameter(Mandatory=$false)]
    [string]$LockedSectionsJson = "{}",

    [Parameter(Mandatory=$false)]
    [string]$PreSelectedTechsJson = "{}"
)

Add-Type -AssemblyName System.Web
$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Find the template file
$templatePath = Join-Path $scriptDir "index2.html"
if (-not (Test-Path $templatePath)) {
    $templatePath = Join-Path $scriptDir "index.html"
}
if (-not (Test-Path $templatePath)) {
    Write-Error "Template file not found"
    exit 1
}

Write-Host "Reading template from: $templatePath"
$html = [System.IO.File]::ReadAllText($templatePath, [System.Text.Encoding]::UTF8)

# Build the CUSTOMER_CONFIG block
$escapedCustomer = $CustomerName -replace '\\', '\\\\' -replace '"', '\"'
$escapedUser = $UserName -replace '\\', '\\\\' -replace '"', '\"'

$configBlock = "const CUSTOMER_CONFIG = {`n"
$configBlock += "  customerName: `"$escapedCustomer`",`n"
$configBlock += "  userName: `"$escapedUser`",`n"
$configBlock += "  templateMode: `"$TemplateMode`",`n"
$configBlock += "  jiraTicket: `"$JiraTicket`",`n"
$configBlock += "  lockedSections: $LockedSectionsJson,`n"
$configBlock += "  preSelectedTechs: $PreSelectedTechsJson`n"
$configBlock += "};"

# Replace the placeholder comment with actual config
$html = $html -replace '/\* const CUSTOMER_CONFIG = null; \*/', $configBlock

# Update page title
$html = $html -replace '<title>ITAM ICQ</title>', "<title>ITAM ICQ - $escapedCustomer</title>"

# Update header branding
$htmlCustomer = [System.Web.HttpUtility]::HtmlEncode($CustomerName)
$html = $html -replace '<h1>ITAM ICQ</h1>', "<h1>ITAM ICQ &#8212; $htmlCustomer</h1>"

# Hide the Reset button
$html = $html -replace 'onclick="showResetModal\(\)">Reset</button>', 'onclick="showResetModal()" style="display:none">Reset</button>'

# Add Jira reference footer before the reset modal
$jiraFooter = "<!-- Jira Reference -->`n"
$jiraFooter += "<div style=`"text-align:center;padding:12px;font-size:0.7rem;color:var(--text-muted)`">`n"
$jiraFooter += "  Generated from <strong>$JiraTicket</strong> | <a href=`"https://certero.atlassian.net/browse/$JiraTicket`" style=`"color:var(--accent)`">View in Jira</a>`n"
$jiraFooter += "</div>`n`n"
$jiraFooter += "<!-- __ Reset Modal __ -->"
$html = $html -replace '<!-- .{1,5} Reset Modal .{1,5} -->', $jiraFooter

# Create output directory
$customerDir = Join-Path $scriptDir "customers" $CustomerName
if (-not (Test-Path $customerDir)) {
    New-Item -ItemType Directory -Path $customerDir -Force | Out-Null
}

# Write output
$outputPath = Join-Path $customerDir "index.html"
[System.IO.File]::WriteAllText($outputPath, $html, (New-Object System.Text.UTF8Encoding $false))

Write-Host "Generated customer portal at: $outputPath"
Write-Host "Expected URL: https://certero.github.io/icq-portal/$CustomerName/"

# Update the landing page manifest
$landingPath = Join-Path $scriptDir "customers" "index.html"
if (Test-Path $landingPath) {
    $landingHtml = [System.IO.File]::ReadAllText($landingPath, [System.Text.Encoding]::UTF8)
    $entryCheck = "name: `"$CustomerName`""
    if ($landingHtml -notmatch [regex]::Escape($entryCheck)) {
        $entry = "  { name: `"$CustomerName`", ticket: `"$JiraTicket`", path: `"$CustomerName/`" },"
        $landingHtml = $landingHtml -replace '(const PORTALS = \[)', "`$1`n$entry"
        [System.IO.File]::WriteAllText($landingPath, $landingHtml, (New-Object System.Text.UTF8Encoding $false))
        Write-Host "Updated landing page manifest"
    }
}
