# WinUILib – Architecture Reference

> WinUI-inspired UI framework for World of Warcraft addon developers.  
> Version 1.0.0 · MIT License

---

## 1. Executive Summary

WinUILib ports the **spirit, quality bar, and design language** of WinUI 3 +
WinUI Gallery + Windows Community Toolkit into the World of Warcraft addon
ecosystem.  It is a **library-first, Lua/XML platform** that addon developers
can embed or depend on to build modern, consistent, high-fidelity interfaces
without re-inventing styling, state management, layout, or motion.

It is **not** a skin pack, not a one-off addon UI, and not a literal XAML
clone.  It extracts the transferable principles from Windows Fluent Design and
maps them onto WoW-native frame constraints.

---

## 2. Framework Name

**WinUILib** — production-grade, library-namespaced, WoW-ecosystem friendly.

Other candidates considered:
- **FluentWoW** — evokes Fluent Design System directly
- **ArcaneUI** — WoW-thematic alternative
- **WoWFluent** — descriptive but slightly redundant
- **LuminaUI** — clean, neutral, library-friendly

---

## 3. Principle Translation Matrix

| WinUI / Fluent Concept | Portability | WoW Strategy | Caveats |
|---|---|---|---|
| **Design tokens** | ✅ Direct | Lua token registry (`WinUILib.Tokens`) | Runtime-switched; no CSS variables |
| **Spacing scale** | ✅ Direct | `Tokens.Spacing.*` (XS=2…XXXL=32) | Integer pixels; WoW rounds sub-pixel |
| **Type ramp** | ✅ Adapted | `Tokens.Typography.*` → `SetFont()` | Limited to bundled WoW fonts |
| **Corner radii** | ⚠️ Adapted | 9-slice textures or backdrop insets | No native rounded-rect primitives |
| **Elevation / shadow** | ⚠️ Adapted | Layered backdrop + border tints | No real drop-shadow support |
| **Surfaces / panels** | ✅ Direct | `Backdrop` + `SetBackdropColor` | Tiling artefacts at fractional scale |
| **Light / dark theme** | ⚠️ Adapted | Token swapping via `SetTheme()` | No OS-level dark-mode hook |
| **Hover/press/disabled states** | ✅ Direct | `StateMachine` + script hooks | Combat lockdown blocks some mutations |
| **Motion / animation** | ✅ Adapted | `Motion` module wraps WoW AnimGroup | `OnUpdate` fallback for height anim |
| **Dialogs / flyouts** | ✅ Adapted | `ContentDialog`, `ComboBox` dropdown | Must defer to post-combat |
| **Settings presentation** | ✅ Direct | `SettingsCard`, `SettingsExpander` | Mirrors CommunityToolkit controls |
| **List / detail** | ⚠️ Adapted | `ScrollFrame` + `FramePool` | No native virtualisation; manual pool |
| **Accessibility** | ⚠️ Partial | Tooltip text, keyboard nav | WoW screen-reader support is limited |
| **Responsive layout** | ⚠️ Adapted | `StackLayout` OnSizeChanged re-layout | No media queries; manual breakpoints |
| **Page transitions** | ✅ Adapted | `Motion:FadeIn/FadeOut` between frames | No connected animation |
| **Navigation structures** | ✅ Adapted | `TabView` + sidebar nav in Gallery | No `NavigationView` widget yet (Phase 2) |
| **Data binding** | ❌ Not viable | Lua callbacks / event bus | No reactive binding engine in WoW |

---

## 4. Architecture Blueprint

