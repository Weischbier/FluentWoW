---
applyTo: "FluentWoW/Tokens/**"
---

# Token System Rules

## Architecture

- `Registry.lua` implements the token resolution engine
- `DefaultTheme.lua` provides the default dark theme token values
- Resolution order: addon override → active theme → default theme

## Invariants

- The resolution order (override → theme → default) is non-negotiable
- `Registry:Override()` always has highest priority
- `Registry:RegisterTheme()` fires `ThemeRegistered` event
- `Registry:SetTheme()` fires `ThemeChanged` event
- `Registry:Override()` fires `TokensOverridden` event
- The flat-key fast path (`tbl[path]`) MUST remain as the first lookup attempt

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
- WinUI design images: `.help/.sources/WinUI-Gallery-main/WinUIGallery/Assets/Design/`
- When adding spacing tokens, verify the pixel value against the design spec
- When adding color tokens, cross-reference the WinUI dark/light theme images

## Adding New Tokens

1. Add the default value to `DefaultTheme.lua` in the correct category
2. Document the token in `.docs/TokenReference.md`
3. Use the token in the control via `T:GetColor()`, `T:GetSpacing()`, `T:GetFont()`, or `T:Get()`

## Prohibited

- Never hardcode a value that should be a token — even "just for testing"
- Never bypass the resolution order
- Never store resolved values — always call `T:Get*()` at usage time so theme changes apply
- Never add tokens that duplicate existing ones — check the catalog first
