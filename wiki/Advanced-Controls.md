# Advanced Controls

Phase 2 controls that extend FluentWoW's vocabulary with data-entry helpers, status indicators, loading placeholders, and contextual UI.

---

## NumberBox

A validated numeric input field with spin (up/down) buttons, min/max bounds, and step increment. Built on WoW's `EditBox` with the same token-driven styling as TextBox.

**WinUI reference:** [NumberBox](https://learn.microsoft.com/windows/apps/design/controls/number-box)

### Creation

```lua
local nb = FluentWoW:CreateNumberBox(parent, "Opacity")
nb:SetPoint("TOPLEFT", parent, "TOPLEFT", 16, -16)
nb:SetSize(200, 32)

nb:SetHeader("Opacity")
nb:SetMinimum(0)
nb:SetMaximum(100)
nb:SetStep(5)
nb:SetValue(75)

nb:SetOnValueChanged(function(self, value)
    print("New value:", value)
end)
```

### API

| Method | Parameters | Returns | Description |
| --- | --- | --- | --- |
| `SetValue(v)` | `number` | — | Set current value (clamped to min/max) |
| `GetValue()` | — | `number` | Get current value |
| `SetMinimum(v)` | `number` | — | Set minimum bound |
| `SetMaximum(v)` | `number` | — | Set maximum bound |
| `SetStep(v)` | `number` | — | Set spin increment |
| `SetHeader(text)` | `string` | — | Set header label |
| `SetOnValueChanged(fn)` | `function(self, value)` | — | Value change callback |
| `SetEnabled(e)` | `boolean` | — | Enable/disable control |

### Visual States

`Normal` → `Hover` → `Focused` → `Disabled`

---

## SegmentedControl

A mutually exclusive segmented selector. Each segment is a clickable region; the active segment displays a sliding selection indicator.

### Creation

```lua
local seg = FluentWoW:CreateSegmentedControl(parent, "ViewMode")
seg:SetPoint("TOPLEFT", parent, "TOPLEFT", 16, -16)
seg:SetSize(300, 32)

seg:SetItems({ "Day", "Week", "Month", "Year" })
seg:SetSelectedIndex(1)

seg:SetOnSelectionChanged(function(self, index, text)
    print("Selected segment:", text)
end)
```

### API

| Method | Parameters | Returns | Description |
| --- | --- | --- | --- |
| `SetItems(items)` | `string[]` | — | Set segment labels |
| `SetSelectedIndex(i)` | `integer` | — | Select segment |
| `GetSelectedItem()` | — | `string?` | Get selected label |
| `SetOnSelectionChanged(fn)` | `function(self, index, text)` | — | Selection callback |
| `SetEnabled(e)` | `boolean` | — | Enable/disable |

### Visual Behaviour

- Animated indicator slides to the selected segment using `Motion` tweening
- FramePool recycling for segment items
- States: `Normal` | `Disabled`

---

## Badge

A compact status pill / indicator. Supports five colour appearances mapped to semantic token aliases.

### Creation

```lua
local badge = FluentWoW:CreateBadge(parent, "StatusBadge", "Success")
badge:SetPoint("CENTER")
badge:SetText("Online")
badge:SetIcon(FluentWoW.Icons.Checkmark)
```

### API

| Method | Parameters | Returns | Description |
| --- | --- | --- | --- |
| `SetText(text)` | `string` | — | Badge label |
| `SetIcon(glyph)` | `string?` | — | Optional icon glyph |
| `SetAppearance(name)` | `"Accent"\|"Success"\|"Warning"\|"Error"\|"Subtle"` | — | Colour scheme |

### Appearances

| Name | Background Token | Text Token |
| --- | --- | --- |
| `Accent` | `AccentDefault` | `TextOnAccentPrimary` |
| `Success` | `StatusSuccessBackground` | `StatusSuccessText` |
| `Warning` | `StatusWarningBackground` | `StatusWarningText` |
| `Error` | `StatusErrorBackground` | `StatusErrorText` |
| `Subtle` | `SubtleFillTransparent` | `TextSecondary` |

---

## CommandBar

A horizontal toolbar containing primary command buttons with optional overflow.

**WinUI reference:** [CommandBar](https://learn.microsoft.com/windows/apps/design/controls/command-bar)

### Creation

```lua
local bar = FluentWoW:CreateCommandBar(parent, "Toolbar")
bar:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
bar:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0)
bar:SetHeight(40)

bar:SetCommands({
    { key = "new",    icon = FluentWoW.Icons.Add,    label = "New",    onClick = function() end },
    { key = "save",   icon = FluentWoW.Icons.Save,   label = "Save",   onClick = function() end },
    { key = "delete", icon = FluentWoW.Icons.Delete,  label = "Delete", onClick = function() end },
    { key = "share",  icon = FluentWoW.Icons.Share,   label = "Share",  onClick = function() end },
})

bar:SetOverflowEnabled(true)
```

### API

| Method | Parameters | Returns | Description |
| --- | --- | --- | --- |
| `SetCommands(cmds)` | `{key, icon?, label?, tooltip?, onClick}[]` | — | Set command list |
| `SetOverflowEnabled(e)` | `boolean` | — | Show "⋯" overflow button |
| `SetOnOverflow(fn)` | `function(self)` | — | Overflow button callback |

### Visual Behaviour

- FramePool recycled command items
- Each item shows icon + optional label
- Overflow button (three dots) at the end when enabled

---

## TeachingTip

A contextual callout/coach mark that anchors to a target frame. Includes title, body text, close button, and optional action slot.

**WinUI reference:** [TeachingTip](https://learn.microsoft.com/windows/apps/design/controls/teaching-tip)

### Creation

```lua
local tip = FluentWoW:CreateTeachingTip(parent, "WelcomeTip")
tip:SetTitle("Welcome!")
tip:SetBody("Click this button to get started.")
tip:SetTarget(myButton, "TOP")  -- anchor above myButton
tip:SetClosable(true)

tip:Open()  -- blocked during InCombatLockdown()
```

### API

| Method | Parameters | Returns | Description |
| --- | --- | --- | --- |
| `SetTitle(text)` | `string` | — | Callout title |
| `SetBody(text)` | `string` | — | Body / description text |
| `SetTarget(frame, placement)` | `Frame, "TOP"\|"BOTTOM"\|"LEFT"\|"RIGHT"` | — | Anchor to a target frame |
| `SetActionControl(ctrl)` | `Frame?` | — | Embed a control (e.g. a Button) in the action slot |
| `SetClosable(closable)` | `boolean` | — | Show/hide close button |
| `Open()` | — | — | Show callout (**combat-guarded**) |
| `Close()` | — | — | Hide callout |
| `SetOnClose(fn)` | `function(self)` | — | Close callback |

### Important Notes

- **Frame strata:** `TOOLTIP` (always on top)
- **Combat-safe:** `Open()` is blocked during `InCombatLockdown()`
- **Arrow:** A directional arrow points toward the target frame
- **Placement:** `TOP` (appears above), `BOTTOM` (below), `LEFT`, `RIGHT`

---

## EmptyState

A placeholder shown when a content area has no data. Displays a large icon, title, description, and an optional call-to-action button slot.

### Creation

```lua
local empty = FluentWoW:CreateEmptyState(parent, "NoResults")
empty:SetAllPoints(parent)

empty:SetIcon(FluentWoW.Icons.Search)
empty:SetTitle("No results found")
empty:SetDescription("Try adjusting your search or filters.")

local btn = FluentWoW:CreateButton(empty, "ClearBtn")
btn:SetText("Clear Filters")
empty:SetActionControl(btn)
```

### API

| Method | Parameters | Returns | Description |
| --- | --- | --- | --- |
| `SetIcon(glyph)` | `string` | — | Large icon glyph |
| `SetTitle(text)` | `string` | — | Title text |
| `SetDescription(text)` | `string` | — | Description text |
| `SetActionControl(ctrl)` | `Frame?` | — | Embed an action control (e.g. Button) |

---

## Skeleton

An animated shimmer loading placeholder. Displays a pulsing/sliding shimmer effect over a neutral background to indicate content is loading. Supports rectangle, circle, and line shapes.

### Creation

```lua
local skel = FluentWoW:CreateSkeleton(parent, "LoadingBar", "rect")
skel:SetPoint("TOPLEFT", parent, "TOPLEFT", 16, -16)
skel:SetSize(200, 16)
skel:SetActive(true)  -- start shimmer

-- Stop and hide when data arrives
skel:SetActive(false)
```

### API

| Method | Parameters | Returns | Description |
| --- | --- | --- | --- |
| `SetActive(active)` | `boolean` | — | Start/stop shimmer animation |
| `IsActive()` | — | `boolean` | Whether shimmer is running |
| `SetShape(shape)` | `"rect"\|"circle"\|"line"` | — | Visual shape variant |

### Important Notes

- **OnUpdate cleanup:** Shimmer `OnUpdate` handler is properly nil'd when `SetActive(false)` is called (Rule #6)
- **SetClipsChildren:** `true` — the shimmer gradient is clipped to the frame bounds
- **Shape variants:**
  - `rect` — default rectangular placeholder
  - `circle` — circular avatar placeholder (corner radius via mask)
  - `line` — thin text-line placeholder (4px height)
