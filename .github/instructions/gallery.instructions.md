---
applyTo: "FluentWoW-Gallery/**"
---

# Gallery Addon Rules

## Purpose

FluentWoW-Gallery is an interactive showcase addon for developers. It is NOT production-critical and is never distributed to end-users.

## Page Structure

Each Gallery page corresponds to one control family and demonstrates:
- All control variants (e.g., Accent/Subtle/Destructive buttons)
- All visual states (Normal, Hover, Pressed, Disabled)
- Interactive examples with live callbacks
- Token-driven styling in action

## Naming

- Page files: `Pages/<ControlName>Page.lua`
- One page per control family (buttons share ButtonPage, all input controls share InputPage, etc.)
- Grouped pages are acceptable: `InputPage.lua` covers CheckBox, RadioButton, ToggleSwitch, TextBox, Slider, ComboBox

## Adding a New Page

1. Create `FluentWoW-Gallery/Pages/<Name>Page.lua`
2. Follow the existing page pattern (see `ButtonPage.lua`)
3. Register the page in `Gallery.lua` sidebar navigation
4. Add the page to `FluentWoW-Gallery/FluentWoW-Gallery.toc`

## Reference Sources

- WinUI Gallery XAML source: `.help/.sources/WinUI-Gallery-main/fwow/Samples/ControlPages/`
- WinUI design images: `.help/.sources/WinUI-Gallery-main/fwow/Assets/Design/`
- Match the WinUI Gallery page structure and demo patterns as closely as possible

## Style Guidelines

- Use `FluentWoW:Create*()` factory methods — never raw `CreateFrame()`
- Use StackLayout for page content arrangement
- Include section headers and descriptions using TextBlock
- Show both enabled and disabled states for each control
