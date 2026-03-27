# Token System

FluentWoW uses a **design-token system** to centralise all visual constants — colours, spacing, typography, radii, motion timing, opacity, and more. This ensures consistent styling across every control and makes theming trivial.

---

## Architecture

```
Resolution order:   Runtime Override  →  Active Theme  →  Dark Theme (fallback)
```

1. **Runtime overrides** (`Tokens:Override({...})`) — highest priority, applied by the consumer addon (Color tokens only)
2. **Active theme** — the currently selected theme (e.g. `"Light"`)
3. **Dark theme** — the built-in dark theme, always present as color fallback

Note: Spacing, typography, radii, motion, opacity, and icon sizes are hardcoded design constants in `Registry.lua` and are not part of the theme chain.

The token registry is accessible as `FluentWoW.Tokens` (an instance of `Tokens/Registry.lua`).

---

## API

### Retrieval

| Method | Signature | Returns | Description |
|---|---|---|---|
| `Get(key)` | `(key: string)` | `any` | Raw token lookup with full resolution chain |
| `GetColor(key)` | `(key: string)` | `r, g, b, a` | Colour as four numbers (0–1) |
| `GetSpacing(key)` | `(key: string)` | `number` | Spacing value (auto-prefixes `"Spacing."`) |
| `GetFont(key)` | `(key: string)` | `font, size, flags` | Font path, size, outline flags |
| `GetNumber(key)` | `(key: string)` | `number` | Any numeric token |

### Theme Management

| Method | Signature | Description |
|---|---|---|
| `RegisterTheme(name, tokens)` | `(string, table)` | Register a new theme |
| `SetTheme(name)` | `(string)` | Switch to a registered theme |
| `GetThemeName()` | — | Returns the active theme name |
| `GetAvailableThemes()` | — | Returns `{name = true, ...}` set |
| `Override(overrides)` | `(table)` | Apply highest-priority overrides |

### Events

