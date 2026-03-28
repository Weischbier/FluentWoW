--- FluentWoW-Gallery -- Gallery.lua
-- Main gallery frame with NavigationView sidebar, HomePage, SectionPage,
-- and per-control ItemPage.  Mirrors the WinUI Gallery architecture.
-- /fwow  command opens/closes the gallery.
-------------------------------------------------------------------------------

local lib = LibStub("FluentWoW-1.0")
local T = lib.Tokens
local Icons = lib.Icons

-------------------------------------------------------------------------------
-- Control catalog  (mirrors ControlInfoData.json)
-------------------------------------------------------------------------------

local CONTROL_IMAGE_PATH = "Interface\\AddOns\\FluentWoW-Gallery\\Assets\\ControlImages\\"

local controlGroups = {
    {
        uniqueId    = "BasicInput",
        title       = "Basic input",
        icon        = Icons.Edit,
        items       = {
            {
                uniqueId    = "Button",
                title       = "Button",
                subtitle    = "A control that responds to user input and raises a Click event.",
                description = "The Button control provides a Click event to respond to user input from a touch, mouse, keyboard, stylus, or other input device. You can put different kinds of content in a button, such as text or an image, or you can restyle a button to give it a new look.",
                imagePath   = CONTROL_IMAGE_PATH .. "Button.png",
            },
            {
                uniqueId    = "CheckBox",
                title       = "CheckBox",
                subtitle    = "A control that a user can select or clear.",
                description = "Use CheckBox controls to let a user select a combination of binary options. Use a single CheckBox for a yes/no choice, or use it with a header CheckBox to control a group of related options.",
                imagePath   = CONTROL_IMAGE_PATH .. "Checkbox.png",
            },
            {
                uniqueId    = "RadioButton",
                title       = "RadioButton",
                subtitle    = "A control that allows a user to select a single option from a group.",
                description = "Use RadioButtons to let a user choose between mutually exclusive, related options. Generally contained within a group control.",
            },
            {
                uniqueId    = "ToggleSwitch",
                title       = "ToggleSwitch",
                subtitle    = "A switch that can be toggled between two states.",
                description = "Use ToggleSwitch controls to present users with exactly two mutually exclusive options (like on/off), with header and on/off content labels.",
                imagePath   = CONTROL_IMAGE_PATH .. "ToggleSwitch.png",
            },
            {
                uniqueId    = "Slider",
                title       = "Slider",
                subtitle    = "A control that lets the user select from a range of values.",
                description = "Use a Slider when you want your users to be able to set defined, contiguous values (such as volume or brightness) or a range of discrete values (such as screen resolution settings).",
                imagePath   = CONTROL_IMAGE_PATH .. "Slider.png",
            },
            {
                uniqueId    = "ComboBox",
                title       = "ComboBox",
                subtitle    = "A drop-down list of items a user can select from.",
                description = "Use a ComboBox when you need to conserve on-screen space and when users select only one option at a time.",
                imagePath   = CONTROL_IMAGE_PATH .. "ComboBox.png",
            },
            {
                uniqueId    = "NumberBox",
                title       = "NumberBox",
                subtitle    = "A text control used for numeric input with spin buttons.",
                description = "Use NumberBox to allow users to enter algebraic equations and numeric input in your app.",
            },
            {
                uniqueId    = "SegmentedControl",
                title       = "SegmentedControl",
                subtitle    = "A set of two or more segments for mutually exclusive selection.",
                description = "SegmentedControl provides a row of selectable segments where only one can be active at a time.",
            },
        },
    },
    {
        uniqueId    = "Text",
        title       = "Text",
        icon        = Icons.Font,
        items       = {
            {
                uniqueId    = "TextBlock",
                title       = "TextBlock",
                subtitle    = "A lightweight control for displaying small amounts of text.",
                description = "TextBlock is the primary control for displaying read-only text in your app. You can use it to display single-line or multi-line text with formatting like bold, italic, or underlined.",
                imagePath   = CONTROL_IMAGE_PATH .. "TextBlock.png",
            },
            {
                uniqueId    = "TextBox",
                title       = "TextBox",
                subtitle    = "A single-line or multi-line plain text field.",
                description = "Use a TextBox to let a user enter simple text input in your app. You can add a header and placeholder text to let the user know what the TextBox is for.",
                imagePath   = CONTROL_IMAGE_PATH .. "TextBox.png",
            },
        },
    },
    {
        uniqueId    = "StatusAndInfo",
        title       = "Status & info",
        icon        = Icons.Diagnostic,
        items       = {
            {
                uniqueId    = "ProgressBar",
                title       = "ProgressBar",
                subtitle    = "Shows the apps progress on a task.",
                description = "The ProgressBar has two display modes: Indeterminate and Determinate. It also supports error and paused visual states.",
                imagePath   = CONTROL_IMAGE_PATH .. "ProgressBar.png",
            },
            {
                uniqueId    = "InfoBar",
                title       = "InfoBar",
                subtitle    = "An inline notification for essential app-wide messages.",
                description = "Use an InfoBar control when a user should be informed of, acknowledge, or take action on a changed application state.",
                imagePath   = CONTROL_IMAGE_PATH .. "InfoBar.png",
            },
            {
                uniqueId    = "Badge",
                title       = "Badge",
                subtitle    = "A small status pill with severity-coloured appearance.",
                description = "Badge displays a short status label using accent, success, warning, error, or subtle appearance tokens.",
            },
            {
                uniqueId    = "TeachingTip",
                title       = "TeachingTip",
                subtitle    = "A content-rich flyout for guiding users.",
                description = "A teaching tip is a semi-persistent and content-rich flyout that provides contextual information, often used for informing, reminding, and teaching users about important and new features.",
            },
        },
    },
    {
        uniqueId    = "DialogsAndFlyouts",
        title       = "Dialogs & flyouts",
        icon        = Icons.Comment,
        items       = {
            {
                uniqueId    = "ContentDialog",
                title       = "ContentDialog",
                subtitle    = "A dialog box that can be customized to contain any content.",
                description = "Use a ContentDialog to show relevant information or to provide a modal dialog experience that can show any content.",
                imagePath   = CONTROL_IMAGE_PATH .. "ContentDialog.png",
            },
        },
    },
    {
        uniqueId    = "Navigation",
        title       = "Navigation",
        icon        = Icons.GlobalNavButton,
        items       = {
            {
                uniqueId    = "NavigationView",
                title       = "NavigationView",
                subtitle    = "Common vertical layout for top-level areas via a collapsible menu.",
                description = "The NavigationView control provides top-level navigation for your app. It adapts to a variety of screen sizes and supports both top and left navigation styles.",
            },
            {
                uniqueId    = "BreadcrumbBar",
                title       = "BreadcrumbBar",
                subtitle    = "Provides the direct path of pages or folders to the current location.",
                description = "The BreadcrumbBar control provides the direct path of pages or folders to the current location.",
            },
            {
                uniqueId    = "TabView",
                title       = "TabView",
                subtitle    = "A control that displays a set of tabs and their respective content.",
                description = "TabView is a way to display a set of tabs and their respective content. Tab controls are useful for displaying several pages of content while giving a user the capability to rearrange, open, or close new tabs.",
                imagePath   = CONTROL_IMAGE_PATH .. "TabView.png",
            },
        },
    },
    {
        uniqueId    = "Layout",
        title       = "Layout",
        icon        = Icons.ViewAll,
        items       = {
            {
                uniqueId    = "StackLayout",
                title       = "StackLayout",
                subtitle    = "A layout panel that arranges children into a single line.",
                description = "StackLayout arranges child elements in a single line that can be oriented horizontally or vertically. It mirrors the WinUI StackPanel with tokenised gap spacing.",
            },
            {
                uniqueId    = "ScrollFrame",
                title       = "ScrollFrame",
                subtitle    = "A scrollable area with a draggable thumb.",
                description = "ScrollFrame provides scrollable content with mouse wheel support and a draggable thumb track.",
                imagePath   = CONTROL_IMAGE_PATH .. "ScrollViewer.png",
            },
            {
                uniqueId    = "Expander",
                title       = "Expander",
                subtitle    = "A control with a collapsible content area.",
                description = "The Expander control lets you show or hide less important content that is related to a piece of primary content that is always visible.",
                imagePath   = CONTROL_IMAGE_PATH .. "Expander.png",
            },
        },
    },
    {
        uniqueId    = "MenusAndToolbars",
        title       = "Menus & toolbars",
        icon        = Icons.Repair,
        items       = {
            {
                uniqueId    = "CommandBar",
                title       = "CommandBar",
                subtitle    = "A toolbar for displaying application-level commands.",
                description = "CommandBar provides a horizontally laid-out row of icon command buttons with tooltips and optional overflow.",
            },
        },
    },
    {
        uniqueId    = "Collections",
        title       = "Collections",
        icon        = Icons.FolderOpen,
        items       = {
            {
                uniqueId    = "EmptyState",
                title       = "EmptyState",
                subtitle    = "A placeholder for empty content areas.",
                description = "EmptyState provides a visual placeholder when there is no content to display, with icon, title, description, and optional action.",
            },
            {
                uniqueId    = "Skeleton",
                title       = "Skeleton",
                subtitle    = "Animated shimmer loading placeholders.",
                description = "Skeleton controls display a pulsing shimmer effect to indicate that content is loading.",
            },
        },
    },
    {
        uniqueId    = "Settings",
        title       = "Settings",
        icon        = Icons.Settings,
        items       = {
            {
                uniqueId    = "SettingsCard",
                title       = "SettingsCard",
                subtitle    = "A card control that represents a setting with a header and trailing action.",
                description = "SettingsCard mirrors the Windows Community Toolkit SettingsCard: a row with icon, title, description, and a trailing action control.",
            },
            {
                uniqueId    = "SettingsExpander",
                title       = "SettingsExpander",
                subtitle    = "An expander that groups related SettingsCards.",
                description = "SettingsExpander mirrors the Windows Community Toolkit SettingsExpander: an expandable row that reveals nested SettingsCards.",
            },
        },
    },
}

