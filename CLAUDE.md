# ICQ Portal - AI Context

> **Purpose:** This file provides context for AI assistants working with the ITAM ICQ (Implementation & Configuration Questionnaire) Portal.

---

## Quick Reference

| Field | Value |
|-------|-------|
| **Project** | ITAM ICQ Portal |
| **Version** | 2.0 |
| **Last Updated** | 2026-02-14 |
| **Technology** | Single-file static HTML/CSS/JS |
| **Main File** | `index.html` (or `index2.html` if index.html is locked) |
| **Reference Material** | `Reference Material/` directory |
| **Future Sections** | `future-icq-sections.js` |

---

## Architecture

The ICQ Portal is a **single-file static HTML application** with no backend dependencies.

### Tech Stack
- HTML5 / CSS3 / Vanilla JavaScript
- localStorage for auto-save (300ms debounce)
- JSON export for completed questionnaires
- Dark theme with Certero brand colors

### CSS Variables
```css
--bg: #0c0a1a
--accent: #7a00df
--cyan: #34e2e4
--gradient-brand: linear-gradient(135deg, #34e2e4, #4721fb, #ab1dfe)
```

---

## Data Model

All questions are defined in the embedded `ICQ_DATA` JavaScript constant within `index.html`.

### Section Structure
```javascript
{
  id: "2.12",                    // Section number
  title: "Microsoft Intune",     // Display title
  category: "about-solution",    // "about-you" (1.x) or "about-solution" (2.x)
  scope: "both",                 // "both" | "onprem" | "saas"
  conditional: true,             // true = has In Scope toggle
  conditionalLabel: "...",       // Toggle label text
  hasTechSelector: true,         // true = has technology pill selector
  techOptions: [                 // Technology pills (only if hasTechSelector)
    { key: "intune", label: "Yes, we use Microsoft Intune" }
  ],
  questions: [...]
}
```

### Question Structure
```javascript
{
  ref: "2.12.1",                 // Question reference number
  text: "...",                   // Question text
  whyRelevant: "...",            // Expandable explanation
  exampleResponse: "...",        // Expandable example
  scope: "both",                 // Visibility filter
  isNew: true,                   // true = shows NEW badge, appears in delta tab
  inputType: "textarea",         // "textarea" | "text" | "select"
  options: [...],                // Only for inputType: "select"
  techGroup: "intune"            // Only if section has hasTechSelector
}
```

### localStorage Schema
Key: `icq_portal_data`
```json
{
  "templateMode": "onprem",
  "customerName": "...",
  "userName": "...",
  "responses": { "2.12.1": "answer text" },
  "sectionsInScope": { "2.12": false },
  "sectionsCollapsed": { "2.12": true },
  "assignees": { "2.12": "John Smith" },
  "selectedTechs": { "2.12": { "intune": true } },
  "auditLog": [...]
}
```

---

## Current Section Structure

### About You (1.x)
| Section | Title | Conditional |
|---------|-------|-------------|
| 1.0 | Environment Overview | No |
| 1.1 | Organizational Structure | No |
| 1.2 | Number & Type of Devices | No |
| 1.3 | Active Directory | No |
| 1.4 | Email | No |
| 1.5 | Virtualization | No |
| 1.6 | Network Infrastructure | No |
| 1.7 | Information Security | No |
| 1.8 | Patch Management | Yes |
| 1.9 | Input into Project Planning | No |

