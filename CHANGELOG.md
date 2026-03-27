# Changelog

All notable changes to FluentWoW will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-03-27

### Added
- Controls: NavigationView — sidebar navigation with collapsible pane and selection indicator
- Controls: BreadcrumbBar — horizontal path breadcrumb trail with click navigation
- Controls: NumberBox — validated numeric input with spin buttons, min/max/step
- Controls: TeachingTip — contextual teaching callout / coach mark with placement options
- Controls: CommandBar — toolbar with primary icon commands and overflow menu
- Controls: SegmentedControl — mutually exclusive segmented toggle selector with animated indicator
- Controls: Badge — compact status pill with 5 appearances (Accent/Success/Warning/Error/Subtle)
- Controls: EmptyState — placeholder for empty content areas with icon, title, description, and action
- Controls: Skeleton — animated shimmer loading placeholder with shape variants
- Gallery: Navigation page showcasing NavigationView and BreadcrumbBar
- Gallery: Advanced Controls page showcasing all Phase 2 controls

## [1.0.0] - 2025-01-01

### Added
- Core runtime: Bootstrap, Utils, EventBus, StateMachine, FramePool
- Token registry with override → theme → default resolution
- Dark theme with full color token table
- Light theme with inverted color palette
- Segoe Fluent Icons glyph map (Assets/FluentIcons)
- Vendored libraries: LibStub, flux motion engine
- Controls: MainFrame (application window shell with title bar, resize, drag)
- Controls: Button (Accent/Subtle/Destructive), IconButton, ToggleButton
- Controls: CheckBox, RadioButton, ToggleSwitch
- Controls: TextBlock (Display/Title/Body/Caption), TextBox, SearchBox
- Controls: Slider, ComboBox
- Controls: ProgressBar (determinate + indeterminate), ProgressRing
- Controls: InfoBar (4 severities), ContentDialog
- Controls: Expander, TabView, ScrollFrame
- Layout: StackLayout (VStack / HStack)
- Motion: Tween engine with 28 easing functions + timer API
- Settings: SettingsCard, SettingsExpander
- FluentWoW-Gallery: 5-page interactive showcase addon (`/fwow`)
