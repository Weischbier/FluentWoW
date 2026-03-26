# WinUILib — Control Porting Guide

> Step-by-step workflow for porting a WinUI control from `.help/.sources/` to WoW XML + Lua.
> This is the single most important skill document in the project.

---

## Prerequisites

- Read `.docs/DesignRules.md` — all 10 rules apply to every ported control
- Read `.docs/PortabilityMatrix.md` — check the control's portability rating before starting
- Have `.help/.sources/WinUI-Gallery-main/` available for XAML reference
- Have `.help/.sources/microsoft-ui-xaml-main/specs/` for behavior specs when available
- Have `.help/.helper/AddOns/Blizzard_*` for WoW frame API reference
- Use the wow-api MCP server (`mcp_wow-api_*` tools) to verify widget methods, events, and enums

## Porting Sequence

### Step 1 — Assess Portability

1. Open the WinUI Gallery control page: `.help/.sources/WinUI-Gallery-main/WinUIGallery/Samples/ControlPages/<Name>Page.xaml`
2. Identify the control's visual states, properties, events, and interaction patterns
3. Check for WinUI-specific features that have no WoW equivalent (data binding, XAML triggers, connected animations)
4. Rate portability: ✅ Direct, ⚠️ Adapted, ❌ Not viable
5. Document the WoW strategy — what frame type, template approach, and compromises are needed
6. Update `.docs/PortabilityMatrix.md` with the assessment

### Step 2 — Create XML Template

1. Create `WinUILib/Controls/<Name>/<Name>.xml`
2. Use the naming convention: `WUIL<Name>Template`
3. Set `virtual="true"` on the template
4. Inherit from the appropriate WoW widget type (`Frame`, `Button`, `Slider`, `EditBox`, `ScrollFrame`)
5. Use `$parent` references for child frames (e.g., `$parent_Label`, `$parent_Overlay`)
6. Verify widget type exists using `mcp_wow-api_get_widget_methods` or `mcp_wow-api_lookup_api`
7. **No inline Lua** in XML — all behavior goes in the Lua file
8. **No hardcoded colors** — use neutral placeholders; Lua will apply tokens

```xml
<Ui xmlns="http://www.blizzard.com/wow/ui/">
    <Frame name="WUIL<Name>Template" virtual="true" inherits="BackdropTemplate">
        <Size x="200" y="32"/>
        <Layers>
            <Layer level="ARTWORK">
                <FontString name="$parent_Label" parentKey="Label"
                    inherits="GameFontNormal" justifyH="LEFT">
                    <Anchors>
                        <Anchor point="LEFT" x="12" y="0"/>
                    </Anchors>
                </FontString>
            </Layer>
        </Layers>
        <Scripts>
            <OnLoad function="WUIL<Name>_OnLoad"/>
        </Scripts>
    </Frame>
</Ui>
```

### Step 3 — Create Lua Behavior

1. Create `WinUILib/Controls/<Name>/<Name>.lua`
2. File header: purpose, WinUI design reference URL, states list
3. Get references: `local lib = WinUILib`, `local T = lib.Tokens`, `local Mot = lib.Motion`
4. Implement `WUIL<Name>_OnLoad(self)`:
   - Call `Mixin(self, lib._controls.ControlBase)` and `self:WUILInit()`
   - Create VSM via `lib.StateMachine:New(self, "Normal")`
   - Apply initial token-driven styling
5. Implement script handlers as global functions: `WUIL<Name>_OnEnter`, `_OnLeave`, `_OnClick`, etc.
6. Implement `OnStateChanged(self, newState, prevState)` for token-driven visual updates
7. Implement public API methods on the mixin table (e.g., `WUIL<Name>:SetLabel()`)
8. **Combat safety**: If the control shows/hides frames (popup, dropdown, dialog), guard with `InCombatLockdown()`
9. **Frame pooling**: If the control creates child frames dynamically, use `lib.FramePool`
10. **Motion**: Use `Mot:FadeIn()`, `Mot:FadeOut()`, `Mot:ScalePress()` — never raw AnimationGroup