-------------------------------------------------------------------------------
-- Quick lookup helpers
-------------------------------------------------------------------------------

local itemsByUniqueId = {}
local groupsByUniqueId = {}

for _, group in ipairs(controlGroups) do
    groupsByUniqueId[group.uniqueId] = group
    for _, item in ipairs(group.items) do
        item._groupId = group.uniqueId
        itemsByUniqueId[item.uniqueId] = item
    end
end

-------------------------------------------------------------------------------
-- Gallery object
-------------------------------------------------------------------------------

local Gallery = {}
Gallery.controlGroups = controlGroups
Gallery.itemsByUniqueId = itemsByUniqueId
Gallery.groupsByUniqueId = groupsByUniqueId
Gallery.pageBuilders = {}

-------------------------------------------------------------------------------
-- Shared helpers
-------------------------------------------------------------------------------

local function createSurface(parent, colorKey)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetClipsChildren(true)

    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(T:GetColor(colorKey or "Color.Surface.Raised"))
    frame.BG = bg

    local edgeTop = frame:CreateTexture(nil, "BORDER")
    edgeTop:SetHeight(1)
    edgeTop:SetPoint("TOPLEFT")
    edgeTop:SetPoint("TOPRIGHT")
    edgeTop:SetColorTexture(T:GetColor("Color.Border.Subtle"))

    local edgeBottom = frame:CreateTexture(nil, "BORDER")
    edgeBottom:SetHeight(1)
    edgeBottom:SetPoint("BOTTOMLEFT")
    edgeBottom:SetPoint("BOTTOMRIGHT")
    edgeBottom:SetColorTexture(T:GetColor("Color.Border.Subtle"))

    local edgeLeft = frame:CreateTexture(nil, "BORDER")
    edgeLeft:SetWidth(1)
    edgeLeft:SetPoint("TOPLEFT", 0, -1)
    edgeLeft:SetPoint("BOTTOMLEFT", 0, 1)
    edgeLeft:SetColorTexture(T:GetColor("Color.Border.Subtle"))

    local edgeRight = frame:CreateTexture(nil, "BORDER")
    edgeRight:SetWidth(1)
    edgeRight:SetPoint("TOPRIGHT", 0, -1)
    edgeRight:SetPoint("BOTTOMRIGHT", 0, 1)
    edgeRight:SetColorTexture(T:GetColor("Color.Border.Subtle"))

    return frame
