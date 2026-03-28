--- FluentWoW-Gallery -- Pages/SliderPage.lua
-- Mirrors WinUI Gallery SliderPage.
-------------------------------------------------------------------------------

local lib = LibStub("FluentWoW-1.0")
local T = lib.Tokens
local Gallery = lib._gallery

Gallery:RegisterControlPage("Slider", function(parent, item)
    local _, _, stack, refresh = Gallery:CreateDemoPage(parent)

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
    -- Example 1: A simple Slider
    ---------------------------------------------------------------------------
    local ex1 = Gallery:CreateControlExample(stack, {
        headerText = "A simple Slider.",
        exampleHeight = 120,
    })

    local slider1 = lib:CreateSlider(ex1.example)
    slider1:SetRange(0, 100)
    slider1:SetValue(50)
    slider1:SetHeader("Volume")
    slider1:SetShowValue(true)
    slider1:SetPoint("CENTER")

    ex1.outputLabel:SetText("Value: 50")
    slider1:SetOnValueChanged(function(_, val)
        ex1.outputLabel:SetText("Value: " .. math.floor(val))
    end)

    local disableCheck = lib:CreateCheckBox(ex1.options)
    disableCheck:SetText("Disable slider")
    disableCheck:SetPoint("TOPLEFT", ex1.optionsAnchor, "BOTTOMLEFT", 0, -8)
    disableCheck:SetOnChanged(function(_, checked)
        slider1:SetEnabled(not checked)
    end)

    stack:AddChild(ex1.block)

    ---------------------------------------------------------------------------
    -- Example 2: Slider with steps and snapping
    ---------------------------------------------------------------------------
    local ex2 = Gallery:CreateControlExample(stack, {
        headerText = "A Slider with tick marks and step values.",
        exampleHeight = 120,
        noOptions = true,
    })

    local slider2 = lib:CreateSlider(ex2.example)
    slider2:SetRange(0, 100)
    slider2:SetValue(0)
    slider2:SetStep(10)
    slider2:SetTickFrequency(10)
    slider2:SetSnapToTicks(true)
    slider2:SetHeader("Control with ticks")
    slider2:SetShowValue(true)
    slider2:SetPoint("CENTER")

    ex2.outputLabel:SetText("Value: 0")
    slider2:SetOnValueChanged(function(_, val)
        ex2.outputLabel:SetText("Value: " .. math.floor(val))
    end)

    stack:AddChild(ex2.block)

    ---------------------------------------------------------------------------
    -- Example 3: Slider with custom range
    ---------------------------------------------------------------------------
    local ex3 = Gallery:CreateControlExample(stack, {
        headerText = "A Slider with a custom range and formatted value.",
        exampleHeight = 120,
        noOutput = true,
        noOptions = true,
    })

    local slider3 = lib:CreateSlider(ex3.example)
    slider3:SetRange(500, 1500)
    slider3:SetValue(1000)
    slider3:SetStep(50)
    slider3:SetHeader("Price range")
    slider3:SetShowValue(true)
    slider3:SetValueFormatter(function(v) return math.floor(v) .. "g" end)
    slider3:SetPoint("CENTER")

    stack:AddChild(ex3.block)

    refresh()
end)
