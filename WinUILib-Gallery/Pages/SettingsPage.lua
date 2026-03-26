--- WinUILib-Gallery – Pages/SettingsPage.lua
-- Demonstrates SettingsCard and SettingsExpander as a sample settings panel.
-------------------------------------------------------------------------------

local WUIL    = WinUILib
local Gallery = WinUILibGallery

Gallery:RegisterPage("settings", "Settings Controls", function(parent)

    local scroll = WUIL:CreateScrollFrame(parent)
    scroll:SetAllPoints()
    local content = scroll:GetScrollChild()
    content:SetWidth(parent:GetWidth() - 32)
    content:SetHeight(800)

    local function Hdr(text, anchor, yOff)
        local h = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        h:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, yOff or -16)
        h:SetText(text)
        h:SetTextColor(0.95, 0.95, 0.97)
        return h
    end
    local function Note(text, anchor, yOff)
        local d = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        d:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, yOff or -4)
        d:SetPoint("RIGHT", content, "RIGHT", -24, 0)
        d:SetText(text)
        d:SetTextColor(0.68, 0.68, 0.72)
        d:SetWordWrap(true)
        return d
    end

    -- ── SettingsCard ─────────────────────────────────────────────────────────
    local topRef = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    topRef:SetPoint("TOPLEFT", content, "TOPLEFT", 24, -16)
    topRef:SetText("SettingsCard")
    topRef:SetTextColor(0.95, 0.95, 0.97)
    local n1 = Note(
        "Each SettingsCard holds an icon, a title, an optional description, "
        .. "and a control placed on the trailing edge.",
        topRef)

    -- Card 1: ToggleSwitch
    local ts = WUIL:CreateToggleSwitch(nil, "On", "Off")
    ts:SetWidth(120)
    ts:SetOn(true)
    local card1 = WUIL:CreateSettingsCard(content,
        "Enable notifications",
        "Show a message when new events occur.", ts)
    card1:SetPoint("TOPLEFT", n1, "BOTTOMLEFT", 0, -12)
    card1:SetWidth(560)

    -- Card 2: ComboBox
    local combo = WUIL:CreateComboBox(nil, {
        { text = "Low",    value = 1 },
        { text = "Medium", value = 2 },
        { text = "High",   value = 3 },
    })
    combo:SetWidth(120)
    combo:SetSelectedIndex(2)
    local card2 = WUIL:CreateSettingsCard(content,
        "Alert verbosity",
        "Controls how much information is shown in alerts.", combo)
    card2:SetPoint("TOPLEFT", card1, "BOTTOMLEFT", 0, -4)
    card2:SetWidth(560)

    -- Card 3: CheckBox (no description)
    local chk = WUIL:CreateCheckBox(nil, nil, false)
    chk:SetWidth(20)
    local card3 = WUIL:CreateSettingsCard(content,
        "Hide during combat", nil, chk)
    card3:SetPoint("TOPLEFT", card2, "BOTTOMLEFT", 0, -4)
    card3:SetWidth(560)
    card3:SetHeight(44)

    -- ── SettingsExpander ──────────────────────────────────────────────────────
    local h2 = Hdr("SettingsExpander", card3, -24)
    local n2 = Note(
        "Collapses a group of related SettingsCards under a single header.  "
        .. "Click the card to expand/collapse.",
        h2)

    local expander = WUIL:CreateSettingsExpander(content,
        "Advanced Options",
        "Performance tuning and developer settings")
    expander:SetPoint("TOPLEFT", n2, "BOTTOMLEFT", 0, -12)
    expander:SetWidth(560)

    -- Nested cards
    local ts2 = WUIL:CreateToggleSwitch(nil, "On", "Off")
    ts2:SetWidth(120)
    local nested1 = WUIL:CreateSettingsCard(nil,
        "Debug logging",
        "Write verbose logs to the chat frame.", ts2)
    nested1:SetWidth(560)
    expander:AddItem(nested1)

    local ts3 = WUIL:CreateToggleSwitch(nil, "On", "Off")
    ts3:SetWidth(120)
    local nested2 = WUIL:CreateSettingsCard(nil,
        "Performance profiling",
        "Measure update loop timing. Disable in production.", ts3)
    nested2:SetWidth(560)
    expander:AddItem(nested2)

    local sl = WUIL:CreateSlider(nil, 1, 60, 30)
    sl:SetWidth(160)
    sl:SetShowValueLabel(true)
    local nested3 = WUIL:CreateSettingsCard(nil,
        "Update interval (sec)",
        "How often the UI refreshes background data.", sl)
    nested3:SetWidth(560)
    expander:AddItem(nested3)
end)
