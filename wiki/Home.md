# FluentWoW Wiki

> **WinUI-inspired UI framework for World of Warcraft addon developers.**

FluentWoW ports the spirit, quality bar, and design language of [WinUI 3](https://github.com/microsoft/microsoft-ui-xaml), [WinUI Gallery](https://github.com/microsoft/WinUI-Gallery), and the [Windows Community Toolkit](https://github.com/CommunityToolkit/Windows) into the World of Warcraft addon ecosystem. It provides reusable controls, a design-token system, layout primitives, motion helpers, and a live gallery addon — everything an addon developer needs to build modern, consistent, high-fidelity interfaces.

---

## Quick Navigation

| Section | Description |
| --- | --- |
| **[Getting Started](Getting-Started)** | Installation, dependencies, your first control |
| **[Controls Overview](Controls-Overview)** | Summary of all 30+ controls with status |
| **[API Reference](API-Reference)** | Quick-reference table of every factory method |

### Control Documentation

| Page | Controls |
| --- | --- |
| **[Button](Button)** | Button (Accent / Subtle / Destructive), IconButton, ToggleButton |
| **[Input Controls](Input-Controls)** | CheckBox, RadioButton, ToggleSwitch, TextBox, SearchBox, Slider, ComboBox |
| **[Feedback Controls](Feedback-Controls)** | ProgressBar, ProgressRing, InfoBar, ContentDialog |
| **[Navigation Controls](Navigation-Controls)** | TabView, Expander, ScrollFrame, MainFrame |
| **[Layout](Layout)** | StackLayout (VStack / HStack) |
| **[Settings Controls](Settings-Controls)** | SettingsCard, SettingsExpander |
| **[Advanced Controls](Advanced-Controls)** | NavigationView, BreadcrumbBar, NumberBox, TeachingTip, CommandBar, SegmentedControl, Badge, EmptyState, Skeleton |

### Framework Internals

| Page | Description |
| --- | --- |
| **[Token System](Token-System)** | Design tokens, resolution order, complete token reference |
| **[Theming](Theming)** | Creating custom themes, light/dark mode, runtime overrides |
| **[Motion & Animation](Motion-and-Animation)** | Tweening engine, presets, easing functions |
| **[Core Modules](Core-Modules)** | EventBus, StateMachine, FramePool, Utils |
| **[Icons](Icons)** | Segoe Fluent Icons glyph map |
| **[Architecture](Architecture)** | Library bootstrap, embed protocol, file layout |

### Extras

| Page | Description |
| --- | --- |
| **[Gallery](Gallery)** | Interactive showcase addon (`/fwow`) |
| **[FAQ & Troubleshooting](FAQ)** | Common issues, combat lockdown, debugging |
| **[Design Principles](Design-Principles)** | WinUI → WoW translation matrix |

---

## At a Glance

- **30+ controls** across 7 categories — buttons, inputs, feedback, navigation, layout, settings, advanced
- **Token-driven theming** — dark theme (default), light theme, and runtime overrides
- **Motion engine** — flux-based tweening with 27 easing functions and preset animations
- **Combat-safe** — all controls respect `InCombatLockdown()` constraints
- **Library-first** — obtain via `LibStub("FluentWoW-1.0")`, embed into AceAddon, or TOC dependency
- **Gallery addon** — live interactive showcase for every control

---

## Version

**FluentWoW 1.4.0** · Interface 120005 / 120001 · MIT License

---

## Design References

- [microsoft/WinUI-Gallery](https://github.com/microsoft/WinUI-Gallery) — design source
- [microsoft/microsoft-ui-xaml](https://github.com/microsoft/microsoft-ui-xaml) — XAML specs
- [CommunityToolkit/Windows](https://github.com/CommunityToolkit/Windows) — SettingsCard / SettingsExpander
- [Microsoft Learn — Windows app design](https://learn.microsoft.com/windows/apps/design/basics/) — Fluent Design System
