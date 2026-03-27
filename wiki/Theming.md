# Theming

FluentWoW ships with two built-in themes (**Dark** and **Light**) and provides a straightforward API for creating and switching custom themes at runtime.

---

## Built-in Themes

| Theme | Registered Name | Description |
|---|---|---|
| Dark (default) | `"Default"` | Dark surfaces, light text, blue accent |
| Light | `"Light"` | Light surfaces, dark text, deeper blue accent |

The dark theme loads via `Tokens/DefaultTheme.lua` and the light theme via `Tokens/LightTheme.lua`. Both are always available.

---

## Switching Themes

```lua
-- Switch to light mode
FluentWoW.Tokens:SetTheme("Light")

-- Switch back to dark mode
FluentWoW.Tokens:SetTheme("Default")

-- Check current theme
local name = FluentWoW.Tokens:GetThemeName()  -- "Default" or "Light"

-- List available themes
local themes = FluentWoW.Tokens:GetAvailableThemes()
-- { Default = true, Light = true }
```

### Automatic Control Updates

When `SetTheme()` is called, the EventBus emits a `"ThemeChanged"` event. All built-in controls listen for this event and re-apply their visual styling automatically. You don't need to manually refresh anything.

---

## Creating a Custom Theme

A theme is a Lua table whose keys match the token names from the [Token System](Token-System) reference. You only need to include the tokens you want to change — missing keys fall through to the `"Default"` theme.

### Step 1 — Define the Token Table

```lua
local myTheme = {
    -- Override accent to gold
    ["Color.Accent.Primary"]  = { 0.90, 0.70, 0.15, 1 },
    ["Color.Accent.Hover"]    = { 0.95, 0.78, 0.25, 1 },
    ["Color.Accent.Pressed"]  = { 0.80, 0.60, 0.10, 1 },
    ["Color.Accent.Light"]    = { 1.00, 0.85, 0.40, 1 },

    -- Darker surfaces
    ["Color.Surface.Base"]    = { 0.08, 0.08, 0.10, 1 },
    ["Color.Surface.Raised"]  = { 0.12, 0.12, 0.14, 1 },

    -- Custom typography
    Typography = {
        Display = { font = "Fonts\\MORPHEUS.ttf", size = 32, flags = "" },
    },
}
```

### Step 2 — Register It

```lua
FluentWoW.Tokens:RegisterTheme("Gold", myTheme)
```

### Step 3 — Activate It

```lua
FluentWoW.Tokens:SetTheme("Gold")
```

### Full Theme Example

Here's a complete "Horde Red" theme:

```lua
local hordeTheme = {
    -- Accent: blood red
    ["Color.Accent.Primary"]  = { 0.80, 0.15, 0.15, 1 },
    ["Color.Accent.Hover"]    = { 0.90, 0.25, 0.25, 1 },
    ["Color.Accent.Pressed"]  = { 0.65, 0.10, 0.10, 1 },
    ["Color.Accent.Light"]    = { 1.00, 0.40, 0.40, 1 },

    -- Surfaces: dark warm grey
    ["Color.Surface.Base"]     = { 0.10, 0.08, 0.08, 1 },
    ["Color.Surface.Raised"]   = { 0.15, 0.12, 0.12, 1 },
    ["Color.Surface.Overlay"]  = { 0.20, 0.16, 0.16, 1 },
    ["Color.Surface.Elevated"] = { 0.25, 0.20, 0.20, 1 },
    ["Color.Surface.Stroke"]   = { 0.30, 0.24, 0.24, 1 },

    -- Text: warm white
    ["Color.Text.Primary"]   = { 0.95, 0.90, 0.85, 1 },
    ["Color.Text.Secondary"] = { 0.70, 0.60, 0.55, 1 },

    -- Feedback colours stay the same (fall through to Default)
}

FluentWoW.Tokens:RegisterTheme("Horde", hordeTheme)
FluentWoW.Tokens:SetTheme("Horde")
```

---

## Runtime Overrides

Overrides sit above all themes in the resolution chain. They're useful for per-addon accent colours without creating a full theme:

```lua
-- Change just the accent colour
FluentWoW.Tokens:Override({
    ["Color.Accent.Primary"] = { 0.60, 0.20, 0.80, 1 },  -- purple
    ["Color.Accent.Hover"]   = { 0.70, 0.30, 0.90, 1 },
})
```

Overrides persist until the addon is reloaded. There is no `ClearOverride` API — to revert, set the override value back to the theme value or switch themes.

---

## Responding to Theme Changes

### In Custom Frames

If you build custom UI outside of FluentWoW controls, listen for theme changes:

```lua
local function refreshMyUI()
    myFrame.bg:SetColorTexture(FluentWoW.Tokens:GetColor("Color.Surface.Raised"))
    myFrame.title:SetTextColor(FluentWoW.Tokens:GetColor("Color.Text.Primary"))
    myFrame.title:SetFont(FluentWoW.Tokens:GetFont("Title"))
end

-- Listen for changes
FluentWoW.EventBus:On("ThemeChanged", refreshMyUI)
FluentWoW.EventBus:On("TokensOverridden", refreshMyUI)

-- Apply initial styling
refreshMyUI()
```

### Event Reference

| Event | Payload | When |
|---|---|---|
| `"ThemeChanged"` | `themeName: string` | `SetTheme()` called |
| `"ThemeRegistered"` | `themeName: string` | `RegisterTheme()` called |
| `"TokensOverridden"` | `overrides: table` | `Override()` called |

---

## Theme Persistence

FluentWoW does not persist theme selection itself. To remember the user's theme choice across sessions, save it in your addon's saved variables:

```lua
-- On load
if MyAddonDB.theme then
    FluentWoW.Tokens:SetTheme(MyAddonDB.theme)
end

-- When user changes theme
FluentWoW.EventBus:On("ThemeChanged", function(name)
    MyAddonDB.theme = name
end)
```

---

## Resolution Order Summary

```
Token("Color.Accent.Primary")
  ↓
1. Check overrides table            → found? return
  ↓
2. Check active theme ("Light")     → found? return
  ↓
3. Check default theme ("Default")  → found? return
  ↓
4. Return nil (+ debug warning)
```

This three-tier system means:
- Consumer addons can tweak specific tokens via `Override()` without building a theme
- Custom themes only need to specify changed tokens — everything else inherits from Default
- The Default theme always provides a complete fallback
