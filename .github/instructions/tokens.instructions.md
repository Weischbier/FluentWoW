---
applyTo: "FluentWoW/Tokens/**"
---

# Token System Rules

## Architecture

- `Registry.lua` implements the token resolution engine
- `DefaultTheme.lua` provides the default dark theme token values
- Resolution order: addon override → active theme → default theme

## Invariants

- **Only Color tokens are themeable** — spacing, typography, radii, motion, opacity, layer, density, and icon sizes are hardcoded design constants in `Registry.lua` (`_DESIGN` table) and cannot be overridden by themes or addon overrides
- For Color tokens: resolution order (override → theme → default) is non-negotiable
- `Registry:Override()` only accepts `Color.*` keys; non-color keys are rejected with a debug message
- `Registry:RegisterTheme()` fires `ThemeRegistered` event
- `Registry:SetTheme()` fires `ThemeChanged` event
- `Registry:Override()` fires `TokensOverridden` event
- The flat-key fast path (`tbl[path]`) MUST remain as the first lookup attempt
- `_DESIGN` is checked first by `Get()` — design constants always win over theme resolution

## Naming Convention

Token names use dot-separated paths:
- `Color.Surface.Base`
- `Color.Accent.Primary`
- `Spacing.MD`
- `Typography.Body`
- `Motion.Duration.Fast`

See `.docs/TokenReference.md` for the complete catalog.

## Design Spec References

- Pixel measurements: `.docs/DesignSpecs.md`
- WinUI specs: `.help/.sources/microsoft-ui-xaml-main/specs/`
- WinUI design images: `.help/.sources/WinUI-Gallery-main/fwow/Assets/Design/`
- When adding spacing tokens, verify the pixel value against the design spec
- When adding color tokens, cross-reference the WinUI dark/light theme images

## Adding New Tokens

### Color tokens (themeable)
1. Add the default value to `DefaultTheme.lua` under the `Color` category
2. Add the light-mode variant to `LightTheme.lua`
3. Document the token in `.docs/TokenReference.md`
4. Use the token in the control via `T:GetColor()` or `T:Get("Color.*")`

### Design constants (hardcoded — spacing, typography, radii, motion, opacity, layer, density, icon)
1. Add the value to the `_DESIGN` table in `Registry.lua`
2. Document the token in `.docs/TokenReference.md`
3. Use the token via `T:GetSpacing()`, `T:GetFont()`, `T:GetNumber()`, or `T:Get()`
4. **Do NOT add these to theme files** — they are fixed by design philosophy

## Prohibited

- Never hardcode a **color** value — always use `Tokens:GetColor()`
- Gaps, font sizes, radii, timing, opacity, icons, and layer order are intentionally hardcoded design constants — never move them into theme tables
- Never bypass the resolution order for color tokens
- Never store resolved color values — always call `T:GetColor()` at usage time so theme changes apply
- Never add tokens that duplicate existing ones — check the catalog first
