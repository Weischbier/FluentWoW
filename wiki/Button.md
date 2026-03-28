# Button

The Button control family implements WinUI's [Button](https://learn.microsoft.com/windows/apps/design/controls/buttons) pattern — five flavours covering primary actions, secondary actions, destructive operations, icon-only triggers, and toggle states.

---

## Variants

| Variant | Factory | Template | Use Case |
| --- | --- | --- | --- |
| **Accent** (default) | `CreateButton(parent, name)` | `WUILButtonTemplate` | Primary / call-to-action |
| **Subtle** | `CreateButton(parent, name, "Subtle")` | `WUILButtonSubtleTemplate` | Secondary / low-emphasis |
| **Destructive** | `CreateButton(parent, name, "Destructive")` | `WUILButtonDestructiveTemplate` | Dangerous / irreversible actions |
| **IconButton** | `CreateIconButton(parent, name)` | `WUILIconButtonTemplate` | Square icon-only button |
| **ToggleButton** | `CreateToggleButton(parent, name)` | `WUILToggleButtonTemplate` | Checked / unchecked toggle |

---

## Visual States

All buttons cycle through these states automatically:

| State | Trigger |
| --- | --- |
| `Normal` | Default resting state |
| `Hover` | Mouse enters button area |
| `Pressed` | Mouse button held down |
| `Disabled` | `SetEnabled(false)` called |
| `Checked` | ToggleButton only — active toggle state |

State transitions drive background, label, edge, and overlay colour changes — all resolved through the token system.

---

## Button (Accent / Subtle / Destructive)

### Creation

```lua
local FluentWoW = LibStub("FluentWoW-1.0")

-- Accent (primary action)
local save = FluentWoW:CreateButton(parent, "SaveBtn", "Accent")
save:SetText("Save")
save:SetPoint("BOTTOMRIGHT", -16, 16)
save:SetOnClick(function(self)
    MyAddon:Save()
end)

-- Subtle (secondary action)
local cancel = FluentWoW:CreateButton(parent, "CancelBtn", "Subtle")
cancel:SetText("Cancel")

-- Destructive (dangerous action)
local delete = FluentWoW:CreateButton(parent, "DeleteBtn", "Destructive")
delete:SetText("Delete All")
```

### API

| Method | Parameters | Description |
| --- | --- | --- |
| `SetText(text)` | `text: string` | Set button label |
| `GetText()` | — | Returns current label text |
| `SetStyle(style)` | `style: "Accent"\|"Subtle"\|"Destructive"` | Change style at runtime |
| `SetOnClick(fn)` | `fn: function(self, mouseButton)` | Set click callback |
| `SetEnabled(enabled)` | `enabled: boolean` | Enable/disable (inherited) |
| `SetTooltip(title, text?)` | `title, text: string` | Set tooltip (inherited) |

### Style Token Mapping

| | Background | Background (Hover) | Background (Press) | Label | Top Edge |
| --- | --- | --- | --- | --- | --- |
| **Accent** | `Color.Accent.Primary` | `Color.Accent.Hover` | `Color.Accent.Pressed` | `Color.Text.OnAccent` | `Color.Accent.Light` |
| **Subtle** | `Color.Surface.Elevated` | `Color.Overlay.Hover` | `Color.Overlay.Press` | `Color.Text.Primary` | `Color.Border.Subtle` |
| **Destructive** | `Color.Feedback.Error` | `Color.Feedback.ErrorHover` | `Color.Feedback.Error` | `Color.Text.OnAccent` | `Color.Feedback.Error` |

---

## IconButton

A square button displaying only an icon — ideal for toolbars, close buttons, and compact actions.

### Creation

```lua
local btn = FluentWoW:CreateIconButton(parent, "CloseBtn")
btn:SetIcon("Interface\\AddOns\\FluentWoW\\Assets\\Fonts\\icon.tga")
btn:SetPoint("TOPRIGHT", -4, -4)
btn:SetOnClick(function(self)
    parent:Hide()
end)

-- Using a Fluent icon glyph
btn:SetIcon(FluentWoW.FLUENT_ICON_FONT)  -- set the font first on the icon fontstring
-- Or use atlas
btn:SetIcon("common-icon-redx", true)
```

### API

| Method | Parameters | Description |
| --- | --- | --- |
| `SetIcon(path, isAtlas?)` | `path: string`, `isAtlas: boolean` | Set icon texture or atlas |
| `SetOnClick(fn)` | `fn: function(self, mouseButton)` | Set click callback |

---

## ToggleButton

A button that alternates between checked and unchecked states on each click.

### Creation

```lua
local toggle = FluentWoW:CreateToggleButton(parent, "BoldBtn")
toggle:SetText("Bold")
toggle:SetOnToggle(function(self, isChecked)
    editor:SetBold(isChecked)
end)

-- Pre-set checked state
toggle:SetChecked(true)
```

### API

| Method | Parameters | Description |
| --- | --- | --- |
| `SetText(text)` | `text: string` | Set button label |
| `GetText()` | — | Returns current label text |
| `SetChecked(checked)` | `checked: boolean` | Set toggle state |
| `IsChecked()` | — | Returns `true` if checked |
| `SetOnToggle(fn)` | `fn: function(self, isChecked)` | Fires on toggle |
| `SetOnClick(fn)` | `fn: function(self, mouseButton)` | Fires on every click |

---

## Motion

All buttons play a **ScalePress** micro-animation (0.95× scale bounce) on mouse-down, providing tactile feedback. This uses a native WoW `AnimationGroup` and completes in ~100ms. The animation respects `Motion.reducedMotion` — if set to `true`, the bounce is skipped.

---

## Best Practices

1. **One primary action per surface.** Use a single Accent button per dialog/card. Use Subtle for everything else.
2. **Use Destructive sparingly.** Reserve for irreversible actions (delete, reset). Consider pairing with a `ContentDialog` confirmation.
3. **Keep labels short.** 1–3 words. Use verbs: "Save", "Delete", "Apply".
4. **Provide tooltips** for IconButtons since they have no visible label.
5. **Respect disabled state.** Don't hide buttons — disable them and explain why via tooltip.
