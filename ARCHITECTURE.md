# FluentWoW – Architecture Reference

> WinUI-inspired UI framework for World of Warcraft addon developers.  
> Version 1.0.0 · MIT License

---

## 1. Executive Summary

FluentWoW ports the **spirit, quality bar, and design language** of WinUI 3 +
WinUI Gallery + Windows Community Toolkit into the World of Warcraft addon
ecosystem.  It is a **library-first, Lua/XML platform** that addon developers
can embed or depend on to build modern, consistent, high-fidelity interfaces
without re-inventing styling, state management, layout, or motion.

It is **not** a skin pack, not a one-off addon UI, and not a literal XAML
clone.  It extracts the transferable principles from Windows Fluent Design and
maps them onto WoW-native frame constraints.

---

## 2. Framework Name

**FluentWoW** — production-grade, library-namespaced, WoW-ecosystem friendly.

Other candidates considered:

- **FluentWoW** — evokes Fluent Design System directly
- **ArcaneUI** — WoW-thematic alternative
- **WoWFluent** — descriptive but slightly redundant
- **LuminaUI** — clean, neutral, library-friendly

---

## 3. Principle Translation Matrix

| WinUI / Fluent Concept | Portability | WoW Strategy | Caveats |
| --- | --- | --- | --- |
| **Design tokens** | ✅ Direct | Lua token registry (`FluentWoW.Tokens`) | Runtime-switched; no CSS variables |
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

