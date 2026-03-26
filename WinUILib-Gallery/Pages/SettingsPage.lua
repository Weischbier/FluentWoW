--- WinUILib-Gallery – Pages/SettingsPage.lua
-- Showcases: SettingsCard, SettingsExpander.
-------------------------------------------------------------------------------

local lib = WinUILib
local Gallery = lib._gallery

Gallery:RegisterPage("settings", "Settings", function(parent)
    local stack = lib:CreateStackLayout(parent, nil, "VERTICAL")
    stack:SetAllPoints(parent)
    stack:SetGap(16)
    stack:SetPadding(16, 0, 16, 0)

    local header = lib:CreateTextBlock(stack)
    header:SetStyle("Header")
    header:SetText("Settings Controls")
    stack:AddChild(header)

    local desc = lib:CreateTextBlock(stack)
    desc:SetText("SettingsCard and SettingsExpander mirror the Windows Community Toolkit controls.")
    desc:SetWrapping(true)
    stack:AddChild(desc)

    -- SettingsCard with ToggleSwitch
    local cardTitle = lib:CreateTextBlock(stack)
    cardTitle:SetStyle("Title")
    cardTitle:SetText("SettingsCard")
    stack:AddChild(cardTitle)

    local card1 = lib:CreateSettingsCard(stack)
    card1:SetTitle("Night mode")
    card1:SetDescription("Reduce blue light in the evening")
    card1:SetWidth(400)
    local toggle1 = lib:CreateToggleSwitch(card1)
    card1:SetActionControl(toggle1)
    stack:AddChild(card1)

    local card2 = lib:CreateSettingsCard(stack)
    card2:SetTitle("Display brightness")
    card2:SetWidth(400)
    local slider1 = lib:CreateSlider(card2)
    slider1:SetRange(0, 100)
    slider1:SetValue(75)
    slider1:SetWidth(120)
    card2:SetActionControl(slider1)
    stack:AddChild(card2)

    -- SettingsExpander
    local expTitle = lib:CreateTextBlock(stack)
    expTitle:SetStyle("Title")
    expTitle:SetText("SettingsExpander")
    stack:AddChild(expTitle)

    local exp = lib:CreateSettingsExpander(stack)
    exp:SetTitle("Screen and sleep")
    exp:SetDescription("Power and display timeout settings")
    exp:SetWidth(400)

    for i, label in ipairs({"Turn off screen after", "Put device to sleep after", "Hibernate after"}) do
        local c = lib:CreateSettingsCard(exp)
        c:SetTitle(label)
        c:SetWidth(400)
        local cb = lib:CreateComboBox(c)
        cb:SetItems({"5 minutes", "10 minutes", "30 minutes", "Never"})
        cb:SetSelectedIndex(2)
        cb:SetWidth(140)
        c:SetActionControl(cb)
        exp:AddCard(c)
    end

    stack:AddChild(exp)

    -- Disabled card
    local disTitle = lib:CreateTextBlock(stack)
    disTitle:SetStyle("Title")
    disTitle:SetText("Disabled Card")
    stack:AddChild(disTitle)

    local card3 = lib:CreateSettingsCard(stack)
    card3:SetTitle("Unavailable setting")
    card3:SetDescription("This card is disabled")
    card3:SetWidth(400)
    card3:SetEnabled(false)
    stack:AddChild(card3)
end)
