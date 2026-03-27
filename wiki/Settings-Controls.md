# Settings Controls

FluentWoW ports the [Windows Community Toolkit](https://github.com/CommunityToolkit/Windows) `SettingsCard` and `SettingsExpander` controls — the standard building blocks for addon settings panels.

---

## SettingsCard

A horizontal card with an icon, title, description, and a trailing action control (toggle, dropdown, button, etc.). The standard unit for constructing settings pages.

**Reference:** [CommunityToolkit SettingsCard](https://learn.microsoft.com/dotnet/communitytoolkit/windows/settingscard)

### Creation

```lua
local lib = FluentWoW

-- Card with a ToggleSwitch action
local toggle = lib:CreateToggleSwitch(parent)
toggle:SetOnContent("On")
toggle:SetOffContent("Off")
toggle:SetIsOn(MyDB.enabled)
toggle:SetOnToggled(function(self, isOn)
    MyDB.enabled = isOn
end)

local card = lib:CreateSettingsCard(parent, "EnableCard")
card:SetTitle("Enable Addon")
card:SetDescription("Turn the addon on or off globally.")
card:SetIconTexture("Interface\\Icons\\INV_Misc_Gear_01")
card:SetActionControl(toggle)
card:SetPoint("TOP", parent, "TOP", 0, -8)
card:SetSize(400, 0)  -- height auto-adjusts based on description text
```

### Card With ComboBox

```lua
local dd = lib:CreateComboBox(parent)
dd:SetItems({
    { text = "English",  value = "en" },
    { text = "Deutsch",  value = "de" },
    { text = "Français", value = "fr" },
})
dd:SetSelectedIndex(1)

local langCard = lib:CreateSettingsCard(parent)
langCard:SetTitle("Language")
langCard:SetDescription("Choose your preferred display language.")
langCard:SetActionControl(dd)
```

### Clickable Card (No Action Control)

```lua
local navCard = lib:CreateSettingsCard(parent)
navCard:SetTitle("About")
navCard:SetDescription("Version info, credits, and license.")
navCard:SetClickable(true)
navCard:SetOnClick(function(self)
    showAboutPage()
end)
```

### API

| Method | Parameters | Returns | Description |
| --- | --- | --- | --- |
| `SetTitle(text)` | `string` | — | Card title text |
| `SetDescription(text)` | `string` | — | Subtitle / description (auto-resizes height) |
| `SetIconTexture(path)` | `string\|number` | — | Icon texture path or fileID |
| `SetActionControl(ctrl)` | `Frame` | — | Embed a trailing action control |
| `GetActionControl()` | — | `Frame?` | Get current action control |
| `SetClickable(clickable)` | `boolean` | — | Make the entire card clickable |
| `SetOnClick(fn)` | `function(self)` | — | Click callback (only if clickable) |

### Visual States

`Normal` → `Hover` → `Pressed` → `Disabled`

On hover, the card background lightens. The card automatically registers/unregisters a theme listener on show/hide.

---

## SettingsExpander

An expandable container with a header row (icon + title + description) and collapsible child cards. Perfect for grouping related settings.

**Reference:** [CommunityToolkit SettingsExpander](https://learn.microsoft.com/dotnet/communitytoolkit/windows/settingsexpander)

### Creation

```lua
local lib = FluentWoW

local expander = lib:CreateSettingsExpander(parent, "DisplayExpander")
expander:SetTitle("Display")
expander:SetDescription("Configure how the UI is rendered.")
expander:SetIconTexture("Interface\\Icons\\INV_Misc_Eye_01")
expander:SetPoint("TOP", parent, "TOP", 0, -8)
expander:SetSize(400, 0)

-- Add child cards
local scaleToggle = lib:CreateToggleSwitch(expander)
local card1 = lib:CreateSettingsCard(expander)
card1:SetTitle("Auto-Scale")
card1:SetDescription("Automatically adjust scale based on resolution.")
card1:SetActionControl(scaleToggle)
expander:AddCard(card1)

local slider = lib:CreateSlider(expander)
slider:SetRange(50, 200)
slider:SetValue(100)
slider:SetStep(10)
slider:SetShowValue(true)
slider:SetValueFormatter(function(v) return v .. "%" end)

local card2 = lib:CreateSettingsCard(expander)
card2:SetTitle("Scale Override")
card2:SetDescription("Manual UI scale percentage.")
card2:SetActionControl(slider)
expander:AddCard(card2)

-- Start expanded
expander:SetExpanded(true)
```

### API

| Method | Parameters | Returns | Description |
| --- | --- | --- | --- |
| `SetTitle(text)` | `string` | — | Header title text |
| `SetDescription(text)` | `string` | — | Header subtitle (auto-resizes) |
| `SetIconTexture(path)` | `string\|number` | — | Header icon texture or fileID |
| `SetExpanded(exp, instant?)` | `boolean, boolean?` | — | Expand/collapse with animation |
| `IsExpanded()` | — | `boolean` | Check expanded state |
| `AddCard(card)` | `Frame` | — | Add a child card (any frame) |
| `RemoveCard(card)` | `Frame` | — | Remove a child card |
| `GetCards()` | — | `table` | Get all child cards |
| `SetOnToggled(fn)` | `function(self, expanded)` | — | Expand/collapse callback |

### Visual States

`Normal` → `Hover` → `Expanded` → `Disabled`

### Layout

Child cards are stacked vertically inside the expander body, separated by 1px token-coloured dividers. The expand/collapse animation uses `Motion:HeightTo()` with a smooth easing curve.

---

## Complete Settings Page Example

```lua
local lib = FluentWoW

-- Create a MainFrame for settings
local frame = lib:CreateMainFrame("MyAddonSettings", "MyAddon — Settings")
local content = frame:GetContentArea()

-- Wrap in a scroll frame for long pages
local scroll = lib:CreateScrollFrame(content, "SettingsScroll")
scroll:SetAllPoints(content)
local scrollChild = scroll:GetScrollChild()

-- Vertical stack
local stack = lib:CreateStackLayout(scrollChild, nil, "VERTICAL")
stack:SetGap(4)
stack:SetPadding(0, 0, 0, 0)
stack:SetPoint("TOPLEFT", 0, 0)
stack:SetPoint("TOPRIGHT", 0, 0)

-- ── General section ──
local generalExp = lib:CreateSettingsExpander(stack)
generalExp:SetTitle("General")
generalExp:SetDescription("Core addon settings")
stack:AddChild(generalExp)

local enableToggle = lib:CreateToggleSwitch(generalExp)
enableToggle:SetOnContent("On")
enableToggle:SetOffContent("Off")

local enableCard = lib:CreateSettingsCard(generalExp)
enableCard:SetTitle("Enable Addon")
enableCard:SetDescription("Turn the addon on or off.")
enableCard:SetActionControl(enableToggle)
generalExp:AddCard(enableCard)

-- ── Appearance section ──
local appearanceExp = lib:CreateSettingsExpander(stack)
appearanceExp:SetTitle("Appearance")
appearanceExp:SetDescription("Visual customisation")
stack:AddChild(appearanceExp)

local themeDD = lib:CreateComboBox(appearanceExp)
themeDD:SetItems({
    { text = "Dark",  value = "Dark" },
    { text = "Light", value = "Light" },
})
themeDD:SetSelectedIndex(1)
themeDD:SetOnSelectionChanged(function(self, idx)
    lib.Tokens:SetTheme(self:GetSelectedValue())
end)

local themeCard = lib:CreateSettingsCard(appearanceExp)
themeCard:SetTitle("Theme")
themeCard:SetDescription("Choose between dark and light modes.")
themeCard:SetActionControl(themeDD)
appearanceExp:AddCard(themeCard)

-- Update scroll height
stack:SetScript("OnSizeChanged", function(self, w, h)
    scroll:SetContentHeight(h)
end)

frame:Open()
```