```lua
--- WinUILib – Controls/<Name>/<Name>.lua
-- <Description>
-- Design reference: https://learn.microsoft.com/windows/apps/design/controls/<name>
-- States: Normal | Hover | Pressed | Disabled
local lib = WinUILib
local T   = lib.Tokens
local Mot = lib.Motion

function WUIL<Name>_OnLoad(self)
    Mixin(self, lib._controls.ControlBase)
    self:WUILInit()
end
```

### Step 4 — Register in TOC

1. Open `WinUILib/WinUILib.toc`
2. Add the XML file **before** the Lua file (XML templates must load first):
   ```
   Controls/<Name>/<Name>.xml
   Controls/<Name>/<Name>.lua
   ```
3. Place the entry in the appropriate section (Controls section, alphabetical)

### Step 5 — Add Factory Method

1. Open `WinUILib/Core/Bootstrap.lua`
2. Add a `WinUILib:Create<Name>(parent, ...)` factory method in the factory section
3. Factory should call `CreateFrame(...)` with the template, set properties, and return the frame

### Step 6 — Create Gallery Page

1. Create `WinUILib-Gallery/Pages/<Name>Page.lua`
2. Follow the existing page pattern (see `ButtonPage.lua` for reference)
3. Show all variants and states of the control
4. Register in Gallery sidebar navigation (`Gallery.lua`)
5. Add to `WinUILib-Gallery/WinUILib-Gallery.toc`

### Step 7 — Update Documentation

1. Add the control to the Control Catalog table in `ARCHITECTURE.md` §5
2. Add the control to `.docs/MasterPlan.md` §4 Implemented table
3. Update `.docs/PortabilityMatrix.md` status to ✅ Implemented
4. Add a `CHANGELOG.md` entry under the next version's `### Added` section

### Step 8 — Review Checklist

Before considering the port complete, verify:

- [ ] All 10 design rules satisfied (see `.docs/DesignRules.md`)
- [ ] Token compliance checklist passed
- [ ] Combat safety matrix entry added if the control shows/hides frames
- [ ] All script handlers are global functions matching `WUIL<Name>_<Event>` pattern
- [ ] Mixin table registered properly
- [ ] Gallery page demonstrates all variants and states
- [ ] TOC entries in correct order (XML before Lua)
- [ ] Factory method works (`WinUILib:Create<Name>(parent, ...)`)
- [ ] No new globals beyond the WUIL-prefixed handlers
- [ ] Works at UIParent scale 0.64 and 1.5

## Naming Conventions

| Item | Pattern | Example |
|---|---|---|
| XML template | `WUIL<Name>Template` | `WUILNavigationViewTemplate` |
| XML file | `Controls/<Name>/<Name>.xml` | `Controls/NavigationView/NavigationView.xml` |
| Lua file | `Controls/<Name>/<Name>.lua` | `Controls/NavigationView/NavigationView.lua` |
| OnLoad handler | `WUIL<Name>_OnLoad` | `WUILNavigationView_OnLoad` |
| Script handlers | `WUIL<Name>_<Event>` | `WUILNavigationView_OnClick` |
| Mixin table | `WUIL<Name>` | `WUILNavigationView` |
| Factory method | `WinUILib:Create<Name>()` | `WinUILib:CreateNavigationView()` |
| Child frames | `$parent_<Part>` | `$parent_Label`, `$parent_Overlay` |
| Gallery page | `Pages/<Name>Page.lua` | `Pages/NavigationViewPage.lua` |

## WoW Frame Type Selection Guide

| WinUI Control Type | WoW Base Widget | Notes |
|---|---|---|
| Button-like (click action) | `Button` | Use `Button` inherits for OnClick support |
| Toggle/switch | `Button` or `Frame` | Frame + manual click handling for custom visuals |
| Text input | `EditBox` | WoW's only text input widget |
| Numeric input | `EditBox` | Add validation in Lua |
| Slider/range | `Slider` | WoW native Slider widget |
| Scroll container | `ScrollFrame` | WoW native ScrollFrame |
| Static container | `Frame` | Most layout/grouping controls |
| Overlay/popup | `Frame` + high strata | Set `DIALOG` or `TOOLTIP` frame strata |
| Tab container | `Frame` | Manual tab button management |
