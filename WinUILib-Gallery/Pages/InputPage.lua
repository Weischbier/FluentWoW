--- WinUILib-Gallery – Pages/InputPage.lua
-- Demonstrates CheckBox, RadioButton, ToggleSwitch, TextBox, Slider, ComboBox.
-------------------------------------------------------------------------------

local WUIL    = WinUILib
local Gallery = WinUILibGallery

Gallery:RegisterPage("input", "Input Controls", function(parent)

    local scroll = WUIL:CreateScrollFrame(parent)
    scroll:SetAllPoints()
    local content = scroll:GetScrollChild()
    content:SetWidth(parent:GetWidth() - 32)
    content:SetHeight(800)

    local function SectionLabel(text, anchor, yOff)
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

    -- ── CheckBox ────────────────────────────────────────────────────────────
    local topAnchor = content
    local h1 = topAnchor:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    h1:SetPoint("TOPLEFT", topAnchor, "TOPLEFT", 24, -16)
    h1:SetText("CheckBox")
    h1:SetTextColor(0.95, 0.95, 0.97)

    local n1 = Note("Three-state capable: Unchecked / Checked / Indeterminate.", h1)

    local cb1 = WUIL:CreateCheckBox(content, "Notifications enabled", false)
    cb1:SetPoint("TOPLEFT", n1, "BOTTOMLEFT", 0, -12)
    local cb2 = WUIL:CreateCheckBox(content, "Show minimap button", true)
    cb2:SetPoint("TOPLEFT", cb1, "BOTTOMLEFT", 0, -8)
    local cb3 = WUIL:CreateCheckBox(content, "Partially configured (indeterminate)",
                                     "Indeterminate")
    cb3:SetPoint("TOPLEFT", cb2, "BOTTOMLEFT", 0, -8)
    cb3:SetEnabled(false)

    -- ── RadioButton ─────────────────────────────────────────────────────────
    local h2 = SectionLabel("RadioButton", cb3, -24)
    local n2 = Note("Only one option in a group may be selected at a time.", h2)

    local rb1 = WUIL:CreateRadioButton(content, "Small",  "size_group")
    rb1:SetPoint("TOPLEFT", n2, "BOTTOMLEFT", 0, -12)
    local rb2 = WUIL:CreateRadioButton(content, "Medium", "size_group")
    rb2:SetPoint("TOPLEFT", rb1, "BOTTOMLEFT", 0, -6)
    local rb3 = WUIL:CreateRadioButton(content, "Large",  "size_group")
    rb3:SetPoint("TOPLEFT", rb2, "BOTTOMLEFT", 0, -6)
    rb2:Select()   -- default selection

    -- ── ToggleSwitch ────────────────────────────────────────────────────────
    local h3 = SectionLabel("ToggleSwitch", rb3, -24)
    local n3 = Note("Instant on/off – best for settings that take effect immediately.", h3)

    local ts1 = WUIL:CreateToggleSwitch(content, "On", "Off")
    ts1:SetPoint("TOPLEFT", n3, "BOTTOMLEFT", 0, -12)
    ts1:SetWidth(220)
    ts1:SetOn(true)

    local ts2 = WUIL:CreateToggleSwitch(content, "Enabled", "Disabled")
    ts2:SetPoint("TOPLEFT", ts1, "BOTTOMLEFT", 0, -8)
    ts2:SetWidth(220)

    -- ── TextBox ─────────────────────────────────────────────────────────────
    local h4 = SectionLabel("TextBox", ts2, -24)
    local n4 = Note("Focused input with placeholder text and validation states.", h4)

    local tb1 = WUIL:CreateTextBox(content, "Enter your name…", 280)
    tb1:SetPoint("TOPLEFT", n4, "BOTTOMLEFT", 0, -12)

    local tb2 = WUIL:CreateSearchBox(content, "Search controls…")
    tb2:SetPoint("TOPLEFT", tb1, "BOTTOMLEFT", 0, -8)
    tb2:SetWidth(280)

    local tbErr = WUIL:CreateTextBox(content, "Invalid value", 280)
    tbErr:SetPoint("TOPLEFT", tb2, "BOTTOMLEFT", 0, -8)
    tbErr:SetText("bad@@@input")
    tbErr:SetValidationState("Error", "Value contains invalid characters")

    -- ── Slider ──────────────────────────────────────────────────────────────
    local h5 = SectionLabel("Slider", tbErr, -24)
    local n5 = Note("Select a value within a range.  Supports step snapping.", h5)

    local sl1 = WUIL:CreateSlider(content, 0, 100, 40)
    sl1:SetPoint("TOPLEFT", n5, "BOTTOMLEFT", 0, -12)
    sl1:SetWidth(280)
    sl1:SetShowValueLabel(true)

    -- ── ComboBox ────────────────────────────────────────────────────────────
    local h6 = SectionLabel("ComboBox", sl1, -24)
    local n6 = Note("Dropdown selection; blocked during combat lockdown.", h6)

    local items = {
        { text = "Normal", value = "normal" },
        { text = "Heroic", value = "heroic" },
        { text = "Mythic", value = "mythic" },
    }
    local cb = WUIL:CreateComboBox(content, items)
    cb:SetPoint("TOPLEFT", n6, "BOTTOMLEFT", 0, -12)
    cb:SetWidth(200)
    cb:SetPlaceholder("Select difficulty…")
    cb.OnSelectionChanged = function(self, text, value, idx)
        WUIL:Debug("ComboBox selected: " .. text)
    end
end)