end

function Gallery:CreateSurface(parent, colorKey)
    return createSurface(parent, colorKey)
end

-------------------------------------------------------------------------------
-- ControlExample  (mirrors WinUI Gallery ControlExample control)
--   opts.headerText    - section header string
--   opts.exampleHeight - height of the example surface (default 180)
--   opts.noOutput      - hide the output pane
--   opts.noOptions     - hide the options pane
--   opts.outputHeight  - height reserved for output (default 72)
-------------------------------------------------------------------------------

function Gallery:CreateControlExample(parent, opts)
    opts = opts or {}
    local headerText    = opts.headerText or ""
    local exampleHeight = opts.exampleHeight or 180
    local noOutput      = opts.noOutput
    local noOptions     = opts.noOptions
    local outputHeight  = opts.outputHeight or 72

    local totalHeight = exampleHeight + 36
    local block = CreateFrame("Frame", nil, parent)
    block:SetHeight(totalHeight)

    local header = lib:CreateTextBlock(block)
    header:SetStyle("BodyBold")
    header:SetText(headerText)
    header:SetPoint("TOPLEFT", block, "TOPLEFT", 0, 0)
    header:SetPoint("TOPRIGHT", block, "TOPRIGHT", 0, 0)

    local body = createSurface(block)
    body:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -8)
    body:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", 0, -8)
    body:SetHeight(exampleHeight)

    local hasRightPane = (not noOutput) or (not noOptions)
    local exampleArea = createSurface(body, "Color.Surface.Base")
    exampleArea:SetPoint("TOPLEFT", body, "TOPLEFT", 12, -12)
    exampleArea:SetPoint("BOTTOMLEFT", body, "BOTTOMLEFT", 12, 12)
    if hasRightPane then
        exampleArea:SetWidth(420)
    else
        exampleArea:SetPoint("BOTTOMRIGHT", body, "BOTTOMRIGHT", -12, 12)
    end

    local result = {
        block   = block,
        body    = body,
        example = exampleArea,
    }

    if hasRightPane then
        if not noOutput and not noOptions then
            local outputPane = createSurface(body)
            outputPane:SetPoint("TOPLEFT", exampleArea, "TOPRIGHT", 12, 0)
            outputPane:SetPoint("TOPRIGHT", body, "TOPRIGHT", -12, -12)
            outputPane:SetHeight(outputHeight)
            result.output = outputPane

            local outputTitle = lib:CreateTextBlock(outputPane)
            outputTitle:SetStyle("Caption")
            outputTitle:SetColorKey("Color.Text.Secondary")
            outputTitle:SetText("Output")
            outputTitle:SetPoint("TOPLEFT", outputPane, "TOPLEFT", 12, -10)

            local outputLabel = lib:CreateTextBlock(outputPane)
            outputLabel:SetText("")
            outputLabel:SetWrapping(true)
            outputLabel:SetPoint("TOPLEFT", outputTitle, "BOTTOMLEFT", 0, -6)
            outputLabel:SetPoint("RIGHT", outputPane, "RIGHT", -12, 0)
            result.outputLabel = outputLabel

            local optionsPane = createSurface(body)
            optionsPane:SetPoint("TOPLEFT", outputPane, "BOTTOMLEFT", 0, -12)
            optionsPane:SetPoint("BOTTOMRIGHT", body, "BOTTOMRIGHT", -12, 12)
            result.options = optionsPane

            local optionsTitle = lib:CreateTextBlock(optionsPane)
            optionsTitle:SetStyle("Caption")
            optionsTitle:SetColorKey("Color.Text.Secondary")
            optionsTitle:SetText("Options")
            optionsTitle:SetPoint("TOPLEFT", optionsPane, "TOPLEFT", 12, -10)
            result.optionsAnchor = optionsTitle
        elseif not noOutput then
            local outputPane = createSurface(body)
            outputPane:SetPoint("TOPLEFT", exampleArea, "TOPRIGHT", 12, 0)
            outputPane:SetPoint("BOTTOMRIGHT", body, "BOTTOMRIGHT", -12, 12)
            result.output = outputPane

            local outputTitle = lib:CreateTextBlock(outputPane)
            outputTitle:SetStyle("Caption")
            outputTitle:SetColorKey("Color.Text.Secondary")
            outputTitle:SetText("Output")
            outputTitle:SetPoint("TOPLEFT", outputPane, "TOPLEFT", 12, -10)

            local outputLabel = lib:CreateTextBlock(outputPane)
            outputLabel:SetText("")
            outputLabel:SetWrapping(true)
            outputLabel:SetPoint("TOPLEFT", outputTitle, "BOTTOMLEFT", 0, -6)
            outputLabel:SetPoint("RIGHT", outputPane, "RIGHT", -12, 0)
            result.outputLabel = outputLabel
        elseif not noOptions then
            local optionsPane = createSurface(body)
            optionsPane:SetPoint("TOPLEFT", exampleArea, "TOPRIGHT", 12, 0)
            optionsPane:SetPoint("BOTTOMRIGHT", body, "BOTTOMRIGHT", -12, 12)
            result.options = optionsPane

            local optionsTitle = lib:CreateTextBlock(optionsPane)
            optionsTitle:SetStyle("Caption")
            optionsTitle:SetColorKey("Color.Text.Secondary")
            optionsTitle:SetText("Options")
            optionsTitle:SetPoint("TOPLEFT", optionsPane, "TOPLEFT", 12, -10)
            result.optionsAnchor = optionsTitle
        end
    end

    return result
