# Icons

FluentWoW bundles the **Segoe Fluent Icons** font and provides a complete glyph map for use in controls, buttons, and custom UI.

---

## Setup

The icon font and glyph map are loaded automatically via `Assets/FluentIcons.lua`. No additional setup is needed.

### Font Path

```lua
FluentWoW.FLUENT_ICON_FONT
-- → "Interface\\AddOns\\FluentWoW\\Assets\\Fonts\\Segoe Fluent Icons.ttf"
```

### Glyph Map

```lua
FluentWoW.Icons
-- Table of named icon → UTF-8 glyph string
```

---

## Usage

### In a FontString

```lua
local fs = myFrame:CreateFontString(nil, "OVERLAY")
fs:SetFont(FluentWoW.FLUENT_ICON_FONT, 16, "")
fs:SetText(FluentWoW.Icons.Settings)
```

### In an IconButton

```lua
local btn = FluentWoW:CreateIconButton(parent)
-- The IconButton's Icon child is a Texture, not a FontString.
-- For glyph-based icons, create a FontString overlay:
local glyph = btn:CreateFontString(nil, "OVERLAY")
glyph:SetFont(FluentWoW.FLUENT_ICON_FONT, 16, "")
glyph:SetText(FluentWoW.Icons.ChevronDown)
glyph:SetPoint("CENTER")
```

### In Control Text

Some controls accept icon glyphs directly as text content:

```lua
-- CheckBox uses icon font for checkmark/dash internally
-- TabView tabs accept icon strings
tabs:SetTabs({
    { text = "Home",     icon = FluentWoW.Icons.Home },
    { text = "Settings", icon = FluentWoW.Icons.Settings },
})
```

---

## Available Icons

The glyph map covers hundreds of icons from the [Microsoft Segoe Fluent Icons](https://learn.microsoft.com/windows/apps/design/iconography/segoe-fluent-icons-font) font family. Icons are encoded as UTF-8 strings from the U+E700–U+F8CC Unicode range.

### Common Icons

| Name | Codepoint | Use |
|---|---|---|
| `Icons.Settings` | U+E713 | Settings gear |
| `Icons.Search` | U+E721 | Search magnifier |
| `Icons.ChevronDown` | U+E70D | Dropdown arrow |
| `Icons.ChevronUp` | U+E70E | Collapse arrow |
| `Icons.ChevronRight` | U+E76C | Forward / expand |
| `Icons.ChevronLeft` | U+E76B | Back / collapse |
| `Icons.CheckMark` | U+E73E | Checkmark |
| `Icons.Cancel` | U+E711 | Close × |
| `Icons.Add` | U+E710 | Plus + |
| `Icons.Remove` | U+E738 | Minus / dash |
| `Icons.Delete` | U+E74D | Trash can |
| `Icons.Edit` | U+E70F | Pencil |
| `Icons.Save` | U+E74E | Floppy disk |
| `Icons.Refresh` | U+E72C | Refresh arrows |
| `Icons.Info` | U+E946 | Info circle |
| `Icons.Warning` | U+E7BA | Warning triangle |
| `Icons.Error` | U+EA39 | Error circle |
| `Icons.Home` | U+E80F | Home |
| `Icons.Brightness` | U+E706 | Sun / brightness |
| `Icons.DeveloperTools` | U+EC7A | Code brackets |

> The full icon list is defined in `Assets/FluentIcons.lua`. Browse the file for all available icon names.

---

## Sizing Guidelines

| Token | Size | Use |
|---|---|---|
| `Icon.SM` | 12px | Inline icons in body text |
| `Icon.MD` | 16px | Standard control icons |
| `Icon.LG` | 20px | Header / title icons |

```lua
local size = FluentWoW.Tokens:GetNumber("Icon.MD")  -- 16
fs:SetFont(FluentWoW.FLUENT_ICON_FONT, size, "")
```

---

## Colouring Icons

Icon FontStrings respond to `SetTextColor`:

```lua
fs:SetTextColor(FluentWoW.Tokens:GetColor("Color.Icon.Default"))

-- Or match accent
fs:SetTextColor(FluentWoW.Tokens:GetColor("Color.Accent.Primary"))
```

For Texture-based icons, use `SetVertexColor`:

```lua
icon:SetVertexColor(FluentWoW.Tokens:GetColor("Color.Icon.Default"))
```
