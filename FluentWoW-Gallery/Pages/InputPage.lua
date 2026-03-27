--- FluentWoW-Gallery – Pages/InputPage.lua
-- Showcases: CheckBox, RadioButton, ToggleSwitch, TextBox, SearchBox,
--            Slider, ComboBox.
-------------------------------------------------------------------------------

local lib = LibStub("FluentWoW-1.0")
local T = lib.Tokens
local Gallery = lib._gallery

local function createCardTitle(parent, text)
    local label = lib:CreateTextBlock(parent)
    label:SetStyle("Caption")
    label:SetColorKey("Color.Text.Secondary")
    label:SetText(text)
    return label
end

Gallery:RegisterPage("input", "Input Controls", function(parent)
    local _, _, stack, refresh = Gallery:CreateDemoPage(parent)

    local header = lib:CreateTextBlock(stack)
    header:SetStyle("Header")
    header:SetText("Input Controls")
    stack:AddChild(header)

    local desc = lib:CreateTextBlock(stack)
    desc:SetText("Mirrors the WinUI Gallery input page more closely: text boxes with headers and multiline behavior, two-state and three-state check boxes, content-rich toggle switches, and sliders with output and tick marks.")
    desc:SetColorKey("Color.Text.Secondary")
    desc:SetWrapping(true)
    desc:SetWidth(700)
    stack:AddChild(desc)

    local textExample, textBody = Gallery:CreateExampleBlock(stack, "TextBox and SearchBox examples.", 276)
    local textArea = Gallery:CreateSurface(textBody, "Color.Surface.Base")
    textArea:SetPoint("TOPLEFT", textBody, "TOPLEFT", 12, -12)
    textArea:SetPoint("BOTTOMLEFT", textBody, "BOTTOMLEFT", 12, 12)
    textArea:SetWidth(420)

    local textOutput = Gallery:CreateSurface(textBody)
    textOutput:SetPoint("TOPLEFT", textArea, "TOPRIGHT", 12, 0)
    textOutput:SetPoint("TOPRIGHT", textBody, "TOPRIGHT", -12, -12)
    textOutput:SetHeight(96)

    local textOptions = Gallery:CreateSurface(textBody)
    textOptions:SetPoint("TOPLEFT", textOutput, "BOTTOMLEFT", 0, -12)
    textOptions:SetPoint("BOTTOMRIGHT", textBody, "BOTTOMRIGHT", -12, 12)

    local simpleBox = lib:CreateTextBox(textArea)
    simpleBox:SetWidth(360)
    simpleBox:SetPlaceholder("Type here")
    simpleBox:SetPoint("TOPLEFT", textArea, "TOPLEFT", 16, -16)

    local headerBox = lib:CreateTextBox(textArea)
    headerBox:SetWidth(360)
    headerBox:SetHeader("Enter your name:")
    headerBox:SetPlaceholder("Name")
    headerBox:SetPoint("TOPLEFT", simpleBox, "BOTTOMLEFT", 0, -12)

    local readOnlyBox = lib:CreateTextBox(textArea)
    readOnlyBox:SetWidth(360)
    readOnlyBox:SetHeader("Read-only")
    readOnlyBox:SetText("I am super excited to be here!")
    readOnlyBox:SetReadOnly(true)
    readOnlyBox:SetPoint("TOPLEFT", headerBox, "BOTTOMLEFT", 0, -12)

    local searchBox = lib:CreateSearchBox(textArea)
    searchBox:SetWidth(360)
    searchBox:SetPoint("TOPLEFT", readOnlyBox, "BOTTOMLEFT", 0, -12)

    local multilineBox = lib:CreateTextBox(textArea)
    multilineBox:SetWidth(360)
    multilineBox:SetHeader("Multi-line")
    multilineBox:SetMultiline(true, 96)
    multilineBox:SetPlaceholder("Write multiple lines of text")
    multilineBox:SetPoint("TOPLEFT", searchBox, "BOTTOMLEFT", 0, -12)

    local textOutputTitle = createCardTitle(textOutput, "Output")
    textOutputTitle:SetPoint("TOPLEFT", textOutput, "TOPLEFT", 12, -10)
    local textOutputLabel = lib:CreateTextBlock(textOutput)
    textOutputLabel:SetText("Waiting for text input")
    textOutputLabel:SetWrapping(true)
    textOutputLabel:SetPoint("TOPLEFT", textOutputTitle, "BOTTOMLEFT", 0, -6)
    textOutputLabel:SetPoint("RIGHT", textOutput, "RIGHT", -12, 0)

    local function updateTextOutput(prefix, value)
        textOutputLabel:SetText(prefix .. ": " .. (value ~= "" and value or "<empty>"))
    end
    simpleBox:SetOnTextChanged(function(_, value) updateTextOutput("Simple", value) end)
    headerBox:SetOnTextChanged(function(_, value) updateTextOutput("Header", value) end)
    searchBox:SetOnTextChanged(function(_, value) updateTextOutput("Search", value) end)
    multilineBox:SetOnTextChanged(function(_, value) updateTextOutput("Multi-line", value:gsub("\n", " / ")) end)

    local textOptionsTitle = createCardTitle(textOptions, "Options")
    textOptionsTitle:SetPoint("TOPLEFT", textOptions, "TOPLEFT", 12, -10)
    local multilineToggle = lib:CreateCheckBox(textOptions)
    multilineToggle:SetText("Enable multi-line sample")
    multilineToggle:SetChecked(true)
    multilineToggle:SetPoint("TOPLEFT", textOptionsTitle, "BOTTOMLEFT", 0, -8)
    multilineToggle:SetOnChanged(function(_, checked)
        multilineBox:SetShown(checked)
    end)
    local readonlyToggle = lib:CreateCheckBox(textOptions)
    readonlyToggle:SetText("Keep read-only sample visible")
    readonlyToggle:SetChecked(true)
    readonlyToggle:SetPoint("TOPLEFT", multilineToggle, "BOTTOMLEFT", 0, -8)
    readonlyToggle:SetOnChanged(function(_, checked)
        readOnlyBox:SetShown(checked)
    end)
    stack:AddChild(textExample)

    local choiceExample, choiceBody = Gallery:CreateExampleBlock(stack, "CheckBox, RadioButton, and ComboBox selection patterns.", 240)
    local choiceArea = Gallery:CreateSurface(choiceBody, "Color.Surface.Base")
    choiceArea:SetPoint("TOPLEFT", choiceBody, "TOPLEFT", 12, -12)
    choiceArea:SetPoint("BOTTOMLEFT", choiceBody, "BOTTOMLEFT", 12, 12)
    choiceArea:SetWidth(420)

    local choiceOutput = Gallery:CreateSurface(choiceBody)
    choiceOutput:SetPoint("TOPLEFT", choiceArea, "TOPRIGHT", 12, 0)
    choiceOutput:SetPoint("BOTTOMRIGHT", choiceBody, "BOTTOMRIGHT", -12, 12)

    local twoState = lib:CreateCheckBox(choiceArea)
    twoState:SetText("Two-state CheckBox")
    twoState:SetPoint("TOPLEFT", choiceArea, "TOPLEFT", 16, -16)

    local threeState = lib:CreateCheckBox(choiceArea)
    threeState:SetText("Three-state CheckBox")
    threeState:SetThreeState(true)
    threeState:SetPoint("TOPLEFT", twoState, "BOTTOMLEFT", 0, -10)

    local selectAll = lib:CreateCheckBox(choiceArea)
    selectAll:SetText("Select all")
    selectAll:SetThreeState(true)
    selectAll:SetPoint("TOPLEFT", threeState, "BOTTOMLEFT", 0, -22)

    local option1 = lib:CreateCheckBox(choiceArea)
    option1:SetText("Option 1")
    option1:SetPoint("TOPLEFT", selectAll, "BOTTOMLEFT", 24, -8)
    local option2 = lib:CreateCheckBox(choiceArea)
    option2:SetText("Option 2")
    option2:SetChecked(true)
    option2:SetPoint("TOPLEFT", option1, "BOTTOMLEFT", 0, -8)
    local option3 = lib:CreateCheckBox(choiceArea)
    option3:SetText("Option 3")
    option3:SetPoint("TOPLEFT", option2, "BOTTOMLEFT", 0, -8)

    local rb1 = lib:CreateRadioButton(choiceArea)
    rb1:SetText("Option A")
    rb1:SetGroup("input-demo")
    rb1:SetSelected(true)
    rb1:SetPoint("TOPLEFT", option3, "BOTTOMLEFT", -24, -22)
    local rb2 = lib:CreateRadioButton(choiceArea)
    rb2:SetText("Option B")
    rb2:SetGroup("input-demo")
    rb2:SetPoint("TOPLEFT", rb1, "BOTTOMLEFT", 0, -8)

    local combo = lib:CreateComboBox(choiceArea)
    combo:SetWidth(240)
    combo:SetHeader("Accent color")
    combo:SetPlaceholder("Pick a color")
    combo:SetItems({
        { text = "Red", value = "red" },
        { text = "Green", value = "green" },
        { text = "Blue", value = "blue" },
        { text = "Yellow", value = "yellow" },
    })
    combo:SetSelectedIndex(2)
    combo:SetPoint("TOPLEFT", rb2, "BOTTOMLEFT", 0, -16)

    local comboPlaceholder = lib:CreateComboBox(choiceArea)
    comboPlaceholder:SetWidth(240)
    comboPlaceholder:SetHeader("No selection")
    comboPlaceholder:SetPlaceholder("Choose an option")
    comboPlaceholder:SetItems({
        { text = "Option 1", value = 1 },
        { text = "Option 2", value = 2 },
        { text = "Option 3", value = 3 },
    })
    comboPlaceholder:SetPoint("TOPLEFT", combo, "BOTTOMLEFT", 0, -12)

    local choiceOutputTitle = createCardTitle(choiceOutput, "Output")
    choiceOutputTitle:SetPoint("TOPLEFT", choiceOutput, "TOPLEFT", 12, -10)
    local choiceOutputLabel = lib:CreateTextBlock(choiceOutput)
    choiceOutputLabel:SetText("Interact with the selectors")
    choiceOutputLabel:SetWrapping(true)
    choiceOutputLabel:SetPoint("TOPLEFT", choiceOutputTitle, "BOTTOMLEFT", 0, -6)
    choiceOutputLabel:SetPoint("RIGHT", choiceOutput, "RIGHT", -12, 0)

    local function syncSelectAll()
        local checkedCount = 0
        if option1:IsChecked() then checkedCount = checkedCount + 1 end
        if option2:IsChecked() then checkedCount = checkedCount + 1 end
        if option3:IsChecked() then checkedCount = checkedCount + 1 end
        if checkedCount == 0 then
            selectAll:SetChecked(false)
        elseif checkedCount == 3 then
            selectAll:SetChecked(true)
        else
            selectAll:SetIndeterminate(true)
        end
        choiceOutputLabel:SetText("Select all state: " .. selectAll:GetCheckState())
    end

    twoState:SetOnChanged(function(_, checked)
        choiceOutputLabel:SetText("Two-state CheckBox: " .. tostring(checked))
    end)
    threeState:SetOnChanged(function(_, _, state)
        choiceOutputLabel:SetText("Three-state CheckBox: " .. state)
    end)
    selectAll:SetOnChanged(function(_, checked, state)
        if state ~= "Indeterminate" then
            option1:SetChecked(checked)
            option2:SetChecked(checked)
            option3:SetChecked(checked)
        end
        choiceOutputLabel:SetText("Select all toggled: " .. state)
    end)
    option1:SetOnChanged(syncSelectAll)
    option2:SetOnChanged(syncSelectAll)
    option3:SetOnChanged(syncSelectAll)
    combo:SetOnSelectionChanged(function(control)
        choiceOutputLabel:SetText("ComboBox selected: " .. tostring(control:GetSelectedValue()))
    end)
    comboPlaceholder:SetOnSelectionChanged(function(control)
        choiceOutputLabel:SetText("Placeholder ComboBox selected: " .. tostring(control:GetSelectedValue()))
    end)
    stack:AddChild(choiceExample)

    local motionExample, motionBody = Gallery:CreateExampleBlock(stack, "ToggleSwitch and Slider with live output.", 220)
    local motionArea = Gallery:CreateSurface(motionBody, "Color.Surface.Base")
    motionArea:SetPoint("TOPLEFT", motionBody, "TOPLEFT", 12, -12)
    motionArea:SetPoint("BOTTOMLEFT", motionBody, "BOTTOMLEFT", 12, 12)
    motionArea:SetWidth(420)

    local motionOutput = Gallery:CreateSurface(motionBody)
    motionOutput:SetPoint("TOPLEFT", motionArea, "TOPRIGHT", 12, 0)
    motionOutput:SetPoint("BOTTOMRIGHT", motionBody, "BOTTOMRIGHT", -12, 12)

    local toggle1 = lib:CreateToggleSwitch(motionArea)
    toggle1:SetWidth(360)
    toggle1:SetHeader("Simple ToggleSwitch")
    toggle1:SetPoint("TOPLEFT", motionArea, "TOPLEFT", 16, -20)

    local toggle2 = lib:CreateToggleSwitch(motionArea)
    toggle2:SetWidth(360)
    toggle2:SetHeader("Toggle work")
    toggle2:SetOnContent("Working")
    toggle2:SetOffContent("Do work")
    toggle2:SetIsOn(true)
    toggle2:SetPoint("TOPLEFT", toggle1, "BOTTOMLEFT", 0, -14)

    local ring = lib:CreateProgressRing(motionArea)
    ring:SetPoint("LEFT", toggle2.Track, "RIGHT", 28, 0)
    ring:SetActive(true)

    local slider1 = lib:CreateSlider(motionArea)
    slider1:SetWidth(320)
    slider1:SetHeader("Volume")
    slider1:SetRange(0, 100)
    slider1:SetValue(50)
    slider1:SetPoint("TOPLEFT", toggle2, "BOTTOMLEFT", 0, -22)

    local slider2 = lib:CreateSlider(motionArea)
    slider2:SetWidth(320)
    slider2:SetHeader("Slider with ticks")
    slider2:SetRange(500, 1000)
    slider2:SetValue(800)
    slider2:SetTickFrequency(100)
    slider2:SetSnapToTicks(true)
    slider2:SetPoint("TOPLEFT", slider1, "BOTTOMLEFT", 0, -22)

    local slider3 = lib:CreateSlider(motionArea)
    slider3:SetSize(100, 160)
    slider3:SetOrientation("VERTICAL")
    slider3:SetRange(-50, 50)
    slider3:SetTickFrequency(10)
    slider3:SetValue(10)
    slider3:SetPoint("TOPRIGHT", motionArea, "TOPRIGHT", -24, -18)

    local motionOutputTitle = createCardTitle(motionOutput, "Output")
    motionOutputTitle:SetPoint("TOPLEFT", motionOutput, "TOPLEFT", 12, -10)
    local motionOutputLabel = lib:CreateTextBlock(motionOutput)
    motionOutputLabel:SetText("Live values will appear here")
    motionOutputLabel:SetWrapping(true)
    motionOutputLabel:SetPoint("TOPLEFT", motionOutputTitle, "BOTTOMLEFT", 0, -6)
    motionOutputLabel:SetPoint("RIGHT", motionOutput, "RIGHT", -12, 0)

    toggle1:SetOnToggled(function(_, isOn)
        motionOutputLabel:SetText("Simple ToggleSwitch: " .. tostring(isOn))
    end)
    toggle2:SetOnToggled(function(_, isOn)
        ring:SetActive(isOn)
        motionOutputLabel:SetText("Work state: " .. (isOn and "Working" or "Idle"))
    end)
    slider1:SetOnValueChanged(function(_, value)
        motionOutputLabel:SetText("Volume: " .. tostring(math.floor(value + 0.5)))
    end)
    slider2:SetOnValueChanged(function(_, value)
        motionOutputLabel:SetText("Stepped value: " .. tostring(math.floor(value + 0.5)))
    end)
    slider3:SetOnValueChanged(function(_, value)
        motionOutputLabel:SetText("Vertical value: " .. tostring(math.floor(value + 0.5)))
    end)
    stack:AddChild(motionExample)

    refresh()
end)