```
WinUILib/
├── WinUILib.toc                 TOC load-order manifest
├── Core/
│   ├── Bootstrap.lua            Global namespace, version negotiation, OnLoad
│   ├── Utils.lua                Table, string, colour, frame helpers
│   ├── EventBus.lua             Pub/sub decoupling layer
│   ├── StateMachine.lua         Visual state machine (VSM) for controls
│   └── FramePool.lua            Frame recycling for lists / dropdowns
├── Tokens/
│   ├── Registry.lua             Token resolution (override → theme → default)
│   └── DefaultTheme.lua         Full dark-theme token table
├── Controls/
│   ├── Base/ControlBase.lua     Shared mixin: VSM, tooltip, enable/disable
│   ├── Button/                  Button, IconButton, ToggleButton
│   ├── CheckBox/
│   ├── RadioButton/
│   ├── ToggleSwitch/
│   ├── TextBlock/
│   ├── TextBox/                 TextBox, SearchBox
│   ├── Slider/
│   ├── ProgressBar/             ProgressBar, ProgressRing
│   ├── ComboBox/
│   ├── InfoBar/
│   ├── ContentDialog/
│   ├── Expander/
│   ├── TabView/
│   └── ScrollFrame/
├── Layout/
│   ├── StackLayout.xml/.lua     VStack + HStack (StackPanel equivalent)
├── Motion/
│   └── Motion.lua               FadeIn/Out, SlideIn, ScalePress, Stop
└── Settings/
    ├── SettingsCard.xml/.lua    CommunityToolkit SettingsCard equivalent
    └── SettingsExpander.xml/.lua CommunityToolkit SettingsExpander equivalent

WinUILib-Gallery/
├── WinUILib-Gallery.toc
├── Gallery.lua                  Window shell + sidebar navigation
└── Pages/
    ├── ButtonPage.lua
    ├── InputPage.lua
    ├── FeedbackPage.lua
    ├── LayoutPage.lua
    └── SettingsPage.lua
```

### Module responsibilities

| Module | Purpose | Combat-safe? | Optional? |
|---|---|---|---|
| `Core/Bootstrap` | Global namespace, version guard, lifecycle | ✅ | No |
| `Core/Utils` | General helpers | ✅ | No |
| `Core/EventBus` | Decoupled pub/sub | ✅ | No |
| `Core/StateMachine` | Per-control state tracking | ✅ | No |
| `Core/FramePool` | Frame recycling | ✅ | No |
| `Tokens/Registry` | Token lookup + override | ✅ | No |
| `Tokens/DefaultTheme` | Default token values | ✅ | No (swappable) |
| `Controls/*` | All UI controls | Mostly ✅ (see notes) | Yes, per-control |
| `Layout/*` | Stack layout helpers | ✅ | Yes |
| `Motion` | Animation presets | ✅ | Yes |
| `Settings/*` | Settings card/expander | ✅ | Yes |
| `Gallery` | Demo addon | ✅ | Yes |

---

## 5. Control Catalog

### Foundational
| Control | Template | Status |
|---|---|---|
| Button (Accent / Subtle / Destructive) | `WUILButtonTemplate` | ✅ MVP |
| IconButton | `WUILIconButtonTemplate` | ✅ MVP |
| ToggleButton | `WUILToggleButtonTemplate` | ✅ MVP |
| TextBlock (Display/Title/Body/Caption) | `WUILTextBlockTemplate` | ✅ MVP |

### Data Entry
| Control | Template | Status |
|---|---|---|
| CheckBox | `WUILCheckBoxTemplate` | ✅ MVP |
| RadioButton | `WUILRadioButtonTemplate` | ✅ MVP |
| ToggleSwitch | `WUILToggleSwitchTemplate` | ✅ MVP |
| TextBox + SearchBox | `WUILTextBoxTemplate` | ✅ MVP |
| Slider | `WUILSliderTemplate` | ✅ MVP |
| ComboBox | `WUILComboBoxTemplate` | ✅ MVP |

### Feedback / Status
| Control | Template | Status |
|---|---|---|
| ProgressBar (det. + indet.) | `WUILProgressBarTemplate` | ✅ MVP |
| ProgressRing | `WUILProgressRingTemplate` | ✅ MVP |
| InfoBar (4 severities) | `WUILInfoBarTemplate` | ✅ MVP |
| ContentDialog | `WUILContentDialogTemplate` | ✅ MVP |

### Navigation / Layout
| Control | Template | Status |
|---|---|---|
| TabView | `WUILTabViewTemplate` | ✅ MVP |
| Expander | `WUILExpanderTemplate` | ✅ MVP |
| ScrollFrame | `WUILScrollFrameTemplate` | ✅ MVP |
| VStack / HStack | `WUILStackLayoutTemplate` | ✅ MVP |