```text
FluentWoW/
├── FluentWoW.toc                 TOC load-order manifest
├── Libs/
│   ├── LibStub/LibStub.lua      Vendored Ace3 library stub (version negotiation)
│   └── Motion/                  Vendored flux-derived tweening engine
│       ├── base.lua
│       ├── flux.lua
│       └── timer.lua
├── Core/
│   ├── Bootstrap.lua            Global namespace, version negotiation, OnLoad
│   ├── Utils.lua                Table, string, colour, frame helpers
│   ├── EventBus.lua             Pub/sub decoupling layer
│   ├── StateMachine.lua         Visual state machine (VSM) for controls
│   └── FramePool.lua            Frame recycling for lists / dropdowns
├── Tokens/
│   ├── Registry.lua             Token resolution + hardcoded design constants
│   ├── DarkTheme.lua            Dark-theme color table (colors only)
│   └── LightTheme.lua           Light-theme color table (colors only)
├── Assets/
│   ├── FluentIcons.lua          Segoe Fluent Icons glyph map
│   └── Fonts/                   Bundled font files
├── Controls/
│   ├── Base/ControlBase.lua     Shared mixin: VSM, tooltip, enable/disable
│   ├── MainFrame/               Application window shell (title bar, resize, drag)
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
│   ├── ScrollFrame/
│   ├── NavigationView/         Sidebar navigation with collapsible pane
│   ├── BreadcrumbBar/           Hierarchical path breadcrumb trail
│   ├── NumberBox/               Validated numeric input with spin buttons
│   ├── TeachingTip/             Contextual teaching callout / coach mark
│   ├── CommandBar/              Toolbar with primary + overflow commands
│   ├── SegmentedControl/        Mutually exclusive segmented selector
│   ├── Badge/                   Status pill / badge indicator
│   ├── EmptyState/              Placeholder for empty content areas
│   └── Skeleton/                Animated shimmer loading placeholder
├── Layout/
│   ├── StackLayout.xml/.lua     VStack + HStack (StackPanel equivalent)
├── Motion/
│   └── Motion.lua               Tween-based animation engine (flux-derived)
└── Settings/
    ├── SettingsCard.xml/.lua    CommunityToolkit SettingsCard equivalent
    └── SettingsExpander.xml/.lua CommunityToolkit SettingsExpander equivalent

FluentWoW-Gallery/
├── FluentWoW-Gallery.toc
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
| --- | --- | --- | --- |
| `Core/Bootstrap` | Global namespace, version guard, lifecycle | ✅ | No |
| `Core/Utils` | General helpers | ✅ | No |
| `Core/EventBus` | Decoupled pub/sub | ✅ | No |
| `Core/StateMachine` | Per-control state tracking | ✅ | No |
| `Core/FramePool` | Frame recycling | ✅ | No |
| `Tokens/Registry` | Token lookup + override | ✅ | No |
| `Tokens/DarkTheme` | Dark-theme color values | ✅ | No (swappable) |
| `Tokens/LightTheme` | Light-theme color values | ✅ | Yes (swappable) |
| `Assets/FluentIcons` | Icon glyph map | ✅ | Yes |
| `Libs/LibStub` | Library version negotiation | ✅ | No |
| `Libs/Motion` | Vendored flux tween engine | ✅ | No |
| `Controls/*` | All UI controls | Mostly ✅ (see notes) | Yes, per-control |
| `Layout/*` | Stack layout helpers | ✅ | Yes |
| `Motion` | Animation presets | ✅ | Yes |
| `Settings/*` | Settings card/expander | ✅ | Yes |
| `Gallery` | Demo addon | ✅ | Yes |

---

## 5. Control Catalog

### Foundational

| Control | Template | Status |
| --- | --- | --- |
| Button (Accent / Subtle / Destructive) | `FWoWButtonTemplate` | ✅ MVP |
| IconButton | `FWoWIconButtonTemplate` | ✅ MVP |
| ToggleButton | `FWoWToggleButtonTemplate` | ✅ MVP |
| TextBlock (Display/Title/Body/Caption) | `FWoWTextBlockTemplate` | ✅ MVP |

### Data Entry

| Control | Template | Status |
| --- | --- | --- |
| CheckBox | `FWoWCheckBoxTemplate` | ✅ MVP |
| RadioButton | `FWoWRadioButtonTemplate` | ✅ MVP |
| ToggleSwitch | `FWoWToggleSwitchTemplate` | ✅ MVP |
| TextBox + SearchBox | `FWoWTextBoxTemplate` | ✅ MVP |
| Slider | `FWoWSliderTemplate` | ✅ MVP |
| ComboBox | `FWoWComboBoxTemplate` | ✅ MVP |

### Feedback / Status

| Control | Template | Status |
| --- | --- | --- |
| ProgressBar (det. + indet.) | `FWoWProgressBarTemplate` | ✅ MVP |
| ProgressRing | `FWoWProgressRingTemplate` | ✅ MVP |
| InfoBar (4 severities) | `FWoWInfoBarTemplate` | ✅ MVP |
| ContentDialog | `FWoWContentDialogTemplate` | ✅ MVP |

### Navigation / Layout

| Control | Template | Status |
| --- | --- | --- |
| MainFrame | `FWoWMainFrameTemplate` | ✅ MVP |
| TabView | `FWoWTabViewTemplate` | ✅ MVP |
| Expander | `FWoWExpanderTemplate` | ✅ MVP |
| ScrollFrame | `FWoWScrollFrameTemplate` | ✅ MVP |
| VStack / HStack | `FWoWStackLayoutTemplate` | ✅ MVP |

### Settings

| Control | Template | Status |
| --- | --- | --- |
| SettingsCard | `FWoWSettingsCardTemplate` | ✅ MVP |
| SettingsExpander | `FWoWSettingsExpanderTemplate` | ✅ MVP |

### Navigation / Advanced

| Control | Template | Status |
| --- | --- | --- |
| NavigationView | `FWoWNavigationViewTemplate` | ✅ Phase 2 |
| BreadcrumbBar | `FWoWBreadcrumbBarTemplate` | ✅ Phase 2 |
| NumberBox | `FWoWNumberBoxTemplate` | ✅ Phase 2 |
| TeachingTip | `FWoWTeachingTipTemplate` | ✅ Phase 2 |
| CommandBar | `FWoWCommandBarTemplate` | ✅ Phase 2 |
| SegmentedControl | `FWoWSegmentedControlTemplate` | ✅ Phase 2 |
| Badge | `FWoWBadgeTemplate` | ✅ Phase 2 |
| EmptyState | `FWoWEmptyStateTemplate` | ✅ Phase 2 |
| Skeleton | `FWoWSkeletonTemplate` | ✅ Phase 2 |

### Planned (Phase 3+)

- Virtualized list (true row recycling)
- Grid layout container
- Responsive width classes
- Connected animation helpers

---

## 6. Token System

```lua
-- Retrieve a colour token
local r, g, b, a = FluentWoW.Tokens:GetColor("Color.Accent.Primary")

-- Retrieve a spacing value
local gap = FluentWoW.Tokens:GetSpacing("MD")   -- → 8

-- Retrieve a font
local font, size, flags = FluentWoW.Tokens:GetFont("Body")

-- Override a token at runtime (highest priority)
FluentWoW.Tokens:Override({
    ["Color.Accent.Primary"] = { 0.80, 0.20, 0.80, 1 },
})

-- Switch to a custom theme
FluentWoW.Tokens:RegisterTheme("MyTheme", { ... })
FluentWoW.Tokens:SetTheme("MyTheme")
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
   `FluentWoW.Tokens` at runtime so themes work
3. **VSM callbacks** — `OnStateChanged(newState, prevState)` mutates textures
   when the control state transitions (hover, press, disabled, etc.)

```lua
-- Custom variant: override accent colour on a single button
local btn = FluentWoW:CreateButton(parent, nil, "Accent")
btn:SetAccentColor(0.80, 0.20, 0.80)
```

To create a full custom theme:

```lua
FluentWoW.Tokens:RegisterTheme("Christmas", {
    Color = { Accent = { Primary = { 1, 0.1, 0.1, 1 } } }
})
FluentWoW.Tokens:SetTheme("Christmas")
-- All controls automatically use the new accent colour on next state update.
```

---

## 8. Layout Model

**FluentWoW does not use absolute positioning internally.**
All controls use `SetPoint` relative anchors, and layout containers
(`StackLayout`) manage child anchors programmatically.

```lua
local stack = FluentWoW:CreateStackLayout(parent, nil, "VERTICAL")
stack:SetPoint("TOPLEFT", parent, "TOPLEFT", 16, -16)
stack:SetWidth(400)
stack:SetGap(8)
stack:SetPadding(16, 16, 16, 16)  -- top, right, bottom, left

local btn1 = FluentWoW:CreateButton(stack, nil, "Accent")
btn1:SetText("Action 1")
local btn2 = FluentWoW:CreateButton(stack, nil, "Subtle")
btn2:SetText("Action 2")
stack:AddChild(btn1)
stack:AddChild(btn2)
-- Stack auto-sizes height to fit children.
```

---

## 9. Motion Model

All animations respect `FluentWoW.Motion.reducedMotion = true` (skip motion).

| Preset | Duration token | Use case |
| --- | --- | --- |
| `FadeIn` | `Motion.Duration.Entrance` (0.25s) | Dialog / panel appear |
| `FadeOut` | `Motion.Duration.Exit` (0.15s) | Dismiss / hide |
| `SlideIn` | `Motion.Duration.Entrance` | Flyout entrance |
| `ScalePress` | `Motion.Duration.Fast` (0.10s) | Click tactile feedback |

---

## 10. Settings / Developer Experience

### Creating a settings panel

```lua
-- Build a settings page using SettingsCard + SettingsExpander
local ts = FluentWoW:CreateToggleSwitch(parent)
ts:SetIsOn(MyAddon_DB.enabled)
ts:SetOnToggled(function(self, isOn)
    MyAddon_DB.enabled = isOn
end)

local card = FluentWoW:CreateSettingsCard(parent)
card:SetTitle("Enable MyAddon")
card:SetDescription("Turn the addon on or off without disabling it.")
card:SetActionControl(ts)
card:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -8)
card:SetWidth(500)
```

### Theme overriding

```lua
-- Per-addon accent colour without forking the whole framework
FluentWoW.Tokens:Override({
    ["Color.Accent.Primary"] = { 0.9, 0.6, 0.1, 1 },  -- gold
})
```

### Version guard

```lua
-- Addons consuming the framework should guard on version:
assert(FluentWoW and FluentWoW.version >= 10000,
    "MyAddon requires FluentWoW 1.0.0 or later")
```

---

## 11. Gallery Addon

Open with: `/fwow`

Pages:

- **Buttons** — Button variants, ToggleButton, state demo
- **Input Controls** — CheckBox, RadioButton, ToggleSwitch, TextBox, Slider, ComboBox
- **Feedback & Dialogs** — ProgressBar, ProgressRing, InfoBar, ContentDialog, Expander
- **Layout & Navigation** — VStack, HStack, TabView
- **Navigation** — NavigationView, BreadcrumbBar
- **Advanced Controls** — NumberBox, CommandBar, SegmentedControl, Badge, TeachingTip, EmptyState, Skeleton
- **Settings Controls** — SettingsCard, SettingsExpander

---

## 12. Testing Strategy

### Unit tests (Lua-side, no WoW API required)

- Token resolution order (override → theme → default) for Color tokens
- Design constants immutability (spacing, typography, radii, motion, opacity cannot be overridden)
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
| --- | --- |
| Open ComboBox during combat | Blocked with debug log; no error |
| Open ContentDialog during combat | Deferred; opens on PLAYER_REGEN_ENABLED |
| ToggleSwitch click during combat | Allowed (non-secure frame) |
| Button click during combat | Allowed |
| Theme switch during combat | Allowed |

---

## 13. Adoption Strategy

FluentWoW is designed for incremental adoption:

1. **Zero controls** — just use the token system for consistent colours/spacing
2. **One control** — embed a single `Button` or `ToggleSwitch` without the rest
3. **Settings panel** — replace bespoke settings UIs with `SettingsCard` groups
4. **Full framework** — build entire addon UIs with layout + controls + motion

### Embedding (standalone distribution)
Addons can list `FluentWoW` as a `Dependencies:` entry in their TOC.

### Library load-order negotiation
`Bootstrap.lua` guards on version: if FluentWoW is already loaded with a higher
version, the embed exits cleanly.  The richest feature set present in the
session is always used.

---

## 14. Risks & Non-Goals

### Risks

| Risk | Mitigation |
| --- | --- |
| Combat lockdown taint | All dialogs/dropdowns guard `InCombatLockdown()` |
| Overengineering | MVP-first roadmap; experimental controls are gated |
| Visual inconsistency with Blizzard | Token system allows Blizzard-aligned theme |
| Performance | `FramePool` recycles frames; `OnUpdate` is stopped when idle |
| Theme fragmentation | Two official themes (Dark + Light); community themes are addons |
| API churn | Semantic versioning; deprecated APIs kept for 2 minor versions |

### Non-Goals

- Direct XAML port (WoW has no layout engine)
- Replacing Ace3 configuration DB (`AceDB` should still be used for saved vars)
- Providing a "look like Blizzard UI" theme (FluentWoW has its own design language)
- Pixel-perfect shadow/blur effects
- Touch input support
- Widescreen-specific layouts

---

## 15. Phased Roadmap

### Phase 0 – Research & feasibility ✅

- Established WoW addon constraints
- Mapped WinUI concepts to WoW primitives
- Defined token system and naming conventions

### Phase 1 – Core runtime + tokens + MVP controls ✅

- Vendored libraries: LibStub, flux motion engine
- Bootstrap, Utils, EventBus, StateMachine, FramePool
- Token registry + Dark theme + Light theme
- Assets: FluentIcons glyph map, bundled fonts
- Controls: MainFrame, Button, CheckBox, RadioButton, ToggleSwitch,
  TextBlock, TextBox, Slider, ProgressBar, ComboBox, InfoBar,
  ContentDialog, Expander, TabView, ScrollFrame
- Layout: StackLayout (VStack / HStack)
- Motion: Tween engine with 28 easing functions + timer API
- Settings: SettingsCard, SettingsExpander
- Gallery: 5-page showcase addon (`/fwow`)

### Phase 2 – Navigation + advanced controls ✅

- `NavigationView` sidebar control
- `BreadcrumbBar`
- `NumberBox` (validated numeric input)
- `TeachingTip` (coach marks / contextual teaching)
- `CommandBar` / Toolbar
- `SegmentedControl`
- `Badge` / status pill
- `EmptyState` placeholder
- `Skeleton` loading state
- Gallery: Navigation page + Advanced Controls page

### Phase 3 – Layout + motion polish

- `Grid` layout container
- Responsive width classes
- Virtualized list rows (true FramePool recycling)
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

1. Never hardcode colour values — always use `Tokens:GetColor()` (spacing, font sizes, radii, motion, and opacity ARE intentionally hardcoded design constants and must not be moved to themes)
2. Never call `Show()` on a protected frame in combat
3. Never use absolute pixel positions — anchor relative to parent
4. Always gate destructive operations with `InCombatLockdown()`
5. Always use `FramePool` for repeated frame creation
6. Always stop `OnUpdate` scripts when the animation completes
7. Never add new Lua globals — everything lives under `FluentWoW.*`
8. Always expose `OnStateChanged` so theming can react to state
9. Never remove or rename a public API without a deprecation cycle
10. Always test at UIParent scale 0.64 and 1.5 to catch pixel snapping

---

## 17. Final Verdict

FluentWoW is **viable** under the following discipline constraints:

- **Library-first**: Never ship FluentWoW as a standalone visible addon.
- **Token-driven**: Colors come from the theme system; spacing, font sizes, radii, motion, and opacity are hardcoded design constants in `Registry.lua`.
- **Combat-aware**: Every popup/dialog must guard `InCombatLockdown()`.
- **Performance budget**: `OnUpdate` handlers must terminate; frame pools are
  mandatory for list-like content.
- **Incremental**: Release Phase 1 as stable, gate Phase 2+ as experimental
  until proven in at least two production addons.

The framework fills a genuine gap in the WoW addon ecosystem and can realistically
achieve Ace3-like adoption if it ships with a polished gallery, clear docs,
and a zero-friction `Dependencies: FluentWoW` onboarding path.
