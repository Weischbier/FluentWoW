# API Reference

Quick-reference table of every FluentWoW factory method. All methods are called on the `FluentWoW` global (or `LibStub("FluentWoW-1.0")`).

---

## Factory Methods

### Buttons

| Method | Signature | Returns |
| --- | --- | --- |
| `CreateButton` | `(parent, name?, style?)` | `WUILButton` |
| `CreateIconButton` | `(parent, name?)` | `WUILIconButton` |
| `CreateToggleButton` | `(parent, name?)` | `WUILToggleButton` |

`style`: `nil` (Accent), `"Subtle"`, `"Destructive"`

### Input

| Method | Signature | Returns |
| --- | --- | --- |
| `CreateCheckBox` | `(parent, name?)` | `WUILCheckBox` |
| `CreateRadioButton` | `(parent, name?)` | `WUILRadioButton` |
| `CreateToggleSwitch` | `(parent, name?)` | `WUILToggleSwitch` |
| `CreateTextBox` | `(parent, name?)` | `WUILTextBox` |
| `CreateSearchBox` | `(parent, name?)` | `WUILTextBox` |
| `CreateSlider` | `(parent, name?)` | `WUILSlider` |
| `CreateComboBox` | `(parent, name?)` | `WUILComboBox` |

### Text

| Method | Signature | Returns |
| --- | --- | --- |
| `CreateTextBlock` | `(parent, name?)` | `WUILTextBlock` |

### Feedback

| Method | Signature | Returns |
| --- | --- | --- |
| `CreateProgressBar` | `(parent, name?)` | `WUILProgressBar` |
| `CreateProgressRing` | `(parent, name?)` | `WUILProgressRing` |
| `CreateInfoBar` | `(parent, name?)` | `WUILInfoBar` |
| `CreateContentDialog` | `(parent?, name?)` | `WUILContentDialog` |

`ContentDialog` defaults to `UIParent` if parent is nil.

### Navigation

| Method | Signature | Returns |
| --- | --- | --- |
| `CreateTabView` | `(parent, name?)` | `WUILTabView` |
| `CreateExpander` | `(parent, name?)` | `WUILExpander` |
| `CreateScrollFrame` | `(parent, name?)` | `WUILScrollFrame` |
| `CreateMainFrame` | `(name?, title?)` | `WUILMainFrame` |

**Note:** `CreateMainFrame` takes `(name, title)` — no parent parameter. Always parents to `UIParent`.

### Layout

| Method | Signature | Returns |
| --- | --- | --- |
| `CreateStackLayout` | `(parent, name?, orientation?)` | `WUILStackLayout` |

`orientation`: `"VERTICAL"` (default) or `"HORIZONTAL"`

### Settings

| Method | Signature | Returns |
| --- | --- | --- |
| `CreateSettingsCard` | `(parent, name?)` | `WUILSettingsCard` |
| `CreateSettingsExpander` | `(parent, name?)` | `WUILSettingsExpander` |

---

## Parameters Glossary

| Parameter | Type | Description |
| --- | --- | --- |
| `parent` | `Frame` | WoW frame to parent the new control to |
| `name` | `string?` | Optional global name for the frame |
| `style` | `string?` | Button style variant |
| `orientation` | `string?` | Stack direction |
| `title` | `string?` | Window title (MainFrame) |

---

## Module Access

| Module | Access | Description |
| --- | --- | --- |
| Tokens | `FluentWoW.Tokens` | [Token registry](Token-System) |
| Motion | `FluentWoW.Motion` | [Animation engine](Motion-and-Animation) |
| EventBus | `FluentWoW.EventBus` | [Pub/sub events](Core-Modules#eventbus) |
| StateMachine | `FluentWoW.StateMachine` | [Visual state machine](Core-Modules#statemachine) |
| FramePool | `FluentWoW.FramePool` | [Frame recycling](Core-Modules#framepool) |
| Utils | `FluentWoW.Utils` | [Utility functions](Core-Modules#utils) |
| Icons | `FluentWoW.Icons` | [Icon glyph map](Icons) |

---

## Token Retrieval

| Method | Signature | Returns |
| --- | --- | --- |
| `Tokens:Get(key)` | `(string)` | `any` |
| `Tokens:GetColor(key)` | `(string)` | `r, g, b, a` |
| `Tokens:GetSpacing(key)` | `(string)` | `number` |
| `Tokens:GetFont(key)` | `(string)` | `font, size, flags` |
| `Tokens:GetNumber(key)` | `(string)` | `number` |

---

## Theme Management

| Method | Signature | Description |
| --- | --- | --- |
| `Tokens:RegisterTheme(name, tokens)` | `(string, table)` | Register a theme |
| `Tokens:SetTheme(name)` | `(string)` | Activate a theme |
| `Tokens:GetThemeName()` | — | Current theme name |
| `Tokens:GetAvailableThemes()` | — | `{name = true}` set |
| `Tokens:Override(overrides)` | `(table)` | Apply runtime overrides |
