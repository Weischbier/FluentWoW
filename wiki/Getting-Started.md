# Getting Started

This guide walks you through adding FluentWoW to your addon and creating your first controls.

---

## Prerequisites

- **World of Warcraft** retail client (Interface 120005 or 120001)
- A working WoW addon directory (typically `Interface/AddOns/`)
- FluentWoW must be installed as its own addon folder alongside yours

---

## Installation

### Option A — Manual (development)

1. Clone or download the FluentWoW repository
2. Copy the `FluentWoW/` folder into your `Interface/AddOns/` directory
3. (Optional) Copy `FluentWoW-Gallery/` too if you want the interactive showcase

```
Interface/AddOns/
├── FluentWoW/          ← the library
├── FluentWoW-Gallery/  ← optional showcase
└── YourAddon/          ← your addon
```

### Option B — BigWigs Packager / CurseForge

Add FluentWoW as a dependency in your `.pkgmeta`:

```yaml
dependencies:
  - FluentWoW
```

---

## Declare the Dependency

In your addon's `.toc` file, declare FluentWoW as a required dependency:

```toc
## Interface: 120005
## Title: My Addon
## Dependencies: FluentWoW

MyAddon.lua
```

This ensures FluentWoW loads before your addon. The global `FluentWoW` table will be available by the time your code runs.

---

## Access the Library

FluentWoW follows the standard Ace3 library pattern. Access it via **LibStub**:

```lua
local FluentWoW = LibStub("FluentWoW-1.0")
```

### AceAddon Embed (optional)

If your addon uses AceAddon, you can embed FluentWoW directly. All `Create*` factory methods, `Tokens`, `EventBus`, and `Motion` are mixed into your addon table automatically:

```lua
local MyAddon = LibStub("AceAddon-3.0"):NewAddon("MyAddon", "FluentWoW-1.0")

function MyAddon:OnInitialize()
    -- All FluentWoW methods are available on self
    local frame = self:CreateMainFrame("MyAddonFrame", "My Addon")
    local content = frame:GetContentArea()
    local btn = self:CreateButton(content, nil, "Accent")
    btn:SetText("Hello from Ace3!")
end
```

### Consumer .pkgmeta

If you ship FluentWoW bundled inside your addon (Ace3 embed style), add it as an external in your `.pkgmeta`:

```yaml
externals:
  MyAddon/Libs/FluentWoW: https://github.com/Weischbier/FluentWoW.git
```

Otherwise, just list FluentWoW as a dependency in your TOC and let users install it separately.

---

## MainFrame — The Required Root

> **Every FluentWoW control must live inside a MainFrame.**
>
> `CreateMainFrame()` is the entry point for all FluentWoW UIs. It provides the
> application window shell (title bar, resize handles, status bar, ESC-to-close,
> combat-safe show/hide, theme propagation, and position persistence). Controls
> created outside a MainFrame hierarchy will produce a debug warning.
>
> The only exceptions are **ContentDialog** and **TeachingTip**, which are
> fullscreen overlays that attach to UIParent by design.

```lua
local FluentWoW = LibStub("FluentWoW-1.0")

-- Step 1: Always create a MainFrame first
local frame = FluentWoW:CreateMainFrame("MyAddonFrame", "My Addon")

-- Step 2: Get its content area — this is where your controls go
local content = frame:GetContentArea()

-- Step 3: Create controls inside the MainFrame hierarchy
local btn = FluentWoW:CreateButton(content, nil, "Accent")
btn:SetText("Click Me")
btn:SetPoint("CENTER")
btn:SetOnClick(function(self, mouseButton)
    print("Button clicked!")
end)

-- Step 4: Open the window
frame:Open()
```

---

## Your First Control

### A Simple Button

```lua
local FluentWoW = LibStub("FluentWoW-1.0")

-- Create the MainFrame (required root for all controls)
local frame = FluentWoW:CreateMainFrame("MyAddonFrame", "My Addon")
local content = frame:GetContentArea()

-- Create an accent button inside the MainFrame
local btn = FluentWoW:CreateButton(content, nil, "Accent")
btn:SetText("Click Me")
btn:SetPoint("CENTER")
btn:SetOnClick(function(self, mouseButton)
    print("Button clicked!")
end)

frame:Open()
```

### A Toggle Switch with Header

