--- FluentWoW-Gallery -- Pages/ExpanderPage.lua
-- Mirrors WinUI Gallery ExpanderPage.
-------------------------------------------------------------------------------

local lib = LibStub("FluentWoW-1.0")
local T = lib.Tokens
local Gallery = lib._gallery

Gallery:RegisterControlPage("Expander", function(parent, item)
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
    -- Example 1: Basic Expander
    ---------------------------------------------------------------------------
    local ex1 = Gallery:CreateControlExample(stack, {
        headerText = "A basic Expander with text content.",
        exampleHeight = 200,
        noOptions = true,
    })

    local exp1 = lib:CreateExpander(ex1.example)
    exp1:SetTitle("Click to expand")
    exp1:SetContentHeight(80)
    exp1:SetPoint("TOPLEFT", ex1.example, "TOPLEFT", 12, -12)
    exp1:SetPoint("RIGHT", ex1.example, "RIGHT", -12, 0)

    local expandContent = exp1:GetContentFrame()
    local expandLabel = lib:CreateTextBlock(expandContent)
    expandLabel:SetText("This is the content inside the expander. It can contain any controls or text.")
    expandLabel:SetWrapping(true)
    expandLabel:SetWidth(350)
    expandLabel:SetPoint("TOPLEFT", expandContent, "TOPLEFT", 12, -12)

    ex1.outputLabel:SetText("")
    exp1:SetOnToggled(function(_, expanded)
        ex1.outputLabel:SetText(expanded and "Expanded" or "Collapsed")
    end)

    stack:AddChild(ex1.block)

    ---------------------------------------------------------------------------
    -- Example 2: Expander starting expanded
    ---------------------------------------------------------------------------
    local ex2 = Gallery:CreateControlExample(stack, {
        headerText = "An Expander that starts in the expanded state.",
        exampleHeight = 240,
        noOutput = true,
        noOptions = true,
    })

    local exp2 = lib:CreateExpander(ex2.example)
    exp2:SetTitle("Settings")
    exp2:SetContentHeight(120)
    exp2:SetExpanded(true, true)
    exp2:SetPoint("TOPLEFT", ex2.example, "TOPLEFT", 12, -12)
    exp2:SetPoint("RIGHT", ex2.example, "RIGHT", -12, 0)

    local expContent2 = exp2:GetContentFrame()
    local toggle = lib:CreateToggleSwitch(expContent2)
    toggle:SetHeader("Notifications")
    toggle:SetOnContent("On")
    toggle:SetOffContent("Off")
    toggle:SetIsOn(true)
    toggle:SetPoint("TOPLEFT", expContent2, "TOPLEFT", 12, -12)

    local slider = lib:CreateSlider(expContent2)
    slider:SetRange(0, 100)
    slider:SetValue(75)
    slider:SetHeader("Volume")
    slider:SetShowValue(true)
    slider:SetPoint("TOPLEFT", toggle, "BOTTOMLEFT", 0, -12)

    stack:AddChild(ex2.block)

    refresh()
end)
