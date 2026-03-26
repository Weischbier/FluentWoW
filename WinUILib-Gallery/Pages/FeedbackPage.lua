--- WinUILib-Gallery – Pages/FeedbackPage.lua
-- Showcases: ProgressBar, ProgressRing, InfoBar, ContentDialog, Expander.
-------------------------------------------------------------------------------

local lib = WinUILib
local Gallery = lib._gallery

Gallery:RegisterPage("feedback", "Feedback", function(parent)
    local stack = lib:CreateStackLayout(parent, nil, "VERTICAL")
    stack:SetAllPoints(parent)
    stack:SetGap(16)
    stack:SetPadding(16, 0, 16, 0)

    local header = lib:CreateTextBlock(stack)
    header:SetStyle("Header")
    header:SetText("Feedback Controls")
    stack:AddChild(header)

    -- ProgressBar
    local pbTitle = lib:CreateTextBlock(stack)
    pbTitle:SetStyle("Title")
    pbTitle:SetText("ProgressBar")
    stack:AddChild(pbTitle)

    local pb = lib:CreateProgressBar(stack)
    pb:SetHeader("Determinate")
    pb:SetValue(65)
    stack:AddChild(pb)

    local pbI = lib:CreateProgressBar(stack)
    pbI:SetHeader("Indeterminate")
    pbI:SetIndeterminate(true)
    stack:AddChild(pbI)

    -- ProgressRing
    local prTitle = lib:CreateTextBlock(stack)
    prTitle:SetStyle("Title")
    prTitle:SetText("ProgressRing")
    stack:AddChild(prTitle)

    local pr = lib:CreateProgressRing(stack)
    pr:SetActive(true)
    stack:AddChild(pr)

    -- InfoBar
    local ibTitle = lib:CreateTextBlock(stack)
    ibTitle:SetStyle("Title")
    ibTitle:SetText("InfoBar")
    stack:AddChild(ibTitle)

    for _, sev in ipairs({"Info", "Success", "Warning", "Error"}) do
        local ib = lib:CreateInfoBar(stack)
        ib:SetSeverity(sev)
        ib:SetTitle(sev)
        ib:SetMessage("This is a " .. sev:lower() .. " message.")
        ib:Open()
        stack:AddChild(ib)
    end

    -- Expander
    local exTitle = lib:CreateTextBlock(stack)
    exTitle:SetStyle("Title")
    exTitle:SetText("Expander")
    stack:AddChild(exTitle)

    local ex = lib:CreateExpander(stack)
    ex:SetTitle("Click to expand")
    ex:SetContentHeight(80)
    local exContent = ex:GetContentFrame()
    local exText = lib:CreateTextBlock(exContent)
    exText:SetText("This is expandable content. It can contain any controls.")
    exText:SetWrapping(true)
    exText:SetPoint("TOPLEFT", exContent, "TOPLEFT", 12, -8)
    exText:SetPoint("RIGHT", exContent, "RIGHT", -12, 0)
    stack:AddChild(ex)

    -- ContentDialog trigger
    local dlgTitle = lib:CreateTextBlock(stack)
    dlgTitle:SetStyle("Title")
    dlgTitle:SetText("ContentDialog")
    stack:AddChild(dlgTitle)

    local dlgBtn = lib:CreateButton(stack, nil, "Accent")
    dlgBtn:SetText("Show Dialog")
    local demoDlg
    dlgBtn:SetOnClick(function()
        if not demoDlg then
            demoDlg = lib:CreateContentDialog(nil, "WUILGalleryDemoDialog")
            demoDlg:SetTitle("Sample Dialog")
            demoDlg:SetBody("This is a ContentDialog with primary and secondary actions.")
            demoDlg:SetPrimaryButton("OK", function() demoDlg:Close() end)
            demoDlg:SetSecondaryButton("Cancel", function() demoDlg:Close() end)
        end
        demoDlg:Open()
    end)
    stack:AddChild(dlgBtn)
end)
