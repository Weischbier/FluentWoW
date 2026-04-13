--- FluentWoW-Gallery -- Pages/ScrollFramePage.lua
-- Mirrors WinUI Gallery ScrollViewer page.
-------------------------------------------------------------------------------

local lib = LibStub("FluentWoW-1.0")
local _T = lib.Tokens
local Gallery = lib._gallery

Gallery:RegisterControlPage("ScrollFrame", function(parent, item)
    local _, _, stack, refresh = Gallery:CreateDemoPage(parent)

    local header = lib:CreateTextBlock(stack)
    header:SetStyle("Title")
    header:SetText(item.title)
    stack:AddChild(header)

    local desc = lib:CreateTextBlock(stack)
    desc:SetText(item.description)
    desc:SetColorKey("Color.Text.Secondary")
    desc:SetWrapping(true)
    desc:SetWidth(680)
    stack:AddChild(desc)

    ---------------------------------------------------------------------------
    -- Example 1: ScrollFrame with long content
    ---------------------------------------------------------------------------
    local ex1 = Gallery:CreateControlExample(stack, {
        headerText = "A ScrollFrame with content taller than its viewport.",
        exampleHeight = 280,
        noOutput = true,
        noOptions = true,
    })

    local scroll = lib:CreateScrollFrame(ex1.example)
    scroll:SetPoint("TOPLEFT", ex1.example, "TOPLEFT", 12, -12)
    scroll:SetPoint("BOTTOMRIGHT", ex1.example, "BOTTOMRIGHT", -12, 12)
    scroll.ScrollFrame:EnableMouseWheel(true)

    local scrollChild = scroll:GetScrollChild()
    scrollChild:ClearAllPoints()
    scrollChild:SetPoint("TOPLEFT", scroll.ScrollFrame, "TOPLEFT", 0, 0)
    scrollChild:SetWidth(380)

    local contentStack = lib:CreateStackLayout(scrollChild, nil, "VERTICAL")
    contentStack:SetGap(8)
    contentStack:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 8, -8)
    contentStack:SetPoint("RIGHT", scrollChild, "RIGHT", -8, 0)

    for i = 1, 20 do
        local row = Gallery:CreateSurface(contentStack)
        row:SetHeight(32)
        local label = lib:CreateTextBlock(row)
        label:SetText("Scrollable item " .. i)
        label:SetPoint("LEFT", row, "LEFT", 12, 0)
        contentStack:AddChild(row)
    end

    contentStack:Refresh()
    scrollChild:SetHeight(contentStack:GetHeight() + 16)
    scroll:SetContentHeight(scrollChild:GetHeight())

    stack:AddChild(ex1.block)

    refresh()
end)
