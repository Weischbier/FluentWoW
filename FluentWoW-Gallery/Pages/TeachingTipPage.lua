--- FluentWoW-Gallery -- Pages/TeachingTipPage.lua
-- Mirrors WinUI Gallery TeachingTipPage.
-------------------------------------------------------------------------------

local lib = LibStub("FluentWoW-1.0")
local T = lib.Tokens
local Gallery = lib._gallery

Gallery:RegisterControlPage("TeachingTip", function(parent, item)
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
    -- Example 1: Targeted TeachingTip
    ---------------------------------------------------------------------------
    local ex1 = Gallery:CreateControlExample(stack, {
        headerText = "A TeachingTip attached to a target element.",
        exampleHeight = 160,
        noOptions = true,
    })

    local targetBtn = lib:CreateButton(ex1.example, nil, "Accent")
    targetBtn:SetText("Click me for a tip!")
    targetBtn:SetPoint("CENTER")

    local tip1 = lib:CreateTeachingTip(ex1.example)
    tip1:SetTitle("Did you know?")
    tip1:SetBody("You can attach a TeachingTip to any control. It will appear near the target.")
    tip1:SetClosable(true)
    tip1:SetTarget(targetBtn, "TOP")

    ex1.outputLabel:SetText("")
    targetBtn:SetOnClick(function()
        tip1:Open()
        ex1.outputLabel:SetText("TeachingTip opened.")
    end)
    tip1:SetOnClosed(function()
        ex1.outputLabel:SetText("TeachingTip closed.")
    end)

    stack:AddChild(ex1.block)

    ---------------------------------------------------------------------------
    -- Example 2: Non-targeted (centered) TeachingTip
    ---------------------------------------------------------------------------
    local ex2 = Gallery:CreateControlExample(stack, {
        headerText = "A non-targeted TeachingTip with an action button.",
        exampleHeight = 140,
        noOutput = true,
        noOptions = true,
    })

    local showBtn = lib:CreateButton(ex2.example, nil, "Subtle")
    showBtn:SetText("Show TeachingTip")
    showBtn:SetPoint("CENTER")

    local tip2 = lib:CreateTeachingTip(ex2.example)
    tip2:SetTitle("Welcome!")
    tip2:SetBody("This is a non-targeted teaching tip. It can appear anywhere on screen.")
    tip2:SetClosable(true)

    local tipAction = lib:CreateButton(ex2.example, nil, "Accent")
    tipAction:SetText("Got it")
    tipAction:SetOnClick(function() tip2:Close() end)
    tip2:SetActionControl(tipAction)

    showBtn:SetOnClick(function() tip2:Open() end)

    stack:AddChild(ex2.block)

    refresh()
end)
