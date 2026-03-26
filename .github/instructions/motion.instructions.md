---
applyTo: "WinUILib/Motion/**"
---

# Motion Module Rules

## Presets

| Preset | Duration Token | Use |
|---|---|---|
| `FadeIn` | `Motion.Duration.Entrance` | Panel/dialog appear |
| `FadeOut` | `Motion.Duration.Exit` | Dismiss/hide |
| `SlideIn` | `Motion.Duration.Entrance` | Flyout entrance |
| `ScalePress` | `Motion.Duration.Fast` | Click tactile feedback |

## Invariants

- All animations MUST respect `Motion.reducedMotion` — if true, skip animation and apply final state immediately
- All `OnUpdate`-based animations MUST nil the handler when complete (Rule #6)
- All AnimationGroup-based animations MUST call `:Stop()` on completion
- Duration values MUST come from tokens — never hardcode timing
- Easing values MUST come from tokens when available

## Adding New Presets

1. Add the method to `Motion.lua`
2. Use token-based duration and easing
3. Ensure reduced motion support
4. Ensure cleanup on completion
5. Document in `.docs/TokenReference.md` Motion section
