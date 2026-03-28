--- FluentWoW-Gallery -- Pages/ContentDialogPage.lua
-- Mirrors WinUI Gallery ContentDialogPage.
-------------------------------------------------------------------------------

local lib = LibStub("FluentWoW-1.0")
local T = lib.Tokens
local Gallery = lib._gallery

Gallery:RegisterControlPage("ContentDialog", function(parent, item)
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
    -- Example 1: Basic ContentDialog with Primary and Secondary buttons
    ---------------------------------------------------------------------------
    local ex1 = Gallery:CreateControlExample(stack, {
        headerText = "A basic ContentDialog with two buttons.",
        exampleHeight = 120,
        noOptions = true,
    })

    local showBtn1 = lib:CreateButton(ex1.example, nil, "Accent")
    showBtn1:SetText("Show dialog")
    showBtn1:SetPoint("CENTER")

    local dlg1 = lib:CreateContentDialog(UIParent)
    dlg1:SetTitle("Save your work?")
    dlg1:SetBody("You have unsaved changes. Would you like to save before continuing?")
    dlg1:SetPrimaryButton("Save", function()
        ex1.outputLabel:SetText("Result: Save clicked")
    end)
    dlg1:SetSecondaryButton("Don't save", function()
        ex1.outputLabel:SetText("Result: Don't save clicked")
    end)
    dlg1:SetClosable(true)

    ex1.outputLabel:SetText("")
    showBtn1:SetOnClick(function() dlg1:Open() end)
    dlg1:SetOnClosed(function(_, result)
        if result then
            ex1.outputLabel:SetText("Result: " .. tostring(result))
        end
    end)

    stack:AddChild(ex1.block)

    ---------------------------------------------------------------------------
    -- Example 2: ContentDialog with just a close button
    ---------------------------------------------------------------------------
    local ex2 = Gallery:CreateControlExample(stack, {
        headerText = "A simple informational dialog.",
        exampleHeight = 120,
        noOutput = true,
        noOptions = true,
    })

    local showBtn2 = lib:CreateButton(ex2.example, nil, "Subtle")
    showBtn2:SetText("Show info dialog")
    showBtn2:SetPoint("CENTER")

    local dlg2 = lib:CreateContentDialog(UIParent)
    dlg2:SetTitle("Information")
    dlg2:SetBody("This is a simple informational dialog with only a close button. Click outside or press the close button to dismiss it.")
    dlg2:SetClosable(true)
    dlg2:SetDismissOnOverlay(true)

    showBtn2:SetOnClick(function() dlg2:Open() end)

    stack:AddChild(ex2.block)

    refresh()
end)