end

-------------------------------------------------------------------------------
-- CreateDemoPage  (scrollable StackLayout container for a page)
-------------------------------------------------------------------------------

local function refreshDemoPage(scroll, content, stack, parent)
    stack:Refresh()
    content:SetWidth(math.max(1, parent:GetWidth() - 24))
    content:SetHeight(math.max(parent:GetHeight(), stack:GetHeight() + 48))
    scroll:SetContentHeight(content:GetHeight())
end

function Gallery:CreateDemoPage(parent)
    local scroll = lib:CreateScrollFrame(parent)
    scroll:SetAllPoints(parent)
    scroll.ScrollFrame:EnableMouseWheel(true)

    local content = scroll:GetScrollChild()
    content:ClearAllPoints()
    content:SetPoint("TOPLEFT", scroll.ScrollFrame, "TOPLEFT", 0, 0)
    content:SetPoint("TOPRIGHT", scroll.ScrollFrame, "TOPRIGHT", 0, 0)

    local stack = lib:CreateStackLayout(content, nil, "VERTICAL")
    stack:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
    stack:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, 0)
    stack:SetGap(36)
    stack:SetPadding(36, 36, 48, 36)

    local function refresh()
        refreshDemoPage(scroll, content, stack, parent)
    end

    scroll.RefreshLayout = refresh
    parent:HookScript("OnShow", refresh)

    return scroll, content, stack, refresh
end

-------------------------------------------------------------------------------
-- RegisterControlPage  (called by each Pages/<Control>Page.lua)
-------------------------------------------------------------------------------

function Gallery:RegisterControlPage(uniqueId, builder)
    self.pageBuilders[uniqueId] = builder
end

-------------------------------------------------------------------------------
-- Build main frame
-------------------------------------------------------------------------------

