# Input Controls

Data-entry controls for capturing user choices and text input. Each control follows WinUI design patterns adapted for the WoW addon platform.

---

## CheckBox

A two-state or three-state checkbox. Supports `Checked`, `Unchecked`, and `Indeterminate` states.

**WinUI reference:** [CheckBox](https://learn.microsoft.com/windows/apps/design/controls/checkbox)

### Creation

```lua
local cb = FluentWoW:CreateCheckBox(parent, "ShowMinimapCB")
cb:SetText("Show minimap icon")
cb:SetChecked(MyDB.showMinimap)
cb:SetOnChanged(function(self, isChecked, checkState)
    -- checkState: "Checked" | "Unchecked" | "Indeterminate"
    MyDB.showMinimap = isChecked
end)
```

### Three-State Mode

```lua
local cb = FluentWoW:CreateCheckBox(parent)
cb:SetText("Select All")
cb:SetThreeState(true)  -- enable Indeterminate
cb:SetIndeterminate(true)
```

### API

| Method | Parameters | Returns | Description |
|---|---|---|---|
| `SetChecked(checked)` | `boolean` | — | Set checked state |
| `IsChecked()` | — | `boolean` | Check if checked |
| `SetIndeterminate(ind)` | `boolean` | — | Set indeterminate (clears checked) |
| `IsIndeterminate()` | — | `boolean` | Check if indeterminate |
| `SetThreeState(enabled)` | `boolean` | — | Enable three-state cycling |
| `IsThreeState()` | — | `boolean` | Check if three-state is enabled |
| `GetCheckState()` | — | `string` | `"Checked"` / `"Unchecked"` / `"Indeterminate"` |
| `SetText(text)` | `string` | — | Set label text |
| `GetText()` | — | `string` | Get label text |
| `SetOnChanged(fn)` | `function(self, isChecked, checkState)` | — | Change callback |

### Visual States

`Normal` → `Hover` → `Pressed` → `Checked` / `Disabled`

When checked, the box fills with the accent colour and displays a checkmark glyph. When indeterminate, it shows a horizontal dash.

---

## RadioButton

Mutual-exclusion radio buttons within named groups. Selecting one automatically deselects all others in the same group.

**WinUI reference:** [RadioButton](https://learn.microsoft.com/windows/apps/design/controls/radio-button)

### Creation

```lua
local r1 = FluentWoW:CreateRadioButton(parent, "SizeSmall")
r1:SetText("Small")
r1:SetGroup("size")
r1:SetOnSelected(function(self)
    MyDB.size = "small"
end)

local r2 = FluentWoW:CreateRadioButton(parent, "SizeMedium")
r2:SetText("Medium")
r2:SetGroup("size")
r2:SetSelected(true)  -- default selection

local r3 = FluentWoW:CreateRadioButton(parent, "SizeLarge")
r3:SetText("Large")
r3:SetGroup("size")
```

### API

| Method | Parameters | Returns | Description |
|---|---|---|---|
| `SetSelected(selected)` | `boolean` | — | Select/deselect (deselects others in group) |
| `IsSelected()` | — | `boolean` | Check if selected |
| `SetGroup(group)` | `string` | — | Set mutual-exclusion group name |
| `SetText(text)` | `string` | — | Set label text |
| `GetText()` | — | `string` | Get label text |
| `SetOnSelected(fn)` | `function(self)` | — | Fires when user selects this radio |

### Groups

The default group is `"default"`. Radio buttons auto-register with their group on show and auto-unregister on hide. Only one radio per group can be selected at a time.

---

## ToggleSwitch

An on/off toggle with a sliding thumb animation. Includes a header label and a state label (e.g. "On" / "Off").

**WinUI reference:** [ToggleSwitch](https://learn.microsoft.com/windows/apps/design/controls/toggleswitch)

### Creation

```lua
local ts = FluentWoW:CreateToggleSwitch(parent, "EnableTS")
ts:SetHeader("Enable Feature")
ts:SetOnContent("Active")
ts:SetOffContent("Inactive")
ts:SetIsOn(MyDB.featureEnabled)
ts:SetOnToggled(function(self, isOn)
    MyDB.featureEnabled = isOn
end)
```

### API

| Method | Parameters | Returns | Description |
|---|---|---|---|
| `SetIsOn(isOn)` | `boolean` | — | Set toggle state |
| `IsOn()` | — | `boolean` | Check if on |
| `SetHeader(text)` | `string` | — | Set header label text |
| `SetOnContent(text)` | `string` | — | Text when on (default: `"On"`) |
| `SetOffContent(text)` | `string` | — | Text when off (default: `"Off"`) |
| `SetOnToggled(fn)` | `function(self, isOn)` | — | Toggle callback |

### Animation

The thumb slides between left (off) and right (on) positions using the Motion engine's `Tween` with `quadout` easing. Duration is controlled by `Motion.Duration.Fast` token (100ms default). Animation is skipped when `Motion.reducedMotion` is `true`.

---

## TextBox

Single-line or multi-line text input with placeholder text, header label, and focus styling.

**WinUI reference:** [TextBox](https://learn.microsoft.com/windows/apps/design/controls/text-box)

### Creation

```lua
-- Basic text input
local tb = FluentWoW:CreateTextBox(parent, "NameInput")
tb:SetHeader("Character Name")
tb:SetPlaceholder("Enter name...")
tb:SetOnTextChanged(function(self, text, userInput)
    if userInput then
        validateName(text)
    end
end)

-- Multi-line
local notes = FluentWoW:CreateTextBox(parent, "NotesInput")
notes:SetHeader("Notes")
notes:SetMultiline(true, 120)
notes:SetPlaceholder("Type your notes here...")
```

### SearchBox

A TextBox variant with a built-in search icon:

```lua
local search = FluentWoW:CreateSearchBox(parent, "SearchInput")
search:SetPlaceholder("Search...")
search:SetOnTextChanged(function(self, text, userInput)
    filterResults(text)
end)
```

### API

| Method | Parameters | Returns | Description |
|---|---|---|---|
| `SetText(text)` | `string` | — | Set input text |
| `GetText()` | — | `string` | Get current text |
| `SetPlaceholder(text)` | `string` | — | Set placeholder text |
| `SetHeader(text)` | `string` | — | Set header label |
| `SetReadOnly(readOnly)` | `boolean` | — | Make field read-only |
| `SetMultiline(multi, height?)` | `boolean, number?` | — | Multi-line mode; height defaults to 96 |
| `SetMaxLength(maxLen)` | `integer` | — | Maximum character count |
| `SetOnTextChanged(fn)` | `function(self, text, userInput)` | — | Text change callback |
| `SetOnEnterPressed(fn)` | `function(self, text)` | — | Enter key callback (single-line only) |

### Visual States

`Normal` → `Hover` → `Focused` → `Disabled`

When focused, the bottom border highlights with the accent colour.

---

## Slider

A range slider with optional tick marks, value label, header, and custom formatting.

**WinUI reference:** [Slider](https://learn.microsoft.com/windows/apps/design/controls/slider)

### Creation

```lua
local sl = FluentWoW:CreateSlider(parent, "VolumeSlider")
sl:SetHeader("Volume")
sl:SetRange(0, 100)
sl:SetValue(75)
sl:SetStep(5)
sl:SetTickFrequency(25)
sl:SetShowValue(true)
sl:SetValueFormatter(function(v) return v .. "%" end)
sl:SetOnValueChanged(function(self, value, userInput)
    SetCVar("Sound_MasterVolume", value / 100)
end)
```

### API

| Method | Parameters | Returns | Description |
|---|---|---|---|
| `SetValue(value)` | `number` | — | Set slider value |
| `GetValue()` | — | `number` | Get current value |
| `SetRange(min, max)` | `number, number` | — | Set min/max range |
| `SetStep(step)` | `number` | — | Value increment step |
| `SetOrientation(orient)` | `"HORIZONTAL"\|"VERTICAL"` | — | Layout direction |
| `SetTickFrequency(freq)` | `number\|nil` | — | Tick spacing; `nil` hides ticks |
| `SetSnapToTicks(enabled)` | `boolean` | — | Snap values to tick positions |
| `SetHeader(text)` | `string` | — | Set header label |
| `SetShowValue(show)` | `boolean` | — | Show/hide value label |
| `SetValueFormatter(fn)` | `function(value) → string` | — | Custom display formatter |
| `SetOnValueChanged(fn)` | `function(self, value, userInput)` | — | Value change callback |

### Visual States

`Normal` → `Hover` → `Pressed` → `Disabled`

The track fills from left to the thumb position with the accent colour. Tick marks are rendered using `WUILSliderTickTemplate`.

---

## ComboBox

A dropdown selection control. Displays a button that expands to show a scrollable list of items.

**WinUI reference:** [ComboBox](https://learn.microsoft.com/windows/apps/design/controls/combo-box)

### Creation

```lua
local cb = FluentWoW:CreateComboBox(parent, "DifficultyDD")
cb:SetHeader("Difficulty")
cb:SetPlaceholder("Choose...")
cb:SetItems({
    { text = "Easy",   value = 1 },
    { text = "Normal", value = 2 },
    { text = "Hard",   value = 3 },
    { text = "Expert", value = 4 },
})
cb:SetSelectedIndex(2)
cb:SetOnSelectionChanged(function(self, index)
    MyDB.difficulty = self:GetSelectedValue()
end)
```

### API

| Method | Parameters | Returns | Description |
|---|---|---|---|
| `SetItems(items)` | `{text, value}[]` | — | Set all dropdown items |
| `GetItems()` | — | `table` | Get items array |
| `SetSelectedIndex(index)` | `integer` | — | Select by index |
| `GetSelectedIndex()` | — | `integer\|nil` | Get selected index |
| `GetSelectedValue()` | — | `any\|nil` | Get selected item's value |
| `SetHeader(text)` | `string` | — | Set header label |
| `SetPlaceholder(text)` | `string` | — | Set placeholder text |
| `SetOnSelectionChanged(fn)` | `function(self, index)` | — | Selection change callback |

### Combat Safety

The dropdown `_Open()` method is blocked during `InCombatLockdown()`. Opening one ComboBox automatically closes any other open ComboBox.

### Visual States

`Normal` → `Hover` → `Expanded` → `Disabled`

Items are rendered using `WUILComboBoxItemTemplate` via `FramePool` for efficient recycling.
