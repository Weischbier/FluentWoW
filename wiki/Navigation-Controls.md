# Navigation Controls

Controls that provide structure, containment, and navigation for your addon's UI.

---

## MainFrame

The top-level application window — equivalent to Ace3's AceGUI "Frame" container but with WinUI design language. Features a title bar, close button, resize grippers, status bar, ESC-to-close, and customisable title-bar slots.

### Creation

```lua
local frame = FluentWoW:CreateMainFrame("MyAddonFrame", "My Addon")

-- Add content
local content = frame:GetContentArea()
local label = FluentWoW:CreateTextBlock(content)
label:SetText("Hello, FluentWoW!")
label:SetStyle("Title")
label:SetPoint("CENTER")

-- Customise title bar
local searchBox = FluentWoW:CreateSearchBox(frame)
frame:SetTitleBarRightControl(searchBox, 200)

-- Persist position/size across sessions
frame:SetStatusTable(MyAddonDB.frameStatus)

-- Open
frame:Open()
```

### API

| Method | Parameters | Returns | Description |
| --- | --- | --- | --- |
| `SetTitle(title)` | `string` | — | Window title text |
| `SetStatusText(text)` | `string` | — | Status bar text (bottom) |
| `SetIcon(path)` | `string` | — | Title bar icon texture path |
| `SetTitleBarLeftControl(ctrl, w?)` | `Frame?, number?` | — | Embed control in left title-bar slot |
| `SetTitleBarRightControl(ctrl, w?)` | `Frame?, number?` | — | Embed control in right title-bar slot |
| `GetTitleBarLeftArea()` | — | `Frame` | Left title-bar slot frame |
| `GetTitleBarRightArea()` | — | `Frame` | Right title-bar slot frame |
| `GetContentArea()` | — | `Frame` | Main content frame |
| `SetContentInsets(l?, r?, t?, b?)` | `number?` each | — | Content padding (defaults: 16, 16, 40, 28) |
| `Open()` | — | — | Show (blocked during combat) |
| `Close()` | — | — | Hide |
| `SetResizable(enabled)` | `boolean` | — | Toggle resize grippers |
| `SetStatusTable(tbl)` | `table` | — | Bind saved-variables for position/size persistence |
| `SetOnClose(fn)` | `function(self)` | — | Fires on hide |
| `SetOnShow(fn)` | `function(self)` | — | Fires on show |
| `SetOnResize(fn)` | `function(self, w, h)` | — | Fires on resize |

### Important Notes

- **Factory signature differs:** `CreateMainFrame(name, title)` — no `parent` parameter (always parents to `UIParent`)
- **Default size:** 700×500, minimum 400×300
- **Frame strata:** `FULLSCREEN_DIALOG`
- **ESC-to-close:** Auto-registered in `UISpecialFrames`
- **Draggable:** Title bar serves as drag handle
- **Resize grippers:** SE corner, south edge, east edge
- **Combat-safe:** `Open()` blocked during `InCombatLockdown()`
- **Theme listener:** Automatically re-applies token-based styling on theme change

---

## TabView

A tabbed content container. Each tab can have a label, icon, optional close button, and an associated content frame.

