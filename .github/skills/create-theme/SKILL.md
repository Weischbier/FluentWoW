---
name: create-theme
description: >
  Create a new WinUILib color theme by defining a token override table and registering it.
---

# create-theme

## When to Use

- When adding a new theme (e.g., Light, High Contrast)
- When a user wants to create a custom theme for their addon

## Prerequisites

1. Read `.docs/TokenReference.md` for the complete token catalog
2. Read `WinUILib/Tokens/DefaultTheme.lua` for the canonical structure
3. Read `WinUILib/Tokens/Registry.lua` for the registration API

## Inputs

| Input | Required | Description |
|---|---|---|
| `themeName` | Yes | e.g., `"Light"`, `"HighContrast"`, `"MyAddonTheme"` |
| `colorPalette` | Yes | Key color values (accent, surface, text, border) |

## Steps

### 1. Create Theme File

Create `WinUILib/Tokens/{ThemeName}Theme.lua`:

```lua
--- WinUILib – Tokens/{ThemeName}Theme.lua
-- {Description}
local lib = WinUILib
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

Add to `WinUILib/WinUILib.toc` after `DefaultTheme.lua`:
```
Tokens/{ThemeName}Theme.lua
```

### 3. Document

Add the theme to `.docs/TokenReference.md` §Theme Notes.

## Outputs

| Output | Path |
|---|---|
| Theme file | `WinUILib/Tokens/{ThemeName}Theme.lua` |
| TOC | Modified (if shipped theme) |
| Docs | `.docs/TokenReference.md` updated |

## Notes

- Addon authors create themes by calling `T:RegisterTheme()` in their own addon — they don't modify WinUILib files
- Only Default (dark) theme ships with WinUILib v1.x
- The theme system supports partial overrides — you only need to specify tokens that differ
