# FAQ & Troubleshooting

Common questions and solutions for FluentWoW addon development.

---

## General

### How do I access FluentWoW?

```lua
-- Direct global (simplest)
local lib = FluentWoW

-- Via LibStub (Ace3 pattern)
local lib = LibStub("FluentWoW-1.0")
```

Both return the same singleton table.

### What WoW versions are supported?

FluentWoW targets **retail** WoW client — Interface 120005 and 120001. It is not tested on Classic, TBC Classic, or Wrath Classic.

### Do I need to embed FluentWoW in my addon?

No — FluentWoW loads as its own addon. Declare it as a dependency in your `.toc`:

```
## Dependencies: FluentWoW
```

### Can I ship FluentWoW bundled with my addon?

Yes. Use LibStub to avoid conflicts. The version negotiation in Bootstrap.lua ensures only the newest copy runs when multiple addons embed it.

---

## Combat Lockdown

### "Action was blocked" errors in combat

FluentWoW controls that show/hide secure frames are blocked during `InCombatLockdown()`. This is a WoW platform limitation, not a bug.

**Affected operations:**
- `ContentDialog:Open()` — blocked in combat
- `ComboBox` dropdown — blocked in combat
- `MainFrame:Open()` — blocked in combat

**Solution:** Check combat state before performing these operations:

```lua
if not FluentWoW.Utils.InCombat() then
    dialog:Open()
else
    -- Queue for after combat
    FluentWoW.EventBus:Once("PLAYER_REGEN_ENABLED", function()
        dialog:Open()
    end)
end
```

Or defer to post-combat:

```lua
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:SetScript("OnEvent", function()
    -- Safe to show frames here
    dialog:Open()
    frame:UnregisterEvent("PLAYER_REGEN_ENABLED")
end)
```

### Controls stop responding after combat

If a control was in a hover/pressed state when combat started and the state couldn't be cleaned up, it may appear stuck. Moving the mouse out and back over the control will reset it.

---

## Theming

### My custom frames don't update when the theme changes

Built-in FluentWoW controls auto-update on theme change. Custom frames need to listen manually:

```lua
FluentWoW.EventBus:On("ThemeChanged", function()
    myFrame.bg:SetColorTexture(FluentWoW.Tokens:GetColor("Color.Surface.Raised"))
end)
```

### How do I create a custom theme?

See the [Theming](Theming) page for a complete guide. In brief:

```lua
FluentWoW.Tokens:RegisterTheme("MyTheme", {
    ["Color.Accent.Primary"] = { r, g, b, a },
    -- ...
})
FluentWoW.Tokens:SetTheme("MyTheme")
```

### How do I persist the theme choice?

FluentWoW doesn't save theme selection. Store it in your addon's saved variables:

```lua
-- Load
if MyDB.theme then FluentWoW.Tokens:SetTheme(MyDB.theme) end

-- Save
FluentWoW.EventBus:On("ThemeChanged", function(name)
    MyDB.theme = name
end)
```

---

## Controls

### "WARNING: Control created outside a FWoWMainFrame"

All FluentWoW controls **must** be descendants of a `MainFrame` created via `CreateMainFrame()`. If you see this debug warning, your control's parent chain doesn't include a MainFrame.

**Fix:** Create a MainFrame first and parent your controls inside it:

```lua
local lib = FluentWoW
local frame = lib:CreateMainFrame("MyAddonFrame", "My Addon")
local content = frame:GetContentArea()

-- Create controls parented to the MainFrame's content area
local btn = lib:CreateButton(content, nil, "Accent")
```

The only controls exempt from this rule are **ContentDialog** and **TeachingTip**, which are fullscreen overlays that attach to UIParent.

### Control doesn't appear / is invisible

1. Check that the control has a **parent** frame that is visible
2. Check that **anchors are set** — every control needs at least one `SetPoint()`
3. Check that the control has a **size** — some controls auto-size, but containers need explicit dimensions
4. Check `IsShown()` and `GetAlpha()` — the control might be hidden or at 0 alpha

### CheckBox cycling order is wrong

By default, CheckBox is two-state (unchecked ↔ checked). For three-state cycling, call `SetThreeState(true)`:

```lua
cb:SetThreeState(true)
-- Cycle: Unchecked → Checked → Indeterminate → Unchecked
```

### RadioButton doesn't deselect others

Make sure all radio buttons in the group share the **same group name**:

```lua
r1:SetGroup("difficulty")
r2:SetGroup("difficulty")
r3:SetGroup("difficulty")
```

The default group is `"default"` — if all buttons use the default, they'll mutually exclude correctly.

### ComboBox dropdown appears in the wrong place

The dropdown positions itself relative to the ComboBox frame. If the ComboBox's parent has unusual strata or scale, the dropdown may misalign. Ensure the ComboBox's ancestor chain has consistent scale values.

### Expander/SettingsExpander height is wrong

After adding content to the expander's content frame, call `SetContentHeight()` with the correct total height:

```lua
exp:SetContentHeight(200)  -- total height of content inside
```

---

## Layout

### StackLayout children overlap

If children are hidden or have zero height, the layout may calculate incorrectly. Ensure all visible children have proper sizes set before calling `AddChild()`.

Call `stack:Refresh()` after dynamically changing child sizes or visibility.

### StackLayout doesn't fill parent width

In `VERTICAL` mode, children are anchored `TOPLEFT` → `TOPRIGHT`, so they stretch to fill the stack's width (minus padding). Ensure the stack itself has its width set:

```lua
stack:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
stack:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0)
```

---

## Motion / Animation

### Animations are janky or slow

1. **Check for tween accumulation** — always `Motion:Stop(frame)` before starting new tweens on the same frame
2. **Check addon CPU usage** — other addons' `OnUpdate` handlers can starve FluentWoW's driver
3. **Lower animation complexity** — use `Motion.reducedMotion = true` for accessibility

### How do I disable all animations?

```lua
FluentWoW.Motion.reducedMotion = true
```

All preset animations and internal control animations will snap instantly.

---

## Performance

### How many frames does FluentWoW create?

FluentWoW creates frames on-demand via factory methods. It uses `FramePool` for recyclable elements (ComboBox items, TabView tabs). A typical settings panel with 10 cards creates ~30-40 frames total — well within WoW's capacity.

### Does FluentWoW have an OnUpdate handler?

Yes — the Motion engine uses a **single** hidden driver frame with `OnUpdate`. It **auto-parks** (hides) when there are no active tweens, so there is zero overhead when idle.

### Memory usage

FluentWoW's Lua footprint is modest — primarily the token tables, icon glyph map, and control code. The icon font file adds ~300KB to disk.

---

## Debugging

### Enable debug logging

```lua
FluentWoW.debug = true
```

This prints `[FluentWoW]` prefixed messages to chat for:
- Token resolution failures
- SafeCall errors
- Assert warnings
- Theme change events

### Check control state

```lua
local state = myControl:GetState()
print("Current state:", state)  -- "Normal", "Hover", "Disabled", etc.
```

### Inspect token resolution

```lua
local value = FluentWoW.Tokens:Get("Color.Accent.Primary")
if value then
    print(unpack(value))  -- r, g, b, a
else
    print("Token not found!")
end
```
