--- FluentWoW-Gallery -- Pages/SettingsExpanderPage.lua
-- Mirrors Windows Community Toolkit SettingsExpander page.
-------------------------------------------------------------------------------

local lib = LibStub("FluentWoW-1.0")
local T = lib.Tokens
local Icons = lib.Icons
local Gallery = lib._gallery

Gallery:RegisterControlPage("SettingsExpander", function(parent, item)
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
    -- Example 1: SettingsExpander with nested cards
    ---------------------------------------------------------------------------
    local ex1 = Gallery:CreateControlExample(stack, {
        headerText = "A SettingsExpander with nested SettingsCards.",
        exampleHeight = 300,
        noOptions = true,
    })

    local expander1 = lib:CreateSettingsExpander(ex1.example)
    expander1:SetTitle("Appearance")
    expander1:SetDescription("Customise theme, fonts, and colours.")
    expander1:SetIconTexture("Interface\\AddOns\\FluentWoW-Gallery\\Assets\\ControlImages\\Expander.png")
    expander1:SetPoint("TOPLEFT", ex1.example, "TOPLEFT", 12, -12)
    expander1:SetPoint("RIGHT", ex1.example, "RIGHT", -12, 0)

    local child1 = lib:CreateSettingsCard(expander1)
    child1:SetTitle("Dark mode")
    child1:SetDescription("Switch between light and dark themes.")
    local darkToggle = lib:CreateToggleSwitch(expander1)
    darkToggle:SetIsOn(true)
    child1:SetActionControl(darkToggle)
    expander1:AddCard(child1)

    local child2 = lib:CreateSettingsCard(expander1)
    child2:SetTitle("Font size")
    child2:SetDescription("Adjust the base font size.")
    local fontSlider = lib:CreateSlider(expander1)
    fontSlider:SetRange(8, 24)
    fontSlider:SetValue(12)
    fontSlider:SetStep(1)
    fontSlider:SetShowValue(true)
    child2:SetActionControl(fontSlider)
    expander1:AddCard(child2)

    ex1.outputLabel:SetText("")
    expander1:SetOnToggled(function(_, expanded)
        ex1.outputLabel:SetText(expanded and "Expanded" or "Collapsed")
    end)

    stack:AddChild(ex1.block)

    ---------------------------------------------------------------------------
    -- Example 2: SettingsExpander starting collapsed
    ---------------------------------------------------------------------------
    local ex2 = Gallery:CreateControlExample(stack, {
        headerText = "A collapsed SettingsExpander.",
        exampleHeight = 120,
        noOutput = true,
        noOptions = true,
    })

    local expander2 = lib:CreateSettingsExpander(ex2.example)
    expander2:SetTitle("Advanced")
    expander2:SetDescription("Advanced settings for power users.")
    expander2:SetExpanded(false, true)
    expander2:SetPoint("TOPLEFT", ex2.example, "TOPLEFT", 12, -12)
    expander2:SetPoint("RIGHT", ex2.example, "RIGHT", -12, 0)

    local advCard = lib:CreateSettingsCard(expander2)
    advCard:SetTitle("Debug logging")
    advCard:SetDescription("Write verbose output to chat.")
    local debugToggle = lib:CreateToggleSwitch(expander2)
    debugToggle:SetIsOn(false)
    advCard:SetActionControl(debugToggle)
    expander2:AddCard(advCard)

    stack:AddChild(ex2.block)

    refresh()
end)
