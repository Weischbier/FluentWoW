--- FluentWoW-Gallery -- Pages/NumberBoxPage.lua
-- Mirrors WinUI Gallery NumberBoxPage.
-------------------------------------------------------------------------------

local lib = LibStub("FluentWoW-1.0")
local T = lib.Tokens
local Gallery = lib._gallery

Gallery:RegisterControlPage("NumberBox", function(parent, item)
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
    -- Example 1: A basic NumberBox with spin buttons
    ---------------------------------------------------------------------------
    local ex1 = Gallery:CreateControlExample(stack, {
        headerText = "A NumberBox with spin-button UI.",
        exampleHeight = 140,
    })

    local nb1 = lib:CreateNumberBox(ex1.example)
    nb1:SetHeader("Enter a number:")
    nb1:SetMinimum(0)
    nb1:SetMaximum(100)
    nb1:SetStep(1)
    nb1:SetValue(42)
    nb1:SetPoint("TOPLEFT", ex1.example, "TOPLEFT", 16, -16)

    ex1.outputLabel:SetText("Value: 42")
    nb1:SetOnValueChanged(function(_, val)
        ex1.outputLabel:SetText("Value: " .. tostring(val))
    end)

    local disableCheck = lib:CreateCheckBox(ex1.options)
    disableCheck:SetText("Disable NumberBox")
    disableCheck:SetPoint("TOPLEFT", ex1.optionsAnchor, "BOTTOMLEFT", 0, -8)
    disableCheck:SetOnChanged(function(_, checked)
        nb1:SetEnabled(not checked)
    end)

    stack:AddChild(ex1.block)

    ---------------------------------------------------------------------------
    -- Example 2: NumberBox with custom step
    ---------------------------------------------------------------------------
    local ex2 = Gallery:CreateControlExample(stack, {
        headerText = "A NumberBox with a larger step value.",
        exampleHeight = 140,
        noOutput = true,
        noOptions = true,
    })

    local nb2 = lib:CreateNumberBox(ex2.example)
    nb2:SetHeader("Step of 5:")
    nb2:SetMinimum(0)
    nb2:SetMaximum(500)
    nb2:SetStep(5)
    nb2:SetValue(100)
    nb2:SetPoint("TOPLEFT", ex2.example, "TOPLEFT", 16, -16)

    stack:AddChild(ex2.block)

    refresh()
end)
