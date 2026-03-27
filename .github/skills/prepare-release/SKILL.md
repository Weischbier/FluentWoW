---
name: prepare-release
description: >
  Prepare a FluentWoW release by bumping versions, updating changelogs,
  verifying all checks, and preparing packaging metadata.
---

# prepare-release

## When to Use

- When the user says "prepare a release" or "bump version"
- Before tagging and pushing a version

## Prerequisites

1. Read `.docs/ReleaseMaster.md` for the complete release procedure
2. All tests / luacheck must pass

## Inputs

| Input | Required | Description |
|---|---|---|
| `newMinor` | Yes | New MINOR number (e.g., `10100` for v1.1.0) |
| `releaseNotes` | Yes | Summary of what changed in this release |

## Steps

### 1. Bump Versions

Update the MINOR version in all locations:
- `FluentWoW/Core/Bootstrap.lua` — `local MINOR = {newMinor}`
- `FluentWoW/FluentWoW.toc` — `## Version: {dotted}`
- `FluentWoW-Gallery/FluentWoW-Gallery.toc` — `## Version: {dotted}`
- `ARCHITECTURE.md` header version

### 2. Update CHANGELOG.md

- Move `## [Unreleased]` entries to a new `## [{dotted}] - {date}` section
- Add a fresh `## [Unreleased]` header at top

### 3. Run Lint

```
luacheck FluentWoW/ FluentWoW-Gallery/ --config .luacheckrc
```

### 4. Verify Packaging

Check `.pkgmeta` excludes are correct — `.help/`, `.docs/`, `.github/` should not ship.

### 5. Review Checklist

- [ ] Version numbers match across all 4 locations
- [ ] CHANGELOG has dated section for this release
- [ ] Luacheck passes with zero errors
- [ ] ARCHITECTURE.md version matches
- [ ] No TODO/FIXME/HACK comments in shipped code

## Outputs

| Output | Path |
|---|---|
| Bootstrap.lua | Modified — MINOR bumped |
| FluentWoW.toc | Modified — Version bumped |
| FluentWoW-Gallery.toc | Modified — Version bumped |
| ARCHITECTURE.md | Modified — header version |
| CHANGELOG.md | Modified — release section added |

## Failure Modes

| Failure | Recovery |
|---|---|
| Luacheck errors | Fix lint errors before proceeding |
| Version mismatch | Manually reconcile all 4 locations |
