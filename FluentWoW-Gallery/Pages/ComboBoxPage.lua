--- FluentWoW-Gallery -- Pages/ComboBoxPage.lua
-- Mirrors WinUI Gallery ComboBoxPage.
-------------------------------------------------------------------------------

local lib = LibStub("FluentWoW-1.0")
local T = lib.Tokens
local Gallery = lib._gallery

Gallery:RegisterControlPage("ComboBox", function(parent, item)
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
    -- Example 1: A basic ComboBox with items
    ---------------------------------------------------------------------------
    local ex1 = Gallery:CreateControlExample(stack, {
        headerText = "A ComboBox with items defined.",
        exampleHeight = 140,
        noOptions = true,
    })

    local combo1 = lib:CreateComboBox(ex1.example)
    combo1:SetHeader("Colors")
    combo1:SetPlaceholder("Pick a color")
    combo1:SetItems({
        { text = "Blue",   value = "blue"   },
        { text = "Green",  value = "green"  },
        { text = "Red",    value = "red"    },
        { text = "Yellow", value = "yellow" },
    })
    combo1:SetPoint("TOPLEFT", ex1.example, "TOPLEFT", 16, -16)

    ex1.outputLabel:SetText("")
    combo1:SetOnSelectionChanged(function(_, idx, itm)
        ex1.outputLabel:SetText("Selected: " .. (itm and itm.text or "nil"))
    end)

    stack:AddChild(ex1.block)

    ---------------------------------------------------------------------------
    -- Example 2: ComboBox with pre-selected value
    ---------------------------------------------------------------------------
    local ex2 = Gallery:CreateControlExample(stack, {
        headerText = "A ComboBox with a pre-selected item.",
        exampleHeight = 140,
        noOutput = true,
        noOptions = true,
    })

    local combo2 = lib:CreateComboBox(ex2.example)
    combo2:SetHeader("Fonts")
    combo2:SetItems({
        { text = "Arial",      value = 1 },
        { text = "Friz Quadrata", value = 2 },
        { text = "Morpheus",   value = 3 },
        { text = "Skurri",     value = 4 },
    })
    combo2:SetSelectedIndex(2)
    combo2:SetPoint("TOPLEFT", ex2.example, "TOPLEFT", 16, -16)

    stack:AddChild(ex2.block)

    refresh()
end)
