# ICQ Portal - Implementation Plan

## Context

Certero uses Word-based ICQ (Implementation & Configuration Questionnaire) templates to gather customer environment details before implementing the CUP platform. There are two templates: On-Premises (v12) and SaaS (v11). Through gap analysis against the full CUP platform capabilities (29 connectors, SNMP, ServiceNow, etc.), we identified ~40 additional questions missing from the templates. This portal will digitize and enhance the ICQ process.

## What We're Building

A **single-file static HTML/CSS/JS portal** (`C:\Repo\ICQ\index.html`) with:

- **Tab 1 (Full ICQ)**: All questions from both templates + new additions, interactive with fill-and-save
- **Tab 2 (New Questions)**: Delta view showing only the additional questions we've added vs the original templates
- **On-Prem / SaaS toggle**: Shows/hides template-specific sections and questions
- **Dark theme**: Matching existing Certero dashboards

## Tech Stack

Pure static site - no backend:
- HTML5 / CSS3 / Vanilla JavaScript
- localStorage for saving responses
- JSON export for completed questionnaires
- Dark theme matching existing dashboards (`--bg: #0a0e1a`, `--accent: #7a00df`, `--cyan: #34e2e4`)

## File to Create

**`C:\Repo\ICQ\index.html`** - Single file containing all CSS, HTML structure, question data (embedded JSON), and application logic.

## Data Model

Questions are defined in an embedded `ICQ_DATA` JavaScript constant:

```
ICQ_DATA = {
  meta: { title, version, lastUpdated },
  sections: [{
    id: "6.1",
    title: "Organizational Structure",
    category: "about-you" | "about-solution",
    scope: "both" | "onprem" | "saas",
    conditional: false,              // true = can be toggled out of scope
    conditionalLabel: "...",
    questions: [{
      ref: "6.1.1",
      text: "...",
      whyRelevant: "...",
      exampleResponse: "...",
      scope: "both" | "onprem" | "saas",
      isNew: false,                  // true = added beyond original template
      inputType: "textarea"          // textarea | text | select
    }]
  }]
}
```

- `scope` on sections AND questions controls On-Prem/SaaS visibility
- `isNew: true` drives the delta tab (Tab 2)
- `conditional: true` adds an "In Scope" toggle to collapse/grey-out sections

## localStorage Schema

Key: `icq_portal_data`
```
{
  templateMode: "onprem" | "saas",
  customerName: "...",
  responses: { "6.1.1": "answer text", ... },
  sectionsInScope: { "6.8": false },
  sectionsCollapsed: { "6.1": true }
}
```
Auto-saves on every input (300ms debounce).

## UI Structure

1. **Header**: Title, customer name input, On-Prem/SaaS toggle, Export/Reset buttons
2. **Summary cards**: Total questions, Answered, Remaining, Progress %
3. **Tabs**: Full ICQ | New Questions (with counts)
4. **Collapsible sections**: Grouped by "About You" (6.x) and "About the Solution" (7.x)
5. **Question cards**: Ref number, question text, expandable "Why relevant" and "Example response", textarea for answer, NEW badge where applicable

## Section Structure (matching ICQ templates + additions)

### About You (6.x)
| Section | Scope | Conditional | Notes |
|---------|-------|-------------|-------|
| 6.1 Organizational Structure | both | no | From template |
| 6.2 Number & Type of Devices | both | no | From template |
| 6.3 Active Directory | both | no | From template |
| 6.4 Email | both | no | From template |
| 6.5 Virtualization | both | no | From template, expanded with Nutanix/oVirt/XenServer |
| 6.6 Network Infrastructure | both | no | From template |
| 6.7 Information Security | both | no | From template |
| 6.8 Patch Management | both | yes | From template |
| 6.9 Input into Project Planning | both | no | From template |

### About the Solution (7.x)
| Section | Scope | Conditional | Notes |
|---------|-------|-------------|-------|
| 7.1 Application Server | onprem | no | From On-Prem template only |
| 7.2 Database Server | onprem | no | From On-Prem template only |
| 7.3 Certero Client Agent | both | no | From template |
| 7.4 Networks | both | no | From template |
| 7.5 Information Security | both | no | From template |
| 7.6 Email & Alerting | both | no | From template |
| 7.7 Certero Customer Centre | both | no | From template |
| 7.8 Distribution | both | yes | From template |
| 7.9 Application Monitoring | both | yes | From template |
| 7.10 Patch Management | both | yes | From template (On-Prem has WSUS questions) |
| 7.11 SNMP Network Discovery | both | yes | **NEW** |
| 7.12 SaaS Connectors - Microsoft 365 | both | yes | **NEW** |
| 7.13 SaaS Connectors - Adobe CC | both | yes | **NEW** |
| 7.14 SaaS Connectors - Salesforce | both | yes | **NEW** |
| 7.15 SaaS Connectors - Google Workspace | both | yes | **NEW** |
| 7.16 Microsoft Intune | both | yes | **NEW** |
| 7.17 Cisco Meraki | both | yes | **NEW** |
| 7.18 ServiceNow Integration | both | yes | **NEW** |
| 7.19 Oracle Database Connector | both | yes | **NEW** |
| 7.20 IBM ILMT Connector | both | yes | **NEW** |
| 7.21 SAP Connector | both | yes | **NEW** |
| 7.22 Warranty | both | no | Enhanced from template (Dell + Lenovo API credentials) |
| 7.23 Additional Virtualization | both | yes | **NEW** (Nutanix, oVirt, XenServer) |

## Key Features

1. **On-Prem/SaaS Toggle**: Pill-style toggle filters sections and questions by scope
2. **Delta Tab**: Filters to show only `isNew: true` questions, hides sections with no new questions
3. **Auto-save**: localStorage with debounced save, visual indicator
4. **Collapsible sections**: Click header to expand/collapse, state persisted
5. **Conditional sections**: "In Scope" checkbox toggle, greys out when unchecked
6. **Progress tracking**: Per-section and overall, updates dynamically
7. **Export JSON**: Downloads structured JSON with all responses
8. **Reset**: Confirmation modal, clears all data
9. **Responsive**: Works on desktop, tablet, mobile

## Implementation Steps

1. Create `C:\Repo\ICQ\index.html` with CSS foundation (dark theme variables copied from existing dashboards)
2. Build HTML skeleton (header, cards, tabs, container, modal)
3. Build the full `ICQ_DATA` JSON from:
   - On-Prem template content (already extracted)
   - SaaS template content (already extracted)
   - New questions identified in gap analysis
   - Mark all new questions with `isNew: true`
4. Implement render pipeline (`renderICQ`, `renderSection`, `renderQuestion`)
5. Implement template mode toggle with visibility filtering
6. Implement localStorage save/load with debounced auto-save
7. Implement progress calculation and summary cards
8. Implement tab switching (Full ICQ / New Questions delta filter)
9. Implement collapsible sections and conditional scope toggles
10. Implement export JSON and reset with confirmation modal
11. Add responsive media queries

## Verification

1. Open `C:\Repo\ICQ\index.html` in a browser
2. Verify On-Prem/SaaS toggle shows/hides correct sections (7.1 App Server, 7.2 DB Server only in On-Prem)
3. Verify "New Questions" tab shows only questions with amber NEW badge
4. Fill in several responses, refresh page - verify they persist via localStorage
5. Toggle a conditional section off/on - verify it collapses/expands
6. Click Export - verify JSON download contains responses
7. Click Reset - verify confirmation modal appears and clears all data
8. Test responsive layout at different widths