```lua
local content = frame:GetContentArea()

local toggle = FluentWoW:CreateToggleSwitch(content)
toggle:SetHeader("Enable Feature")
toggle:SetOnContent("Enabled")
toggle:SetOffContent("Disabled")
toggle:SetPoint("CENTER", content, "CENTER", 0, -40)
toggle:SetOnToggled(function(self, isOn)
    print("Toggle is now:", isOn)
end)
```

### A Settings Card

```lua
local content = frame:GetContentArea()

-- Create a toggle switch as the action control
local ts = FluentWoW:CreateToggleSwitch(content)
ts:SetOnContent("On")
ts:SetOffContent("Off")

-- Create a settings card with the toggle embedded
local card = FluentWoW:CreateSettingsCard(content)
card:SetTitle("Enable Notifications")
card:SetDescription("Show popup notifications for important events.")
card:SetActionControl(ts)
card:SetPoint("TOP", content, "TOP", 0, -20)
card:SetSize(360, 0)  -- height auto-adjusts
```

---

## Building a Complete Settings Panel

Here's a more realistic example — a full settings panel using MainFrame, StackLayout, and Settings controls:

```lua
local FluentWoW = LibStub("FluentWoW-1.0")

-- Create the main window
local frame = FluentWoW:CreateMainFrame("MyAddonSettings", "My Addon \u2014 Settings")

-- Get the content area
local content = frame:GetContentArea()

-- Create a vertical stack for layout
local stack = FluentWoW:CreateStackLayout(content, nil, "VERTICAL")
stack:SetGap(8)
stack:SetPadding(16, 16, 16, 16)
stack:SetAllPoints(content)

-- Settings card 1: Toggle feature
local ts1 = FluentWoW:CreateToggleSwitch(stack)
ts1:SetOnContent("On")
ts1:SetOffContent("Off")

local card1 = FluentWoW:CreateSettingsCard(stack)
card1:SetTitle("Auto-Track")
card1:SetDescription("Automatically track new quests when they are accepted.")
card1:SetActionControl(ts1)
card1:SetSize(0, 0)
stack:AddChild(card1)

-- Settings card 2: Dropdown
local cb = FluentWoW:CreateComboBox(stack)
cb:SetItems({
    { text = "Small",  value = 0.8 },
    { text = "Normal", value = 1.0 },
    { text = "Large",  value = 1.2 },
})
cb:SetSelectedIndex(2)

local card2 = FluentWoW:CreateSettingsCard(stack)
card2:SetTitle("UI Scale")
card2:SetDescription("Adjust the overall size of the interface.")
card2:SetActionControl(cb)
card2:SetSize(0, 0)
stack:AddChild(card2)

-- Settings card 3: Slider
local sl = FluentWoW:CreateSlider(stack)
sl:SetRange(0, 100)
sl:SetValue(75)
sl:SetStep(5)
sl:SetShowValue(true)

local card3 = FluentWoW:CreateSettingsCard(stack)
card3:SetTitle("Opacity")
card3:SetDescription("Set the transparency of the frame.")
card3:SetActionControl(sl)
card3:SetSize(0, 0)
stack:AddChild(card3)

-- Open the window
frame:Open()
```

---

## Using Tokens for Consistent Styling

If you need to style custom frames to match FluentWoW's design language:

```lua
local FluentWoW = LibStub("FluentWoW-1.0")
local T = FluentWoW.Tokens

-- Get a colour (returns r, g, b, a)
local r, g, b, a = T:GetColor("Color.Accent.Primary")

-- Get spacing (returns number)
local gap = T:GetSpacing("MD")  -- 8

-- Get font info (returns path, size, flags)
local font, size, flags = T:GetFont("Body")

-- Apply to a custom frame
myFrame:SetBackdropColor(T:GetColor("Color.Surface.Raised"))
myFontString:SetFont(T:GetFont("Title"))
myFontString:SetTextColor(T:GetColor("Color.Text.Primary"))
```

---

## Responding to Theme Changes

If you create custom UI elements and want them to update when the theme changes:

```lua
FluentWoW.EventBus:On("ThemeChanged", function(themeName)
    -- Re-apply your token-based styling here
    myFrame:SetBackdropColor(FluentWoW.Tokens:GetColor("Color.Surface.Base"))
end)
```

---

## Next Steps

- Browse the **[Controls Overview](Controls-Overview)** to see everything available
- Check the **[Token System](Token-System)** for the full token reference
- Read about **[Theming](Theming)** to create your own colour scheme
- Open the **[Gallery](Gallery)** in-game with `/fwow` to see live demos
