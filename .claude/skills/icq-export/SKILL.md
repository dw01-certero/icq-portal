---
name: icq-export
description: Export ICQ section data, question list, or structure summary
user-invocable: true
argument-hint: "[sections|questions|summary|reference] [--section <id>] [--new-only] [--format <md|json|csv>]"
allowed-tools: Read, Write, Grep, Glob
---

# Export ICQ Data

Export section data, question lists, or structural summaries from the ICQ portal.

## Usage

```
/icq-export summary                    # Overall structure summary
/icq-export sections                   # All sections as JSON
/icq-export sections --section 2.18    # Single section as JSON
/icq-export questions                  # All questions as markdown table
/icq-export questions --new-only       # Only isNew:true questions
/icq-export questions --format csv     # Questions as CSV
/icq-export reference --section 2.18   # Generate reference material markdown
```

## Export Types

### summary
Generates a markdown overview of the entire ICQ structure:
- Total sections and questions count
- Section list with question counts
- Tech selector summary
- Conditional section summary
- New question count per section

### sections
Exports section data as JSON:
- Full section objects with all questions
- Can filter to a single section with `--section`
- Output saved to `exports/icq-sections-YYYY-MM-DD.json`

### questions
Exports a flat question list:
- **Markdown (default):** Table with ref, text, section, isNew, inputType
- **CSV:** Comma-separated with headers
- **JSON:** Array of question objects
- Filter to new questions only with `--new-only`
- Filter to specific section with `--section`

### reference
Generates reference material markdown for a section:
- Formatted like the files in `Reference Material/`
- Includes all questions with whyRelevant and exampleResponse
- Useful for documentation or sharing with stakeholders

## Output Location

All exports saved to `C:\Repo\ICQ\exports\` directory (created if needed).

## Examples

### Export New Questions for Review
```
/icq-export questions --new-only --format md
```
Outputs:
```markdown
| Ref | Section | Question | Type |
|-----|---------|----------|------|
| 1.0.1 | Environment Overview | How would you describe... | select |
| 1.3.2 | Active Directory | Do you use Azure AD... | select |
```

### Export Section as Reference Material
```
/icq-export reference --section 2.19
```
Creates a markdown file matching the `Reference Material/` format.

### Export Customer Portal Scope
```
/icq-export customer-scope --customer ROMO
```
Reads `customers/ROMO/index.html`, extracts the `CUSTOMER_CONFIG`, and outputs a scope summary:
- Customer name, user, hosting model, Jira ticket
- In-scope sections (with product mapping)
- Locked sections (with reason)
- Pre-selected tech options

### customers
Lists all generated customer portals from the `customers/` directory:
- Customer name (folder name)
- Jira ticket (from CUSTOMER_CONFIG)
- Hosting model
- Number of in-scope vs locked sections
- GitHub Pages URL (`https://dw01-certero.github.io/icq-portal/customers/<NAME>/`)
- Jira remote link status (if link exists on ticket)
