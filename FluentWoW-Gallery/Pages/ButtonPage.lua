--- FluentWoW-Gallery – Pages/ButtonPage.lua
-- Showcases Button (Accent/Subtle/Destructive), IconButton, ToggleButton.
-------------------------------------------------------------------------------

local lib = LibStub("FluentWoW-1.0")
local T = lib.Tokens
local Gallery = lib._gallery

local function createSurface(parent, inset)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetClipsChildren(true)

    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(T:GetColor("Color.Surface.Raised"))
    frame.BG = bg

    local edgeTop = frame:CreateTexture(nil, "BORDER")
    edgeTop:SetHeight(1)
    edgeTop:SetPoint("TOPLEFT")
    edgeTop:SetPoint("TOPRIGHT")
    edgeTop:SetColorTexture(T:GetColor("Color.Border.Subtle"))

    local edgeBottom = frame:CreateTexture(nil, "BORDER")
    edgeBottom:SetHeight(1)
    edgeBottom:SetPoint("BOTTOMLEFT")
    edgeBottom:SetPoint("BOTTOMRIGHT")
    edgeBottom:SetColorTexture(T:GetColor("Color.Border.Subtle"))

    local edgeLeft = frame:CreateTexture(nil, "BORDER")
    edgeLeft:SetWidth(1)
    edgeLeft:SetPoint("TOPLEFT", 0, -1)
    edgeLeft:SetPoint("BOTTOMLEFT", 0, 1)
    edgeLeft:SetColorTexture(T:GetColor("Color.Border.Subtle"))

    local edgeRight = frame:CreateTexture(nil, "BORDER")
    edgeRight:SetWidth(1)
    edgeRight:SetPoint("TOPRIGHT", 0, -1)
    edgeRight:SetPoint("BOTTOMRIGHT", 0, 1)
    edgeRight:SetColorTexture(T:GetColor("Color.Border.Subtle"))

    if inset then
        frame:SetPoint("TOPLEFT", inset, -inset)
        frame:SetPoint("BOTTOMRIGHT", -inset, inset)
    end

    return frame
end

local function createExampleBlock(parent, headerText, height)
    local block = CreateFrame("Frame", nil, parent)
    block:SetHeight(height + T:GetNumber("Spacing.XXXL"))

    local header = lib:CreateTextBlock(block)
    header:SetStyle("BodyBold")
    header:SetText(headerText)
    header:SetPoint("TOPLEFT", block, "TOPLEFT", 0, 0)
    header:SetPoint("TOPRIGHT", block, "TOPRIGHT", 0, 0)

    local body = createSurface(block)
    body:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -T:GetNumber("Spacing.LG"))
    body:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", 0, -T:GetNumber("Spacing.LG"))
    body:SetHeight(height)

    return block, body
end

local function createCardTitle(parent, text)
    local label = lib:CreateTextBlock(parent)
    label:SetStyle("Caption")
    label:SetColorKey("Color.Text.Secondary")
    label:SetText(text)
    return label
end

