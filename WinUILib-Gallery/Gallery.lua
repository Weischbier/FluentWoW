--- WinUILib-Gallery – Gallery.lua
-- Main gallery frame with sidebar navigation and content pages.
-- /wuil  command opens/closes the gallery.
-------------------------------------------------------------------------------

local lib = WinUILib
local T = lib.Tokens

-------------------------------------------------------------------------------
-- Page registry
-------------------------------------------------------------------------------

local Gallery = {}
Gallery.pages = {}
Gallery.pageOrder = {}

local function refreshDemoPage(scroll, content, stack, parent)
    stack:Refresh()
    content:SetWidth(math.max(1, parent:GetWidth() - T:GetNumber("Spacing.XXL")))
    content:SetHeight(math.max(parent:GetHeight(), stack:GetHeight() + T:GetNumber("Spacing.XXXL")))
    scroll:SetContentHeight(content:GetHeight())
end

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

local function createExampleBlock(parent, headerText, height)
    local block = CreateFrame("Frame", nil, parent)
    block:SetHeight(height + T:GetNumber("Spacing.XXXL"))

    local header = lib:CreateTextBlock(block)
    header:SetStyle("BodyBold")
    header:SetText(headerText)
    header:SetPoint("TOPLEFT", block, "TOPLEFT", 0, 0)
    header:SetPoint("TOPRIGHT", block, "TOPRIGHT", 0, 0)

    local body = createSurface(block)
    body:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -T:GetNumber("Spacing.LG"))
    body:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", 0, -T:GetNumber("Spacing.LG"))
    body:SetHeight(height)

    return block, body
end

function Gallery:CreateSurface(parent, colorKey)
    return createSurface(parent, colorKey)
end

function Gallery:CreateExampleBlock(parent, headerText, height)
    return createExampleBlock(parent, headerText, height)
end

---@param key string
---@param title string
---@param builder function(contentParent)  builds page content into the parent
function Gallery:RegisterPage(key, title, builder)
    self.pages[key] = { title = title, builder = builder, frame = nil }
    table.insert(self.pageOrder, key)
end

---@param parent Frame
---@return WUILScrollFrame, Frame, WUILStackLayout, function
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
    stack:SetGap(T:GetNumber("Spacing.XL"))
    stack:SetPadding(T:GetNumber("Spacing.XL"), T:GetNumber("Spacing.XL"), T:GetNumber("Spacing.XXXL"), T:GetNumber("Spacing.XL"))

    local function refresh()
        refreshDemoPage(scroll, content, stack, parent)
    end

    scroll.RefreshLayout = refresh
    parent:HookScript("OnShow", refresh)

    return scroll, content, stack, refresh
end

-------------------------------------------------------------------------------
-- Build main frame
-------------------------------------------------------------------------------

local mainFrame

