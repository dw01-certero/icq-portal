---
name: icq-tech-selector
description: Add or modify a technology selector on an ICQ section
user-invocable: true
argument-hint: "<section-id> [--add <key:label>] [--remove <key>]"
allowed-tools: Read, Edit, Grep
---

# ICQ Tech Selector

Add, modify, or remove technology selector pills on an ICQ section. Tech selectors allow users to indicate which technologies they use, and questions are shown/hidden based on the selection.

## Usage

```
/icq-tech-selector 2.12                              # Show current tech selector config
/icq-tech-selector 2.12 --add "intune:Yes, we use Microsoft Intune"
/icq-tech-selector 2.18 --add "aix:IBM AIX" --add "solaris:Oracle Solaris"
/icq-tech-selector 2.12 --remove intune
```

## How Tech Selectors Work

1. Section has `hasTechSelector: true` and a `techOptions` array
2. Each tech option is a pill button: `{ key: "keyname", label: "Display text" }`
3. Users click pills to select/deselect technologies
4. Questions with matching `techGroup` property are shown when that tech is selected
5. Questions without `techGroup` are always visible
6. Selection state is saved in `selectedTechs` in localStorage

## Process

### Adding a Tech Selector to a Section

1. Read the section in `ICQ_DATA`
2. Add `hasTechSelector: true` to the section
3. Add `techOptions` array with the specified options
4. Add `techGroup` property to all existing questions in the section
5. If the section has a single tech option, set all questions to that techGroup
6. If multiple options, ask the user which questions belong to which group

### Modifying Tech Options

1. Read the current `techOptions` array
2. Add or remove the specified options
3. Update question `techGroup` values as needed
4. Warn if removing a tech option that questions still reference

### Removing a Tech Selector

1. Remove `hasTechSelector` and `techOptions` from the section
2. Remove `techGroup` from all questions in the section

## Validation

After modification:
- [ ] Every `techGroup` value on questions matches a `techOptions` key
- [ ] No orphaned tech groups (questions referencing removed options)
- [ ] If `hasTechSelector: true`, at least one techOption exists
- [ ] All techOption keys are unique within the section

## Examples

### Single-Technology Confirmation
For sections like Intune, Meraki, ServiceNow where you just need a yes/no:
```javascript
hasTechSelector: true,
techOptions: [
  { key: "intune", label: "Yes, we use Microsoft Intune" }
]
```

### Multi-Technology Selection
For sections like C4IBM where multiple technologies may apply:
```javascript
hasTechSelector: true,
techOptions: [
  { key: "solaris", label: "Oracle Solaris" },
  { key: "hpux", label: "HP-UX" },
  { key: "aix", label: "IBM AIX" },
  { key: "subcapacity", label: "IBM Sub-Capacity Reporting" },
  { key: "powervm", label: "IBM PowerVM" }
]
```
