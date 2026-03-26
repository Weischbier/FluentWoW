--- WinUILib-Gallery – Pages/SettingsPage.lua
-- Showcases: SettingsCard, SettingsExpander.
-------------------------------------------------------------------------------

local lib = WinUILib
local Gallery = lib._gallery

Gallery:RegisterPage("settings", "Settings", function(parent)
    local _, _, stack, refresh = Gallery:CreateDemoPage(parent)

    local header = lib:CreateTextBlock(stack)
    header:SetStyle("Header")
    header:SetText("Settings Controls")
    stack:AddChild(header)

    local desc = lib:CreateTextBlock(stack)
    desc:SetText("SettingsCard and SettingsExpander mirror the Windows Community Toolkit controls.")
    desc:SetColorKey("Color.Text.Secondary")
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
    card1:SetIconTexture("Interface\\ICONS\\Spell_Nature_Sleep")
    card1:SetWidth(400)
    local toggle1 = lib:CreateToggleSwitch(card1)
    card1:SetActionControl(toggle1)
    stack:AddChild(card1)

    local card2 = lib:CreateSettingsCard(stack)
    card2:SetTitle("Display brightness")
    card2:SetIconTexture("Interface\\ICONS\\INV_Misc_EngGizmos_17")
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
    exp:SetIconTexture("Interface\\ICONS\\INV_Misc_Gear_01")
    exp:SetWidth(400)

    for i, label in ipairs({"Turn off screen after", "Put device to sleep after", "Hibernate after"}) do
        local c = lib:CreateSettingsCard(exp)
        c:SetTitle(label)
        c:SetIconTexture("Interface\\ICONS\\INV_Misc_PocketWatch_01")
        c:SetWidth(400)
        local cb = lib:CreateComboBox(c)
        cb:SetItems({
            { text = "5 minutes", value = 5 },
            { text = "10 minutes", value = 10 },
            { text = "30 minutes", value = 30 },
            { text = "Never", value = 0 },
        })
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
    card3:SetIconTexture("Interface\\ICONS\\INV_Misc_Lockbox_01")
    card3:SetWidth(400)
    card3:SetEnabled(false)
    stack:AddChild(card3)

    refresh()
end)