### Settings
| Control | Template | Status |
|---|---|---|
| SettingsCard | `WUILSettingsCardTemplate` | ✅ MVP |
| SettingsExpander | `WUILSettingsExpanderTemplate` | ✅ MVP |

### Planned (Phase 2+)
- NavigationView sidebar  
- BreadcrumbBar  
- NumberBox (validated numeric input)  
- TeachingTip (coach marks)  
- CommandBar / Toolbar  
- SegmentedControl  
- Badge / status pill  
- EmptyState placeholder  
- Skeleton loading state  
- Virtualized list (true row recycling)

---

## 6. Token System

```lua
-- Retrieve a colour token
local r, g, b, a = WinUILib.Tokens:GetColor("Color.Accent.Primary")

-- Retrieve a spacing value
local gap = WinUILib.Tokens:GetSpacing("MD")   -- → 8

-- Retrieve a font
local font, size, flags = WinUILib.Tokens:GetFont("Body")

-- Override a token at runtime (highest priority)
WinUILib.Tokens:Override({
    ["Color.Accent.Primary"] = { 0.80, 0.20, 0.80, 1 },
})

-- Switch to a custom theme
WinUILib.Tokens:RegisterTheme("MyTheme", { ... })
WinUILib.Tokens:SetTheme("MyTheme")
```

### Token categories
- `Color.Surface.*` — background layers
- `Color.Border.*` — control borders, focus rings
- `Color.Text.*` — text roles
- `Color.Icon.*` — icon tints
- `Color.Accent.*` — interactive accent
- `Color.Feedback.*` — success/warning/error/info
- `Color.Overlay.*` — scrim and hover tints
- `Spacing.XS/SM/MD/LG/XL/XXL/XXXL`
- `Typography.Display/Header/Title/Body/BodyBold/Caption/Mono`
- `Radii.None/SM/MD/LG/Full`
- `Motion.Duration.Fast/Normal/Slow/Entrance/Exit`
- `Motion.Easing.Standard/Decelerate/Accelerate`
- `Opacity.Disabled/Overlay/Ghost`
- `Layer.Base/Raised/Overlay/Dialog/Toast`
- `Density.Compact/Normal/Comfortable`
- `Icon.SM/MD/LG`

---

## 7. Styling & Template Model

Controls are styled through a **three-layer system**:

1. **XML template** — visual structure (textures, font strings, sizing)
2. **Token resolution** — colours, fonts, and spacing resolved from
   `WinUILib.Tokens` at runtime so themes work
3. **VSM callbacks** — `OnStateChanged(newState, prevState)` mutates textures
   when the control state transitions (hover, press, disabled, etc.)

```lua
-- Custom variant: override accent colour on a single button
local btn = WinUILib:CreateButton(parent, nil, "Accent")
btn:SetAccentColor(0.80, 0.20, 0.80)
```

To create a full custom theme:
```lua
WinUILib.Tokens:RegisterTheme("Christmas", {
    Color = { Accent = { Primary = { 1, 0.1, 0.1, 1 } } }
})
WinUILib.Tokens:SetTheme("Christmas")
-- All controls automatically use the new accent colour on next state update.
```

---

## 8. Layout Model

**WinUILib does not use absolute positioning internally.**
All controls use `SetPoint` relative anchors, and layout containers
(`StackLayout`) manage child anchors programmatically.

```lua
local stack = WinUILib:CreateStackLayout(parent, nil, "VERTICAL")
stack:SetPoint("TOPLEFT", parent, "TOPLEFT", 16, -16)
stack:SetWidth(400)
stack:SetGap(8)
stack:SetPadding(16, 16, 16, 16)  -- top, right, bottom, left

local btn1 = WinUILib:CreateButton(stack, nil, "Accent")
btn1:SetText("Action 1")
local btn2 = WinUILib:CreateButton(stack, nil, "Subtle")
btn2:SetText("Action 2")
stack:AddChild(btn1)
stack:AddChild(btn2)
-- Stack auto-sizes height to fit children.
```

---

## 9. Motion Model

All animations respect `WinUILib.Motion.reducedMotion = true` (skip motion).

