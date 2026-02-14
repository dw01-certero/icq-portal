---
name: icq-save-session
description: Save ICQ conversation summary to markdown file before ending session
user-invocable: true
argument-hint: "[optional-filename]"
allowed-tools: Write, Read, Glob, Bash
---

# Save ICQ Session

Save a structured conversation summary for the ICQ portal project. Creates a markdown file with session details for continuity.

## Usage

```
/icq-save-session
/icq-save-session my-session-name
```

## Default Behavior

- **Filename:** `session-YYYY-MM-DD.md` (or custom name if provided)
- **Location:** `C:\Repo\ICQ\sessions\`
- **Format:** Structured markdown summary

## Summary Structure

Generate a summary with these sections:

```markdown
# ICQ Session Summary - [DATE]

## Session Overview
- **Date:** [YYYY-MM-DD]
- **Main Focus:** [1-2 sentence description]

## Changes Made
[Bulleted list of changes to the ICQ portal]

## Sections Modified
| Section | Change | Details |
|---------|--------|---------|
| 2.12 | Added tech selector | Intune confirmation toggle |
| 2.16 | Removed | Additional Virtualization Platforms |

## Questions Added/Removed
| Ref | Action | Text |
|-----|--------|------|
| 2.17.1 | Added | Who is responsible for SAM? |

## Current State
- **Total Sections:** [count]
- **Total Questions:** [count]
- **New Questions:** [count]
- **Sections with Tech Selectors:** [list]

## Customer Portals Generated
| Customer | Jira Ticket | Hosting | URL |
|----------|------------|---------|-----|
| ROMO | TMT4-154 | On-Prem | https://dw01-certero.github.io/icq-portal/customers/ROMO/ |

## Git Status
- **Branch:** [current branch]
- **Unpushed commits:** [count]
- **Uncommitted changes:** [list]

## Issues Encountered
[Any errors, file locks, or problems and how they were resolved]

## Next Steps
[What needs to be done next]
```

## Process

1. **Review** the conversation for ICQ-related changes
2. **Read** `index.html` to get current section/question counts
3. **Check** `customers/` directory for any generated customer portals
4. **Check** git status for uncommitted or unpushed changes
5. **Generate** the summary markdown
6. **Write** to the sessions directory
7. **Confirm** the file was saved
