--- FluentWoW-Gallery – Pages/FeedbackPage.lua
-- Showcases: ProgressBar, ProgressRing, InfoBar, ContentDialog, Expander.
-------------------------------------------------------------------------------

local lib = FluentWoW
local Gallery = lib._gallery

local function createCardTitle(parent, text)
    local label = lib:CreateTextBlock(parent)
    label:SetStyle("Caption")
    label:SetColorKey("Color.Text.Secondary")
    label:SetText(text)
    return label
end

Gallery:RegisterPage("feedback", "Feedback", function(parent)
    local _, _, stack, refresh = Gallery:CreateDemoPage(parent)

    local header = lib:CreateTextBlock(stack)
    header:SetStyle("Header")
    header:SetText("Feedback Controls")
    stack:AddChild(header)

    local desc = lib:CreateTextBlock(stack)
    desc:SetText("Progress controls, InfoBars, expanders, and dialogs are grouped here using the same example, output, and options pattern as the WinUI Gallery.")
    desc:SetColorKey("Color.Text.Secondary")
    desc:SetWrapping(true)
    desc:SetWidth(700)
    stack:AddChild(desc)

    local progressExample, progressBody = Gallery:CreateExampleBlock(stack, "ProgressBar and ProgressRing examples.", 180)
    local progressArea = Gallery:CreateSurface(progressBody, "Color.Surface.Base")
    progressArea:SetPoint("TOPLEFT", progressBody, "TOPLEFT", 12, -12)
    progressArea:SetPoint("BOTTOMLEFT", progressBody, "BOTTOMLEFT", 12, 12)
    progressArea:SetWidth(420)

    local progressOutput = Gallery:CreateSurface(progressBody)
    progressOutput:SetPoint("TOPLEFT", progressArea, "TOPRIGHT", 12, 0)
    progressOutput:SetPoint("BOTTOMRIGHT", progressBody, "BOTTOMRIGHT", -12, 12)

    local determinate = lib:CreateProgressBar(progressArea)
    determinate:SetWidth(320)
    determinate:SetHeader("Determinate")
    determinate:SetValue(65)
    determinate:SetPoint("TOPLEFT", progressArea, "TOPLEFT", 16, -20)

    local indeterminate = lib:CreateProgressBar(progressArea)
    indeterminate:SetWidth(320)
    indeterminate:SetHeader("Indeterminate")
    indeterminate:SetIndeterminate(true)
    indeterminate:SetPoint("TOPLEFT", determinate, "BOTTOMLEFT", 0, -20)

    local pausedBar = lib:CreateProgressBar(progressArea)
    pausedBar:SetWidth(320)
    pausedBar:SetHeader("Paused")
    pausedBar:SetIndeterminate(true)
    pausedBar:SetPaused(true)
    pausedBar:SetPoint("TOPLEFT", indeterminate, "BOTTOMLEFT", 0, -20)

    local errorBar = lib:CreateProgressBar(progressArea)
    errorBar:SetWidth(320)
    errorBar:SetHeader("Error")
    errorBar:SetValue(40)
    errorBar:SetError(true)
    errorBar:SetPoint("TOPLEFT", pausedBar, "BOTTOMLEFT", 0, -20)

    local ringToggle = lib:CreateToggleSwitch(progressArea)
    ringToggle:SetHeader("Toggle ring")
    ringToggle:SetOnContent("Running")
    ringToggle:SetOffContent("Stopped")
    ringToggle:SetIsOn(true)
    ringToggle:SetPoint("TOPLEFT", errorBar, "BOTTOMLEFT", 0, -18)

    local ring = lib:CreateProgressRing(progressArea)
    ring:SetPoint("LEFT", ringToggle.Track, "RIGHT", 24, 0)
    ring:SetActive(true)

    local progressOutputTitle = createCardTitle(progressOutput, "Output")
    progressOutputTitle:SetPoint("TOPLEFT", progressOutput, "TOPLEFT", 12, -10)
    local progressOutputLabel = lib:CreateTextBlock(progressOutput)
    progressOutputLabel:SetText("ProgressBar states include running, paused, and error")
    progressOutputLabel:SetWrapping(true)
    progressOutputLabel:SetPoint("TOPLEFT", progressOutputTitle, "BOTTOMLEFT", 0, -6)
    progressOutputLabel:SetPoint("RIGHT", progressOutput, "RIGHT", -12, 0)
    ringToggle:SetOnToggled(function(_, isOn)
        ring:SetActive(isOn)
        progressOutputLabel:SetText(isOn and "ProgressRing running" or "ProgressRing stopped")
    end)
    stack:AddChild(progressExample)

    local infoExample, infoBody = Gallery:CreateExampleBlock(stack, "A closable InfoBar with icon, severity, and action options.", 250)
    local infoArea = Gallery:CreateSurface(infoBody, "Color.Surface.Base")
    infoArea:SetPoint("TOPLEFT", infoBody, "TOPLEFT", 12, -12)
    infoArea:SetPoint("BOTTOMLEFT", infoBody, "BOTTOMLEFT", 12, 12)
    infoArea:SetWidth(480)

    local infoOptions = Gallery:CreateSurface(infoBody)
    infoOptions:SetPoint("TOPLEFT", infoArea, "TOPRIGHT", 12, 0)
    infoOptions:SetPoint("BOTTOMRIGHT", infoBody, "BOTTOMRIGHT", -12, 12)

    local infoBar = lib:CreateInfoBar(infoArea)
    infoBar:SetWidth(440)
    infoBar:SetTitle("Title")
    infoBar:SetMessage("Essential app message for your users to be informed of, acknowledge, or take action on.")
    infoBar:SetPoint("TOPLEFT", infoArea, "TOPLEFT", 16, -16)
    infoBar:Open()

    local longInfoBar = lib:CreateInfoBar(infoArea)
    longInfoBar:SetWidth(440)
    longInfoBar:SetTitle("Download available")
    longInfoBar:SetMessage("A longer message demonstrates wrapping and auto-height behavior while leaving room for an inline action button.")
    longInfoBar:SetPoint("TOPLEFT", infoBar, "BOTTOMLEFT", 0, -12)
    local actionButton = lib:CreateButton(longInfoBar.ActionSlot, nil, "Accent")
    actionButton:SetText("Install")
    actionButton:SetWidth(92)
    longInfoBar:SetActionControl(actionButton)
    longInfoBar:Open()

    local infoOptionsTitle = createCardTitle(infoOptions, "Options")
    infoOptionsTitle:SetPoint("TOPLEFT", infoOptions, "TOPLEFT", 12, -10)

    local severityBox = lib:CreateComboBox(infoOptions)
    severityBox:SetWidth(180)
    severityBox:SetItems({
        { text = "Info", value = "Info" },
        { text = "Success", value = "Success" },
        { text = "Warning", value = "Warning" },
        { text = "Error", value = "Error" },
    })
    severityBox:SetSelectedIndex(1)
    severityBox:SetPoint("TOPLEFT", infoOptionsTitle, "BOTTOMLEFT", 0, -10)

    local openCheck = lib:CreateCheckBox(infoOptions)
    openCheck:SetText("Is open")
    openCheck:SetChecked(true)
    openCheck:SetPoint("TOPLEFT", severityBox, "BOTTOMLEFT", 0, -12)

    local iconCheck = lib:CreateCheckBox(infoOptions)
    iconCheck:SetText("Show icon")
    iconCheck:SetChecked(true)
    iconCheck:SetPoint("TOPLEFT", openCheck, "BOTTOMLEFT", 0, -8)

    local closeCheck = lib:CreateCheckBox(infoOptions)
    closeCheck:SetText("Show close button")
    closeCheck:SetChecked(true)
    closeCheck:SetPoint("TOPLEFT", iconCheck, "BOTTOMLEFT", 0, -8)

    severityBox:SetOnSelectionChanged(function(control)
        local severity = control:GetSelectedValue()
        infoBar:SetSeverity(severity)
        infoBar:SetTitle(severity)
        infoBar:SetMessage("This is a " .. severity:lower() .. " message.")
    end)
    openCheck:SetOnChanged(function(_, checked)
        if checked then infoBar:Open() else infoBar:Hide() end
    end)
    iconCheck:SetOnChanged(function(_, checked)
        infoBar:SetIconVisible(checked)
    end)
    closeCheck:SetOnChanged(function(_, checked)
        infoBar:SetClosable(checked)
    end)
    stack:AddChild(infoExample)

    local revealExample, revealBody = Gallery:CreateExampleBlock(stack, "Expander and ContentDialog examples.", 196)
    local revealArea = Gallery:CreateSurface(revealBody, "Color.Surface.Base")
    revealArea:SetPoint("TOPLEFT", revealBody, "TOPLEFT", 12, -12)
    revealArea:SetPoint("BOTTOMLEFT", revealBody, "BOTTOMLEFT", 12, 12)
    revealArea:SetWidth(420)

    local revealOutput = Gallery:CreateSurface(revealBody)
    revealOutput:SetPoint("TOPLEFT", revealArea, "TOPRIGHT", 12, 0)
    revealOutput:SetPoint("BOTTOMRIGHT", revealBody, "BOTTOMRIGHT", -12, 12)

    local expander = lib:CreateExpander(revealArea)
    expander:SetWidth(380)
    expander:SetTitle("Click to expand")
    expander:SetContentHeight(92)
    expander:SetPoint("TOPLEFT", revealArea, "TOPLEFT", 16, -16)
    local expContent = expander:GetContentFrame()
    local expText = lib:CreateTextBlock(expContent)
    expText:SetText("This is expandable content. It can contain any controls and should reflow without clipping.")
    expText:SetWrapping(true)
    expText:SetPoint("TOPLEFT", expContent, "TOPLEFT", 12, -8)
    expText:SetPoint("RIGHT", expContent, "RIGHT", -12, 0)

    local dialogButton = lib:CreateButton(revealArea, nil, "Accent")
    dialogButton:SetText("Show Dialog")
    dialogButton:SetPoint("TOPLEFT", expander, "BOTTOMLEFT", 0, -18)
    local dialogButton2 = lib:CreateButton(revealArea, nil, "Subtle")
    dialogButton2:SetText("Show Dialog Without Primary")
    dialogButton2:SetPoint("LEFT", dialogButton, "RIGHT", 12, 0)
    local demoDialog
    local secondaryDialog
    dialogButton:SetOnClick(function()
        if not demoDialog then
            demoDialog = lib:CreateContentDialog(nil, "WUILGalleryDemoDialog")
            demoDialog:SetTitle("Sample Dialog")
            demoDialog:SetBody("This is a ContentDialog with primary and secondary actions.")
            demoDialog:SetPrimaryButton("OK")
            demoDialog:SetSecondaryButton("Cancel")
        end
        demoDialog:Open()
    end)
    dialogButton2:SetOnClick(function()
        if not secondaryDialog then
            secondaryDialog = lib:CreateContentDialog(nil, "WUILGallerySecondaryDialog")
            secondaryDialog:SetTitle("Secondary-only Dialog")
            secondaryDialog:SetBody("This variant mirrors the no-default-button path from the WinUI Gallery by exposing only a secondary action.")
            secondaryDialog:SetSecondaryButton("Close")
        end
        secondaryDialog:Open()
    end)

    local revealOutputTitle = createCardTitle(revealOutput, "Output")
    revealOutputTitle:SetPoint("TOPLEFT", revealOutput, "TOPLEFT", 12, -10)
    local revealOutputLabel = lib:CreateTextBlock(revealOutput)
    revealOutputLabel:SetText("Expand the section or open the dialog")
    revealOutputLabel:SetWrapping(true)
    revealOutputLabel:SetPoint("TOPLEFT", revealOutputTitle, "BOTTOMLEFT", 0, -6)
    revealOutputLabel:SetPoint("RIGHT", revealOutput, "RIGHT", -12, 0)
    expander:SetOnToggled(function(_, expanded)
        revealOutputLabel:SetText(expanded and "Expander opened" or "Expander collapsed")
    end)
    stack:AddChild(revealExample)

    refresh()
end)
