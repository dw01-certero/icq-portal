# Batch ICQ Portal Generator
# Reads the base template and generates customer portals for all tickets

param(
    [string]$TemplateFile = "C:\Repo\ICQ\index.html",
    [string]$CustomersDir = "C:\Repo\ICQ\customers"
)

# Ticket data extracted from Jira TMT4 queue "All Ongoing Projects"
# Only parent project tickets with customfield_11578 (products) populated
$tickets = @(
    @{Key="TMT4-106"; Customer="aaaaa"; Summary="aaaaa"; Assignee="Jordan Wong"; Hosting="On Premise";
      Products=@("C4EITAM","C4ESAM","C4SaaS"); ITAMModules=@("Distribution","Inventory","ITAM Connectors");
      SAMModules=@("Adobe Licensing"); SaaSConnectors=@("Adobe Creative Cloud")},
    @{Key="TMT4-110"; Customer="bb"; Summary="bb"; Assignee="Unassigned"; Hosting="On Premise";
      Products=@("C4EITAM","C4ESAM","C4SaaS"); ITAMModules=@(); SAMModules=@(); SaaSConnectors=@()},
    @{Key="TMT4-117"; Customer="ddd"; Summary="ddd"; Assignee="Unassigned"; Hosting="On Premise";
      Products=@("C4EITAM","C4ESAM","C4SaaS"); ITAMModules=@("Application Monitoring (AppsMon)","Distribution","Virtualization Connectors");
      SAMModules=@("Generic Licensing","Adobe Licensing"); SaaSConnectors=@("Microsoft 365","Okta","Dropbox")},
    @{Key="TMT4-122"; Customer="ads"; Summary="ads"; Assignee="Unassigned"; Hosting="On Premise";
      Products=@("C4EITAM","C4ESAM"); ITAMModules=@("Application Monitoring (AppsMon)","Distribution");
      SAMModules=@("Generic Licensing","Adobe Licensing"); SaaSConnectors=@()},
    @{Key="TMT4-128"; Customer="Company Name"; Summary="[Project Title]"; Assignee="Unassigned"; Hosting="On Premise";
      Products=@("C4EITAM","C4ESAM"); ITAMModules=@("Application Monitoring (AppsMon)","Distribution");
      SAMModules=@("Generic Licensing","Adobe Licensing","Microsoft Licensing"); SaaSConnectors=@()},
    @{Key="TMT4-136"; Customer="ARUP Laboratories"; Summary="Distribution and AccessCTRL"; Assignee="Jordan Wong"; Hosting="On Premise";
      Products=@("C4EITAM","C4ESAM"); ITAMModules=@("Distribution");
      SAMModules=@("Access Control"); SaaSConnectors=@()},
    @{Key="TMT4-140"; Customer="test2"; Summary="test2"; Assignee="Jordan Wong"; Hosting="SaaS: Single Tenancy";
      Products=@("C4EITAM","C4ESAM"); ITAMModules=@("Distribution");
      SAMModules=@("Access Control"); SaaSConnectors=@()},
    @{Key="TMT4-142"; Customer="test3"; Summary="test3"; Assignee="Jordan Wong"; Hosting="SaaS: Single Tenancy";
      Products=@("C4EITAM","C4ESAM"); ITAMModules=@("Distribution");
      SAMModules=@("Access Control"); SaaSConnectors=@()},
    @{Key="TMT4-147"; Customer="test4"; Summary="test4"; Assignee="Jordan Wong"; Hosting="On Premise";
      Products=@("C4EITAM","C4ESAM","C4SaaS"); ITAMModules=@("Distribution");
      SAMModules=@("Generic Licensing","Adobe Licensing"); SaaSConnectors=@("Adobe Creative Cloud")},
    @{Key="TMT4-152"; Customer="Company1"; Summary="project2"; Assignee="Jordan Wong"; Hosting="On Premise";
      Products=@("C4EITAM","C4ESAM"); ITAMModules=@("Distribution");
      SAMModules=@("Microsoft Licensing","Access Control"); SaaSConnectors=@()},
    @{Key="TMT4-154"; Customer="ROMO"; Summary="Certero Enterprise Standard Edition On Demand"; Assignee="Jordan Wong"; Hosting="On Premise";
      Products=@("C4EITAM","C4ESAM","C4SaaS"); ITAMModules=@("Application Monitoring (AppsMon)","Inventory","ITAM Connectors","Virtualization Connectors");
      SAMModules=@("Generic Licensing","Adobe Licensing","Microsoft Licensing","Access Control"); SaaSConnectors=@("Adobe Creative Cloud","Microsoft 365","Salesforce")},
    @{Key="TMT4-156"; Customer="ROMO"; Summary="Certero of Enterprise ITAM"; Assignee="Jordan Wong"; Hosting="On Premise";
      Products=@("C4EITAM","C4ESAM"); ITAMModules=@("Application Monitoring (AppsMon)","Inventory","ITAM Connectors","Virtualization Connectors");
      SAMModules=@("Generic Licensing","Adobe Licensing","Microsoft Licensing","Access Control"); SaaSConnectors=@("Adobe Creative Cloud","Microsoft 365","Salesforce")},
    @{Key="TMT4-158"; Customer="sad"; Summary="dasad"; Assignee="Jordan Wong"; Hosting="On Premise";
      Products=@("C4EITAM","C4ESAM"); ITAMModules=@("Distribution");
      SAMModules=@("Access Control"); SaaSConnectors=@()},
    @{Key="TMT4-163"; Customer="aaa"; Summary="bbb"; Assignee="Jordan Wong"; Hosting="SaaS: Single Tenancy";
      Products=@("C4EITAM","C4ESAM"); ITAMModules=@("Distribution");
      SAMModules=@("Access Control"); SaaSConnectors=@()},
    @{Key="TMT4-166"; Customer="ffff"; Summary="ggggg"; Assignee="Jordan Wong"; Hosting="On Premise";
      Products=@("C4ESAM","C4SaaS"); ITAMModules=@();
      SAMModules=@("Access Control"); SaaSConnectors=@("Adobe Creative Cloud","Microsoft 365","Salesforce")},
    @{Key="TMT4-169"; Customer="ARUP Laboratories"; Summary="Distribution & AccessCTRL"; Assignee="Richard Morgan"; Hosting="On Premise";
      Products=@("C4EITAM","C4ESAM"); ITAMModules=@("Distribution");
      SAMModules=@("Access Control"); SaaSConnectors=@()},
    @{Key="TMT4-171"; Customer="Arup Lab"; Summary="Distribution & AccessCTRL"; Assignee="Richard Morgan"; Hosting="On Premise";
      Products=@("C4EITAM","C4ESAM"); ITAMModules=@("Distribution");
      SAMModules=@("Access Control"); SaaSConnectors=@()},
    @{Key="TMT4-173"; Customer="test 2"; Summary="project 2"; Assignee="Unassigned"; Hosting="SaaS: Single Tenancy";
      Products=@("C4EITAM","C4ESAM","C4SaaS"); ITAMModules=@("Inventory","ITAM Connectors","Virtualization Connectors");
      SAMModules=@(); SaaSConnectors=@("Microsoft 365")}
)

