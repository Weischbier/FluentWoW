--- FluentWoW-Gallery – Pages/AdvancedPage.lua
-- Showcases Phase 2+ controls: NumberBox, CommandBar, SegmentedControl,
-- Badge, TeachingTip, EmptyState, Skeleton.
-------------------------------------------------------------------------------

local lib = LibStub("FluentWoW-1.0")
local T = lib.Tokens
local Gallery = lib._gallery
local Icons = lib.Icons

Gallery:RegisterPage("advanced", "Advanced Controls", function(parent)
    local _, _, stack, refresh = Gallery:CreateDemoPage(parent)

    -- Header
    local header = lib:CreateTextBlock(stack)
    header:SetStyle("Header")
    header:SetText("Advanced Controls")
    stack:AddChild(header)

    local desc = lib:CreateTextBlock(stack)
    desc:SetText("Phase 2 controls: NumberBox, CommandBar, SegmentedControl, Badge, TeachingTip, EmptyState, and Skeleton loading.")
    desc:SetColorKey("Color.Text.Secondary")
    desc:SetWrapping(true)
    desc:SetWidth(680)
    stack:AddChild(desc)

    ---------------------------------------------------------------------------
    -- NumberBox
    ---------------------------------------------------------------------------
    local nbBlock, nbBody = Gallery:CreateExampleBlock(stack, "NumberBox — Validated numeric input with spin buttons.", 120)

    local exArea = Gallery:CreateSurface(nbBody)
    exArea:SetPoint("TOPLEFT", nbBody, "TOPLEFT", 12, -12)
    exArea:SetPoint("BOTTOMLEFT", nbBody, "BOTTOMLEFT", 12, 12)
    exArea:SetWidth(280)
    exArea.BG:SetColorTexture(T:GetColor("Color.Surface.Base"))

    local nb = lib:CreateNumberBox(exArea)
    nb:SetPoint("CENTER")
    nb:SetWidth(180)
    nb:SetHeader("Quantity")
    nb:SetMinimum(0)
    nb:SetMaximum(100)
    nb:SetStep(5)
    nb:SetValue(25)

    local nbOutput = lib:CreateTextBlock(nbBody)
    nbOutput:SetColorKey("Color.Text.Secondary")
    nbOutput:SetText("Value: 25")
    nbOutput:SetPoint("LEFT", exArea, "RIGHT", 16, 0)

    nb:SetOnValueChanged(function(_, value)
        nbOutput:SetText("Value: " .. tostring(value))
    end)

    stack:AddChild(nbBlock)

    ---------------------------------------------------------------------------
    -- SegmentedControl
    ---------------------------------------------------------------------------
    local segBlock, segBody = Gallery:CreateExampleBlock(stack, "SegmentedControl — Mutually exclusive segmented selector.", 80)

    local seg = lib:CreateSegmentedControl(segBody)
    seg:SetPoint("CENTER")
    seg:SetSize(300, 32)
    seg:SetItems({"Day", "Week", "Month", "Year"})
    seg:SetSelectedIndex(2)

    local segOutput = lib:CreateTextBlock(segBody)
    segOutput:SetColorKey("Color.Text.Secondary")
    segOutput:SetText("Selected: Week")
    segOutput:SetPoint("BOTTOM", segBody, "BOTTOM", 0, 8)

    seg:SetOnSelectionChanged(function(_, index, label)
        segOutput:SetText("Selected: " .. tostring(label))
    end)

    stack:AddChild(segBlock)

    ---------------------------------------------------------------------------
    -- Badge
    ---------------------------------------------------------------------------
    local badgeBlock, badgeBody = Gallery:CreateExampleBlock(stack, "Badge — Status pill indicators with severity colors.", 60)

    local badgeRow = CreateFrame("Frame", nil, badgeBody)
    badgeRow:SetPoint("CENTER")
    badgeRow:SetSize(400, 20)

    local appearances = {"Accent", "Success", "Warning", "Error", "Subtle"}
    local xOff = 0
    for _, app in ipairs(appearances) do
        local badge = lib:CreateBadge(badgeRow, nil, app)
        badge:SetText(app)
        badge:SetPoint("LEFT", badgeRow, "LEFT", xOff, 0)
        xOff = xOff + badge:GetWidth() + 8
    end

    stack:AddChild(badgeBlock)

    ---------------------------------------------------------------------------
    -- CommandBar
    ---------------------------------------------------------------------------
    local cmdBlock, cmdBody = Gallery:CreateExampleBlock(stack, "CommandBar — Toolbar with icon commands.", 60)

    local cmdBar = lib:CreateCommandBar(cmdBody)
    cmdBar:SetPoint("TOPLEFT", cmdBody, "TOPLEFT", 12, -12)
    cmdBar:SetPoint("RIGHT", cmdBody, "RIGHT", -12, 0)
    cmdBar:SetHeight(40)

    local cmdOutput = lib:CreateTextBlock(cmdBody)
    cmdOutput:SetColorKey("Color.Text.Secondary")
    cmdOutput:SetText("Click a command")
    cmdOutput:SetPoint("BOTTOMLEFT", cmdBody, "BOTTOMLEFT", 16, 6)

    cmdBar:SetCommands({
        { key = "add",    icon = Icons.Add,    tooltip = "Add new item",    onClick = function() cmdOutput:SetText("Add clicked") end },
        { key = "edit",   icon = Icons.Edit,   tooltip = "Edit selection",  onClick = function() cmdOutput:SetText("Edit clicked") end },
        { key = "delete", icon = Icons.Delete, tooltip = "Delete selected", onClick = function() cmdOutput:SetText("Delete clicked") end },
        { key = "share",  icon = Icons.Share,  tooltip = "Share",           onClick = function() cmdOutput:SetText("Share clicked") end },
    })
    cmdBar:SetOverflowEnabled(true)

    stack:AddChild(cmdBlock)

    ---------------------------------------------------------------------------
    -- EmptyState
    ---------------------------------------------------------------------------
    local emptyBlock, emptyBody = Gallery:CreateExampleBlock(stack, "EmptyState — Placeholder for empty content areas.", 200)

    local empty = lib:CreateEmptyState(emptyBody)
    empty:SetPoint("CENTER")
    empty:SetSize(300, 180)
    empty:SetIcon(Icons.Search)
    empty:SetTitle("No results found")
    empty:SetDescription("Try adjusting your search or filter to find what you're looking for.")

    local emptyAction = lib:CreateButton(empty, nil, "Accent")
    emptyAction:SetText("Clear filters")
    empty:SetActionControl(emptyAction)

    stack:AddChild(emptyBlock)

    ---------------------------------------------------------------------------
    -- Skeleton
    ---------------------------------------------------------------------------
    local skelBlock, skelBody = Gallery:CreateExampleBlock(stack, "Skeleton — Animated shimmer loading placeholders.", 120)

    local skelStack = lib:CreateStackLayout(skelBody, nil, "VERTICAL")
    skelStack:SetPoint("TOPLEFT", skelBody, "TOPLEFT", 16, -16)
    skelStack:SetWidth(300)
    skelStack:SetGap(8)

    local skel1 = lib:CreateSkeleton(skelStack)
    skel1:SetSize(200, 20)
    skelStack:AddChild(skel1)

    local skel2 = lib:CreateSkeleton(skelStack)
    skel2:SetSize(300, 14)
    skelStack:AddChild(skel2)

    local skel3 = lib:CreateSkeleton(skelStack)
    skel3:SetSize(260, 14)
    skelStack:AddChild(skel3)

    local skel4 = lib:CreateSkeleton(skelStack, nil, "circle")
    skel4:SetSize(40, 40)
    skel4:SetPoint("LEFT", skelBody, "LEFT", 340, 0)

    stack:AddChild(skelBlock)

    ---------------------------------------------------------------------------
    -- TeachingTip
    ---------------------------------------------------------------------------
    local tipBlock, tipBody = Gallery:CreateExampleBlock(stack, "TeachingTip — Contextual coach mark / teaching callout.", 100)

    local tipTarget = lib:CreateButton(tipBody, nil, "Accent")
    tipTarget:SetText("Show TeachingTip")
    tipTarget:SetPoint("CENTER")

    local tip = lib:CreateTeachingTip()
    tip:SetTitle("Did you know?")
    tip:SetBody("You can use TeachingTips to highlight features and guide users through your addon's interface.")
    tip:SetTarget(tipTarget, "BOTTOM")
    tip:SetClosable(true)

    tipTarget:SetOnClick(function()
        if tip:IsShown() then
            tip:Close()
        else
            tip:Open()
        end
    end)

    stack:AddChild(tipBlock)

    refresh()
end)
