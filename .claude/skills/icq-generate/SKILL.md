---
name: icq-generate
description: Generate a customer-facing ICQ portal from a Jira onboarding ticket
user-invocable: true
argument-hint: "<ticket-key> (e.g., TMT4-154)"
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, ToolSearch, mcp__mcp-atlassian__jira_get_issue, mcp__mcp-atlassian__jira_create_remote_issue_link, mcp__mcp-atlassian__jira_add_comment
---

# Generate Customer ICQ Portal

Generate a customer-specific, publicly-accessible ICQ portal from a Jira TMT4 onboarding ticket.

## Usage

```
/icq-generate TMT4-154
```

## Process

1. **Read the Jira ticket** via MCP tool `mcp__mcp-atlassian__jira_get_issue` with the provided ticket key
2. **Extract fields** from the ticket (see Field Mapping below)
3. **Read the base template** from `C:\Repo\ICQ\index2.html` (or `index.html` if index2 doesn't exist)
4. **Determine in-scope sections** using the Product-to-Section Mapping
5. **Build the CUSTOMER_CONFIG** JavaScript object
6. **Generate the customer HTML** by injecting CUSTOMER_CONFIG into the template
7. **Write output** to `C:\Repo\ICQ\customers\<CUSTOMER_NAME>\index.html`
8. **Update the landing page** manifest in `C:\Repo\ICQ\customers\index.html`
9. **Git commit and push** to deploy via GitHub Pages (`pages.yml` workflow handles deployment)
10. **Add Jira remote link** on the ticket using `mcp__mcp-atlassian__jira_create_remote_issue_link` (see Jira Integration below)
11. **Add Jira comment** summarizing the deployment using `mcp__mcp-atlassian__jira_add_comment`
12. **Report success** with the public URL

## Jira Field Mapping

| Custom Field ID | Field Name | Maps To |
|----------------|------------|---------|
| `customfield_11315` | Customer name | `CUSTOMER_CONFIG.customerName` |
| `assignee.displayName` | Assignee | `CUSTOMER_CONFIG.userName` |
| `customfield_11248` | Hosting model | `CUSTOMER_CONFIG.templateMode` ("On Premise" → "onprem", "SaaS" → "saas") |
| `customfield_11578` | Certero products | Determines which sections are in scope |
| `customfield_11249` | Modules - C4EITAM | ITAM sub-modules in scope |
| `customfield_11579` | Modules - C4ESAM | SAM sub-modules in scope |
| `customfield_11580` | Modules - C4SaaS | SaaS connectors to pre-select |
| `customfield_11611` | ICQ generation rule | Controls which ICQs to create |
| `customfield_11451` | Project type | "Standard I&C" etc. |

### Field Value Extraction

Custom fields may be returned as:
- **Strings**: Use directly
- **Arrays of objects** with `.value` property: Extract `.value` from each item
- **Objects** with `.value` property: Extract `.value`
- **null/undefined**: Treat as empty/not-purchased

Example extraction logic:
```javascript
// Products: customfield_11578 → array of { value: "C4EITAM" }
const products = (fields.customfield_11578 || []).map(p => p.value || p);

// Hosting: customfield_11248 → { value: "On Premise" } or string
const hostingRaw = fields.customfield_11248?.value || fields.customfield_11248 || 'On Premise';
const templateMode = hostingRaw.toLowerCase().includes('saas') ? 'saas' : 'onprem';

// Modules: customfield_11249 → array of { value: "Inventory" }
const itamModules = (fields.customfield_11249 || []).map(m => m.value || m);
const samModules = (fields.customfield_11579 || []).map(m => m.value || m);
const saasConnectors = (fields.customfield_11580 || []).map(m => m.value || m);

// Customer name: customfield_11315 → string
const customerName = fields.customfield_11315 || fields.summary?.replace(/^.*?[-–]\s*/, '') || 'Unknown';

// Assignee
const userName = fields.assignee?.displayName || 'TBD';
```

## Product-to-Section Mapping

### Always In Scope (when product purchased)

| Jira Product | ICQ Sections In Scope |
|-------------|----------------------|
| **C4EITAM** (base) | 1.0, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.9, 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.15 |
| **C4EITAM + "Inventory"** | 2.3, 2.4 (already included in base) |
| **C4EITAM + "ITAM Connectors"** | 2.11, 2.12, 2.13, 2.14 |
| **C4EITAM + "Application Monitoring"** | 2.9 |
| **C4EITAM + "Distribution"** | 2.8 |
| **C4EITAM + "Patch Management"** | 1.8, 2.10 |
| **C4ESAM** | 2.17 |
| **C4SaaS** | 2.20 |
| **C4IBM** | 2.18 |
| **C4Oracle** / **C4O** | 2.19 |
| **C4SAP** | 2.21 |
| **App-Centre** | 2.16 |

### All Conditional Sections (that can be locked)

These are the sections with `conditional: true` in ICQ_DATA:
- 1.8 (Patch Management)
- 2.8 (Distribution)
- 2.9 (Application Monitoring)
- 2.10 (Patch Management)
- 2.11 (SNMP Network Discovery)
- 2.12 (Microsoft Intune)
- 2.13 (Cisco Meraki)
- 2.14 (ServiceNow Integration)
- 2.16 (App-Centre)
- 2.17 (Enterprise SAM)
- 2.18 (Certero for IBM)
- 2.19 (Certero for Oracle)
- 2.20 (Certero for SaaS)
- 2.21 (Certero for SAP)

Non-conditional sections (1.0-1.7, 1.9, 2.1-2.7, 2.15) are always in scope if C4EITAM is purchased.

### SaaS Connector-to-techOption Key Mapping

When C4SaaS is purchased, pre-select these tech options in section 2.20 based on the SaaS connectors from `customfield_11580`:

| Jira SaaS Connector | techOption Key |
|---------------------|---------------|
| Microsoft 365 | m365 |
| Adobe Creative Cloud | adobe_cc |
| Salesforce | salesforce |
| Google Workspace | google_workspace |
| ServiceNow | servicenow_saas |
| Zoom | zoom |
| Slack | slack |
| Dropbox | dropbox |
| Box | box |
| DocuSign | docusign |
| Atlassian | atlassian |

## CUSTOMER_CONFIG Object Structure

```javascript
const CUSTOMER_CONFIG = {
  customerName: "ROMO",
  userName: "Jordan Wong",
  templateMode: "onprem",
  jiraTicket: "TMT4-154",
  lockedSections: {
    // Only include sections that are NOT in scope
    "2.16": { locked: true, reason: "Not included in your project scope. Contact your account manager or PMO for details." },
    "2.18": { locked: true, reason: "Not included in your project scope. Contact your account manager or PMO for details." },
    // ...etc
  },
  preSelectedTechs: {
    // Only for C4SaaS section 2.20
    "2.20": ["m365", "adobe_cc", "salesforce"]
  }
};
```

## HTML Generation Steps

1. Read the base template file (`C:\Repo\ICQ\index2.html` or `index.html`)
2. Find the comment line `/* const CUSTOMER_CONFIG = null; */`
3. Replace it with the actual `const CUSTOMER_CONFIG = { ... };` block
4. Optionally hide the Reset button by adding `style="display:none"` to the Reset button element
5. Add a Jira reference in the footer area (after the main-content div, before the reset modal)
6. Update the page `<title>` to include the customer name
7. Write the modified HTML to `C:\Repo\ICQ\customers\<CUSTOMER_NAME>\index.html`

### Reset Button Removal

Find and modify:
```html
<button class="btn btn-danger" onclick="showResetModal()">Reset</button>
```
Replace with:
```html
<button class="btn btn-danger" onclick="showResetModal()" style="display:none">Reset</button>
```

### Title Update

Replace:
```html
<title>ITAM ICQ</title>
```
With:
```html
<title>ITAM ICQ - CUSTOMER_NAME</title>
```

### Header Customer Branding

Replace:
```html
<h1>ITAM ICQ</h1>
```
With:
```html
<h1>ITAM ICQ — CUSTOMER_NAME</h1>
```

### Jira Reference Footer

Add before the reset modal:
```html
<div style="text-align:center;padding:12px;font-size:0.7rem;color:var(--text-muted)">
  Generated from <strong>TICKET_KEY</strong> | <a href="https://certero.atlassian.net/browse/TICKET_KEY" style="color:var(--accent)">View in Jira</a>
</div>
```

## Jira Integration

### Remote Link (Portal Button on Ticket)

After generating and deploying, add a remote link to the Jira ticket so users can launch the portal directly:

```
mcp__mcp-atlassian__jira_create_remote_issue_link(
  issue_key: "TMT4-154",
  url: "https://dw01-certero.github.io/icq-portal/customers/CUSTOMER_NAME/",
  title: "🟣 Open ICQ Portal",
  icon_url: "https://dw01-certero.github.io/icq-portal/customers/assets/icq-icon.svg",
  icon_title: "ICQ Portal"
)
```

- The icon SVG is hosted at `customers/assets/icq-icon.svg` (Certero-branded gradient "Q" icon)
- The `🟣` emoji in the title helps the link stand out in Jira's link list
- **Limitation:** Remote links cannot be deleted via the Jira MCP API (`jira_remove_issue_link` only handles issue-to-issue links). Old links must be manually removed from the Jira UI.

### Jira Comment

After creating the remote link, add a summary comment to the ticket:

```
mcp__mcp-atlassian__jira_add_comment(
  issue_key: "TMT4-154",
  body: "h3. 🟣 ICQ Portal Deployed\n\n||Detail||Value||\n|Customer|CUSTOMER_NAME|\n|Hosting|On-Prem / SaaS|\n|Portal|[Open ICQ Portal|https://dw01-certero.github.io/icq-portal/customers/CUSTOMER_NAME/]|\n|In-Scope Sections|X sections|\n|Locked Sections|Y sections|\n\n_Auto-generated by ICQ Portal Generator_"
)
```

### GitHub Pages Deployment

- The `pages.yml` workflow deploys the entire repo root to GitHub Pages on push to `main`
- Customer portals are accessible at `https://dw01-certero.github.io/icq-portal/customers/<NAME>/`
- The icon SVG is at `https://dw01-certero.github.io/icq-portal/customers/assets/icq-icon.svg`
- **Do NOT create a separate deploy workflow** — it will conflict with `pages.yml` and cause 404 errors

## Output

After successful generation, report:
- File path: `C:\Repo\ICQ\customers\<NAME>\index.html`
- Public URL: `https://dw01-certero.github.io/icq-portal/customers/<NAME>/`
- Jira remote link created (with portal URL)
- Jira comment posted (with deployment summary)
- Summary of in-scope vs locked sections
- Pre-selected tech options (if any)

## Error Handling

- If the Jira ticket cannot be read, report the error and stop
- If required fields are missing (customer name), fall back to the ticket summary
- If no products are found, warn but still generate with all conditional sections locked
- If the template file cannot be read, report and stop
- If git push fails, report but still attempt Jira link/comment creation
- If Jira remote link creation fails, report but continue with comment
- If Jira comment creation fails, report but still report success with the URL
