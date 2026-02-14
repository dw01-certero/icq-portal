---
name: icq-validate
description: Validate the ICQ portal data structure for errors and inconsistencies
user-invocable: true
argument-hint: "[--fix]"
allowed-tools: Read, Grep, Glob, Edit
---

# Validate ICQ Portal

Validate the `ICQ_DATA` structure in `index.html` for structural errors, inconsistencies, and data quality issues.

## Usage

```
/icq-validate          # Report only
/icq-validate --fix    # Report and auto-fix where possible
```

## Validation Checks

### 1. Structural Integrity
- [ ] `ICQ_DATA` constant exists and is valid JavaScript
- [ ] `meta` object has `title`, `version`, `lastUpdated`
- [ ] `sections` is a non-empty array
- [ ] Every section has required fields: `id`, `title`, `category`, `scope`, `questions`
- [ ] Every question has required fields: `ref`, `text`, `scope`, `isNew`, `inputType`

### 2. ID Uniqueness
- [ ] All section IDs are unique
- [ ] All question refs are unique across all sections
- [ ] No empty or null IDs

### 3. Numbering Consistency
- [ ] Section IDs follow sequential order (1.0, 1.1, ..., 2.1, 2.2, ...)
- [ ] Question refs match their parent section ID (e.g., `2.12.1` is in section `2.12`)
- [ ] Question numbers within a section are sequential (X.X.1, X.X.2, ...)
- [ ] No gaps in numbering

### 4. Scope Validation
- [ ] All scope values are one of: "both", "onprem", "saas"
- [ ] Question scope is compatible with section scope (question can't be "onprem" if section is "saas")
- [ ] Category values are "about-you" or "about-solution"

### 5. Tech Selector Consistency
- [ ] If `hasTechSelector: true`, section has `techOptions` array
- [ ] `techOptions` has at least one entry with `key` and `label`
- [ ] All questions in tech-selector sections have `techGroup` property
- [ ] `techGroup` values match one of the `techOptions` keys
- [ ] No orphaned `techGroup` values (referring to non-existent tech options)

### 6. Input Type Validation
- [ ] All `inputType` values are one of: "textarea", "text", "select"
- [ ] Questions with `inputType: "select"` have an `options` array
- [ ] Options arrays have at least 2 entries
- [ ] No questions with `inputType: "select"` missing options

### 7. Conditional Section Checks
- [ ] If `conditional: true`, section has `conditionalLabel` string
- [ ] `conditionalLabel` is not empty

### 8. Content Quality
- [ ] Question text ends with appropriate punctuation (? or .)
- [ ] `whyRelevant` field is present on all questions (warning if missing)
- [ ] `exampleResponse` field is present on all questions (warning if missing)
- [ ] No duplicate question text within the same section

## Output Format

```markdown
## ICQ Validation Report

**Date:** [Date]
**File:** index.html
**Sections:** [count]
**Questions:** [total count]

### Summary

| Check | Status | Issues |
|-------|--------|--------|
| Structural Integrity | PASS/FAIL | [count] |
| ID Uniqueness | PASS/FAIL | [count] |
| Numbering Consistency | PASS/FAIL | [count] |
| Scope Validation | PASS/FAIL | [count] |
| Tech Selector | PASS/FAIL | [count] |
| Input Types | PASS/FAIL | [count] |
| Conditional Sections | PASS/FAIL | [count] |
| Content Quality | PASS/WARN | [count] |

### Critical Issues (Must Fix)
[List each with section/question ref and fix needed]

### Warnings
[List each with recommendation]

### All Clear
[List checks that passed]
```

### 9. Customer Portal Config
- [ ] `CUSTOMER_CONFIG` placeholder comment exists: `/* const CUSTOMER_CONFIG = null; */`
- [ ] `isLockedSection()` function exists and references `CUSTOMER_CONFIG`
- [ ] `loadState()` applies CUSTOMER_CONFIG (always enforces identity/mode/locked sections)
- [ ] `passGate()` auto-bypasses gate when CUSTOMER_CONFIG is present
- [ ] `passGate()` greys out non-relevant mode toggle for customer portals
- [ ] `setMode()` blocks mode switching when CUSTOMER_CONFIG is present
- [ ] `toggleScope()` prevents toggling locked sections back to in-scope
- [ ] `renderSection()` suppresses scope toggle checkbox on locked sections
- [ ] `renderSection()` adds `locked-notice` banner on locked sections
- [ ] Locked-scope CSS classes exist (`.locked-scope`, `.locked-notice`)
- [ ] `exportJSON()` includes `jiraTicket` in meta when CUSTOMER_CONFIG present
- [ ] `allowedTechs` keys (if present) correspond to sections with `hasTechSelector: true`
- [ ] `allowedTechs` values are valid tech option keys for that section
- [ ] All sections start collapsed in customer portals (`sectionsCollapsed` forced to `true`)

## Auto-Fix Behavior (--fix flag)

When `--fix` is passed:
- Fix sequential numbering gaps
- Add missing `techGroup` to questions in tech-selector sections
- Add missing `conditionalLabel` with sensible default
- Do NOT fix duplicate IDs (requires manual resolution)
- Do NOT fix scope conflicts (requires understanding intent)

## Validating Customer Portals

When validating files in `customers/*/index.html`:
- Check that `CUSTOMER_CONFIG` is a real object (not the commented placeholder)
- Verify all locked section IDs in `lockedSections` correspond to actual section IDs in `ICQ_DATA`
- Verify `preSelectedTechs` keys correspond to sections with `hasTechSelector: true`
- Verify `preSelectedTechs` values are valid tech option keys for that section
- Verify Reset button has `style="display:none"`
- Verify page title includes customer name
- Verify header includes customer name
- Verify Jira reference footer is present with correct ticket key and link
- Verify non-relevant mode toggle is greyed out (opacity 0.3, pointer-events none)
