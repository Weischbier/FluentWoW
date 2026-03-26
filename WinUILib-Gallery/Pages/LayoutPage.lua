--- WinUILib-Gallery – Pages/LayoutPage.lua
-- Showcases: StackLayout (VStack/HStack), TabView, ScrollFrame.
-------------------------------------------------------------------------------

local lib = WinUILib
local Gallery = lib._gallery

Gallery:RegisterPage("layout", "Layout", function(parent)
    local stack = lib:CreateStackLayout(parent, nil, "VERTICAL")
    stack:SetAllPoints(parent)
    stack:SetGap(16)
    stack:SetPadding(16, 0, 16, 0)

    local header = lib:CreateTextBlock(stack)
    header:SetStyle("Header")
    header:SetText("Layout Controls")
    stack:AddChild(header)

    -- StackLayout demo
    local slTitle = lib:CreateTextBlock(stack)
    slTitle:SetStyle("Title")
    slTitle:SetText("StackLayout (Horizontal)")
    stack:AddChild(slTitle)

    local hStack = lib:CreateStackLayout(stack, nil, "HORIZONTAL")
    hStack:SetGap(8)
    hStack:SetHeight(32)

    for i = 1, 3 do
        local b = lib:CreateButton(hStack, nil, "Subtle")
        b:SetText("Item " .. i)
        hStack:AddChild(b)
    end
    stack:AddChild(hStack)

    -- TabView demo
    local tvTitle = lib:CreateTextBlock(stack)
    tvTitle:SetStyle("Title")
    tvTitle:SetText("TabView")
    stack:AddChild(tvTitle)

    local tv = lib:CreateTabView(stack)
    tv:SetSize(400, 200)

    -- Build tab content
    local tabs = {}
    for i = 1, 3 do
        local f = CreateFrame("Frame", nil, tv)
        local t = lib:CreateTextBlock(f)
        t:SetText("Content for Tab " .. i)
        t:SetPoint("TOPLEFT", 12, -12)
        tabs[i] = { text = "Tab " .. i, content = f }
    end
    tv:SetTabs(tabs)
    tv:SelectTab(1)
    stack:AddChild(tv)

    -- ScrollFrame demo
    local sfTitle = lib:CreateTextBlock(stack)
    sfTitle:SetStyle("Title")
    sfTitle:SetText("ScrollFrame")
    stack:AddChild(sfTitle)

    local sf = lib:CreateScrollFrame(stack)
    sf:SetSize(380, 120)
    sf:SetContentHeight(400)
    local child = sf:GetScrollChild()
    for i = 1, 20 do
        local line = lib:CreateTextBlock(child)
        line:SetText("Scrollable line " .. i)
        line:SetPoint("TOPLEFT", child, "TOPLEFT", 4, -((i - 1) * 18))
        line:SetWidth(340)
    end
    stack:AddChild(sf)
end)
