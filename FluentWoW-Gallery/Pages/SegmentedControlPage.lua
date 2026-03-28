--- FluentWoW-Gallery -- Pages/SegmentedControlPage.lua
-- Mirrors WinUI Gallery SegmentedButton / custom control page.
-------------------------------------------------------------------------------

local lib = LibStub("FluentWoW-1.0")
local T = lib.Tokens
local Gallery = lib._gallery

Gallery:RegisterControlPage("SegmentedControl", function(parent, item)
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
    -- Example 1: Basic SegmentedControl
    ---------------------------------------------------------------------------
    local ex1 = Gallery:CreateControlExample(stack, {
        headerText = "A basic SegmentedControl.",
        exampleHeight = 120,
        noOptions = true,
    })

    local seg1 = lib:CreateSegmentedControl(ex1.example)
    seg1:SetItems({ "Day", "Week", "Month", "Year" })
    seg1:SetSelectedIndex(2)
    seg1:SetPoint("CENTER")

    ex1.outputLabel:SetText("Selected: Week")
    seg1:SetOnSelectionChanged(function(_, idx, label)
        ex1.outputLabel:SetText("Selected: " .. label)
    end)

    stack:AddChild(ex1.block)

    ---------------------------------------------------------------------------
    -- Example 2: SegmentedControl driving visibility
    ---------------------------------------------------------------------------
    local ex2 = Gallery:CreateControlExample(stack, {
        headerText = "A SegmentedControl that switches content.",
        exampleHeight = 160,
        noOutput = true,
        noOptions = true,
    })

    local seg2 = lib:CreateSegmentedControl(ex2.example)
    seg2:SetItems({ "Stormwind", "Orgrimmar", "Dalaran" })
    seg2:SetSelectedIndex(1)
    seg2:SetPoint("TOPLEFT", ex2.example, "TOPLEFT", 16, -16)

    local contentLabel = lib:CreateTextBlock(ex2.example)
    contentLabel:SetWrapping(true)
    contentLabel:SetWidth(360)
    contentLabel:SetPoint("TOPLEFT", seg2, "BOTTOMLEFT", 0, -16)

    local descriptions = {
        "Stormwind is the capital of the Alliance, a grand human city.",
        "Orgrimmar is the capital of the Horde, built into the red canyons of Durotar.",
        "Dalaran is a neutral mage city that floats above the Broken Isles.",
    }
    contentLabel:SetText(descriptions[1])

    seg2:SetOnSelectionChanged(function(_, idx)
        contentLabel:SetText(descriptions[idx] or "")
    end)

    stack:AddChild(ex2.block)

    refresh()
end)