# SaaS connector to techOption key mapping
$saasMapping = @{
    "Microsoft 365" = "m365"
    "Adobe Creative Cloud" = "adobe_cc"
    "Salesforce" = "salesforce"
    "Google Workspace" = "google_workspace"
    "ServiceNow" = "servicenow_saas"
    "Zoom" = "zoom"
    "Slack" = "slack"
    "Dropbox" = "dropbox"
    "Box" = "box"
    "DocuSign" = "docusign"
    "Atlassian" = "atlassian"
    "Okta" = "okta"
}

# All conditional section IDs
$allConditionalSections = @("1.8","2.8","2.9","2.10","2.11","2.12","2.13","2.14","2.16","2.17","2.18","2.19","2.20","2.21")

function Get-InScopeSections {
    param($Products, $ITAMModules)
    $inScope = @()

    if ($Products -contains "C4EITAM") {
        # Base ITAM sections always in scope
        $inScope += @("1.0","1.1","1.2","1.3","1.4","1.5","1.6","1.7","1.9","2.1","2.2","2.3","2.4","2.5","2.6","2.7","2.15")

        if ($ITAMModules -contains "Inventory") { $inScope += @("2.3","2.4") }
        if ($ITAMModules -contains "ITAM Connectors") { $inScope += @("2.11","2.12","2.13","2.14") }
        if ($ITAMModules -match "Application Monitoring") { $inScope += @("2.9") }
        if ($ITAMModules -contains "Distribution") { $inScope += @("2.8") }
        if ($ITAMModules -contains "Patch Management") { $inScope += @("1.8","2.10") }
    }
    if ($Products -contains "C4ESAM") { $inScope += @("2.17") }
    if ($Products -contains "C4SaaS") { $inScope += @("2.20") }
    if ($Products -contains "C4IBM") { $inScope += @("2.18") }
    if ($Products -match "C4Oracle|C4O") { $inScope += @("2.19") }
    if ($Products -contains "C4SAP") { $inScope += @("2.21") }
    if ($Products -contains "App-Centre") { $inScope += @("2.16") }

    return $inScope | Select-Object -Unique
}

