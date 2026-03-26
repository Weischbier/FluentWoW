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

## Future Layout Containers

When implementing Grid, RelativePanel, or other layout containers:
- Follow the same XML + Lua pattern as StackLayout
- Use `WUIL<Name>Template` naming
- Compute layout in Lua, not XML
- All dimensions from tokens where applicable
