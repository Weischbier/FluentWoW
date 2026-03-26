# WinUILib — Design Rules

> The 10 non-negotiable rules from ARCHITECTURE.md §16, plus the combat safety matrix.
> Every agent, instruction, and review checklist must reference this document.

---

## The 10 Rules

| # | Rule | Rationale |
|---|---|---|
| 1 | **Never hardcode colour values** — always use `Tokens:GetColor()` | Theme switching breaks if any control uses literal RGBA |
| 2 | **Never call `Show()` on a protected frame in combat** | Causes taint; Blizzard will block the action and log errors |
| 3 | **Never use absolute pixel positions** — anchor relative to parent | Different UI scales and resolutions break absolute layouts |
| 4 | **Always gate destructive operations with `InCombatLockdown()`** | Popups, dropdowns, and dialogs must defer to PLAYER_REGEN_ENABLED |
| 5 | **Always use `FramePool` for repeated frame creation** | Unchecked CreateFrame calls leak memory and degrade performance |
| 6 | **Always stop `OnUpdate` scripts when the animation completes** | Orphaned OnUpdate handlers run every frame forever, killing FPS |
| 7 | **Never add new Lua globals** — everything lives under `WinUILib.*` | Global pollution causes addon conflicts and taint |
| 8 | **Always expose `OnStateChanged` so theming can react to state** | Token-driven theming requires state callbacks to update visuals |
| 9 | **Never remove or rename a public API without a deprecation cycle** | Consumers depend on API stability; deprecated APIs kept for 2 minor versions |
| 10 | **Always test at UIParent scale 0.64 and 1.5** | Catches pixel snapping and layout overflow at extreme scales |

## Rule Enforcement

- **Rules 1, 7, 8**: Enforced by code review and luacheck
- **Rules 2, 4**: Enforced by code review; verified by combat-safety integration tests
- **Rules 3, 10**: Enforced by code review; verified by multi-scale visual testing
- **Rules 5, 6**: Enforced by code review and audit sweeps
- **Rule 9**: Enforced by API surface review agent

## Combat Safety Matrix

| Scenario | Expected Behavior | Guard Required |
|---|---|---|
| Open ComboBox dropdown during combat | Blocked with debug log; no error, no taint | `InCombatLockdown()` check in OnClick |
| Open ContentDialog during combat | Deferred; opens on `PLAYER_REGEN_ENABLED` | Combat queue in ContentDialog:Show() |
| ToggleSwitch click during combat | Allowed (non-secure frame) | None |
| Button click during combat | Allowed (non-secure frame) | None |
| Theme switch during combat | Allowed (no secure frame mutations) | None |
| Show InfoBar during combat | Allowed (non-secure frame) | None |
| Expander toggle during combat | Allowed (non-secure frame) | None |

## Violation Severity

| Severity | Description | Action |
|---|---|---|
| **P0 — Blocker** | Taint, combat lockdown violation, data loss | Must fix before merge |
| **P1 — Critical** | Hardcoded color, orphaned OnUpdate, global leak | Must fix before merge |
| **P2 — Major** | Missing FramePool usage, missing OnStateChanged | Should fix before merge |
| **P3 — Minor** | Absolute positioning, missing scale test | Fix in follow-up |

## Token Compliance Checklist

For every new or modified control, verify:

- [ ] All colors come from `Tokens:GetColor()`
- [ ] All spacing comes from `Tokens:GetSpacing()`
- [ ] All fonts come from `Tokens:GetFont()`
- [ ] All motion durations come from `Tokens:Get("Motion.Duration.*")`
- [ ] No literal RGBA values anywhere in Lua or XML
- [ ] `OnStateChanged` updates visuals using token lookups
