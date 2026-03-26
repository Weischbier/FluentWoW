--- WinUILib-Gallery – Pages/ButtonPage.lua
-- Showcases Button (Accent/Subtle/Destructive), IconButton, ToggleButton.
-------------------------------------------------------------------------------

local lib = WinUILib
local Gallery = lib._gallery

Gallery:RegisterPage("buttons", "Buttons", function(parent)
    local stack = lib:CreateStackLayout(parent, nil, "VERTICAL")
    stack:SetAllPoints(parent)
    stack:SetGap(16)
    stack:SetPadding(16, 0, 16, 0)

    -- Section header
    local header = lib:CreateTextBlock(stack)
    header:SetStyle("Header")
    header:SetText("Button")
    stack:AddChild(header)

    local desc = lib:CreateTextBlock(stack)
    desc:SetText("A control that responds to user input and raises a Click event.")
    desc:SetWrapping(true)
    stack:AddChild(desc)

    -- Accent button (default)
    local row1 = lib:CreateStackLayout(stack, nil, "HORIZONTAL")
    row1:SetGap(8)
    row1:SetHeight(36)

    local btnAccent = lib:CreateButton(row1, nil, "Accent")
    btnAccent:SetText("Accent")
    row1:AddChild(btnAccent)

    local btnSubtle = lib:CreateButton(row1, nil, "Subtle")
    btnSubtle:SetText("Subtle")
    row1:AddChild(btnSubtle)

    local btnDestructive = lib:CreateButton(row1, nil, "Destructive")
    btnDestructive:SetText("Destructive")
    row1:AddChild(btnDestructive)

    stack:AddChild(row1)

    -- Disabled variants
    local disabledHeader = lib:CreateTextBlock(stack)
    disabledHeader:SetStyle("Title")
    disabledHeader:SetText("Disabled")
    stack:AddChild(disabledHeader)

    local row2 = lib:CreateStackLayout(stack, nil, "HORIZONTAL")
    row2:SetGap(8)
    row2:SetHeight(36)

    local btnDis = lib:CreateButton(row2, nil, "Accent")
    btnDis:SetText("Disabled")
    btnDis:SetEnabled(false)
    row2:AddChild(btnDis)

    stack:AddChild(row2)

    -- Icon button
    local iconHeader = lib:CreateTextBlock(stack)
    iconHeader:SetStyle("Title")
    iconHeader:SetText("Icon Button")
    stack:AddChild(iconHeader)

    local iconBtn = lib:CreateIconButton(stack)
    iconBtn:SetIcon("Interface\\Buttons\\UI-GroupLoot-Coin-Up")
    stack:AddChild(iconBtn)

    -- Toggle button
    local toggleHeader = lib:CreateTextBlock(stack)
    toggleHeader:SetStyle("Title")
    toggleHeader:SetText("Toggle Button")
    stack:AddChild(toggleHeader)

    local toggleBtn = lib:CreateToggleButton(stack)
    toggleBtn:SetText("Toggle me")
    stack:AddChild(toggleBtn)
end)
