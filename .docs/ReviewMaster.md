# WinUILib — Code Review Master

> Orchestration document for code review. All review agents and human reviewers follow this checklist.

---

## Review Scope

Every change to `WinUILib/` or `WinUILib-Gallery/` must be reviewed against these gates before merge.

## Severity Model

| Severity | Meaning | Merge? |
|---|---|---|
| **P0 — Blocker** | Taint, combat lockdown violation, data loss, security issue | ❌ Must fix |
| **P1 — Critical** | Hardcoded color, orphaned OnUpdate, global leak, broken API contract | ❌ Must fix |
| **P2 — Major** | Missing FramePool, missing OnStateChanged, missing deprecation cycle | ⚠️ Should fix |
| **P3 — Minor** | Absolute positioning, missing scale test, style nit | ✅ Fix in follow-up |

## Review Checklist

### 1. Design Rules (mandatory — all 10)

- [ ] **Rule 1**: No hardcoded color values — all colors from `Tokens:GetColor()`
- [ ] **Rule 2**: No `Show()` on protected frames in combat
- [ ] **Rule 3**: No absolute pixel positions — all anchors relative to parent
- [ ] **Rule 4**: All popup/dialog operations guarded with `InCombatLockdown()`
- [ ] **Rule 5**: `FramePool` used for any repeated frame creation
- [ ] **Rule 6**: All `OnUpdate` scripts stopped when animation completes
- [ ] **Rule 7**: No new Lua globals outside `WinUILib.*` and `WUIL*` handlers
- [ ] **Rule 8**: `OnStateChanged` exposed for theming
- [ ] **Rule 9**: No public API removed without deprecation (2 minor versions)
- [ ] **Rule 10**: Tested at UIParent scale 0.64 and 1.5

### 2. Token Compliance

- [ ] All colors from tokens
- [ ] All spacing from tokens
- [ ] All fonts from tokens
- [ ] All motion durations from tokens
- [ ] No literal RGBA values in Lua or XML

### 3. Architecture Compliance

- [ ] New code uses `RegisterModule` pattern if it's a module
- [ ] XML templates follow `WUIL<Name>Template` naming
- [ ] Script handlers follow `WUIL<Name>_<Event>` naming
- [ ] Mixin uses `ControlBase` via `Mixin(self, lib._controls.ControlBase)`
- [ ] VSM created via `lib.StateMachine:New()`
- [ ] Factory method added to Bootstrap.lua

### 4. Combat Safety (for controls that show/hide frames)

- [ ] `InCombatLockdown()` checked before Show/Hide
- [ ] Combat-deferred controls register for `PLAYER_REGEN_ENABLED`
- [ ] No secure frame mutations in combat

### 5. API Surface

- [ ] Public methods are documented with `---@param` annotations
- [ ] No breaking changes to existing public API
- [ ] Deprecated methods wrapped with warning + forwarding

### 6. Gallery Coverage

- [ ] New controls have a Gallery page
- [ ] Gallery page demonstrates all variants and states
- [ ] Gallery TOC updated

### 7. Documentation

- [ ] ARCHITECTURE.md control catalog updated
- [ ] MasterPlan.md control inventory updated
- [ ] CHANGELOG.md entry added

## Auto-Approve Criteria

A change may be merged without full review if ALL of these are true:
- Only modifies Gallery pages (no library code)
- No new controls or API changes
- No modifications to Core/ or Tokens/
- Passes luacheck CI

## Escalation

If a reviewer is unsure whether a change violates a rule:
1. Check `.docs/DesignRules.md` for the rule definition
2. Check `.docs/ControlPortingGuide.md` for the expected pattern
3. Use wow-api MCP to verify WoW API behavior
4. If still unclear, flag for maintainer decision
