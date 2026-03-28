# Architecture

FluentWoW ports the spirit, quality bar, and design language of [WinUI 3](https://github.com/microsoft/microsoft-ui-xaml), [WinUI Gallery](https://github.com/microsoft/WinUI-Gallery), and the [Windows Community Toolkit](https://github.com/CommunityToolkit/Windows) into the World of Warcraft addon ecosystem. It is a library-first Lua/XML platform that addon developers embed or depend on to build modern, consistent, high-fidelity interfaces without re-inventing styling, state management, layout, or motion.

It is **not** a skin pack, not a one-off addon UI, and not a literal XAML clone. It extracts the transferable principles from Windows Fluent Design and maps them onto WoW-native frame constraints.

---

## Library Conventions

FluentWoW follows the standard Ace3 library pattern:

- **LibStub registration** — `LibStub("FluentWoW-1.0")` returns the singleton
- **Version negotiation** — only the newest copy loads when multiple addons embed it
- **Embed support** — `AceAddon:NewAddon("MyAddon", "FluentWoW-1.0")` mixes all `Create*` methods, `Tokens`, `EventBus`, and `Motion` into the consumer addon
- **No global dependency** — consumers should always access the library through `LibStub`, not the `FluentWoW` global

See [Getting Started](Getting-Started) for consumer setup.

---

## Directory Layout

```text
FluentWoW/
├── FluentWoW.toc                 TOC load-order manifest
├── Libs/
│   ├── LibStub/LibStub.lua       Vendored Ace3 library stub
│   └── Motion/                   Vendored flux-derived tweening engine
├── Core/
│   ├── Bootstrap.lua             LibStub registration, version guard, Embed
│   ├── Utils.lua                 Table, string, colour, frame helpers
│   ├── EventBus.lua              Pub/sub decoupling layer
│   ├── StateMachine.lua          Visual state machine (VSM) for controls
│   └── FramePool.lua             Frame recycling for lists / dropdowns
├── Tokens/
│   ├── Registry.lua              Token resolution + hardcoded design constants
│   ├── DarkTheme.lua             Dark-theme colour table
│   └── LightTheme.lua            Light-theme colour table
├── Assets/
│   ├── FluentIcons.lua           Segoe Fluent Icons glyph map
│   ├── Fonts/                    Bundled font files
│   └── Textures/                 9-slice corners, shadows, pills, rings
├── Controls/
│   ├── Base/ControlBase.lua      Shared mixin: VSM, tooltip, enable/disable,
│   │                             theme listener, MainFrame enforcement
│   ├── MainFrame/                Application window shell
│   ├── Button/                   Button, IconButton, ToggleButton
│   ├── CheckBox/
│   ├── RadioButton/
│   ├── ToggleSwitch/
│   ├── TextBlock/
│   ├── TextBox/                  TextBox, SearchBox
│   ├── Slider/
│   ├── ProgressBar/              ProgressBar, ProgressRing
│   ├── ComboBox/
│   ├── InfoBar/
│   ├── ContentDialog/
│   ├── Expander/
│   ├── TabView/
│   ├── ScrollFrame/
│   ├── NavigationView/
│   ├── BreadcrumbBar/
│   ├── NumberBox/
│   ├── TeachingTip/
│   ├── CommandBar/
│   ├── SegmentedControl/
│   ├── Badge/
│   ├── EmptyState/
│   └── Skeleton/
├── Layout/
│   └── StackLayout.xml/.lua      VStack / HStack (StackPanel equivalent)
├── Motion/
│   └── Motion.lua                Tween-based animation presets
└── Settings/
    ├── SettingsCard.xml/.lua
    └── SettingsExpander.xml/.lua

FluentWoW-Gallery/
├── FluentWoW-Gallery.toc
├── Gallery.lua                   Window shell + sidebar navigation
└── Pages/                        ButtonPage, InputPage, FeedbackPage, etc.
```

---

## Module Responsibilities

| Module | Purpose | Combat-safe? |
| --- | --- | --- |
| `Core/Bootstrap` | LibStub registration, version guard, Embed, module registry | Yes |
| `Core/Utils` | Table, string, colour, frame helpers | Yes |
| `Core/EventBus` | Pub/sub decoupling (`On`, `Off`, `Once`, `Emit`) | Yes |
| `Core/StateMachine` | Per-control visual state tracking | Yes |
| `Core/FramePool` | Frame recycling (`Acquire` / `Release`) | Yes |
| `Tokens/Registry` | Token lookup, override chain, theme switching | Yes |
| `Tokens/DarkTheme` | Dark-theme colour values (default) | Yes |
| `Tokens/LightTheme` | Light-theme colour values | Yes |
| `Assets/FluentIcons` | Icon glyph → codepoint mapping | Yes |
| `Controls/*` | All UI controls (XML template + Lua behaviour) | Mostly (see notes) |
| `Layout/StackLayout` | VStack / HStack auto-layout | Yes |
| `Motion/Motion` | Animation presets (FadeIn, SlideIn, ScalePress, etc.) | Yes |
| `Settings/*` | SettingsCard, SettingsExpander | Yes |

---

## Three-Layer Styling Model

Controls are styled through three cooperating layers:

1. **XML template** — visual structure (textures, font strings, sizing, anchors)
2. **Token resolution** — colours, fonts, and spacing resolved from `FluentWoW.Tokens` at runtime so themes work
3. **VSM callbacks** — `OnStateChanged(newState, prevState)` mutates textures when the control state transitions (Hover, Pressed, Disabled, etc.)

When a theme changes, `ControlBase` fires `OnStateChanged` on every control so they re-resolve their tokens automatically.

---

## Token Resolution Order

```
Token("Color.Accent.Primary")
  ↓
1. Runtime overrides (Tokens:Override)    → found? return
  ↓
2. Active theme ("Light", "Horde", etc.)  → found? return
  ↓
3. Dark theme (always-present fallback)   → found? return
  ↓
4. nil + debug warning
```

Spacing, typography, radii, motion, opacity, and icon sizes are hard-coded design constants in `Registry.lua` and are not part of the theme chain.

See [Token System](Token-System) for the complete token reference.

---

## Control Lifecycle

1. Consumer calls `FluentWoW:CreateButton(parent, name, style)` (or any factory)
2. Factory creates a frame from the XML template, applies the Lua mixin
3. `ControlBase:WUILInit()` runs — creates the VSM, validates MainFrame ancestry, hooks `ThemeChanged`
4. Tokens are resolved and applied via `OnStateChanged("Normal")`
5. User interaction triggers state transitions (Hover → Pressed → Normal)
6. Theme changes fire `OnStateChanged` for the current state, refreshing all token-derived visuals

### MainFrame Requirement

All FluentWoW controls must be descendants of a `CreateMainFrame()` window. Controls created outside a MainFrame hierarchy emit a debug warning. The only exceptions are **ContentDialog** and **TeachingTip**, which are fullscreen overlays parented to `UIParent`.

---

## Combat Safety

FluentWoW respects WoW's combat lockdown system:

- **All controls** can be read and styled safely during combat
- **Show/Hide** of secure frames is blocked during `InCombatLockdown()`
- `MainFrame:Open()`, `ContentDialog:Open()`, and `ComboBox` dropdown are combat-guarded
- Non-secure operations (token reads, state changes, styling) work normally in combat

---

## Embed Protocol

FluentWoW implements the Ace3 Embed contract. Libraries that expose `:Embed()` are auto-embedded by `AceAddon:NewAddon()` when listed in the mixin varargs.

```lua
-- AceAddon auto-embed
local MyAddon = LibStub("AceAddon-3.0"):NewAddon("MyAddon", "FluentWoW-1.0")

-- Manual embed (for non-Ace3 consumers)
local myTable = {}
LibStub("FluentWoW-1.0"):Embed(myTable)
local btn = myTable:CreateButton(parent)
```

What gets embedded:

- All `Create*` factory methods
- `Tokens` (token registry)
- `EventBus` (pub/sub)
- `Motion` (animation engine)

The embed table is tracked in `lib.embeds` so that library upgrades re-Embed existing consumers automatically.

---

## Adoption Strategy

FluentWoW is designed for incremental adoption:

1. **Zero controls** — just use the token system for consistent colours and spacing
2. **MainFrame shell** — create a `CreateMainFrame()` as your addon's root window
3. **One control** — add a Button or ToggleSwitch inside the MainFrame
4. **Settings panel** — replace bespoke settings UIs with SettingsCard groups
5. **Full framework** — build entire addon UIs with layout + controls + motion

---

## Risks & Non-Goals

### Risks

| Risk | Mitigation |
| --- | --- |
| Combat lockdown taint | All dialogs/dropdowns guard `InCombatLockdown()` |
| Overengineering | MVP-first roadmap; experimental controls are gated |
| Performance | `FramePool` recycles frames; Motion `OnUpdate` auto-parks when idle |
| Theme fragmentation | Two official themes (Dark + Light); community themes are addons |
| API churn | Semantic versioning; deprecated APIs kept for 2 minor versions |

### Non-Goals

- Direct XAML port (WoW has no layout engine)
- Replacing AceDB for saved variables
- Providing a "look like Blizzard UI" theme
- Pixel-perfect shadow/blur effects
- Touch input support