local mainFrame
local SIDEBAR_WIDTH = 260

local function EnsureFrame()
    if mainFrame then return mainFrame end

    mainFrame = lib:CreateMainFrame("FWoWGalleryFrame", "FluentWoW Gallery")
    mainFrame:SetSize(1100, 750)
    mainFrame:SetStatusText("FluentWoW v" .. tostring(lib.version))
    mainFrame:ClearAllPoints()
    mainFrame:SetPoint("CENTER")

    local history = {}
    local currentView = nil
    local viewFrames = {}

    ---------------------------------------------------------------------------
    -- Sidebar
    ---------------------------------------------------------------------------
    local sidebar = CreateFrame("Frame", nil, mainFrame)
    sidebar:SetWidth(SIDEBAR_WIDTH)
    sidebar:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 0, -40)
    sidebar:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 0, 24)

    local sidebarBG = sidebar:CreateTexture(nil, "BACKGROUND")
    sidebarBG:SetAllPoints()
    sidebarBG:SetColorTexture(T:GetColor("Color.Surface.Raised"))

    local sidebarDivider = sidebar:CreateTexture(nil, "BORDER")
    sidebarDivider:SetWidth(1)
    sidebarDivider:SetPoint("TOPRIGHT", sidebar, "TOPRIGHT")
    sidebarDivider:SetPoint("BOTTOMRIGHT", sidebar, "BOTTOMRIGHT")
    sidebarDivider:SetColorTexture(T:GetColor("Color.Border.Subtle"))

    local sidebarScroll = lib:CreateScrollFrame(sidebar)
    sidebarScroll:SetPoint("TOPLEFT", sidebar, "TOPLEFT", 0, -4)
    sidebarScroll:SetPoint("BOTTOMRIGHT", sidebar, "BOTTOMRIGHT", 0, 0)
    sidebarScroll.ScrollFrame:EnableMouseWheel(true)
    local sidebarContent = sidebarScroll:GetScrollChild()
    sidebarContent:ClearAllPoints()
    sidebarContent:SetPoint("TOPLEFT", sidebarScroll.ScrollFrame, "TOPLEFT", 0, 0)
    sidebarContent:SetWidth(SIDEBAR_WIDTH - 10)

    ---------------------------------------------------------------------------
    -- Content area
    ---------------------------------------------------------------------------
    mainFrame:SetContentInsets(SIDEBAR_WIDTH, 24, 40, 32)
    local contentArea = mainFrame:GetContentArea()

    ---------------------------------------------------------------------------
    -- Navigation helpers
    ---------------------------------------------------------------------------
    local navButtons = {}
    local selectedNavKey = nil

    local function highlightNav(key)
        if selectedNavKey and navButtons[selectedNavKey] then
            local prev = navButtons[selectedNavKey]
            if prev.BG then prev.BG:Hide() end
            if prev.Label then prev.Label:SetTextColor(T:GetColor("Color.Text.Secondary")) end
            if prev.Icon then prev.Icon:SetTextColor(T:GetColor("Color.Text.Secondary")) end
        end
        selectedNavKey = key
        if key and navButtons[key] then
            local cur = navButtons[key]
            if cur.BG then
                cur.BG:SetColorTexture(T:GetColor("Color.Surface.Elevated"))
                cur.BG:Show()
            end
            if cur.Label then cur.Label:SetTextColor(T:GetColor("Color.Accent.Primary")) end
            if cur.Icon then cur.Icon:SetTextColor(T:GetColor("Color.Accent.Primary")) end
        end
    end

    local function hideAllViews()
        for _, f in pairs(viewFrames) do
            f:Hide()
        end
    end

    local function navigateTo(viewType, viewId, addToHistory)
        if addToHistory ~= false and currentView then
            table.insert(history, { type = currentView.type, id = currentView.id })
        end

        hideAllViews()
        currentView = { type = viewType, id = viewId }

        local frameKey = viewType .. ":" .. (viewId or "")

        if not viewFrames[frameKey] then
            local f = CreateFrame("Frame", nil, contentArea)
            f:SetAllPoints(contentArea)
            viewFrames[frameKey] = f

            if viewType == "home" then
                Gallery:BuildHomePage(f)
            elseif viewType == "section" then
                Gallery:BuildSectionPage(f, viewId)
            elseif viewType == "item" then
                Gallery:BuildItemPage(f, viewId)
            end
        end

        viewFrames[frameKey]:Show()

        if viewType == "home" then
            mainFrame:SetStatusText("Home  |  FluentWoW v" .. tostring(lib.version))
            highlightNav("__home")
        elseif viewType == "section" then
            local group = groupsByUniqueId[viewId]
            mainFrame:SetStatusText((group and group.title or viewId) .. "  |  FluentWoW v" .. tostring(lib.version))
            highlightNav("__section_" .. viewId)
        elseif viewType == "item" then
            local item = itemsByUniqueId[viewId]
            mainFrame:SetStatusText((item and item.title or viewId) .. "  |  FluentWoW v" .. tostring(lib.version))
            highlightNav("__item_" .. viewId)
        end
    end

    Gallery.navigateTo = navigateTo

    ---------------------------------------------------------------------------
    -- Build sidebar nav items
    ---------------------------------------------------------------------------
    local bodyFont = T:Get("Typography.Body")
    local captionFont = T:Get("Typography.Caption")
    local allNavEntries = {}

    local function createNavButton(text, key, indent, iconGlyph)
        local btn = CreateFrame("Button", nil, sidebarContent)
        btn:SetHeight(30)

        local bg = btn:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:Hide()
        btn.BG = bg

        local xOffset = 12 + (indent or 0)

        if iconGlyph then
            local icon = btn:CreateFontString(nil, "ARTWORK")
            icon:SetFont(lib.FLUENT_ICON_FONT, 12, "")
            icon:SetText(iconGlyph)
            icon:SetTextColor(T:GetColor("Color.Text.Secondary"))
            icon:SetPoint("LEFT", xOffset, 0)
            btn.Icon = icon
            xOffset = xOffset + 20
        end

        local label = btn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        label:SetPoint("LEFT", xOffset, 0)
        label:SetPoint("RIGHT", btn, "RIGHT", -8, 0)
        label:SetJustifyH("LEFT")
        label:SetText(text)
        label:SetTextColor(T:GetColor("Color.Text.Secondary"))
        label:SetWordWrap(false)
        if bodyFont then label:SetFont(bodyFont.font, bodyFont.size, bodyFont.flags) end
        btn.Label = label

        btn:SetScript("OnEnter", function()
            if key ~= selectedNavKey then
                bg:SetColorTexture(T:GetColor("Color.Overlay.Hover"))
                bg:Show()
            end
        end)
        btn:SetScript("OnLeave", function()
            if key ~= selectedNavKey then bg:Hide() end
        end)

        navButtons[key] = btn
        return btn
    end

    -- Home
    local homeBtn = createNavButton("Home", "__home", 0, Icons.Home)
    homeBtn:SetScript("OnClick", function() navigateTo("home", nil) end)
    table.insert(allNavEntries, { key = "__home", text = "Home", btn = homeBtn })

    -- All controls
    local allBtn = createNavButton("All controls", "__all", 0, Icons.ViewAll)
    allBtn:SetScript("OnClick", function() navigateTo("section", "__all") end)
    table.insert(allNavEntries, { key = "__all", text = "All controls", btn = allBtn })

    -- Category separators + groups + items
    for _, group in ipairs(controlGroups) do
        -- Separator header label (non-interactive)
        local sepKey = "__sep_" .. group.uniqueId
        local sep = CreateFrame("Frame", nil, sidebarContent)
        sep:SetHeight(26)
        local sepLabel = sep:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        sepLabel:SetPoint("LEFT", 12, 0)
        sepLabel:SetPoint("RIGHT", sep, "RIGHT", -8, 0)
        sepLabel:SetJustifyH("LEFT")
        sepLabel:SetText(group.title)
        sepLabel:SetTextColor(T:GetColor("Color.Text.Tertiary"))
        if captionFont then sepLabel:SetFont(captionFont.font, captionFont.size, captionFont.flags) end
        sep._label = sepLabel
        table.insert(allNavEntries, { key = sepKey, text = group.title, btn = sep, isSep = true })

        -- Child items
        for _, item in ipairs(group.items) do
            local itemKey = "__item_" .. item.uniqueId
            local itemBtn = createNavButton(item.title, itemKey, 8)
            itemBtn:SetScript("OnClick", function() navigateTo("item", item.uniqueId) end)
            table.insert(allNavEntries, { key = itemKey, text = item.title, btn = itemBtn, parentSep = sepKey })
        end
    end

    ---------------------------------------------------------------------------
    -- Layout sidebar
    ---------------------------------------------------------------------------
    local function refreshSidebarLayout(filterText)
        local yOff = -4
        local query = filterText and filterText:lower() or ""
        local matchedGroups = {}

        if query ~= "" then
            for _, entry in ipairs(allNavEntries) do
                if not entry.isSep and entry.text:lower():find(query, 1, true) then
                    matchedGroups[entry.key] = true
                    if entry.parentSep then
                        matchedGroups[entry.parentSep] = true
                    end
                end
            end
        end

        for _, entry in ipairs(allNavEntries) do
            local btn = entry.btn
            local visible
            if query == "" then
                visible = true
            else
                visible = matchedGroups[entry.key] or false
            end

            btn:SetShown(visible)
            if visible then
                btn:ClearAllPoints()
                btn:SetPoint("TOPLEFT", sidebarContent, "TOPLEFT", 4, yOff)
                btn:SetPoint("RIGHT", sidebarContent, "RIGHT", -4, 0)
                yOff = yOff - (entry.isSep and 26 or 30)
            end
        end

        sidebarContent:SetHeight(math.abs(yOff) + 8)
        sidebarScroll:SetContentHeight(math.abs(yOff) + 8)
    end

    refreshSidebarLayout(nil)

    ---------------------------------------------------------------------------
    -- Title bar controls
    ---------------------------------------------------------------------------
    local backButton = lib:CreateButton(mainFrame, nil, "Subtle")
    backButton:SetText(Icons.ChromeBack)
    local backLabel = backButton:GetFontString()
    if backLabel then
        backLabel:SetFont(lib.FLUENT_ICON_FONT, 12, "")
    end
    backButton:SetOnClick(function()
        local previous = table.remove(history)
        if previous then
            navigateTo(previous.type, previous.id, false)
        end
    end)
    mainFrame:SetTitleBarLeftControl(backButton, 36)

    local searchBox = lib:CreateSearchBox(mainFrame)
    searchBox:SetPlaceholder("Search controls...")
    searchBox:SetOnTextChanged(function(_, text)
        refreshSidebarLayout(text)
    end)
    mainFrame:SetTitleBarRightControl(searchBox, 240)

    ---------------------------------------------------------------------------
    -- Start on home
    ---------------------------------------------------------------------------
    navigateTo("home", nil, false)

    return mainFrame
