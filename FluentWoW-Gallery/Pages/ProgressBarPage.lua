--- FluentWoW-Gallery -- Pages/ProgressBarPage.lua
-- Mirrors WinUI Gallery ProgressBarPage: determinate, indeterminate, states, ring.
-------------------------------------------------------------------------------

local lib = LibStub("FluentWoW-1.0")
local T = lib.Tokens
local Gallery = lib._gallery

Gallery:RegisterControlPage("ProgressBar", function(parent, item)
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
    -- Example 1: Determinate ProgressBar
    ---------------------------------------------------------------------------
    local ex1 = Gallery:CreateControlExample(stack, {
        headerText = "A determinate ProgressBar.",
        exampleHeight = 120,
    })

    local pb1 = lib:CreateProgressBar(ex1.example)
    pb1:SetValue(45)
    pb1:SetHeader("Progress")
    pb1:SetPoint("CENTER")

    ex1.outputLabel:SetText("45%")

    local valSlider = lib:CreateSlider(ex1.options)
    valSlider:SetRange(0, 100)
    valSlider:SetValue(45)
    valSlider:SetHeader("Value")
    valSlider:SetShowValue(true)
    valSlider:SetPoint("TOPLEFT", ex1.optionsAnchor, "BOTTOMLEFT", 0, -8)
    valSlider:SetOnValueChanged(function(_, v)
        local val = math.floor(v)
        pb1:SetValue(val)
        ex1.outputLabel:SetText(val .. "%")
    end)

    stack:AddChild(ex1.block)

    ---------------------------------------------------------------------------
    -- Example 2: Indeterminate ProgressBar
    ---------------------------------------------------------------------------
    local ex2 = Gallery:CreateControlExample(stack, {
        headerText = "An indeterminate ProgressBar.",
        exampleHeight = 120,
        noOptions = true,
    })

    local pb2 = lib:CreateProgressBar(ex2.example)
    pb2:SetIndeterminate(true)
    pb2:SetHeader("Loading...")
    pb2:SetPoint("CENTER")

    ex2.outputLabel:SetText("Indeterminate")

    stack:AddChild(ex2.block)

    ---------------------------------------------------------------------------
    -- Example 3: ProgressBar visual states
    ---------------------------------------------------------------------------
    local ex3 = Gallery:CreateControlExample(stack, {
        headerText = "ProgressBar states: running, paused, error.",
        exampleHeight = 180,
        noOutput = true,
    })

    local pb3 = lib:CreateProgressBar(ex3.example)
    pb3:SetValue(60)
    pb3:SetHeader("State demo")
    pb3:SetPoint("CENTER")

    local stateCombo = lib:CreateComboBox(ex3.options)
    stateCombo:SetHeader("Visual state")
    stateCombo:SetItems({
        { text = "Running", value = "Running" },
        { text = "Paused",  value = "Paused"  },
        { text = "Error",   value = "Error"   },
    })
    stateCombo:SetSelectedIndex(1)
    stateCombo:SetPoint("TOPLEFT", ex3.optionsAnchor, "BOTTOMLEFT", 0, -8)
    stateCombo:SetOnSelectionChanged(function(_, _, itm)
        pb3:SetVisualState(itm.value)
    end)

    stack:AddChild(ex3.block)

    ---------------------------------------------------------------------------
    -- Example 4: ProgressRing
    ---------------------------------------------------------------------------
    local ex4 = Gallery:CreateControlExample(stack, {
        headerText = "A ProgressRing for non-blocking loading indicators.",
        exampleHeight = 120,
        noOutput = true,
    })

    local ring = lib:CreateProgressRing(ex4.example)
    ring:SetActive(true)
    ring:SetPoint("CENTER")

    local activeCheck = lib:CreateCheckBox(ex4.options)
    activeCheck:SetText("Active")
    activeCheck:SetChecked(true)
    activeCheck:SetPoint("TOPLEFT", ex4.optionsAnchor, "BOTTOMLEFT", 0, -8)
    activeCheck:SetOnChanged(function(_, checked)
        ring:SetActive(checked)
    end)

    stack:AddChild(ex4.block)

    refresh()
end)
