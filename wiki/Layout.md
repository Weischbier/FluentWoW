# Layout

FluentWoW provides a `StackLayout` control that automatically arranges child frames in a vertical or horizontal stack — equivalent to WinUI's `StackPanel`.

---

## StackLayout

Automatically positions child frames sequentially in a vertical (`VStack`) or horizontal (`HStack`) orientation, with configurable gap and padding.

### Creation

```lua
-- Vertical stack (default)
local vstack = FluentWoW:CreateStackLayout(parent, "SettingsStack", "VERTICAL")
vstack:SetGap(8)
vstack:SetPadding(16, 16, 16, 16)
vstack:SetAllPoints(parent)

-- Add children
local btn1 = FluentWoW:CreateButton(vstack, nil, "Accent")
btn1:SetText("First")
vstack:AddChild(btn1)

local btn2 = FluentWoW:CreateButton(vstack, nil, "Subtle")
btn2:SetText("Second")
vstack:AddChild(btn2)

local btn3 = FluentWoW:CreateButton(vstack, nil, "Subtle")
btn3:SetText("Third")
vstack:AddChild(btn3)
```

```lua
-- Horizontal stack
local hstack = FluentWoW:CreateStackLayout(parent, "ButtonRow", "HORIZONTAL")
hstack:SetGap(12)
hstack:SetPoint("BOTTOM", parent, "BOTTOM", 0, 16)

local cancel = FluentWoW:CreateButton(hstack, nil, "Subtle")
cancel:SetText("Cancel")
hstack:AddChild(cancel)

local save = FluentWoW:CreateButton(hstack, nil, "Accent")
save:SetText("Save")
hstack:AddChild(save)
```

### API

| Method | Parameters | Returns | Description |
|---|---|---|---|
| `AddChild(child)` | `Frame` | — | Add a child frame and re-layout |
| `RemoveChild(child)` | `Frame` | — | Remove a child frame and re-layout |
| `GetChildren()` | — | `table` | Get the ordered children array |
| `SetOrientation(orient)` | `"VERTICAL"\|"HORIZONTAL"` | — | Set stack direction |
| `SetGap(gap)` | `number` | — | Pixels between children |
| `SetPadding(t, r, b, l)` | `number, number, number, number` | — | Container padding (top, right, bottom, left) |
| `Refresh()` | — | — | Force a re-layout of all children |

### Factory

```lua
FluentWoW:CreateStackLayout(parent, name?, orientation?)
```

- `parent` — parent frame
- `name` — optional global name
- `orientation` — `"VERTICAL"` (default) or `"HORIZONTAL"`

### Layout Behaviour

- **Vertical:** Children are stacked top-to-bottom. Each child is anchored `TOPLEFT` → `TOPRIGHT` (full width minus padding). Y offset accumulates by child height + gap.
- **Horizontal:** Children are stacked left-to-right. Each child keeps its own width. X offset accumulates by child width + gap.
- `Refresh()` is called automatically after `AddChild()` and `RemoveChild()`.
- Hidden children are skipped during layout.
- Call `Refresh()` manually if you change a child's size or visibility outside of the add/remove API.

### Example — Settings Panel

```lua
local lib = FluentWoW

local stack = lib:CreateStackLayout(content, nil, "VERTICAL")
stack:SetGap(4)
stack:SetPadding(0, 0, 0, 0)
stack:SetAllPoints(content)

-- Each settings card stretches to full width
local card1 = lib:CreateSettingsCard(stack)
card1:SetTitle("Option A")
card1:SetDescription("Description of option A.")
stack:AddChild(card1)

local card2 = lib:CreateSettingsCard(stack)
card2:SetTitle("Option B")
card2:SetDescription("Description of option B.")
stack:AddChild(card2)

-- Expander with nested cards
local exp = lib:CreateSettingsExpander(stack)
exp:SetTitle("Advanced")
exp:SetDescription("More options")
stack:AddChild(exp)

local advCard = lib:CreateSettingsCard(exp:GetContentFrame())
advCard:SetTitle("Debug Mode")
exp:AddCard(advCard)
```

### Token Integration

Use spacing tokens for consistent gaps:

```lua
stack:SetGap(FluentWoW.Tokens:GetSpacing("MD"))      -- 8px
stack:SetPadding(
    FluentWoW.Tokens:GetSpacing("XL"),   -- 16
    FluentWoW.Tokens:GetSpacing("XL"),   -- 16
    FluentWoW.Tokens:GetSpacing("XL"),   -- 16
    FluentWoW.Tokens:GetSpacing("XL")    -- 16
)
```
