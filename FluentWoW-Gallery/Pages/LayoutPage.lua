--- FluentWoW-Gallery – Pages/LayoutPage.lua
-- Showcases: StackLayout (VStack/HStack), TabView, ScrollFrame.
-------------------------------------------------------------------------------

local lib = LibStub("FluentWoW-1.0")
local Gallery = lib._gallery

local function createCardTitle(parent, text)
    local label = lib:CreateTextBlock(parent)
    label:SetStyle("Caption")
    label:SetColorKey("Color.Text.Secondary")
    label:SetText(text)
    return label
end

Gallery:RegisterPage("layout", "Layout", function(parent)
    local _, _, stack, refresh = Gallery:CreateDemoPage(parent)

    local header = lib:CreateTextBlock(stack)
    header:SetStyle("Header")
    header:SetText("Layout Controls")
    stack:AddChild(header)

    local desc = lib:CreateTextBlock(stack)
    desc:SetText("StackLayout, TabView, and ScrollFrame are grouped here using the same example surfaces as the other gallery pages. The focus is on composition, tab management, and scroll behavior.")
    desc:SetColorKey("Color.Text.Secondary")
    desc:SetWrapping(true)
    desc:SetWidth(700)
    stack:AddChild(desc)

    local textExample, textBody = Gallery:CreateExampleBlock(stack, "TextBlock typography, color, and wrapping.", 168)
    local textArea = Gallery:CreateSurface(textBody, "Color.Surface.Base")
    textArea:SetPoint("TOPLEFT", textBody, "TOPLEFT", 12, -12)
    textArea:SetPoint("BOTTOMLEFT", textBody, "BOTTOMLEFT", 12, 12)
    textArea:SetWidth(420)

    local textOutput = Gallery:CreateSurface(textBody)
    textOutput:SetPoint("TOPLEFT", textArea, "TOPRIGHT", 12, 0)
    textOutput:SetPoint("BOTTOMRIGHT", textBody, "BOTTOMRIGHT", -12, 12)

    local tb1 = lib:CreateTextBlock(textArea)
    tb1:SetText("I am a TextBlock.")
    tb1:SetPoint("TOPLEFT", textArea, "TOPLEFT", 16, -16)

    local tb2 = lib:CreateTextBlock(textArea)
    tb2:SetStyle("Title")
    tb2:SetText("I am a styled TextBlock.")
    tb2:SetPoint("TOPLEFT", tb1, "BOTTOMLEFT", 0, -14)

    local tb3 = lib:CreateTextBlock(textArea)
    tb3:SetStyle("BodyBold")
    tb3:SetColorKey("Color.Accent.Primary")
    tb3:SetWrapping(true)
    tb3:SetWidth(360)
    tb3:SetText("I am super excited to be here! This sample approximates the styled and wrapped cases from the WinUI Gallery using tokenized typography and color.")
    tb3:SetPoint("TOPLEFT", tb2, "BOTTOMLEFT", 0, -14)

    local tb4 = lib:CreateTextBlock(textArea)
    tb4:SetStyle("Caption")
    tb4:SetColorKey("Color.Text.Secondary")
    tb4:SetWrapping(true)
    tb4:SetWidth(360)
    tb4:SetText("Inline runs, selection highlight, and rich text semantics remain limited by the WoW FontString platform, so this section demonstrates the closest token-driven equivalent.")
    tb4:SetPoint("TOPLEFT", tb3, "BOTTOMLEFT", 0, -14)

    local textOutputTitle = createCardTitle(textOutput, "Output")
    textOutputTitle:SetPoint("TOPLEFT", textOutput, "TOPLEFT", 12, -10)
    local textOutputLabel = lib:CreateTextBlock(textOutput)
    textOutputLabel:SetText("TextBlock coverage now includes its own demo surface in the gallery.")
    textOutputLabel:SetWrapping(true)
    textOutputLabel:SetPoint("TOPLEFT", textOutputTitle, "BOTTOMLEFT", 0, -6)
    textOutputLabel:SetPoint("RIGHT", textOutput, "RIGHT", -12, 0)
    stack:AddChild(textExample)

    local stackExample, stackBody = Gallery:CreateExampleBlock(stack, "Horizontal and vertical StackLayout composition.", 180)
    local stackArea = Gallery:CreateSurface(stackBody, "Color.Surface.Base")
    stackArea:SetPoint("TOPLEFT", stackBody, "TOPLEFT", 12, -12)
    stackArea:SetPoint("BOTTOMLEFT", stackBody, "BOTTOMLEFT", 12, 12)
    stackArea:SetWidth(420)

    local stackOutput = Gallery:CreateSurface(stackBody)
    stackOutput:SetPoint("TOPLEFT", stackArea, "TOPRIGHT", 12, 0)
    stackOutput:SetPoint("BOTTOMRIGHT", stackBody, "BOTTOMRIGHT", -12, 12)

    local hStack = lib:CreateStackLayout(stackArea, nil, "HORIZONTAL")
    hStack:SetGap(8)
    hStack:SetHeight(36)
    hStack:SetPoint("TOPLEFT", stackArea, "TOPLEFT", 16, -20)
    for i = 1, 3 do
        local b = lib:CreateButton(hStack, nil, i == 1 and "Accent" or "Subtle")
        b:SetText("Item " .. i)
        hStack:AddChild(b)
    end

    local vStack = lib:CreateStackLayout(stackArea, nil, "VERTICAL")
    vStack:SetGap(8)
    vStack:SetWidth(240)
    vStack:SetPoint("TOPLEFT", hStack, "BOTTOMLEFT", 0, -24)
    for _, label in ipairs({"First row", "Second row", "Third row"}) do
        local line = lib:CreateTextBlock(vStack)
        line:SetText(label)
        vStack:AddChild(line)
    end

    local stackOutputTitle = createCardTitle(stackOutput, "Output")
    stackOutputTitle:SetPoint("TOPLEFT", stackOutput, "TOPLEFT", 12, -10)
    local stackOutputLabel = lib:CreateTextBlock(stackOutput)
    stackOutputLabel:SetText("StackLayout arranges content horizontally and vertically with tokenized gaps.")
    stackOutputLabel:SetWrapping(true)
    stackOutputLabel:SetPoint("TOPLEFT", stackOutputTitle, "BOTTOMLEFT", 0, -6)
    stackOutputLabel:SetPoint("RIGHT", stackOutput, "RIGHT", -12, 0)
    stack:AddChild(stackExample)

    local tabExample, tabBody = Gallery:CreateExampleBlock(stack, "TabView with icons, close buttons, add button, and strip header/footer.", 284)
    local tabArea = Gallery:CreateSurface(tabBody, "Color.Surface.Base")
    tabArea:SetPoint("TOPLEFT", tabBody, "TOPLEFT", 12, -12)
    tabArea:SetPoint("BOTTOMLEFT", tabBody, "BOTTOMLEFT", 12, 12)
    tabArea:SetWidth(500)

    local tabOutput = Gallery:CreateSurface(tabBody)
    tabOutput:SetPoint("TOPLEFT", tabArea, "TOPRIGHT", 12, 0)
    tabOutput:SetPoint("BOTTOMRIGHT", tabBody, "BOTTOMRIGHT", -12, 12)

    local tv = lib:CreateTabView(tabArea)
    tv:SetSize(460, 240)
    tv:SetPoint("TOPLEFT", tabArea, "TOPLEFT", 16, -16)
    tv:SetAddButtonVisible(true)

    local headerBadge = lib:CreateTextBlock(tabArea)
    headerBadge:SetText("Header")
    headerBadge:SetColorKey("Color.Text.Secondary")
    tv:SetTabStripHeader(headerBadge, 56)

    local footerBadge = lib:CreateTextBlock(tabArea)
    footerBadge:SetText("Footer")
    footerBadge:SetColorKey("Color.Text.Secondary")
    tv:SetTabStripFooter(footerBadge, 56)

    local tabs = {}
    for i = 1, 3 do
        local f = CreateFrame("Frame", nil, tv)
        local t = lib:CreateTextBlock(f)
        t:SetText("Content for Document " .. i)
        t:SetPoint("TOPLEFT", 12, -12)
        tabs[i] = {
            text = "Document " .. i,
            content = f,
            closable = i > 1,
            icon = "Interface\\MINIMAP\\TRACKING\\None",
        }
    end
    tv:SetTabs(tabs)
    tv:SelectTab(1)

    local tabOutputTitle = createCardTitle(tabOutput, "Output")
    tabOutputTitle:SetPoint("TOPLEFT", tabOutput, "TOPLEFT", 12, -10)
    local tabOutputLabel = lib:CreateTextBlock(tabOutput)
    tabOutputLabel:SetText("Select, add, or close tabs")
    tabOutputLabel:SetWrapping(true)
    tabOutputLabel:SetPoint("TOPLEFT", tabOutputTitle, "BOTTOMLEFT", 0, -6)
    tabOutputLabel:SetPoint("RIGHT", tabOutput, "RIGHT", -12, 0)
    tv:SetOnTabChanged(function(_, index)
        tabOutputLabel:SetText("Selected tab index: " .. tostring(index))
    end)
    tv:SetOnAddTab(function(control)
        local index = #control._tabs + 1
        local f = CreateFrame("Frame", nil, control)
        local t = lib:CreateTextBlock(f)
        t:SetText("Content for Document " .. index)
        t:SetPoint("TOPLEFT", 12, -12)
        control:AddTab({
            text = "Document " .. index,
            content = f,
            closable = true,
            icon = "Interface\\MINIMAP\\TRACKING\\None",
        })
        tabOutputLabel:SetText("Added tab " .. tostring(index))
    end)
    tv:SetOnTabCloseRequested(function(control, index)
        control:RemoveTab(index)
        tabOutputLabel:SetText("Closed tab " .. tostring(index))
    end)
    stack:AddChild(tabExample)

    local scrollExample, scrollBody = Gallery:CreateExampleBlock(stack, "ScrollFrame with draggable thumb and long content.", 244)
    local scrollArea = Gallery:CreateSurface(scrollBody, "Color.Surface.Base")
    scrollArea:SetPoint("TOPLEFT", scrollBody, "TOPLEFT", 12, -12)
    scrollArea:SetPoint("BOTTOMLEFT", scrollBody, "BOTTOMLEFT", 12, 12)
    scrollArea:SetWidth(420)

    local scrollOutput = Gallery:CreateSurface(scrollBody)
    scrollOutput:SetPoint("TOPLEFT", scrollArea, "TOPRIGHT", 12, 0)
    scrollOutput:SetPoint("BOTTOMRIGHT", scrollBody, "BOTTOMRIGHT", -12, 12)

    local sf = lib:CreateScrollFrame(scrollArea)
    sf:SetSize(380, 200)
    sf:SetPoint("TOPLEFT", scrollArea, "TOPLEFT", 16, -16)
    sf:SetContentHeight(560)
    local child = sf:GetScrollChild()
    for i = 1, 24 do
        local line = lib:CreateTextBlock(child)
        line:SetText("Scrollable line " .. i .. " demonstrates wheel and thumb dragging behavior.")
        line:SetPoint("TOPLEFT", child, "TOPLEFT", 4, -((i - 1) * 22))
        line:SetWidth(330)
    end

    local scrollOutputTitle = createCardTitle(scrollOutput, "Output")
    scrollOutputTitle:SetPoint("TOPLEFT", scrollOutput, "TOPLEFT", 12, -10)
    local scrollOutputLabel = lib:CreateTextBlock(scrollOutput)
    scrollOutputLabel:SetText("Use the mouse wheel or drag the thumb")
    scrollOutputLabel:SetWrapping(true)
    scrollOutputLabel:SetPoint("TOPLEFT", scrollOutputTitle, "BOTTOMLEFT", 0, -6)
    scrollOutputLabel:SetPoint("RIGHT", scrollOutput, "RIGHT", -12, 0)
    stack:AddChild(scrollExample)

    refresh()
end)
