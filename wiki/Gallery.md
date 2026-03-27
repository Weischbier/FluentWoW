# Gallery

FluentWoW ships with an interactive showcase addon (**FluentWoW-Gallery**) that demonstrates every control in a live, browsable interface.

---

## Opening the Gallery

```
/wuil
```

Type `/wuil` in the WoW chat box to toggle the gallery window open or closed.

---

## Installation

The gallery is a separate addon that depends on FluentWoW:

```
Interface/AddOns/
├── FluentWoW/            ← required library
└── FluentWoW-Gallery/    ← the gallery addon
```

Both must be in your AddOns folder. The Gallery's TOC declares `Dependencies: FluentWoW`.

---

## Pages

The gallery organises controls into five themed pages:

| Page | File | Controls Demonstrated |
|---|---|---|
| **Button** | `Pages/ButtonPage.lua` | Button (Accent, Subtle, Destructive), IconButton, ToggleButton |
| **Input** | `Pages/InputPage.lua` | CheckBox, RadioButton, ToggleSwitch, TextBox, SearchBox, Slider, ComboBox |
| **Feedback** | `Pages/FeedbackPage.lua` | ProgressBar, ProgressRing, InfoBar, ContentDialog |
| **Layout** | `Pages/LayoutPage.lua` | StackLayout (VStack / HStack), Expander, TabView, ScrollFrame |
| **Settings** | `Pages/SettingsPage.lua` | SettingsCard, SettingsExpander |

Each page contains:
- Live, interactive examples of each control variant
- Multiple configurations (e.g. all severities for InfoBar, all styles for Button)
- Example code context via titles and descriptions

---

## UI Structure

The gallery is built entirely with FluentWoW controls:

```
MainFrame (1000×700)
├── Title Bar
│   ├── ← Back button (left slot)
│   └── SearchBox (right slot, filters nav)
├── Sidebar (220px, left)
│   └── Nav buttons (one per page)
└── Content Area (right)
    └── Active page (lazy-built on first select)
```

- **MainFrame** — `FluentWoW:CreateMainFrame("WUILGalleryFrame", "FluentWoW Gallery")`
- **Navigation** — sidebar buttons filter by the search box in the title bar
- **Pages** — lazy-built on first visit for fast startup
- **Scrolling** — pages use `ScrollFrame` with `StackLayout` for vertical content flow

---

## Page Building Utilities

Gallery pages use shared helper methods for consistent layout:

| Method | Description |
|---|---|
| `Gallery:CreateDemoPage(parent)` | Returns `scroll, content, stack, refresh` — a standard scrollable page layout |
| `Gallery:CreateSurface(parent, colorKey)` | Creates a coloured background surface frame |
| `Gallery:CreateExampleBlock(parent, header, height)` | Creates a titled section block |
| `Gallery:RegisterPage(key, title, builder)` | Registers a new page with the gallery |

### Page Registration

Each page file self-registers:

```lua
Gallery:RegisterPage("button", "Button", function(parent)
    local scroll, content, stack, refresh = Gallery:CreateDemoPage(parent)
    -- ... build demo controls ...
    refresh()
    return scroll
end)
```

---

## Adding a Custom Gallery Page

If you're extending FluentWoW and want to add a gallery page for testing:

```lua
local Gallery = FluentWoW._gallery

Gallery:RegisterPage("mycontrol", "My Control", function(parent)
    local scroll, content, stack, refresh = Gallery:CreateDemoPage(parent)

    -- Add demo controls
    local demo = FluentWoW:CreateButton(stack, nil, "Accent")
    demo:SetText("My Demo Button")
    stack:AddChild(demo)

    refresh()
    return scroll
end)
```

The page will appear in the sidebar navigation automatically.

---

## Screenshots

Open the gallery in-game with `/wuil` to see:
- All button variants side by side
- Interactive input controls with live state feedback
- All four InfoBar severities
- ContentDialog with overlay
- Expand/collapse animations on Expanders
- Settings page with cards and expanders
- Theme switching between dark and light modes
