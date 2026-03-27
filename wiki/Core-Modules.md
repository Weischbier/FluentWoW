# Core Modules

FluentWoW's core runtime provides five foundational modules that underpin every control. They are loaded first via the TOC and registered on the `FluentWoW` global namespace.

---

## Bootstrap

**File:** `Core/Bootstrap.lua`  
**Access:** `FluentWoW` (global)

The entry point for the entire framework. Handles:

- **LibStub registration** — `LibStub("FluentWoW-1.0")` for Ace3-pattern consumers
- **Version negotiation** — only the newest copy loads when multiple addons embed FluentWoW
- **Global namespace** — establishes `FluentWoW` as the singleton table
- **Module registration** — `RegisterModule(name, tbl)` for internal modules

### Key Properties

| Property | Type | Description |
|---|---|---|
| `FluentWoW.version` | `number` | Encoded version (e.g. 10000 = 1.00.00) |
| `FluentWoW.name` | `string` | Library name (`"FluentWoW-1.0"`) |
| `FluentWoW.debug` | `boolean?` | Set to `true` to enable debug messages |

### Methods

| Method | Signature | Description |
|---|---|---|
| `Error(msg, level?)` | Raises a formatted error | `[FluentWoW] msg` |
| `Assert(cond, msg)` | Returns false + prints warning if cond is falsy | Non-throwing assertion |
| `Debug(msg)` | Prints to chat if `lib.debug == true` | Debug logging |
| `RegisterModule(name, tbl)` | Registers `tbl` as `FluentWoW[name]` | Internal module registration |

### Usage Patterns

```lua
-- Direct global
local lib = FluentWoW

-- LibStub (Ace3 pattern)
local lib = LibStub("FluentWoW-1.0")

-- Enable debug logging
FluentWoW.debug = true
FluentWoW:Debug("This will print to chat")
```

---

## EventBus

**File:** `Core/EventBus.lua`  
**Access:** `FluentWoW.EventBus`

A lightweight publish/subscribe system for decoupling framework internals. Used by the token system, controls, and available for consumer addons.

### API

| Method | Signature | Description |
|---|---|---|
| `On(event, fn)` | Subscribe to an event | Persistent listener |
| `Off(event, fn)` | Unsubscribe a specific function | Must pass the exact function reference |
| `Once(event, fn)` | Subscribe for a single firing | Auto-removes after first call |
| `Emit(event, ...)` | Fire an event with arguments | Calls all listeners with `SafeCall` |
| `Clear(event)` | Remove all listeners for an event | Nuclear option |

### Built-in Events

| Event | Payload | Source |
|---|---|---|
| `"ThemeChanged"` | `themeName` | `Tokens:SetTheme()` |
| `"ThemeRegistered"` | `themeName` | `Tokens:RegisterTheme()` |
| `"TokensOverridden"` | `overridesTable` | `Tokens:Override()` |

### Example

```lua
local bus = FluentWoW.EventBus

-- Subscribe
local function onTheme(name)
    print("Theme changed to:", name)
end
bus:On("ThemeChanged", onTheme)

-- Emit (done internally by Tokens)
bus:Emit("ThemeChanged", "Light")

-- Unsubscribe
bus:Off("ThemeChanged", onTheme)

-- One-shot listener
bus:Once("ThemeChanged", function(name)
    print("First theme change only:", name)
end)
```

### Custom Events

You can use the EventBus for your own addon's events:

```lua
-- Publisher
FluentWoW.EventBus:Emit("MyAddon_DataLoaded", data)

-- Subscriber
FluentWoW.EventBus:On("MyAddon_DataLoaded", function(data)
    processData(data)
end)
```

> **Note:** Event handlers are called via `Utils.SafeCall`, so one failing listener won't break others.

---

## StateMachine

**File:** `Core/StateMachine.lua`  
**Access:** `FluentWoW.StateMachine`

A Visual State Machine (VSM) that tracks the current interaction state of each control. Every FluentWoW control has a `_vsm` instance (created by `ControlBase:WUILInit()`).

### States

| State | Meaning |
|---|---|
| `Normal` | Default resting state |
| `Hover` | Mouse is over the control |
| `Pressed` | Mouse button is held down |
| `Disabled` | Control is disabled |
| `Focused` | Control has keyboard focus |
| `Selected` | Selected item (RadioButton) |
| `Checked` | Checked state (CheckBox, ToggleButton) |
| `Expanded` | Expanded (Expander, ComboBox, SettingsExpander) |
| `Error` | Error state |
| `Warning` | Warning state |

### API

| Method | Signature | Description |
|---|---|---|
| `New(control, initial?)` | Creates a new VSM instance | Returns a machine object |
| `GetState()` | — | Current state name |
| `SetState(newState)` | Transition to new state | Fires handlers + `control.OnStateChanged` |
| `SetFlag(flag, value)` | Set a boolean flag | Special handling for `"Disabled"` flag |
| `GetFlag(flag)` | Get flag value | Returns `true` or `false` |
| `OnState(state, fn)` | Register a state handler | Called when entering that state |

