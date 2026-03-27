# Feedback Controls

Controls for communicating status, progress, and modal decisions to the user.

---

## ProgressBar

A horizontal bar indicating determinate (0–100%) or indeterminate (looping) progress. Supports Running, Paused, and Error visual states.

**WinUI reference:** [ProgressBar](https://learn.microsoft.com/windows/apps/design/controls/progress-controls)

### Creation

```lua
-- Determinate progress
local pb = FluentWoW:CreateProgressBar(parent, "DownloadProgress")
pb:SetHeader("Downloading...")
pb:SetValue(0)

-- Update as work progresses
pb:SetValue(42)

-- Indeterminate (unknown duration)
local loading = FluentWoW:CreateProgressBar(parent, "LoadingBar")
loading:SetIndeterminate(true)
```

### API

| Method | Parameters | Returns | Description |
| --- | --- | --- | --- |
| `SetValue(value)` | `number` | — | Set progress 0–100 (switches to determinate) |
| `GetValue()` | — | `number` | Get current progress value |
| `SetIndeterminate(isInd)` | `boolean` | — | Toggle indeterminate animation |
| `SetHeader(text)` | `string` | — | Set header label text |
| `SetVisualState(state)` | `"Running"\|"Paused"\|"Error"` | — | Set visual state |
| `SetPaused(paused)` | `boolean` | — | Shorthand for `SetVisualState("Paused")` |
| `SetError(hasError)` | `boolean` | — | Shorthand for `SetVisualState("Error")` |

### Visual States

| State | Behaviour |
| --- | --- |
| `Running` | Normal accent-coloured fill |
| `Paused` | Yellow/warning fill colour |
| `Error` | Red/error fill colour |
| `Indeterminate` | Animated looping fill bar |

---

## ProgressRing

A spinning activity indicator for use when space is limited or progress percentage is unknown.

### Creation

```lua
local ring = FluentWoW:CreateProgressRing(parent, "Spinner")
ring:SetPoint("CENTER")
ring:SetActive(true)

-- Stop when done
ring:SetActive(false)
```

### API

| Method | Parameters | Returns | Description |
| --- | --- | --- | --- |
| `SetActive(active)` | `boolean` | — | Start/stop spinning |
| `IsActive()` | — | `boolean` | Check if spinning |

---

## InfoBar

A non-modal notification bar with four severity levels, title, message, optional close button and action control. Equivalent to WinUI's `InfoBar`.

**WinUI reference:** [InfoBar](https://learn.microsoft.com/windows/apps/design/controls/infobar)

### Creation

```lua
local info = FluentWoW:CreateInfoBar(parent, "UpdateInfo")
info:SetSeverity("Success")
info:SetTitle("Update Complete")
info:SetMessage("All settings have been saved successfully.")
info:SetClosable(true)
info:SetPoint("TOP", parent, "TOP", 0, -8)
info:SetSize(400, 0)  -- height auto-sizes
info:Open()

-- With an action button
local actionBtn = FluentWoW:CreateButton(info, nil, "Subtle")
actionBtn:SetText("Undo")
actionBtn:SetOnClick(function() MyAddon:Undo() end)
info:SetActionControl(actionBtn)
```

### Severities

| Severity | Icon | Background Colour Token |
| --- | --- | --- |
| `"Info"` | Information circle | `Color.Feedback.Info` |
| `"Success"` | Checkmark circle | `Color.Feedback.Success` |
| `"Warning"` | Warning triangle | `Color.Feedback.Warning` |
| `"Error"` | Error circle | `Color.Feedback.Error` |

### API

| Method | Parameters | Returns | Description |
| --- | --- | --- | --- |
| `SetSeverity(severity)` | `string` | — | `"Info"` / `"Success"` / `"Warning"` / `"Error"` |
| `GetSeverity()` | — | `string` | Current severity |
| `SetTitle(text)` | `string` | — | Bold title text |
| `SetMessage(text)` | `string` | — | Body message text |
| `SetClosable(show)` | `boolean` | — | Show/hide close (×) button |
| `SetIconVisible(show)` | `boolean` | — | Show/hide severity icon |
| `SetActionControl(ctrl)` | `Frame\|nil` | — | Embed an action control |
| `SetIcon(iconName)` | `string` | — | Override the severity icon |
| `Open()` | — | — | Fade in with animation |
| `Close()` | — | — | Fade out, then fires `OnClosed` |
| `SetOnClosed(fn)` | `function(self)` | — | Fires after close animation |

---

## ContentDialog

A modal dialog with an overlay scrim, title, body text, and up to two action buttons (primary + secondary). Equivalent to WinUI's `ContentDialog`.

**WinUI reference:** [ContentDialog](https://learn.microsoft.com/windows/apps/design/controls/dialogs-and-flyouts/dialogs)

### Creation

```lua
local dialog = FluentWoW:CreateContentDialog(UIParent, "ConfirmDelete")
dialog:SetTitle("Delete Character?")
dialog:SetBody("This will permanently delete your character data. This action cannot be undone.")
dialog:SetPrimaryButton("Delete", function(self)
    MyAddon:DeleteCharacter()
end)
dialog:SetSecondaryButton("Cancel")
dialog:SetOnClosed(function(self, result)
    -- result: "Primary" | "Secondary" | "Close" | "Overlay"
    print("Dialog closed with:", result)
end)
dialog:Open()
```

### API

| Method | Parameters | Returns | Description |
| --- | --- | --- | --- |
| `SetTitle(title)` | `string` | — | Dialog title text |
| `SetBody(body)` | `string` | — | Body text (word-wrapped) |
| `SetPrimaryButton(text, cb?)` | `string, function?` | — | Primary button text + optional callback |
| `SetSecondaryButton(text, cb?)` | `string, function?` | — | Secondary button text + optional callback |
| `SetClosable(closable)` | `boolean` | — | Show/hide × close button |
| `SetDismissOnOverlay(dismiss)` | `boolean` | — | Close when clicking overlay |
| `Open()` | — | — | Show with fade + slide animation |
| `Close(result?)` | `string?` | — | Close; result sent to `OnClosed` |
| `SetOnClosed(fn)` | `function(self, result)` | — | Close callback with result string |

### Close Results

| Result | Trigger |
| --- | --- |
| `"Primary"` | Primary button clicked |
| `"Secondary"` | Secondary button clicked |
| `"Close"` | × button or ESC key |
| `"Overlay"` | Clicked outside dialog (if `SetDismissOnOverlay(true)`) |

### Combat Safety

`Open()` is blocked during `InCombatLockdown()`. The dialog defaults to parenting to `UIParent` if no parent is specified.

### Animation

Opens with a combined fade-in + slide-up entrance. Closes with a fade-out exit. Durations are controlled by `Motion.Duration.Entrance` (250ms) and `Motion.Duration.Exit` (150ms) tokens.
