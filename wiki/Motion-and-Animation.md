# Motion & Animation

FluentWoW includes a consolidated motion engine (`FluentWoW.Motion`) that provides property tweening, timer utilities, and preset animations. It is built on a flux-derived tweening core adapted for WoW's `OnUpdate` frame driver.

---

## Architecture

The motion system lives in `Motion/Motion.lua` and registers as `FluentWoW.Motion`. Under the hood, it drives all tweens from a single hidden frame's `OnUpdate` handler — no `C_Timer` dependency, no per-frame overhead when idle. The driver frame auto-parks itself (hides) when there are no active tweens.

The `Libs/Motion/` folder contains the **original MIT-licensed source files** ([rxi/flux](https://github.com/rxi/flux), [airstruck/knife](https://github.com/airstruck/knife)) as reference/attribution. They are not loaded by the TOC.

---

## Core Tweening

### `Motion:Tween(obj, time, vars)`

Animates properties on a proxy object over time.

```lua
local Mot = FluentWoW.Motion

-- Animate a proxy object
local proxy = { x = 0, alpha = 0 }
local handle = Mot:Tween(proxy, 0.3, { x = 100, alpha = 1 })
```

**Parameters:**
- `obj` — Lua table whose fields will be interpolated
- `time` — duration in seconds
- `vars` — target values for fields in `obj`

**Returns** a chainable tween handle with:

| Chain Method | Description |
| --- | --- |
| `:ease(name)` | Set easing function (see [Easing Functions](#easing-functions)) |
| `:delay(seconds)` | Delay before start |
| `:onstart(fn)` | Callback when tween begins |
| `:onupdate(fn)` | Callback every tick |
| `:oncomplete(fn)` | Callback when tween finishes |
| `:after(time, vars)` | Chain a follow-up tween |
| `:stop()` | Cancel this tween |

### Example — Custom Fade

```lua
local proxy = { alpha = 0 }
FluentWoW.Motion:Tween(proxy, 0.25, { alpha = 1 })
    :ease("quadout")
    :onupdate(function()
        myFrame:SetAlpha(proxy.alpha)
    end)
    :oncomplete(function()
        myFrame:SetAlpha(1)
    end)
```

### Tween Ownership

Set `handle._owner = someFrame` so `Motion:Stop(someFrame)` can cancel it:

```lua
local handle = Mot:Tween(proxy, 0.3, { y = 100 })
handle._owner = myFrame
-- Later: Mot:Stop(myFrame) will cancel this tween
```

---

## Timer Utilities

### `Motion:After(delay, callback)`

One-shot delayed callback. Returns a cancellable handle.

```lua
local handle = FluentWoW.Motion:After(2, function()
    print("Two seconds later!")
end)

-- Cancel if needed
FluentWoW.Motion:Cancel(handle)
```

### `Motion:Every(interval, callback, limit?)`

Repeating timer. Optional `limit` stops after N repetitions.

```lua
-- Tick every 0.5 seconds, 10 times
FluentWoW.Motion:Every(0.5, function()
    updateDisplay()
end, 10)

-- Tick forever
FluentWoW.Motion:Every(1, function()
    pollStatus()
end)
```

---

## Control Methods

| Method | Description |
| --- | --- |
| `Motion:Cancel(handle)` | Cancel a specific tween or timer handle |
| `Motion:Stop(frame)` | Stop all tweens owned by `frame` |
| `Motion:StopAll()` | Stop all tweens and timers, park the driver frame |

---

## Preset Animations

These are ready-made animations that FluentWoW controls use internally. You can use them on any frame.

### `Motion:FadeIn(frame, duration?, onDone?)`

Fades a frame from alpha 0 to 1 and shows it.

```lua
FluentWoW.Motion:FadeIn(myFrame, 0.25, function()
    print("Fully visible")
end)
```

### `Motion:FadeOut(frame, duration?, onDone?)`

Fades a frame from current alpha to 0 and hides it.

```lua
FluentWoW.Motion:FadeOut(myFrame, 0.15, function()
    print("Hidden")
end)
```

### `Motion:SlideIn(frame, direction, distance, duration?, onDone?)`

Slides a frame in from an offset position while fading in.

```lua
-- Slide in from 20px below
FluentWoW.Motion:SlideIn(myFrame, "UP", 20, 0.25)

-- Slide in from the left
FluentWoW.Motion:SlideIn(myFrame, "RIGHT", 30, 0.3)
```

**Directions:** `"UP"`, `"DOWN"`, `"LEFT"`, `"RIGHT"`

### `Motion:ScalePress(frame, duration?)`

A tactile 0.95× scale bounce — used on button mouse-down for haptic feedback. Uses a native WoW `AnimationGroup` (not the tween engine) for crisp timing.

```lua
FluentWoW.Motion:ScalePress(myButton, 0.1)
```

### `Motion:ColorTo(frame, fromR,G,B,A, toR,G,B,A, duration?, applyFn, onDone?)`

Smoothly transitions between two colours over time.

```lua
FluentWoW.Motion:ColorTo(myFrame,
    1, 0, 0, 1,   -- from: red
    0, 0, 1, 1,   -- to: blue
    0.3,
    function(r, g, b, a)
        myFrame.bg:SetColorTexture(r, g, b, a)
    end
)
```

### `Motion:HeightTo(frame, fromH, toH, duration?, onDone?)`

Animates frame height — used by Expander and SettingsExpander for expand/collapse.

```lua
FluentWoW.Motion:HeightTo(myFrame, 0, 200, 0.25, function()
    print("Expanded")
end)
```

---

## Easing Functions

The motion engine provides 27 easing functions plus `linear`:

| Family | In | Out | InOut |
| --- | --- | --- | --- |
| **quad** | `quadin` | `quadout` | `quadinout` |
| **cubic** | `cubicin` | `cubicout` | `cubicinout` |
| **quart** | `quartin` | `quartout` | `quartinout` |
| **quint** | `quintin` | `quintout` | `quintinout` |
| **expo** | `expoin` | `expoout` | `expoinout` |
| **sine** | `sinein` | `sineout` | `sineinout` |
| **circ** | `circin` | `circout` | `circinout` |
| **back** | `backin` | `backout` | `backinout` |
| **elastic** | `elasticin` | `elasticout` | `elasticinout` |
| **linear** | `linear` | — | — |

```lua
FluentWoW.Motion:Tween(proxy, 0.3, { x = 100 }):ease("cubicout")
```

The default easing is `quadout` for most FluentWoW controls.

### Easing Descriptions

| Type | Feel |
| --- | --- |
| `linear` | Constant speed |
| `*in` | Starts slow, accelerates |
| `*out` | Starts fast, decelerates (most natural for UI) |
| `*inout` | Slow at both ends, fast in middle |
| `back*` | Overshoots then settles |
| `elastic*` | Springy bounce |

---

## Reduced Motion

Set `Motion.reducedMotion = true` to skip all animations globally. Controls will snap to their final visual state instantly.

```lua
FluentWoW.Motion.reducedMotion = true  -- accessibility
```

This is respected by all preset animations and by internal control animations (ToggleSwitch thumb, Expander height, etc.).

---

## Performance Notes

- **Single driver frame** — all tweens share one `OnUpdate` handler. Zero overhead when idle.
- **Auto-park** — the driver frame hides itself when there are no active tweens, eliminating unnecessary `OnUpdate` calls.
- **ScalePress uses AnimationGroup** — native WoW animation for crisp sub-frame timing.
- **Cancel defunct tweens** — always `Stop(frame)` before starting new tweens on the same frame to avoid accumulation.
