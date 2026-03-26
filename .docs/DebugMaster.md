# WinUILib — Debug Master

> Playbooks for investigating WoW-specific runtime issues. The debugger agent follows these procedures.

---

## Common Failure Modes

| Failure Mode | Symptoms | Likely Cause | Section |
|---|---|---|---|
| Taint error | "Action blocked" in chat, BugSack/BugGrabber stack trace | Secure frame mutation in combat | §1 |
| Frame not visible | Control created but invisible | Missing Show(), wrong strata, zero size, wrong anchor | §2 |
| Layout overflow | Controls overlap or extend beyond parent | Wrong anchor chain, missing SetWidth/SetHeight | §3 |
| Animation stuck | Visual frozen mid-transition, FPS drop | Orphaned OnUpdate, animation not stopped | §4 |
| Theme not applying | Colors don't change after SetTheme() | Missing OnStateChanged, stale token cache | §5 |
| ComboBox dropdown wrong position | Dropdown appears in wrong location | Anchor calculated before parent positioned | §6 |
| SettingsExpander height wrong | Content clips or expander doesn't fit | Height animation target miscalculated | §7 |

---

## §1 — Taint Investigation Playbook

### Symptoms
- "Action [X] blocked because of taint from [AddOn]" message
- Blizzard frames stop working after interacting with WinUILib controls
- `/tinspect` shows tainted values on Blizzard frames

### Investigation Steps

1. **Reproduce**: Note the exact action sequence. Does it only happen in combat?
2. **Enable taint log**: `/console taintLog 2` (logs all taint to `Logs/taint.log`)
3. **Identify the source**: Look for the first WinUILib frame in the taint stack
4. **Check for secure frame mutation**:
   - Search for `Show()`, `Hide()`, `SetParent()`, `SetPoint()` calls on the suspect frame
   - Verify the frame isn't inheriting from a secure template
   - Use `mcp_wow-api_lookup_api` to check if the API is protected
5. **Verify combat guard**: Is there an `InCombatLockdown()` check before the mutation?
6. **Check global pollution**: Did WinUILib accidentally write to a Blizzard global? Run `mcp_wow-api_search_api` to check if a function name conflicts.

### Remediation
- Add `if InCombatLockdown() then return end` guard
- For deferred operations, register for `PLAYER_REGEN_ENABLED` event
- Never inherit from `SecureActionButtonTemplate` or other secure templates
- Never modify Blizzard frame methods or metatables

---

## §2 — Frame Visibility Debugging

### Investigation Steps

1. **Check existence**: `print(frame)` — is the frame nil?
2. **Check Show state**: `print(frame:IsShown(), frame:IsVisible())`
   - `IsShown() = true` but `IsVisible() = false` → parent is hidden
3. **Check size**: `print(frame:GetWidth(), frame:GetHeight())` — zero size = invisible
4. **Check position**: `print(frame:GetPoint(1))` — no anchor = stuck at (0,0)
5. **Check strata**: `print(frame:GetFrameStrata(), frame:GetFrameLevel())` — may be behind another frame
6. **Check alpha**: `print(frame:GetAlpha())` — may be 0 from animation

### Common Fixes
- Ensure `frame:Show()` is called after all setup
- Ensure parent chain is all shown
- Ensure frame has non-zero size (from template or explicit SetSize)
- Ensure at least one anchor point is set

---

## §3 — Layout Overflow Debugging

### Investigation Steps

1. **Check anchor chain**: Walk from the overflowing control up to the root. Each anchor should reference its parent or a sibling.
2. **Check StackLayout**: If using VStack/HStack, verify `SetWidth()` is set on the stack. Height is auto-calculated.
3. **Check padding**: `StackLayout:SetPadding(top, right, bottom, left)` — are values reasonable?
4. **Check child sizes**: Each child in a stack needs an explicit or template-derived width/height.

### Common Fixes
- Set explicit `SetWidth()` on layout containers
- Use `SetPoint("LEFT")` and `SetPoint("RIGHT")` for full-width children
- Verify gap values via `Tokens:GetSpacing()`

---

## §4 — Animation Debugging

### Investigation Steps

1. **Identify the animation**: Which Motion preset? FadeIn, FadeOut, SlideIn, ScalePress?
2. **Check completion**: Is the `OnFinished` callback firing?
3. **Check OnUpdate**: `print(frame:GetScript("OnUpdate"))` — is there an orphaned handler?
4. **Check reducedMotion**: `print(lib.Motion.reducedMotion)` — if true, animations should skip

### Common Fixes
- Ensure animation groups have `OnFinished` that calls `:Stop()` and restores final state
- Ensure OnUpdate-based animations have a termination condition
- Verify `Motion:Stop(frame)` cleans up all animation state

---

## §5 — Theme Not Applying

### Investigation Steps

1. **Check theme registration**: `print(WinUILib.Tokens:GetThemeName())` — is it the expected theme?
2. **Check event firing**: Add temporary listener: `WinUILib.EventBus:On("ThemeChanged", print)`
3. **Check OnStateChanged**: Does the control have an `OnStateChanged` handler that re-reads tokens?
4. **Force state update**: Call `control._vsm:SetState("Normal")` to trigger OnStateChanged

### Common Fixes
- Ensure all controls implement `OnStateChanged` that re-reads tokens
- Ensure theme table uses correct key structure (flat `"Color.Accent.Primary"` or nested `Color.Accent.Primary`)

---

## §6 — ComboBox Dropdown Position

### Investigation Steps

1. **Check timing**: Is the dropdown positioned before or after the parent frame has its final position?
2. **Check screen bounds**: Does the dropdown flip up when near the bottom of the screen?
3. **Check GetScreenHeight**: `print(GetScreenHeight())` — is the flip threshold correct?

### Common Fixes
- Position dropdown in a separate frame callback or after a short delay
- Use `GetBottom()` / `GetTop()` on the combo box to calculate dropdown position

---

## §7 — SettingsExpander Height Animation

### Investigation Steps

1. **Calculate expected height**: Sum of all nested card heights + gaps + padding
2. **Check animation target**: Is the height animation target matching the calculated value?
3. **Check child count**: Did a card get added/removed after the height was calculated?

### Common Fixes
- Recalculate target height immediately before starting the animation
- Consider using `OnSizeChanged` to detect when children have been laid out

---

## MCP Tools for Debugging

Use these wow-api MCP tools during investigation:

| Tool | Use For |
|---|---|
| `mcp_wow-api_lookup_api` | Verify if a WoW API function exists and its signature |
| `mcp_wow-api_get_widget_methods` | Check available methods on a widget type (Frame, Button, EditBox, etc.) |
| `mcp_wow-api_get_event` | Check event payload and timing |
| `mcp_wow-api_get_enum` | Look up enum values for API parameters |
| `mcp_wow-api_search_api` | Search for APIs by keyword |
| `mcp_wow-api_get_namespace` | Explore C_* namespace APIs |
