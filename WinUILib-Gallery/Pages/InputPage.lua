--- WinUILib-Gallery – Pages/InputPage.lua
-- Showcases: CheckBox, RadioButton, ToggleSwitch, TextBox, SearchBox,
--            Slider, ComboBox.
-------------------------------------------------------------------------------

local lib = WinUILib
local Gallery = lib._gallery

Gallery:RegisterPage("input", "Input Controls", function(parent)
    local stack = lib:CreateStackLayout(parent, nil, "VERTICAL")
    stack:SetAllPoints(parent)
    stack:SetGap(16)
    stack:SetPadding(16, 0, 16, 0)

    local header = lib:CreateTextBlock(stack)
    header:SetStyle("Header")
    header:SetText("Input Controls")
    stack:AddChild(header)

    -- CheckBox
    local cbTitle = lib:CreateTextBlock(stack)
    cbTitle:SetStyle("Title")
    cbTitle:SetText("CheckBox")
    stack:AddChild(cbTitle)

    local cb1 = lib:CreateCheckBox(stack)
    cb1:SetText("Two-state CheckBox")
    stack:AddChild(cb1)

    local cb2 = lib:CreateCheckBox(stack)
    cb2:SetText("Three-state")
    cb2:SetChecked("indeterminate")
    stack:AddChild(cb2)

    -- RadioButton
    local rbTitle = lib:CreateTextBlock(stack)
    rbTitle:SetStyle("Title")
    rbTitle:SetText("RadioButton")
    stack:AddChild(rbTitle)

    local rb1 = lib:CreateRadioButton(stack)
    rb1:SetText("Option 1")
    rb1:SetGroup("demo")
    rb1:SetSelected(true)
    stack:AddChild(rb1)

    local rb2 = lib:CreateRadioButton(stack)
    rb2:SetText("Option 2")
    rb2:SetGroup("demo")
    stack:AddChild(rb2)

    -- ToggleSwitch
    local tsTitle = lib:CreateTextBlock(stack)
    tsTitle:SetStyle("Title")
    tsTitle:SetText("ToggleSwitch")
    stack:AddChild(tsTitle)

    local ts = lib:CreateToggleSwitch(stack)
    ts:SetHeader("Wi-Fi")
    stack:AddChild(ts)

    -- TextBox
    local tbTitle = lib:CreateTextBlock(stack)
    tbTitle:SetStyle("Title")
    tbTitle:SetText("TextBox")
    stack:AddChild(tbTitle)

    local tb = lib:CreateTextBox(stack)
    tb:SetPlaceholder("Type something...")
    stack:AddChild(tb)

    -- SearchBox
    local sbTitle = lib:CreateTextBlock(stack)
    sbTitle:SetStyle("Title")
    sbTitle:SetText("SearchBox")
    stack:AddChild(sbTitle)

    local sb = lib:CreateSearchBox(stack)
    sb:SetPlaceholder("Search...")
    stack:AddChild(sb)

    -- Slider
    local slTitle = lib:CreateTextBlock(stack)
    slTitle:SetStyle("Title")
    slTitle:SetText("Slider")
    stack:AddChild(slTitle)

    local sl = lib:CreateSlider(stack)
    sl:SetHeader("Volume")
    sl:SetRange(0, 100)
    sl:SetValue(50)
    sl:SetShowValue(true)
    stack:AddChild(sl)

    -- ComboBox
    local cxTitle = lib:CreateTextBlock(stack)
    cxTitle:SetStyle("Title")
    cxTitle:SetText("ComboBox")
    stack:AddChild(cxTitle)

    local cx = lib:CreateComboBox(stack)
    cx:SetItems({
        { text = "Red", value = "red" },
        { text = "Green", value = "green" },
        { text = "Blue", value = "blue" },
        { text = "Yellow", value = "yellow" },
    })
    cx:SetSelectedIndex(1)
    stack:AddChild(cx)
end)
