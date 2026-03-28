# Design Principles

FluentWoW translates the core principles of Microsoft's Fluent Design System into patterns that work within World of Warcraft's addon platform constraints.

---

## Philosophy

FluentWoW is **not** a XAML clone. It extracts the **transferable design principles** from Windows Fluent Design and maps them onto WoW-native frame constraints:

- **Token-driven** — all visual constants flow from a central registry, not hard-coded values
- **State-machine driven** — every control has explicit visual states with clean transitions
- **Combat-aware** — all UI mutations respect `InCombatLockdown()`
- **Library-first** — designed to be consumed via `LibStub("FluentWoW-1.0")` or embedded through AceAddon

---

## Principle Translation Matrix

| WinUI / Fluent Concept | Portability | WoW Strategy | Caveats |
| --- | --- | --- | --- |
| **Design tokens** | ✅ Direct | Lua token registry (`FluentWoW.Tokens`) | Runtime-switched; no CSS variables |
| **Spacing scale** | ✅ Direct | `Tokens.Spacing.*` (XS=2 … XXXL=32) | Integer pixels; WoW rounds sub-pixel |
| **Type ramp** | ✅ Adapted | `Tokens.Typography.*` → `SetFont()` | Limited to bundled WoW fonts |
| **Corner radii** | ⚠️ Adapted | 9-slice textures or backdrop insets | No native rounded-rect primitives |
| **Elevation / shadow** | ⚠️ Adapted | Layered backdrop + border tints | No real drop-shadow support |
| **Surfaces / panels** | ✅ Direct | `Backdrop` + `SetBackdropColor` | Tiling artefacts at fractional scale |
| **Light / dark theme** | ⚠️ Adapted | Token swapping via `SetTheme()` | No OS-level dark-mode hook |
| **Hover/press/disabled** | ✅ Direct | `StateMachine` + script hooks | Combat lockdown blocks some mutations |
| **Motion / animation** | ✅ Adapted | `Motion` module wraps flux tweening | `OnUpdate` fallback for height anim |
| **Dialogs / flyouts** | ✅ Adapted | `ContentDialog`, `ComboBox` dropdown | Must defer to post-combat |
| **Settings presentation** | ✅ Direct | `SettingsCard`, `SettingsExpander` | Mirrors CommunityToolkit controls |
| **List / detail** | ⚠️ Adapted | `ScrollFrame` + `FramePool` | No native virtualisation; manual pool |
| **Accessibility** | ⚠️ Partial | Tooltip text, keyboard nav | WoW screen-reader support is limited |
| **Responsive layout** | ⚠️ Adapted | `StackLayout` OnSizeChanged re-layout | No media queries; manual breakpoints |
| **Page transitions** | ✅ Adapted | `Motion:FadeIn/FadeOut` between frames | No connected animation |
| **Navigation structures** | ✅ Adapted | `TabView`, `NavigationView`, sidebar nav | Full parity with WinUI nav patterns |
| **Data binding** | ❌ Not viable | Lua callbacks / event bus | No reactive binding engine in WoW |

---

## Key Adaptations

### Rounded Corners

WoW has no native `border-radius`. FluentWoW uses:
- **Backdrop insets** for subtle rounding (controlled by `Radii.*` tokens)
- **9-slice textures** where precise corner radius is needed
- Most controls use subtle 1–2px corner rounding that reads as "modern" without requiring complex texture work

### Elevation & Shadow

WoW has no drop-shadow primitive. FluentWoW simulates depth through:
- **Layered backgrounds** — Shadow textures positioned behind the main surface
- **Border tinting** — Darker bottom edges on buttons create a "lifted" appearance
- **Surface colour hierarchy** — Base → Raised → Overlay → Elevated creates perceived depth

### Animation

WoW's animation system is more limited than CSS/XAML:
- **Property tweening** — handled by the flux-derived Motion engine via `OnUpdate`
- **Height animation** — no native support; Motion uses frame-by-frame `SetHeight()` calls
- **Scale animation** — native `AnimationGroup` with `Scale` animation type (used for ScalePress)
- **Colour transitions** — proxy-based tweening with per-frame `SetColorTexture` application

### Typography

WoW restricts font choices to bundled game fonts or addon-provided `.ttf` files:
- `MORPHEUS.ttf` — decorative (Display headers)
- `FRIZQT__.TTF` — standard UI (Headers, Titles)
- `ARIALN.TTF` — body / small text (Body, Caption)
- `Segoe Fluent Icons.ttf` — icon glyphs (bundled)

The type ramp is faithfully adapted but cannot match WinUI's Segoe UI family exactly.

---

## Design Rules Summary

1. **MainFrame is the root** — all FluentWoW controls must be descendants of a `CreateMainFrame()` window
2. **Token everything** — no hard-coded colours, sizes, or fonts in control code
3. **State machine drives visuals** — all visual changes flow through `OnStateChanged`
4. **Combat-safe by default** — defer protected operations to post-combat
5. **One control, one file pair** — XML template + Lua behaviour in a named folder
6. **Factory pattern** — consumers create controls via `FluentWoW:Create*()`, never `CreateFrame` directly
7. **Theme-reactive** — all controls listen for `"ThemeChanged"` and re-style automatically
8. **Pool recyclable frames** — ComboBox items, tab headers, list rows use `FramePool`
9. **Pixel-snap** — use `Utils.SnapToPixel()` for crisp alignment
10. **Accessible by default** — tooltips, disabled states, and clear visual feedback
11. **Motion with purpose** — animations serve UX (feedback, orientation, delight), never just decoration
