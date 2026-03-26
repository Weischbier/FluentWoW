---
applyTo: ".docs/**,ARCHITECTURE.md,README.md,CHANGELOG.md"
---

# Documentation Rules

## ARCHITECTURE.md

- Must match the current implementation — if code changes, update the doc
- Control Catalog (§5) must list every implemented control with template name and status
- Roadmap (§15) phase statuses must reflect actual progress
- Version in header must match TOC and Bootstrap.lua

## README.md

- Consumer-facing quick start — keep it concise and practical
- Code examples must work with the current API
- Feature table must list all implemented controls

## CHANGELOG.md

- Follow [Keep a Changelog](https://keepachangelog.com/) format
- Every version has: `### Added`, `### Changed`, `### Fixed`, `### Deprecated`, `### Removed` (as applicable)
- New controls go under `### Added`
- API changes go under `### Changed`
- Deprecated APIs go under `### Deprecated` with removal target version

## .docs/ Files

- `.docs/MasterPlan.md` — root orchestration; update control inventory after each port
- `.docs/DesignRules.md` — authoritative rules; update only for actual rule changes
- `.docs/PortabilityMatrix.md` — update status when controls are assessed or ported
- `.docs/TokenReference.md` — update when tokens are added or modified

## Style

- Use tables for inventories and registries
- Use checklists for procedures
- Use code blocks for examples
- Cross-link related documents
- Be specific — use actual file paths, function names, and token names