### About the Solution (2.x)
| Section | Title | Conditional | Tech Selector |
|---------|-------|-------------|---------------|
| 2.1 | Application Server | No | No |
| 2.2 | Database Server | No | No |
| 2.3 | Certero Client Agent | No | No |
| 2.4 | Networks | No | No |
| 2.5 | Information Security | No | No |
| 2.6 | Email & Alerting | No | No |
| 2.7 | Certero Customer Centre | No | No |
| 2.8 | Distribution | Yes | No |
| 2.9 | Application Monitoring | Yes | No |
| 2.10 | Patch Management | Yes | No |
| 2.11 | SNMP Network Discovery | Yes | No |
| 2.12 | Microsoft Intune | Yes | Yes (intune) |
| 2.13 | Cisco Meraki | Yes | Yes (meraki) |
| 2.14 | ServiceNow Integration | Yes | Yes (servicenow) |
| 2.15 | Warranty | No | No |
| 2.16 | App-Centre | Yes | No |
| 2.17 | Enterprise SAM | Yes | No |
| 2.18 | Certero for IBM | Yes | Yes (solaris, hpux, aix, subcapacity, powervm) |
| 2.19 | Certero for Oracle | Yes | Yes (database, middleware, ebs) |
| 2.20 | Certero for SaaS | Yes | Yes (12 SaaS platforms) |
| 2.21 | Certero for SAP | Yes | No |

---

## UI Features

1. **Gate Modal** - Requires userName + customerName before accessing portal
2. **On-Prem/SaaS Toggle** - Filters sections/questions by deployment scope
3. **Three Tabs** - Full ICQ (in-scope) | Out of Scope | New Questions (delta)
4. **Collapsible Sections** - Click header to expand/collapse, state persisted
5. **Conditional Sections** - "In Scope" checkbox toggle
6. **Tech Selector Pills** - Dynamic technology selectors that show/hide questions
7. **Per-Section Progress** - Progress bars on each section header
8. **Assignee Fields** - Per-section assignee input in header banner
9. **Sticky Headers** - Header and stats bar stick on scroll
10. **Auto-Save** - localStorage with 300ms debounce
11. **Audit Log** - Timestamped entries for logins, answers, scope changes
12. **Export JSON** - Downloads structured JSON with all responses
13. **Save/Load Progress** - JSON file save/load for portability

---

## Reference Material

Located in `Reference Material/` directory:

| File | Content |
|------|---------|
| `icq-common-sections.md` | Questions from the common ICQ template sections |
| `icq-appcentre.md` | App-Centre module questions |
| `icq-c4esam.md` | Enterprise SAM module questions |
| `icq-c4ibm.md` | Certero for IBM questions |
| `icq-c4oracle.md` | Certero for Oracle questions |
| `icq-c4saas.md` | Certero for SaaS questions |
| `icq-c4sap.md` | Certero for SAP questions |
| `icq-aci-example.md` | ACI example questionnaire |

Original Word templates are also stored here (15 .docx files).

---

## Key Patterns

### Adding a New Section
1. Add section object to `ICQ_DATA.sections` array in `index.html`
2. Follow the data model structure above
3. Use the next available section number (e.g., 2.22)
4. Set `conditional: true` for optional modules
5. Add `hasTechSelector` + `techOptions` if technology confirmation is needed
6. Set `techGroup` on questions that should be filtered by tech selection
7. Mark new questions with `isNew: true`

### Adding a Tech Selector
1. Add `hasTechSelector: true` to the section
2. Add `techOptions: [{ key: "keyname", label: "Display text" }]`
3. Add `techGroup: "keyname"` to each question that should be filtered

### Renumbering After Removal
When removing a section, renumber all subsequent sections and their question refs.

---

## File Lock Issue

The browser (Chrome) can hold an exclusive lock on `index.html` when it's open. If editing fails with EBUSY:
1. Close the browser tab showing the ICQ portal
2. If the lock persists, edit a copy (e.g., `index2.html`) and replace when unlocked
3. The `copy-fix.ps1` script uses FileShare.ReadWrite to attempt writes past shared locks

---

## Available Skills

| Skill | Command | Purpose |
|-------|---------|---------|
| icq-add-section | `/icq-add-section` | Add a new section with questions |
| icq-validate | `/icq-validate` | Validate ICQ_DATA structure |
| icq-tech-selector | `/icq-tech-selector` | Add/modify tech selector on a section |
| icq-export | `/icq-export` | Export section data or question list |
| icq-save-session | `/icq-save-session` | Save conversation summary |
| icq-renumber | `/icq-renumber` | Renumber sections after changes |
| icq-generate | `/icq-generate` | Generate customer-facing ICQ portal from Jira ticket |

