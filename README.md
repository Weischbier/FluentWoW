# FluentWoW

**WinUI-inspired UI framework for World of Warcraft addon developers.**

FluentWoW ports the spirit, quality bar, and design language of [WinUI 3](https://github.com/microsoft/microsoft-ui-xaml) + [WinUI Gallery](https://github.com/microsoft/WinUI-Gallery) + [Windows Community Toolkit](https://github.com/CommunityToolkit/Windows) into the World of Warcraft addon ecosystem — providing reusable controls, a design-token system, layout primitives, motion helpers, and a live gallery addon.

> Open the gallery in-game with `/wuil`

---

## Features

| Category | Controls |
|---|---|
| **Buttons** | Button (Accent / Subtle / Destructive), IconButton, ToggleButton |
| **Input** | CheckBox, RadioButton, ToggleSwitch, TextBox, SearchBox, Slider, ComboBox |
| **Feedback** | ProgressBar, ProgressRing, InfoBar (4 severities), ContentDialog |
| **Navigation** | TabView, Expander, ScrollFrame |
| **Layout** | VStack, HStack (StackLayout) |
| **Settings** | SettingsCard, SettingsExpander |

---

## Quick Start

### 1. Declare dependency in your TOC

```
Dependencies: FluentWoW
```

### 2. Create controls in Lua

```lua
-- Button
local btn = FluentWoW:CreateButton(parent, "Accent", "Save Settings")
btn.OnActivated = function(self) MyAddon:Save() end

-- ToggleSwitch
local ts = FluentWoW:CreateToggleSwitch(parent, "On", "Off")
ts:SetOn(MyAddon_DB.enabled)
ts.OnToggled = function(self, isOn) MyAddon_DB.enabled = isOn end

-- SettingsCard
local card = FluentWoW:CreateSettingsCard(parent,
    "Enable MyAddon",
    "Turn the addon on or off without /reload.", ts)
```

### 3. Use tokens for consistent styling

```lua
local r, g, b, a = FluentWoW.Tokens:GetColor("Color.Accent.Primary")
local gap         = FluentWoW.Tokens:GetSpacing("MD")  -- 8 px
```

### 4. Override tokens for a custom theme

```lua
FluentWoW.Tokens:Override({
    ["Color.Accent.Primary"] = { 0.9, 0.6, 0.1, 1 },  -- gold accent
})
```

---

## Structure

```
FluentWoW/              Main library (add as dependency)
  Core/                Bootstrap, Utils, EventBus, StateMachine, FramePool
  Tokens/              Token registry + Default dark theme
  Controls/            All UI controls (XML templates + Lua behaviour)
  Layout/              StackLayout (VStack / HStack)
  Motion/              FadeIn, FadeOut, SlideIn, ScalePress
  Settings/            SettingsCard, SettingsExpander

FluentWoW-Gallery/      Interactive showcase addon (/wuil)
  Pages/               ButtonPage, InputPage, FeedbackPage, LayoutPage, SettingsPage
```

See [ARCHITECTURE.md](ARCHITECTURE.md) for the full design reference, principle
translation matrix, token system docs, roadmap, and adoption guide.

---

## Design references

- [microsoft/WinUI-Gallery](https://github.com/microsoft/WinUI-Gallery)
- [microsoft/microsoft-ui-xaml](https://github.com/microsoft/microsoft-ui-xaml)
- [CommunityToolkit/Windows](https://github.com/CommunityToolkit/Windows)
- [Microsoft Learn — Windows app design basics](https://learn.microsoft.com/windows/apps/design/basics/)

---

## License

MIT — see [LICENSE](LICENSE)
