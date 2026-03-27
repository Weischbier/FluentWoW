---
name: create-theme
description: >
  Create a new FluentWoW color theme by defining a token override table and registering it.
---

# create-theme

## When to Use

- When adding a new theme (e.g., Light, High Contrast)
- When a user wants to create a custom theme for their addon

## Prerequisites

1. Read `.docs/TokenReference.md` for the complete token catalog
2. Read `FluentWoW/Tokens/DefaultTheme.lua` for the canonical structure
3. Read `FluentWoW/Tokens/Registry.lua` for the registration API
4. View design images in `.help/.sources/WinUI-Gallery-main/fwow/Assets/Design/` for dark/light theme color references
5. Read `.docs/DesignSpecs.md` for extracted design measurements and color notes

## Inputs

| Input | Required | Description |
|---|---|---|
| `themeName` | Yes | e.g., `"Light"`, `"HighContrast"`, `"MyAddonTheme"` |
| `colorPalette` | Yes | Key color values (accent, surface, text, border) |

## Steps

### 1. Create Theme File

Create `FluentWoW/Tokens/{ThemeName}Theme.lua`:

```lua
--- FluentWoW – Tokens/{ThemeName}Theme.lua
-- {Description}
local lib = FluentWoW
local T = lib.Tokens

T:RegisterTheme("{themeName}", {
    Color = {
        Surface = {
            Base    = { r, g, b, a },
            Layer1  = { r, g, b, a },
            Layer2  = { r, g, b, a },
        },
        Text = {
            Primary   = { r, g, b, a },
            Secondary = { r, g, b, a },
            Disabled  = { r, g, b, a },
        },
        Accent = {
            Primary = { r, g, b, a },
            Hover   = { r, g, b, a },
            Pressed = { r, g, b, a },
        },
        Border = {
            Default  = { r, g, b, a },
            Focused  = { r, g, b, a },
        },
        -- ... other Color tokens
    },
    -- Only override categories that differ from DefaultTheme
    -- Missing tokens fall through to default
})
```

### 2. Register in TOC (if shipped)

Add to `FluentWoW/FluentWoW.toc` after `DefaultTheme.lua`:
```
Tokens/{ThemeName}Theme.lua
```

### 3. Document

Add the theme to `.docs/TokenReference.md` §Theme Notes.

## Outputs

| Output | Path |
|---|---|
| Theme file | `FluentWoW/Tokens/{ThemeName}Theme.lua` |
| TOC | Modified (if shipped theme) |
| Docs | `.docs/TokenReference.md` updated |

## Notes

- Addon authors create themes by calling `T:RegisterTheme()` in their own addon — they don't modify FluentWoW files
- Only Default (dark) theme ships with FluentWoW v1.x
- The theme system supports partial overrides — you only need to specify tokens that differ