### How Controls Use It

```lua
-- Inside a control's OnLoad
self._vsm = FluentWoW.StateMachine:New(self)

-- Transition on hover
function MyControl_OnEnter(self)
    self._vsm:SetState("Hover")
end

-- The control overrides OnStateChanged to update visuals
function MyControlMixin:OnStateChanged(newState, prevState)
    if newState == "Hover" then
        self.BG:SetColorTexture(hoverColor)
    elseif newState == "Normal" then
        self.BG:SetColorTexture(normalColor)
    end
end
```

### Disabled Flag

The `"Disabled"` flag has special handling:

```lua
self._vsm:SetFlag("Disabled", true)   -- saves current state, transitions to "Disabled"
self._vsm:SetFlag("Disabled", false)  -- restores to "Normal"
```

---

## FramePool

**File:** `Core/FramePool.lua`  
**Access:** `FluentWoW.FramePool`

A frame recycling pool to avoid repeated `CreateFrame` allocations. Used internally by ComboBox (dropdown items), TabView (tabs), and available for consumer addons building lists.

### API

| Method | Signature | Description |
|---|---|---|
| `New(frameType, parent, template?, resetFn?)` | Create a new pool | Returns pool instance |
| `Acquire()` | — | Get a frame (creates if pool is empty) |
| `Release(frame)` | Return a frame to the pool | Hides, clears points, calls resetFn |
| `ReleaseAll()` | Return all active frames | Bulk cleanup |
| `ActiveCount()` | — | Number of currently acquired frames |

### Example

```lua
local pool = FluentWoW.FramePool:New("Button", parent, "WUILComboBoxItemTemplate", function(frame)
    -- Custom reset function (optional)
    frame:SetText("")
    frame:SetScript("OnClick", nil)
end)

-- Acquire frames as needed
local item1 = pool:Acquire()
item1:SetText("Option 1")

local item2 = pool:Acquire()
item2:SetText("Option 2")

-- Release when done
pool:Release(item1)
pool:Release(item2)

-- Or release everything
pool:ReleaseAll()

-- Check active count
print(pool:ActiveCount())  -- 0
```

### Lifecycle

1. `Acquire()` checks the free pool first
2. If empty, creates a new frame via `CreateFrame`
3. Acquired frames are shown automatically
4. `Release()` hides the frame, clears anchors, runs the optional reset function, and returns it to the free pool

---

## Utils

**File:** `Core/Utils.lua`  
**Access:** `FluentWoW.Utils`

A collection of stateless utility functions used throughout the framework.

### Table Helpers

| Function | Signature | Description |
|---|---|---|
| `Merge(dst, src)` | Returns `dst` | Copies `src` keys into `dst` (non-overwriting) |
| `DeepCopy(orig)` | Returns new table | Deep-clones a table |
| `Contains(tbl, value)` | Returns `boolean` | Checks if array contains value |

### String Helpers

| Function | Signature | Description |
|---|---|---|
| `ColorText(text, r, g, b)` | Returns `string` | Wraps text in WoW colour codes |
| `Truncate(text, maxLen)` | Returns `string` | Truncates with ellipsis (`…`) |

### Frame Helpers

| Function | Signature | Description |
|---|---|---|
| `SetPoint(frame, point, relativeTo, relativePoint, x?, y?)` | — | `ClearAllPoints()` then `SetPoint()` in one call |
| `SnapToPixel(v)` | Returns `number` | Rounds to nearest integer (pixel-snap) |
| `UIScale()` | Returns `number` | `UIParent:GetScale()` |

### Colour Helpers

| Function | Signature | Description |
|---|---|---|
| `HexToRGB(hex)` | Returns `r, g, b` | Converts `"#FF8800"` or `"FF8800"` to 0–1 floats |
| `LerpColor(r1,g1,b1, r2,g2,b2, t)` | Returns `r, g, b` | Linear interpolation between two colours |

### Safety

| Function | Signature | Description |
|---|---|---|
| `SafeCall(fn, ...)` | Returns `ok, result` | `pcall` wrapper with debug logging on failure |
| `InCombat()` | Returns `boolean` | Alias for `InCombatLockdown()` |

### Example

```lua
local U = FluentWoW.Utils

-- Merge defaults
local opts = U.Merge({ size = 12 }, userOpts)

-- Safe colour text
local msg = U.ColorText("Warning!", 1, 0.8, 0)

-- Hex conversion
local r, g, b = U.HexToRGB("#4A90D9")

-- Combat check
if U.InCombat() then
    print("Can't do that in combat!")
end
```
