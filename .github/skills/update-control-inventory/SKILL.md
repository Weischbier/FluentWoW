---
name: update-control-inventory
description: >
  Synchronize all control tracking surfaces after a control is added, modified, or removed.
  Updates MasterPlan, PortabilityMatrix, ARCHITECTURE.md, and CHANGELOG.
---

# update-control-inventory

## When to Use

- After a new control is ported and merged
- After a control is deprecated or removed
- During periodic inventory audits

## Prerequisites

1. The control must be fully scaffolded (or confirmed removed)
2. Read current state of all inventory surfaces

## Inputs

| Input | Required | Description |
|---|---|---|
| `controlName` | Yes | e.g., `NavigationView` |
| `action` | Yes | `added`, `updated`, `deprecated`, `removed` |
| `version` | No | Version in which the action occurs |

## Steps

### 1. Update `.docs/MasterPlan.md` §4

- If `added`: add row to Implemented table with name, template, factory method, gallery page
- If `deprecated`: move to Deprecated table with removal target version
- If `removed`: delete from all tables

### 2. Update `.docs/PortabilityMatrix.md`

- If `added`: set status to ✅ Implemented
- If `deprecated`: add note "Deprecated in v{version}"
- If `removed`: set status to 🗑️ Removed

### 3. Update `ARCHITECTURE.md` §5 Control Catalog

- Add or remove the control entry in the catalog table

### 4. Update `CHANGELOG.md`

- If `added`: add under `### Added`
- If `deprecated`: add under `### Deprecated`
- If `removed`: add under `### Removed`

### 5. Verify Count Consistency

Count controls in each surface and verify they match:
- TOC file entries (count XML/Lua pairs in Controls section)
- MasterPlan §4 Implemented table rows
- ARCHITECTURE.md §5 catalog rows
- Filesystem: count directories under `WinUILib/Controls/`

Also verify pixel-fidelity:
- Check `.docs/DesignSpecs.md` has measurements for the control (if applicable)
- Ensure the control's spacing values use design-spec-aligned tokens

Report any discrepancies.

## Outputs

| Output | Description |
|---|---|
| MasterPlan.md | Updated §4 |
| PortabilityMatrix.md | Updated status |
| ARCHITECTURE.md | Updated §5 |
| CHANGELOG.md | Updated |
| Count verification | Reported |
