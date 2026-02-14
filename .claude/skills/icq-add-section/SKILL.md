---
name: icq-add-section
description: Add a new section with questions to the ICQ portal
user-invocable: true
argument-hint: "<section-title> [--after <section-id>] [--conditional] [--tech-selector]"
allowed-tools: Read, Edit, Grep, Glob
---

# Add ICQ Section

Add a new section with questions to the ICQ portal's `ICQ_DATA` structure.

## Usage

```
/icq-add-section "Certero for Cloud"
/icq-add-section "Backup & Recovery" --after 2.15 --conditional
/icq-add-section "AWS Connector" --after 2.20 --conditional --tech-selector
```

## Process

1. **Read** the current `index.html` (or `index2.html` if locked) to find the `ICQ_DATA.sections` array
2. **Determine** the next section ID based on `--after` flag or the last existing section
3. **Ask** the user for the questions to include (or accept from reference material)
4. **Build** the section object following the ICQ data model
5. **Insert** the section into the correct position in the sections array
6. **Renumber** subsequent sections if inserting in the middle

## Section Template

```javascript
{
  id: "X.XX",
  title: "[Section Title]",
  category: "about-solution",  // or "about-you" for 1.x sections
  scope: "both",               // "both" | "onprem" | "saas"
  conditional: true,           // if --conditional flag
  conditionalLabel: "[Title] module in scope",
  // Only if --tech-selector:
  hasTechSelector: true,
  techOptions: [
    { key: "keyname", label: "Yes, we use [Technology]" }
  ],
  questions: [
    {
      ref: "X.XX.1",
      text: "Question text here?",
      whyRelevant: "Why this question matters for implementation.",
      exampleResponse: "Example answer",
      scope: "both",
      isNew: true,
      inputType: "textarea",   // or "text" or "select"
      // Only if tech selector:
      techGroup: "keyname"
    }
  ]
}
```

## Rules

1. **Section IDs** follow the pattern `1.X` (About You) or `2.X` (About the Solution)
2. **Question refs** follow the pattern `{sectionId}.{questionNumber}` (e.g., `2.22.1`)
3. New questions should have `isNew: true` to appear in the New Questions tab
4. If adding a tech selector, every question must have a `techGroup` property
5. `conditionalLabel` should describe what being "in scope" means
6. Always verify no duplicate IDs exist after insertion
7. If inserting in the middle, renumber all subsequent sections and their question refs

## Reference Material

Check `Reference Material/` directory for existing question templates:
- `icq-common-sections.md` - Common ICQ questions
- `icq-appcentre.md` through `icq-c4sap.md` - Product-specific questions

## Validation

After adding, verify:
- [ ] Section ID is unique
- [ ] All question refs are unique
- [ ] techGroup matches techOptions keys (if applicable)
- [ ] scope is valid ("both", "onprem", or "saas")
- [ ] inputType is valid ("textarea", "text", or "select")
- [ ] options array exists if inputType is "select"

## Customer Portal Impact

When adding new sections that correspond to purchasable Certero products or modules:
1. Update the **product-to-section mapping** in `.claude/skills/icq-generate/SKILL.md`
2. Existing generated customer portals in `customers/` are **not** automatically updated
3. If the new section is `conditional: true`, it can be locked via `CUSTOMER_CONFIG.lockedSections` in customer portals
4. After adding, regenerate affected customer portals with `/icq-generate` (this also commits, pushes, and updates Jira links/comments)
5. GitHub Pages URL: `https://dw01-certero.github.io/icq-portal/customers/<NAME>/`
6. If the new section has `hasTechSelector: true`, update the `allowedTechs` logic in both `batch-generate.ps1` and `generate-customer.ps1` to support restricting tech options for the new section in customer portals