end

-------------------------------------------------------------------------------
-- HomePage builder
-------------------------------------------------------------------------------

function Gallery:BuildHomePage(parent)
    local _, _, stack, refresh = self:CreateDemoPage(parent)

    -- Hero header
    local heroFrame = CreateFrame("Frame", nil, stack)
    heroFrame:SetHeight(120)
    stack:AddChild(heroFrame)

    local heroBG = heroFrame:CreateTexture(nil, "BACKGROUND")
    heroBG:SetAllPoints()
    heroBG:SetColorTexture(T:GetColor("Color.Accent.Primary"))
    heroBG:SetAlpha(0.15)

    local heroTitle = lib:CreateTextBlock(heroFrame)
    heroTitle:SetStyle("Header")
    heroTitle:SetText("FluentWoW Gallery")
    heroTitle:SetPoint("TOPLEFT", heroFrame, "TOPLEFT", 24, -20)

    local heroSubtitle = lib:CreateTextBlock(heroFrame)
    heroSubtitle:SetStyle("Body")
    heroSubtitle:SetColorKey("Color.Text.Secondary")
    heroSubtitle:SetWrapping(true)
    heroSubtitle:SetWidth(600)
    heroSubtitle:SetText("An interactive showcase of all FluentWoW controls. Browse by category or search for a specific control. Each page provides live, interactive examples mirroring the WinUI 3 Gallery.")
    heroSubtitle:SetPoint("TOPLEFT", heroTitle, "BOTTOMLEFT", 0, -8)

    -- Control tiles by category
    for _, group in ipairs(controlGroups) do
        local sectionHeader = lib:CreateTextBlock(stack)
        sectionHeader:SetStyle("Subtitle")
        sectionHeader:SetText(group.title)
        stack:AddChild(sectionHeader)

        local tileRow = lib:CreateStackLayout(stack, nil, "HORIZONTAL")
        tileRow:SetGap(12)
        tileRow:SetHeight(80)
        stack:AddChild(tileRow)

        for _, item in ipairs(group.items) do
            local tile = CreateFrame("Button", nil, tileRow)
            tile:SetSize(200, 72)

            local border = tile:CreateTexture(nil, "BORDER")
            border:SetPoint("TOPLEFT", -1, 1)
            border:SetPoint("BOTTOMRIGHT", 1, -1)
            border:SetColorTexture(T:GetColor("Color.Border.Subtle"))

            local inner = tile:CreateTexture(nil, "ARTWORK", nil, -1)
            inner:SetAllPoints()
            inner:SetColorTexture(T:GetColor("Color.Surface.Raised"))

            local tileTitle = tile:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            tileTitle:SetPoint("TOPLEFT", 12, -12)
            tileTitle:SetPoint("RIGHT", tile, "RIGHT", -12, 0)
            tileTitle:SetJustifyH("LEFT")
            tileTitle:SetText(item.title)
            tileTitle:SetTextColor(T:GetColor("Color.Text.Primary"))
            local bf = T:Get("Typography.BodyBold")
            if bf then tileTitle:SetFont(bf.font, bf.size, bf.flags) end

            local tileSub = tile:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            tileSub:SetPoint("TOPLEFT", tileTitle, "BOTTOMLEFT", 0, -4)
            tileSub:SetPoint("RIGHT", tile, "RIGHT", -12, 0)
            tileSub:SetJustifyH("LEFT")
            tileSub:SetWordWrap(true)
            tileSub:SetText(item.subtitle or "")
            tileSub:SetTextColor(T:GetColor("Color.Text.Secondary"))
            local cf = T:Get("Typography.Caption")
            if cf then tileSub:SetFont(cf.font, cf.size, cf.flags) end

            tile:SetScript("OnEnter", function()
                inner:SetColorTexture(T:GetColor("Color.Overlay.Hover"))
            end)
            tile:SetScript("OnLeave", function()
                inner:SetColorTexture(T:GetColor("Color.Surface.Raised"))
            end)
            tile:SetScript("OnClick", function()
                self.navigateTo("item", item.uniqueId)
            end)

            tileRow:AddChild(tile)
        end
    end

    refresh()