**WinUI reference:** [TabView](https://learn.microsoft.com/windows/apps/design/controls/tab-view)

### Creation

```lua
local tabs = FluentWoW:CreateTabView(parent, "SettingsTabs")
tabs:SetAllPoints(parent)

-- Define tabs
tabs:SetTabs({
    { text = "General",  icon = FluentWoW.Icons.Settings },
    { text = "Display",  icon = FluentWoW.Icons.Brightness },
    { text = "Advanced", icon = FluentWoW.Icons.DeveloperTools, closable = true },
})

-- React to tab changes
tabs:SetOnTabChanged(function(self, index)
    print("Switched to tab", index)
end)

-- Add tab button
tabs:SetAddButtonVisible(true)
tabs:SetOnAddTab(function(self)
    self:AddTab({ text = "New Tab", closable = true })
end)
```

### API

| Method | Parameters | Returns | Description |
| --- | --- | --- | --- |
| `SetTabs(tabs)` | `{text, content?, icon?, closable?}[]` | — | Set all tabs; selects first |
| `AddTab(tab)` | `table` | — | Append a tab and select it |
| `RemoveTab(index)` | `integer` | — | Remove tab by index |
| `SelectTab(index)` | `integer` | — | Select tab by index |
| `GetSelectedIndex()` | — | `integer?` | Current selected tab index |
| `SetAddButtonVisible(vis)` | `boolean` | — | Show/hide "+" add button |
| `SetTabStripHeader(ctrl, w?)` | `Frame?, number?` | — | Embed control in left strip slot |
| `SetTabStripFooter(ctrl, w?)` | `Frame?, number?` | — | Embed control in right strip slot |
| `SetTabWidthMode(mode)` | `"SizeToContent"\|"Equal"` | — | Tab sizing mode |
| `SetOnTabChanged(fn)` | `function(self, index)` | — | Tab change callback |
| `SetOnAddTab(fn)` | `function(self)` | — | Add button callback |
| `SetOnTabCloseRequested(fn)` | `function(self, index)` | — | Tab close request (if unset, removes directly) |

### Tab Items

Each tab item uses `WUILTabItemTemplate` and supports:
- `text` — tab label (required)
- `content` — pre-built content frame (optional; otherwise create on tab change)
- `icon` — Fluent icon glyph string or texture path
- `closable` — show an × button on the tab

---

## Expander

A collapsible section that reveals or hides a content area with a smooth height animation. Click the header to toggle.

**WinUI reference:** [Expander](https://learn.microsoft.com/windows/apps/design/controls/expander)

### Creation

```lua
local exp = FluentWoW:CreateExpander(parent, "AdvancedOptions")
exp:SetTitle("Advanced Options")
exp:SetContentHeight(150)
exp:SetPoint("TOP", parent, "TOP", 0, -16)
exp:SetSize(360, 0)

-- Add content to the expander's content frame
local content = exp:GetContentFrame()
local cb = FluentWoW:CreateCheckBox(content)
cb:SetText("Enable debug logging")
cb:SetPoint("TOPLEFT", 12, -12)

-- React to expand/collapse
exp:SetOnToggled(function(self, isExpanded)
    print("Expander is now", isExpanded and "open" or "closed")
end)

-- Start expanded
exp:SetExpanded(true, true)  -- instant, no animation
```

### API

| Method | Parameters | Returns | Description |
| --- | --- | --- | --- |
| `SetTitle(text)` | `string` | — | Header text |
| `GetTitle()` | — | `string` | Get header text |
| `SetExpanded(exp, instant?)` | `boolean, boolean?` | — | Expand/collapse (with animation unless instant) |
| `IsExpanded()` | — | `boolean` | Check expanded state |
| `SetContentHeight(h)` | `number` | — | Set content area height |
| `GetContentFrame()` | — | `Frame` | Content frame for embedding children |
| `SetOnToggled(fn)` | `function(self, expanded)` | — | Toggle callback |

### Visual States

`Normal` → `Hover` → `Expanded` → `Disabled`

The expand/collapse animation uses `Motion:HeightTo()` with the standard entrance/exit duration tokens.

---

## ScrollFrame

A scrollable content area with a custom-styled scroll thumb. Supports mouse-wheel scrolling and thumb dragging.

### Creation

```lua
local scroll = FluentWoW:CreateScrollFrame(parent, "ContentScroll")
scroll:SetAllPoints(parent)

-- Get the scroll child
local child = scroll:GetScrollChild()

-- Add content that exceeds the visible area
for i = 1, 50 do
    local line = FluentWoW:CreateTextBlock(child)
    line:SetText("Line " .. i)
    line:SetStyle("Body")
    line:SetPoint("TOPLEFT", 8, -((i - 1) * 20))
end

-- Set total content height
scroll:SetContentHeight(50 * 20)
```

### API

| Method | Parameters | Returns | Description |
| --- | --- | --- | --- |
| `GetScrollChild()` | — | `Frame` | Scroll child for embedding content |
| `SetContentHeight(h)` | `number` | — | Set total content height |
| `SetScrollOffset(offset)` | `number` | — | Set vertical scroll position |
| `GetScrollOffset()` | — | `number` | Get vertical scroll position |

### Interaction

- **Mouse wheel:** 40px per scroll step
- **Thumb drag:** Click and drag the scroll thumb
- **Auto-hide:** Thumb hides when content fits within the visible area

---

## NavigationView

A sidebar navigation control with a collapsible pane, selection indicator, and content area. The pane can toggle between expanded (200px) and collapsed (48px icon-only) modes with smooth animation.

**WinUI reference:** [NavigationView](https://learn.microsoft.com/windows/apps/design/controls/navigationview)

### Creation

```lua
local nav = FluentWoW:CreateNavigationView(parent, "MyNav")
nav:SetAllPoints(parent)

-- Define navigation items
nav:SetItems({
    { key = "home",     icon = FluentWoW.Icons.Home,     text = "Home" },
    { key = "settings", icon = FluentWoW.Icons.Settings, text = "Settings" },
    { key = "about",    icon = FluentWoW.Icons.Info,     text = "About" },
})

-- React to selection changes
nav:SetOnSelectionChanged(function(self, key, index)
    print("Selected:", key)
end)

-- Embed content per page
local contentArea = nav:GetContentArea()
```

### API

| Method | Parameters | Returns | Description |
| --- | --- | --- | --- |
| `SetItems(items)` | `{key, icon?, text}[]` | — | Set navigation items |
| `SelectItem(key)` | `string` | — | Select item by key |
| `SetPaneExpanded(exp)` | `boolean` | — | Expand/collapse sidebar pane |
| `SetItemContent(key, frame)` | `string, Frame` | — | Assign content frame for a nav key |
| `GetContentArea()` | — | `Frame` | Content area frame |
| `SetOnSelectionChanged(fn)` | `function(self, key, index)` | — | Selection change callback |

### Visual Behaviour

- **Collapsed pane:** 48px wide, shows only icons
- **Expanded pane:** 200px wide, shows icon + text labels
- **Selection indicator:** Animated highlight bar on selected item
- **FramePool:** Nav items are recycled via `FramePool`
- **States:** `Normal` | `Disabled`

---

## BreadcrumbBar

A horizontal breadcrumb trail that displays a navigable path hierarchy. Click any crumb to navigate back to that level.

**WinUI reference:** [BreadcrumbBar](https://learn.microsoft.com/windows/apps/design/controls/breadcrumbbar)

### Creation

```lua
local crumbs = FluentWoW:CreateBreadcrumbBar(parent, "PathBar")
crumbs:SetPoint("TOPLEFT", parent, "TOPLEFT", 16, -16)

crumbs:SetItems({ "Home", "Documents", "Projects", "FluentWoW" })

crumbs:SetOnItemClicked(function(self, index, text)
    print("Navigate to:", text, "at level", index)
end)
```

### API

| Method | Parameters | Returns | Description |
| --- | --- | --- | --- |
| `SetItems(items)` | `string[]` | — | Set breadcrumb path levels |
| `SetOnItemClicked(fn)` | `function(self, index, text)` | — | Crumb click callback |

### Visual Behaviour

- Items separated by chevron (`>`) icons
- Last item rendered in bold (current location)
- All items except the last are clickable
- **FramePool:** Crumb items recycled via `FramePool`
