# Changelog

All notable changes to FluentWoW will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

- **CommandBar gallery**: Replaced broken demo glyphs with known-good Segoe Fluent icons already used elsewhere in the gallery so the command examples no longer show tofu boxes
- **Button gallery**: Fixed the graphical-content button example so it renders with the bundled Segoe Fluent Icons font instead of depending on a gallery texture that could show up empty
- **CheckBox**: Fixed three-state CheckBox visuals so the indeterminate state refreshes immediately when cycling from checked and uses the correct active styling instead of leaving the previous checked mark rendered
- **Gallery panel sizing**: Fixed the shared demo output and options pane relayout so repeated interactions no longer re-measure the pane background and grow panels taller on every refresh, and kept wrapped output text and example headers in sync with width-driven relayouts
- **Gallery tile flow**: Fixed home and section page entries so control tiles wrap onto new rows at narrow widths, shrink within the available content area instead of clipping off-screen, and keep token-driven gaps between tiles
- **Scroll / Slider / Progress**: Fixed ScrollFrame thumb refresh so the scroll indicator tracks content correctly, added a themed Slider value bubble, repaired Slider tick positioning after layout changes, and made the ProgressRing demo more visible in the gallery
- **ComboBox / NavigationView / Gallery assets**: Fixed ComboBox selection callbacks so gallery demos apply selected values reliably, corrected NavigationView demo page switching so collapsed-pane content no longer overlaps, and surfaced available control preview images on gallery tiles
- **Settings / Skeleton**: Fixed SettingsCard and SettingsExpander auto-sizing so titles, descriptions, and action controls stop clipping or leaking when expanded/collapsed, and restored distinct Skeleton rect, line, and circle showcase shapes
- **Gallery / MainFrame**: Fixed several screenshot-reported gallery regressions, including the main window close button not reliably closing via the title-bar X, missing sidebar tertiary text tokens, and right-panel demo layouts whose output/options panes were too short and clipped toggle or disabled-state showcase controls
- **Popup controls**: Fixed ComboBox dropdown and TeachingTip popup clipping by moving their overlays to `UIParent` while open, preserving the documented callback behavior, and deferring restore work safely until combat ends when needed
- **CheckBox / RadioButton / EmptyState / CommandBar / TabView**: Fixed multiple control-level layout and icon rendering issues causing missing labels, overlapping command labels, unsupported demo glyphs, and TabView icon rendering failures when tabs use Fluent glyphs or texture paths
- **ContentDialog / SettingsExpander**: Fixed dialog button-row visibility and SettingsExpander expanded/collapsed synchronization so examples render their intended states correctly
- **Button**: Replaced flat 1px `TopEdge`/`BottomEdge` `SetColorTexture` strips with a proper `RR4_Border` 9-slice rounded border texture — buttons now display correct rounded corners matching all other controls (Accent, Subtle, Destructive, and Toggle variants)
- **ComboBox**: Fixed nil error on `self.SelectedLabel` → `self.Field.SelectedLabel` (3 call sites: `updateText`, `OnStateChanged` Disabled branch, `OnLoad` font setup)
- **Slider**: Added early-return guard in `FWoWSlider_OnValueChanged` — WoW fires `OnValueChanged` during `CreateFrame` before `OnLoad` applies the mixin, causing a nil `_UpdateFill` call
- **TextBox**: Fixed parent chain in 5 script handlers — `EditBox → Field → TextBox` requires double `GetParent()` to reach the mixin; `ClearBtn → Field` requires single `GetParent()`
- **ToggleSwitch**: Moved `StateLabel` anchor from XML to Lua `OnLoad` — XML `<Layers>` parse before `<Frames>`, so `$parent_Track` doesn't exist when the FontString tries to anchor to it
- **RadioButtonPage (Gallery)**: Changed `SetOnChanged` → `SetOnSelected` to match RadioButton's actual public API
- **SettingsCard.xml**: Wrapped the `Action` child `<Frame>` inside `<Frames>` — bare `<Frame>` inside a template `<Frame>` without the wrapper caused WoW to ignore the element

### Added

- **Custom TGA texture integration** — all 25 custom textures in `FluentWoW/Assets/Textures/` are now used across the entire control library
- **`lib.Textures` registry** — centralized texture path table in ControlBase.lua with keys for every asset (RR4, RR8, Pill, Circle, Badge, Nav/Tab indicators, etc.)
- **`lib.SetupTexture()` helper** — one-call 9-slice texture setup (`SetTexture` + `SetTextureSliceMode` + `SetTextureSliceMargins`)

### Changed

- **24 control files migrated** from `SetColorTexture` to shaped textures with `SetVertexColor`:
  - Rounded-rect controls (Button, TextBox, NumberBox, ComboBox, InfoBar, Expander, CommandBar, Skeleton, SettingsCard, SettingsExpander) use `RR4` / `RR4_Border` / `RR4_Shadow` with 4px 9-slice
  - Dialog/frame controls (ContentDialog, TeachingTip, MainFrame) use `RR8` / `RR8_Border` with 8px 9-slice
  - Pill controls (ToggleSwitch, Badge, SegmentedControl) use `Pill` / `PillBorder` / `BadgePill` with 10px 9-slice
  - Track controls (Slider, ProgressBar) use `PillTrack` / `PillFill` with 2px 9-slice
  - Fixed-size controls (CheckBox, RadioButton) swap between `RoundSquare`/`RoundSquareFill` and `CircleRing`/`CircleDot`
  - Indicator textures (NavigationView, TabView, SegmentedControl, ScrollFrame) use dedicated assets
- 1px edge lines (`TopEdge`, `BottomEdge`, separators) in input controls (TextBox, ComboBox, NumberBox) and full-screen overlays intentionally kept as `SetColorTexture`

- **Architecture wiki page** — rewrote the old ARCHITECTURE.md as [wiki/Architecture.md](wiki/Architecture.md) covering directory layout, module map, three-layer styling model, token resolution, control lifecycle, embed protocol, and adoption strategy

### Changed

- **Ace3 / LibStub access pattern** — all documentation now uses `LibStub("FluentWoW-1.0")` as the sole recommended way to access FluentWoW; the direct `FluentWoW` global is no longer documented as a primary pattern
- **AceAddon Embed** — documented the `AceAddon:NewAddon("MyAddon", "FluentWoW-1.0")` embed pattern across Getting Started, FAQ, API Reference, Core Modules, and Architecture pages
- **Consumer .pkgmeta** — documented how consumer addons can add FluentWoW as an external for Ace3-style embedding
- Removed unused Ace3 external from `.pkgmeta` (FluentWoW does not use Ace3 internally; only LibStub)
- Removed stale ARCHITECTURE.md from `.pkgmeta` ignore list (file no longer tracked)
- Updated wiki sidebar and Home page to include Architecture and Advanced Controls links
- Fixed Controls Overview: removed stale "Phase 2" heading, updated planned-controls to Phase 3+
- Updated Home.md control count (22 → 30+), category count (6 → 7), version (1.0.0 → 1.4.0)
- Updated Gallery.md page table from 5 to 7 pages (added Navigation, Advanced)
- Updated Advanced-Controls.md to remove stale "Phase 2" label
- Updated Design-Principles.md NavigationView row to reflect implemented status
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