local function EnsureFrame()
    if mainFrame then return mainFrame end

    mainFrame = lib:CreateMainFrame("WUILGalleryFrame", "WinUILib Gallery")
    mainFrame:SetSize(1000, 700)
    mainFrame:SetStatusText("WinUILib v" .. tostring(lib.version))
    mainFrame:ClearAllPoints()
    mainFrame:SetPoint("CENTER")

    local history = {}

    ---------------------------------------------------------------------------
    -- Sidebar (navigation pane)
    ---------------------------------------------------------------------------
    local sidebar = CreateFrame("Frame", nil, mainFrame)
    sidebar:SetWidth(220)
    sidebar:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 0, -40)
    sidebar:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 0, 24)

    -- Sidebar background
    local sidebarBG = sidebar:CreateTexture(nil, "BACKGROUND")
    sidebarBG:SetAllPoints()
    sidebarBG:SetColorTexture(T:GetColor("Color.Surface.Raised"))

    -- Sidebar divider
    local divider = sidebar:CreateTexture(nil, "BORDER")
    divider:SetWidth(1)
    divider:SetPoint("TOPRIGHT", sidebar, "TOPRIGHT")
    divider:SetPoint("BOTTOMRIGHT", sidebar, "BOTTOMRIGHT")
    divider:SetColorTexture(T:GetColor("Color.Border.Subtle"))

    ---------------------------------------------------------------------------
    -- Content area (right of sidebar)
    ---------------------------------------------------------------------------
    mainFrame:SetContentInsets(220, 24, 40, 32)
    local content = mainFrame:GetContentArea()

    ---------------------------------------------------------------------------
    -- Nav buttons in sidebar
    ---------------------------------------------------------------------------
    local navButtons = {}
    local selectedKey = nil

    local function refreshNavLayout(filterText)
        local yOff = -8
        local query = filterText and filterText:lower() or ""
        for _, key in ipairs(Gallery.pageOrder) do
            local btn = navButtons[key]
            local page = Gallery.pages[key]
            local visible = query == "" or page.title:lower():find(query, 1, true) ~= nil
            btn:SetShown(visible)
            if visible then
                btn:ClearAllPoints()
                btn:SetPoint("TOPLEFT", sidebar, "TOPLEFT", 4, yOff)
                btn:SetPoint("RIGHT", sidebar, "RIGHT", -4, 0)
                yOff = yOff - 32
            end
        end
    end

    local function selectPage(key, addToHistory)
        if selectedKey == key then return end

        if addToHistory ~= false and selectedKey then
            table.insert(history, selectedKey)
        end

        -- Deselect previous
        if selectedKey and navButtons[selectedKey] then
            local prev = navButtons[selectedKey]
            prev.BG:Hide()
            prev.Label:SetTextColor(T:GetColor("Color.Text.Secondary"))
        end

        -- Hide previous page
        if selectedKey and Gallery.pages[selectedKey] and Gallery.pages[selectedKey].frame then
            Gallery.pages[selectedKey].frame:Hide()
        end

        selectedKey = key

        -- Highlight current
        if navButtons[key] then
            local cur = navButtons[key]
            cur.BG:SetColorTexture(T:GetColor("Color.Surface.Elevated"))
            cur.BG:Show()
            cur.Label:SetTextColor(T:GetColor("Color.Accent.Primary"))
        end

        -- Show / build page
        local page = Gallery.pages[key]
        if page then
            if not page.frame then
                page.frame = CreateFrame("Frame", nil, content)
                page.frame:SetAllPoints(content)
                page.builder(page.frame)
            end
            page.frame:Show()
            mainFrame:SetStatusText(page.title .. "  |  WinUILib v" .. tostring(lib.version))
        end
    end

    for _, key in ipairs(Gallery.pageOrder) do
        local page = Gallery.pages[key]
        local btn = CreateFrame("Button", nil, sidebar)
        btn:SetHeight(32)

        local bg = btn:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:Hide()
        btn.BG = bg

        local label = btn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        label:SetPoint("LEFT", 12, 0)
        label:SetText(page.title)
        label:SetTextColor(T:GetColor("Color.Text.Secondary"))
        local font = T:Get("Typography.Body")
        if font then label:SetFont(font.font, font.size, font.flags) end
        btn.Label = label

        btn:SetScript("OnClick", function() selectPage(key) end)
        btn:SetScript("OnEnter", function(self)
            if key ~= selectedKey then
                bg:SetColorTexture(T:GetColor("Color.Overlay.Hover"))
                bg:Show()
            end
        end)
        btn:SetScript("OnLeave", function(self)
            if key ~= selectedKey then
                bg:Hide()
            end
        end)

        navButtons[key] = btn
    end

    refreshNavLayout(nil)

    local backButton = lib:CreateButton(mainFrame, nil, "Subtle")
    backButton:SetText("←")
    backButton:SetOnClick(function()
        local previous = table.remove(history)
        if previous then
            selectPage(previous, false)
        end
    end)
    mainFrame:SetTitleBarLeftControl(backButton, 36)

    local searchBox = lib:CreateSearchBox(mainFrame)
    searchBox:SetPlaceholder("Search pages")
    searchBox:SetOnTextChanged(function(_, text)
        refreshNavLayout(text)
    end)
    mainFrame:SetTitleBarRightControl(searchBox, 220)

    -- Select first page
    if Gallery.pageOrder[1] then
        selectPage(Gallery.pageOrder[1], false)
    end

    return mainFrame
end

-------------------------------------------------------------------------------
-- Slash command
-------------------------------------------------------------------------------

SLASH_WUIL1 = "/wuil"
SlashCmdList["WUIL"] = function()
    local f = EnsureFrame()
    if f:IsShown() then f:Close() else f:Open() end
end

-------------------------------------------------------------------------------
-- Export for pages
-------------------------------------------------------------------------------

WinUILib._gallery = Gallery