| Preset | Duration token | Use case |
|---|---|---|
| `FadeIn` | `Motion.Duration.Entrance` (0.25s) | Dialog / panel appear |
| `FadeOut` | `Motion.Duration.Exit` (0.15s) | Dismiss / hide |
| `SlideIn` | `Motion.Duration.Entrance` | Flyout entrance |
| `ScalePress` | `Motion.Duration.Fast` (0.10s) | Click tactile feedback |

---

## 10. Settings / Developer Experience

### Creating a settings panel

```lua
-- Build a settings page using SettingsCard + SettingsExpander
local ts = WinUILib:CreateToggleSwitch(parent)
ts:SetIsOn(MyAddon_DB.enabled)
ts:SetOnToggled(function(self, isOn)
    MyAddon_DB.enabled = isOn
end)

local card = WinUILib:CreateSettingsCard(parent)
card:SetTitle("Enable MyAddon")
card:SetDescription("Turn the addon on or off without disabling it.")
card:SetActionControl(ts)
card:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -8)
card:SetWidth(500)
```

### Theme overriding

```lua
-- Per-addon accent colour without forking the whole framework
WinUILib.Tokens:Override({
    ["Color.Accent.Primary"] = { 0.9, 0.6, 0.1, 1 },  -- gold
})
```

### Version guard

```lua
-- Addons consuming the framework should guard on version:
assert(WinUILib and WinUILib.version >= 10000,
    "MyAddon requires WinUILib 1.0.0 or later")
```

---

## 11. Gallery Addon

Open with: `/wuil` or `/winuigallery`

Pages:
- **Buttons** — Button variants, ToggleButton, state demo
- **Input Controls** — CheckBox, RadioButton, ToggleSwitch, TextBox, Slider, ComboBox
- **Feedback & Dialogs** — ProgressBar, ProgressRing, InfoBar, ContentDialog, Expander
- **Layout & Navigation** — VStack, HStack, TabView
- **Settings Controls** — SettingsCard, SettingsExpander

---

## 12. Testing Strategy

### Unit tests (Lua-side, no WoW API required)
- Token resolution order (override → theme → default)
- StateMachine transitions (all valid state paths)
- StackLayout measurement (height = sum of children + gaps + padding)
- FramePool acquire/release counts
- EventBus subscribe/emit/unsubscribe/once

### Integration / behaviour tests (in-game)
- All controls display correctly at UIParent:GetScale() = 0.64, 1.0, 1.5
- ToggleSwitch thumb animates between positions
- ComboBox dropdown appears below (flips up when near screen bottom)
- ContentDialog defers correctly when `InCombatLockdown()` returns true
- InfoBar OnClosed fires after FadeOut completes
- SettingsExpander height animates correctly with 1/2/3 nested cards

### Taint / combat-safety matrix
| Scenario | Expected |
|---|---|
| Open ComboBox during combat | Blocked with debug log; no error |
| Open ContentDialog during combat | Deferred; opens on PLAYER_REGEN_ENABLED |
| ToggleSwitch click during combat | Allowed (non-secure frame) |
| Button click during combat | Allowed |
| Theme switch during combat | Allowed |

---

## 13. Adoption Strategy

WinUILib is designed for incremental adoption:

1. **Zero controls** — just use the token system for consistent colours/spacing
2. **One control** — embed a single `Button` or `ToggleSwitch` without the rest
3. **Settings panel** — replace bespoke settings UIs with `SettingsCard` groups
4. **Full framework** — build entire addon UIs with layout + controls + motion

### Embedding (standalone distribution)
Addons can list `WinUILib` as a `Dependencies:` entry in their TOC.

### Library load-order negotiation
`Bootstrap.lua` guards on version: if WinUILib is already loaded with a higher
version, the embed exits cleanly.  The richest feature set present in the
session is always used.

---

## 14. Risks & Non-Goals

