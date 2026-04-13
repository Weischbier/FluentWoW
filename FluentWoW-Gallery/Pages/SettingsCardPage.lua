--- FluentWoW-Gallery -- Pages/SettingsCardPage.lua
-- Mirrors Windows Community Toolkit SettingsCard page.
-------------------------------------------------------------------------------

local lib = LibStub("FluentWoW-1.0")
local _T = lib.Tokens
local _Icons = lib.Icons
local Gallery = lib._gallery

Gallery:RegisterControlPage("SettingsCard", function(parent, item)
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
    -- Example 1: SettingsCard with a ToggleSwitch
    ---------------------------------------------------------------------------
    local ex1 = Gallery:CreateControlExample(stack, {
        headerText = "A SettingsCard with a ToggleSwitch action.",
        exampleHeight = 152,
        noOptions = true,
    })

    local card1 = lib:CreateSettingsCard(ex1.example)
    card1:SetTitle("Notifications")
    card1:SetDescription("Enable push notifications for this character.")
    card1:SetIconTexture("Interface\\AddOns\\FluentWoW-Gallery\\Assets\\ControlImages\\ToggleSwitch.png")
    card1:SetPoint("TOPLEFT", ex1.example, "TOPLEFT", 12, -12)
    card1:SetPoint("RIGHT", ex1.example, "RIGHT", -12, 0)

    local cardToggle = lib:CreateToggleSwitch(ex1.example)
    cardToggle:SetIsOn(true)
    card1:SetActionControl(cardToggle)

    ex1.outputLabel:SetText("On")
    cardToggle:SetOnToggled(function(_, isOn)
        ex1.outputLabel:SetText(isOn and "On" or "Off")
    end)

    stack:AddChild(ex1.block)

    ---------------------------------------------------------------------------
    -- Example 2: SettingsCard with a Slider
    ---------------------------------------------------------------------------
    local ex2 = Gallery:CreateControlExample(stack, {
        headerText = "A SettingsCard with a Slider action.",
        exampleHeight = 164,
        noOutput = true,
        noOptions = true,
    })

    local card2 = lib:CreateSettingsCard(ex2.example)
    card2:SetTitle("Opacity")
    card2:SetDescription("Adjust the background opacity level.")
    card2:SetPoint("TOPLEFT", ex2.example, "TOPLEFT", 12, -12)
    card2:SetPoint("RIGHT", ex2.example, "RIGHT", -12, 0)

    local cardSlider = lib:CreateSlider(ex2.example)
    cardSlider:SetWidth(120)
    cardSlider:SetRange(0, 100)
    cardSlider:SetValue(80)
    cardSlider:SetShowValue(true)
    card2:SetActionControl(cardSlider)
    card2:SetAlpha(0.8)
    cardSlider:SetOnValueChanged(function(_, value)
        card2:SetAlpha(math.max(0.2, value / 100))
    end)

    stack:AddChild(ex2.block)

    ---------------------------------------------------------------------------
    -- Example 3: Clickable SettingsCard
    ---------------------------------------------------------------------------
    local ex3 = Gallery:CreateControlExample(stack, {
        headerText = "A clickable SettingsCard.",
        exampleHeight = 136,
        noOptions = true,
    })

    local card3 = lib:CreateSettingsCard(ex3.example)
    card3:SetTitle("Storage")
    card3:SetDescription("Manage local storage and cache settings.")
    card3:SetClickable(true)
    card3:SetPoint("TOPLEFT", ex3.example, "TOPLEFT", 12, -12)
    card3:SetPoint("RIGHT", ex3.example, "RIGHT", -12, 0)

    ex3.outputLabel:SetText("")
    card3:SetOnClick(function()
        ex3.outputLabel:SetText("SettingsCard clicked!")
    end)

    stack:AddChild(ex3.block)

    refresh()
end)