function Get-LockedSections {
    param($InScopeSections)
    $locked = @{}
    foreach ($s in $allConditionalSections) {
        if ($s -notin $InScopeSections) {
            $locked[$s] = @{ locked = $true; reason = "Not included in your project scope. Contact your account manager or PMO for details." }
        }
    }
    return $locked
}

function Get-PreSelectedTechs {
    param($Products, $SaaSConnectors)
    $pre = @{}
    if ($Products -contains "C4SaaS" -and $SaaSConnectors.Count -gt 0) {
        $techKeys = @()
        foreach ($conn in $SaaSConnectors) {
            if ($saasMapping.ContainsKey($conn)) {
                $techKeys += $saasMapping[$conn]
            }
        }
        if ($techKeys.Count -gt 0) {
            $pre["2.20"] = $techKeys
        }
    }
    return $pre
}

function Get-SafeFolderName {
    param($Name)
    # Remove/replace characters not safe for URLs and folder names
    $safe = $Name -replace '[<>:"/\\|?*]', '' -replace '\s+', '-'
    return $safe
}

function Build-CustomerConfig {
    param($Ticket)

    $templateMode = if ($Ticket.Hosting -match 'SaaS') { 'saas' } else { 'onprem' }
    $customerName = if ($Ticket.Customer) { $Ticket.Customer } else { $Ticket.Summary }
    $userName = $Ticket.Assignee
    $jiraTicket = $Ticket.Key

    $inScope = Get-InScopeSections -Products $Ticket.Products -ITAMModules $Ticket.ITAMModules
    $locked = Get-LockedSections -InScopeSections $inScope
    $preTechs = Get-PreSelectedTechs -Products $Ticket.Products -SaaSConnectors $Ticket.SaaSConnectors

    # Build lockedSections JS
    $lockedLines = @()
    foreach ($key in ($locked.Keys | Sort-Object { [double]$_ })) {
        $reason = $locked[$key].reason
        $lockedLines += "    `"$key`": { locked: true, reason: `"$reason`" }"
    }
    $lockedJS = $lockedLines -join ",`n"

    # Build preSelectedTechs JS
    $preLines = @()
    foreach ($key in $preTechs.Keys) {
        $vals = ($preTechs[$key] | ForEach-Object { "`"$_`"" }) -join ", "
        $preLines += "    `"$key`": [$vals]"
    }
    $preJS = $preLines -join ",`n"

    # Build allowedTechs JS — restrict tech options to only purchased connectors
    # Always include section entry when the product is purchased (empty array = hide all options)
    $allowedTechs = @{}
    if ($Ticket.Products -contains "C4SaaS") {
        $techKeys = @()
        foreach ($conn in $Ticket.SaaSConnectors) {
            if ($saasMapping.ContainsKey($conn)) {
                $techKeys += $saasMapping[$conn]
            }
        }
        $allowedTechs["2.20"] = $techKeys
    }
    $allowedLines = @()
    foreach ($key in $allowedTechs.Keys) {
        $vals = ($allowedTechs[$key] | ForEach-Object { "`"$_`"" }) -join ", "
        $allowedLines += "    `"$key`": [$vals]"
    }
    $allowedJS = $allowedLines -join ",`n"

    $config = @"
const CUSTOMER_CONFIG = {
  customerName: "$customerName",
  userName: "$userName",
  templateMode: "$templateMode",
  jiraTicket: "$jiraTicket",
  lockedSections: {
$lockedJS
  },
  preSelectedTechs: {
$preJS
  },
  allowedTechs: {
$allowedJS
  }
};
"@
    return $config
}

# --- Main ---

Write-Host "Reading base template: $TemplateFile"
$template = Get-Content $TemplateFile -Raw -Encoding UTF8
if (-not $template) {
    Write-Host "ERROR: Could not read template file"
    exit 1
}

# Track folder names to handle duplicates
$usedFolders = @{}
$generated = @()

foreach ($ticket in $tickets) {
    $customerName = if ($ticket.Customer) { $ticket.Customer } else { $ticket.Summary }
    $folderName = Get-SafeFolderName -Name $customerName

    # Handle duplicate folder names by appending ticket key
    if ($usedFolders.ContainsKey($folderName)) {
        $folderName = "$folderName-$($ticket.Key)"
    }
    $usedFolders[$folderName] = $true

    $outDir = Join-Path $CustomersDir $folderName
    $outFile = Join-Path $outDir "index.html"

    Write-Host "Generating: $folderName ($($ticket.Key)) ..."

    # Build config
    $config = Build-CustomerConfig -Ticket $ticket

    # Start with template
    $html = $template

    # Inject CUSTOMER_CONFIG
    $html = $html -replace '/\*\s*const CUSTOMER_CONFIG\s*=\s*null;\s*\*/', $config

    # Update title
    $html = $html -replace '<title>ITAM ICQ</title>', "<title>ITAM ICQ - $customerName</title>"

    # Update header
    $html = $html -replace '<h1>ITAM ICQ</h1>', "<h1>ITAM ICQ &#8212; $customerName</h1>"

    # Hide reset button
    $html = $html -replace '(<button class="btn btn-danger" onclick="showResetModal\(\)")>', '$1 style="display:none">'

    # Add Jira reference footer (before reset modal)
    $jiraFooter = @"
<div style="text-align:center;padding:12px;font-size:0.7rem;color:var(--text-muted)">
  Generated from <strong>$($ticket.Key)</strong> | <a href="https://certero.atlassian.net/browse/$($ticket.Key)" style="color:var(--accent)">View in Jira</a>
</div>
"@
    $html = $html -replace '(<!-- Reset Confirmation Modal)', "$jiraFooter`n`$1"
    # If no reset modal comment, try before the modal div
    if ($html -notmatch 'Generated from') {
        $html = $html -replace '(<div id="resetModal")', "$jiraFooter`n`$1"
    }

    # Write output
    if (-not (Test-Path $outDir)) {
        New-Item -ItemType Directory -Path $outDir -Force | Out-Null
    }

    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($outFile, $html, $utf8NoBom)

    $inScope = Get-InScopeSections -Products $ticket.Products -ITAMModules $ticket.ITAMModules
    $locked = Get-LockedSections -InScopeSections $inScope
    $templateMode = if ($ticket.Hosting -match 'SaaS') { 'SaaS' } else { 'On-Prem' }

    $generated += @{
        Key = $ticket.Key
        Customer = $customerName
        Folder = $folderName
        Hosting = $templateMode
        InScope = ($allConditionalSections.Count - $locked.Count)
        Locked = $locked.Count
    }

    Write-Host "  -> customers/$folderName/index.html (In-scope: $($allConditionalSections.Count - $locked.Count), Locked: $($locked.Count))"
}

# Update landing page manifest
Write-Host "`nUpdating landing page manifest..."
$landingPath = Join-Path $CustomersDir "index.html"
$landing = Get-Content $landingPath -Raw -Encoding UTF8

# Build new PORTALS array
$portalEntries = @()
foreach ($g in $generated) {
    $url = "https://dw01-certero.github.io/icq-portal/customers/$($g.Folder)/"
    $portalEntries += "      { name: `"$($g.Customer)`", ticket: `"$($g.Key)`", hosting: `"$($g.Hosting)`", url: `"$url`" }"
}
$portalsJS = $portalEntries -join ",`n"
$newManifest = "const PORTALS = [`n$portalsJS`n    ];"

# Replace the existing PORTALS array
$landing = $landing -replace 'const PORTALS = \[[\s\S]*?\];', $newManifest
[System.IO.File]::WriteAllText($landingPath, $landing, $utf8NoBom)

Write-Host "`n=== Generation Complete ==="
Write-Host "Total portals generated: $($generated.Count)"
foreach ($g in $generated) {
    Write-Host "  $($g.Key) | $($g.Customer) | $($g.Hosting) | In-scope: $($g.InScope) | Locked: $($g.Locked)"
}
