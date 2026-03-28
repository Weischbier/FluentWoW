--- FluentWoW-Gallery -- Pages/StackLayoutPage.lua
-- Mirrors WinUI Gallery StackPanel page.
-------------------------------------------------------------------------------

local lib = LibStub("FluentWoW-1.0")
local T = lib.Tokens
local Gallery = lib._gallery

Gallery:RegisterControlPage("StackLayout", function(parent, item)
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
    -- Example 1: Vertical StackLayout
    ---------------------------------------------------------------------------
    local ex1 = Gallery:CreateControlExample(stack, {
        headerText = "A vertical StackLayout.",
        exampleHeight = 200,
        noOutput = true,
        noOptions = true,
    })

    local vStack = lib:CreateStackLayout(ex1.example, nil, "VERTICAL")
    vStack:SetGap(8)
    vStack:SetPoint("TOPLEFT", ex1.example, "TOPLEFT", 16, -16)

    for i = 1, 4 do
        local surface = Gallery:CreateSurface(vStack)
        surface:SetSize(200, 32)
        local label = lib:CreateTextBlock(surface)
        label:SetText("Item " .. i)
        label:SetPoint("CENTER")
        vStack:AddChild(surface)
    end

    stack:AddChild(ex1.block)

    ---------------------------------------------------------------------------
    -- Example 2: Horizontal StackLayout
    ---------------------------------------------------------------------------
    local ex2 = Gallery:CreateControlExample(stack, {
        headerText = "A horizontal StackLayout.",
        exampleHeight = 120,
        noOutput = true,
        noOptions = true,
    })

    local hStack = lib:CreateStackLayout(ex2.example, nil, "HORIZONTAL")
    hStack:SetGap(12)
    hStack:SetHeight(40)
    hStack:SetPoint("CENTER")

    for i = 1, 4 do
        local surface = Gallery:CreateSurface(hStack)
        surface:SetSize(80, 36)
        local label = lib:CreateTextBlock(surface)
        label:SetText("Item " .. i)
        label:SetPoint("CENTER")
        hStack:AddChild(surface)
    end

    stack:AddChild(ex2.block)

    ---------------------------------------------------------------------------
    -- Example 3: StackLayout with adjustable gap
    ---------------------------------------------------------------------------
    local ex3 = Gallery:CreateControlExample(stack, {
        headerText = "Adjust the gap between StackLayout children.",
        exampleHeight = 200,
        noOutput = true,
    })

    local gapStack = lib:CreateStackLayout(ex3.example, nil, "VERTICAL")
    gapStack:SetGap(8)
    gapStack:SetPoint("TOPLEFT", ex3.example, "TOPLEFT", 16, -16)

    for i = 1, 3 do
        local btn = lib:CreateButton(gapStack, nil, "Subtle")
        btn:SetText("Button " .. i)
        gapStack:AddChild(btn)
    end

    local gapSlider = lib:CreateSlider(ex3.options)
    gapSlider:SetRange(0, 32)
    gapSlider:SetValue(8)
    gapSlider:SetStep(2)
    gapSlider:SetHeader("Gap")
    gapSlider:SetShowValue(true)
    gapSlider:SetPoint("TOPLEFT", ex3.optionsAnchor, "BOTTOMLEFT", 0, -8)
    gapSlider:SetOnValueChanged(function(_, v)
        gapStack:SetGap(math.floor(v))
        gapStack:Refresh()
    end)

    stack:AddChild(ex3.block)

    refresh()
end)