end

-------------------------------------------------------------------------------
-- SectionPage builder
-------------------------------------------------------------------------------

function Gallery:BuildSectionPage(parent, groupId)
    local _, _, stack, refresh = self:CreateDemoPage(parent)

    local items, title
    if groupId == "__all" then
        title = "All controls"
        items = {}
        for _, group in ipairs(controlGroups) do
            for _, item in ipairs(group.items) do
                table.insert(items, item)
            end
        end
        table.sort(items, function(a, b) return a.title < b.title end)
    else
        local group = groupsByUniqueId[groupId]
        if not group then return end
        title = group.title
        items = group.items
    end

    local header = lib:CreateTextBlock(stack)
    header:SetStyle("Title")
    header:SetText(title)
    stack:AddChild(header)

    local TILE_W, TILE_H, GAP = 200, 72, 12
    local TILES_PER_ROW = 3
    local row
    for i, item in ipairs(items) do
        if (i - 1) % TILES_PER_ROW == 0 then
            row = lib:CreateStackLayout(stack, nil, "HORIZONTAL")
            row:SetGap(GAP)
            row:SetHeight(TILE_H + 8)
            stack:AddChild(row)
        end

        local tile = CreateFrame("Button", nil, row)
        tile:SetSize(TILE_W, TILE_H)

        local border = tile:CreateTexture(nil, "BORDER")
        border:SetPoint("TOPLEFT", -1, 1)
        border:SetPoint("BOTTOMRIGHT", 1, -1)
        border:SetColorTexture(T:GetColor("Color.Border.Subtle"))

        local inner = tile:CreateTexture(nil, "ARTWORK", nil, -1)
        inner:SetAllPoints()
        inner:SetColorTexture(T:GetColor("Color.Surface.Raised"))

        local tileTitle = tile:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        tileTitle:SetPoint("TOPLEFT", 12, -12)
        tileTitle:SetPoint("RIGHT", tile, "RIGHT", -12, 0)
        tileTitle:SetJustifyH("LEFT")
        tileTitle:SetText(item.title)
        tileTitle:SetTextColor(T:GetColor("Color.Text.Primary"))
        local bf = T:Get("Typography.BodyBold")
        if bf then tileTitle:SetFont(bf.font, bf.size, bf.flags) end

        local tileSub = tile:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        tileSub:SetPoint("TOPLEFT", tileTitle, "BOTTOMLEFT", 0, -4)
        tileSub:SetPoint("RIGHT", tile, "RIGHT", -12, 0)
        tileSub:SetJustifyH("LEFT")
        tileSub:SetWordWrap(true)
        tileSub:SetText(item.subtitle or "")
        tileSub:SetTextColor(T:GetColor("Color.Text.Secondary"))
        local cf = T:Get("Typography.Caption")
        if cf then tileSub:SetFont(cf.font, cf.size, cf.flags) end

        tile:SetScript("OnEnter", function()
            inner:SetColorTexture(T:GetColor("Color.Overlay.Hover"))
        end)
        tile:SetScript("OnLeave", function()
            inner:SetColorTexture(T:GetColor("Color.Surface.Raised"))
        end)
        tile:SetScript("OnClick", function()
            self.navigateTo("item", item.uniqueId)
        end)

        row:AddChild(tile)
    end

    refresh()
end

-------------------------------------------------------------------------------
-- ItemPage builder
-------------------------------------------------------------------------------

function Gallery:BuildItemPage(parent, uniqueId)
    local item = itemsByUniqueId[uniqueId]
    if not item then return end

    local builder = self.pageBuilders[uniqueId]
    if builder then
        builder(parent, item)
    else
        local _, _, stack, refresh = self:CreateDemoPage(parent)

        local header = lib:CreateTextBlock(stack)
        header:SetStyle("Title")
        header:SetText(item.title)
        stack:AddChild(header)

        local desc = lib:CreateTextBlock(stack)
        desc:SetText(item.description or "No sample page registered for this control.")
        desc:SetColorKey("Color.Text.Secondary")
        desc:SetWrapping(true)
        desc:SetWidth(680)
        stack:AddChild(desc)

        refresh()
    end
end

-------------------------------------------------------------------------------
-- Slash command
-------------------------------------------------------------------------------

SLASH_FWOW1 = "/fwow"
SlashCmdList["FWOW"] = function()
    local f = EnsureFrame()
    if f:IsShown() then f:Close() else f:Open() end
end

-------------------------------------------------------------------------------
-- Export for pages
-------------------------------------------------------------------------------

FluentWoW._gallery = Gallery
