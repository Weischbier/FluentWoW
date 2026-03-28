# Controls Overview

FluentWoW provides 30+ controls across 7 categories, each faithfully adapted from WinUI 3 and the Windows Community Toolkit for the WoW addon platform.

---

## Control Catalog

### Foundational

| Control | Template | Factory | Description |
| --- | --- | --- | --- |
| Button (Accent) | `WUILButtonTemplate` | `CreateButton(parent, name, "Accent")` | Primary action button |
| Button (Subtle) | `WUILButtonSubtleTemplate` | `CreateButton(parent, name, "Subtle")` | Secondary / low-emphasis button |
| Button (Destructive) | `WUILButtonDestructiveTemplate` | `CreateButton(parent, name, "Destructive")` | Dangerous / irreversible action |
| IconButton | `WUILIconButtonTemplate` | `CreateIconButton(parent, name)` | Square button with icon only |
| ToggleButton | `WUILToggleButtonTemplate` | `CreateToggleButton(parent, name)` | Button with checked/unchecked state |
| TextBlock | `WUILTextBlockTemplate` | `CreateTextBlock(parent, name)` | Styled text label (7 typography styles) |

→ **[Button page](Button)** · **[TextBlock reference](Input-Controls#textblock)**

### Data Entry

| Control | Template | Factory | Description |
| --- | --- | --- | --- |
| CheckBox | `WUILCheckBoxTemplate` | `CreateCheckBox(parent, name)` | Two-state or three-state checkbox |
| RadioButton | `WUILRadioButtonTemplate` | `CreateRadioButton(parent, name)` | Mutual-exclusion radio within groups |
| ToggleSwitch | `WUILToggleSwitchTemplate` | `CreateToggleSwitch(parent, name)` | On/off toggle with sliding thumb |
| TextBox | `WUILTextBoxTemplate` | `CreateTextBox(parent, name)` | Single/multi-line text input |
| SearchBox | `WUILSearchBoxTemplate` | `CreateSearchBox(parent, name)` | TextBox variant with search icon |
| Slider | `WUILSliderTemplate` | `CreateSlider(parent, name)` | Range slider with ticks and value label |
| ComboBox | `WUILComboBoxTemplate` | `CreateComboBox(parent, name)` | Dropdown selection list |

→ **[Input Controls page](Input-Controls)**

### Feedback & Status

| Control | Template | Factory | Description |
| --- | --- | --- | --- |
| ProgressBar | `WUILProgressBarTemplate` | `CreateProgressBar(parent, name)` | Determinate + indeterminate progress |
| ProgressRing | `WUILProgressRingTemplate` | `CreateProgressRing(parent, name)` | Spinning activity indicator |
| InfoBar | `WUILInfoBarTemplate` | `CreateInfoBar(parent, name)` | Severity-coloured notification bar |
| ContentDialog | `WUILContentDialogTemplate` | `CreateContentDialog(parent, name)` | Modal dialog with overlay |

→ **[Feedback Controls page](Feedback-Controls)**

### Navigation & Chrome

| Control | Template | Factory | Description |
| --- | --- | --- | --- |
| TabView | `WUILTabViewTemplate` | `CreateTabView(parent, name)` | Tabbed content container |
| Expander | `WUILExpanderTemplate` | `CreateExpander(parent, name)` | Collapsible section with animation |
| ScrollFrame | `WUILScrollFrameTemplate` | `CreateScrollFrame(parent, name)` | Scrollable content area with thumb |
| MainFrame | `WUILMainFrameTemplate` | `CreateMainFrame(name, title)` | Top-level application window |

→ **[Navigation Controls page](Navigation-Controls)**

### Advanced

| Control | Template | Factory | Description |
| --- | --- | --- | --- |
| NavigationView | `FWoWNavigationViewTemplate` | `CreateNavigationView(parent, name)` | Sidebar navigation with collapsible pane |
| BreadcrumbBar | `FWoWBreadcrumbBarTemplate` | `CreateBreadcrumbBar(parent, name)` | Horizontal breadcrumb path trail |
| NumberBox | `FWoWNumberBoxTemplate` | `CreateNumberBox(parent, name)` | Validated numeric input with spin buttons |
| TeachingTip | `FWoWTeachingTipTemplate` | `CreateTeachingTip(parent, name)` | Contextual teaching callout / coach mark |
| CommandBar | `FWoWCommandBarTemplate` | `CreateCommandBar(parent, name)` | Toolbar with primary + overflow commands |
| SegmentedControl | `FWoWSegmentedControlTemplate` | `CreateSegmentedControl(parent, name)` | Mutually exclusive segmented selector |
| Badge | `FWoWBadgeTemplate` | `CreateBadge(parent, name, appearance)` | Compact status pill / badge indicator |
| EmptyState | `FWoWEmptyStateTemplate` | `CreateEmptyState(parent, name)` | Placeholder for empty content areas |
| Skeleton | `FWoWSkeletonTemplate` | `CreateSkeleton(parent, name, shape)` | Animated shimmer loading placeholder |

→ **[Advanced Controls page](Advanced-Controls)**

### Layout

| Control | Template | Factory | Description |
| --- | --- | --- | --- |
| StackLayout | `WUILStackLayoutTemplate` | `CreateStackLayout(parent, name, orient)` | VStack / HStack auto-layout |

→ **[Layout page](Layout)**

### Settings (Community Toolkit)

| Control | Template | Factory | Description |
| --- | --- | --- | --- |
| SettingsCard | `WUILSettingsCardTemplate` | `CreateSettingsCard(parent, name)` | Settings row with title + action |
| SettingsExpander | `WUILSettingsExpanderTemplate` | `CreateSettingsExpander(parent, name)` | Expandable settings group |

→ **[Settings Controls page](Settings-Controls)**

---

## Shared Control Behaviour

Every FluentWoW control inherits from `ControlBase`, which provides:

| Method | Description |
| --- | --- |
| `SetEnabled(enabled)` | Enable or disable the control (greys out, blocks interaction) |
| `IsEnabled()` | Returns `true` if the control is enabled |
| `SetTooltip(title, text?)` | Set tooltip title and optional body text |
| `ShowTooltip()` | Programmatically show the tooltip |
| `Token(key)` | Shorthand for `FluentWoW.Tokens:Get(key)` |
| `GetState()` | Returns the current visual state name |

### Visual State Machine

Every control has an internal `_vsm` (Visual State Machine) that tracks states like `Normal`, `Hover`, `Pressed`, `Disabled`, `Checked`, `Expanded`, etc. State transitions happen automatically in response to user interaction. Controls override `OnStateChanged(newState, prevState)` to update their visuals.

---

## Combat Safety

FluentWoW respects WoW's combat lockdown system:

- **All controls** can be read safely during combat
- **Show/Hide** of secure frames is blocked during `InCombatLockdown()`
- **ComboBox** dropdown opening is blocked during combat
- **ContentDialog** `Open()` is blocked during combat
- **MainFrame** `Open()` is blocked during combat

Controls that are shown before combat continues to work; only new show/hide operations are deferred.

---

## Planned Controls (Phase 3+)\n\n- Virtualized list (true row recycling)\n- Grid layout container\n- Responsive width classes\n- Connected animation helpers
