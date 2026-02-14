---
name: icq-renumber
description: Renumber ICQ sections and question refs after additions or removals
user-invocable: true
argument-hint: "[--from <section-id>] [--preview]"
allowed-tools: Read, Edit, Grep
---

# Renumber ICQ Sections

Renumber section IDs and question reference numbers after sections have been added, removed, or reordered.

## Usage

```
/icq-renumber                    # Renumber all sections sequentially
/icq-renumber --from 2.16        # Renumber from section 2.16 onwards
/icq-renumber --preview          # Show what would change without editing
```

## Process

1. **Read** the current `ICQ_DATA.sections` array from `index.html`
2. **Identify** gaps or inconsistencies in numbering
3. **Calculate** new sequential IDs (1.0, 1.1, ..., 2.1, 2.2, ...)
4. **Preview** changes if `--preview` flag is set
5. **Apply** renumbering to:
   - Section `id` fields
   - All question `ref` fields within each section
   - `conditionalLabel` if it references the section number

## Rules

1. **About You** sections use `1.x` numbering (category: "about-you")
2. **About the Solution** sections use `2.x` numbering (category: "about-solution")
3. Question refs follow `{sectionId}.{questionNumber}` pattern
4. Question numbers within a section are always sequential starting from 1
5. Section order in the array determines the numbering
6. The `--from` flag only renumbers sections at or after the specified ID

## Example

Before (gap after removing section 2.16):
```
2.15 Warranty
2.17 Enterprise SAM    <- gap
2.18 Certero for IBM
```

After renumbering:
```
2.15 Warranty
2.16 Enterprise SAM    <- renumbered
2.17 Certero for IBM   <- renumbered
```

All question refs update accordingly:
- `2.17.1` -> `2.16.1`
- `2.17.2` -> `2.16.2`
- `2.18.1` -> `2.17.1`

## Preview Output

```markdown
## Renumbering Preview

| Current ID | New ID | Title | Questions Affected |
|------------|--------|-------|--------------------|
| 2.17 | 2.16 | Enterprise SAM | 2 (2.17.1-2.17.2 -> 2.16.1-2.16.2) |
| 2.18 | 2.17 | Certero for IBM | 19 (2.18.1-2.18.19 -> 2.17.1-2.17.19) |
```

## Safety

- Always creates a preview before applying changes
- Verifies no duplicate IDs would result from renumbering
- Does not change the order of sections, only the numbering

## Customer Portal Impact

Renumbering sections in the base template **breaks existing customer portals** because:
- `CUSTOMER_CONFIG.lockedSections` references section IDs by number (e.g., `"2.16"`)
- `CUSTOMER_CONFIG.preSelectedTechs` references section IDs by number (e.g., `"2.20"`)
- The product-to-section mapping in `.claude/skills/icq-generate/SKILL.md` uses section numbers

After renumbering:
1. Update the product-to-section mapping in `icq-generate/SKILL.md`
2. Regenerate all customer portals in `customers/` using `/icq-generate`
3. Commit and push to update GitHub Pages (`pages.yml` deploys from repo root)
4. Jira remote links on tickets will still work since the URL uses customer name, not section IDs
5. Jira comments referencing section counts may become stale — consider re-commenting
