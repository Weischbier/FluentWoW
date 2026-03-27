---
applyTo: "FluentWoW/Controls/**"
---

# Controls Module Rules

## Required Pattern

Every control MUST follow this structure:

1. **XML template** (`Controls/<Name>/<Name>.xml`):
   - Template named `WUIL<Name>Template` with `virtual="true"`
   - Inherits from appropriate WoW widget (`Frame`, `Button`, `EditBox`, `Slider`, `ScrollFrame`)
   - Child frames use `$parent_<PartName>` naming and `parentKey`
   - No inline Lua — all behavior in the Lua file
   - No hardcoded colors — Lua applies tokens

2. **Lua behavior** (`Controls/<Name>/<Name>.lua`):
   - Header comment with purpose, WinUI design reference URL, and states list
   - `local lib = FluentWoW`, `local T = lib.Tokens`, `local Mot = lib.Motion`
   - `OnLoad` handler: `Mixin(self, lib._controls.ControlBase)`, `self:WUILInit()`
   - VSM: `self._vsm = lib.StateMachine:New(self, "Normal")`
   - Script handlers as global functions: `WUIL<Name>_OnLoad`, `WUIL<Name>_OnEnter`, etc.
   - `OnStateChanged(self, newState, prevState)` for token-driven visual updates
   - Public API as methods on the mixin table

## Token-Driven Styling (Rule #1)

```lua
-- CORRECT
local r, g, b, a = T:GetColor("Color.Accent.Primary")
self.Label:SetTextColor(r, g, b, a)

-- FORBIDDEN
self.Label:SetTextColor(0.26, 0.56, 0.94, 1)  -- hardcoded!
```

## Combat Safety (Rules #2, #4)

Controls that show/hide overlay frames (ComboBox dropdown, ContentDialog, Flyout) MUST:
```lua
function WUILMyControl_OnClick(self)
    if InCombatLockdown() then
        lib:Debug("Blocked: cannot show in combat")
        return
    end
    self.Dropdown:Show()
end
```

## Pixel-Fidelity (Design Spec Compliance)

Every control MUST match the WinUI pixel measurements exactly:
- Read `.docs/DesignSpecs.md` for measurements extracted from design images
- Read `.help/.sources/microsoft-ui-xaml-main/specs/` for control-specific specs
- Read `.help/.sources/WinUI-Gallery-main/WinUIGallery/Assets/Design/` for annotated design images
- Map pixel values to spacing tokens: 8px→`Spacing.MD`, 12px→`Spacing.LG`, 16px→`Spacing.XL`, 24px→`Spacing.XXL`, 32px→`Spacing.XXXL`
- Internal card padding: 12px top, 16px left/right/bottom
- Icon-to-text gap: 12px, inter-element gap: 16px, action-icon-to-label: 8px
- Never approximate — use the exact pixel value from the spec

## Available Libraries

Vendored in `FluentWoW/Libs/` and loaded before Core:
- **Ace3** — LibStub, AceAddon, AceDB, AceEvent, AceGUI, AceConfig, etc.
- **Motion** — flux (tweening), knife.base, knife.timer
- **PureLua** — 30log (OOP), dkjson (JSON), i18n, inspect, lume (utils), serpent

Vendored lib files must NOT be modified — use them as-is.

## State Machine (Rule #8)

Every control MUST implement `OnStateChanged`:
```lua
function WUILMyControl:OnStateChanged(newState, prevState)
    if newState == "Disabled" then
        self:SetAlpha(T:Get("Opacity.Disabled"))
    elseif newState == "Hover" then
        -- update hover visuals using tokens
    end
end
```

## Global Functions

- ONLY `WUIL<Name>_<Event>` global functions are allowed
- All other functions must be `local` or methods on the mixin table
- The mixin table itself may be file-local if only used within that file

## Frame Pooling (Rule #5)

Controls that create dynamic child frames (dropdown items, list rows) MUST use:
```lua
local item = lib.FramePool:Acquire("WUIL<Name>ItemTemplate", self.Container)
-- ... configure item ...
-- On cleanup:
lib.FramePool:Release(item)
```

## Motion (Rule #6)

All animations must use the Motion module and stop when complete:
```lua
Mot:FadeIn(self)        -- auto-stops on completion
Mot:ScalePress(self)    -- auto-stops on completion
-- If using custom OnUpdate:
self:SetScript("OnUpdate", function(self, elapsed)
    -- ... animate ...
    if done then
        self:SetScript("OnUpdate", nil)  -- MUST nil the handler
    end
end)
```
