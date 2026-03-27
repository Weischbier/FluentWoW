---
name: scaffold-control
description: >
  Scaffold the full file set for a new FluentWoW control — XML template, Lua behavior,
  TOC entry, factory method, Gallery page, and documentation updates.
  This is the primary code-generating skill for the control-builder agent.
---

# scaffold-control

## When to Use

- Porting a new WinUI control to WoW
- Creating a new original control that follows the FluentWoW pattern
- The control-builder agent should invoke this skill as its primary workflow

## Prerequisites

1. Verify the control is rated ✅ Direct or ⚠️ Adapted in `.docs/PortabilityMatrix.md`
2. If not yet assessed, run the `assess-portability` skill first
3. Read `.docs/ControlPortingGuide.md` for the full 8-step procedure
4. Read `.docs/DesignRules.md` for the 10 non-negotiable rules

## Inputs

| Input | Required | Description |
| --- | --- | --- |
| `controlName` | Yes | PascalCase name, e.g., `NavigationView` |
| `baseWidget` | Yes | WoW widget type: `Frame`, `Button`, `Slider`, `EditBox`, `ScrollFrame`, `StatusBar` |
| `states` | Yes | Comma-separated states, e.g., `Normal, Hover, Pressed, Disabled` |
| `winuiRef` | No | WinUI Gallery XAML path in `.help/.sources/` |
| `specRef` | No | WinUI spec path in `.help/.sources/microsoft-ui-xaml-main/specs/` |

## Steps

### 1. Verify WoW APIs

Use the wow-api MCP tools to confirm the chosen `baseWidget` and its methods:
- `mcp_wow-api_get_widget_methods` for the base widget type
- `mcp_wow-api_lookup_api` for any specific API you need
- `mcp_wow-api_list_deprecated` to check for deprecated APIs you might accidentally use

### 1b. Read Design Specs

- Read `.docs/DesignSpecs.md` for pixel measurements from WinUI design images
- If `specRef` is provided, read the WinUI spec for control-specific measurements
- Read design images in `.help/.sources/WinUI-Gallery-main/fwow/Assets/Design/` for visual reference
- Map pixel values to spacing tokens: 8px→`Spacing.MD`, 12px→`Spacing.LG`, 16px→`Spacing.XL`

### 2. Create XML Template

Create `FluentWoW/Controls/{controlName}/{controlName}.xml`:
- Template name: `FWoW{controlName}Template`, `virtual="true"`
- Inherit from appropriate base: `BackdropTemplate` for Frame-based, widget itself for Button/Slider
- Script: `<OnLoad function="FWoW{controlName}_OnLoad"/>`
- Child frames use `$parent_{PartName}` with `parentKey`
- No inline Lua, no hardcoded colors

### 3. Create Lua Behavior

Create `FluentWoW/Controls/{controlName}/{controlName}.lua`:

```lua
--- FluentWoW – Controls/{controlName}/{controlName}.lua
-- {Description}
-- Design reference: https://learn.microsoft.com/windows/apps/design/controls/{lowercase-name}
-- States: {states}
local lib = FluentWoW
local T   = lib.Tokens
local Mot = lib.Motion

function FWoW{controlName}_OnLoad(self)
    Mixin(self, lib._controls.ControlBase)
    self:FWoWInit()
    -- Create state machine
    -- Apply initial token styling
end

function FWoW{controlName}_OnEnter(self)
    if not self._disabled then self._vsm:SetState("Hover") end
end

function FWoW{controlName}_OnLeave(self)
    if not self._disabled then self._vsm:SetState("Normal") end
end

function FWoW{controlName}:OnStateChanged(newState, prevState)
    -- Apply token-driven visual updates per state
end
```

### 4. Register in TOC

Add to `FluentWoW/FluentWoW.toc` (XML before Lua, in Controls section):
```
Controls/{controlName}/{controlName}.xml
Controls/{controlName}/{controlName}.lua
```

### 5. Add Factory Method

Add to `FluentWoW/Core/Bootstrap.lua` factory section:
```lua
function FluentWoW:Create{controlName}(parent, name, ...)
    local f = CreateFrame("{baseWidget}", name, parent, "FWoW{controlName}Template")
    return f
end
```

### 6. Create Gallery Page

Create or update the appropriate `FluentWoW-Gallery/Pages/{Family}Page.lua`:
- Demonstrate all variants and states
- Use StackLayout for arrangement
- Include both enabled and disabled examples

### 7. Update Documentation

- `ARCHITECTURE.md` §5 Control Catalog — add the new control row
- `.docs/MasterPlan.md` §4 — update control inventory
- `.docs/PortabilityMatrix.md` — set status to ✅ Implemented
- `CHANGELOG.md` — add under next version `### Added`

### 8. Review

Run through the review checklist in `.docs/ControlPortingGuide.md` Step 8.
Verify pixel-fidelity: all spacing, padding, gap values match `.docs/DesignSpecs.md`.

## Vendored Libraries

Available in `FluentWoW/Libs/` (loaded before Core, do NOT modify):
- **Ace3** — LibStub, AceAddon, AceDB, AceEvent, AceGUI, AceConfig, etc.
- **Motion** — flux (tweening), knife.base, knife.timer
- **PureLua** — 30log (OOP), dkjson (JSON), i18n, inspect, lume (utils), serpent

## Outputs

| Output | Path |
| --- | --- |
| XML template | `FluentWoW/Controls/{controlName}/{controlName}.xml` |
| Lua behavior | `FluentWoW/Controls/{controlName}/{controlName}.lua` |
| TOC entry | `FluentWoW/FluentWoW.toc` (modified) |
| Factory method | `FluentWoW/Core/Bootstrap.lua` (modified) |
| Gallery page | `FluentWoW-Gallery/Pages/{Family}Page.lua` (created or modified) |
| Docs updates | ARCHITECTURE.md, MasterPlan.md, PortabilityMatrix.md, CHANGELOG.md (modified) |

## Failure Modes

| Failure | Recovery |
| --- | --- |
| Base widget type doesn't support needed behavior | Check `mcp_wow-api_get_widget_methods` and consider a different base or manual implementation |
| Control requires secure frames | Add combat lockdown guard; mark in Combat Safety Matrix |
| No equivalent WoW feature | Document in PortabilityMatrix as ❌ and skip, or design an adapted alternative |
| Naming collision with Blizzard UI | Check `.help/.helper/AddOns/Blizzard_*` for existing names; all FWoW-prefixed names are safe |
