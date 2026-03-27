---
applyTo: "FluentWoW/Settings/**"
---

# Settings Controls Rules

## Controls

- `SettingsCard` — mirrors Windows Community Toolkit SettingsCard
- `SettingsExpander` — mirrors Windows Community Toolkit SettingsExpander

## Design Reference

- Windows Community Toolkit: `.help/.sources/microsoft-ui-xaml-main/specs/WCT/`

## Pattern

Settings controls follow the same pattern as regular controls:
- XML template + Lua behavior
- ControlBase mixin + StateMachine
- Token-driven styling
- OnStateChanged for theming

## API Stability

SettingsCard and SettingsExpander are high-usage controls (most addons will use these for settings panels). Their public API is stability-critical:
- `SettingsCard:SetTitle(text)`
- `SettingsCard:SetDescription(text)`
- `SettingsCard:SetActionControl(control)`
- `SettingsExpander:AddCard(card)`
- `SettingsExpander:SetExpanded(expanded)`

These methods MUST NOT be renamed or removed without the 2-minor-version deprecation cycle.

## Pixel-Fidelity (Card Layout Measurements)

From `.docs/DesignSpecs.md` §2.1 Cards:
- Card internal top padding: 12px (`Spacing.LG`)
- Card internal left/right/bottom padding: 16px (`Spacing.XL`)
- Icon-to-subtitle gap: 12px (`Spacing.LG`)
- Subtitle to body text gap: 16px (`Spacing.XL`)
- Card-to-card vertical gap: 36px
- Section title to first card gap: 40px
- Action icon-to-text gap: 8px (`Spacing.MD`)

Always cross-reference `.help/.sources/microsoft-ui-xaml-main/specs/WCT/` for WCT spec details.
