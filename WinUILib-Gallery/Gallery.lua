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

    local function selectPage(key)
        if selectedKey == key then return end

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

    local yOff = -8
    for _, key in ipairs(Gallery.pageOrder) do
        local page = Gallery.pages[key]
        local btn = CreateFrame("Button", nil, sidebar)
        btn:SetHeight(32)
        btn:SetPoint("TOPLEFT", sidebar, "TOPLEFT", 4, yOff)
        btn:SetPoint("RIGHT", sidebar, "RIGHT", -4, 0)

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
        yOff = yOff - 32
    end

    -- Select first page
    if Gallery.pageOrder[1] then
        selectPage(Gallery.pageOrder[1])
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
