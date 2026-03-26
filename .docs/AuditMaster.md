# WinUILib — Audit Master

> Orchestration document for periodic codebase audits. The auditor agent follows these procedures.

---

## Audit Purpose

Sweep the entire WinUILib codebase for violations of the 10 design rules, token compliance drift, combat safety gaps, and API stability issues.

## Audit Schedule

- **Pre-release**: Full audit before every version bump
- **Post-port**: Targeted audit after each new control is ported
- **Periodic**: Monthly sweep of the full codebase

## Audit Categories

### 1. Token Compliance Audit

**Scan for**: Hardcoded RGBA values in Lua files, inline color attributes in XML

**Procedure**:
1. Search all `.lua` files in `WinUILib/Controls/`, `WinUILib/Settings/`, `WinUILib/Layout/` for patterns like:
   - `SetTextColor(0.` or `SetVertexColor(0.` with literal numbers
   - `SetBackdropColor(0.` with literal numbers
   - Any `{0.xxx, 0.xxx, 0.xxx` that isn't inside `DefaultTheme.lua` or `Registry.lua`
2. Search all `.xml` files for `color=` or `r=` / `g=` / `b=` / `a=` attributes with literal values
3. Exclude `DefaultTheme.lua` (that's where token defaults live)

**Report format**:
```
FILE:LINE — Hardcoded color: SetTextColor(1, 0, 0, 1) → should use Tokens:GetColor("Color.Feedback.Error")
```

### 2. Combat Safety Audit

**Scan for**: Unguarded `Show()`, `Hide()`, `SetParent()` on frames that could be protected

**Procedure**:
1. Search for `:Show()` and `:Hide()` calls in Controls that use popups/dropdowns
2. Verify each has an `InCombatLockdown()` guard
3. Check ContentDialog, ComboBox, Flyout-like controls specifically
4. Verify `PLAYER_REGEN_ENABLED` registration for deferred operations

**Report format**:
```
FILE:LINE — Unguarded Show() in combat-sensitive context → add InCombatLockdown() check
```

### 3. Global Leak Audit

**Scan for**: New global variables or functions not in the approved list

**Procedure**:
1. Run luacheck with the project `.luacheckrc`
2. Identify any "setting non-standard global variable" warnings
3. Verify all global functions match `WUIL*_*` pattern or are in `.luacheckrc` globals list

**Report format**:
```
FILE:LINE — Undeclared global: MyHelper → should be local or under WinUILib.*
```

### 4. OnUpdate Orphan Audit

**Scan for**: `SetScript("OnUpdate", ...)` without corresponding `SetScript("OnUpdate", nil)`

**Procedure**:
1. Search for all `OnUpdate` script registrations
2. For each, verify there's a termination condition that nils the OnUpdate
3. Check Motion module animations specifically — all must call `Stop()` or nil OnUpdate

**Report format**:
```
FILE:LINE — OnUpdate set but no termination found → risk of orphaned per-frame handler
```

### 5. FramePool Compliance Audit

**Scan for**: `CreateFrame()` calls that should use FramePool

**Procedure**:
1. Search for `CreateFrame(` in Controls that create multiple similar child frames
2. Exclude: one-time frame creation in factory methods, template registration
3. Flag: any loop or repeated call that creates frames without FramePool

**Report format**:
```
FILE:LINE — CreateFrame in loop → should use lib.FramePool:Acquire()
```

### 6. API Stability Audit

**Scan for**: Removed or renamed public methods without deprecation

**Procedure**:
1. Compare current public API surface (methods on WUIL* mixins and WinUILib:Create* factories) against previous release
2. Flag any method that was removed without a deprecation wrapper
3. Verify deprecated methods still forward correctly

**Report format**:
```
CONTROL — Method :SetValue() removed without deprecation cycle → restore with deprecation wrapper
```

## Audit Report Template

```markdown
# WinUILib Audit Report — [DATE]

## Summary
- Token compliance: X violations
- Combat safety: X violations
- Global leaks: X violations
- OnUpdate orphans: X violations
- FramePool compliance: X violations
- API stability: X violations

## P0 — Blockers
(list)

## P1 — Critical
(list)

## P2 — Major
(list)

## P3 — Minor
(list)

## Recommendations
(list)
```