### Risks
| Risk | Mitigation |
|---|---|
| Combat lockdown taint | All dialogs/dropdowns guard `InCombatLockdown()` |
| Overengineering | MVP-first roadmap; experimental controls are gated |
| Visual inconsistency with Blizzard | Token system allows Blizzard-aligned theme |
| Performance | `FramePool` recycles frames; `OnUpdate` is stopped when idle |
| Theme fragmentation | One official Default theme; community themes are addons |
| API churn | Semantic versioning; deprecated APIs kept for 2 minor versions |

### Non-Goals
- Direct XAML port (WoW has no layout engine)
- Replacing Ace3 configuration DB (`AceDB` should still be used for saved vars)
- Providing a "look like Blizzard UI" theme (WinUILib has its own design language)
- Pixel-perfect shadow/blur effects
- Touch input support
- Widescreen-specific layouts

---

## 15. Phased Roadmap

### Phase 0 – Research & feasibility ✅
- Established WoW addon constraints
- Mapped WinUI concepts to WoW primitives
- Defined token system and naming conventions

### Phase 1 – Core runtime + tokens + MVP controls ✅ (this PR)
- Bootstrap, Utils, EventBus, StateMachine, FramePool
- Token registry + Default dark theme
- Controls: Button, CheckBox, RadioButton, ToggleSwitch, TextBlock,
  TextBox, Slider, ProgressBar, ComboBox, InfoBar, ContentDialog,
  Expander, TabView, ScrollFrame
- Layout: StackLayout (VStack / HStack)
- Motion: FadeIn/Out, SlideIn, ScalePress
- Settings: SettingsCard, SettingsExpander
- Gallery: 5-page showcase addon

### Phase 2 – Navigation + advanced layout
- `NavigationView` sidebar control
- `BreadcrumbBar`
- `NumberBox` (validated numeric TextBox)
- `Grid` layout container
- Responsive width classes

### Phase 3 – Advanced controls + motion polish
- `TeachingTip` (coach marks / contextual teaching)
- `CommandBar` / Toolbar
- `SegmentedControl`
- `Badge` / status pill
- Virtualized list rows (true FramePool recycling)
- Skeleton loading state
- Connected animation helpers

### Phase 4 – Gallery + docs expansion
- Source snippet viewer in Gallery
- Anti-pattern examples page
- Token browser page
- Accessibility checklist page
- Performance notes page

### Phase 5 – Hardening + adoption prep
- CurseForge / Wago packaging
- Semantic versioning automation
- Lua lint CI (luacheck)
- Taint regression test suite
- Migration guide from common patterns

---

## 16. MVP Recommendation

**Top 10 first controls to build (already implemented)**:
1. Button (Accent / Subtle / Destructive) + ToggleButton
2. ToggleSwitch
3. CheckBox + RadioButton
4. TextBox + SearchBox
5. Slider
6. ComboBox
7. ProgressBar + ProgressRing
8. InfoBar
9. ContentDialog
10. SettingsCard + SettingsExpander

**Top 10 design rules that must never be violated**:
1. Never hardcode colour values — always use `Tokens:GetColor()`
2. Never call `Show()` on a protected frame in combat
3. Never use absolute pixel positions — anchor relative to parent
4. Always gate destructive operations with `InCombatLockdown()`
5. Always use `FramePool` for repeated frame creation
6. Always stop `OnUpdate` scripts when the animation completes
7. Never add new Lua globals — everything lives under `WinUILib.*`
8. Always expose `OnStateChanged` so theming can react to state
9. Never remove or rename a public API without a deprecation cycle
10. Always test at UIParent scale 0.64 and 1.5 to catch pixel snapping

---

## 17. Final Verdict

WinUILib is **viable** under the following discipline constraints:

- **Library-first**: Never ship WinUILib as a standalone visible addon.
- **Token-driven**: Resist the urge to hardcode any visual value.
- **Combat-aware**: Every popup/dialog must guard `InCombatLockdown()`.
- **Performance budget**: `OnUpdate` handlers must terminate; frame pools are
  mandatory for list-like content.
- **Incremental**: Release Phase 1 as stable, gate Phase 2+ as experimental
  until proven in at least two production addons.

The framework fills a genuine gap in the WoW addon ecosystem and can realistically
achieve Ace3-like adoption if it ships with a polished gallery, clear docs,
and a zero-friction `Dependencies: WinUILib` onboarding path.
