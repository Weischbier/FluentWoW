# Changelog

All notable changes to FluentWoW will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2026-03-27

### Added

- **MainFrame enforcement**: All FluentWoW controls must now be descendants of a `CreateMainFrame()` window. Controls created outside a MainFrame hierarchy emit a debug warning. ContentDialog and TeachingTip are exempt (fullscreen overlays)
- **ControlBase**: `hasMainFrameAncestor()` parent-chain walk validates frame ancestry at init time
- **ControlBase**: `ANCESTOR_EXEMPT` table for MainFrame, ContentDialog, TeachingTip
- **MainFrame**: `_FWoWMainFrame` and `_FWoWControlType` tags set in OnLoad
- **ContentDialog/TeachingTip**: `_FWoWControlType` tags set in OnLoad for exemption lookup
- **Workflow instructions**: `.github/instructions/workflow.instructions.md` codifies the 6-step task workflow (implement → audit → changelog → wiki → commit message → push)

### Changed

- **Design rules**: Expanded from 10 to 11 rules — new Rule #1 "MainFrame is the root" (all other rules shifted +1)
- **ARCHITECTURE.md**: Executive summary, adoption strategy, ControlBase description, and design rules updated for MainFrame requirement
- **Wiki**: Getting-Started, Design-Principles, FAQ, Navigation-Controls, API-Reference updated with MainFrame requirement documentation

## [1.1.1] - 2026-03-27

### Fixed

- **ContentDialog**: `Open()` now calls `self:Show()` before animating children — dialog was invisible after first close/reopen cycle (P0)
- **FramePool**: `ReleaseAll()` no longer mutates `_active` table during `pairs()` iteration — undefined behavior in Lua 5.1 (P0)
- **FramePool**: `ActiveCount()` now uses O(1) counter instead of O(n) `pairs()` loop
- **ToggleSwitch**: Fixed `SetColorTexture` multi-return truncation — `T:GetColor()` returns `r,g,b` which was silently truncated when not the last argument (P0)
- **StateMachine**: `SetState()` now validates against known states and rejects invalid strings with a debug message
- **ControlBase**: All controls now automatically re-apply `OnStateChanged` on `ThemeChanged` events — previously only 3 of 20+ controls listened
- **ScrollFrame**: Added `OnHide` cleanup to stop thumb-drag `OnUpdate` if parent hides mid-drag (Rule #6)
- **ProgressBar**: `OnStateChanged("Disabled")` now stops indeterminate animation; re-enables on un-disable (Rule #6)
- **ProgressRing**: `OnStateChanged("Disabled")` now removes `OnUpdate` script; restores on re-enable (Rule #6)
- **InfoBar**: `Open()` now guards with `InCombatLockdown()` check (Rule #4)
- **Skeleton**: `_StartShimmer()` now respects `Motion.reducedMotion` flag
- **Expander**: Removed competing `oncomplete` height sets from parallel `HeightTo` animations — prevents flicker
- **SettingsExpander**: Same competing-animation fix as Expander
- **NavigationView**: Removed dead ternary (`expanded and X or X` where both branches were identical)

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

### Added (v1.0.0)

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