Gallery:RegisterPage("buttons", "Buttons", function(parent)
    local _, _, stack, refresh = Gallery:CreateDemoPage(parent)

    local header = lib:CreateTextBlock(stack)
    header:SetStyle("Header")
    header:SetText("Buttons")
    stack:AddChild(header)

    local desc = lib:CreateTextBlock(stack)
    desc:SetText("Mirrors the WinUI Gallery Button page: simple content, graphical content, built-in styles, and large-content layout behavior.")
    desc:SetColorKey("Color.Text.Secondary")
    desc:SetWrapping(true)
    desc:SetWidth(680)
    stack:AddChild(desc)

    local example1, body1 = createExampleBlock(stack, "A simple Button with text content.", 180)
    local exampleArea1 = createSurface(body1)
    exampleArea1:SetPoint("TOPLEFT", body1, "TOPLEFT", 12, -12)
    exampleArea1:SetPoint("BOTTOMLEFT", body1, "BOTTOMLEFT", 12, 12)
    exampleArea1:SetWidth(360)
    exampleArea1.BG:SetColorTexture(T:GetColor("Color.Surface.Base"))

    local outputArea1 = createSurface(body1)
    outputArea1:SetPoint("TOPLEFT", exampleArea1, "TOPRIGHT", 12, 0)
    outputArea1:SetPoint("TOPRIGHT", body1, "TOPRIGHT", -12, -12)
    outputArea1:SetHeight(72)

    local optionsArea1 = createSurface(body1)
    optionsArea1:SetPoint("TOPLEFT", outputArea1, "BOTTOMLEFT", 0, -12)
    optionsArea1:SetPoint("BOTTOMRIGHT", body1, "BOTTOMRIGHT", -12, 12)

    local btn1 = lib:CreateButton(exampleArea1, nil, "Accent")
    btn1:SetText("Standard XAML button")
    btn1:SetPoint("CENTER")

    local outputLabel1 = createCardTitle(outputArea1, "Output")
    outputLabel1:SetPoint("TOPLEFT", outputArea1, "TOPLEFT", 12, -10)
    local outputText1 = lib:CreateTextBlock(outputArea1)
    outputText1:SetColorKey("Color.Text.Primary")
    outputText1:SetText("No interaction yet")
    outputText1:SetPoint("TOPLEFT", outputLabel1, "BOTTOMLEFT", 0, -6)
    outputText1:SetPoint("RIGHT", outputArea1, "RIGHT", -12, 0)

    local optionsLabel1 = createCardTitle(optionsArea1, "Options")
    optionsLabel1:SetPoint("TOPLEFT", optionsArea1, "TOPLEFT", 12, -10)
    local disableButton1 = lib:CreateCheckBox(optionsArea1)
    disableButton1:SetText("Disable button")
    disableButton1:SetPoint("TOPLEFT", optionsLabel1, "BOTTOMLEFT", 0, -8)
    disableButton1:SetOnChanged(function(_, checked)
        btn1:SetEnabled(not checked)
    end)
    btn1:SetOnClick(function()
        outputText1:SetText("Button clicked")
    end)
    stack:AddChild(example1)

    local example2, body2 = createExampleBlock(stack, "A Button with graphical content.", 140)
    local exampleArea2 = createSurface(body2)
    exampleArea2:SetPoint("TOPLEFT", body2, "TOPLEFT", 12, -12)
    exampleArea2:SetPoint("BOTTOMLEFT", body2, "BOTTOMLEFT", 12, 12)
    exampleArea2:SetPoint("RIGHT", body2, "RIGHT", -184, 0)
    exampleArea2.BG:SetColorTexture(T:GetColor("Color.Surface.Base"))

    local outputArea2 = createSurface(body2)
    outputArea2:SetPoint("TOPRIGHT", body2, "TOPRIGHT", -12, -12)
    outputArea2:SetPoint("BOTTOMRIGHT", body2, "BOTTOMRIGHT", -12, 12)
    outputArea2:SetWidth(160)

    local graphicButton = lib:CreateButton(exampleArea2, nil, "Subtle")
    graphicButton:SetSize(56, 56)
    graphicButton:SetPoint("CENTER")
    graphicButton:SetText("")
    local slice = graphicButton:CreateTexture(nil, "ARTWORK")
    slice:SetSize(28, 28)
    slice:SetPoint("CENTER")
    slice:SetTexture("Interface\\Buttons\\UI-GroupLoot-Coin-Up")
    slice:SetVertexColor(T:GetColor("Color.Accent.Primary"))

    local outputLabel2 = createCardTitle(outputArea2, "Output")
    outputLabel2:SetPoint("TOPLEFT", outputArea2, "TOPLEFT", 12, -10)
    local outputText2 = lib:CreateTextBlock(outputArea2)
    outputText2:SetText("No interaction yet")
    outputText2:SetPoint("TOPLEFT", outputLabel2, "BOTTOMLEFT", 0, -6)
    outputText2:SetPoint("RIGHT", outputArea2, "RIGHT", -12, 0)
    graphicButton:SetOnClick(function()
        outputText2:SetText("Graphic button clicked")
    end)
    stack:AddChild(example2)

    local example3, body3 = createExampleBlock(stack, "Built-in styles applied to Button.", 120)
    local exampleArea3 = createSurface(body3)
    exampleArea3:SetPoint("TOPLEFT", body3, "TOPLEFT", 12, -12)
    exampleArea3:SetPoint("BOTTOMRIGHT", body3, "BOTTOMRIGHT", -12, 12)
    exampleArea3.BG:SetColorTexture(T:GetColor("Color.Surface.Base"))

    local styleRow = lib:CreateStackLayout(exampleArea3, nil, "HORIZONTAL")
    styleRow:SetPoint("CENTER")
    styleRow:SetGap(16)
    styleRow:SetHeight(36)

    local btnAccent = lib:CreateButton(styleRow, nil, "Accent")
    btnAccent:SetText("Accent style button")
    styleRow:AddChild(btnAccent)

    local btnSubtle = lib:CreateButton(styleRow, nil, "Subtle")
    btnSubtle:SetText("Subtle style button")
    styleRow:AddChild(btnSubtle)

    stack:AddChild(example3)

    local example4, body4 = createExampleBlock(stack, "Wrapping Buttons with large content.", 220)
    local copy = lib:CreateTextBlock(body4)
    copy:SetPoint("TOPLEFT", body4, "TOPLEFT", 12, -12)
    copy:SetPoint("RIGHT", body4, "RIGHT", -12, 0)
    copy:SetStyle("Caption")
    copy:SetColorKey("Color.Text.Secondary")
    copy:SetText("The source page demonstrates how large button content behaves. WoW cannot do XAML-style wrapped button content natively, so this section shows the closest layout-safe equivalent: full-width buttons stacked vertically.")
    copy:SetWrapping(true)
    copy:SetWidth(640)

    local fullWidthButton1 = lib:CreateButton(body4, nil, "Accent")
    fullWidthButton1:SetText("This is some text that is too long and would clip in a cramped horizontal layout")
    fullWidthButton1:SetPoint("TOPLEFT", copy, "BOTTOMLEFT", 0, -12)
    fullWidthButton1:SetPoint("RIGHT", body4, "RIGHT", -12, 0)

    local fullWidthButton2 = lib:CreateButton(body4, nil, "Subtle")
    fullWidthButton2:SetText("This is another text example for a large content button")
    fullWidthButton2:SetPoint("TOPLEFT", fullWidthButton1, "BOTTOMLEFT", 0, -8)
    fullWidthButton2:SetPoint("RIGHT", body4, "RIGHT", -12, 0)

    local inlineRow = lib:CreateStackLayout(body4, nil, "HORIZONTAL")
    inlineRow:SetGap(8)
    inlineRow:SetHeight(36)
    inlineRow:SetPoint("TOPLEFT", fullWidthButton2, "BOTTOMLEFT", 0, -20)

    local toggleBtn = lib:CreateToggleButton(inlineRow)
    toggleBtn:SetText("Toggle me")
    inlineRow:AddChild(toggleBtn)

    local iconBtn = lib:CreateIconButton(inlineRow)
    iconBtn:SetIcon("Interface\\Buttons\\UI-GroupLoot-DE-Up")
    inlineRow:AddChild(iconBtn)

    stack:AddChild(example4)

    refresh()
end)
