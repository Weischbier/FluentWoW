--- FluentWoW-Gallery -- Pages/ButtonPage.lua
-- Mirrors WinUI Gallery ButtonPage: simple, graphical, built-in styles, wrapping.
-------------------------------------------------------------------------------

local lib = LibStub("FluentWoW-1.0")
local T = lib.Tokens
local Gallery = lib._gallery
local Icons = lib.Icons

Gallery:RegisterControlPage("Button", function(parent, item)
    local _, _, stack, refresh = Gallery:CreateDemoPage(parent)

    -- Page header
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
    -- Example 1: Simple Button with text content
    ---------------------------------------------------------------------------
    local ex1 = Gallery:CreateControlExample(stack, {
        headerText = "A simple Button with text content.",
        exampleHeight = 180,
    })

    local btn1 = lib:CreateButton(ex1.example, nil, "Accent")
    btn1:SetText("Standard XAML button")
    btn1:SetPoint("CENTER")

    ex1.outputLabel:SetText("No interaction yet")

    local disableCheck = lib:CreateCheckBox(ex1.options)
    disableCheck:SetText("Disable button")
    disableCheck:SetPoint("TOPLEFT", ex1.optionsAnchor, "BOTTOMLEFT", 0, -8)
    disableCheck:SetOnChanged(function(_, checked)
        btn1:SetEnabled(not checked)
    end)

    btn1:SetOnClick(function()
        ex1.outputLabel:SetText("You clicked: Standard XAML button")
    end)

    stack:AddChild(ex1.block)

    ---------------------------------------------------------------------------
    -- Example 2: Button with graphical content
    ---------------------------------------------------------------------------
    local ex2 = Gallery:CreateControlExample(stack, {
        headerText = "A Button with graphical content.",
        exampleHeight = 140,
        noOptions = true,
    })

    local graphicBtn = lib:CreateButton(ex2.example, nil, "Subtle")
    graphicBtn:SetSize(56, 56)
    graphicBtn:SetPoint("CENTER")
    graphicBtn:SetText(Icons.PhotoCollection)
    if graphicBtn.Label then
        graphicBtn.Label:SetFont(lib.FLUENT_ICON_FONT, 20, "")
    end

    ex2.outputLabel:SetText("No interaction yet")
    graphicBtn:SetOnClick(function()
        ex2.outputLabel:SetText("You clicked: graphic button")
    end)

    stack:AddChild(ex2.block)

    ---------------------------------------------------------------------------
    -- Example 3: Built-in styles
    ---------------------------------------------------------------------------
    local ex3 = Gallery:CreateControlExample(stack, {
        headerText = "Built-in styles applied to Button.",
        exampleHeight = 120,
        noOutput = true,
        noOptions = true,
    })

    local styleRow = lib:CreateStackLayout(ex3.example, nil, "HORIZONTAL")
    styleRow:SetPoint("CENTER")
    styleRow:SetGap(16)
    styleRow:SetHeight(36)

    local btnAccent = lib:CreateButton(styleRow, nil, "Accent")
    btnAccent:SetText("Accent style button")
    styleRow:AddChild(btnAccent)

    local btnSubtle = lib:CreateButton(styleRow, nil, "Subtle")
    btnSubtle:SetText("Subtle style button")
    styleRow:AddChild(btnSubtle)

    stack:AddChild(ex3.block)

    ---------------------------------------------------------------------------
    -- Example 4: Wrapping / large content
    ---------------------------------------------------------------------------
    local ex4 = Gallery:CreateControlExample(stack, {
        headerText = "Wrapping Buttons with large content.",
        exampleHeight = 240,
        noOutput = true,
        noOptions = true,
    })

    local copy = lib:CreateTextBlock(ex4.example)
    copy:SetPoint("TOPLEFT", ex4.example, "TOPLEFT", 12, -12)
    copy:SetPoint("RIGHT", ex4.example, "RIGHT", -12, 0)
    copy:SetStyle("Caption")
    copy:SetColorKey("Color.Text.Secondary")
    copy:SetText("One option to mitigate clipped content is to place Buttons underneath each other, allowing for more space to grow horizontally:")
    copy:SetWrapping(true)
    copy:SetWidth(640)

    local fullBtn1 = lib:CreateButton(ex4.example, nil, "Accent")
    fullBtn1:SetText("This is some text that is too long and will get cut off")
    fullBtn1:SetPoint("TOPLEFT", copy, "BOTTOMLEFT", 0, -12)
    fullBtn1:SetPoint("RIGHT", ex4.example, "RIGHT", -12, 0)

    local fullBtn2 = lib:CreateButton(ex4.example, nil, "Subtle")
    fullBtn2:SetText("This is another text that would result in being cut off")
    fullBtn2:SetPoint("TOPLEFT", fullBtn1, "BOTTOMLEFT", 0, -8)
    fullBtn2:SetPoint("RIGHT", ex4.example, "RIGHT", -12, 0)

    local inlineRow = lib:CreateStackLayout(ex4.example, nil, "HORIZONTAL")
    inlineRow:SetGap(8)
    inlineRow:SetHeight(36)
    inlineRow:SetPoint("TOPLEFT", fullBtn2, "BOTTOMLEFT", 0, -20)

    local toggleBtn = lib:CreateToggleButton(inlineRow)
    toggleBtn:SetText("ToggleButton")
    inlineRow:AddChild(toggleBtn)

    local iconBtn = lib:CreateIconButton(inlineRow)
    iconBtn:SetIcon("Interface\\Buttons\\UI-GroupLoot-DE-Up")
    inlineRow:AddChild(iconBtn)

    stack:AddChild(ex4.block)

    refresh()
end)