## Available Agents

| Agent | Purpose |
|-------|---------|
| icq-section-builder | Build complete sections from reference material |
| icq-reference-analyzer | Analyze Word templates and extract questions |
| icq-qa | Quality assurance testing of the portal |

---

## Customer Portal Generation

The ICQ portal supports generating customer-specific portals from Jira TMT4 onboarding tickets.

### Key Files
| File | Purpose |
|------|---------|
| `index.html` / `index2.html` | Base template with `CUSTOMER_CONFIG` support |
| `generate-customer.ps1` | PowerShell script to inject config and generate portal |
| `customers/` | Output directory for generated portals |
| `customers/index.html` | Landing page listing all portals |
| `customers/assets/icq-icon.svg` | Certero-branded icon for Jira remote links |
| `batch-generate.ps1` | Canonical batch generation script — contains all 23 parent ticket data, runs full regeneration pipeline. Parent tickets are TMT4 tickets whose summary does NOT contain "ICQ". |
| `.github/workflows/pages.yml` | GitHub Pages deployment (deploys repo root) |

### CUSTOMER_CONFIG
When present at the top of the `<script>` block, the `CUSTOMER_CONFIG` object:
- Auto-bypasses the gate modal
- Pre-populates customer name, user name, and deployment mode
- Locks non-purchased sections via three-tier locking (see below)
- Pre-selects technology options via `preSelectedTechs` (e.g., SaaS connectors)
- Greys out the non-relevant hosting mode toggle
- Restricts visible tech options per section via `allowedTechs` — keys are section IDs, values are arrays of allowed tech option keys; empty array `[]` hides ALL options
- Forces all sections to start collapsed (`sectionsCollapsed: true`)
- Forces Full ICQ tab active on every load (`activeTab: 'full'`)
- Adds Jira ticket reference to exported JSON

### Three-Tier Section Locking
- **Tier 1 — Lockable by product/module:** 1.8, 2.8, 2.9, 2.10, 2.16, 2.17, 2.18, 2.19, 2.20, 2.21. Greyed out with notice banner if not purchased.
- **Tier 2 — Always shown with user toggle (NEVER locked):** 2.11, 2.12, 2.13, 2.14. Always appear with conditional "In Scope" checkbox.
- **Tier 3 — Non-conditional (always in scope when C4EITAM):** 1.0-1.7, 1.9, 2.1-2.7, 2.15.

### Generating a Portal
```
/icq-generate TMT4-154
```
This reads the Jira ticket, maps products/modules to sections, writes to `customers/<NAME>/index.html`, commits and pushes to deploy via GitHub Pages, then adds a remote link and summary comment on the Jira ticket.

### GitHub Pages
- **URL pattern:** `https://dw01-certero.github.io/icq-portal/customers/<NAME>/`
- **Deployment:** `pages.yml` deploys from repo root on push to `main`
- **Do NOT create a separate deploy workflow** — it conflicts with `pages.yml` and causes 404s
- **Folder name sanitization:** Brackets `[]` are stripped from customer folder names for URL safety

### Jira Integration
- **Remote link:** Added to the ticket with `🟣 Open ICQ Portal` title and custom icon
- **Comment:** Summary table posted with customer details and portal URL
- **Icon:** Hosted at `customers/assets/icq-icon.svg` (gradient "Q" on purple)
- **Limitation:** Remote links cannot be deleted via API — must be removed manually from Jira UI

---

## Common Pitfalls

1. **File lock** - Always check if index.html is locked before editing
2. **Duplicate IDs** - Section IDs and question refs must be unique
3. **Missing techGroup** - If a section has `hasTechSelector`, all questions need `techGroup`
4. **Scope consistency** - Question scope must be compatible with section scope
5. **Renumbering** - After removing/reordering sections, renumber everything
6. **Large file** - index.html is 2000+ lines; use targeted edits, not full rewrites
