--- FluentWoW-Gallery -- Pages/RadioButtonPage.lua
-- Mirrors WinUI Gallery RadioButtonPage: basic group selection.
-------------------------------------------------------------------------------

local lib = LibStub("FluentWoW-1.0")
local _T = lib.Tokens
local Gallery = lib._gallery

Gallery:RegisterControlPage("RadioButton", function(parent, item)
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
    -- Example 1: Basic RadioButton group
    ---------------------------------------------------------------------------
    local ex1 = Gallery:CreateControlExample(stack, {
        headerText = "A group of RadioButton controls.",
        exampleHeight = 180,
        noOptions = true,
    })

    local rb1 = lib:CreateRadioButton(ex1.example)
    rb1:SetText("Option 1")
    rb1:SetGroup("radio-demo-1")
    rb1:SetSelected(true)
    rb1:SetPoint("TOPLEFT", ex1.example, "TOPLEFT", 16, -16)

    local rb2 = lib:CreateRadioButton(ex1.example)
    rb2:SetText("Option 2")
    rb2:SetGroup("radio-demo-1")
    rb2:SetPoint("TOPLEFT", rb1, "BOTTOMLEFT", 0, -8)

    local rb3 = lib:CreateRadioButton(ex1.example)
    rb3:SetText("Option 3")
    rb3:SetGroup("radio-demo-1")
    rb3:SetPoint("TOPLEFT", rb2, "BOTTOMLEFT", 0, -8)

    ex1.outputLabel:SetText("Selected: Option 1")

    local function onSelect(_, selected, text)
        if selected then
            ex1.outputLabel:SetText("Selected: " .. text)
        end
    end
    rb1:SetOnSelected(function() onSelect(nil, true, "Option 1") end)
    rb2:SetOnSelected(function() onSelect(nil, true, "Option 2") end)
    rb3:SetOnSelected(function() onSelect(nil, true, "Option 3") end)

    stack:AddChild(ex1.block)

    ---------------------------------------------------------------------------
    -- Example 2: Two groups side-by-side
    ---------------------------------------------------------------------------
    local ex2 = Gallery:CreateControlExample(stack, {
        headerText = "Two independent RadioButton groups.",
        exampleHeight = 180,
        noOutput = true,
        noOptions = true,
    })

    local groupALabel = lib:CreateTextBlock(ex2.example)
    groupALabel:SetStyle("BodyBold")
    groupALabel:SetText("Background")
    groupALabel:SetPoint("TOPLEFT", ex2.example, "TOPLEFT", 16, -12)

    local bgRed = lib:CreateRadioButton(ex2.example)
    bgRed:SetText("Red")
    bgRed:SetGroup("radio-bg")
    bgRed:SetSelected(true)
    bgRed:SetPoint("TOPLEFT", groupALabel, "BOTTOMLEFT", 0, -8)

    local bgGreen = lib:CreateRadioButton(ex2.example)
    bgGreen:SetText("Green")
    bgGreen:SetGroup("radio-bg")
    bgGreen:SetPoint("TOPLEFT", bgRed, "BOTTOMLEFT", 0, -6)

    local bgBlue = lib:CreateRadioButton(ex2.example)
    bgBlue:SetText("Blue")
    bgBlue:SetGroup("radio-bg")
    bgBlue:SetPoint("TOPLEFT", bgGreen, "BOTTOMLEFT", 0, -6)

    local groupBLabel = lib:CreateTextBlock(ex2.example)
    groupBLabel:SetStyle("BodyBold")
    groupBLabel:SetText("Border")
    groupBLabel:SetPoint("TOPLEFT", ex2.example, "TOPLEFT", 200, -12)

    local brRed = lib:CreateRadioButton(ex2.example)
    brRed:SetText("Red")
    brRed:SetGroup("radio-border")
    brRed:SetSelected(true)
    brRed:SetPoint("TOPLEFT", groupBLabel, "BOTTOMLEFT", 0, -8)

    local brGreen = lib:CreateRadioButton(ex2.example)
    brGreen:SetText("Green")
    brGreen:SetGroup("radio-border")
    brGreen:SetPoint("TOPLEFT", brRed, "BOTTOMLEFT", 0, -6)

    local brBlue = lib:CreateRadioButton(ex2.example)
    brBlue:SetText("Blue")
    brBlue:SetGroup("radio-border")
    brBlue:SetPoint("TOPLEFT", brGreen, "BOTTOMLEFT", 0, -6)

    stack:AddChild(ex2.block)

    refresh()
end)
