--- FluentWoW-Gallery -- Pages/ToggleSwitchPage.lua
-- Mirrors WinUI Gallery ToggleSwitchPage.
-------------------------------------------------------------------------------

local lib = LibStub("FluentWoW-1.0")
local T = lib.Tokens
local Gallery = lib._gallery

Gallery:RegisterControlPage("ToggleSwitch", function(parent, item)
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
    -- Example 1: Simple ToggleSwitch
    ---------------------------------------------------------------------------
    local ex1 = Gallery:CreateControlExample(stack, {
        headerText = "A simple ToggleSwitch.",
        exampleHeight = 120,
    })

    local toggle1 = lib:CreateToggleSwitch(ex1.example)
    toggle1:SetHeader("Toggle work")
    toggle1:SetOnContent("Working")
    toggle1:SetOffContent("Do work")
    toggle1:SetPoint("CENTER")

    ex1.outputLabel:SetText("")
    toggle1:SetOnToggled(function(_, isOn)
        ex1.outputLabel:SetText("Toggled " .. (isOn and "On" or "Off") .. ".")
    end)

    local disableCheck = lib:CreateCheckBox(ex1.options)
    disableCheck:SetText("Disable toggle")
    disableCheck:SetPoint("TOPLEFT", ex1.optionsAnchor, "BOTTOMLEFT", 0, -8)
    disableCheck:SetOnChanged(function(_, checked)
        toggle1:SetEnabled(not checked)
    end)

    stack:AddChild(ex1.block)

    ---------------------------------------------------------------------------
    -- Example 2: ToggleSwitch with custom on/off labels
    ---------------------------------------------------------------------------
    local ex2 = Gallery:CreateControlExample(stack, {
        headerText = "A ToggleSwitch with custom header and content labels.",
        exampleHeight = 120,
        noOutput = true,
        noOptions = true,
    })

    local toggle2 = lib:CreateToggleSwitch(ex2.example)
    toggle2:SetHeader("Power")
    toggle2:SetOnContent("On")
    toggle2:SetOffContent("Off")
    toggle2:SetPoint("CENTER")

    stack:AddChild(ex2.block)

    refresh()
end)
