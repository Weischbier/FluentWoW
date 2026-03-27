--- WinUILib-Gallery – Pages/SettingsPage.lua
-- Showcases: SettingsCard, SettingsExpander.
-------------------------------------------------------------------------------

local lib = WinUILib
local Gallery = lib._gallery

local function createCardTitle(parent, text)
    local label = lib:CreateTextBlock(parent)
    label:SetStyle("Caption")
    label:SetColorKey("Color.Text.Secondary")
    label:SetText(text)
    return label
end

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
    desc:SetWidth(700)
    stack:AddChild(desc)

    local cardExample, cardBody = Gallery:CreateExampleBlock(stack, "SettingsCard variations with action controls and clickable behavior.", 308)
    local cardArea = Gallery:CreateSurface(cardBody, "Color.Surface.Base")
    cardArea:SetPoint("TOPLEFT", cardBody, "TOPLEFT", 12, -12)
    cardArea:SetPoint("BOTTOMLEFT", cardBody, "BOTTOMLEFT", 12, 12)
    cardArea:SetWidth(460)

    local cardOutput = Gallery:CreateSurface(cardBody)
    cardOutput:SetPoint("TOPLEFT", cardArea, "TOPRIGHT", 12, 0)
    cardOutput:SetPoint("BOTTOMRIGHT", cardBody, "BOTTOMRIGHT", -12, 12)

    local card1 = lib:CreateSettingsCard(cardArea)
    card1:SetTitle("Night mode")
    card1:SetDescription("Reduce blue light in the evening")
    card1:SetIconTexture("Interface\\ICONS\\Spell_Nature_Sleep")
    card1:SetWidth(420)
    card1:SetPoint("TOPLEFT", cardArea, "TOPLEFT", 16, -16)
    local toggle1 = lib:CreateToggleSwitch(card1)
    toggle1:SetWidth(120)
    card1:SetActionControl(toggle1)

    local card2 = lib:CreateSettingsCard(cardArea)
    card2:SetTitle("Display brightness")
    card2:SetDescription("Change the brightness used for your primary display when this profile is active.")
    card2:SetIconTexture("Interface\\ICONS\\INV_Misc_EngGizmos_17")
    card2:SetWidth(420)
    card2:SetPoint("TOPLEFT", card1, "BOTTOMLEFT", 0, -12)
    local slider1 = lib:CreateSlider(card2)
    slider1:SetRange(0, 100)
    slider1:SetValue(75)
    slider1:SetWidth(140)
    slider1:SetShowValue(false)
    card2:SetActionControl(slider1)

    local card3 = lib:CreateSettingsCard(cardArea)
    card3:SetTitle("Launch at sign-in")
    card3:SetDescription("A clickable settings card mirrors the navigable rows used in Windows settings surfaces.")
    card3:SetIconTexture("Interface\\ICONS\\INV_Misc_Note_05")
    card3:SetWidth(420)
    card3:SetPoint("TOPLEFT", card2, "BOTTOMLEFT", 0, -12)
    card3:SetClickable(true)

    local card4 = lib:CreateSettingsCard(cardArea)
    card4:SetTitle("Unavailable setting")
    card4:SetDescription("This long disabled description verifies line wrapping and trailing-content spacing without clipping or collapsing the text region.")
    card4:SetIconTexture("Interface\\ICONS\\INV_Misc_Lockbox_01")
    card4:SetWidth(420)
    card4:SetPoint("TOPLEFT", card3, "BOTTOMLEFT", 0, -12)
    card4:SetEnabled(false)

    local cardOutputTitle = createCardTitle(cardOutput, "Output")
    cardOutputTitle:SetPoint("TOPLEFT", cardOutput, "TOPLEFT", 12, -10)
    local cardOutputLabel = lib:CreateTextBlock(cardOutput)
    cardOutputLabel:SetText("Interact with the cards to inspect layout and behavior")
    cardOutputLabel:SetWrapping(true)
    cardOutputLabel:SetPoint("TOPLEFT", cardOutputTitle, "BOTTOMLEFT", 0, -6)
    cardOutputLabel:SetPoint("RIGHT", cardOutput, "RIGHT", -12, 0)
    toggle1:SetOnToggled(function(_, isOn)
        cardOutputLabel:SetText(isOn and "Night mode enabled" or "Night mode disabled")
    end)
    slider1:SetOnValueChanged(function(_, value)
        cardOutputLabel:SetText("Display brightness: " .. tostring(math.floor(value + 0.5)) .. "%")
    end)
    card3:SetOnClick(function()
        cardOutputLabel:SetText("Clickable card invoked")
    end)
    stack:AddChild(cardExample)

    local expExample, expBody = Gallery:CreateExampleBlock(stack, "SettingsExpander with nested cards and mixed collapsed/expanded states.", 316)
    local expArea = Gallery:CreateSurface(expBody, "Color.Surface.Base")
    expArea:SetPoint("TOPLEFT", expBody, "TOPLEFT", 12, -12)
    expArea:SetPoint("BOTTOMLEFT", expBody, "BOTTOMLEFT", 12, 12)
    expArea:SetWidth(460)

    local expOutput = Gallery:CreateSurface(expBody)
    expOutput:SetPoint("TOPLEFT", expArea, "TOPRIGHT", 12, 0)
    expOutput:SetPoint("BOTTOMRIGHT", expBody, "BOTTOMRIGHT", -12, 12)

    local exp = lib:CreateSettingsExpander(expArea)
    exp:SetTitle("Screen and sleep")
    exp:SetDescription("Power and display timeout settings")
    exp:SetIconTexture("Interface\\ICONS\\INV_Misc_Gear_01")
    exp:SetWidth(420)
    exp:SetPoint("TOPLEFT", expArea, "TOPLEFT", 16, -16)

    for _, label in ipairs({"Turn off screen after", "Put device to sleep after", "Hibernate after"}) do
        local c = lib:CreateSettingsCard(exp)
        c:SetTitle(label)
        c:SetIconTexture("Interface\\ICONS\\INV_Misc_PocketWatch_01")
        c:SetWidth(420)
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

    local compact = lib:CreateSettingsExpander(expArea)
    compact:SetTitle("Audio")
    compact:SetDescription("Collapsed group")
    compact:SetIconTexture("Interface\\ICONS\\INV_Misc_Horn_04")
    compact:SetWidth(420)
    compact:SetPoint("TOPLEFT", exp, "BOTTOMLEFT", 0, -16)
    local compactCard = lib:CreateSettingsCard(compact)
    compactCard:SetTitle("Default output")
    compactCard:SetWidth(420)
    local compactToggle = lib:CreateToggleSwitch(compactCard)
    compactToggle:SetWidth(120)
    compactCard:SetActionControl(compactToggle)
    compact:AddCard(compactCard)
    exp:SetExpanded(true, true)

    local expOutputTitle = createCardTitle(expOutput, "Output")
    expOutputTitle:SetPoint("TOPLEFT", expOutput, "TOPLEFT", 12, -10)
    local expOutputLabel = lib:CreateTextBlock(expOutput)
    expOutputLabel:SetText("Expand or collapse the grouped settings")
    expOutputLabel:SetWrapping(true)
    expOutputLabel:SetPoint("TOPLEFT", expOutputTitle, "BOTTOMLEFT", 0, -6)
    expOutputLabel:SetPoint("RIGHT", expOutput, "RIGHT", -12, 0)
    exp:SetOnToggled(function(_, expanded)
        expOutputLabel:SetText(expanded and "Screen and sleep expanded" or "Screen and sleep collapsed")
    end)
    compact:SetOnToggled(function(_, expanded)
        expOutputLabel:SetText(expanded and "Audio expanded" or "Audio collapsed")
    end)
    stack:AddChild(expExample)

    refresh()
end)
