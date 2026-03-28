# Changelog

All notable changes to FluentWoW will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Removed the discarded review-only texture packs, audit outputs, and alternative comparison generators after retaining `FluentWoW/Assets/Textures` as the canonical runtime pack
- Narrowed the tracked repository set to addon payloads, wiki sources, release metadata, packaging config, and the release-support workflows while keeping the wiki excluded from packaged releases

### Fixed

- Cleaned up the active texture-pack notes to match the post-review asset layout

## [1.4.0] - 2026-03-27

### Added

- **Texture Assets**: Generated all 25 TGA texture files in `FluentWoW/Assets/Textures/` per the `.docs/TextureAssets.md` spec — rounded rectangle fills/borders/shadows (4px & 8px radius), pill shapes (toggle track, slider/progress), circle shapes (slider/toggle thumbs, radio button ring/dot), checkbox rounded squares, focus rings, badge pill, nav/tab indicators, progress ring spinner, callout arrow, and scrollbar thumb
- **Texture Generator**: `tools/generate_textures.py` — Python/Pillow script that procedurally generates all 25 assets with 4× supersampled anti-aliasing, correct dimensions, pure white on transparent background (32-bit RGBA TGA)

## [1.3.0] - 2026-03-27

### Changed

- **CheckBox**: Box size 18×18 → 20×20 to match WinUI spec
- **ToggleSwitch**: Track width 40 → 44px to match WinUI Fluent Design (44×20 pill)
- **TextBox**: Horizontal padding 12 → 16px (`Spacing.XL`); SearchBox left inset 30 → 34px
- **Slider**: Tick container height/width 12px → 6px (SM+XS) to match WinUI tick mark size
- **ComboBox**: Dropdown item height 28 → 32px (`Spacing.XXXL`) to match WinUI standard item height
- **InfoBar**: Left accent edge width 3 → 4px to match WinUI severity stripe
- **NavigationView**: Item height 36 → 40px (XXXL+MD); hamburger button 36 → 40px
- **Expander**: Header height 40 → 48px (XXXL+XL) to match WinUI ExpanderHeaderMinHeight

### Added

- **Texture Asset Specifications** (`.docs/TextureAssets.md`): 25 TGA texture descriptions with AI-generation prompts for rounded corners, pill shapes, circles, shadows, focus rings, and indicators — enabling full Fluent Design visual fidelity
- **Copilot review texture pack**: Added `tools/generate_texture_pack.py` plus an isolated 25-file TGA output set under `FluentWoW/Assets/Textures_Copilot/` for side-by-side comparison with other generated variants

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
