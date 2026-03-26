---
applyTo: "WinUILib/Layout/**"
---

# Layout Module Rules

## StackLayout (VStack / HStack)

- Uses `SetPoint()` relative anchoring — never absolute positions (Rule #3)
- Auto-calculates total height/width from children + gaps + padding
- Gap values come from `Tokens:GetSpacing()`
- Padding set via `SetPadding(top, right, bottom, left)`

## Invariants

- `AddChild(child)` appends and re-anchors all children
- `RemoveChild(child)` removes and re-anchors remaining children
- `OnSizeChanged` triggers re-layout
- Width must be set explicitly on vertical stacks; height is computed
- Height must be set explicitly on horizontal stacks; width is computed

## Pixel-Fidelity

- Gap and padding values must match the WinUI design spec exactly
- Cross-reference `.docs/DesignSpecs.md` for authoritative pixel measurements
- Cross-reference `.help/.sources/microsoft-ui-xaml-main/specs/` for layout-specific specs (e.g., WrapPanel)
- Map pixel values to spacing tokens: 8px→`Spacing.MD`, 12px→`Spacing.LG`, 16px→`Spacing.XL`, 24px→`Spacing.XXL`

## Future Layout Containers

When implementing Grid, RelativePanel, or other layout containers:
- Follow the same XML + Lua pattern as StackLayout
- Use `WUIL<Name>Template` naming
- Compute layout in Lua, not XML
- All dimensions from tokens where applicable