Theme operations emit events via the [EventBus](Core-Modules#eventbus):

| Event | Payload | Trigger |
|---|---|---|
| `"ThemeRegistered"` | `themeName` | `RegisterTheme()` |
| `"ThemeChanged"` | `themeName` | `SetTheme()` |
| `"TokensOverridden"` | `overridesTable` | `Override()` |

---

## Token Key Resolution

Keys use dot-notation paths. The registry resolves keys in two ways:

1. **Flat lookup** — `tokens["Color.Accent.Primary"]`
2. **Nested lookup** — `tokens.Color.Accent.Primary`

Both are tried in order. Flat keys take priority when both exist.

```lua
-- These are equivalent:
FluentWoW.Tokens:Get("Color.Accent.Primary")
FluentWoW.Tokens:GetColor("Color.Accent.Primary")  -- returns r, g, b, a
```

---

## Complete Token Reference

### Colours

#### Color.Base

| Token | Default (Dark) | Description |
|---|---|---|
| `Color.Base.White` | `1.00, 1.00, 1.00, 1` | Pure white |

#### Color.Surface

| Token | Default (Dark) | Description |
|---|---|---|
| `Color.Surface.Base` | `0.12, 0.12, 0.12, 1` | App background |
| `Color.Surface.Raised` | `0.16, 0.16, 0.16, 1` | Card / panel background |
| `Color.Surface.Overlay` | `0.20, 0.20, 0.20, 1` | Flyout / dropdown bg |
| `Color.Surface.Elevated` | `0.24, 0.24, 0.24, 1` | Button rest bg |
| `Color.Surface.Stroke` | `0.28, 0.28, 0.28, 1` | Subtle stroke / divider |

#### Color.Border

| Token | Default (Dark) | Description |
|---|---|---|
| `Color.Border.Default` | `0.33, 0.33, 0.33, 1` | Control border |
| `Color.Border.Subtle` | `0.25, 0.25, 0.25, 1` | Low-contrast border |
| `Color.Border.Focus` | `0.60, 0.60, 0.60, 1` | Focus ring / hover border |
| `Color.Border.Error` | `0.90, 0.25, 0.25, 1` | Error-state border |

#### Color.Text

| Token | Default (Dark) | Description |
|---|---|---|
| `Color.Text.Primary` | `1.00, 1.00, 1.00, 1` | Primary text |
| `Color.Text.Secondary` | `0.70, 0.70, 0.70, 1` | Subtitle / hint |
| `Color.Text.Disabled` | `0.40, 0.40, 0.40, 1` | Disabled text |
| `Color.Text.OnAccent` | `1.00, 1.00, 1.00, 1` | Text on accent bg |
| `Color.Text.Error` | `0.90, 0.25, 0.25, 1` | Error text |
| `Color.Text.Warning` | `0.95, 0.75, 0.20, 1` | Warning text |
| `Color.Text.Success` | `0.30, 0.80, 0.40, 1` | Success text |

#### Color.Icon

| Token | Default (Dark) | Description |
|---|---|---|
| `Color.Icon.Default` | `1.00, 1.00, 1.00, 1` | Default icon |
| `Color.Icon.Subtle` | `0.70, 0.70, 0.70, 1` | Muted icon |
| `Color.Icon.Disabled` | `0.40, 0.40, 0.40, 1` | Disabled icon |
| `Color.Icon.OnAccent` | `1.00, 1.00, 1.00, 1` | Icon on accent bg |

#### Color.Accent

| Token | Default (Dark) | Description |
|---|---|---|
| `Color.Accent.Primary` | `0.38, 0.57, 0.93, 1` | Primary accent (blue) |
| `Color.Accent.Hover` | `0.48, 0.65, 0.96, 1` | Accent hover |
| `Color.Accent.Pressed` | `0.28, 0.47, 0.83, 1` | Accent pressed |
| `Color.Accent.Light` | `0.55, 0.72, 1.00, 1` | Accent highlight edge |

#### Color.Feedback

| Token | Default (Dark) | Description |
|---|---|---|
| `Color.Feedback.Success` | `0.30, 0.80, 0.40, 1` | Success green |
| `Color.Feedback.Warning` | `0.95, 0.75, 0.20, 1` | Warning amber |
| `Color.Feedback.Error` | `0.90, 0.25, 0.25, 1` | Error red |
| `Color.Feedback.ErrorHover` | `0.95, 0.35, 0.35, 1` | Error hover |
| `Color.Feedback.Info` | `0.38, 0.57, 0.93, 1` | Info blue |

#### Color.Overlay

| Token | Default (Dark) | Description |
|---|---|---|
| `Color.Overlay.Dialog` | `0.00, 0.00, 0.00, 0.72` | Modal backdrop scrim |
| `Color.Overlay.Hover` | `1.00, 1.00, 1.00, 0.08` | Hover state overlay |
| `Color.Overlay.Press` | `1.00, 1.00, 1.00, 0.16` | Press state overlay |

---

### Spacing

| Token | Value | Use |
|---|---|---|
| `Spacing.XS` | 2 | Tight insets |
| `Spacing.SM` | 4 | Small gaps |
| `Spacing.MD` | 8 | Standard gap |
| `Spacing.LG` | 12 | Section gap |
| `Spacing.XL` | 16 | Card padding |
| `Spacing.XXL` | 24 | Large sections |
| `Spacing.XXXL` | 32 | Page-level margins |

```lua
local gap = FluentWoW.Tokens:GetSpacing("MD")  -- 8
```

---

### Typography

| Token | Font | Size | Flags | Use |
|---|---|---|---|---|
| `Typography.Display` | MORPHEUS.ttf | 28 | — | Hero headings |
| `Typography.Header` | FRIZQT__.TTF | 20 | — | Section headers |
| `Typography.Title` | FRIZQT__.TTF | 16 | — | Card titles |
| `Typography.Body` | ARIALN.TTF | 13 | — | Body text |
| `Typography.BodyBold` | ARIALN.TTF | 13 | OUTLINE | Emphasis / buttons |
| `Typography.Caption` | ARIALN.TTF | 11 | — | Small labels |
| `Typography.Mono` | ARIALN.TTF | 11 | — | Code / data |

```lua
local font, size, flags = FluentWoW.Tokens:GetFont("Body")
myFontString:SetFont(font, size, flags)
```

---

### Corner Radii

| Token | Value | Use |
|---|---|---|
| `Radii.None` | 0 | No rounding |
| `Radii.SM` | 2 | Subtle rounding |
| `Radii.MD` | 4 | Default rounding |
| `Radii.LG` | 8 | Cards / panels |
| `Radii.Full` | 999 | Pill / capsule |

> **Note:** WoW has no native rounded-rect primitives. Radii tokens are used for backdrop insets and 9-slice texture calculations.

---

### Motion Duration

| Token | Value (s) | Use |
|---|---|---|
| `Motion.Duration.Instant` | 0 | No animation |
| `Motion.Duration.Fast` | 0.10 | Micro-interactions (press, toggle) |
| `Motion.Duration.Normal` | 0.20 | Standard transitions |
| `Motion.Duration.Slow` | 0.35 | Complex / large animations |
| `Motion.Duration.Entrance` | 0.25 | Element appearing |
| `Motion.Duration.Exit` | 0.15 | Element disappearing |

### Motion Easing

| Token | Value | Description |
|---|---|---|
| `Motion.Easing.Standard` | `"Smooth"` | Default for most transitions |
| `Motion.Easing.Decelerate` | `"Smooth"` | Entrance animations |
| `Motion.Easing.Accelerate` | `"Linear"` | Exit animations |
| `Motion.Easing.Linear` | `"Linear"` | Constant speed |

---

### Opacity

| Token | Value | Use |
|---|---|---|
| `Opacity.Disabled` | 0.40 | Disabled controls |
| `Opacity.Overlay` | 0.60 | Semi-transparent overlays |
| `Opacity.Ghost` | 0.70 | De-emphasized elements |

---

### Layer

| Token | Value | Use |
|---|---|---|
| `Layer.Base` | 1 | Background frames |
| `Layer.Raised` | 2 | Cards / panels |
| `Layer.Overlay` | 3 | Flyouts / dropdowns |
| `Layer.Dialog` | 4 | Modal dialogs |
| `Layer.Toast` | 5 | Notifications |

---

### Density

| Token | Value | Use |
|---|---|---|
| `Density.Compact` | 0.75 | Dense / condensed layouts |
| `Density.Normal` | 1.00 | Standard spacing |
| `Density.Comfortable` | 1.30 | Roomy / touch-friendly |

---

### Icon Sizes

| Token | Value | Use |
|---|---|---|
| `Icon.SM` | 12 | Small inline icons |
| `Icon.MD` | 16 | Standard icons |
| `Icon.LG` | 20 | Large / header icons |
