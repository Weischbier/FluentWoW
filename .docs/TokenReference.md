# WinUILib — Token Reference

> Complete catalog of all design tokens in the WinUILib token system.
> Source of truth: `Tokens/DefaultTheme.lua` + `Tokens/Registry.lua`

---

## Token Resolution Order

1. **Addon override** — registered via `WinUILib.Tokens:Override({ [key] = value })`
2. **Active theme** — registered via `WinUILib.Tokens:RegisterTheme(name, table)`
3. **Default theme** — loaded by `Tokens/DefaultTheme.lua`

The first non-nil value in this chain is returned.

## API

```lua
-- Color (returns r, g, b, a)
local r, g, b, a = WinUILib.Tokens:GetColor("Color.Accent.Primary")

-- Spacing (returns number)
local px = WinUILib.Tokens:GetSpacing("MD")

-- Font (returns font, size, flags)
local font, size, flags = WinUILib.Tokens:GetFont("Body")

-- Generic (returns raw value)
local val = WinUILib.Tokens:Get("Motion.Duration.Fast")

-- Override at runtime
WinUILib.Tokens:Override({ ["Color.Accent.Primary"] = { 0.9, 0.6, 0.1, 1 } })

-- Register and switch theme
WinUILib.Tokens:RegisterTheme("MyTheme", { ... })
WinUILib.Tokens:SetTheme("MyTheme")
```

## Token Categories

### Color.Surface — Background layers
| Token | Purpose | Default (dark theme) |
|---|---|---|
| `Color.Surface.Base` | Window/panel background | Near-black |
| `Color.Surface.Raised` | Card/raised surface | Slightly lighter |
| `Color.Surface.Overlay` | Modal backdrop scrim | Semi-transparent black |

### Color.Border — Control borders and focus rings
| Token | Purpose |
|---|---|
| `Color.Border.Default` | Normal control border |
| `Color.Border.Hover` | Hovered control border |
| `Color.Border.Focus` | Keyboard focus ring |
| `Color.Border.Disabled` | Disabled control border |

### Color.Text — Text roles
| Token | Purpose |
|---|---|
| `Color.Text.Primary` | Primary body text |
| `Color.Text.Secondary` | Subtitle / description |
| `Color.Text.Disabled` | Disabled text |
| `Color.Text.OnAccent` | Text on accent-colored background |

### Color.Accent — Interactive accent
| Token | Purpose |
|---|---|
| `Color.Accent.Primary` | Default accent (buttons, links) |
| `Color.Accent.Hover` | Accent on hover |
| `Color.Accent.Pressed` | Accent on press |
| `Color.Accent.Disabled` | Accent when disabled |

### Color.Feedback — Status colors
| Token | Purpose |
|---|---|
| `Color.Feedback.Success` | Success / info-bar green |
| `Color.Feedback.Warning` | Warning / info-bar yellow |
| `Color.Feedback.Error` | Error / destructive red |
| `Color.Feedback.Info` | Informational blue |

### Color.Overlay — Scrim and hover tints
| Token | Purpose |
|---|---|
| `Color.Overlay.Hover` | Hover state overlay |
| `Color.Overlay.Pressed` | Press state overlay |
| `Color.Overlay.Scrim` | Modal backdrop overlay |

### Color.Icon — Icon tints
| Token | Purpose |
|---|---|
| `Color.Icon.Default` | Default icon color |
| `Color.Icon.Disabled` | Disabled icon color |

### Spacing — Scale
| Token | Value (px) |
|---|---|
| `Spacing.XS` | 2 |
| `Spacing.SM` | 4 |
| `Spacing.MD` | 8 |
| `Spacing.LG` | 12 |
| `Spacing.XL` | 16 |
| `Spacing.XXL` | 24 |
| `Spacing.XXXL` | 32 |

### Typography — Type ramp
| Token | Usage |
|---|---|
| `Typography.Display` | Hero text, large headers |
| `Typography.Header` | Section headers |
| `Typography.Title` | Card titles |
| `Typography.Body` | Body text (default) |
| `Typography.BodyBold` | Emphasized body |
| `Typography.Caption` | Descriptions, secondary |
| `Typography.Mono` | Code, numeric values |

### Radii — Corner radii
| Token | Usage |
|---|---|
| `Radii.None` | No rounding (0) |
| `Radii.SM` | Subtle rounding |
| `Radii.MD` | Standard control rounding |
| `Radii.LG` | Card / dialog rounding |
| `Radii.Full` | Pill shape |

### Motion — Animation timing
| Token | Value | Usage |
|---|---|---|
| `Motion.Duration.Fast` | 0.10s | Click feedback (ScalePress) |
| `Motion.Duration.Normal` | 0.20s | Standard transitions |
| `Motion.Duration.Slow` | 0.35s | Complex animations |
| `Motion.Duration.Entrance` | 0.25s | FadeIn, SlideIn |
| `Motion.Duration.Exit` | 0.15s | FadeOut, dismiss |
| `Motion.Easing.Standard` | ease-in-out | Default easing |
| `Motion.Easing.Decelerate` | ease-out | Entrance animations |
| `Motion.Easing.Accelerate` | ease-in | Exit animations |

### Opacity
| Token | Usage |
|---|---|
| `Opacity.Disabled` | Disabled control opacity multiplier |
| `Opacity.Overlay` | Overlay/scrim alpha |
| `Opacity.Ghost` | Ghost/placeholder alpha |

### Layer — Frame strata mapping
| Token | Usage |
|---|---|
| `Layer.Base` | Normal controls |
| `Layer.Raised` | Cards, raised surfaces |
| `Layer.Overlay` | Dropdowns, flyouts |
| `Layer.Dialog` | Modal dialogs |
| `Layer.Toast` | Notifications, info bars |

### Density — Sizing modes
| Token | Usage |
|---|---|
| `Density.Compact` | Compact control height |
| `Density.Normal` | Standard control height |
| `Density.Comfortable` | Large / touch-friendly height |

### Icon — Icon sizes
| Token | Value |
|---|---|
| `Icon.SM` | 12px |
| `Icon.MD` | 16px |
| `Icon.LG` | 24px |

## Creating a Custom Theme

```lua
WinUILib.Tokens:RegisterTheme("Light", {
    Color = {
        Surface = {
            Base    = { 0.95, 0.95, 0.95, 1 },
            Raised  = { 1.00, 1.00, 1.00, 1 },
        },
        Text = {
            Primary   = { 0.10, 0.10, 0.10, 1 },
            Secondary = { 0.40, 0.40, 0.40, 1 },
        },
        Accent = {
            Primary = { 0.00, 0.47, 0.84, 1 },
        },
    },
})
WinUILib.Tokens:SetTheme("Light")
```

All controls automatically pick up the new values on their next state update.
