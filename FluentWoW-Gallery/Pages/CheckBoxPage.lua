--- FluentWoW-Gallery -- Pages/CheckBoxPage.lua
-- Mirrors WinUI Gallery CheckBoxPage: two-state, three-state, select-all.
-------------------------------------------------------------------------------

local lib = LibStub("FluentWoW-1.0")
local _T = lib.Tokens
local Gallery = lib._gallery

Gallery:RegisterControlPage("CheckBox", function(parent, item)
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
    -- Example 1: Two-state CheckBox
    ---------------------------------------------------------------------------
    local ex1 = Gallery:CreateControlExample(stack, {
        headerText = "A 2-state CheckBox.",
        exampleHeight = 100,
        noOptions = true,
    })

    local twoState = lib:CreateCheckBox(ex1.example)
    twoState:SetText("Two-state CheckBox")
    twoState:SetPoint("CENTER")

    ex1.outputLabel:SetText("")
    twoState:SetOnChanged(function(_, checked)
        ex1.outputLabel:SetText("CheckBox is " .. (checked and "checked" or "unchecked") .. ".")
    end)

    stack:AddChild(ex1.block)

    ---------------------------------------------------------------------------
    -- Example 2: Three-state CheckBox
    ---------------------------------------------------------------------------
    local ex2 = Gallery:CreateControlExample(stack, {
        headerText = "A 3-state CheckBox.",
        exampleHeight = 100,
        noOptions = true,
    })

    local threeState = lib:CreateCheckBox(ex2.example)
    threeState:SetText("Three-state CheckBox")
    threeState:SetThreeState(true)
    threeState:SetPoint("CENTER")

    ex2.outputLabel:SetText("")
    threeState:SetOnChanged(function(_, _, state)
        ex2.outputLabel:SetText("CheckBox state: " .. state)
    end)

    stack:AddChild(ex2.block)

    ---------------------------------------------------------------------------
    -- Example 3: Using a three-state CheckBox (select all)
    ---------------------------------------------------------------------------
    local ex3 = Gallery:CreateControlExample(stack, {
        headerText = "Using a 3-state CheckBox to represent mixed selection.",
        exampleHeight = 200,
        noOptions = true,
    })

    local selectAll = lib:CreateCheckBox(ex3.example)
    selectAll:SetText("Select all")
    selectAll:SetThreeState(true)
    selectAll:SetPoint("TOPLEFT", ex3.example, "TOPLEFT", 16, -16)

    local opt1 = lib:CreateCheckBox(ex3.example)
    opt1:SetText("Option 1")
    opt1:SetPoint("TOPLEFT", selectAll, "BOTTOMLEFT", 24, -8)

    local opt2 = lib:CreateCheckBox(ex3.example)
    opt2:SetText("Option 2")
    opt2:SetChecked(true)
    opt2:SetPoint("TOPLEFT", opt1, "BOTTOMLEFT", 0, -8)

    local opt3 = lib:CreateCheckBox(ex3.example)
    opt3:SetText("Option 3")
    opt3:SetPoint("TOPLEFT", opt2, "BOTTOMLEFT", 0, -8)

    local function syncSelectAll()
        local count = 0
        if opt1:IsChecked() then count = count + 1 end
        if opt2:IsChecked() then count = count + 1 end
        if opt3:IsChecked() then count = count + 1 end
        if count == 0 then
            selectAll:SetChecked(false)
        elseif count == 3 then
            selectAll:SetChecked(true)
        else
            selectAll:SetIndeterminate(true)
        end
        ex3.outputLabel:SetText("Selected: " .. count .. " of 3")
    end

    selectAll:SetOnChanged(function(_, checked, state)
        if state ~= "Indeterminate" then
            opt1:SetChecked(checked)
            opt2:SetChecked(checked)
            opt3:SetChecked(checked)
        end
        ex3.outputLabel:SetText("Select all: " .. state)
    end)

    opt1:SetOnChanged(syncSelectAll)
    opt2:SetOnChanged(syncSelectAll)
    opt3:SetOnChanged(syncSelectAll)

    ex3.outputLabel:SetText("Selected: 1 of 3")
    stack:AddChild(ex3.block)

    refresh()
end)
